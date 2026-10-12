"""/v1/admin: configuration, system health and the audit log (SPEC P11).

Areas below sub-county, responsibilities and alert routing, the default
limit set per area, security settings, review of custom parameters,
response cards. Every change is audited; devices get configuration changes
through the reference sync stream.
"""

from __future__ import annotations

import csv
import io
import json
import re
import uuid
from datetime import datetime
from typing import Annotated, Any, Literal
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, status
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.api.deps import AdminDep, DbDep, SettingsDep
from app.services import policy

router = APIRouter(prefix="/v1/admin", tags=["admin"])


async def _audit(
    conn: AsyncConnection,
    actor: UUID | None,
    action: str,
    entity: str,
    entity_id: UUID | None = None,
    after: Any = None,
) -> None:
    await conn.execute(
        text(
            "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id, after) "
            "VALUES (:by, 'console', :a, :e, :id, CAST(:after AS jsonb))"
        ),
        {
            "by": actor,
            "a": action,
            "e": entity,
            "id": entity_id,
            "after": None if after is None else json.dumps(after, default=str),
        },
    )


# ------------------------------------------------------------- audit log
class AuditEntry(BaseModel):
    id: int
    at: datetime
    actor_id: UUID | None
    actor_name: str | None
    installation_id: UUID | None
    platform: str | None
    action: str
    entity: str
    entity_id: UUID | None
    after: Any


async def _audit_rows(
    conn: AsyncConnection,
    action: str | None,
    entity: str | None,
    actor_id: UUID | None,
    installation_id: UUID | None,
    since: datetime | None,
    until: datetime | None,
    limit: int,
) -> list[AuditEntry]:
    rows = (
        await conn.execute(
            text(
                "SELECT l.id, l.at, l.actor_id, u.full_name AS actor_name, l.installation_id, "
                "l.platform, l.action, l.entity, l.entity_id, l.after FROM audit_log l "
                "LEFT JOIN app_user u ON u.id = l.actor_id WHERE "
                "(CAST(:action AS text) IS NULL OR l.action LIKE :action || '%') AND "
                "(CAST(:entity AS text) IS NULL OR l.entity = :entity) AND "
                "(CAST(:actor AS uuid) IS NULL OR l.actor_id = :actor) AND "
                "(CAST(:inst AS uuid) IS NULL OR l.installation_id = :inst) AND "
                "(CAST(:since AS timestamptz) IS NULL OR l.at >= :since) AND "
                "(CAST(:until AS timestamptz) IS NULL OR l.at < :until) "
                "ORDER BY l.at DESC, l.id DESC LIMIT :limit"
            ),
            {
                "action": action,
                "entity": entity,
                "actor": actor_id,
                "inst": installation_id,
                "since": since,
                "until": until,
                "limit": limit,
            },
        )
    ).all()
    return [AuditEntry(**r._asdict()) for r in rows]


@router.get("/audit")
async def audit(
    admin: AdminDep,
    db: DbDep,
    action: str | None = None,
    entity: str | None = None,
    actor_id: UUID | None = None,
    installation_id: UUID | None = None,
    since: datetime | None = None,
    until: datetime | None = None,
    limit: Annotated[int, Query(ge=1, le=1000)] = 200,
) -> list[AuditEntry]:
    async with db.transaction(admin) as conn:
        return await _audit_rows(
            conn, action, entity, actor_id, installation_id, since, until, limit
        )


@router.get("/audit.csv", response_class=PlainTextResponse)
async def audit_csv(
    admin: AdminDep,
    db: DbDep,
    action: str | None = None,
    entity: str | None = None,
    actor_id: UUID | None = None,
    installation_id: UUID | None = None,
    since: datetime | None = None,
    until: datetime | None = None,
    limit: Annotated[int, Query(ge=1, le=50000)] = 10000,
) -> PlainTextResponse:
    """The same filters as a CSV file (UTF-8, ISO dates)."""
    async with db.transaction(admin) as conn:
        rows = await _audit_rows(
            conn, action, entity, actor_id, installation_id, since, until, limit
        )
    out = io.StringIO()
    w = csv.writer(out)
    w.writerow(
        [
            "at_utc",
            "actor",
            "actor_id",
            "installation_id",
            "platform",
            "action",
            "entity",
            "entity_id",
            "details",
        ]
    )
    for r in rows:
        w.writerow(
            [
                r.at.isoformat(),
                r.actor_name or "",
                r.actor_id or "",
                r.installation_id or "",
                r.platform or "",
                r.action,
                r.entity,
                r.entity_id or "",
                "" if r.after is None else json.dumps(r.after, default=str),
            ]
        )
    await _audit_export_noted(db, admin, len(rows))
    return PlainTextResponse(
        "﻿" + out.getvalue(),
        media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": 'attachment; filename="watercheck-audit.csv"'},
    )


