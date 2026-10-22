"""/v1/admin: people and phones for the IT admin (SPEC P11, F-ADM-1/2).

Activation codes and revoking a phone live in `installations.py` (P5);
this adds the people, the list of phones and the list of codes.
"""

from __future__ import annotations

from datetime import datetime
from typing import Literal
from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy import text

from app.api.deps import AdminDep, DbDep
from app.services import admin_users
from app.services.admin_users import AdminError
from app.services.users import NewUser, create_user

router = APIRouter(prefix="/v1/admin", tags=["admin"])

_STATUS = {
    "not_found": status.HTTP_404_NOT_FOUND,
    "username_taken": status.HTTP_409_CONFLICT,
}


def _fail(e: AdminError) -> HTTPException:
    return HTTPException(_STATUS.get(e.code, status.HTTP_422_UNPROCESSABLE_CONTENT), e.code)


class AreaOut(BaseModel):
    id: UUID
    code: str
    name: str
    level: str


class UserOut(BaseModel):
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
    areas: list[AreaOut]
    responsibilities: list[str]


class NewUserIn(BaseModel):
    username: str = Field(min_length=3, max_length=200)
    full_name: str = Field(min_length=1, max_length=200)
    role: Literal["stakeholder", "it_admin"] = "stakeholder"
    organisation: str | None = None
    position: str | None = None
    phone: str | None = None
    email: str | None = None
    area_ids: list[UUID] = Field(default_factory=list)
    responsibilities: list[str] = Field(default_factory=list)


class UserChangesIn(BaseModel):
    full_name: str | None = Field(default=None, min_length=1, max_length=200)
    organisation: str | None = None
    position: str | None = None
    phone: str | None = None
    email: str | None = None
    role: Literal["stakeholder", "it_admin"] | None = None
    is_active: bool | None = None
    area_ids: list[UUID] | None = None
    responsibilities: list[str] | None = None


class CredentialsOut(BaseModel):
    """Shown once: the admin passes it on (in person, SMS or email)."""

    user: UserOut
    temporary_password: str


class InstallationOut(BaseModel):
    id: UUID
    area: AreaOut
    platform: str | None
    app_version: str | None
    short_code: str | None
    activated_at: datetime
    last_seen_at: datetime | None
    revoked_at: datetime | None
    collectors_seen: int
    tests: int
    # A name the IT admin gave the phone; archived phones stay listed so
    # they can be restored (ADR-018).
    label: str | None = None
    archived: bool = False


class ActivationCodeOut(BaseModel):
    id: UUID
    area: AreaOut
    expires_at: datetime
    max_installations: int
    used_count: int
    created_at: datetime
    revoked_at: datetime | None


async def _user(conn: object, user_id: UUID) -> UserOut:
    users = await admin_users.list_users(conn, user_id)  # type: ignore[arg-type]
    if not users:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
    return UserOut.model_validate(users[0], from_attributes=True)


@router.get("/users")
async def users(admin: AdminDep, db: DbDep) -> list[UserOut]:
    async with db.transaction(admin) as conn:
        found = await admin_users.list_users(conn)
    return [UserOut.model_validate(u, from_attributes=True) for u in found]


@router.post("/users", status_code=status.HTTP_201_CREATED)
async def new_user(body: NewUserIn, admin: AdminDep, db: DbDep) -> CredentialsOut:
    async with db.transaction(admin) as conn:
        taken = (
            await conn.execute(
                text("SELECT 1 FROM app_user WHERE lower(username) = lower(:u)"),
                {"u": body.username.strip()},
            )
        ).first()
        if taken:
            raise HTTPException(status.HTTP_409_CONFLICT, "username_taken")
        made = await create_user(
            conn,
            NewUser(
                username=body.username,
                full_name=body.full_name,
                role=body.role,
                organisation=body.organisation,
                position=body.position,
                phone=body.phone,
                email=body.email,
            ),
            created_by=admin.user_id,
            platform="console",
        )
        try:
            await admin_users.update_user(
                conn,
                admin.user_id,
                made.id,
                {"area_ids": body.area_ids, "responsibilities": body.responsibilities},
            )
        except AdminError as e:
            raise _fail(e) from e
        user = await _user(conn, made.id)
    return CredentialsOut(user=user, temporary_password=made.temporary_password)


@router.patch("/users/{user_id}")
async def change_user(user_id: UUID, body: UserChangesIn, admin: AdminDep, db: DbDep) -> UserOut:
    # A null means "clear" only where a field may be empty (contacts, job);
    # generated clients send null for everything they leave out.
    changes = {
        k: v
        for k, v in body.model_dump(exclude_unset=True).items()
        if v is not None or k in ("organisation", "position", "phone", "email")
    }
    try:
        async with db.transaction(admin) as conn:
            await admin_users.update_user(conn, admin.user_id, user_id, changes)
            return await _user(conn, user_id)
    except AdminError as e:
        raise _fail(e) from e


@router.post("/users/{user_id}/reset-password")
async def reset_password(user_id: UUID, admin: AdminDep, db: DbDep) -> CredentialsOut:
    try:
        async with db.transaction(admin) as conn:
            password = await admin_users.reset_password(conn, admin.user_id, user_id)
            user = await _user(conn, user_id)
    except AdminError as e:
        raise _fail(e) from e
    return CredentialsOut(user=user, temporary_password=password)


