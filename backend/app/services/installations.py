"""Collect installations: activation codes, activation and signed requests
(F-AUTH-4, F-AUTH-7, ADR-009). Collectors never have accounts."""

from __future__ import annotations

import secrets
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from uuid import UUID, uuid4

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.core.config import Settings
from app.core.security import (
    SecretBox,
    new_token,
    sign_request,
    signatures_match,
    token_hash,
    utcnow,
)
from app.db.database import Database, Principal

# No 0/O, 1/I/L: codes are read out and typed in by people.
_CODE_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"


def new_activation_code() -> str:
    """12 characters in groups of four, e.g. ``K7QM-RT4W-9XHB`` (~59 bits)."""
    raw = "".join(secrets.choice(_CODE_ALPHABET) for _ in range(12))
    return "-".join(raw[i : i + 4] for i in range(0, 12, 4))


def new_short_code() -> str:
    """The installation's short ID for SMS (`I:7Q2K`, SPEC §8.5)."""
    return "".join(secrets.choice(_CODE_ALPHABET) for _ in range(4))


async def ensure_short_code(conn: AsyncConnection, installation_id: UUID) -> str:
    """Returns the installation's short code, assigning one if missing
    (installations activated before P8)."""
    existing = (
        await conn.execute(
            text("SELECT short_code FROM installation WHERE id = :id"), {"id": installation_id}
        )
    ).scalar_one()
    if existing:
        return str(existing)
    for _ in range(20):
        code = new_short_code()
        taken = (
            await conn.execute(
                text("SELECT 1 FROM installation WHERE short_code = :c"), {"c": code}
            )
        ).first()
        if taken is None:
            await conn.execute(
                text("UPDATE installation SET short_code = :c WHERE id = :id"),
                {"c": code, "id": installation_id},
            )
            return code
    raise InstallationError("no_short_code")


def normalise_code(code: str) -> str:
    return "".join(c for c in code.upper() if c.isalnum())


class InstallationError(Exception):
    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code


@dataclass(frozen=True)
class IssuedCode:
    id: UUID
    code: str
    expires_at: datetime
    max_installations: int


@dataclass(frozen=True)
class Activation:
    installation_id: UUID
    secret: str
    area_id: UUID
    area_code: str
    area_name: str
    area_level: str
    server_time: datetime
    short_code: str = ""


async def create_activation_code(
    conn: AsyncConnection,
    settings: Settings,
    *,
    area_code: str,
    created_by: UUID | None,
    max_installations: int = 5,
    days: int | None = None,
) -> IssuedCode:
    """Creates a code bound to an area. Only its hash is stored; the code is
    shown once (SPEC §9.1 "leaked activation code")."""
    area = (
        await conn.execute(text("SELECT id FROM admin_unit WHERE code = :c"), {"c": area_code})
    ).scalar_one_or_none()
    if area is None:
        raise InstallationError("unknown_area")
    code = new_activation_code()
    issued = IssuedCode(
        id=uuid4(),
        code=code,
        expires_at=utcnow() + timedelta(days=days or settings.activation_code_days),
        max_installations=max_installations,
    )
    await conn.execute(
        text(
            "INSERT INTO activation_code (id, code_hash, admin_unit_id, expires_at, "
            "max_installations, created_by) VALUES (:id, :h, :a, :e, :m, :by)"
        ),
        {
            "id": issued.id,
            "h": token_hash(normalise_code(code)),
            "a": area,
            "e": issued.expires_at,
            "m": max_installations,
            "by": created_by,
        },
    )
    await _audit(conn, created_by, None, "activation_code.created", "activation_code", issued.id)
    return issued