async def _audit_export_noted(db: Any, admin: Any, n: int) -> None:
    async with db.transaction(admin) as conn:
        await _audit(conn, admin.user_id, "audit.exported", "audit_log", after={"rows": n})


# --------------------------------------------------------- system health
class Health(BaseModel):
    database: bool
    worker_last_job_at: datetime | None
    jobs_queued: int
    jobs_overdue: int
    jobs_failed_24h: int
    notifications_failed_24h: int
    phones_active_7d: int
    phones_total: int
    app_versions: dict[str, int]
    records_received_24h: int
    sync_conflicts_open: int
    photos: int
    photo_bytes: int
    last_backup_at: datetime | None


@router.get("/health")
async def system_health(admin: AdminDep, db: DbDep) -> Health:
    """DevOps view (F-ADM-6). Backups come with deployment (P12); until
    then `last_backup_at` stays empty."""
    async with db.transaction(admin) as conn:
        r = (
            await conn.execute(
                text(
                    "SELECT "
                    "(SELECT max(finished_at) FROM job WHERE status = 'done') AS last_job, "
                    "(SELECT count(*) FROM job WHERE status = 'queued') AS queued, "
                    "(SELECT count(*) FROM job WHERE status = 'queued' "
                    " AND run_at < now() - interval '10 minutes') AS overdue, "
                    "(SELECT count(*) FROM job WHERE status = 'failed' "
                    " AND finished_at > now() - interval '1 day') AS failed, "
                    "(SELECT count(*) FROM notification WHERE status = 'failed' "
                    " AND created_at > now() - interval '1 day') AS notif_failed, "
                    "(SELECT count(*) FROM installation WHERE revoked_at IS NULL "
                    " AND last_seen_at > now() - interval '7 days') AS active, "
                    "(SELECT count(*) FROM installation WHERE revoked_at IS NULL) AS phones, "
                    "(SELECT count(*) FROM test_session "
                    " WHERE created_at_server > now() - interval '1 day') AS received, "
                    "(SELECT count(*) FROM sync_conflict WHERE resolved_at IS NULL) AS conflicts, "
                    "(SELECT count(*) FROM attachment WHERE upload_status = 'uploaded') AS photos, "
                    "(SELECT coalesce(sum(bytes), 0) FROM attachment "
                    " WHERE upload_status = 'uploaded') AS photo_bytes"
                )
            )
        ).one()
        versions: dict[Any, Any] = dict(
            (
                await conn.execute(
                    text(
                        "SELECT coalesce(app_version, '?'), count(*) FROM installation "
                        "WHERE revoked_at IS NULL GROUP BY 1 ORDER BY 1"
                    )
                )
            ).all()
        )
    return Health(
        database=True,
        worker_last_job_at=r.last_job,
        jobs_queued=r.queued,
        jobs_overdue=r.overdue,
        jobs_failed_24h=r.failed,
        notifications_failed_24h=r.notif_failed,
        phones_active_7d=r.active,
        phones_total=r.phones,
        app_versions={str(k): int(v) for k, v in versions.items()},
        records_received_24h=r.received,
        sync_conflicts_open=r.conflicts,
        photos=r.photos,
        photo_bytes=int(r.photo_bytes),
        last_backup_at=None,
    )


# ----------------------------------------------------------------- areas
class NewAreaIn(BaseModel):
    parent_id: UUID
    level: Literal["subcounty", "parish", "village"]
    name: str = Field(min_length=1, max_length=120)


class PlaceOut(BaseModel):
    id: UUID
    code: str
    name: str
    level: str
    parent_id: UUID | None


_ORDER = ["country", "region", "district", "subcounty", "parish", "village"]


