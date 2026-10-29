"""Profiles people manage themselves (ADR-025).

Console users change their name, organisation and position at once. A new
email or phone is saved as not confirmed and confirmed with a code; until
email and SMS are set up the code is shown to IT admins ("Codes to pass
on"), who give it by phone. A stakeholder's own areas are a request an IT
admin decides, because areas decide what they can see. "Delete my account"
closes it for good and erases contact details; records stay. Testers have
the same contact confirmation, can sign out of one device, and can delete
their profile (every device signed out, contacts erased).
"""

from __future__ import annotations

import json
import re
import secrets
from datetime import datetime, timedelta
from typing import Literal
from uuid import UUID, uuid4

from fastapi import APIRouter, HTTPException, Request, status
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.api.admin import SideFilter
from app.api.deps import AdminDep, DbDep, UserDep
from app.api.installations import InstallationDep
from app.api.testers import _holds
from app.core.security import utcnow, verify_password
from app.db.database import Principal
from app.domain.phone import normalize_uganda_phone
from app.services.auth import record_acceptance

router = APIRouter(prefix="/v1", tags=["profile"])

# One-time-password style (2026-10-27): one code per person and contact,
# short-lived, replaced only after a short wait.
CODE_LIFETIME = timedelta(minutes=15)
RESEND_AFTER = timedelta(seconds=60)
MAX_ATTEMPTS = 5
_EMAIL = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

Channel = Literal["email", "phone"]


class ProfileIn(BaseModel):
    full_name: str = Field(min_length=2, max_length=120)
    organisation: str | None = Field(default=None, max_length=120)
    position: str | None = Field(default=None, max_length=120)


class ContactIn(BaseModel):
    channel: Channel
    value: str = Field(min_length=3, max_length=120)


class ContactPending(BaseModel):
    id: UUID
    channel: Channel
    value: str
    expires_at: datetime


class ConfirmIn(BaseModel):
    code: str = Field(min_length=4, max_length=12)


class AreaRequestIn(BaseModel):
    area_ids: list[UUID] = Field(min_length=1, max_length=20)
    reason: str = Field(min_length=3, max_length=500)


class AreaRequestOut(BaseModel):
    id: UUID
    user_id: UUID
    full_name: str
    areas: list[str]
    area_ids: list[UUID]
    current: list[str]
    reason: str
    created_at: datetime
    decided_at: datetime | None
    approved: bool | None


class LegalIn(BaseModel):
    version: int = Field(ge=1)
    # The side whose documents were accepted (ADR-031); older apps send
    # none and accept the combined documents.
    side: Literal["water", "research"] | None = None


class CloseIn(BaseModel):
    password: str = Field(min_length=1, max_length=200)


class DecideIn(BaseModel):
    approve: bool


class CodeToPass(BaseModel):
    """A confirmation code an IT admin passes on (ADR-024/025)."""

    id: UUID
    kind: Literal["contact", "sign_out_devices"]
    who: str
    user_id: UUID | None
    collector_key: UUID | None
    detail: str
    code: str
    created_at: datetime
    expires_at: datetime


def _normalise(channel: str, value: str) -> str:
    v = value.strip()
    if channel == "email":
        if not _EMAIL.match(v):
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "invalid_email")
        return v.lower()
    phone = normalize_uganda_phone(v)
    if phone is None:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "invalid_phone")
    return phone


