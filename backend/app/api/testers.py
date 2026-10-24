"""Testers on any device, assigned to areas (ADR-024).

Devices register themselves; what is official is the tester. A tester:

- is assigned to an area with an assignment code from an IT admin (the
  former activation code), or directly by an IT admin;
- makes their own recovery code on a device they use (one use, valid until
  used) to sign in on another device, as well as getting one from an admin;
- sees the devices they use and signs some out; until email and SMS are set
  up the confirmation code is shown to IT admins, who pass it on.
"""

from __future__ import annotations

import json
import secrets
from datetime import datetime, timedelta
from typing import Any
from uuid import UUID, uuid4

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.api.deps import AdminDep, DbDep, UserDep
from app.api.installations import InstallationDep
from app.core.security import token_hash, utcnow
from app.db.database import Principal
from app.services.installations import normalise_code

router = APIRouter(prefix="/v1", tags=["testers"])

_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
CONFIRM_LIFETIME = timedelta(hours=24)
CONFIRM_ATTEMPTS = 5


class AssignmentOut(BaseModel):
    id: UUID
    collector_key: UUID
    area_id: UUID
    area: str
    level: str
    assigned_at: datetime
    by_code: bool


class AssignIn(BaseModel):
    code: str = Field(min_length=4, max_length=40)


class OwnCodeOut(BaseModel):
    code: str
    full_name: str


class TesterDevice(BaseModel):
    installation_id: UUID
    platform: str | None
    label: str | None
    short_code: str | None
    signed_in_via: str
    first_seen_at: datetime
    last_seen_at: datetime
    signed_out_at: datetime | None
    this_device: bool


class SignOutIn(BaseModel):
    installation_ids: list[UUID] = Field(min_length=1, max_length=50)


class SignOutRequested(BaseModel):
    request_id: UUID
    expires_at: datetime


class ConfirmIn(BaseModel):
    code: str = Field(min_length=4, max_length=12)


class SignOutDone(BaseModel):
    signed_out: int


def _snapshot(value: Any) -> dict[str, Any]:
    return value if isinstance(value, dict) else json.loads(value)


async def _holds(conn: AsyncConnection, key: UUID, installation: UUID | None) -> None:
    """The tester is signed in on this device (ADR-024)."""
    row = (
        await conn.execute(
            text(
                "SELECT signed_out_at FROM collector_device "
                "WHERE collector_key = :k AND installation_id = :i"
            ),
            {"k": key, "i": installation},
        )
    ).first()
    if row is None:
        # Not sent from this device yet: their profile reaches the server
        # with the first sync.
        raise HTTPException(status.HTTP_409_CONFLICT, "sync_first")
    if row.signed_out_at is not None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "collector_signed_out")


async def _assignments(conn: AsyncConnection, key: UUID) -> list[AssignmentOut]:
    rows = await conn.execute(
        text(
            "SELECT s.id, s.collector_key, s.admin_unit_id AS area_id, a.name AS area, a.level, "
            "s.assigned_at, s.activation_code_id IS NOT NULL AS by_code "
            "FROM collector_assignment s JOIN admin_unit a ON a.id = s.admin_unit_id "
            "WHERE s.collector_key = :k AND s.ended_at IS NULL ORDER BY s.assigned_at"
        ),
        {"k": key},
    )
    return [AssignmentOut(**r._mapping) for r in rows]


