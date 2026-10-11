"""The P9 performance fixture: 50 sources x 10 tests x 4 readings (2,000).

Dev and test only. Records go through the normal sync push, so the server
classifies them and raises alerts exactly as for real submissions; those
alerts notify nobody and never escalate. Names
and collectors are invented ("Perf source 07", "Perf collector 3"); no
personal data.
"""

from __future__ import annotations

import json
import random
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from typing import Any

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.db.database import Principal
from app.services.sync_push import Change, PushService

CLASS_II = "ba9093d7-4551-54b4-9da1-3c14a7041644"
# Fixed namespace, so a rerun finds the same records (pushes are idempotent).
_NS = uuid.UUID("6d1f6c0e-6a4e-4c51-9a55-8e3f0f2c2a10")


def _id(*parts: object) -> str:
    return str(uuid.uuid5(_NS, "/".join(str(p) for p in parts)))


class _FixturePush(PushService):
    """Submits as the fixture's phone; records name an invented collector
    in their data, as a real phone would."""

    def __init__(self, conn: AsyncConnection, now: datetime, installation: uuid.UUID) -> None:
        super().__init__(conn, Principal.system(), now)
        self.installation = installation

    def _origin(self, d: dict[str, Any]) -> dict[str, Any]:
        key = d.get("collector_key")
        return {
            "inst": self.installation,
            "ck": uuid.UUID(key) if key else None,
            "cs": json.dumps(d["collector_snapshot"]) if "collector_snapshot" in d else None,
            "by": None,
        }


@dataclass
class FixtureReport:
    sources: int
    tests: int
    readings: int
    applied: int
    duplicate: int
    rejected: int


async def load_perf_fixture(
    conn: AsyncConnection,
    *,
    village_code: str,
    sources: int = 50,
    tests_per_source: int = 10,
    now: datetime | None = None,
    seed: int = 9,
) -> FixtureReport:
    now = now or datetime.now(UTC)
    rng = random.Random(seed)  # noqa: S311 - test data, not security
    village = (
        await conn.execute(
            text("SELECT id FROM admin_unit WHERE code = :c AND level = 'village'"),
            {"c": village_code},
        )
    ).scalar_one_or_none()
    if village is None:
        raise ValueError(f"no village with code {village_code}")
    lat0, lon0 = 2.70, 33.65
    changes: list[Change] = []
    for s in range(sources):
        src = _id(village_code, "source", s)
        made = (now - timedelta(days=7 * tests_per_source + 1)).isoformat()
        changes.append(
            Change(
                "water_source",
                "insert",
                src,
                {
                    "id": src,
                    "village_id": str(village),
                    "code": f"{village_code}-P{s:03d}",
                    "name": f"Perf source {s:02d}",
                    "source_type": rng.choice(["borehole", "shallow_well", "protected_spring"]),
                    "lat": round(lat0 + rng.uniform(-0.15, 0.15), 5),
                    "lon": round(lon0 + rng.uniform(-0.2, 0.2), 5),
                    "functional_status": "functional",
                    "created_at_device": made,
                    "updated_at_device": made,
                },
            )
        )
        for t in range(tests_per_source):
            ses, res = _id(village_code, "session", s, t), _id(village_code, "result", s, t)
            at = (now - timedelta(days=7 * t, hours=rng.randint(0, 48))).isoformat()
            n = (s + t) % 6
            unsafe = rng.random() < 0.12
            ph = round(rng.uniform(8.7, 9.6) if unsafe else rng.uniform(6.6, 8.2), 1)
            readings = [
                ("ph", ph, "pH", "high" if unsafe else "ok"),
                ("tds", round(rng.uniform(80, 900)), "mg/L", "ok"),
                ("turbidity", round(rng.uniform(0.5, 6), 1), "NTU", "ok"),
                ("temp", round(rng.uniform(21, 29), 1), "°C", "not_assessed"),
            ]
            changes += [
                Change(
                    "test_session",
                    "insert",
                    ses,
                    {
                        "id": ses,
                        "source_id": src,
                        "reference_standard_id": CLASS_II,
                        "calibrated": True,
                        "tested_at_device": at,
                        "collector_key": _id(village_code, "collector", n),
                        "collector_snapshot": {"full_name": f"Perf collector {n}"},
                    },
                ),
                Change(
                    "test_result",
                    "insert",
                    res,
                    {
                        "id": res,
                        "session_id": ses,
                        "overall": "unsafe" if unsafe else "safe",
                        "standard_id": CLASS_II,
                        "flags": [],
                        "created_at_device": at,
                    },
                ),
            ]
            changes += [
                Change(
                    "reading",
                    "insert",
                    _id(village_code, "reading", s, t, code),
                    {
                        "id": _id(village_code, "reading", s, t, code),
                        "session_id": ses,
                        "result_id": res,
                        "parameter_code": code,
                        "value": str(value),
                        "unit": unit,
                        "result": result,
                    },
                )
                for code, value, unit, result in readings
            ]
    # A stand-in phone for the area: born revoked, with no usable secret,
    # so it can never sign a request.
    installation = uuid.UUID(_id(village_code, "installation"))
    await conn.execute(
        text(
            "INSERT INTO installation (id, admin_unit_id, secret_encrypted, platform, "
            "app_version, revoked_at) VALUES (:id, :v, 'none', 'perf-fixture', '-', now()) "
            "ON CONFLICT (id) DO NOTHING"
        ),
        {"id": installation, "v": village},
    )
    outcomes = await _FixturePush(conn, now, installation).apply(changes)
    # Test data must not notify anyone: drop the queued notices for its
    # alerts and keep them from escalating (a step past any real chain).
    prefix = {"prefix": f"{village_code}-P%"}
    await conn.execute(
        text(
            "DELETE FROM job WHERE kind = 'notify_alert' AND status = 'queued' "
            "AND (payload ->> 'alert_id')::uuid IN (SELECT a.id FROM alert a "
            "JOIN water_source w ON w.id = a.source_id WHERE w.code LIKE :prefix)"
        ),
        prefix,
    )
    await conn.execute(
        text(
            "UPDATE alert SET escalation_level = 99 WHERE id IN (SELECT a.id FROM alert a "
            "JOIN water_source w ON w.id = a.source_id WHERE w.code LIKE :prefix)"
        ),
        prefix,
    )
    count = {"applied": 0, "duplicate": 0, "rejected": 0}
    for o in outcomes:
        count[o.status] = count.get(o.status, 0) + 1
    return FixtureReport(
        sources=sources,
        tests=sources * tests_per_source,
        readings=sources * tests_per_source * 4,
        applied=count["applied"],
        duplicate=count["duplicate"],
        rejected=count["rejected"],
    )
