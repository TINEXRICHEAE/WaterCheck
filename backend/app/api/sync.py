"""/v1/sync: push and pull (SPEC §8, ADR-011)."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Annotated, Any, Literal
from uuid import UUID

import structlog
from fastapi import APIRouter, HTTPException, Query, status
from pydantic import BaseModel, Field

from app.api.deps import DbDep
from app.api.reference import AnyPrincipal
from app.services.sync_pull import StreamError, pull
from app.services.sync_push import Change, PushService

log = structlog.get_logger()
router = APIRouter(prefix="/v1/sync", tags=["sync"])

MAX_CHANGES = 200


class ChangeIn(BaseModel):
    entity: str = Field(max_length=40)
    op: Literal["insert", "update"]
    id: str = Field(min_length=1, max_length=80)
    base_version: int | None = None
    data: dict[str, Any]


class PushRequest(BaseModel):
    batch_id: UUID
    changes: list[ChangeIn] = Field(max_length=MAX_CHANGES)


class ChangeResult(BaseModel):
    id: str
    entity: str
    status: Literal["applied", "duplicate", "conflict", "rejected"]
    server_version: int | None = None
    reason: str | None = None


class PushResponse(BaseModel):
    batch_id: UUID
    results: list[ChangeResult]
    server_time: datetime


class PulledChange(BaseModel):
    entity: str
    op: Literal["upsert", "tombstone"]
    id: str
    server_seq: int
    data: dict[str, Any]


class PullResponse(BaseModel):
    changes: list[PulledChange]
    next_cursor: str
    has_more: bool
    server_time: datetime


@router.post("/push")
async def push(body: PushRequest, principal: AnyPrincipal, db: DbDep) -> PushResponse:
    """Applies a batch; every record gets its own answer. Safe to resend."""
    now = datetime.now(UTC)
    changes = [Change(c.entity, c.op, c.id, c.data, c.base_version) for c in body.changes]
    async with db.transaction(principal) as conn:
        outcomes = await PushService(conn, principal, now).apply(changes)
    counts: dict[str, int] = {}
    for o in outcomes:
        counts[o.status] = counts.get(o.status, 0) + 1
    log.info("sync_push", batch_id=str(body.batch_id), kind=principal.kind, **counts)
    return PushResponse(
        batch_id=body.batch_id,
        results=[
            ChangeResult(
                id=o.id,
                entity=o.entity,
                status=o.status,
                server_version=o.server_version,
                reason=o.reason,
            )
            for o in outcomes
        ],
        server_time=now,
    )


@router.get("/pull")
async def pull_changes(
    principal: AnyPrincipal,
    db: DbDep,
    stream: Annotated[str, Query(max_length=60)],
    cursor: Annotated[str | None, Query(max_length=60)] = None,
    limit: Annotated[int, Query(ge=1, le=1000)] = 500,
) -> PullResponse:
    try:
        async with db.transaction(principal) as conn:
            page = await pull(
                conn, stream, cursor, limit, installation_id=principal.installation_id
            )
    except StreamError as e:
        code = status.HTTP_403_FORBIDDEN if str(e) == "out_of_scope" else 400
        raise HTTPException(code, str(e)) from e
    return PullResponse(**page, server_time=datetime.now(UTC))
