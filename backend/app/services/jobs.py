"""A small Postgres job queue (ADR-013).

Jobs are inserted in the caller's transaction, so a change and the work it
needs (an alert and its notification) commit or roll back together. The
worker claims due jobs with ``FOR UPDATE SKIP LOCKED``.
"""

from __future__ import annotations

import json
from datetime import datetime
from typing import Any

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection


async def enqueue(
    conn: AsyncConnection,
    kind: str,
    payload: dict[str, Any] | None = None,
    *,
    run_at: datetime | None = None,
    dedupe_key: str | None = None,
) -> None:
    """Queues a job. With [dedupe_key], a job already queued under the same
    key makes this a no-op."""
    await conn.execute(
        text(
            "INSERT INTO job (kind, payload, run_at, dedupe_key) VALUES "
            "(:k, CAST(:p AS jsonb), coalesce(:at, now()), :d) ON CONFLICT DO NOTHING"
        ),
        {"k": kind, "p": json.dumps(payload or {}), "at": run_at, "d": dedupe_key},
    )