# ------------------------------------------------------------- on a device
@router.post("/collectors/{collector_key}/assign")
async def assign_with_code(
    collector_key: UUID, body: AssignIn, device: InstallationDep, db: DbDep
) -> list[AssignmentOut]:
    """An assignment code from an IT admin puts the tester officially in its
    area. The code works for as many testers as it was made for."""
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        code = (
            await conn.execute(
                text(
                    "SELECT id, admin_unit_id, expires_at, max_installations, used_count, "
                    "revoked_at FROM activation_code WHERE code_hash = :h FOR UPDATE"
                ),
                {"h": token_hash(normalise_code(body.code))},
            )
        ).first()
        if code is None or code.revoked_at is not None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "invalid_code")
        if code.expires_at <= utcnow():
            raise HTTPException(status.HTTP_410_GONE, "expired_code")
        already = (
            await conn.execute(
                text(
                    "SELECT 1 FROM collector_assignment WHERE collector_key = :k "
                    "AND admin_unit_id = :a AND ended_at IS NULL"
                ),
                {"k": collector_key, "a": code.admin_unit_id},
            )
        ).first()
        if already is None:
            if code.used_count >= code.max_installations:
                raise HTTPException(status.HTTP_409_CONFLICT, "code_used_up")
            await conn.execute(
                text(
                    "INSERT INTO collector_assignment (id, collector_key, admin_unit_id, "
                    "activation_code_id, installation_id) VALUES (:id, :k, :a, :c, :i)"
                ),
                {
                    "id": uuid4(),
                    "k": collector_key,
                    "a": code.admin_unit_id,
                    "c": code.id,
                    "i": device.installation_id,
                },
            )
            await conn.execute(
                text("UPDATE activation_code SET used_count = used_count + 1 WHERE id = :id"),
                {"id": code.id},
            )
            # A device without an area takes its tester's first one.
            await conn.execute(
                text(
                    "UPDATE installation SET admin_unit_id = :a "
                    "WHERE id = :i AND admin_unit_id IS NULL"
                ),
                {"a": code.admin_unit_id, "i": device.installation_id},
            )
            await conn.execute(
                text(
                    "INSERT INTO audit_log (installation_id, collector_key, platform, action, "
                    "entity, entity_id) VALUES (:i, :k, 'collect', 'collector.assigned', "
                    "'admin_unit', :a)"
                ),
                {"i": device.installation_id, "k": collector_key, "a": code.admin_unit_id},
            )
        return await _assignments(conn, collector_key)


@router.get("/collectors/{collector_key}/assignments")
async def tester_assignments(
    collector_key: UUID, device: InstallationDep, db: DbDep
) -> list[AssignmentOut]:
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        return await _assignments(conn, collector_key)


@router.post("/collectors/{collector_key}/recovery-code/own", status_code=status.HTTP_201_CREATED)
async def own_recovery_code(collector_key: UUID, device: InstallationDep, db: DbDep) -> OwnCodeOut:
    """A tester's own sign-in code for another device: one use, valid until
    used. Shown once; only its hash is kept."""
    code = "".join(secrets.choice(_ALPHABET) for _ in range(10))
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        profile = (
            await conn.execute(
                text("SELECT snapshot FROM collector_profile WHERE collector_key = :k"),
                {"k": collector_key},
            )
        ).first()
        if profile is None:
            raise HTTPException(status.HTTP_409_CONFLICT, "sync_first")
        await conn.execute(
            text(
                "INSERT INTO collector_recovery_code (id, code_hash, collector_key, "
                "issued_by_installation, expires_at) VALUES (:id, :h, :k, :i, NULL)"
            ),
            {
                "id": uuid4(),
                "h": token_hash(code),
                "k": collector_key,
                "i": device.installation_id,
            },
        )
        await conn.execute(
            text(
                "INSERT INTO audit_log (installation_id, collector_key, platform, action, entity) "
                "VALUES (:i, :k, 'collect', 'collector.own_code_made', 'collector')"
            ),
            {"i": device.installation_id, "k": collector_key},
        )
    return OwnCodeOut(
        code=f"{code[:5]}-{code[5:]}",
        full_name=_snapshot(profile.snapshot).get("full_name", ""),
    )


async def _devices(conn: AsyncConnection, key: UUID, this: UUID | None) -> list[TesterDevice]:
    rows = await conn.execute(
        text(
            "SELECT d.installation_id, i.platform, i.device_label AS label, i.short_code, "
            "d.signed_in_via, d.first_seen_at, d.last_seen_at, d.signed_out_at "
            "FROM collector_device d JOIN installation i ON i.id = d.installation_id "
            "WHERE d.collector_key = :k ORDER BY d.last_seen_at DESC"
        ),
        {"k": key},
    )
    return [TesterDevice(**r._mapping, this_device=r.installation_id == this) for r in rows]


@router.get("/collectors/{collector_key}/devices")
async def tester_devices(
    collector_key: UUID, device: InstallationDep, db: DbDep
) -> list[TesterDevice]:
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        return await _devices(conn, collector_key, device.installation_id)


