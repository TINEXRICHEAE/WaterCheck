"""Archive and restore (the lead, 2026-10-22; ADR-018).

An IT admin archives a device, a collector, a source or a test. Archiving
cascades in that order: a device takes its collectors, a collector takes its
tests and the sources only they used, a source takes its tests and alerts, a
test takes its alerts. A source another collector also tested stays (only
the archived collector's tests go).

Nothing is deleted: each archived record gets a mark in ``archive_mark``,
and listings, dashboards, reports and sync skip marked records. One action
and its cascade share a batch, and a restore brings back exactly that batch.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from uuid import UUID, uuid4

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

ENTITIES = ("installation", "collector", "water_source", "test_session", "alert")


class ArchiveError(Exception):
    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code


@dataclass
class Batch:
    batch_id: UUID
    actor: UUID
    reason: str
    counts: dict[str, int] = field(default_factory=dict)


async def _mark(
    conn: AsyncConnection,
    b: Batch,
    entity: str,
    record_id: UUID,
    village_id: UUID | None,
) -> bool:
    """Marks one record; False when it was already archived."""
    row = (
        await conn.execute(
            text(
                "INSERT INTO archive_mark (entity, record_id, village_id, archived, reason, "
                "batch_id, archived_by, server_seq, server_xid) VALUES (:e, :id, :v, true, "
                ":why, :b, :by, 0, '1'::xid8) ON CONFLICT (entity, record_id) DO UPDATE SET "
                "archived = true, reason = EXCLUDED.reason, batch_id = EXCLUDED.batch_id, "
                "archived_by = EXCLUDED.archived_by, archived_at = now(), restored_by = NULL, "
                "restored_at = NULL, village_id = EXCLUDED.village_id "
                "WHERE NOT archive_mark.archived RETURNING 1"
            ),
            {
                "e": entity,
                "id": record_id,
                "v": village_id,
                "why": b.reason,
                "b": b.batch_id,
                "by": b.actor,
            },
        )
    ).first()
    if row is not None:
        b.counts[entity] = b.counts.get(entity, 0) + 1
    return row is not None


async def _alerts(conn: AsyncConnection, b: Batch, where: str, params: dict[str, object]) -> None:
    # `where` is one of the constant conditions below; values are bound.
    sql = "SELECT a.id, w.village_id FROM alert a JOIN water_source w ON w.id = a.source_id "
    rows = await conn.execute(text(sql + "WHERE " + where), params)
    for r in rows.all():
        await _mark(conn, b, "alert", r.id, r.village_id)


async def _session(conn: AsyncConnection, b: Batch, session_id: UUID) -> None:
    village = (
        await conn.execute(
            text(
                "SELECT w.village_id FROM test_session s JOIN water_source w ON w.id = s.source_id "
                "WHERE s.id = :id"
            ),
            {"id": session_id},
        )
    ).scalar_one_or_none()
    if village is None:
        raise ArchiveError("not_found")
    await _alerts(
        conn,
        b,
        "a.trigger_result_id IN (SELECT r.id FROM test_result r WHERE r.session_id = :s)",
        {"s": session_id},
    )
    await _mark(conn, b, "test_session", session_id, village)


async def _source(conn: AsyncConnection, b: Batch, source_id: UUID) -> None:
    village = (
        await conn.execute(
            text("SELECT village_id FROM water_source WHERE id = :id"), {"id": source_id}
        )
    ).scalar_one_or_none()
    if village is None:
        raise ArchiveError("not_found")
    sessions = await conn.execute(
        text("SELECT id FROM test_session WHERE source_id = :id"), {"id": source_id}
    )
    for (sid,) in sessions.all():
        await _session(conn, b, sid)
    await _alerts(conn, b, "a.source_id = :s", {"s": source_id})
    await _mark(conn, b, "water_source", source_id, village)


async def _collector(conn: AsyncConnection, b: Batch, key: UUID) -> None:
    sessions = await conn.execute(
        text("SELECT id FROM test_session WHERE collector_key = :k"), {"k": key}
    )
    for (sid,) in sessions.all():
        await _session(conn, b, sid)
    # Sources this collector added that nobody else has tested.
    own = await conn.execute(
        text(
            "SELECT w.id FROM water_source w WHERE w.collector_key = :k AND NOT EXISTS ("
            "SELECT 1 FROM test_session s WHERE s.source_id = w.id AND s.collector_key <> :k "
            "AND NOT wc_archived('test_session', s.id))"
        ),
        {"k": key},
    )
    for (wid,) in own.all():
        await _source(conn, b, wid)
    await _mark(conn, b, "collector", key, None)


async def _installation(conn: AsyncConnection, b: Batch, installation_id: UUID) -> None:
    found = (
        await conn.execute(
            # Archiving a phone also revokes it: it must not send more.
            text(
                "UPDATE installation SET revoked_at = coalesce(revoked_at, now()) "
                "WHERE id = :id RETURNING id"
            ),
            {"id": installation_id},
        )
    ).first()
    if found is None:
        raise ArchiveError("not_found")
    keys = await conn.execute(
        text(
            "SELECT collector_key FROM collector_profile WHERE installation_id = :i "
            "UNION SELECT collector_key FROM test_session WHERE installation_id = :i "
            "UNION SELECT collector_key FROM water_source WHERE installation_id = :i "
            "AND collector_key IS NOT NULL"
        ),
        {"i": installation_id},
    )
    for (key,) in keys.all():
        await _collector(conn, b, key)
    # Tests the phone sent under a collector already archived elsewhere.
    rest = await conn.execute(
        text(
            "SELECT id FROM test_session WHERE installation_id = :i "
            "AND NOT wc_archived('test_session', id)"
        ),
        {"i": installation_id},
    )
    for (sid,) in rest.all():
        await _session(conn, b, sid)
    await _mark(conn, b, "installation", installation_id, None)


_CASCADE = {
    "installation": _installation,
    "collector": _collector,
    "water_source": _source,
    "test_session": _session,
}


async def archive(
    conn: AsyncConnection, actor: UUID, entity: str, record_id: UUID, reason: str
) -> Batch:
    if entity not in _CASCADE:
        raise ArchiveError("unsupported_entity")
    b = Batch(batch_id=uuid4(), actor=actor, reason=reason)
    already = (
        await conn.execute(text("SELECT wc_archived(:e, :id)"), {"e": entity, "id": record_id})
    ).scalar_one()
    if already:
        raise ArchiveError("already_archived")
    await _CASCADE[entity](conn, b, record_id)
    await conn.execute(
        text("UPDATE archive_mark SET root = true WHERE entity = :e AND record_id = :id"),
        {"e": entity, "id": record_id},
    )
    await _audit(
        conn,
        actor,
        "archive.created",
        entity,
        record_id,
        {"batch_id": str(b.batch_id), "reason": reason, "counts": b.counts},
    )
    return b


async def restore(conn: AsyncConnection, actor: UUID, batch_id: UUID) -> dict[str, int]:
    rows = (
        await conn.execute(
            text(
                "UPDATE archive_mark SET archived = false, restored_by = :by, "
                "restored_at = now() WHERE batch_id = :b AND archived "
                "RETURNING entity, record_id, root"
            ),
            {"b": batch_id, "by": actor},
        )
    ).all()
    if not rows:
        raise ArchiveError("not_found")
    counts: dict[str, int] = {}
    for r in rows:
        counts[r.entity] = counts.get(r.entity, 0) + 1
    root = next((r for r in rows if r.root), rows[0])
    await _audit(
        conn,
        actor,
        "archive.restored",
        root.entity,
        root.record_id,
        {"batch_id": str(batch_id), "counts": counts},
    )
    return counts


async def _audit(
    conn: AsyncConnection,
    actor: UUID,
    action: str,
    entity: str,
    entity_id: UUID,
    after: object,
) -> None:
    await conn.execute(
        text(
            "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id, after) "
            "VALUES (:a, 'console', :act, :e, :id, CAST(:after AS jsonb))"
        ),
        {"a": actor, "act": action, "e": entity, "id": entity_id, "after": json.dumps(after)},
    )
