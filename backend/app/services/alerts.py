"""Server-side alerts (SPEC §4.4 F-ALR-1, ADR-013).

The server raises the same alerts as the phone, from its own classification
of each synced result: E. coli detected, an unsafe result, or a jump from
the source's baseline. Both sides derive the alert ID from the result and
the rule (UUID v5), so an alert raised on the phone and on the server is the
same alert: never a duplicate (errata G7), whichever arrives first.
"""

from __future__ import annotations

import json
import uuid
from datetime import timedelta
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.domain.classification import FLAG_BASELINE_JUMP_PREFIX, ClassificationResult
from app.services.jobs import enqueue

# Shared with packages/domain (alertId in alert_triggers.dart).
ALERT_NAMESPACE = UUID("4a1d8c2e-7b3f-5e60-9d21-8c4b0f6e2a17")

SEVERITY = {"ecoli": "critical", "unsafe": "high", "baseline_jump": "medium"}
# A provisional SMS alert and its full record match within this window.
MATCH_WINDOW = timedelta(hours=3)


def alert_id(result_id: UUID | str, trigger_rule: str) -> UUID:
    """The one ID an alert for this result and rule can have."""
    return uuid.uuid5(ALERT_NAMESPACE, f"{result_id}/{trigger_rule}")


def triggers(result: ClassificationResult, germ_parameter: str = "ecoli") -> list[str]:
    """Most urgent first; inconclusive results raise none (retest instead)."""
    out = []
    by_code = {a.parameter_code: a for a in result.readings}
    germ = by_code.get(germ_parameter)
    if germ is not None and germ.result.value == "detected":
        out.append("ecoli")
    if result.overall.value == "unsafe":
        out.append("unsafe")
    if any(f.startswith(FLAG_BASELINE_JUMP_PREFIX) for f in result.flags):
        out.append("baseline_jump")
    return out


async def raise_alerts(
    conn: AsyncConnection, result_id: UUID, result: ClassificationResult
) -> list[UUID]:
    """Creates the alerts this result calls for, unless they exist, and
    queues their notifications. Returns the new alerts' IDs."""
    head = (
        await conn.execute(
            text(
                "SELECT s.source_id, s.installation_id, s.collector_key, s.collector_snapshot, "
                "s.tested_at_device FROM test_result r JOIN test_session s "
                "ON s.id = r.session_id WHERE r.id = :id"
            ),
            {"id": result_id},
        )
    ).one()
    created = []
    for rule in triggers(result):
        aid = alert_id(result_id, rule)
        row = (
            await conn.execute(
                text(
                    "INSERT INTO alert (id, source_id, trigger_result_id, trigger_rule, severity, "
                    "status, opened_at, installation_id, collector_key, collector_snapshot, "
                    "server_seq) VALUES (:id, :src, :res, :rule, :sev, 'open', :at, :inst, :ck, "
                    "CAST(:cs AS jsonb), 0) ON CONFLICT DO NOTHING RETURNING id"
                ),
                {
                    "id": aid,
                    "src": head.source_id,
                    "res": result_id,
                    "rule": rule,
                    "sev": SEVERITY[rule],
                    "at": head.tested_at_device,
                    "inst": head.installation_id,
                    "ck": head.collector_key,
                    "cs": None
                    if head.collector_snapshot is None
                    else _json(head.collector_snapshot),
                },
            )
        ).first()
        if row is not None:
            await notify_or_reconcile(conn, aid)
            created.append(aid)
    return created


async def notify_or_reconcile(conn: AsyncConnection, alert_id: UUID) -> None:
    """A full alert just arrived. If an SMS already opened a provisional
    alert for it, merge the two (people were already told); otherwise
    notify."""
    if await reconcile(conn, alert_id) is None:
        await notify_new(conn, alert_id)


async def notify_new(conn: AsyncConnection, alert_id: UUID) -> None:
    """Queues the notification of a new alert (within ~seconds, gate: ≤ 5 min)."""
    await enqueue(conn, "notify_alert", {"alert_id": str(alert_id), "level": 0})


def _json(value: object) -> str:
    return value if isinstance(value, str) else json.dumps(value)


async def reconcile(conn: AsyncConnection, alert_id: UUID) -> UUID | None:
    """A full alert just arrived: close the matching provisional SMS alert
    and link it, so there is one alert. Returns the provisional alert's ID
    (its stakeholders were already told)."""
    real = (
        await conn.execute(
            text("SELECT source_id, trigger_rule, opened_at FROM alert WHERE id = :id"),
            {"id": alert_id},
        )
    ).one()
    provisional = (
        await conn.execute(
            text(
                "SELECT id FROM alert WHERE provisional AND linked_alert_id IS NULL "
                "AND source_id = :s AND trigger_rule = :t AND opened_at BETWEEN :lo AND :hi "
                "ORDER BY opened_at LIMIT 1 FOR UPDATE"
            ),
            {
                "s": real.source_id,
                "t": real.trigger_rule,
                "lo": real.opened_at - MATCH_WINDOW,
                "hi": real.opened_at + MATCH_WINDOW,
            },
        )
    ).first()
    if provisional is None:
        return None
    await conn.execute(
        text(
            "UPDATE alert SET status = 'closed', closed_at = now(), linked_alert_id = :real, "
            "version = version + 1 WHERE id = :id"
        ),
        {"real": alert_id, "id": provisional.id},
    )
    await add_event(conn, provisional.id, "reconciled", json.dumps({"alert_id": str(alert_id)}))
    await add_event(
        conn, alert_id, "reconciled", json.dumps({"provisional_alert_id": str(provisional.id)})
    )
    return UUID(str(provisional.id))


async def add_event(conn: AsyncConnection, alert_id: UUID, kind: str, note: str) -> None:
    await conn.execute(
        text(
            "INSERT INTO alert_event (id, alert_id, event_type, note, server_seq) "
            "VALUES (gen_random_uuid(), :a, :k, :n, 0)"
        ),
        {"a": alert_id, "k": kind, "n": note},
    )
