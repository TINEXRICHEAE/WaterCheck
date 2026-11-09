"""Unfinished forms kept on the server, and records corrected or done again
by the collector who made them (2026-11-09, ADR-034)."""

from __future__ import annotations

import uuid
from typing import Any

import pytest
from httpx2 import AsyncClient
from sqlalchemy import text

from app.db.database import Database, Principal
from tests.test_form_links import _form, _record, _research_phone
from tests.test_research import _join, _person
from tests.test_sync import Phone, seeded

__all__ = ["seeded"]  # the fixture, used by name


def _draft(
    p: Phone,
    form: dict[str, Any],
    draft_id: str,
    updated: str = "2026-11-10T08:05:00Z",
    answers: dict[str, Any] | None = None,
) -> dict[str, Any]:
    return {
        "entity": "research_draft",
        "op": "insert",
        "id": draft_id,
        "data": {
            "form_id": form["id"],
            "form_version": 1,
            "number": "H-001",
            "collector_key": p.collector,
            "started_at": "2026-11-10T08:00:00Z",
            "updated_at": updated,
            "answers": answers if answers is not None else {"consent": "yes"},
            "media": {},
            "lat": 2.7,
            "lon": 33.6,
        },
    }


def _picture(p: Phone, owner: str) -> dict[str, Any]:
    return {
        "entity": "attachment",
        "op": "insert",
        "id": str(uuid.uuid4()),
        "data": {
            "owner_type": "research_draft",
            "owner_id": owner,
            "field_name": "photo",
            "sha256": "b" * 64,
            "bytes": 2000,
            "mime": "image/jpeg",
            **p.origin(),
        },
    }


async def _pulled(p: Phone, entity: str) -> list[dict[str, Any]]:
    changes = (await p.pull("research", None)).json()["changes"]
    return [c["data"] for c in changes if c["entity"] == entity]


async def _ready(
    client: AsyncClient, owner_db: Database
) -> tuple[dict[str, str], dict[str, Any], Phone]:
    _, owner = await _person(client, owner_db)
    _, form = await _form(client, owner)
    await client.patch(
        f"/v1/research/forms/{form['id']}", json={"join_approval": False}, headers=owner
    )
    p = await _research_phone(client, owner_db)
    await _join(client, p, form["access_code"])
    return owner, form, p


@pytest.mark.usefixtures("seeded")
async def test_a_draft_is_kept_latest_first_and_stays_the_collectors(
    client: AsyncClient, owner_db: Database
) -> None:
    owner, form, p = await _ready(client, owner_db)
    draft_id = str(uuid.uuid4())
    sent = await p.push([_draft(p, form, draft_id, answers={"consent": "yes", "people": 4})])
    assert sent["results"][0]["status"] == "applied"
    # An older copy arriving late changes nothing.
    late = await p.push([_draft(p, form, draft_id, "2026-11-10T08:01:00Z", {"consent": "no"})])
    assert late["results"][0]["status"] == "duplicate"
    held = await _pulled(p, "research_draft")
    assert [d["answers"] for d in held] == [{"consent": "yes", "people": 4}]

    # Not a record: no count, nothing for the team.
    listed = (await client.get(f"/v1/research/forms/{form['id']}/records", headers=owner)).json()
    assert listed["total"] == 0
    # Nor for another phone.
    other = await _research_phone(client, owner_db)
    assert await _pulled(other, "research_draft") == []


@pytest.mark.usefixtures("seeded")
async def test_signing_in_on_another_device_brings_the_draft_back(
    client: AsyncClient, owner_db: Database
) -> None:
    """The browser cleared everything: the same collector, a new device."""
    _, form, p = await _ready(client, owner_db)
    draft_id = str(uuid.uuid4())
    await p.push([_draft(p, form, draft_id)])
    fresh = await _research_phone(client, owner_db)
    # Before signing in, the new device has nothing of theirs.
    assert await _pulled(fresh, "research_draft") == []
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "INSERT INTO collector_device (collector_key, installation_id, signed_in_via) "
                "VALUES (:k, :i, 'admin_code')"
            ),
            {"k": p.collector, "i": fresh.id},
        )
    # Signed in, the feed read from the start (as the phone does then)
    # brings back the form they had joined, and the draft.
    changes = (await fresh.pull("research", None)).json()["changes"]
    assert [c["id"] for c in changes if c["entity"] == "research_draft"] == [draft_id]
    assert form["id"] in {c["id"] for c in changes if c["entity"] == "research_form"}
    access = await fresh.get("/v1/research/device/forms")
    assert form["id"] in access["allowed"]