async def _new_code(
    conn: AsyncConnection,
    *,
    user_id: UUID | None,
    collector_key: UUID | None,
    channel: str,
    value: str,
) -> ContactPending:
    now = utcnow()
    who = {"u": user_id, "k": collector_key, "ch": channel, "v": value}
    match = (
        "(CAST(:u AS uuid) IS NOT NULL AND user_id = CAST(:u AS uuid) OR "
        "CAST(:k AS uuid) IS NOT NULL AND collector_key = CAST(:k AS uuid)) "
        "AND channel = :ch AND value = :v AND confirmed_at IS NULL AND expires_at > now()"
    )
    recent = (
        await conn.execute(
            text(
                "SELECT id, created_at, expires_at FROM contact_confirmation "  # noqa: S608
                f"WHERE {match} ORDER BY created_at DESC LIMIT 1"
            ),
            who,
        )
    ).first()
    if recent is not None and now - recent.created_at < RESEND_AFTER:
        # Asked again at once: the same code stands.
        return ContactPending(
            id=recent.id, channel=channel, value=value, expires_at=recent.expires_at
        )
    # A new code replaces any older one.
    await conn.execute(
        text(f"UPDATE contact_confirmation SET expires_at = now() WHERE {match}"),  # noqa: S608
        who,
    )
    pending = ContactPending(
        id=uuid4(), channel=channel, value=value, expires_at=now + CODE_LIFETIME
    )
    await conn.execute(
        text(
            "INSERT INTO contact_confirmation (id, user_id, collector_key, channel, value, code, "
            "expires_at) VALUES (:id, :u, :k, :ch, :v, :c, :e)"
        ),
        {
            "id": pending.id,
            "u": user_id,
            "k": collector_key,
            "ch": channel,
            "v": value,
            "c": "".join(secrets.choice("0123456789") for _ in range(6)),
            "e": pending.expires_at,
        },
    )
    return pending


async def _check_code(
    conn: AsyncConnection, request_id: UUID, code: str, *, user_id: UUID | None, key: UUID | None
) -> tuple[str, str]:
    row = (
        await conn.execute(
            text(
                "UPDATE contact_confirmation SET attempts = attempts + 1 WHERE id = :id "
                "AND confirmed_at IS NULL AND user_id IS NOT DISTINCT FROM :u "
                "AND collector_key IS NOT DISTINCT FROM :k "
                "RETURNING code, attempts, expires_at, channel, value"
            ),
            {"id": request_id, "u": user_id, "k": key},
        )
    ).first()
    if row is None or row.expires_at <= utcnow() or row.attempts > MAX_ATTEMPTS:
        raise HTTPException(status.HTTP_410_GONE, "request_expired")
    if not secrets.compare_digest(row.code, "".join(ch for ch in code if ch.isdigit())):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "wrong_code")
    await conn.execute(
        text("UPDATE contact_confirmation SET confirmed_at = now() WHERE id = :id"),
        {"id": request_id},
    )
    return row.channel, row.value


async def _audit(conn: AsyncConnection, **values: object) -> None:
    await conn.execute(
        text(
            "INSERT INTO audit_log (actor_id, installation_id, collector_key, platform, action, "
            "entity, entity_id, after) VALUES (:actor, :inst, :ck, :platform, :action, :entity, "
            ":eid, CAST(:after AS jsonb))"
        ),
        {
            "actor": values.get("actor"),
            "inst": values.get("inst"),
            "ck": values.get("ck"),
            "platform": values.get("platform", "console"),
            "action": values["action"],
            "entity": values["entity"],
            "eid": values.get("eid"),
            "after": json.dumps(values.get("after")) if values.get("after") else None,
        },
    )


# ----------------------------------------------------------- Console users
@router.put("/me/profile", status_code=status.HTTP_204_NO_CONTENT)
async def edit_profile(body: ProfileIn, user: UserDep, db: DbDep) -> None:
    async with db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "UPDATE app_user SET full_name = :n, organisation = :o, position = :p "
                "WHERE id = :id"
            ),
            {
                "n": " ".join(body.full_name.split()),
                "o": (body.organisation or "").strip() or None,
                "p": (body.position or "").strip() or None,
                "id": user.user_id,
            },
        )
        await _audit(
            conn,
            actor=user.user_id,
            action="user.profile_edited",
            entity="app_user",
            eid=user.user_id,
            after=body.model_dump(),
        )