@router.post("/collectors/{collector_key}/devices/sign-out", status_code=status.HTTP_201_CREATED)
async def request_sign_out(
    collector_key: UUID, body: SignOutIn, device: InstallationDep, db: DbDep
) -> SignOutRequested:
    """Asks to sign the tester out of other devices. A code confirms it:
    sent by email or SMS later; for now IT admins see it on the tester's
    page and pass it on."""
    if device.installation_id in body.installation_ids:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "not_this_device")
    code = "".join(secrets.choice("0123456789") for _ in range(6))
    request_id, expires = uuid4(), utcnow() + CONFIRM_LIFETIME
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        known = {
            r.installation_id
            for r in await conn.execute(
                text("SELECT installation_id FROM collector_device WHERE collector_key = :k"),
                {"k": collector_key},
            )
        }
        if not set(body.installation_ids) <= known:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "unknown_device")
        await conn.execute(
            text(
                "INSERT INTO collector_confirmation (id, collector_key, purpose, "
                "installation_ids, code, requested_by_installation, expires_at) "
                "VALUES (:id, :k, 'sign_out_devices', :ids, :c, :i, :e)"
            ),
            {
                "id": request_id,
                "k": collector_key,
                "ids": list(body.installation_ids),
                "c": code,
                "i": device.installation_id,
                "e": expires,
            },
        )
        await conn.execute(
            text(
                "INSERT INTO audit_log (installation_id, collector_key, platform, action, entity, "
                "entity_id) VALUES (:i, :k, 'collect', 'collector.sign_out_requested', "
                "'collector_confirmation', :id)"
            ),
            {"i": device.installation_id, "k": collector_key, "id": request_id},
        )
    return SignOutRequested(request_id=request_id, expires_at=expires)


@router.post("/collectors/{collector_key}/devices/sign-out/{request_id}/confirm")
async def confirm_sign_out(
    collector_key: UUID, request_id: UUID, body: ConfirmIn, device: InstallationDep, db: DbDep
) -> SignOutDone:
    async with db.transaction(Principal.system()) as conn:
        await _holds(conn, collector_key, device.installation_id)
        row = (
            await conn.execute(
                text(
                    "UPDATE collector_confirmation SET attempts = attempts + 1 "
                    "WHERE id = :id AND collector_key = :k AND confirmed_at IS NULL "
                    "RETURNING code, attempts, expires_at, installation_ids"
                ),
                {"id": request_id, "k": collector_key},
            )
        ).first()
    # The attempt is counted even when the code is wrong.
    if row is None or row.expires_at <= utcnow() or row.attempts > CONFIRM_ATTEMPTS:
        raise HTTPException(status.HTTP_410_GONE, "request_expired")
    if not secrets.compare_digest(row.code, "".join(ch for ch in body.code if ch.isdigit())):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "wrong_code")
    async with db.transaction(Principal.system()) as conn:
        done = (
            await conn.execute(
                text(
                    "UPDATE collector_device SET signed_out_at = now(), "
                    "signed_out_by_request = :id WHERE collector_key = :k "
                    "AND installation_id = ANY(:ids) AND signed_out_at IS NULL"
                ),
                {"id": request_id, "k": collector_key, "ids": list(row.installation_ids)},
            )
        ).rowcount
        await conn.execute(
            text("UPDATE collector_confirmation SET confirmed_at = now() WHERE id = :id"),
            {"id": request_id},
        )
        await conn.execute(
            text(
                "INSERT INTO audit_log (installation_id, collector_key, platform, action, entity, "
                "entity_id) VALUES (:i, :k, 'collect', 'collector.devices_signed_out', "
                "'collector_confirmation', :id)"
            ),
            {"i": device.installation_id, "k": collector_key, "id": request_id},
        )
    return SignOutDone(signed_out=done)


# ----------------------------------------------------------------- Console
class SignIn(BaseModel):
    installation_id: UUID
    platform: str | None
    label: str | None
    via: str
    at: datetime


class PendingConfirmation(BaseModel):
    id: UUID
    code: str
    devices: int
    created_at: datetime
    expires_at: datetime


class TesterAccess(BaseModel):
    assignments: list[AssignmentOut]
    devices: list[TesterDevice]
    sign_ins: list[SignIn]
    pending: list[PendingConfirmation]


class AssignAreaIn(BaseModel):
    area_id: UUID


