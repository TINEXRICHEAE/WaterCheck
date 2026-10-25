"""Sync push: apply a batch of client changes (SPEC §8.1-8.4, ADR-011).

- Idempotent: records are keyed by their client UUID (or code for custom
  parameters). Replaying a record answers ``duplicate`` and changes nothing.
- Parents before children: the batch is applied in entity order (source →
  session → result → readings → alert → events), each record in its own
  savepoint. That gives the per-record answers of §8.2: one bad record never
  sinks the batch. Sorting stands in for deferred foreign keys, which only
  fail at commit, so they could not say which record was at fault.
- Never trusted from the client: who sent it (installation, user), server
  times, versions, server classification and clock flags.
"""

from __future__ import annotations

import json
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from decimal import Decimal, InvalidOperation
from typing import Any, Literal
from uuid import UUID, uuid4

import structlog
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError, IntegrityError
from sqlalchemy.ext.asyncio import AsyncConnection

from app.db.database import Principal
from app.domain.model import ReferenceProfile
from app.services.alerts import notify_or_reconcile, raise_alerts
from app.services.classification import classify_result

log = structlog.get_logger()

Status = Literal["applied", "duplicate", "conflict", "rejected"]

# Parents first; within an entity, the order the client queued them.
ORDER = [
    "admin_unit",
    "place_name",
    "parameter_definition",
    "reference_standard",
    "water_source",
    "calibration",
    "test_session",
    "test_result",
    "reading",
    "alert",
    "alert_event",
    "sanitary_inspection",
    "attachment",
    "collector_mark",
    "submission_flag",
    "message",
]
ATTACHMENT_MIME = {"image/jpeg"}

# What a signed-in Console user may queue (SPEC §8.4, P6).
USER_ENTITIES = {
    "water_source",
    "place_name",
    "alert_event",
    "collector_mark",
    "submission_flag",
    "reference_standard",
    "message",
}
# Marks and flags are stakeholder judgements, never sent by phones.
USER_ONLY = {"collector_mark", "submission_flag"}

# The area a thread belongs to, from its subject (ADR-022).
_THREAD_AREA = {
    "source": "SELECT village_id FROM water_source WHERE id = :s",
    "test": (
        "SELECT w.village_id FROM test_session t JOIN water_source w ON w.id = t.source_id "
        "WHERE t.id = :s"
    ),
    "area": "SELECT id FROM admin_unit WHERE id = :s",
    # A collector's area: where they last tested or added a source.
    "collector": (
        "SELECT village_id FROM ("
        " SELECT w.village_id, t.tested_at_device AS at FROM test_session t"
        " JOIN water_source w ON w.id = t.source_id WHERE t.collector_key = :s"
        " UNION ALL"
        " SELECT village_id, created_at_device FROM water_source WHERE collector_key = :s"
        ") x ORDER BY at DESC NULLS LAST LIMIT 1"
    ),
}


# Kinds of place a person may add from the map (ADR-028).
ADDED_PLACE_KINDS = {
    "village",
    "trading_centre",
    "school",
    "health_centre",
    "market",
    "worship",
    "landmark",
    "other",
}

# Area levels a phone may add below (district down), top first.
_PLACE_ORDER = ["district", "subcounty", "parish", "village"]

# Clock sanity (SPEC §5.2): tested in the future, or long before first sync.
FUTURE_SLACK = timedelta(days=1)
TOO_OLD = timedelta(days=60)


@dataclass(frozen=True)
class Change:
    entity: str
    op: Literal["insert", "update"]
    id: str
    data: dict[str, Any]
    base_version: int | None = None


@dataclass
class Outcome:
    id: str
    entity: str
    status: Status
    server_version: int | None = None
    reason: str | None = None


class Rejected(Exception):
    def __init__(self, reason: str) -> None:
        super().__init__(reason)
        self.reason = reason


# ------------------------------------------------------------ conversions
def _uuid(v: Any, field: str) -> UUID | None:
    if v is None:
        return None
    try:
        return UUID(str(v))
    except ValueError as e:
        raise Rejected(f"invalid:{field}") from e


def _ts(v: Any, field: str) -> datetime | None:
    if v is None:
        return None
    try:
        t = datetime.fromisoformat(str(v).replace("Z", "+00:00"))
    except ValueError as e:
        raise Rejected(f"invalid:{field}") from e
    return t if t.tzinfo else t.replace(tzinfo=UTC)


def _num(v: Any, field: str) -> Decimal | None:
    if v is None:
        return None
    try:
        return Decimal(str(v))
    except InvalidOperation as e:
        raise Rejected(f"invalid:{field}") from e


def _json(v: Any) -> str | None:
    """Client text columns hold JSON as a string; the API may send objects."""
    if v is None:
        return None
    if isinstance(v, str):
        try:
            json.loads(v)
        except json.JSONDecodeError as e:
            raise Rejected("invalid:json") from e
        return v
    return json.dumps(v)


def _list(v: Any) -> list[str]:
    if v is None:
        return []
    if isinstance(v, str):
        v = json.loads(v)
    if not isinstance(v, list):
        raise Rejected("invalid:list")
    return [str(x) for x in v]


def _req(d: dict[str, Any], field: str) -> Any:
    if d.get(field) is None:
        raise Rejected(f"missing:{field}")
    return d[field]


_POINT = (
    "CASE WHEN CAST(:lat AS double precision) IS NULL THEN NULL ELSE "
    "CAST(ST_SetSRID(ST_MakePoint(CAST(:lon AS double precision), "
    "CAST(:lat AS double precision)), 4326) AS geography) END"
)