@router.post("/me/contacts", status_code=status.HTTP_201_CREATED)
async def change_contact(body: ContactIn, user: UserDep, db: DbDep) -> ContactPending:
    """Saves a new email or phone as not confirmed and makes a code."""
    value = _normalise(body.channel, body.value)
    column = "email" if body.channel == "email" else "phone"
    async with db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                f"UPDATE app_user SET {column} = :v, {column}_confirmed_at = NULL "  # noqa: S608
                "WHERE id = :id"
            ),
            {"v": value, "id": user.user_id},
        )
        pending = await _new_code(
            conn, user_id=user.user_id, collector_key=None, channel=body.channel, value=value
        )
        await _audit(
            conn,
            actor=user.user_id,
            action=f"user.{column}_changed",
            entity="app_user",
            eid=user.user_id,
        )
    return pending


@router.post("/me/contacts/{request_id}/confirm", status_code=status.HTTP_204_NO_CONTENT)
async def confirm_contact(request_id: UUID, body: ConfirmIn, user: UserDep, db: DbDep) -> None:
    async with db.transaction(Principal.system()) as conn:
        channel, value = await _check_code(
            conn, request_id, body.code, user_id=user.user_id, key=None
        )
    column = "email" if channel == "email" else "phone"
    async with db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                f"UPDATE app_user SET {column}_confirmed_at = now() "  # noqa: S608
                f"WHERE id = :id AND {column} = :v"
            ),
            {"id": user.user_id, "v": value},
        )


@router.get("/me/contacts/status")
async def contact_status(user: UserDep, db: DbDep) -> dict[str, bool]:
    async with db.transaction(Principal.system()) as conn:
        row = (
            await conn.execute(
                text(
                    "SELECT phone IS NOT NULL AND phone_confirmed_at IS NOT NULL AS phone, "
                    "email IS NOT NULL AND email_confirmed_at IS NOT NULL AS email "
                    "FROM app_user WHERE id = :id"
                ),
                {"id": user.user_id},
            )
        ).one()
    return {"phone": row.phone, "email": row.email}


async def _area_requests(
    conn: AsyncConnection, *, user_id: UUID | None = None, open_only: bool = False
) -> list[AreaRequestOut]:
    rows = await conn.execute(
        text(
            "SELECT r.id, r.user_id, u.full_name, r.area_ids, r.reason, r.created_at, "
            "r.decided_at, r.approved, "
            "ARRAY(SELECT a.name FROM admin_unit a WHERE a.id = ANY(r.area_ids) ORDER BY a.name) "
            "AS areas, "
            "ARRAY(SELECT a.name FROM user_scope s JOIN admin_unit a ON a.id = s.admin_unit_id "
            "WHERE s.user_id = r.user_id ORDER BY a.name) AS current "
            "FROM area_request r JOIN app_user u ON u.id = r.user_id "
            "WHERE (CAST(:u AS uuid) IS NULL OR r.user_id = CAST(:u AS uuid)) "
            "AND (NOT :open OR r.decided_at IS NULL) ORDER BY r.created_at DESC"
        ),
        {"u": user_id, "open": open_only},
    )
    return [AreaRequestOut(**r._mapping) for r in rows]


@router.post("/me/area-requests", status_code=status.HTTP_201_CREATED)
async def request_areas(body: AreaRequestIn, user: UserDep, db: DbDep) -> list[AreaRequestOut]:
    """Asks the IT admin for different areas (replacing the current ones)."""
    async with db.transaction(Principal.system()) as conn:
        known = (
            await conn.execute(
                text("SELECT count(*) FROM admin_unit WHERE id = ANY(:ids)"),
                {"ids": list(body.area_ids)},
            )
        ).scalar_one()
        if known != len(set(body.area_ids)):
            raise HTTPException(status.HTTP_404_NOT_FOUND, "unknown_area")
        # One open request at a time: a new one replaces it.
        await conn.execute(
            text(
                "UPDATE area_request SET decided_at = now(), approved = false "
                "WHERE user_id = :u AND decided_at IS NULL"
            ),
            {"u": user.user_id},
        )
        await conn.execute(
            text(
                "INSERT INTO area_request (id, user_id, area_ids, reason) VALUES (:id, :u, :a, :r)"
            ),
            {"id": uuid4(), "u": user.user_id, "a": list(body.area_ids), "r": body.reason},
        )
        await _audit(
            conn,
            actor=user.user_id,
            action="user.areas_requested",
            entity="app_user",
            eid=user.user_id,
            after={"areas": [str(a) for a in body.area_ids]},
        )
        return await _area_requests(conn, user_id=user.user_id)