@router.get("/collectors/assignments")
async def all_assignments(user: UserDep, db: DbDep) -> list[AssignmentOut]:
    """Current assignments, so the Console can tell assigned testers."""
    async with db.transaction(Principal.system()) as conn:
        rows = await conn.execute(
            text(
                "SELECT s.id, s.collector_key, s.admin_unit_id AS area_id, a.name AS area, "
                "a.level, s.assigned_at, s.activation_code_id IS NOT NULL AS by_code "
                "FROM collector_assignment s JOIN admin_unit a ON a.id = s.admin_unit_id "
                "WHERE s.ended_at IS NULL ORDER BY s.assigned_at"
            )
        )
        return [AssignmentOut(**r._mapping) for r in rows]


@router.get("/admin/collectors/{collector_key}/access")
async def tester_access(collector_key: UUID, admin: AdminDep, db: DbDep) -> TesterAccess:
    """A tester's areas, devices, sign-ins, and codes waiting to be passed on."""
    async with db.transaction(Principal.system()) as conn:
        sign_ins = await conn.execute(
            text(
                "SELECT s.installation_id, i.platform, i.device_label AS label, s.via, s.at "
                "FROM collector_signin s JOIN installation i ON i.id = s.installation_id "
                "WHERE s.collector_key = :k ORDER BY s.at DESC LIMIT 50"
            ),
            {"k": collector_key},
        )
        pending = await conn.execute(
            text(
                "SELECT id, code, cardinality(installation_ids) AS devices, created_at, "
                "expires_at FROM collector_confirmation WHERE collector_key = :k "
                "AND confirmed_at IS NULL AND expires_at > now() "
                "AND attempts < :max ORDER BY created_at DESC"
            ),
            {"k": collector_key, "max": CONFIRM_ATTEMPTS},
        )
        return TesterAccess(
            assignments=await _assignments(conn, collector_key),
            devices=await _devices(conn, collector_key, None),
            sign_ins=[SignIn(**r._mapping) for r in sign_ins],
            pending=[PendingConfirmation(**r._mapping) for r in pending],
        )


@router.post("/admin/collectors/{collector_key}/assignments", status_code=status.HTTP_201_CREATED)
async def assign_directly(
    collector_key: UUID, body: AssignAreaIn, admin: AdminDep, db: DbDep
) -> list[AssignmentOut]:
    """An IT admin assigns a tester to an area without a code."""
    async with db.transaction(Principal.system()) as conn:
        if (
            await conn.execute(text("SELECT 1 FROM admin_unit WHERE id = :a"), {"a": body.area_id})
        ).first() is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "unknown_area")
        await conn.execute(
            text(
                "INSERT INTO collector_assignment (id, collector_key, admin_unit_id, assigned_by) "
                "SELECT :id, :k, :a, :by WHERE NOT EXISTS (SELECT 1 FROM collector_assignment "
                "WHERE collector_key = :k AND admin_unit_id = :a AND ended_at IS NULL)"
            ),
            {"id": uuid4(), "k": collector_key, "a": body.area_id, "by": admin.user_id},
        )
        await conn.execute(
            text(
                "INSERT INTO audit_log (actor_id, collector_key, platform, action, entity, "
                "entity_id) VALUES (:by, :k, 'console', 'collector.assigned', 'admin_unit', :a)"
            ),
            {"by": admin.user_id, "k": collector_key, "a": body.area_id},
        )
        return await _assignments(conn, collector_key)


@router.post("/admin/collectors/{collector_key}/assignments/{assignment_id}/end")
async def end_assignment(
    collector_key: UUID, assignment_id: UUID, admin: AdminDep, db: DbDep
) -> list[AssignmentOut]:
    async with db.transaction(Principal.system()) as conn:
        done = (
            await conn.execute(
                text(
                    "UPDATE collector_assignment SET ended_at = now(), ended_by = :by "
                    "WHERE id = :id AND collector_key = :k AND ended_at IS NULL RETURNING 1"
                ),
                {"id": assignment_id, "k": collector_key, "by": admin.user_id},
            )
        ).first()
        if done is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        await conn.execute(
            text(
                "INSERT INTO audit_log (actor_id, collector_key, platform, action, entity, "
                "entity_id) VALUES (:by, :k, 'console', 'collector.assignment_ended', "
                "'collector_assignment', :id)"
            ),
            {"by": admin.user_id, "k": collector_key, "id": assignment_id},
        )
        return await _assignments(conn, collector_key)