@router.post("/areas", status_code=status.HTTP_201_CREATED)
async def new_area(body: NewAreaIn, admin: AdminDep, db: DbDep) -> PlaceOut:
    """Adds a sub-county, parish or village (the official list stops at
    sub-counties). Its code extends the parent's."""
    async with db.transaction(admin) as conn:
        parent = (
            await conn.execute(
                text("SELECT code, level FROM admin_unit WHERE id = :id"), {"id": body.parent_id}
            )
        ).one_or_none()
        if parent is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "parent_not_found")
        if _ORDER.index(body.level) <= _ORDER.index(parent.level):
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "level_not_below_parent")
        slug = re.sub(r"[^A-Z0-9]+", "-", body.name.strip().upper()).strip("-") or "AREA"
        code = f"{parent.code}-{slug}"
        taken = (
            await conn.execute(text("SELECT 1 FROM admin_unit WHERE code = :c"), {"c": code})
        ).first()
        if taken:
            raise HTTPException(status.HTTP_409_CONFLICT, "area_exists")
        new_id = uuid.uuid4()
        await conn.execute(
            text(
                "INSERT INTO admin_unit (id, level, name, code, parent_id) "
                "VALUES (:id, :level, :name, :code, :parent)"
            ),
            {
                "id": new_id,
                "level": body.level,
                "name": body.name.strip(),
                "code": code,
                "parent": body.parent_id,
            },
        )
        await _audit(conn, admin.user_id, "area.created", "admin_unit", new_id, body.model_dump())
    return PlaceOut(
        id=new_id, code=code, name=body.name.strip(), level=body.level, parent_id=body.parent_id
    )


class RenameIn(BaseModel):
    name: str = Field(min_length=1, max_length=120)


@router.patch("/areas/{area_id}")
async def rename_area(area_id: UUID, body: RenameIn, admin: AdminDep, db: DbDep) -> PlaceOut:
    async with db.transaction(admin) as conn:
        row = (
            await conn.execute(
                text(
                    "UPDATE admin_unit SET name = :n WHERE id = :id "
                    "RETURNING id, code, name, level, parent_id"
                ),
                {"n": body.name.strip(), "id": area_id},
            )
        ).one_or_none()
        if row is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        await _audit(conn, admin.user_id, "area.renamed", "admin_unit", area_id, {"name": row.name})
    return PlaceOut(**row._asdict())


class DefaultProfileIn(BaseModel):
    standard_id: UUID | None


@router.get("/areas/{area_id}/default-profile")
async def get_default_profile(area_id: UUID, admin: AdminDep, db: DbDep) -> DefaultProfileIn:
    """The limit set set on this area itself (empty: it inherits)."""
    async with db.transaction(admin) as conn:
        sid = (
            await conn.execute(
                text("SELECT standard_id FROM area_default_profile WHERE admin_unit_id = :a"),
                {"a": area_id},
            )
        ).scalar_one_or_none()
    return DefaultProfileIn(standard_id=sid)


@router.put("/areas/{area_id}/default-profile", status_code=status.HTTP_204_NO_CONTENT)
async def default_profile(
    area_id: UUID, body: DefaultProfileIn, admin: AdminDep, db: DbDep
) -> None:
    """The limit set phones in this area start with (cleared: inherit)."""
    async with db.transaction(admin) as conn:
        if body.standard_id is None:
            await conn.execute(
                text("DELETE FROM area_default_profile WHERE admin_unit_id = :a"), {"a": area_id}
            )
        else:
            await conn.execute(
                text(
                    "INSERT INTO area_default_profile (admin_unit_id, standard_id, set_by) "
                    "VALUES (:a, :s, :by) ON CONFLICT (admin_unit_id) DO UPDATE SET "
                    "standard_id = EXCLUDED.standard_id, set_by = EXCLUDED.set_by, "
                    "set_at = now()"
                ),
                {"a": area_id, "s": body.standard_id, "by": admin.user_id},
            )
        # Devices get it with the area (reference stream).
        await conn.execute(
            text("UPDATE admin_unit SET default_standard_id = :s WHERE id = :a"),
            {"a": area_id, "s": body.standard_id},
        )
        await _audit(
            conn,
            admin.user_id,
            "area.default_profile",
            "admin_unit",
            area_id,
            {"standard_id": body.standard_id},
        )