class PushService:
    def __init__(self, conn: AsyncConnection, principal: Principal, now: datetime) -> None:
        self.conn = conn
        self.p = principal
        self.now = now
        self.classify: set[UUID] = set()
        self._collectors_seen: set[UUID] = set()
        # Collectors signed out on this device (ADR-024): their records are refused.
        self._signed_out: set[UUID] = set()

    async def _refuse_archived(self, entity: str, record_id: UUID | None) -> None:
        """New records and edits on an archived record are refused (ADR-018)."""
        if record_id is None:
            return
        archived = (
            await self.conn.execute(
                text("SELECT wc_archived(:e, :id)"), {"e": entity, "id": record_id}
            )
        ).scalar_one()
        if archived:
            raise Rejected("archived")

    async def _actor_name(self, o: dict[str, Any]) -> str | None:
        if o["cs"]:
            name = json.loads(o["cs"]).get("full_name")
            return str(name) if name else None
        if o["by"]:
            return (
                await self.conn.execute(
                    text("SELECT full_name FROM app_user WHERE id = :id"), {"id": o["by"]}
                )
            ).scalar_one_or_none()
        return None

    async def _trail(
        self,
        entity: str,
        record_id: UUID,
        village: UUID | None,
        o: dict[str, Any],
        changes: list[tuple[str, Any, Any]],
    ) -> None:
        """One trail row per changed field: old → new, who, when (ADR-018)."""
        if not changes:
            return
        name = await self._actor_name(o)
        for field, old, new in changes:
            await self.conn.execute(
                text(
                    "INSERT INTO change_trail (entity, record_id, field, old_value, new_value, "
                    "village_id, actor_user_id, installation_id, collector_key, actor_name, "
                    "server_seq, server_xid) VALUES (:e, :id, :f, CAST(:old AS jsonb), "
                    "CAST(:new AS jsonb), :v, :by, :inst, :ck, :name, 0, '1'::xid8)"
                ),
                {
                    "e": entity,
                    "id": record_id,
                    "f": field,
                    "old": json.dumps(old, default=str),
                    "new": json.dumps(new, default=str),
                    "v": village,
                    "by": o["by"],
                    "inst": o["inst"],
                    "ck": o["ck"],
                    "name": name,
                },
            )

    async def _note_collector(self, o: dict[str, Any]) -> None:
        """Keeps each collector's latest details; a newer profile version
        writes the changed fields to the trail. Records the device they use
        (ADR-024), and refuses their records from a device they signed out."""
        key = o["ck"]
        if self.p.kind != "installation" or key is None:
            return
        if key in self._signed_out:
            raise Rejected("collector_signed_out")
        if key in self._collectors_seen:
            return
        device = (
            await self.conn.execute(
                text(
                    "INSERT INTO collector_device (collector_key, installation_id, signed_in_via) "
                    "VALUES (:k, :i, 'created') ON CONFLICT (collector_key, installation_id) "
                    "DO UPDATE SET last_seen_at = now() RETURNING signed_out_at"
                ),
                {"k": key, "i": o["inst"]},
            )
        ).one()
        if device.signed_out_at is not None:
            self._signed_out.add(key)
            raise Rejected("collector_signed_out")
        self._collectors_seen.add(key)
        if not o["cs"]:
            return
        snap = json.loads(o["cs"])
        version = int(snap.get("profile_version") or 1)
        cur = (
            await self.conn.execute(
                text(
                    "SELECT snapshot, profile_version FROM collector_profile "
                    "WHERE collector_key = :k FOR UPDATE"
                ),
                {"k": key},
            )
        ).first()
        if cur is None:
            await self.conn.execute(
                text(
                    "INSERT INTO collector_profile (collector_key, installation_id, snapshot, "
                    "profile_version) VALUES (:k, :i, CAST(:s AS jsonb), :v) "
                    "ON CONFLICT (collector_key) DO NOTHING"
                ),
                {"k": key, "i": o["inst"], "s": o["cs"], "v": version},
            )
            return
        old = cur.snapshot if isinstance(cur.snapshot, dict) else json.loads(cur.snapshot)
        if version <= cur.profile_version:
            await self.conn.execute(
                text("UPDATE collector_profile SET last_seen_at = now() WHERE collector_key = :k"),
                {"k": key},
            )
            return
        await self.conn.execute(
            text(
                "UPDATE collector_profile SET snapshot = CAST(:s AS jsonb), "
                "profile_version = :v, last_seen_at = now() WHERE collector_key = :k"
            ),
            {"k": key, "s": o["cs"], "v": version},
        )
        area = (
            await self.conn.execute(
                text("SELECT admin_unit_id FROM installation WHERE id = :i"), {"i": o["inst"]}
            )
        ).scalar_one_or_none()
        changed = [
            (f, old.get(f), snap.get(f))
            for f in sorted(set(old) | set(snap))
            if f != "profile_version" and old.get(f) != snap.get(f)
        ]
        await self._trail("collector", key, area, o, changed)

    # Who sent it ------------------------------------------------------
    def _origin(self, d: dict[str, Any]) -> dict[str, Any]:
        if self.p.kind == "installation":
            return {
                "inst": self.p.installation_id,
                "ck": _uuid(d.get("collector_key"), "collector_key"),
                "cs": _json(d.get("collector_snapshot")),
                "by": None,
            }
        return {"inst": None, "ck": None, "cs": None, "by": self.p.user_id}

    async def apply(self, changes: list[Change]) -> list[Outcome]:
        # Entity rank first; within an entity the client's own order (it
        # queues records as they are made, so an edit follows its insert).
        def key(ic: tuple[int, Change]) -> tuple[int, int]:
            i, c = ic
            return (ORDER.index(c.entity) if c.entity in ORDER else len(ORDER)), i

        outcomes: dict[int, Outcome] = {}
        for i, c in sorted(enumerate(changes), key=key):
            outcomes[i] = await self._one(c)
        for result_id in sorted(self.classify):
            async with self.conn.begin_nested():
                classified = await classify_result(self.conn, result_id)
                session = next(c for c in classified if c.is_session_profile)
                if session.result is not None:
                    # Same alerts as the phone, by the same IDs (ADR-013).
                    await raise_alerts(self.conn, result_id, session.result)
        return [outcomes[i] for i in range(len(changes))]

    async def _one(self, c: Change) -> Outcome:
        handler = _HANDLERS.get((c.entity, c.op))
        if handler is None:
            return Outcome(c.id, c.entity, "rejected", reason="unsupported_change")
        if self.p.kind == "user" and c.entity not in USER_ENTITIES:
            return Outcome(c.id, c.entity, "rejected", reason="not_allowed")
        if self.p.kind != "user" and c.entity in USER_ONLY:
            return Outcome(c.id, c.entity, "rejected", reason="not_allowed")
        try:
            async with self.conn.begin_nested():
                await self._note_collector(self._origin(c.data))
                return await handler(self, c)
        except Rejected as e:
            return Outcome(c.id, c.entity, "rejected", reason=e.reason)
        except IntegrityError as e:
            return Outcome(c.id, c.entity, "rejected", reason=_db_reason(e))
        except DBAPIError as e:
            reason = _db_reason(e)
            # Child rows are checked through their parent: a parent the caller
            # cannot see is, to them, a missing one (and says nothing more).
            if reason == "out_of_scope" and c.entity != "water_source":
                reason = "missing_parent"
            if reason == "server_error":
                log.exception("sync_push_failed", entity=c.entity, id=c.id)
            return Outcome(c.id, c.entity, "rejected", reason=reason)

    async def _insert(self, c: Change, sql: str, params: dict[str, Any]) -> Outcome:
        row = (await self.conn.execute(text(sql), params)).first()
        if row is None:
            return Outcome(c.id, c.entity, "duplicate")
        return Outcome(c.id, c.entity, "applied")

    # Handlers ----------------------------------------------------------
    async def admin_unit_insert(self, c: Change) -> Outcome:
        """A place a collector typed that is not in the list (ADR-019): a
        sub-county, parish or village below a known place, marked 'new'
        for the IT admin to review. Phones only."""
        if self.p.kind != "installation":
            raise Rejected("not_allowed")
        d, o = c.data, self._origin(c.data)
        uid = _uuid(c.id, "id")
        level = str(_req(d, "level"))
        name = " ".join(str(_req(d, "name")).split())
        if level not in _PLACE_ORDER[1:] or not name or len(name) > 120:
            raise Rejected("invalid_value")
        parent = (
            await self.conn.execute(
                text("SELECT level FROM admin_unit WHERE id = :id"),
                {"id": _uuid(_req(d, "parent_id"), "parent_id")},
            )
        ).first()
        if parent is None:
            raise Rejected("missing_parent")
        # Exactly one level down: a village sits in a parish, and so on.
        if (
            parent.level not in _PLACE_ORDER
            or _PLACE_ORDER.index(parent.level) != _PLACE_ORDER.index(level) - 1
        ):
            raise Rejected("invalid_value")
        if (
            await self.conn.execute(text("SELECT 1 FROM admin_unit WHERE id = :id"), {"id": uid})
        ).first():
            return Outcome(c.id, c.entity, "duplicate")
        # Two phones can add the same name offline: keep both (the admin
        # merges); a taken code gets a suffix, which flows back on pull.
        code = str(_req(d, "code"))
        reason = None
        if (
            await self.conn.execute(text("SELECT 1 FROM admin_unit WHERE code = :c"), {"c": code})
        ).first():
            code = f"{code}-{str(uid)[-4:].upper()}"
            reason = "code_renamed"
        await self.conn.execute(
            text(
                "INSERT INTO admin_unit (id, level, name, code, parent_id, review_status, "
                "added_by_installation, added_collector_snapshot, added_at, server_seq) "
                "VALUES (:id, :level, :name, :code, :parent, 'new', :inst, "
                "CAST(:cs AS jsonb), now(), 0)"
            ),
            {
                "id": uid,
                "level": level,
                "name": name,
                "code": code,
                "parent": _uuid(d["parent_id"], "parent_id"),
                "inst": o["inst"],
                "cs": o["cs"],
            },
        )
        return Outcome(c.id, c.entity, "applied", reason=reason)

    async def place_name_insert(self, c: Change) -> Outcome:
        """A place added from the map (ADR-028): a name and a kind at a
        point. The server puts it in its sub-county from the boundaries;
        everyone sees it with the next sync."""
        d, o = c.data, self._origin(c.data)
        pid = _uuid(c.id, "id")
        name = " ".join(str(_req(d, "name")).split())
        kind = str(_req(d, "kind"))
        if not name or len(name) > 120 or kind not in ADDED_PLACE_KINDS:
            raise Rejected("invalid_value")
        lat, lon = _num(_req(d, "lat"), "lat"), _num(_req(d, "lon"), "lon")
        if lat is None or lon is None or not (-90 <= lat <= 90 and -180 <= lon <= 180):
            raise Rejected("invalid_value")
        if (
            await self.conn.execute(text("SELECT 1 FROM place_name WHERE id = :id"), {"id": pid})
        ).first():
            return Outcome(c.id, c.entity, "duplicate")
        subcounty = (
            await self.conn.execute(
                text("SELECT wc_subcounty_at(:lat, :lon)"),
                {"lat": float(lat), "lon": float(lon)},
            )
        ).scalar()
        if subcounty is None:
            raise Rejected("outside_uganda")
        # The name shown as "added by …": the tester's, or the user's.
        if o["by"] is not None:
            who = (
                await self.conn.execute(
                    text("SELECT full_name FROM app_user WHERE id = :id"), {"id": o["by"]}
                )
            ).scalar()
        else:
            snapshot = d.get("collector_snapshot")
            if isinstance(snapshot, str):
                try:
                    snapshot = json.loads(snapshot)
                except ValueError:
                    snapshot = None
            who = snapshot.get("full_name") if isinstance(snapshot, dict) else None
        await self.conn.execute(
            text(
                "INSERT INTO place_name (id, name, kind, lat, lon, subcounty_id, "
                "added_by_installation, added_collector_snapshot, added_by_user, added_by_name, "
                "added_at, server_seq) VALUES (:id, :name, :kind, :lat, :lon, :sub, :inst, "
                "CAST(:cs AS jsonb), :by, :who, now(), 0)"
            ),
            {
                "id": pid,
                "name": name,
                "kind": kind,
                "lat": float(lat),
                "lon": float(lon),
                "sub": subcounty,
                "inst": o["inst"],
                "cs": o["cs"],
                "by": o["by"],
                "who": who,
            },
        )
        return Outcome(c.id, c.entity, "applied")

    async def water_source_insert(self, c: Change) -> Outcome:
        d, o = c.data, self._origin(c.data)
        params = {
            "id": _uuid(c.id, "id"),
            "village": _uuid(_req(d, "village_id"), "village_id"),
            "code": str(_req(d, "code")),
            "name": d.get("name"),
            "type": str(_req(d, "source_type")),
            "lat": d.get("lat"),
            "lon": d.get("lon"),
            "acc": d.get("location_accuracy_m"),
            "hh": d.get("households_served"),
            "fs": d.get("functional_status") or "functional",
            "active": d.get("is_active", True),
            "cad": _ts(d.get("created_at_device"), "created_at_device"),
            "uad": _ts(d.get("updated_at_device"), "updated_at_device"),
            **o,
        }
        exists = (
            await self.conn.execute(
                text("SELECT 1 FROM water_source WHERE id = :id"), {"id": params["id"]}
            )
        ).first()
        if exists:
            return Outcome(c.id, c.entity, "duplicate")
        # Two phones in one village can pick the same code offline: keep the
        # record and give it a distinct code, which flows back on pull.
        reason = None
        taken = (
            await self.conn.execute(
                text("SELECT 1 FROM water_source WHERE village_id = :v AND code = :c"),
                {"v": params["village"], "c": params["code"]},
            )
        ).first()
        if taken:
            params["code"] = f"{params['code']}-{str(params['id'])[:4].upper()}"
            reason = "code_renamed"
        await self.conn.execute(
            text(
                "INSERT INTO water_source (id, village_id, code, name, source_type, location, "  # noqa: S608 - constant SQL
                "location_accuracy_m, households_served, functional_status, is_active, "
                "created_by, installation_id, collector_key, collector_snapshot, "
                "created_at_device, updated_at_device, server_seq) VALUES (:id, :village, :code, "
                f":name, :type, {_POINT}, :acc, :hh, :fs, :active, :by, :inst, :ck, "
                "CAST(:cs AS jsonb), :cad, :uad, 0)"
            ),
            params,
        )
        return Outcome(c.id, c.entity, "applied", server_version=1, reason=reason)

    async def water_source_update(self, c: Change) -> Outcome:
        """Optimistic concurrency on ``version`` (SPEC §8.4): on a stale base,
        name/households/location are last-writer-wins; functional status and
        active flag keep the server's value and record a conflict."""
        d = c.data
        sid = _uuid(c.id, "id")
        cur = (
            (
                await self.conn.execute(
                    text(
                        "SELECT version, name, households_served, functional_status, is_active, "
                        "source_type, location_accuracy_m, village_id, "
                        "ST_Y(location::geometry) AS lat, ST_X(location::geometry) AS lon "
                        "FROM water_source WHERE id = :id FOR UPDATE"
                    ),
                    {"id": sid},
                )
            )
            .mappings()
            .first()
        )
        if cur is None:
            raise Rejected("not_found")
        await self._refuse_archived("water_source", sid)
        stale = c.base_version is not None and c.base_version != cur["version"]
        sets: dict[str, Any] = {}
        for f in ("name", "households_served", "source_type", "location_accuracy_m"):
            if f in d:
                sets[f] = d[f]
        conflicts: list[tuple[str, Any, Any]] = []
        for f in ("functional_status", "is_active"):
            if f not in d:
                continue
            if stale and d[f] != cur[f]:
                conflicts.append((f, cur[f], d[f]))
            else:
                sets[f] = d[f]
        point = "lat" in d or "lon" in d
        if not sets and not point and not conflicts:
            return Outcome(c.id, c.entity, "duplicate", server_version=cur["version"])
        version = cur["version"]
        if sets or point:
            assignments = [f"{k} = :{k}" for k in sets]
            if point:
                assignments.append(f"location = {_POINT}")
            version = (
                await self.conn.execute(
                    text(
                        f"UPDATE water_source SET {', '.join(assignments)}, "  # noqa: S608 - fixed column names
                        "version = version + 1, updated_at_device = :uad "
                        "WHERE id = :id RETURNING version"
                    ),
                    {
                        **sets,
                        "lat": d.get("lat"),
                        "lon": d.get("lon"),
                        "uad": _ts(d.get("updated_at_device"), "updated_at_device"),
                        "id": sid,
                    },
                )
            ).scalar_one()
        trail = [(f, cur[f], v) for f, v in sets.items() if cur[f] != v]
        if point:
            for f in ("lat", "lon"):
                if f in d and d[f] != cur[f]:
                    trail.append((f, cur[f], d[f]))
        if sid is not None:
            await self._trail("water_source", sid, cur["village_id"], self._origin(d), trail)
        for field, server_value, client_value in conflicts:
            await self.conn.execute(
                text(
                    "INSERT INTO sync_conflict (entity, entity_id, field, server_value, "
                    "client_value, installation_id, user_id) VALUES ('water_source', :id, :f, "
                    "CAST(:sv AS jsonb), CAST(:cv AS jsonb), :inst, :user)"
                ),
                {
                    "id": sid,
                    "f": field,
                    "sv": json.dumps(server_value),
                    "cv": json.dumps(client_value),
                    "inst": self.p.installation_id,
                    "user": self.p.user_id,
                },
            )
        if conflicts:
            return Outcome(
                c.id,
                c.entity,
                "conflict",
                server_version=version,
                reason="kept_server:" + ",".join(f for f, _, _ in conflicts),
            )
        return Outcome(c.id, c.entity, "applied", server_version=version)

    async def calibration_insert(self, c: Change) -> Outcome:
        d, o = c.data, self._origin(c.data)
        return await self._insert(
            c,
            "INSERT INTO calibration (id, tester_serial, tester_profile_id, "
            "reference_standard_id, buffers, passed, installation_id, collector_key, "
            "collector_snapshot, performed_at_device, server_seq) VALUES (:id, :serial, "
            ":tp, :rs, CAST(:buffers AS jsonb), :passed, :inst, :ck, CAST(:cs AS jsonb), "
            ":at, 0) ON CONFLICT (id) DO NOTHING RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "serial": d.get("tester_serial"),
                "tp": _uuid(d.get("tester_profile_id"), "tester_profile_id"),
                "rs": _uuid(_req(d, "reference_standard_id"), "reference_standard_id"),
                "buffers": _json(d.get("buffers")),
                "passed": bool(_req(d, "passed")),
                "at": _ts(_req(d, "performed_at_device"), "performed_at_device"),
                **o,
            },
        )

    def _clock_flags(self, at: datetime) -> list[str]:
        if at > self.now + FUTURE_SLACK:
            return ["device_time_in_future"]
        if at < self.now - TOO_OLD:
            return ["device_time_too_old"]
        return []

    async def test_session_insert(self, c: Change) -> Outcome:
        d, o = c.data, self._origin(c.data)
        if o["ck"] is None or o["cs"] is None:
            raise Rejected("missing:collector")
        await self._refuse_archived("water_source", _uuid(_req(d, "source_id"), "source_id"))
        at = _ts(_req(d, "tested_at_device"), "tested_at_device")
        assert at is not None  # noqa: S101 - _req guarantees it
        return await self._insert(
            c,
            "INSERT INTO test_session (id, source_id, installation_id, collector_key, "  # noqa: S608 - constant SQL
            "collector_snapshot, calibration_id, tester_profile_id, reference_standard_id, "
            "calibrated, location, location_accuracy_m, distance_from_source_m, "
            "distance_override_reason, notes, tested_at_device, clock_flags, "
            "no_photo_reason, server_seq) "
            "VALUES (:id, :src, :inst, :ck, CAST(:cs AS jsonb), :cal, :tp, :rs, :calibrated, "
            f"{_POINT}, :acc, :dist, :why, :notes, :at, :flags, :nophoto, 0) "
            "ON CONFLICT (id) DO NOTHING RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "src": _uuid(_req(d, "source_id"), "source_id"),
                "cal": _uuid(d.get("calibration_id"), "calibration_id"),
                "tp": _uuid(d.get("tester_profile_id"), "tester_profile_id"),
                "rs": _uuid(_req(d, "reference_standard_id"), "reference_standard_id"),
                "calibrated": bool(d.get("calibrated", False)),
                "lat": d.get("lat"),
                "lon": d.get("lon"),
                "acc": d.get("location_accuracy_m"),
                "dist": d.get("distance_from_source_m"),
                "why": d.get("distance_override_reason"),
                "notes": d.get("notes"),
                "nophoto": d.get("no_photo_reason"),
                "at": at,
                "flags": self._clock_flags(at),
                **o,
            },
        )

    async def test_result_insert(self, c: Change) -> Outcome:
        d = c.data
        rid = _uuid(c.id, "id")
        session = _uuid(_req(d, "session_id"), "session_id")
        await self._refuse_archived("test_session", session)
        amends = _uuid(d.get("amendment_of"), "amendment_of")
        # A correction records who made it; only the person who made the
        # test may correct it (ADR-018).
        o = self._origin(d) if amends is not None else {"inst": None, "ck": None, "cs": None}
        if amends is not None and self.p.kind == "installation":
            owner = (
                await self.conn.execute(
                    text("SELECT collector_key FROM test_session WHERE id = :s"), {"s": session}
                )
            ).scalar_one_or_none()
            if owner is not None and o["ck"] is not None and owner != o["ck"]:
                raise Rejected("not_creator")
        out = await self._insert(
            c,
            "INSERT INTO test_result (id, session_id, overall, standard_id, computed_by, "
            "retest_of, amendment_of, amendment_reason, flags, limitation_code, "
            "created_at_device, installation_id, collector_key, collector_snapshot, "
            "server_seq) VALUES (:id, :session, :overall, :std, 'device', "
            ":retest, :amends, :why, :flags, :limitation, :at, :inst, :ck, "
            "CAST(:cs AS jsonb), 0) ON CONFLICT (id) DO NOTHING RETURNING 1",
            {
                "id": rid,
                "session": session,
                "inst": o["inst"],
                "ck": o["ck"],
                "cs": o["cs"],
                "overall": _req(d, "overall"),
                "std": _uuid(_req(d, "standard_id"), "standard_id"),
                "retest": _uuid(d.get("retest_of"), "retest_of"),
                "amends": amends,
                "why": d.get("amendment_reason"),
                "flags": _list(d.get("flags")),
                "limitation": d.get("limitation_code"),
                "at": _ts(_req(d, "created_at_device"), "created_at_device"),
            },
        )
        if out.status == "applied" and rid is not None:
            self.classify.add(rid)
        return out

    async def reading_insert(self, c: Change) -> Outcome:
        d = c.data
        result_id = _uuid(_req(d, "result_id"), "result_id")
        await self._refuse_archived("test_session", _uuid(d.get("session_id"), "session_id"))
        out = await self._insert(
            c,
            "INSERT INTO reading (id, session_id, result_id, parameter_code, value, detected, "
            "acceptable, value_text, unit, result, is_derived, source_device, server_seq) "
            "VALUES (:id, :session, :result, :param, :value, :detected, :acceptable, :vt, "
            ":unit, :res, :derived, :device, 0) ON CONFLICT (id) DO NOTHING RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "session": _uuid(_req(d, "session_id"), "session_id"),
                "result": result_id,
                "param": _req(d, "parameter_code"),
                "value": _num(d.get("value"), "value"),
                "detected": d.get("detected"),
                "acceptable": d.get("acceptable"),
                "vt": d.get("value_text"),
                "unit": d.get("unit"),
                "res": _req(d, "result"),
                "derived": bool(d.get("is_derived", False)),
                "device": d.get("source_device"),
            },
        )
        # Readings may arrive in a later batch than their result: classify
        # again once they are in.
        if out.status == "applied" and result_id is not None:
            self.classify.add(result_id)
        return out

    async def alert_insert(self, c: Change) -> Outcome:
        d, o = c.data, self._origin(c.data)
        await self._refuse_archived("water_source", _uuid(_req(d, "source_id"), "source_id"))
        # The same result and rule cannot raise two alerts (ADR-005).
        out = await self._insert(
            c,
            "INSERT INTO alert (id, source_id, trigger_result_id, trigger_rule, severity, "
            "status, opened_at, linked_alert_id, installation_id, collector_key, "
            "collector_snapshot, server_seq) VALUES (:id, :src, :result, :rule, :sev, 'open', "
            ":opened, :linked, :inst, :ck, CAST(:cs AS jsonb), 0) "
            "ON CONFLICT DO NOTHING RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "src": _uuid(_req(d, "source_id"), "source_id"),
                "result": _uuid(d.get("trigger_result_id"), "trigger_result_id"),
                "rule": _req(d, "trigger_rule"),
                "sev": d.get("severity") or "high",
                "opened": _ts(_req(d, "opened_at"), "opened_at"),
                "linked": _uuid(d.get("linked_alert_id"), "linked_alert_id"),
                **o,
            },
        )
        if out.status == "applied":
            await notify_or_reconcile(self.conn, UUID(c.id))
        return out

    async def alert_event_insert(self, c: Change) -> Outcome:
        d, o = c.data, self._origin(c.data)
        alert_id = _uuid(_req(d, "alert_id"), "alert_id")
        await self._refuse_archived("alert", alert_id)
        event_type = str(_req(d, "event_type"))
        out = await self._insert(
            c,
            "INSERT INTO alert_event (id, alert_id, actor_id, installation_id, collector_key, "
            "collector_snapshot, event_type, note, occurred_at_device, server_seq) VALUES "
            "(:id, :alert, :by, :inst, :ck, CAST(:cs AS jsonb), :type, :note, :at, 0) "
            "ON CONFLICT (id) DO NOTHING RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "alert": alert_id,
                "type": event_type,
                "note": d.get("note"),
                "at": _ts(d.get("occurred_at_device"), "occurred_at_device"),
                **o,
            },
        )
        if out.status != "applied" or alert_id is None:
            return out
        return await self._transition(c, alert_id, event_type)

    async def _transition(self, c: Change, alert_id: UUID, event_type: str) -> Outcome:
        """The server's alert state machine is authoritative (SPEC §8.4)."""
        if event_type not in STATUS_EVENTS and event_type != "reopened":
            return Outcome(c.id, c.entity, "applied")
        cur = (
            (
                await self.conn.execute(
                    text("SELECT status, version FROM alert WHERE id = :id FOR UPDATE"),
                    {"id": alert_id},
                )
            )
            .mappings()
            .first()
        )
        if cur is None:
            raise Rejected("not_found")
        status = cur["status"]
        if event_type == "reopened":
            if status not in ("closed", "false_alarm"):
                return Outcome(c.id, c.entity, "applied", server_version=cur["version"])
            # Reopening a closed alert offline opens a new, linked alert.
            new_id = uuid4()
            await self.conn.execute(
                text(
                    "INSERT INTO alert (id, source_id, trigger_rule, severity, status, opened_at, "
                    "linked_alert_id, installation_id, collector_key, collector_snapshot, "
                    "server_seq) SELECT :new, source_id, trigger_rule, severity, 'open', now(), "
                    "id, installation_id, collector_key, collector_snapshot, 0 FROM alert "
                    "WHERE id = :id"
                ),
                {"new": new_id, "id": alert_id},
            )
            return Outcome(c.id, c.entity, "applied", reason=f"new_alert:{new_id}")
        if event_type not in TRANSITIONS[status]:
            return Outcome(
                c.id,
                c.entity,
                "conflict",
                server_version=cur["version"],
                reason=f"invalid_transition:{status}->{event_type}",
            )
        version = (
            await self.conn.execute(
                text(
                    "UPDATE alert SET status = :s, version = version + 1, "
                    "acknowledged_at = CASE WHEN :s = 'acknowledged' THEN now() "
                    "ELSE acknowledged_at END, "
                    "closed_at = CASE WHEN :s IN ('closed','false_alarm') THEN now() "
                    "ELSE closed_at END WHERE id = :id RETURNING version"
                ),
                {"s": event_type, "id": alert_id},
            )
        ).scalar_one()
        return Outcome(c.id, c.entity, "applied", server_version=version)

    async def sanitary_inspection_insert(self, c: Change) -> Outcome:
        d, o = c.data, self._origin(c.data)
        await self._refuse_archived("water_source", _uuid(_req(d, "source_id"), "source_id"))
        return await self._insert(
            c,
            "INSERT INTO sanitary_inspection (id, source_id, answers, inspected_at_device, "
            "installation_id, collector_key, collector_snapshot, server_seq) VALUES "
            "(:id, :src, CAST(:answers AS jsonb), :at, :inst, :ck, CAST(:cs AS jsonb), 0) "
            "ON CONFLICT (id) DO NOTHING RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "src": _uuid(_req(d, "source_id"), "source_id"),
                "answers": _json(_req(d, "answers")),
                "at": _ts(_req(d, "inspected_at_device"), "inspected_at_device"),
                **o,
            },
        )

    async def attachment_insert(self, c: Change) -> Outcome:
        """Photo metadata; the bytes follow by chunked upload (ADR-012)."""
        d = c.data
        mime = str(_req(d, "mime"))
        if mime not in ATTACHMENT_MIME:
            raise Rejected("unsupported_type")
        owner_type = str(_req(d, "owner_type"))
        if owner_type not in ("water_source", "test_session"):
            raise Rejected("invalid:owner_type")
        aid = _uuid(c.id, "id")
        lat, lon = _num(d.get("taken_lat"), "taken_lat"), _num(d.get("taken_lon"), "taken_lon")
        if (lat is None) != (lon is None) or (
            lat is not None and lon is not None and not (-90 <= lat <= 90 and -180 <= lon <= 180)
        ):
            raise Rejected("invalid:taken_lat")

        def num(field: str) -> float | None:
            v = _num(d.get(field), field)
            return None if v is None else float(v)

        return await self._insert(
            c,
            "INSERT INTO attachment (id, owner_type, owner_id, object_key, sha256, bytes, mime, "
            "installation_id, created_by, collector_key, taken_lat, taken_lon, "
            "taken_accuracy_m, taken_altitude_m, taken_speed_mps, taken_heading_deg, taken_at, "
            "server_seq) VALUES (:id, :ot, :oid, :key, :sha, :bytes, :mime, :inst, :by, :ck, "
            ":tlat, :tlon, :tacc, :talt, :tspd, :thead, :tat, 0) "
            "ON CONFLICT (id) DO NOTHING RETURNING 1",
            {
                "tlat": num("taken_lat"),
                "tlon": num("taken_lon"),
                "tacc": num("taken_accuracy_m"),
                "talt": num("taken_altitude_m"),
                "tspd": num("taken_speed_mps"),
                "thead": num("taken_heading_deg"),
                "tat": _ts(d.get("taken_at"), "taken_at"),
                "id": aid,
                "ot": owner_type,
                "oid": _uuid(_req(d, "owner_id"), "owner_id"),
                "key": f"attachments/{aid}.jpg",
                "sha": str(_req(d, "sha256")).lower(),
                "bytes": int(_req(d, "bytes")),
                "mime": mime,
                "inst": self.p.installation_id,
                "by": self.p.user_id,
                "ck": self._origin(d)["ck"],
            },
        )

    async def attachment_update(self, c: Change) -> Outcome:
        """Removes a picture (ADR-022): only the collector who added it. The
        picture is kept on the server, marked; devices drop their copy."""
        if not c.data.get("removed"):
            raise Rejected("unsupported_change")
        o = self._origin(c.data)
        aid = _uuid(c.id, "id")
        done = (
            await self.conn.execute(
                text(
                    "UPDATE attachment SET removed_at = now(), removed_by_installation = :inst "
                    "WHERE id = :id AND removed_at IS NULL "
                    "AND collector_key IS NOT DISTINCT FROM :ck RETURNING 1"
                ),
                {"id": aid, "inst": o["inst"], "ck": o["ck"]},
            )
        ).first()
        if done:
            return Outcome(c.id, c.entity, "applied")
        row = (
            await self.conn.execute(
                text("SELECT removed_at FROM attachment WHERE id = :id"), {"id": aid}
            )
        ).first()
        if row is None:
            raise Rejected("not_found")
        if row.removed_at is not None:
            return Outcome(c.id, c.entity, "duplicate")
        raise Rejected("not_creator")

    async def collector_mark_upsert(self, c: Change) -> Outcome:
        """Known or flagged collector (P9): the latest stakeholder decision
        wins; each change is versioned and audited."""
        d = c.data
        key = _uuid(c.id, "collector_key")
        status = str(_req(d, "status"))
        if status not in ("known", "flagged"):
            raise Rejected("invalid:status")
        version = (
            await self.conn.execute(
                text(
                    "INSERT INTO collector_mark (collector_key, status, note, marked_by, "
                    "server_seq) VALUES (:k, :s, :n, :by, 0) "
                    "ON CONFLICT (collector_key) DO UPDATE SET "
                    "status = EXCLUDED.status, note = EXCLUDED.note, "
                    "marked_by = EXCLUDED.marked_by, marked_at = now(), "
                    "version = collector_mark.version + 1 RETURNING version"
                ),
                {"k": key, "s": status, "n": d.get("note"), "by": self.p.user_id},
            )
        ).scalar_one()
        await self.conn.execute(
            text(
                "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id, after) "
                "VALUES (:by, 'console', 'collector.marked', 'collector', :k, CAST(:a AS jsonb))"
            ),
            {"by": self.p.user_id, "k": key, "a": json.dumps({"status": status})},
        )
        return Outcome(c.id, c.entity, "applied", server_version=version)

    async def submission_flag_insert(self, c: Change) -> Outcome:
        d = c.data
        return await self._insert(
            c,
            "INSERT INTO submission_flag (id, result_id, reason, flagged_by, created_at_device, "
            "server_seq) VALUES (:id, :r, :why, :by, :at, 0) ON CONFLICT (id) DO NOTHING "
            "RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "r": _uuid(_req(d, "result_id"), "result_id"),
                "why": str(_req(d, "reason"))[:500],
                "by": self.p.user_id,
                "at": _ts(d.get("created_at_device"), "created_at_device"),
            },
        )

    async def message_insert(self, c: Change) -> Outcome:
        """A message in a thread on a test, source, collector or area
        (ADR-022), from a collector or a Console user."""
        d, o = c.data, self._origin(c.data)
        kind = str(_req(d, "subject_type"))
        if kind not in _THREAD_AREA:
            raise Rejected("unknown_subject")
        subject = _uuid(_req(d, "subject_id"), "subject_id")
        body = str(_req(d, "body")).strip()
        if not body or len(body) > 2000:
            raise Rejected("invalid_body")
        area = (
            await self.conn.execute(text(_THREAD_AREA[kind]), {"s": subject})
        ).scalar_one_or_none()
        if area is None and kind == "collector" and self.p.kind == "installation":
            # A collector writing about themselves before any record: the
            # device's own area.
            area = (
                await self.conn.execute(
                    text("SELECT admin_unit_id FROM installation WHERE id = :i"),
                    {"i": self.p.installation_id},
                )
            ).scalar_one_or_none()
        if area is None:
            raise Rejected("not_found")
        snapshot = o["cs"]
        name = None
        if snapshot:
            name = (json.loads(snapshot) or {}).get("full_name")
        elif self.p.user_id is not None:
            name = (
                await self.conn.execute(
                    text("SELECT full_name FROM app_user WHERE id = :u"), {"u": self.p.user_id}
                )
            ).scalar_one_or_none()
        return await self._insert(
            c,
            "INSERT INTO message (id, subject_type, subject_id, body, village_id, "
            "author_user_id, installation_id, collector_key, collector_snapshot, author_name, "
            "written_at_device, server_seq) VALUES (:id, :kind, :subject, :body, :area, :by, "
            ":inst, :ck, CAST(:cs AS jsonb), :name, :at, 0) ON CONFLICT (id) DO NOTHING "
            "RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "kind": kind,
                "subject": subject,
                "body": body,
                "area": area,
                "name": name,
                "at": _ts(d.get("written_at_device"), "written_at_device"),
                **o,
            },
        )

    async def parameter_definition_insert(self, c: Change) -> Outcome:
        """A custom parameter (`custom:<uuid>`), pending IT admin review."""
        d, o = c.data, self._origin(c.data)
        if not c.id.startswith("custom:"):
            raise Rejected("not_custom")
        return await self._insert(
            c,
            "INSERT INTO parameter_definition (code, name, category_code, default_unit, "
            "value_type, display_order, plausible_min, plausible_max, is_custom, created_by, "
            "installation_id, collector_key, collector_snapshot, scope_admin_unit_id, "
            "review_status, server_seq) VALUES (:code, :name, :cat, :unit, :vt, :order, "
            ":min, :max, true, :by, :inst, :ck, CAST(:cs AS jsonb), :scope, 'pending', 0) "
            "ON CONFLICT (code) DO NOTHING RETURNING 1",
            {
                "code": c.id,
                "name": _req(d, "name"),
                "cat": d.get("category") or _req(d, "category_code"),
                "unit": d.get("default_unit") or "",
                "vt": _req(d, "value_type"),
                "order": d.get("display_order") or 0,
                "min": _num(d.get("plausible_min"), "plausible_min"),
                "max": _num(d.get("plausible_max"), "plausible_max"),
                "scope": _uuid(d.get("scope_admin_unit_id"), "scope_admin_unit_id"),
                **o,
            },
        )

    async def reference_standard_insert(self, c: Change) -> Outcome:
        """A custom limit set (D-MN). Only a stakeholder may make one (O2,
        the lead, 2026-10-12): from the Console, or from Collect after the
        stakeholder signs in on the phone. Who made it and their comment
        (the reason) are recorded and audited; readings already taken keep
        the limit set they were judged under."""
        if self.p.kind != "user" or self.p.role != "stakeholder":
            raise Rejected("stakeholder_required")
        d, o = c.data, self._origin(c.data)
        if len(str(d.get("custom_reason") or "").strip()) < 5:
            raise Rejected("invalid:custom_reason")
        doc = {
            k: v
            for k, v in d.items()
            if k
            not in ("installation_id", "collector_key", "collector_snapshot", "created_by", "via")
        }
        try:
            profile = ReferenceProfile.from_json(doc)
        except (KeyError, ValueError, TypeError) as e:
            raise Rejected("invalid:profile") from e
        if not profile.is_custom:
            raise Rejected("not_custom")
        out = await self._insert(
            c,
            "INSERT INTO reference_standard (id, code, title, version, based_on_id, is_custom, "
            "custom_reason, is_provisional, created_by, installation_id, collector_key, "
            "collector_snapshot, document, server_seq) VALUES (:id, :code, :title, :version, "
            ":based, true, :why, :prov, :by, :inst, :ck, CAST(:cs AS jsonb), "
            "CAST(:doc AS jsonb), 0) ON CONFLICT (id) DO NOTHING RETURNING 1",
            {
                "id": _uuid(c.id, "id"),
                "code": profile.code,
                "title": profile.title,
                "version": profile.version,
                "based": _uuid(doc.get("based_on_id"), "based_on_id"),
                "why": doc.get("custom_reason"),
                "prov": profile.is_provisional,
                "doc": json.dumps(doc),
                **o,
            },
        )
        if out.status == "applied":
            for limit in doc.get("limits", []):
                await self.conn.execute(
                    text(
                        "INSERT INTO parameter_limit (standard_id, parameter_code, unit, "
                        "min_value, max_value, must_be_absent, must_be_acceptable, note, source) "
                        "VALUES (:s, :p, :unit, :min, :max, :absent, :acceptable, :note, :source)"
                    ),
                    {
                        "s": _uuid(c.id, "id"),
                        "p": limit["parameter_code"],
                        "unit": limit.get("unit") or "",
                        "min": _num(limit.get("min"), "min"),
                        "max": _num(limit.get("max"), "max"),
                        "absent": limit.get("must_be_absent", False),
                        "acceptable": limit.get("must_be_acceptable", False),
                        "note": limit.get("note"),
                        "source": limit.get("source"),
                    },
                )
            await self.conn.execute(
                text(
                    "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id, after) "
                    "VALUES (:by, :platform, 'reference_profile.created', "
                    "'reference_standard', :id, CAST(:after AS jsonb))"
                ),
                {
                    "by": self.p.user_id,
                    "platform": "collect" if d.get("via") == "collect" else "console",
                    "id": _uuid(c.id, "id"),
                    "after": json.dumps(
                        {
                            "code": profile.code,
                            "based_on_id": doc.get("based_on_id"),
                            "reason": doc.get("custom_reason"),
                            "limits": doc.get("limits", []),
                        }
                    ),
                },
            )
        return out


