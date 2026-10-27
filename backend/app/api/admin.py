"""/v1/admin: people and phones for the IT admin (SPEC P11, F-ADM-1/2).

Activation codes and revoking a phone live in `installations.py` (P5);
this adds the people, the list of phones and the list of codes.
"""

from __future__ import annotations

import json
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
    # 'water', 'research' or 'all' (ADR-031); 'admin', 'signup' or 'join'.
    side: str = "water"
    created_via: str = "admin"


class NewUserIn(BaseModel):
    username: str = Field(min_length=3, max_length=200)
    full_name: str = Field(min_length=1, max_length=200)
    role: Literal["stakeholder", "it_admin"] = "stakeholder"
    # The side of a stakeholder's account; IT admins work on all.
    side: Literal["water", "research"] = "water"
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
    # Null for a device that registered itself (ADR-024).
    area: AreaOut | None
    registered_via: str = "code"
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


SideFilter = Literal["water", "research"] | None


@router.get("/users")
async def users(admin: AdminDep, db: DbDep, side: SideFilter = None) -> list[UserOut]:
    """Console accounts; with `side`, that side's accounts and the IT admins,
    who work on every side (ADR-031)."""
    async with db.transaction(admin) as conn:
        found = await admin_users.list_users(conn)
    return [
        UserOut.model_validate(u, from_attributes=True)
        for u in found
        if side is None or u.side in (side, "all")
    ]