# ------------------------------------------- responsibilities and routing
class Responsibility(BaseModel):
    code: str = Field(pattern=r"^[a-z][a-z0-9_]{1,40}$")
    name: str = Field(min_length=1, max_length=80)


class RoutingRule(BaseModel):
    trigger_rule: str
    responsibility_code: str


class Routing(BaseModel):
    responsibilities: list[Responsibility]
    triggers: list[str]
    rules: list[RoutingRule]


TRIGGERS = ["ecoli", "unsafe", "baseline_jump", "sms"]


@router.get("/routing")
async def routing(admin: AdminDep, db: DbDep) -> Routing:
    async with db.transaction(admin) as conn:
        resp = (
            await conn.execute(text("SELECT code, name FROM responsibility ORDER BY name"))
        ).all()
        rules = (
            await conn.execute(
                text("SELECT trigger_rule, responsibility_code FROM alert_routing_rule")
            )
        ).all()
    return Routing(
        responsibilities=[Responsibility(code=r.code, name=r.name) for r in resp],
        triggers=TRIGGERS,
        rules=[RoutingRule(**r._asdict()) for r in rules],
    )


@router.post("/responsibilities", status_code=status.HTTP_201_CREATED)
async def new_responsibility(body: Responsibility, admin: AdminDep, db: DbDep) -> Responsibility:
    async with db.transaction(admin) as conn:
        done = (
            await conn.execute(
                text(
                    "INSERT INTO responsibility (code, name) VALUES (:c, :n) "
                    "ON CONFLICT (code) DO NOTHING RETURNING 1"
                ),
                {"c": body.code, "n": body.name},
            )
        ).first()
        if not done:
            raise HTTPException(status.HTTP_409_CONFLICT, "responsibility_exists")
        await _audit(conn, admin.user_id, "responsibility.created", "responsibility", None, body)
    return body


class RoutingIn(BaseModel):
    rules: list[RoutingRule]


@router.put("/routing", status_code=status.HTTP_204_NO_CONTENT)
async def set_routing(body: RoutingIn, admin: AdminDep, db: DbDep) -> None:
    """Replaces the routing table: which alert types reach which
    responsibilities (people with none get everything in their areas)."""
    async with db.transaction(admin) as conn:
        known = {r[0] for r in await conn.execute(text("SELECT code FROM responsibility"))}
        if any(
            r.trigger_rule not in TRIGGERS or r.responsibility_code not in known for r in body.rules
        ):
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "unknown_rule")
        await conn.execute(text("DELETE FROM alert_routing_rule"))
        for r in {(r.trigger_rule, r.responsibility_code) for r in body.rules}:
            await conn.execute(
                text(
                    "INSERT INTO alert_routing_rule (trigger_rule, responsibility_code) "
                    "VALUES (:t, :r)"
                ),
                {"t": r[0], "r": r[1]},
            )
        await _audit(
            conn, admin.user_id, "routing.updated", "alert_routing_rule", None, body.model_dump()
        )


# ------------------------------------------------------ security settings
class SecurityIn(BaseModel):
    max_failed_logins: int
    lockout_minutes: int
    password_min_length: int
    console_idle_minutes: int


@router.get("/security")
async def get_security(admin: AdminDep, db: DbDep, settings: SettingsDep) -> SecurityIn:
    async with db.transaction(admin) as conn:
        p = await policy.security_policy(conn, settings)
    return SecurityIn(**p.__dict__)


@router.put("/security")
async def set_security(
    body: SecurityIn, admin: AdminDep, db: DbDep, settings: SettingsDep
) -> SecurityIn:
    bad = policy.validate(body.model_dump())
    if bad:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, f"out_of_range:{','.join(bad)}")
    async with db.transaction(admin) as conn:
        await conn.execute(
            text(
                "INSERT INTO config_document (key, document, version, server_seq) "
                "VALUES ('security', CAST(:d AS jsonb), 1, 0) ON CONFLICT (key) DO UPDATE "
                "SET document = EXCLUDED.document, version = config_document.version + 1"
            ),
            {"d": body.model_dump_json()},
        )
        await _audit(conn, admin.user_id, "security.updated", "config_document", None, body)
        p = await policy.security_policy(conn, settings)
    return SecurityIn(**p.__dict__)