class InstallationService:
    def __init__(self, db: Database, settings: Settings) -> None:
        self.db = db
        self.settings = settings
        self.box = SecretBox(settings.secret_key.get_secret_value())

    async def activate(
        self, code: str, *, platform: str | None, app_version: str | None
    ) -> Activation:
        now = utcnow()
        async with self.db.transaction(Principal.auth()) as conn:
            row = (
                await conn.execute(
                    text(
                        "SELECT c.id, c.admin_unit_id, c.expires_at, c.max_installations, "
                        "c.used_count, c.revoked_at, a.code, a.name, a.level "
                        "FROM activation_code c JOIN admin_unit a ON a.id = c.admin_unit_id "
                        "WHERE c.code_hash = :h FOR UPDATE OF c"
                    ),
                    {"h": token_hash(normalise_code(code))},
                )
            ).one_or_none()
            if row is None or row.revoked_at is not None:
                raise InstallationError("invalid_code")
            if row.expires_at <= now:
                raise InstallationError("expired_code")
            if row.used_count >= row.max_installations:
                raise InstallationError("code_used_up")
            secret = new_token()
            installation_id = uuid4()
            await conn.execute(
                text(
                    "INSERT INTO installation (id, activation_code_id, admin_unit_id, "
                    "secret_encrypted, platform, app_version, last_seen_at) "
                    "VALUES (:id, :c, :a, :s, :p, :v, :now)"
                ),
                {
                    "id": installation_id,
                    "c": row.id,
                    "a": row.admin_unit_id,
                    "s": self.box.seal(secret),
                    "p": platform,
                    "v": app_version,
                    "now": now,
                },
            )
            await conn.execute(
                text("UPDATE activation_code SET used_count = used_count + 1 WHERE id = :id"),
                {"id": row.id},
            )
            short_code = await ensure_short_code(conn, installation_id)
            await _audit(
                conn,
                None,
                installation_id,
                "installation.activated",
                "installation",
                installation_id,
            )
        return Activation(
            installation_id=installation_id,
            secret=secret,
            area_id=row.admin_unit_id,
            area_code=row.code,
            area_name=row.name,
            area_level=row.level,
            server_time=now,
            short_code=short_code,
        )

    async def verify(
        self,
        *,
        installation_id: str | None,
        timestamp: str | None,
        signature: str | None,
        method: str,
        path: str,
        body: bytes,
        nonce: str | None = None,
    ) -> Principal:
        """Checks a signed Collect request and returns its principal.

        The client signs with server-corrected time (it learns the offset at
        activation and from each response's ``Date``), so a wrong device clock
        does not lock collectors out (SPEC §5.2)."""
        if not (installation_id and timestamp and signature):
            raise InstallationError("unsigned_request")
        try:
            inst_id = UUID(installation_id)
            sent_at = datetime.fromtimestamp(int(timestamp), tz=UTC)
        except ValueError as e:
            raise InstallationError("unsigned_request") from e
        now = utcnow()
        if abs((now - sent_at).total_seconds()) > self.settings.signature_window_seconds:
            raise InstallationError("stale_request")
        async with self.db.transaction(Principal.auth()) as conn:
            row = (
                await conn.execute(
                    text(
                        "SELECT admin_unit_id, secret_encrypted, revoked_at "
                        "FROM installation WHERE id = :id"
                    ),
                    {"id": inst_id},
                )
            ).one_or_none()
            if row is None:
                raise InstallationError("invalid_signature")
            if row.revoked_at is not None:
                raise InstallationError("installation_revoked")
            expected = sign_request(
                self.box.open(row.secret_encrypted), method, path, timestamp, body, nonce
            )
            if not signatures_match(expected, signature):
                raise InstallationError("invalid_signature")
            fresh = (
                await conn.execute(
                    text(
                        "INSERT INTO request_nonce (installation_id, signature) VALUES (:i, :s) "
                        "ON CONFLICT DO NOTHING RETURNING 1"
                    ),
                    {"i": inst_id, "s": signature},
                )
            ).scalar_one_or_none()
            if fresh is None:
                raise InstallationError("replayed_request")
            await conn.execute(
                text("UPDATE installation SET last_seen_at = :now WHERE id = :id"),
                {"now": now, "id": inst_id},
            )
            # Old nonces cannot be replayed anyway (outside the time window).
            await conn.execute(
                text("DELETE FROM request_nonce WHERE seen_at < :cutoff"),
                {"cutoff": now - timedelta(seconds=2 * self.settings.signature_window_seconds)},
            )
        return Principal(
            kind="installation", installation_id=inst_id, scope_units=(row.admin_unit_id,)
        )

    async def revoke(self, installation_id: UUID, *, by: UUID | None) -> bool:
        async with self.db.transaction(Principal.system()) as conn:
            done = (
                await conn.execute(
                    text(
                        "UPDATE installation SET revoked_at = now() "
                        "WHERE id = :id AND revoked_at IS NULL RETURNING id"
                    ),
                    {"id": installation_id},
                )
            ).scalar_one_or_none()
            if done is not None:
                await _audit(
                    conn,
                    by,
                    installation_id,
                    "installation.revoked",
                    "installation",
                    installation_id,
                )
        return done is not None


async def _audit(
    conn: AsyncConnection,
    actor: UUID | None,
    installation: UUID | None,
    action: str,
    entity: str,
    entity_id: UUID,
) -> None:
    await conn.execute(
        text(
            "INSERT INTO audit_log (actor_id, installation_id, platform, action, entity, "
            "entity_id) VALUES (:a, :i, 'api', :action, :entity, :eid)"
        ),
        {"a": actor, "i": installation, "action": action, "entity": entity, "eid": entity_id},
    )
