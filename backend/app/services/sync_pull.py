# SQL here is assembled only from the constant templates below; values are bound.
# ruff: noqa: S608
"""Sync pull: scoped change feeds (SPEC §8.2, ADR-011).

Streams:

- ``reference``: catalogue, tester profiles, reference profiles, response
  cards, configuration, admin units.
- ``area:<id>``: sources and their results, alerts and inspections in the
  area. Row-level security still limits rows to the caller's scope.
- ``scope``: everything in the caller's scope (Console, which may have
  several areas).

The cursor is opaque to clients: ``<xid>.<seq>`` of the last row sent. Rows
come in (server_xid, server_seq) order and only from transactions older than
the oldest one still running, so a later commit can never land behind a
cursor a client already holds.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

MAX_LIMIT = 1000

# Each query returns client-shaped columns plus _xid and _seq.
# `{area}` is replaced by a filter on the row's village, or by `true`.
_SRC = "(SELECT village_id FROM water_source s WHERE s.id = {col})"
_SES = "(SELECT s.village_id FROM test_session t JOIN water_source s ON s.id = t.source_id WHERE t.id = {col})"  # noqa: E501

REFERENCE: dict[str, str] = {
    "admin_unit": (
        "SELECT id, level, name, code, parent_id, pcode, center_lat, center_lon, "
        "default_standard_id, {cols} "
        "FROM admin_unit x"
    ),
    "parameter_category": "SELECT code, name, display_order, {cols} FROM parameter_category x",
    "parameter_definition": (
        "SELECT code, name, category_code, default_unit, value_type, is_core, display_order, "
        "plausible_min::text AS plausible_min, plausible_max::text AS plausible_max, is_custom, "
        "scope_admin_unit_id, review_status, installation_id, collector_key, "
        "collector_snapshot, {cols} FROM parameter_definition x WHERE merged_into IS NULL"
    ),
    "tester_profile": (
        "SELECT id, name, manufacturer, model, tds_factor::text AS tds_factor, "
        "coalesce((SELECT json_agg(json_build_object('parameter_code', p.parameter_code, "
        "'unit', p.unit) ORDER BY p.parameter_code) FROM tester_profile_parameter p "
        "WHERE p.tester_profile_id = x.id), '[]') AS parameters, {cols} FROM tester_profile x"
    ),
    "reference_standard": (
        "SELECT id, code, title, version, based_on_id, is_custom, custom_reason, "
        "is_provisional, published_at, document, installation_id, collector_key, "
        "collector_snapshot, {cols} FROM reference_standard x"
    ),
    "response_card": (
        "SELECT id, trigger_rule, audience, version, content, {cols} FROM response_card x"
    ),
    "config_document": (
        "SELECT key, document, version, {cols} FROM config_document x "
        "WHERE key IN ('rules', 'lists', 'notifications')"
    ),
}

AREA: dict[str, str] = {
    "water_source": (
        "SELECT id, village_id, code, name, source_type, "
        "ST_Y(location::geometry) AS lat, ST_X(location::geometry) AS lon, "
        "location_accuracy_m, households_served, functional_status, is_active, version, "
        "created_by, installation_id, collector_key, collector_snapshot, "
        "coalesce(created_at_device, created_at_server) AS created_at_device, "
        "coalesce(updated_at_device, updated_at_server) AS updated_at_device, {cols} "
        "FROM water_source x WHERE {area:x.village_id} AND NOT wc_archived('water_source', x.id)"
    ),
    "calibration": (
        "SELECT id, tester_serial, tester_profile_id, reference_standard_id, buffers, passed, "
        "performed_at_device, installation_id, collector_key, collector_snapshot, {cols} "
        "FROM calibration x WHERE "
        "{area:(SELECT i.admin_unit_id FROM installation i WHERE i.id = x.installation_id)}"
    ),
    "test_session": (
        "SELECT id, source_id, calibration_id, tester_profile_id, reference_standard_id, "
        "calibrated, ST_Y(location::geometry) AS lat, ST_X(location::geometry) AS lon, "
        "location_accuracy_m, distance_from_source_m, distance_override_reason, notes, "
        "tested_at_device, clock_flags, installation_id, collector_key, collector_snapshot, "
        "{cols} FROM test_session x WHERE {area:" + _SRC.format(col="x.source_id") + "} "
        "AND NOT wc_archived('test_session', x.id)"
    ),
    "test_result": (
        "SELECT id, session_id, overall, standard_id, computed_by, retest_of, amendment_of, "
        "amendment_reason, flags, limitation_code, created_at_device, installation_id, "
        "collector_key, collector_snapshot, {cols} "
        "FROM test_result x WHERE {area:" + _SES.format(col="x.session_id") + "} "
        "AND NOT wc_archived('test_session', x.session_id)"
    ),
    "reading": (
        "SELECT id, session_id, result_id, parameter_code, value::text AS value, detected, "
        "acceptable, value_text, unit, result, is_derived, source_device, {cols} "
        "FROM reading x WHERE {area:" + _SES.format(col="x.session_id") + "} "
        "AND NOT wc_archived('test_session', x.session_id)"
    ),
    "classification": (
        "SELECT result_id, standard_id, computed_by, overall, reading_results, flags, "
        "limitation_code, computed_at, {cols} FROM classification x WHERE {area:"
        + _SES.format(col="(SELECT r.session_id FROM test_result r WHERE r.id = x.result_id)")
        + "} AND NOT wc_archived('test_session', "
        "(SELECT r.session_id FROM test_result r WHERE r.id = x.result_id))"
    ),
    "alert": (
        "SELECT id, source_id, trigger_result_id, trigger_rule, status, severity, opened_at, "
        "acknowledged_at, closed_at, linked_alert_id, version, installation_id, "
        "collector_key, collector_snapshot, {cols} FROM alert x WHERE {area:"
        + _SRC.format(col="x.source_id")
        + "} AND NOT wc_archived('alert', x.id)"
    ),
    "alert_event": (
        "SELECT id, alert_id, actor_id, event_type, note, "
        "coalesce(occurred_at_device, created_at_server) AS occurred_at_device, "
        "installation_id, collector_key, collector_snapshot, {cols} FROM alert_event x "
        "WHERE {area:"
        + _SRC.format(col="(SELECT a.source_id FROM alert a WHERE a.id = x.alert_id)")
        + "} AND NOT wc_archived('alert', x.alert_id)"
    ),
    "attachment": (
        "SELECT id, owner_type, owner_id, object_key, sha256, bytes, mime, upload_status, {cols} "
        "FROM attachment x WHERE {area:"
        + _SRC.format(
            col="CASE WHEN x.owner_type = 'water_source' THEN x.owner_id ELSE "
            "(SELECT t.source_id FROM test_session t WHERE t.id = x.owner_id) END"
        )
        + "} AND NOT wc_archived('water_source', x.owner_id) "
        "AND NOT wc_archived('test_session', x.owner_id)"
    ),
    # Staff only (RLS): phones never receive marks.
    "collector_mark": (
        "SELECT collector_key, status, note, marked_by, marked_at, version, {cols} "
        "FROM collector_mark x WHERE {area:"
        + "(SELECT w.village_id FROM test_session t JOIN water_source w ON w.id = t.source_id "
        "WHERE t.collector_key = x.collector_key ORDER BY t.tested_at_device DESC LIMIT 1)" + "}"
    ),
    "submission_flag": (
        "SELECT id, result_id, reason, flagged_by, "
        "coalesce(created_at_device, created_at_server) AS created_at_device, {cols} "
        "FROM submission_flag x WHERE {area:"
        + _SES.format(col="(SELECT r.session_id FROM test_result r WHERE r.id = x.result_id)")
        + "} AND NOT wc_archived('test_session', "
        "(SELECT r.session_id FROM test_result r WHERE r.id = x.result_id))"
    ),
    "sanitary_inspection": (
        "SELECT id, source_id, answers, inspected_at_device, installation_id, collector_key, "
        "collector_snapshot, {cols} FROM sanitary_inspection x WHERE {area:"
        + _SRC.format(col="x.source_id")
        + "} AND NOT wc_archived('water_source', x.source_id)"
    ),
    # Archive marks (ADR-018): devices remove archived records, and put them
    # back after a restore. Marks without an area (phones, collectors) reach
    # IT admins only (row-level security).
    "archive_mark": (
        "SELECT entity, record_id, archived, reason, archived_at, {cols} "
        "FROM archive_mark x WHERE {area:x.village_id}"
    ),
    # Who changed what, from what to what (ADR-018).
    "change_trail": (
        "SELECT id, entity, record_id, field, old_value::text AS old_value, "
        "new_value::text AS new_value, reason, actor_name, changed_at, {cols} "
        "FROM change_trail x WHERE {area:x.village_id}"
    ),
}

_KEY = {
    "parameter_definition": "code",
    "parameter_category": "code",
    "config_document": "key",
    "collector_mark": "collector_key",
}


class StreamError(ValueError):
    pass


@dataclass(frozen=True)
class Cursor:
    xid: int = 0
    seq: int = 0

    @classmethod
    def parse(cls, raw: str | None) -> Cursor:
        if not raw or raw == "0":
            return cls()
        try:
            xid, seq = raw.split(".")
            return cls(int(xid), int(seq))
        except ValueError as e:
            raise StreamError("invalid_cursor") from e

    def __str__(self) -> str:
        return f"{self.xid}.{self.seq}"


def _queries(stream: str) -> tuple[dict[str, str], UUID | None]:
    if stream == "reference":
        return REFERENCE, None
    if stream == "scope":
        return AREA, None
    if stream.startswith("area:"):
        try:
            return AREA, UUID(stream.removeprefix("area:"))
        except ValueError as e:
            raise StreamError("unknown_stream") from e
    raise StreamError("unknown_stream")


# json/jsonb columns, sent as JSON values rather than strings.
JSON_COLUMNS = {
    "collector_snapshot",
    "document",
    "content",
    "buffers",
    "answers",
    "reading_results",
    "parameters",
}


def _plain(column: str, v: Any) -> Any:
    if v is None:
        return None
    if column in JSON_COLUMNS and isinstance(v, str):
        return json.loads(v)
    if isinstance(v, UUID):
        return str(v)
    if isinstance(v, datetime):
        return v.isoformat()
    if isinstance(v, Decimal):
        return str(v)
    return v


async def pull(
    conn: AsyncConnection,
    stream: str,
    cursor: str | None,
    limit: int,
    *,
    installation_id: UUID | None = None,
) -> dict[str, Any]:
    """[installation_id]: a Collect phone gets collector details (name, phone)
    only for its own records; other phones' collectors stay private."""
    queries, area = _queries(stream)
    after = Cursor.parse(cursor)
    limit = max(1, min(limit, MAX_LIMIT))
    horizon = (
        await conn.execute(text("SELECT pg_snapshot_xmin(pg_current_snapshot())::text"))
    ).scalar_one()
    horizon = int(horizon)
    if area is not None:
        visible = (await conn.execute(text("SELECT wc_in_scope(:a)"), {"a": area})).scalar_one()
        if not visible:
            raise StreamError("out_of_scope")

    rows: list[tuple[int, int, str, dict[str, Any]]] = []
    cols = "x.server_xid AS _xid, x.server_seq AS _seq"
    for entity, template in queries.items():
        sql = template.replace("{cols}", cols)
        # Area filter: `{area:<village expression>}`.
        while "{area:" in sql:
            start = sql.index("{area:")
            depth, end = 0, start
            for end in range(start, len(sql)):
                if sql[end] == "{":
                    depth += 1
                elif sql[end] == "}":
                    depth -= 1
                    if depth == 0:
                        break
            expr = sql[start + len("{area:") : end]
            cond = f"wc_under({expr}, :area)" if area is not None else "true"
            sql = sql[:start] + cond + sql[end + 1 :]
        # Simple subquery: Postgres pushes the feed condition down onto the
        # (server_xid, server_seq) index.
        sql = (
            f"SELECT q.*, q._xid::text AS _xidt FROM ({sql}) q "
            "WHERE (q._xid, q._seq) > (CAST(:cx AS xid8), :cs) "
            "AND q._xid < CAST(:horizon AS xid8) ORDER BY q._xid, q._seq LIMIT :n"
        )
        result = await conn.execute(
            text(sql),
            {
                "cx": after.xid,
                "cs": after.seq,
                "horizon": horizon,
                "n": limit + 1,
                "area": area,
            },
        )
        for r in result.mappings():
            data = {k: _plain(k, v) for k, v in r.items() if not k.startswith("_")}
            if (
                installation_id is not None
                and "collector_snapshot" in data
                and data.get("installation_id") != str(installation_id)
            ):
                data["collector_snapshot"] = None
            rows.append((int(r["_xidt"]), r["_seq"], entity, data))

    rows.sort(key=lambda t: (t[0], t[1]))
    page, more = rows[:limit], len(rows) > limit
    changes = []
    for _xid, seq, entity, data in page:
        key = _KEY.get(entity)
        if entity == "archive_mark":
            ident = f"{data['entity']}/{data['record_id']}"
        else:
            ident = (
                data[key] if key else data.get("id") or f"{data['result_id']}/{data['standard_id']}"
            )
        op = (
            "tombstone" if entity == "water_source" and data.get("is_active") is False else "upsert"
        )
        changes.append(
            {"entity": entity, "op": op, "id": str(ident), "server_seq": seq, "data": data}
        )
    last = Cursor(page[-1][0], page[-1][1]) if page else after
    return {"changes": changes, "next_cursor": str(last), "has_more": more}
