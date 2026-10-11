"""People management for the IT admin (F-ADM-1, F-AUTH-6; SPEC P11).

Users sit at any level (village to national) through one or more areas,
which is what the alert chain follows (docs/PLAN.md §3). Every change is
written to the audit log with the admin who made it.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from datetime import datetime
from typing import Any
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.core.security import hash_password, temporary_password


class AdminError(Exception):
    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code


@dataclass
class UserArea:
    id: UUID
    code: str
    name: str
    level: str


@dataclass
class UserSummary:
    id: UUID
    username: str
    full_name: str
    organisation: str | None
    position: str | None
    phone: str | None
    email: str | None
    role: str
    is_active: bool
    must_change_password: bool
    locked: bool
    last_sign_in_at: datetime | None
    created_at: datetime
    areas: list[UserArea] = field(default_factory=list)
    responsibilities: list[str] = field(default_factory=list)


async def _audit(
    conn: AsyncConnection, actor: UUID | None, action: str, user_id: UUID, after: Any = None
) -> None:
    await conn.execute(
        text(
            "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id, after) "
            "VALUES (:by, 'console', :action, 'app_user', :id, CAST(:after AS jsonb))"
        ),
        {
            "by": actor,
            "action": action,
            "id": user_id,
            "after": None if after is None else json.dumps(after, default=str),
        },
    )


async def list_users(conn: AsyncConnection, user_id: UUID | None = None) -> list[UserSummary]:
    rows = (
        await conn.execute(
            text(
                "SELECT id, username, full_name, organisation, position, phone, email, role, "
                "is_active, must_change_password, coalesce(locked_until > now(), false) "
                "AS locked, last_sign_in_at, created_at FROM app_user "
                "WHERE CAST(:id AS uuid) IS NULL OR id = :id ORDER BY full_name"
            ),
            {"id": user_id},
        )
    ).all()
    users = {r.id: UserSummary(**r._asdict()) for r in rows}
    if not users:
        return []
    for r in await conn.execute(
        text(
            "SELECT s.user_id, a.id, a.code, a.name, a.level FROM user_scope s "
            "JOIN admin_unit a ON a.id = s.admin_unit_id WHERE s.user_id = ANY(:ids) "
            "ORDER BY a.name"
        ),
        {"ids": list(users)},
    ):
        users[r.user_id].areas.append(UserArea(r.id, r.code, r.name, r.level))
    for r in await conn.execute(
        text(
            "SELECT user_id, responsibility_code FROM user_responsibility "
            "WHERE user_id = ANY(:ids) ORDER BY responsibility_code"
        ),
        {"ids": list(users)},
    ):
        users[r.user_id].responsibilities.append(r.responsibility_code)
    return list(users.values())


async def _set_areas(conn: AsyncConnection, user_id: UUID, area_ids: list[UUID]) -> None:
    found = (
        await conn.execute(
            text("SELECT count(*) FROM admin_unit WHERE id = ANY(:ids)"), {"ids": area_ids}
        )
    ).scalar_one()
    if found != len(set(area_ids)):
        raise AdminError("unknown_area")
    await conn.execute(text("DELETE FROM user_scope WHERE user_id = :u"), {"u": user_id})
    for a in set(area_ids):
        await conn.execute(
            text("INSERT INTO user_scope (user_id, admin_unit_id) VALUES (:u, :a)"),
            {"u": user_id, "a": a},
        )


async def _set_responsibilities(conn: AsyncConnection, user_id: UUID, codes: list[str]) -> None:
    known = {r[0] for r in await conn.execute(text("SELECT code FROM responsibility"))}
    if not set(codes) <= known:
        raise AdminError("unknown_responsibility")
    await conn.execute(text("DELETE FROM user_responsibility WHERE user_id = :u"), {"u": user_id})
    for c in set(codes):
        await conn.execute(
            text("INSERT INTO user_responsibility (user_id, responsibility_code) VALUES (:u, :c)"),
            {"u": user_id, "c": c},
        )


async def update_user(
    conn: AsyncConnection, actor: UUID | None, user_id: UUID, changes: dict[str, Any]
) -> None:
    """Applies the given fields; areas and responsibilities replace the old
    sets. An IT admin cannot disable or demote themselves."""
    exists = (
        await conn.execute(text("SELECT role FROM app_user WHERE id = :id"), {"id": user_id})
    ).scalar_one_or_none()
    if exists is None:
        raise AdminError("not_found")
    if user_id == actor and (
        changes.get("is_active") is False or changes.get("role", "it_admin") != "it_admin"
    ):
        raise AdminError("cannot_lock_yourself_out")
    simple = {
        k: v
        for k, v in changes.items()
        if k in ("full_name", "organisation", "position", "phone", "email", "role", "is_active")
    }
    if "role" in simple and simple["role"] not in ("stakeholder", "it_admin"):
        raise AdminError("unknown_role")
    if simple:
        sets = ", ".join(f"{k} = :{k}" for k in simple)
        await conn.execute(
            text(f"UPDATE app_user SET {sets} WHERE id = :id"),  # noqa: S608 - keys from a fixed list
            {**simple, "id": user_id},
        )
    if "area_ids" in changes:
        await _set_areas(conn, user_id, list(changes["area_ids"]))
    if "responsibilities" in changes:
        await _set_responsibilities(conn, user_id, list(changes["responsibilities"]))
    if changes.get("is_active") is False:
        # Disabling ends every session at once.
        await conn.execute(
            text(
                "UPDATE refresh_token SET revoked_at = now() "
                "WHERE user_id = :u AND revoked_at IS NULL"
            ),
            {"u": user_id},
        )
    action = (
        "user.disabled"
        if changes.get("is_active") is False
        else "user.enabled"
        if changes.get("is_active") is True
        else "user.updated"
    )
    await _audit(conn, actor, action, user_id, changes)


async def reset_password(conn: AsyncConnection, actor: UUID | None, user_id: UUID) -> str:
    """A new temporary password (shown once), to be changed at next sign-in;
    unlocks the account and ends its sessions."""
    password = temporary_password()
    done = (
        await conn.execute(
            text(
                "UPDATE app_user SET password_hash = :h, must_change_password = true, "
                "failed_attempts = 0, locked_until = NULL WHERE id = :id RETURNING id"
            ),
            {"h": hash_password(password), "id": user_id},
        )
    ).scalar_one_or_none()
    if done is None:
        raise AdminError("not_found")
    await conn.execute(
        text(
            "UPDATE refresh_token SET revoked_at = now() WHERE user_id = :u AND revoked_at IS NULL"
        ),
        {"u": user_id},
    )
    await _audit(conn, actor, "user.password_reset", user_id)
    return password
