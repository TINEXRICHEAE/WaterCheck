"""The dashboard summary the web Console shows first (P9 web gate, ADR-014).

The web keeps no data between visits (SPEC §10.2), so a reload would wait
for the whole area to download before showing anything. This computes, on
the server, what the dashboard opens with: the KPIs, overdue sources,
collector activity, the latest tests and the latest issue. The full data
still syncs in the background for the map, the sources and the profile
comparison.

Same rules as the device (`DashboardQueries`), "as collected":
- a correcting result replaces the one it corrects;
- the server's classification under the collection profile wins over the
  device's;
- the testing schedule follows results as collected.
Row-level security limits everything to the user's areas.
"""

from __future__ import annotations

import json
import statistics
from collections.abc import Sequence
from dataclasses import dataclass, field
from datetime import UTC, date, datetime, timedelta
from typing import Any
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.domain.classification import OverallStatus
from app.domain.model import DomainRules
from app.domain.schedule import ScheduleStatus, compute_schedule


@dataclass
class Summary:
    sources: int = 0
    tested_in_period: int = 0
    unsafe_in_period: int = 0
    open_alerts: int = 0
    median_ack_seconds: float | None = None
    overdue: list[dict[str, Any]] = field(default_factory=list)
    collectors: list[dict[str, Any]] = field(default_factory=list)
    latest_tests: list[dict[str, Any]] = field(default_factory=list)
    latest_issue: dict[str, Any] | None = None


async def _rules(conn: AsyncConnection) -> DomainRules:
    doc = (
        await conn.execute(text("SELECT document FROM config_document WHERE key = 'rules'"))
    ).scalar_one()
    return DomainRules.from_json(json.loads(doc) if isinstance(doc, str) else doc)


async def summary(
    conn: AsyncConnection,
    *,
    area_id: UUID | None,
    days: int,
    now: datetime | None = None,
) -> Summary:
    now = now or datetime.now(UTC)
    since = now - timedelta(days=days)
    area = {"area": area_id}

    sources = (
        await conn.execute(
            text(
                "SELECT w.id, w.code, w.name, ST_Y(w.location::geometry) AS lat, "
                "ST_X(w.location::geometry) AS lon FROM water_source w "
                "WHERE w.is_active AND NOT wc_archived('water_source', w.id) "
                "AND (CAST(:area AS uuid) IS NULL "
                "OR wc_under(w.village_id, CAST(:area AS uuid)))"
            ),
            area,
        )
    ).all()
    by_id = {s.id: s for s in sources}
    out = Summary(sources=len(sources))
    if not sources:
        return out

    # Every result of these sources, newest first, without corrected ones.
    results = (
        await conn.execute(
            text(
                "SELECT r.id, r.overall AS device_overall, c.overall AS server_overall, "
                "s.id AS session_id, s.source_id, s.tested_at_device, s.collector_key, "
                "s.collector_snapshot, rs.is_custom, rs.code AS profile_code "
                "FROM test_result r JOIN test_session s ON s.id = r.session_id "
                "JOIN water_source w ON w.id = s.source_id "
                "JOIN reference_standard rs ON rs.id = r.standard_id "
                "LEFT JOIN classification c ON c.result_id = r.id "
                "  AND c.standard_id = r.standard_id AND c.computed_by = 'server' "
                "WHERE w.is_active AND (CAST(:area AS uuid) IS NULL "
                "OR wc_under(w.village_id, CAST(:area AS uuid))) "
                "AND NOT wc_archived('test_session', s.id) "
                "AND NOT EXISTS (SELECT 1 FROM test_result x WHERE x.amendment_of = r.id) "
                "ORDER BY s.tested_at_device DESC"
            ),
            area,
        )
    ).all()

    rules = await _rules(conn)
    history: dict[UUID, list[tuple[date, OverallStatus]]] = {}
    latest: dict[UUID, Any] = {}
    seen_sessions: set[UUID] = set()
    for r in results:
        if r.session_id in seen_sessions:
            continue
        seen_sessions.add(r.session_id)
        history.setdefault(r.source_id, []).append(
            (r.tested_at_device.date(), OverallStatus(r.device_overall))
        )
        latest.setdefault(r.source_id, r)

    def shown(r: Any) -> str:
        return str(r.server_overall or r.device_overall)

    today = now.date()
    for sid, s in by_id.items():
        state = compute_schedule(history.get(sid, []), today, rules.schedule)
        if state.status is ScheduleStatus.OVERDUE:
            last = latest.get(sid)
            out.overdue.append(
                {
                    "id": sid,
                    "code": s.code,
                    "name": s.name,
                    "due_date": state.due_date,
                    "latest_overall": shown(last) if last else None,
                }
            )
    out.overdue.sort(key=lambda o: (o["due_date"], o["code"]))

    # KPIs: the newest test of each source within the period.
    for sid in by_id:
        newest = next(
            (r for r in results if r.source_id == sid and r.tested_at_device >= since), None
        ) if sid in latest else None  # fmt: skip
        if newest is not None:
            out.tested_in_period += 1
            if shown(newest) == "unsafe":
                out.unsafe_in_period += 1

    for r in results[:10]:
        snap = _snapshot(r.collector_snapshot)
        src = by_id[r.source_id]
        out.latest_tests.append(
            {
                "source_id": r.source_id,
                "code": src.code,
                "name": src.name,
                "tested_at": r.tested_at_device,
                "overall": shown(r),
                "collector_name": snap.get("full_name"),
                "custom_limits": r.is_custom,
            }
        )

    out.collectors = await _collectors(conn, results, since)
    await _alerts(conn, out, area, since, by_id, latest, shown)
    return out


