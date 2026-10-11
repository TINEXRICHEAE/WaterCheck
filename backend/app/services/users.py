"""Console user accounts (F-ADM-1). Collectors never get accounts."""

from __future__ import annotations

from dataclasses import dataclass
from uuid import UUID, uuid4

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.core.security import hash_password, temporary_password


@dataclass(frozen=True)
class NewUser:
    username: str
    full_name: str
    role: str  # 'stakeholder' | 'it_admin'
    area_codes: tuple[str, ...] = ()
    responsibilities: tuple[str, ...] = ()
    organisation: str | None = None
    position: str | None = None
    phone: str | None = None
    email: str | None = None


@dataclass(frozen=True)
class CreatedUser:
    id: UUID
    temporary_password: str


async def create_user(
    conn: AsyncConnection,
    user: NewUser,
    *,
    created_by: UUID | None = None,
    platform: str = "cli",
) -> CreatedUser:
    """Creates a user with a temporary password they must change at first
    sign-in. The password is returned once and never stored in plain text."""
    if user.role not in ("stakeholder", "it_admin"):
        raise ValueError(f"Unknown role: {user.role}")
    password = temporary_password()
    user_id = uuid4()
    await conn.execute(
        text(
            "INSERT INTO app_user (id, username, full_name, organisation, position, phone, "
            "email, password_hash, must_change_password, role, created_by) VALUES "
            "(:id, :username, :full_name, :organisation, :position, :phone, :email, :hash, "
            "true, :role, :created_by)"
        ),
        {
            "id": user_id,
            "username": user.username.strip(),
            "full_name": user.full_name.strip(),
            "organisation": user.organisation,
            "position": user.position,
            "phone": user.phone,
            "email": user.email,
            "hash": hash_password(password),
            "role": user.role,
            "created_by": created_by,
        },
    )
    for code in user.area_codes:
        area = (
            await conn.execute(text("SELECT id FROM admin_unit WHERE code = :c"), {"c": code})
        ).scalar_one_or_none()
        if area is None:
            raise ValueError(f"Unknown area code: {code}")
        await conn.execute(
            text("INSERT INTO user_scope (user_id, admin_unit_id) VALUES (:u, :a)"),
            {"u": user_id, "a": area},
        )
    for responsibility in user.responsibilities:
        await conn.execute(
            text("INSERT INTO user_responsibility (user_id, responsibility_code) VALUES (:u, :r)"),
            {"u": user_id, "r": responsibility},
        )
    await conn.execute(
        text(
            "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id) "
            "VALUES (:by, :platform, 'user.created', 'app_user', :id)"
        ),
        {"by": created_by, "id": user_id, "platform": platform},
    )
    return CreatedUser(id=user_id, temporary_password=password)