@router.post("/users", status_code=status.HTTP_201_CREATED)
async def new_user(body: NewUserIn, admin: AdminDep, db: DbDep) -> CredentialsOut:
    side = "all" if body.role == "it_admin" else body.side
    async with db.transaction(admin) as conn:
        taken = (
            await conn.execute(
                text(
                    "SELECT 1 FROM app_user WHERE lower(username) = lower(:u) "
                    "AND (side = :s OR side = 'all' OR :s = 'all')"
                ),
                {"u": body.username.strip(), "s": side},
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
                side=side,
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


# Devices of a side (ADR-031): used by one of its testers, or (water) by
# nobody yet.
_DEVICE_SIDE = (
    "(CAST(:side AS text) IS NULL OR EXISTS (SELECT 1 FROM collector_device d "
    "JOIN collector_profile p ON p.collector_key = d.collector_key "
    "WHERE d.installation_id = i.id AND p.side = :side) OR (:side = 'water' AND NOT EXISTS "
    "(SELECT 1 FROM collector_device d WHERE d.installation_id = i.id)))"
)


@router.get("/installations")
async def installations(
    admin: AdminDep, db: DbDep, side: SideFilter = None
) -> list[InstallationOut]:
    """Devices; with `side`, those its testers use. `tests` counts that
    side's records (water tests or research records)."""
    async with db.transaction(admin) as conn:
        rows = (
            await conn.execute(
                text(
                    "SELECT i.id, i.platform, i.app_version, i.short_code, i.activated_at, "  # noqa: S608
                    "i.last_seen_at, i.revoked_at, coalesce(i.label, i.device_label) AS label, "
                    "i.registered_via, "
                    "wc_archived('installation', i.id) AS archived, "
                    "a.id AS area_id, a.code, a.name, a.level, "
                    "CASE WHEN :side = 'research' THEN (SELECT count(DISTINCT d.collector_key) "
                    " FROM collector_device d JOIN collector_profile p "
                    " ON p.collector_key = d.collector_key WHERE d.installation_id = i.id "
                    " AND p.side = 'research') ELSE (SELECT count(DISTINCT s.collector_key) "
                    " FROM test_session s WHERE s.installation_id = i.id) END "
                    "AS collectors_seen, "
                    "CASE WHEN :side = 'research' THEN (SELECT count(*) FROM research.record r "
                    " WHERE r.installation_id = i.id) ELSE (SELECT count(*) FROM test_session s "
                    " WHERE s.installation_id = i.id AND NOT wc_archived('test_session', s.id)) "
                    "END AS tests FROM installation i "
                    "LEFT JOIN admin_unit a ON a.id = i.admin_unit_id "
                    f"WHERE {_DEVICE_SIDE} "
                    "ORDER BY i.revoked_at IS NOT NULL, i.last_seen_at DESC NULLS LAST"
                ),
                {"side": side},
            )
        ).all()
    return [
        InstallationOut(
            id=r.id,
            area=None
            if r.area_id is None
            else AreaOut(id=r.area_id, code=r.code, name=r.name, level=r.level),
            registered_via=r.registered_via,
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


class DeviceCollector(BaseModel):
    """Someone who worked on a device: from their tests, sources, details
    or a recovery code redeemed there (ADR-022)."""

    collector_key: UUID
    full_name: str
    phone: str | None
    collector_type: str | None
    village: str | None
    tests: int
    sources: int
    last_at: datetime | None
    recovered_here: bool


@router.get("/installations/{installation_id}/collectors")
async def installation_collectors(
    installation_id: UUID, admin: AdminDep, db: DbDep
) -> list[DeviceCollector]:
    """The collectors and testers seen on one device. People added on the
    device who never sent anything are not known to the server yet."""
    async with db.transaction(admin) as conn:
        rows = (
            await conn.execute(
                text(
                    "WITH keys AS ("
                    " SELECT collector_key FROM test_session WHERE installation_id = :i"
                    " UNION SELECT collector_key FROM water_source"
                    "  WHERE installation_id = :i AND collector_key IS NOT NULL"
                    " UNION SELECT collector_key FROM collector_profile WHERE installation_id = :i"
                    " UNION SELECT collector_key FROM collector_recovery_code"
                    "  WHERE used_by_installation = :i) "
                    "SELECT k.collector_key, p.snapshot, "
                    "(SELECT count(*) FROM test_session s WHERE s.collector_key = k.collector_key"
                    " AND s.installation_id = :i AND NOT wc_archived('test_session', s.id))"
                    " AS tests,"
                    " (SELECT count(*) FROM water_source w WHERE w.collector_key = k.collector_key"
                    " AND w.installation_id = :i) AS sources,"
                    " (SELECT max(s.tested_at_device) FROM test_session s"
                    "  WHERE s.collector_key = k.collector_key AND s.installation_id = :i)"
                    " AS last_at,"
                    " EXISTS (SELECT 1 FROM collector_recovery_code c"
                    "  WHERE c.collector_key = k.collector_key AND c.used_by_installation = :i)"
                    " AS recovered_here "
                    "FROM keys k LEFT JOIN collector_profile p ON p.collector_key = k.collector_key"
                ),
                {"i": installation_id},
            )
        ).all()
    out = []
    for r in rows:
        snap = (
            r.snapshot
            if isinstance(r.snapshot, dict)
            else (json.loads(r.snapshot) if r.snapshot else {})
        )
        out.append(
            DeviceCollector(
                collector_key=r.collector_key,
                full_name=snap.get("full_name") or "?",
                phone=snap.get("phone"),
                collector_type=snap.get("collector_type"),
                village=snap.get("village"),
                tests=r.tests,
                sources=r.sources,
                last_at=r.last_at,
                recovered_here=r.recovered_here,
            )
        )
    return sorted(out, key=lambda c: (c.last_at is None, c.full_name))


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


class LedgerDevice(BaseModel):
    id: UUID
    label: str | None
    short_code: str | None
    platform: str | None
    activated_at: datetime
    last_seen_at: datetime | None
    revoked_at: datetime | None


class LedgerTester(BaseModel):
    """A tester an assignment code put in its area (ADR-024)."""

    collector_key: UUID
    full_name: str | None
    assigned_at: datetime
    ended_at: datetime | None


class LedgerCode(BaseModel):
    """An assignment (formerly activation) code: who made it, for where,
    and the testers it assigned (and devices, for codes used before)."""

    id: UUID
    area: AreaOut
    created_by: str | None
    created_at: datetime
    expires_at: datetime
    max_installations: int
    used_count: int
    revoked_at: datetime | None
    devices: list[LedgerDevice]
    testers: list[LedgerTester] = []


class LedgerAccount(BaseModel):
    """A Console account: who made it, and whether and when it was used."""

    id: UUID
    username: str
    full_name: str
    role: str
    created_by: str | None
    created_at: datetime
    first_sign_in_done: bool
    last_sign_in_at: datetime | None
    is_active: bool
    areas: list[str]


class Ledger(BaseModel):
    codes: list[LedgerCode]
    accounts: list[LedgerAccount]


@router.get("/credentials")
async def credentials(admin: AdminDep, db: DbDep, side: SideFilter = None) -> Ledger:
    """Every activation code and Console account made, by whom, for which
    area, and their use: devices activated, first and last sign-in
    (ADR-022). The codes and passwords themselves are never stored."""
    async with db.transaction(admin) as conn:
        codes = (
            await conn.execute(
                text(
                    "SELECT c.id, c.created_at, c.expires_at, c.max_installations, "
                    "c.used_count, c.revoked_at, u.full_name AS created_by, "
                    "a.id AS area_id, a.code, a.name, a.level "
                    "FROM activation_code c JOIN admin_unit a ON a.id = c.admin_unit_id "
                    "LEFT JOIN app_user u ON u.id = c.created_by "
                    "ORDER BY c.created_at DESC"
                )
            )
        ).all()
        devices = (
            await conn.execute(
                text(
                    "SELECT activation_code_id, id, label, short_code, platform, "
                    "activated_at, last_seen_at, revoked_at FROM installation "
                    "WHERE activation_code_id IS NOT NULL ORDER BY activated_at"
                )
            )
        ).all()
        testers = (
            await conn.execute(
                text(
                    "SELECT s.activation_code_id, s.collector_key, "
                    "p.snapshot->>'full_name' AS full_name, s.assigned_at, s.ended_at "
                    "FROM collector_assignment s "
                    "LEFT JOIN collector_profile p ON p.collector_key = s.collector_key "
                    "WHERE s.activation_code_id IS NOT NULL ORDER BY s.assigned_at"
                )
            )
        ).all()
        accounts = (
            await conn.execute(
                text(
                    "SELECT u.id, u.username, u.full_name, u.role, u.created_at, "
                    "NOT u.must_change_password AS first_sign_in_done, u.last_sign_in_at, "
                    "u.is_active, m.full_name AS created_by, "
                    "coalesce((SELECT array_agg(a.name ORDER BY a.name) FROM user_scope s "
                    " JOIN admin_unit a ON a.id = s.admin_unit_id WHERE s.user_id = u.id),"
                    " '{}') AS areas "
                    "FROM app_user u LEFT JOIN app_user m ON m.id = u.created_by "
                    "WHERE CAST(:side AS text) IS NULL OR u.side IN (:side, 'all') "
                    "ORDER BY u.created_at DESC"
                ),
                {"side": side},
            )
        ).all()
        if side == "research":
            # Activation and assignment codes belong to water testing;
            # research uses form access codes and recovery codes.
            codes = []
    by_code: dict[UUID, list[LedgerDevice]] = {}
    for d in devices:
        by_code.setdefault(d.activation_code_id, []).append(
            LedgerDevice(**{k: v for k, v in d._asdict().items() if k != "activation_code_id"})
        )
    assigned: dict[UUID, list[LedgerTester]] = {}
    for t in testers:
        assigned.setdefault(t.activation_code_id, []).append(
            LedgerTester(**{k: v for k, v in t._asdict().items() if k != "activation_code_id"})
        )
    return Ledger(
        codes=[
            LedgerCode(
                id=c.id,
                area=AreaOut(id=c.area_id, code=c.code, name=c.name, level=c.level),
                created_by=c.created_by,
                created_at=c.created_at,
                expires_at=c.expires_at,
                max_installations=c.max_installations,
                used_count=c.used_count,
                revoked_at=c.revoked_at,
                devices=by_code.get(c.id, []),
                testers=assigned.get(c.id, []),
            )
            for c in codes
        ],
        accounts=[LedgerAccount(**a._asdict()) for a in accounts],
    )


@router.post("/activation-codes/{code_id}/revoke", status_code=status.HTTP_204_NO_CONTENT)
async def revoke_code(code_id: UUID, admin: AdminDep, db: DbDep) -> None:
    """Withdraws an unused or partly used code; devices already activated
    with it keep working (revoke those one by one)."""
    async with db.transaction(admin) as conn:
        done = (
            await conn.execute(
                text(
                    "UPDATE activation_code SET revoked_at = now() "
                    "WHERE id = :id AND revoked_at IS NULL RETURNING id"
                ),
                {"id": code_id},
            )
        ).first()
        if done is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        await conn.execute(
            text(
                "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id) "
                "VALUES (:a, 'console', 'activation_code.revoked', 'activation_code', :id)"
            ),
            {"a": admin.user_id, "id": code_id},
        )


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


class AcceptanceOut(BaseModel):
    side: str
    version: int
    terms_accepted: bool
    privacy_accepted: bool
    how: str
    accepted_at: datetime
    ip: str | None
    device: str | None


@router.get("/legal-acceptances")
async def legal_acceptances(
    admin: AdminDep,
    db: DbDep,
    user_id: UUID | None = None,
    collector_key: UUID | None = None,
) -> list[AcceptanceOut]:
    """Each time an account or a tester accepted a side's Terms of Use and
    Privacy Policy (ADR-031): kept for accountability, newest first."""
    if (user_id is None) == (collector_key is None):
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "one_of_user_or_collector")
    async with db.transaction(admin) as conn:
        rows = await conn.execute(
            text(
                "SELECT l.side, l.version, l.terms_accepted, l.privacy_accepted, l.how, "
                "l.accepted_at, host(l.ip) AS ip, coalesce(i.label, i.device_label, "
                "i.short_code) AS device FROM legal_acceptance l "
                "LEFT JOIN installation i ON i.id = l.installation_id "
                "WHERE (CAST(:u AS uuid) IS NOT NULL AND l.user_id = CAST(:u AS uuid)) "
                "OR (CAST(:k AS uuid) IS NOT NULL AND l.collector_key = CAST(:k AS uuid)) "
                "ORDER BY l.accepted_at DESC"
            ),
            {"u": user_id, "k": collector_key},
        )
        return [AcceptanceOut(**r._mapping) for r in rows]
