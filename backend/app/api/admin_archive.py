"""/v1/admin: archive and restore, and naming phones (ADR-018).

Only IT admins archive. An archive hides a record and what cascades from it
everywhere (lists, maps, dashboards, reports, sync) and can be restored.
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
from app.services import archive as svc

router = APIRouter(prefix="/v1/admin", tags=["admin"])

_STATUS = {
    "not_found": status.HTTP_404_NOT_FOUND,
    "already_archived": status.HTTP_409_CONFLICT,
    "unsupported_entity": status.HTTP_422_UNPROCESSABLE_CONTENT,
}


class ArchiveIn(BaseModel):
    entity: Literal["installation", "collector", "water_source", "test_session"]
    record_id: UUID
    reason: str = Field(min_length=5, max_length=500)


class ArchiveOut(BaseModel):
    batch_id: UUID
    counts: dict[str, int]


@router.post("/archive", status_code=status.HTTP_201_CREATED)
async def archive_record(body: ArchiveIn, admin: AdminDep, db: DbDep) -> ArchiveOut:
    """Archives a record and what cascades from it (restorable)."""
    assert admin.user_id is not None  # noqa: S101 - AdminDep is a signed-in user
    async with db.transaction(admin) as conn:
        try:
            b = await svc.archive(conn, admin.user_id, body.entity, body.record_id, body.reason)
        except svc.ArchiveError as e:
            raise HTTPException(_STATUS.get(e.code, 400), e.code) from e
    return ArchiveOut(batch_id=b.batch_id, counts=b.counts)


class ArchivedItem(BaseModel):
    batch_id: UUID
    entity: str
    record_id: UUID
    label: str
    reason: str
    archived_by: str | None
    archived_at: datetime
    counts: dict[str, int]


@router.get("/archive")
async def archived(admin: AdminDep, db: DbDep) -> list[ArchivedItem]:
    """Archive actions that can still be restored, newest first."""
    async with db.transaction(admin) as conn:
        rows = (
            await conn.execute(
                text(
                    "SELECT m.batch_id, m.entity, m.record_id, m.reason, m.archived_at, "
                    "u.full_name AS archived_by, "
                    "(SELECT json_object_agg(c.entity, c.n) FROM (SELECT entity, count(*) AS n "
                    " FROM archive_mark WHERE batch_id = m.batch_id AND archived "
                    " GROUP BY entity) c) AS counts, "
                    "CASE m.entity "
                    " WHEN 'water_source' THEN (SELECT w.code || coalesce(' ' || w.name, '') "
                    "   FROM water_source w WHERE w.id = m.record_id) "
                    " WHEN 'test_session' THEN (SELECT w.code || ', test of ' || "
                    "   to_char(s.tested_at_device, 'YYYY-MM-DD HH24:MI') FROM test_session s "
                    "   JOIN water_source w ON w.id = s.source_id WHERE s.id = m.record_id) "
                    " WHEN 'collector' THEN (SELECT p.snapshot ->> 'full_name' "
                    "   FROM collector_profile p WHERE p.collector_key = m.record_id) "
                    " WHEN 'installation' THEN (SELECT coalesce(i.label, i.short_code, "
                    "   i.id::text) FROM installation i WHERE i.id = m.record_id) END AS label "
                    "FROM archive_mark m LEFT JOIN app_user u ON u.id = m.archived_by "
                    "WHERE m.root AND m.archived ORDER BY m.archived_at DESC"
                )
            )
        ).all()
    return [
        ArchivedItem(
            batch_id=r.batch_id,
            entity=r.entity,
            record_id=r.record_id,
            label=r.label or str(r.record_id),
            reason=r.reason,
            archived_by=r.archived_by,
            archived_at=r.archived_at,
            counts=(json.loads(r.counts) if isinstance(r.counts, str) else r.counts) or {},
        )
        for r in rows
    ]


@router.post("/archive/{batch_id}/restore")
async def restore(batch_id: UUID, admin: AdminDep, db: DbDep) -> dict[str, int]:
    """Brings back everything one archive action hid. A restored phone stays
    revoked: issue it a new activation code."""
    assert admin.user_id is not None  # noqa: S101
    async with db.transaction(admin) as conn:
        try:
            return await svc.restore(conn, admin.user_id, batch_id)
        except svc.ArchiveError as e:
            raise HTTPException(_STATUS.get(e.code, 400), e.code) from e


class LabelIn(BaseModel):
    label: str | None = Field(default=None, max_length=80)


@router.patch("/installations/{installation_id}", status_code=status.HTTP_204_NO_CONTENT)
async def name_installation(
    installation_id: UUID, body: LabelIn, admin: AdminDep, db: DbDep
) -> None:
    """Names a phone ("Nalongo's phone"); the change is kept in its trail."""
    label = (body.label or "").strip() or None
    async with db.transaction(admin) as conn:
        old = (
            await conn.execute(
                text("SELECT label FROM installation WHERE id = :id FOR UPDATE"),
                {"id": installation_id},
            )
        ).first()
        if old is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        if old.label == label:
            return
        await conn.execute(
            text("UPDATE installation SET label = :l WHERE id = :id"),
            {"l": label, "id": installation_id},
        )
        name = (
            await conn.execute(
                text("SELECT full_name FROM app_user WHERE id = :id"), {"id": admin.user_id}
            )
        ).scalar_one_or_none()
        await conn.execute(
            text(
                "INSERT INTO change_trail (entity, record_id, field, old_value, new_value, "
                "actor_user_id, actor_name, server_seq, server_xid) VALUES ('installation', "
                ":id, 'label', CAST(:o AS jsonb), CAST(:n AS jsonb), :by, :name, 0, '1'::xid8)"
            ),
            {
                "id": installation_id,
                "o": json.dumps(old.label),
                "n": json.dumps(label),
                "by": admin.user_id,
                "name": name,
            },
        )
