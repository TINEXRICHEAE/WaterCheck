"""Collector recovery codes (ADR-020).

A collector who lost a phone, or works on another one, gets back in as the
same person: an IT admin, or a stakeholder whose areas the collector works
in, issues a one-time code and passes it on (by phone for now; email or SMS
later). On any activated phone, "I already have a profile" takes the code
and brings the collector's latest details back under the same key, so
their earlier work stays theirs.
"""

from __future__ import annotations

import json
import secrets
from datetime import datetime, timedelta
from typing import Any, Literal
from uuid import UUID, uuid4

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy import text

from app.api.deps import DbDep, UserDep
from app.api.reference import AnyPrincipal
from app.api.research import may_recover_research
from app.core.security import token_hash, utcnow
from app.db.database import Principal

router = APIRouter(prefix="/v1/collectors", tags=["collectors"])

CODE_LIFETIME = timedelta(hours=24)
# Read aloud over the phone: no 0/O or 1/I.
_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"


def _snapshot(value: Any) -> dict[str, Any]:
    return value if isinstance(value, dict) else json.loads(value)


def _normalise(code: str) -> str:
    return "".join(ch for ch in code.upper() if ch.isalnum())


class RecoveryCodeOut(BaseModel):
    code: str
    expires_at: datetime
    full_name: str


class RecoverIn(BaseModel):
    code: str = Field(min_length=6, max_length=40)


class RecoveredCollector(BaseModel):
    collector_key: UUID
    snapshot: dict[str, Any]


@router.post("/{collector_key}/recovery-code", status_code=status.HTTP_201_CREATED)
async def issue_code(
    collector_key: UUID,
    user: UserDep,
    db: DbDep,
    side: Literal["water", "research"] | None = None,
) -> RecoveryCodeOut:
    """A one-time code for this collector, valid 24 hours. From the research
    pages (`side=research`), a profile made before sides that never tested
    water becomes a research profile (ADR-031)."""
    if side == "research" and user.side in ("research", "all"):
        async with db.transaction(Principal.system()) as conn:
            await conn.execute(
                text(
                    "UPDATE collector_profile SET side = 'research', "
                    'snapshot = snapshot || \'{"side": "research"}\'::jsonb '
                    "WHERE collector_key = :k AND side = 'water' "
                    "AND NOT EXISTS (SELECT 1 FROM test_session WHERE collector_key = :k) "
                    "AND NOT EXISTS (SELECT 1 FROM water_source WHERE collector_key = :k)"
                ),
                {"k": collector_key},
            )
    async with db.transaction(user) as conn:
        side = (
            await conn.execute(
                text("SELECT side FROM collector_profile WHERE collector_key = :k"),
                {"k": collector_key},
            )
        ).scalar_one_or_none()
        if side == "research":
            # Research collectors (ADR-031): an IT admin or the team of a
            # project they collect for.
            allowed = user.side in ("research", "all") and await may_recover_research(
                conn, collector_key
            )
        else:
            # Water testers: a water Console user who can see their tests or
            # sources (every water user, now areas no longer limit what is
            # seen), or an IT admin.
            allowed = user.is_admin or (
                user.side == "water"
                and (
                    await conn.execute(
                        text(
                            "SELECT 1 FROM test_session WHERE collector_key = :k "
                            "UNION ALL SELECT 1 FROM water_source WHERE collector_key = :k "
                            "LIMIT 1"
                        ),
                        {"k": collector_key},
                    )
                ).first()
                is not None
            )
    if not allowed:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "not_your_collector")
    code = "".join(secrets.choice(_ALPHABET) for _ in range(10))
    async with db.transaction(Principal.system()) as conn:
        profile = (
            await conn.execute(
                text("SELECT snapshot FROM collector_profile WHERE collector_key = :k"),
                {"k": collector_key},
            )
        ).first()
        if profile is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "collector_not_found")
        snap = _snapshot(profile.snapshot)
        expires = utcnow() + CODE_LIFETIME
        await conn.execute(
            text(
                "INSERT INTO collector_recovery_code (id, code_hash, collector_key, created_by, "
                "expires_at) VALUES (:id, :h, :k, :by, :exp)"
            ),
            {
                "id": uuid4(),
                "h": token_hash(code),
                "k": collector_key,
                "by": user.user_id,
                "exp": expires,
            },
        )
        await conn.execute(
            text(
                "INSERT INTO audit_log (actor_id, collector_key, platform, action, entity) "
                "VALUES (:a, :k, 'console', 'collector.recovery_code_issued', 'collector')"
            ),
            {"a": user.user_id, "k": collector_key},
        )
    return RecoveryCodeOut(
        code=f"{code[:5]}-{code[5:]}", expires_at=expires, full_name=snap.get("full_name", "")
    )


@router.post("/recover")
async def recover(body: RecoverIn, principal: AnyPrincipal, db: DbDep) -> RecoveredCollector:
    """Redeems a code on an activated phone; each code works once."""
    if principal.kind != "installation":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "phones_only")
    async with db.transaction(Principal.system()) as conn:
        row = (
            await conn.execute(
                text(
                    "UPDATE collector_recovery_code SET used_at = now(), "
                    "used_by_installation = :inst "
                    "WHERE code_hash = :h AND used_at IS NULL "
                    "AND (expires_at IS NULL OR expires_at > now()) "
                    "RETURNING collector_key, created_by IS NULL AS own"
                ),
                {"h": token_hash(_normalise(body.code)), "inst": principal.installation_id},
            )
        ).first()
        if row is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "invalid_code")
        profile = (
            await conn.execute(
                text("SELECT snapshot, side FROM collector_profile WHERE collector_key = :k"),
                {"k": row.collector_key},
            )
        ).one()
        # This device now holds the tester (again, if signed out before),
        # and the sign-in is in their trail (ADR-024).
        via = "own_code" if row.own else "admin_code"
        await conn.execute(
            text(
                "INSERT INTO collector_device (collector_key, installation_id, signed_in_via) "
                "VALUES (:k, :i, :via) ON CONFLICT (collector_key, installation_id) DO UPDATE "
                "SET signed_out_at = NULL, signed_out_by_request = NULL, last_seen_at = now(), "
                "signed_in_via = EXCLUDED.signed_in_via"
            ),
            {"k": row.collector_key, "i": principal.installation_id, "via": via},
        )
        await conn.execute(
            text(
                "INSERT INTO collector_signin (id, collector_key, installation_id, via, platform) "
                "SELECT :id, :k, :i, :via, platform FROM installation WHERE id = :i"
            ),
            {"id": uuid4(), "k": row.collector_key, "i": principal.installation_id, "via": via},
        )
        await conn.execute(
            text(
                "INSERT INTO audit_log (installation_id, collector_key, platform, action, entity) "
                "VALUES (:i, :k, 'collect', 'collector.recovered', 'collector')"
            ),
            {"i": principal.installation_id, "k": row.collector_key},
        )
    # The profile's side comes back with it (ADR-031), also for profiles
    # whose details were sent before sides.
    snap = _snapshot(profile.snapshot) | {"side": profile.side}
    return RecoveredCollector(collector_key=row.collector_key, snapshot=snap)