TRANSITIONS: dict[str, set[str]] = {
    "open": {"acknowledged", "false_alarm"},
    "acknowledged": {"action_in_progress", "closed", "false_alarm"},
    "action_in_progress": {"closed", "false_alarm"},
    "closed": set(),
    "false_alarm": set(),
}
# Event types that ask for a status change; others (e.g. `action_taken`)
# are just recorded.
STATUS_EVENTS = {"acknowledged", "action_in_progress", "closed", "false_alarm"}

_Handler = Callable[[PushService, Change], Awaitable[Outcome]]
_HANDLERS: dict[tuple[str, str], _Handler] = {
    ("admin_unit", "insert"): PushService.admin_unit_insert,
    ("place_name", "insert"): PushService.place_name_insert,
    ("water_source", "insert"): PushService.water_source_insert,
    ("water_source", "update"): PushService.water_source_update,
    ("calibration", "insert"): PushService.calibration_insert,
    ("test_session", "insert"): PushService.test_session_insert,
    ("test_result", "insert"): PushService.test_result_insert,
    ("reading", "insert"): PushService.reading_insert,
    ("alert", "insert"): PushService.alert_insert,
    ("alert_event", "insert"): PushService.alert_event_insert,
    ("sanitary_inspection", "insert"): PushService.sanitary_inspection_insert,
    ("message", "insert"): PushService.message_insert,
    ("parameter_definition", "insert"): PushService.parameter_definition_insert,
    ("reference_standard", "insert"): PushService.reference_standard_insert,
    ("attachment", "insert"): PushService.attachment_insert,
    ("attachment", "update"): PushService.attachment_update,
    ("collector_mark", "insert"): PushService.collector_mark_upsert,
    ("collector_mark", "update"): PushService.collector_mark_upsert,
    ("submission_flag", "insert"): PushService.submission_flag_insert,
}


def _db_reason(e: DBAPIError) -> str:
    """A safe, specific reason from a database error (no SQL echoed)."""
    code = getattr(getattr(e, "orig", None), "sqlstate", None) or getattr(
        getattr(getattr(e, "orig", None), "__cause__", None), "sqlstate", None
    )
    message = str(getattr(e, "orig", e)).lower()
    if code == "23503" or "foreign key" in message:
        return "missing_parent"
    if code == "23514" or "check constraint" in message:
        return "invalid_value"
    if code == "23505" or "unique" in message:
        return "duplicate_key"
    if code == "42501" or "row-level security" in message:
        return "out_of_scope"
    if code == "23001" or "insert-only" in message:
        return "insert_only"
    if code in ("22P02", "22003", "22007", "22008") or "invalid input" in message:
        return "invalid_value"
    return "server_error"