@pytest.mark.usefixtures("seeded")
async def test_finishing_empties_the_draft_and_keeps_only_answering_pictures(
    client: AsyncClient, owner_db: Database
) -> None:
    owner, form, p = await _ready(client, owner_db)
    draft_id = str(uuid.uuid4())
    await p.push([_draft(p, form, draft_id)])
    kept, dropped = _picture(p, draft_id), _picture(p, draft_id)
    results = (await p.push([kept, dropped]))["results"]
    assert [r["status"] for r in results] == ["applied", "applied"]

    record = _record(p, form)
    record["id"] = draft_id
    record["data"]["answers"]["photo"] = kept["id"]
    assert (await p.push([record]))["results"][0]["status"] == "applied"

    drafts = await _pulled(p, "research_draft")
    assert drafts[0]["closed_at"] is not None and drafts[0]["answers"] == {}
    # A copy still on its way cannot reopen it.
    assert (await p.push([_draft(p, form, draft_id)]))["results"][0]["status"] == "duplicate"

    detail = (await client.get(f"/v1/research/records/{draft_id}", headers=owner)).json()
    assert [x["id"] for x in detail["pictures"]] == [kept["id"]]


@pytest.mark.usefixtures("seeded")
async def test_discarding_removes_the_answers(client: AsyncClient, owner_db: Database) -> None:
    _, form, p = await _ready(client, owner_db)
    draft_id = str(uuid.uuid4())
    await p.push([_draft(p, form, draft_id)])
    gone = {
        "entity": "research_draft",
        "op": "update",
        "id": draft_id,
        "data": {"discarded": True, "collector_key": p.collector},
    }
    assert (await p.push([gone]))["results"][0]["status"] == "applied"
    assert (await p.push([gone]))["results"][0]["status"] == "duplicate"
    drafts = await _pulled(p, "research_draft")
    assert drafts[0]["answers"] == {} and drafts[0]["closed_at"] is not None


@pytest.mark.usefixtures("seeded")
async def test_a_collector_waiting_for_approval_can_back_up_drafts(
    client: AsyncClient, owner_db: Database
) -> None:
    _, owner = await _person(client, owner_db)
    _, form = await _form(client, owner)
    p = await _research_phone(client, owner_db)
    assert (await _join(client, p, form["access_code"])).json()["status"] == "pending"
    result = (await p.push([_draft(p, form, str(uuid.uuid4()))]))["results"][0]
    assert result["status"] == "applied"
    # A phone with no part in the form cannot.
    stranger = await _research_phone(client, owner_db)
    refused = (await stranger.push([_draft(stranger, form, str(uuid.uuid4()))]))["results"][0]
    assert (refused["status"], refused["reason"]) == ("rejected", "not_found")


@pytest.mark.usefixtures("seeded")
async def test_a_correction_replaces_the_record_for_the_team_and_keeps_it(
    client: AsyncClient, owner_db: Database
) -> None:
    owner, form, p = await _ready(client, owner_db)
    first = _record(p, form)
    first["data"]["number"] = "H-7"
    await p.push([first])

    fixed = _record(p, form)
    fixed["data"].update(
        number="H-7",
        replaces=first["id"],
        replace_kind="correction",
        replace_reason="typed 60 people instead of 6",
    )
    out = (await p.push([fixed]))["results"][0]
    # Its own number again is not a clash.
    assert (out["status"], out.get("reason")) == ("applied", None)

    listed = (await client.get(f"/v1/research/forms/{form['id']}/records", headers=owner)).json()
    assert [r["id"] for r in listed["items"]] == [fixed["id"]]
    assert listed["items"][0]["replaces"] == first["id"]
    project = form["project_id"]
    assert (await client.get(f"/v1/research/forms/{form['id']}", headers=owner)).json()[
        "records"
    ] == 1
    data = (await client.get(f"/v1/research/forms/{form['id']}/data", headers=owner)).json()
    assert [r["id"] for r in data["rows"]] == [fixed["id"]]
    points = await client.get(f"/v1/research/projects/{project}/points", headers=owner)
    assert points.status_code == 200

    # The first stays as made, and says what replaced it.
    old = (await client.get(f"/v1/research/records/{first['id']}", headers=owner)).json()
    assert old["replaced_by"] == fixed["id"]
    assert old["answers"] == first["data"]["answers"]