@router.get("/installations")
async def installations(admin: AdminDep, db: DbDep) -> list[InstallationOut]:
    async with db.transaction(admin) as conn:
        rows = (
            await conn.execute(
                text(
                    "SELECT i.id, i.platform, i.app_version, i.short_code, i.activated_at, "
                    "i.last_seen_at, i.revoked_at, i.label, "
                    "wc_archived('installation', i.id) AS archived, "
                    "a.id AS area_id, a.code, a.name, a.level, "
                    "(SELECT count(DISTINCT s.collector_key) FROM test_session s "
                    " WHERE s.installation_id = i.id) AS collectors_seen, "
                    "(SELECT count(*) FROM test_session s WHERE s.installation_id = i.id "
                    " AND NOT wc_archived('test_session', s.id)) "
                    "AS tests FROM installation i JOIN admin_unit a ON a.id = i.admin_unit_id "
                    "ORDER BY i.revoked_at IS NOT NULL, i.last_seen_at DESC NULLS LAST"
                )
            )
        ).all()
    return [
        InstallationOut(
            id=r.id,
            area=AreaOut(id=r.area_id, code=r.code, name=r.name, level=r.level),
            platform=r.platform,
            app_version=r.app_version,
            short_code=r.short_code,
            activated_at=r.activated_at,
            last_seen_at=r.last_seen_at,
            revoked_at=r.revoked_at,
            collectors_seen=r.collectors_seen,
            tests=r.tests,
            label=r.label,
            archived=r.archived,
        )
        for r in rows
    ]


@router.get("/activation-codes")
async def activation_codes(admin: AdminDep, db: DbDep) -> list[ActivationCodeOut]:
    """Recent codes; the codes themselves were shown once and are not stored."""
    async with db.transaction(admin) as conn:
        rows = (
            await conn.execute(
                text(
                    "SELECT c.id, c.expires_at, c.max_installations, c.used_count, c.created_at, "
                    "c.revoked_at, a.id AS area_id, a.code, a.name, a.level "
                    "FROM activation_code c JOIN admin_unit a ON a.id = c.admin_unit_id "
                    "ORDER BY c.created_at DESC LIMIT 200"
                )
            )
        ).all()
    return [
        ActivationCodeOut(
            id=r.id,
            area=AreaOut(id=r.area_id, code=r.code, name=r.name, level=r.level),
            expires_at=r.expires_at,
            max_installations=r.max_installations,
            used_count=r.used_count,
            created_at=r.created_at,
            revoked_at=r.revoked_at,
        )
        for r in rows
    ]


class ChainPerson(BaseModel):
    id: UUID
    full_name: str
    responsibilities: list[str]
    is_active: bool


class ChainLevel(BaseModel):
    area: AreaOut
    people: list[ChainPerson]

    @property
    def empty(self) -> bool:
        return not self.people


class ChainOut(BaseModel):
    """Who an alert from this area reaches, level by level, lowest first
    (docs/PLAN.md §3). Empty levels are skipped by the alert chain; the IT
    admins are told only when every level is empty."""

    levels: list[ChainLevel]
    first_notice: AreaOut | None
    gaps: list[AreaOut]


@router.get("/areas/{area_id}/chain")
async def chain(area_id: UUID, admin: AdminDep, db: DbDep) -> ChainOut:
    async with db.transaction(admin) as conn:
        path = (
            await conn.execute(
                text(
                    "WITH RECURSIVE up AS ("
                    " SELECT id, code, name, level, parent_id, 0 AS depth FROM admin_unit "
                    " WHERE id = :id UNION ALL "
                    " SELECT a.id, a.code, a.name, a.level, a.parent_id, up.depth + 1 "
                    " FROM admin_unit a JOIN up ON a.id = up.parent_id) "
                    "SELECT id, code, name, level FROM up ORDER BY depth"
                ),
                {"id": area_id},
            )
        ).all()
        if not path:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        people = (
            await conn.execute(
                text(
                    "SELECT s.admin_unit_id, u.id, u.full_name, u.is_active, "
                    "coalesce(array_agg(r.responsibility_code ORDER BY r.responsibility_code) "
                    "FILTER (WHERE r.responsibility_code IS NOT NULL), '{}') AS resp "
                    "FROM user_scope s JOIN app_user u ON u.id = s.user_id "
                    "LEFT JOIN user_responsibility r ON r.user_id = u.id "
                    "WHERE s.admin_unit_id = ANY(:ids) AND u.role = 'stakeholder' "
                    "GROUP BY s.admin_unit_id, u.id ORDER BY u.full_name"
                ),
                {"ids": [p.id for p in path]},
            )
        ).all()
    by_area: dict[UUID, list[ChainPerson]] = {}
    for r in people:
        by_area.setdefault(r.admin_unit_id, []).append(
            ChainPerson(
                id=r.id, full_name=r.full_name, responsibilities=list(r.resp), is_active=r.is_active
            )
        )
    levels = [
        ChainLevel(
            area=AreaOut(id=p.id, code=p.code, name=p.name, level=p.level),
            people=by_area.get(p.id, []),
        )
        for p in path
    ]
    active = [lv for lv in levels if any(x.is_active for x in lv.people)]
    return ChainOut(
        levels=levels,
        first_notice=active[0].area if active else None,
        gaps=[lv.area for lv in levels if not any(x.is_active for x in lv.people)],
    )
