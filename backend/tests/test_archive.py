"""Archive and restore, edit trails and who corrects (the lead, 2026-10-22;
ADR-018)."""

from __future__ import annotations

import copy
import json
import uuid
from typing import Any

from httpx2 import AsyncClient
from sqlalchemy import text

from app.db.database import Database, Principal
from tests.helpers import make_area, signed_in
from tests.test_sync import PROFILE, Phone, client, phone, seeded, visit

__all__ = ["client", "seeded"]


async def _all(p: Phone) -> dict[str, set[str]]:
    """Every record id the phone would receive from a fresh pull, by entity."""
    seen: dict[str, set[str]] = {}
    cursor = None
    while True:
        page = (await p.pull(f"area:{p.village}", cursor, limit=1000)).json()
        for c in page["changes"]:
            seen.setdefault(c["entity"], set()).add(c["id"])
        cursor = page["next_cursor"]
        if not page["has_more"]:
            return seen


def _ids(changes: list[dict[str, Any]], entity: str) -> list[str]:
    return [c["id"] for c in changes if c["entity"] == entity]


def _as(other_collector: str, changes: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """The same visit sent by another person on the phone."""
    out = copy.deepcopy(changes)
    for c in out:
        if "collector_key" in c["data"]:
            c["data"]["collector_key"] = other_collector
            c["data"]["collector_snapshot"] = json.dumps({"full_name": "Second Collector"})
    return out


async def test_archiving_a_test_hides_it_and_its_alert_until_restored(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    v = visit(p)
    assert {r["status"] for r in (await p.push(v))["results"]} == {"applied"}
    session = _ids(v, "test_session")[0]
    alert = _ids(v, "alert")[0]
    admin = await signed_in(client, owner_db, role="it_admin")

    made = await client.post(
        "/v1/admin/archive",
        json={"entity": "test_session", "record_id": session, "reason": "typed by mistake"},
        headers=admin,
    )
    assert made.status_code == 201, made.text
    counts = made.json()["counts"]
    # The phone's alert, and any the server raised for the same result.
    assert counts["test_session"] == 1
    assert counts["alert"] >= 1
    again = await client.post(
        "/v1/admin/archive",
        json={"entity": "test_session", "record_id": session, "reason": "typed by mistake"},
        headers=admin,
    )
    assert again.status_code == 409

    seen = await _all(p)
    assert session not in seen.get("test_session", set())
    assert alert not in seen.get("alert", set())
    assert not seen.get("reading", set()) & set(_ids(v, "reading"))
    # The phone also learns about the archive, so it removes its copies.
    assert f"test_session/{session}" in seen["archive_mark"]
    # The source itself stays.
    assert _ids(v, "water_source")[0] in seen["water_source"]

    listed = (await client.get("/v1/admin/archive", headers=admin)).json()
    item = next(i for i in listed if i["record_id"] == session)
    assert item["reason"] == "typed by mistake"
    assert item["label"].startswith("ENT-001")

    restored = await client.post(f"/v1/admin/archive/{item['batch_id']}/restore", headers=admin)
    assert restored.json() == counts
    seen = await _all(p)
    assert session in seen["test_session"]
    assert alert in seen["alert"]

    # Only IT admins archive.
    stakeholder = await signed_in(client, owner_db)
    refused = await client.post(
        "/v1/admin/archive",
        json={"entity": "test_session", "record_id": session, "reason": "not mine to do"},
        headers=stakeholder,
    )
    assert refused.status_code == 403


async def test_archiving_a_collector_keeps_sources_others_tested(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    mine = visit(p)
    assert {r["status"] for r in (await p.push(mine))["results"]} == {"applied"}
    shared = _ids(mine, "water_source")[0]
    # A second visit by the same collector: a source only they used.
    alone = visit(p)
    await p.push(alone)
    # Another person tests the first source.
    other_key = str(uuid.uuid4())
    theirs = [c for c in _as(other_key, visit(p)) if c["entity"] != "water_source"]
    for c in theirs:
        if "source_id" in c["data"]:
            c["data"]["source_id"] = shared
    assert {r["status"] for r in (await p.push(theirs))["results"]} == {"applied"}

    admin = await signed_in(client, owner_db, role="it_admin")
    made = await client.post(
        "/v1/admin/archive",
        json={"entity": "collector", "record_id": p.collector, "reason": "test person"},
        headers=admin,
    )
    assert made.status_code == 201, made.text
    counts = made.json()["counts"]
    assert counts["collector"] == 1
    assert counts["test_session"] == 2
    assert counts["water_source"] == 1  # only the source nobody else tested

    seen = await _all(p)
    assert shared in seen["water_source"]
    assert _ids(alone, "water_source")[0] not in seen.get("water_source", set())
    assert _ids(theirs, "test_session")[0] in seen["test_session"]
    assert _ids(mine, "test_session")[0] not in seen.get("test_session", set())

    # Nothing new can be added to an archived source.
    late = [c for c in visit(p) if c["entity"] == "test_session"]
    late[0]["data"]["source_id"] = _ids(alone, "water_source")[0]
    out = (await p.push(late))["results"][0]
    assert (out["status"], out["reason"]) == ("rejected", "archived")


async def test_archiving_a_phone_revokes_it_and_takes_its_records(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    v = visit(p)
    await p.push(v)
    admin = await signed_in(client, owner_db, role="it_admin")
    made = await client.post(
        "/v1/admin/archive",
        json={"entity": "installation", "record_id": p.id, "reason": "test phone"},
        headers=admin,
    )
    assert made.status_code == 201, made.text
    assert made.json()["counts"]["installation"] == 1
    phones = (await client.get("/v1/admin/installations", headers=admin)).json()
    me = next(x for x in phones if x["id"] == p.id)
    assert me["archived"] is True
    assert me["revoked_at"] is not None


async def test_edits_leave_a_trail_and_only_the_tester_corrects(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    v = visit(p)
    await p.push(v)
    source = _ids(v, "water_source")[0]

    # A source edit: old → new, by whom.
    edit = {
        "entity": "water_source",
        "op": "update",
        "id": source,
        "base_version": 1,
        "data": {"name": "Upper borehole", "households_served": 40, **p.origin()},
    }
    assert (await p.push([edit]))["results"][0]["status"] == "applied"
    # A newer profile of the same collector: the changed fields are kept.
    profile = {
        **p.origin(),
        "collector_snapshot": json.dumps(
            {"profile_version": 2, "full_name": "Example Collector Two"}
        ),
    }
    insp = next(c for c in visit(p) if c["entity"] == "sanitary_inspection")
    insp["data"].update(profile, source_id=source)
    await p.push([insp])
    async with owner_db.transaction(Principal.system()) as conn:
        rows = (
            await conn.execute(
                text(
                    "SELECT entity, field, old_value, new_value, actor_name FROM change_trail "
                    "WHERE record_id IN (:s, :k) ORDER BY entity, field"
                ),
                {"s": source, "k": p.collector},
            )
        ).all()
    trail = {(r.entity, r.field): (r.old_value, r.new_value, r.actor_name) for r in rows}
    assert trail[("water_source", "name")] == (
        "Main borehole",
        "Upper borehole",
        "Example Collector",
    )
    assert trail[("collector", "full_name")][1] == "Example Collector Two"

    # The phone receives the trail for its area.
    assert (await _all(p)).get("change_trail")

    # A correction by someone else is refused; by the tester, it is kept
    # with their name.
    result = _ids(v, "test_result")[0]
    session = _ids(v, "test_session")[0]

    def amendment(origin: dict[str, Any]) -> dict[str, Any]:
        rid = str(uuid.uuid4())
        return {
            "entity": "test_result",
            "op": "insert",
            "id": rid,
            "data": {
                "id": rid,
                "session_id": session,
                "overall": "safe",
                "standard_id": PROFILE,
                "amendment_of": result,
                "amendment_reason": "typing error",
                "flags": "[]",
                "created_at_device": "2026-10-22T08:00:00+00:00",
                **origin,
            },
        }

    stranger = {**p.origin(), "collector_key": str(uuid.uuid4())}
    out = (await p.push([amendment(stranger)]))["results"][0]
    assert out["reason"] == "not_creator"
    fix = amendment(p.origin())
    assert (await p.push([fix]))["results"][0]["status"] == "applied"
    async with owner_db.transaction(Principal.system()) as conn:
        by = (
            await conn.execute(
                text("SELECT collector_key::text FROM test_result WHERE id = :id"),
                {"id": fix["id"]},
            )
        ).scalar_one()
    assert by == p.collector


async def test_phones_get_a_name_with_a_trail(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    admin = await signed_in(client, owner_db, role="it_admin")
    r = await client.patch(
        f"/v1/admin/installations/{p.id}", json={"label": "Nalongo's phone"}, headers=admin
    )
    assert r.status_code == 204
    phones = (await client.get("/v1/admin/installations", headers=admin)).json()
    assert next(x for x in phones if x["id"] == p.id)["label"] == "Nalongo's phone"
    async with owner_db.transaction(Principal.system()) as conn:
        n = (
            await conn.execute(
                text("SELECT count(*) FROM change_trail WHERE record_id = :id"), {"id": p.id}
            )
        ).scalar_one()
    assert n == 1