@pytest.mark.usefixtures("seeded")
async def test_only_the_collector_who_made_a_record_replaces_it_with_a_reason(
    client: AsyncClient, owner_db: Database
) -> None:
    _, form, p = await _ready(client, owner_db)
    first = _record(p, form)
    await p.push([first])

    other = await _research_phone(client, owner_db)
    await _join(client, other, form["access_code"])
    theirs = _record(other, form)
    theirs["data"].update(replaces=first["id"], replace_kind="retake", replace_reason="again")
    # They cannot even see it.
    refused = (await other.push([theirs]))["results"][0]
    assert (refused["status"], refused["reason"]) == ("rejected", "missing_parent")

    no_reason = _record(p, form)
    no_reason["data"].update(replaces=first["id"], replace_kind="retake", replace_reason=" ")
    refused = (await p.push([no_reason]))["results"][0]
    assert (refused["status"], refused["reason"]) == ("rejected", "missing:replace_reason")

    retake = _record(p, form)
    retake["data"].update(
        replaces=first["id"], replace_kind="retake", replace_reason="the wrong household"
    )
    assert (await p.push([retake]))["results"][0]["status"] == "applied"
    pulled = {r["id"]: r for r in await _pulled(p, "research_record")}
    assert pulled[retake["id"]]["replace_kind"] == "retake"


def _water_draft(p: Phone, draft_id: str, updated: str = "2026-11-10T08:05:00Z") -> dict[str, Any]:
    return {
        "entity": "water_draft",
        "op": "insert",
        "id": draft_id,
        "data": {
            "source_id": str(uuid.uuid4()),
            "collector_key": p.collector,
            "started_at": "2026-11-10T08:00:00Z",
            "updated_at": updated,
            "state": {"values": {"ph": {"number": updated[-3:-1]}}},
            "media": {},
        },
    }


@pytest.mark.usefixtures("seeded")
async def test_a_water_test_in_progress_is_kept_and_stays_the_testers(
    client: AsyncClient, owner_db: Database
) -> None:
    p = await _research_phone(client, owner_db)
    draft_id = str(uuid.uuid4())
    assert (await p.push([_water_draft(p, draft_id)]))["results"][0]["status"] == "applied"
    late = await p.push([_water_draft(p, draft_id, "2026-11-10T08:01:00Z")])
    assert late["results"][0]["status"] == "duplicate"
    held = await _pulled(p, "water_draft")
    assert [(d["id"], d["updated_at"][:16]) for d in held] == [(draft_id, "2026-11-10T08:05")]
    other = await _research_phone(client, owner_db)
    assert await _pulled(other, "water_draft") == []

    gone = {
        "entity": "water_draft",
        "op": "update",
        "id": draft_id,
        "data": {"discarded": True, "collector_key": p.collector},
    }
    assert (await p.push([gone]))["results"][0]["status"] == "applied"
    closed = await _pulled(p, "water_draft")
    assert closed[0]["state"] == {} and closed[0]["closed_at"] is not None


@pytest.mark.usefixtures("seeded")
async def test_recovering_brings_the_other_side_and_the_districts_worked_in(
    client: AsyncClient, owner_db: Database
) -> None:
    """A code used on a new device: the linked profile is signed in too,
    and the phone is told where this person has worked."""
    _, form, p = await _ready(client, owner_db)
    water = await _research_phone(client, owner_db)
    # Two profiles of one person, linked by their details.
    linked = str(uuid.uuid4())
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "UPDATE collector_profile SET snapshot = snapshot || "
                "jsonb_build_object('linked_key', CAST(:l AS text)) WHERE collector_key = :k"
            ),
            {"k": p.collector, "l": linked},
        )
        await conn.execute(
            text(
                "INSERT INTO collector_profile (collector_key, installation_id, snapshot, "
                "profile_version, side) VALUES (:k, :i, CAST(:s AS jsonb), 1, 'water')"
            ),
            {"k": linked, "i": p.id, "s": '{"full_name": "Friend"}'},
        )
    code = await p.post(f"/v1/collectors/{p.collector}/recovery-code/own", {})
    assert code.status_code == 201, code.text
    back = await water.post("/v1/collectors/recover", {"code": code.json()["code"]})
    assert back.status_code == 200, back.text
    out = back.json()
    assert out["linked"]["collector_key"] == linked
    assert out["districts"] == []
    assert form["id"] in (await water.get("/v1/research/device/forms"))["allowed"]