@router.get("/me/area-requests")
async def my_area_requests(user: UserDep, db: DbDep) -> list[AreaRequestOut]:
    async with db.transaction(Principal.system()) as conn:
        return await _area_requests(conn, user_id=user.user_id)


@router.post("/me/legal", status_code=status.HTTP_204_NO_CONTENT)
async def accept_legal(body: LegalIn, request: Request, user: UserDep, db: DbDep) -> None:
    """Records that the person accepted this version of the Privacy Policy
    and Terms of Use (the version only goes up)."""
    async with db.transaction(Principal.system()) as conn:
        if body.side is None:
            await conn.execute(
                text(
                    "UPDATE app_user SET legal_version = :v, legal_accepted_at = now() "
                    "WHERE id = :id AND legal_version < :v"
                ),
                {"v": body.version, "id": user.user_id},
            )
        else:
            await conn.execute(
                text(
                    "UPDATE app_user SET legal = legal || jsonb_build_object(CAST(:s AS text), "
                    ":v), legal_accepted_at = now() WHERE id = :id "
                    "AND coalesce((legal->>CAST(:s AS text))::int, 0) < :v"
                ),
                {"s": body.side, "v": body.version, "id": user.user_id},
            )
            if user.user_id is not None:
                await record_acceptance(
                    conn,
                    user_id=user.user_id,
                    side=body.side,
                    version=body.version,
                    how="prompt",
                    ip=request.client.host if request.client else None,
                )
        await _audit(
            conn,
            actor=user.user_id,
            action="user.accepted_legal",
            entity="app_user",
            eid=user.user_id,
            after={"version": body.version, "side": body.side},
        )


@router.post("/me/close", status_code=status.HTTP_204_NO_CONTENT)
async def close_account(body: CloseIn, user: UserDep, db: DbDep) -> None:
    """Closes the account for good: no more sign-in, contact details erased,
    every session ended. Records already made stay, under the name."""
    async with db.transaction(Principal.system()) as conn:
        row = (
            await conn.execute(
                text("SELECT password_hash, role FROM app_user WHERE id = :id"),
                {"id": user.user_id},
            )
        ).one()
        if not verify_password(row.password_hash, body.password):
            raise HTTPException(status.HTTP_401_UNAUTHORIZED, "wrong_password")
        if row.role == "it_admin":
            others = (
                await conn.execute(
                    text(
                        "SELECT count(*) FROM app_user WHERE role = 'it_admin' AND is_active "
                        "AND id <> :id"
                    ),
                    {"id": user.user_id},
                )
            ).scalar_one()
            if others == 0:
                raise HTTPException(status.HTTP_409_CONFLICT, "last_it_admin")
        await conn.execute(
            text(
                "UPDATE app_user SET is_active = false, closed_at = now(), phone = NULL, "
                "email = NULL, organisation = NULL, phone_confirmed_at = NULL, "
                "email_confirmed_at = NULL WHERE id = :id"
            ),
            {"id": user.user_id},
        )
        await conn.execute(
            text(
                "UPDATE refresh_token SET revoked_at = now() "
                "WHERE user_id = :id AND revoked_at IS NULL"
            ),
            {"id": user.user_id},
        )
        await _audit(
            conn,
            actor=user.user_id,
            action="user.closed_own_account",
            entity="app_user",
            eid=user.user_id,
        )