def _snapshot(value: object) -> dict[str, Any]:
    if value is None:
        return {}
    parsed = json.loads(value) if isinstance(value, str) else value
    return parsed if isinstance(parsed, dict) else {}


async def _collectors(
    conn: AsyncConnection, results: Sequence[Any], since: datetime
) -> list[dict[str, Any]]:
    marks: dict[UUID, str] = {
        r.collector_key: r.status
        for r in await conn.execute(text("SELECT collector_key, status FROM collector_mark"))
    }
    sessions = {r.session_id: r for r in results}.values()
    counts: dict[UUID, int] = {}
    newest: dict[UUID, Any] = {}
    for s in sessions:
        if s.collector_key is None or s.tested_at_device < since:
            continue
        counts[s.collector_key] = counts.get(s.collector_key, 0) + 1
        prev = newest.get(s.collector_key)
        if prev is None or s.tested_at_device > prev.tested_at_device:
            newest[s.collector_key] = s
    out = []
    for key, s in newest.items():
        snap = _snapshot(s.collector_snapshot)
        out.append(
            {
                "collector_key": key,
                "name": snap.get("full_name") or "?",
                "submissions": counts[key],
                "last_submission": s.tested_at_device,
                "mark": marks.get(key),
            }
        )
    out.sort(key=lambda c: c["last_submission"], reverse=True)
    return out[:20]


async def _alerts(
    conn: AsyncConnection,
    out: Summary,
    area: dict[str, Any],
    since: datetime,
    by_id: dict[UUID, Any],
    latest: dict[UUID, Any],
    shown: Any,
) -> None:
    alerts = (
        await conn.execute(
            text(
                "SELECT a.id, a.source_id, a.trigger_rule, a.severity, a.status, a.opened_at, "
                "a.acknowledged_at FROM alert a JOIN water_source w ON w.id = a.source_id "
                "WHERE w.is_active AND NOT wc_archived('alert', a.id) "
                "AND (CAST(:area AS uuid) IS NULL "
                "OR wc_under(w.village_id, CAST(:area AS uuid))) ORDER BY a.opened_at DESC"
            ),
            area,
        )
    ).all()
    open_ = [a for a in alerts if a.status not in ("closed", "false_alarm")]
    out.open_alerts = len(open_)
    acks = [
        (a.acknowledged_at - a.opened_at).total_seconds()
        for a in alerts
        if a.acknowledged_at is not None and a.acknowledged_at >= since
    ]
    out.median_ack_seconds = statistics.median(acks) if acks else None

    # The issue to look at first: the newest open alert on a located
    # source, else the newest unsafe result.
    for a in open_:
        s = by_id.get(a.source_id)
        if s is not None and s.lat is not None:
            out.latest_issue = {
                "source_id": s.id,
                "code": s.code,
                "name": s.name,
                "lat": s.lat,
                "lon": s.lon,
                "trigger_rule": a.trigger_rule,
                "severity": a.severity,
                "at": a.opened_at,
            }
            return
    unsafe = [
        (r.tested_at_device, sid)
        for sid, r in latest.items()
        if shown(r) == "unsafe" and by_id[sid].lat is not None
    ]
    if unsafe:
        at, sid = max(unsafe)
        s = by_id[sid]
        out.latest_issue = {
            "source_id": sid,
            "code": s.code,
            "name": s.name,
            "lat": s.lat,
            "lon": s.lon,
            "trigger_rule": "unsafe",
            "severity": "high",
            "at": at,
        }
