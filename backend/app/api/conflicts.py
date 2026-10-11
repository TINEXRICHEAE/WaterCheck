"""/v1/conflicts: kept-server source changes for stakeholders (ADR-011).

When a phone's change to a source's working status (or active flag) loses
to a newer server value, the phone's value is kept here. Stakeholders of
the area see them on the source page and decide: keep the current value,
or use the phone's. Visibility follows row-level security.
"""

from __future__ import annotations

import json
from datetime import datetime
from typing import Any, Literal
from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import text

from app.api.deps import DbDep, UserDep

router = APIRouter(prefix="/v1/conflicts", tags=["conflicts"])

# Only these fields keep the server's value (ADR-011).
_FIELDS = {"functional_status", "is_active"}


class ConflictOut(BaseModel):
    id: UUID
    source_id: UUID
    field: str
    server_value: Any
    client_value: Any
    from_phone: bool
    created_at: datetime


class ResolveIn(BaseModel):
    keep: Literal["server", "client"]


@router.get("")
async def open_conflicts(
    user: UserDep, db: DbDep, source_id: UUID | None = None
) -> list[ConflictOut]:
    async with db.transaction(user) as conn:
        rows = (
            await conn.execute(
                text(
                    "SELECT id, entity_id, field, server_value, client_value, "
                    "installation_id IS NOT NULL AS from_phone, created_at FROM sync_conflict "
                    "WHERE entity = 'water_source' AND resolved_at IS NULL "
                    "AND (CAST(:src AS uuid) IS NULL OR entity_id = :src) "
                    "ORDER BY created_at LIMIT 200"
                ),
                {"src": source_id},
            )
        ).all()
    return [
        ConflictOut(
            id=r.id,
            source_id=r.entity_id,
            field=r.field,
            server_value=r.server_value,
            client_value=r.client_value,
            from_phone=r.from_phone,
            created_at=r.created_at,
        )
        for r in rows
    ]


@router.post("/{conflict_id}/resolve")
async def resolve(conflict_id: UUID, body: ResolveIn, user: UserDep, db: DbDep) -> ConflictOut:
    async with db.transaction(user) as conn:
        row = (
            await conn.execute(
                text(
                    "SELECT id, entity_id, field, server_value, client_value, resolved_at, "
                    "installation_id IS NOT NULL AS from_phone, created_at FROM sync_conflict "
                    "WHERE id = :id AND entity = 'water_source' FOR UPDATE"
                ),
                {"id": conflict_id},
            )
        ).first()
        if row is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        if row.resolved_at is not None:
            raise HTTPException(status.HTTP_409_CONFLICT, "already_resolved")
        if row.field not in _FIELDS:  # pragma: no cover - only these are recorded
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "unsupported_field")
        if body.keep == "client":
            # Column name from the allow-list above, never from input.
            await conn.execute(
                text(
                    f"UPDATE water_source SET {row.field} = :v, "  # noqa: S608
                    "version = version + 1 WHERE id = :id"
                ),
                {"v": row.client_value, "id": row.entity_id},
            )
        await conn.execute(
            text("UPDATE sync_conflict SET resolved_at = now(), resolved_by = :by WHERE id = :id"),
            {"by": user.user_id, "id": conflict_id},
        )
        await conn.execute(
            text(
                "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id, after) "
                "VALUES (:by, 'console', 'conflict.resolved', 'water_source', :src, "
                "CAST(:a AS jsonb))"
            ),
            {
                "by": user.user_id,
                "src": row.entity_id,
                "a": json.dumps({"field": row.field, "kept": body.keep}),
            },
        )
    return ConflictOut(
        id=row.id,
        source_id=row.entity_id,
        field=row.field,
        server_value=row.server_value,
        client_value=row.client_value,
        from_phone=row.from_phone,
        created_at=row.created_at,
    )