# ----------------------------------------------------------------- testers
@router.post("/collectors/{collector_key}/contacts", status_code=status.HTTP_201_CREATED)
async def tester_contact(
    collector_key: UUID, body: ContactIn, device: InstallationDep, db: DbDep
) -> ContactPending:
    value = _normalise(body.channel, body.value)
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        return await _new_code(
            conn, user_id=None, collector_key=collector_key, channel=body.channel, value=value
        )


@router.post(
    "/collectors/{collector_key}/contacts/{request_id}/confirm",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def tester_confirm_contact(
    collector_key: UUID, request_id: UUID, body: ConfirmIn, device: InstallationDep, db: DbDep
) -> None:
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        channel, value = await _check_code(
            conn, request_id, body.code, user_id=None, key=collector_key
        )
    column = "confirmed_email" if channel == "email" else "confirmed_phone"
    async with db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(f"UPDATE collector_profile SET {column} = :v WHERE collector_key = :k"),  # noqa: S608
            {"v": value, "k": collector_key},
        )


@router.get("/collectors/{collector_key}/contacts/status")
async def tester_contact_status(
    collector_key: UUID, device: InstallationDep, db: DbDep
) -> dict[str, str | None]:
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        row = (
            await conn.execute(
                text(
                    "SELECT confirmed_phone, confirmed_email FROM collector_profile "
                    "WHERE collector_key = :k"
                ),
                {"k": collector_key},
            )
        ).first()
    return {
        "phone": row.confirmed_phone if row else None,
        "email": row.confirmed_email if row else None,
    }


@router.post("/collectors/{collector_key}/sign-out-here", status_code=status.HTTP_204_NO_CONTENT)
async def tester_sign_out_here(collector_key: UUID, device: InstallationDep, db: DbDep) -> None:
    """The tester leaves this device; a sign-in code brings them back."""
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        await conn.execute(
            text(
                "UPDATE collector_device SET signed_out_at = now() "
                "WHERE collector_key = :k AND installation_id = :i"
            ),
            {"k": collector_key, "i": device.installation_id},
        )
        await _audit(
            conn,
            inst=device.installation_id,
            ck=collector_key,
            platform="collect",
            action="collector.signed_out_here",
            entity="collector",
        )


@router.post("/collectors/{collector_key}/close", status_code=status.HTTP_204_NO_CONTENT)
async def tester_close(collector_key: UUID, device: InstallationDep, db: DbDep) -> None:
    """Deletes the tester's profile: every device signed out, assignments
    ended, contact details erased. Their tests and sources stay."""
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        snap = (
            await conn.execute(
                text("SELECT snapshot FROM collector_profile WHERE collector_key = :k"),
                {"k": collector_key},
            )
        ).first()
        if snap is not None:
            kept = snap.snapshot if isinstance(snap.snapshot, dict) else json.loads(snap.snapshot)
            for field in ("phone", "email", "organisation"):
                kept.pop(field, None)
            await conn.execute(
                text(
                    "UPDATE collector_profile SET snapshot = CAST(:s AS jsonb), closed_at = now(), "
                    "confirmed_phone = NULL, confirmed_email = NULL WHERE collector_key = :k"
                ),
                {"s": json.dumps(kept), "k": collector_key},
            )
        await conn.execute(
            text(
                "UPDATE collector_device SET signed_out_at = now() "
                "WHERE collector_key = :k AND signed_out_at IS NULL"
            ),
            {"k": collector_key},
        )
        await conn.execute(
            text(
                "UPDATE collector_assignment SET ended_at = now() "
                "WHERE collector_key = :k AND ended_at IS NULL"
            ),
            {"k": collector_key},
        )
        await _audit(
            conn,
            inst=device.installation_id,
            ck=collector_key,
            platform="collect",
            action="collector.closed_own_profile",
            entity="collector",
        )


