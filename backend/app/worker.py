"""Background worker (ADR-013): runs queued jobs and periodic sweeps.

Jobs come from the `job` table. Each runs in its own transaction as the
system principal; a failure rolls back the job's changes and re-queues it
with exponential backoff, until `max_attempts`. The clock is injectable, so
tests can travel in time (escalation after 48 h).
"""

from __future__ import annotations

import asyncio
import json
import signal
from collections.abc import Awaitable, Callable
from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import UUID

import structlog
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.core.config import Settings, get_settings
from app.core.logging import configure_logging
from app.db.database import Database, Principal
from app.services.channels import ChannelError, Channels, channels_from
from app.services.jobs import enqueue
from app.services.notifications import deliver, escalation_sweep, mark_failed, notify_alert

log = structlog.get_logger()

Clock = Callable[[], datetime]
SWEEP_EVERY = timedelta(minutes=5)


def utc_now() -> datetime:
    return datetime.now(UTC)


class Worker:
    def __init__(self, db: Database, channels: Channels, *, clock: Clock = utc_now) -> None:
        self.db = db
        self.channels = channels
        self.clock = clock
        self.handlers: dict[str, Callable[[AsyncConnection, dict[str, Any]], Awaitable[None]]] = {
            "notify_alert": self._notify_alert,
            "deliver": self._deliver,
            "escalation_sweep": self._escalation_sweep,
        }

    async def _notify_alert(self, conn: AsyncConnection, p: dict[str, Any]) -> None:
        told = await notify_alert(conn, UUID(p["alert_id"]), int(p.get("level", 0)))
        log.info("alert_notified", alert_id=p["alert_id"], level=p.get("level", 0), told=told)

    async def _deliver(self, conn: AsyncConnection, p: dict[str, Any]) -> None:
        await deliver(conn, self.channels, UUID(p["notification_id"]))

    async def _escalation_sweep(self, conn: AsyncConnection, p: dict[str, Any]) -> None:
        escalated = await escalation_sweep(conn, self.clock())
        if escalated:
            log.info("alerts_escalated", count=len(escalated))
        # The next sweep (one queued at a time).
        await enqueue(
            conn,
            "escalation_sweep",
            run_at=self.clock() + SWEEP_EVERY,
            dedupe_key="escalation_sweep",
        )

    async def schedule_periodic(self) -> None:
        async with self.db.transaction(Principal.system()) as conn:
            await enqueue(conn, "escalation_sweep", dedupe_key="escalation_sweep")

    async def run_due(self, limit: int = 20) -> int:
        """Runs jobs that are due; returns how many ran (tests call this)."""
        ran = 0
        while ran < limit:
            job = await self._run_one()
            if job is None:
                break
            ran += 1
        return ran

    async def _run_one(self) -> int | None:
        now = self.clock()
        error: str | None = None
        async with self.db.transaction(Principal.system()) as conn:
            job = (
                await conn.execute(
                    text(
                        "SELECT id, kind, payload, attempts, max_attempts FROM job "
                        "WHERE status = 'queued' AND run_at <= :now ORDER BY run_at, id "
                        "LIMIT 1 FOR UPDATE SKIP LOCKED"
                    ),
                    {"now": now},
                )
            ).first()
            if job is None:
                return None
            payload = job.payload if isinstance(job.payload, dict) else json.loads(job.payload)
            handler = self.handlers.get(job.kind)
            try:
                async with conn.begin_nested():
                    if handler is None:
                        raise ChannelError(f"unknown job kind {job.kind}")
                    await handler(conn, payload)
                await conn.execute(
                    text("UPDATE job SET status = 'done', finished_at = :now WHERE id = :id"),
                    {"now": now, "id": job.id},
                )
                return int(job.id)
            except Exception as e:
                error = f"{type(e).__name__}: {e}"[:500]
            attempts = job.attempts + 1
            final = attempts >= job.max_attempts
            # 30 s, 1 min, 2 min, … capped at 1 h.
            delay = timedelta(seconds=min(3600, 30 * 2 ** (attempts - 1)))
            await conn.execute(
                text(
                    "UPDATE job SET attempts = :a, last_error = :e, run_at = :at, "
                    "status = :s, "
                    "finished_at = CASE WHEN :s = 'failed' THEN CAST(:now AS timestamptz) END "
                    "WHERE id = :id"
                ),
                {
                    "a": attempts,
                    "e": error,
                    "at": now + delay,
                    "s": "failed" if final else "queued",
                    "now": now,
                    "id": job.id,
                },
            )
            if final and job.kind == "deliver":
                await mark_failed(conn, UUID(payload["notification_id"]), error or "failed")
            log.warning("job_failed", kind=job.kind, attempts=attempts, final=final, error=error)
            return int(job.id)


async def run(stop: asyncio.Event, settings: Settings | None = None) -> None:
    settings = settings or get_settings()
    if not settings.database_url:
        log.warning("worker_idle", reason="WC_DATABASE_URL not set")
        await stop.wait()
        return
    db = Database(settings.database_url)
    worker = Worker(db, channels_from(settings))
    await worker.schedule_periodic()
    log.info("worker_started", environment=settings.environment)
    try:
        while not stop.is_set():
            ran = await worker.run_due()
            if ran == 0:
                try:
                    await asyncio.wait_for(stop.wait(), timeout=settings.worker_poll_seconds)
                except TimeoutError:
                    pass
    finally:
        await db.dispose()
        log.info("worker_stopped")


def main() -> None:
    configure_logging(get_settings().log_level)
    stop = asyncio.Event()

    async def _main() -> None:
        loop = asyncio.get_running_loop()
        for sig in (signal.SIGINT, signal.SIGTERM):
            try:
                loop.add_signal_handler(sig, stop.set)
            except NotImplementedError:  # Windows dev shells
                pass
        await run(stop)

    asyncio.run(_main())


if __name__ == "__main__":
    main()