# -------------------------------------------------- custom parameters
class PendingParameter(BaseModel):
    code: str
    name: str
    category_code: str
    default_unit: str
    value_type: str
    collector_name: str | None
    readings: int


@router.get("/parameters/pending")
async def pending_parameters(admin: AdminDep, db: DbDep) -> list[PendingParameter]:
    async with db.transaction(admin) as conn:
        rows = (
            await conn.execute(
                text(
                    "SELECT p.code, p.name, p.category_code, p.default_unit, p.value_type, "
                    "p.collector_snapshot ->> 'full_name' AS collector_name, "
                    "(SELECT count(*) FROM reading r WHERE r.parameter_code = p.code) AS readings "
                    "FROM parameter_definition p WHERE p.is_custom "
                    "AND p.review_status = 'pending' AND p.merged_into IS NULL ORDER BY p.name"
                )
            )
        ).all()
    return [PendingParameter(**r._asdict()) for r in rows]


class ReviewIn(BaseModel):
    action: Literal["approve", "rename", "merge", "reject"]
    name: str | None = None
    merge_into: str | None = None


@router.post("/parameters/{code}/review", status_code=status.HTTP_204_NO_CONTENT)
async def review_parameter(code: str, body: ReviewIn, admin: AdminDep, db: DbDep) -> None:
    """Approve, rename, merge into a catalogue parameter (readings keep their
    original code and stay traceable through `merged_into`) or reject."""
    async with db.transaction(admin) as conn:
        found = (
            await conn.execute(
                text("SELECT 1 FROM parameter_definition WHERE code = :c AND is_custom"),
                {"c": code},
            )
        ).first()
        if not found:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        if body.action == "rename":
            if not body.name:
                raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "name_required")
            await conn.execute(
                text(
                    "UPDATE parameter_definition SET name = :n, review_status = 'approved' "
                    "WHERE code = :c"
                ),
                {"n": body.name.strip(), "c": code},
            )
        elif body.action == "merge":
            target = (
                await conn.execute(
                    text(
                        "SELECT 1 FROM parameter_definition WHERE code = :t AND merged_into IS NULL"
                    ),
                    {"t": body.merge_into},
                )
            ).first()
            if not target or body.merge_into == code:
                raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "bad_merge_target")
            await conn.execute(
                text(
                    "UPDATE parameter_definition SET merged_into = :t, review_status = 'approved' "
                    "WHERE code = :c"
                ),
                {"t": body.merge_into, "c": code},
            )
        else:
            await conn.execute(
                text("UPDATE parameter_definition SET review_status = :s WHERE code = :c"),
                {"s": "approved" if body.action == "approve" else "rejected", "c": code},
            )
        await _audit(
            conn,
            admin.user_id,
            f"parameter.{body.action}",
            "parameter_definition",
            None,
            {"code": code, **body.model_dump()},
        )


# --------------------------------------------------------- response cards
class CardOut(BaseModel):
    id: UUID
    trigger_rule: str
    audience: str
    version: int
    content: dict[str, Any]


class CardIn(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    actions: list[str] = Field(min_length=1)
    report_to: list[str] = Field(default_factory=list)
    report_note: str | None = None


@router.get("/response-cards")
async def admin_response_cards(admin: AdminDep, db: DbDep) -> list[CardOut]:
    async with db.transaction(admin) as conn:
        rows = (
            await conn.execute(
                text(
                    "SELECT id, trigger_rule, audience, version, content FROM response_card "
                    "ORDER BY trigger_rule"
                )
            )
        ).all()
    return [CardOut(**r._asdict()) for r in rows]


@router.put("/response-cards/{card_id}")
async def edit_card(card_id: UUID, body: CardIn, admin: AdminDep, db: DbDep) -> CardOut:
    """A new version of the card; phones get it with the reference data."""
    async with db.transaction(admin) as conn:
        row = (
            await conn.execute(
                text(
                    "UPDATE response_card SET content = content || CAST(:c AS jsonb), "
                    "version = version + 1 WHERE id = :id "
                    "RETURNING id, trigger_rule, audience, version, content"
                ),
                {"c": body.model_dump_json(), "id": card_id},
            )
        ).one_or_none()
        if row is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        await _audit(conn, admin.user_id, "response_card.updated", "response_card", card_id, body)
    return CardOut(**row._asdict())