# ------------------------------------------------------------------ admins
@router.get("/admin/codes-to-pass")
async def codes_to_pass(admin: AdminDep, db: DbDep, side: SideFilter = None) -> list[CodeToPass]:
    """Every confirmation code waiting for an IT admin to give by phone;
    with `side`, those of that side's people (ADR-031)."""
    async with db.transaction(Principal.system()) as conn:
        contacts = await conn.execute(
            text(
                "SELECT c.id, c.user_id, c.collector_key, c.channel, c.value, c.code, "
                "c.created_at, c.expires_at, coalesce(wc_user_label(u.id), "
                "wc_collector_label(p.collector_key), '?') AS who FROM contact_confirmation c "
                "LEFT JOIN app_user u ON u.id = c.user_id "
                "LEFT JOIN collector_profile p ON p.collector_key = c.collector_key "
                "WHERE c.confirmed_at IS NULL AND c.expires_at > now() AND c.attempts < :max "
                "AND (CAST(:side AS text) IS NULL OR coalesce(u.side, p.side) IN (:side, 'all'))"
            ),
            {"max": MAX_ATTEMPTS, "side": side},
        )
        devices = await conn.execute(
            text(
                "SELECT c.id, c.collector_key, c.code, c.created_at, c.expires_at, "
                "cardinality(c.installation_ids) AS n, "
                "coalesce(wc_collector_label(p.collector_key), '?') AS who "
                "FROM collector_confirmation c "
                "LEFT JOIN collector_profile p ON p.collector_key = c.collector_key "
                "WHERE c.confirmed_at IS NULL AND c.expires_at > now() AND c.attempts < :max "
                "AND (CAST(:side AS text) IS NULL OR p.side = :side)"
            ),
            {"max": MAX_ATTEMPTS, "side": side},
        )
        out = [
            CodeToPass(
                id=r.id,
                kind="contact",
                who=r.who,
                user_id=r.user_id,
                collector_key=r.collector_key,
                detail=f"{r.channel}: {r.value}",
                code=r.code,
                created_at=r.created_at,
                expires_at=r.expires_at,
            )
            for r in contacts
        ] + [
            CodeToPass(
                id=r.id,
                kind="sign_out_devices",
                who=r.who,
                user_id=None,
                collector_key=r.collector_key,
                detail=f"sign out {r.n} device(s)",
                code=r.code,
                created_at=r.created_at,
                expires_at=r.expires_at,
            )
            for r in devices
        ]
    return sorted(out, key=lambda c: c.created_at, reverse=True)


@router.get("/admin/area-requests")
async def area_requests(admin: AdminDep, db: DbDep) -> list[AreaRequestOut]:
    async with db.transaction(Principal.system()) as conn:
        return await _area_requests(conn, open_only=True)


@router.post("/admin/area-requests/{request_id}/decide")
async def decide_area_request(
    request_id: UUID, body: DecideIn, admin: AdminDep, db: DbDep
) -> list[AreaRequestOut]:
    """Approving replaces the person's areas with those asked for."""
    async with db.transaction(Principal.system()) as conn:
        row = (
            await conn.execute(
                text(
                    "UPDATE area_request SET decided_at = now(), decided_by = :by, approved = :ok "
                    "WHERE id = :id AND decided_at IS NULL RETURNING user_id, area_ids"
                ),
                {"id": request_id, "by": admin.user_id, "ok": body.approve},
            )
        ).first()
        if row is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        if body.approve:
            await conn.execute(
                text("DELETE FROM user_scope WHERE user_id = :u"), {"u": row.user_id}
            )
            await conn.execute(
                text(
                    "INSERT INTO user_scope (user_id, admin_unit_id) "
                    "SELECT :u, unnest(CAST(:a AS uuid[]))"
                ),
                {"u": row.user_id, "a": list(row.area_ids)},
            )
        await _audit(
            conn,
            actor=admin.user_id,
            action="user.areas_approved" if body.approve else "user.areas_declined",
            entity="app_user",
            eid=row.user_id,
            after={"areas": [str(a) for a in row.area_ids]},
        )
        return await _area_requests(conn, open_only=True)
