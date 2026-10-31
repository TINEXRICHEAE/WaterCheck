"""Forms a phone gains later (a code joined, access opened) arrive with
their project, even when the phone synced while the project was hidden
from it (2026-10-31, the CHS4102 forms that "disappeared")."""

from __future__ import annotations

import uuid
from typing import Any

import pytest
from httpx2 import AsyncClient

from app.db.database import Database
from tests.helpers import make_area
from tests.test_research import DEFINITION, _join, _person
from tests.test_sync import Phone, phone, seeded

__all__ = ["seeded"]  # the fixture, used by name


async def _pull_all(p: Phone, cursor: str | None) -> tuple[list[dict[str, Any]], str]:
    seen: list[dict[str, Any]] = []
    while True:
        r = (await p.pull("research", cursor)).json()
        seen += r["changes"]
        cursor = r["next_cursor"]
        if not r["has_more"]:
            return seen, cursor


@pytest.mark.usefixtures("seeded")
async def test_a_form_joined_later_arrives_with_its_project(
    client: AsyncClient, owner_db: Database
) -> None:
    _, owner = await _person(client, owner_db)
    code = f"P{uuid.uuid4().hex[:5].upper()}"
    project = (
        await client.post(
            "/v1/research/projects", json={"code": code, "title": "Hidden at first"}, headers=owner
        )
    ).json()
    form = (
        await client.post(
            f"/v1/research/projects/{project['id']}/forms",
            json={"code": "lg", "title": "Log"},
            headers=owner,
        )
    ).json()
    await client.put(
        f"/v1/research/forms/{form['id']}/draft", json={"definition": DEFINITION}, headers=owner
    )
    await client.post(f"/v1/research/forms/{form['id']}/publish", headers=owner)

    # Another team's open form, published after it: the phone's cursor moves
    # past the hidden project (production, 2026-10-31).
    _, other = await _person(client, owner_db)
    elsewhere = (
        await client.post(
            "/v1/research/projects",
            json={"code": f"O{uuid.uuid4().hex[:5].upper()}", "title": "Open"},
            headers=other,
        )
    ).json()
    open_form = (
        await client.post(
            f"/v1/research/projects/{elsewhere['id']}/forms",
            json={"code": "op", "title": "Open"},
            headers=other,
        )
    ).json()
    await client.put(
        f"/v1/research/forms/{open_form['id']}/draft",
        json={"definition": DEFINITION},
        headers=other,
    )
    await client.post(f"/v1/research/forms/{open_form['id']}/publish", headers=other)
    await client.patch(
        f"/v1/research/forms/{open_form['id']}", json={"collect_access": "open"}, headers=other
    )

    # A research phone syncs while the form is for assigned collectors only:
    # the project is not its to see, and its cursor moves past it.
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    p.side = "research"
    hello = {
        "entity": "message",
        "op": "insert",
        "id": str(uuid.uuid4()),
        "data": {
            "subject_type": "collector",
            "subject_id": p.collector,
            "body": "Hi",
            **p.origin(),
        },
    }
    assert (await p.push([hello]))["results"][0]["status"] == "applied"
    first, cursor = await _pull_all(p, None)
    assert project["id"] not in {c["id"] for c in first if c["entity"] == "research_project"}
    assert open_form["id"] in {c["id"] for c in first if c["entity"] == "research_form"}

    # The owner opens the form to collectors with a code; the phone joins.
    patched = (
        await client.patch(
            f"/v1/research/forms/{form['id']}", json={"collect_access": "code"}, headers=owner
        )
    ).json()
    joined = await _join(client, p, patched["access_code"])
    assert joined.status_code == 200, joined.text

    # The next pull must bring the project too, or the phone cannot list the form.
    later, _ = await _pull_all(p, cursor)
    entities = {(c["entity"], c["id"]) for c in later}
    assert ("research_form", form["id"]) in entities
    assert ("research_project", project["id"]) in entities
    # And the phone may keep it: Collect drops forms not in "allowed".
    access = await p.get("/v1/research/device/forms")
    assert form["id"] in access["allowed"]
    assert form["id"] not in {f["id"] for f in access["locked"]}


@pytest.mark.usefixtures("seeded")
async def test_a_tester_sent_on_their_own_can_join_at_once(
    client: AsyncClient, owner_db: Database
) -> None:
    """A tester added on a phone reaches the server with the next sync, before
    any record, so a code works for them straight away (2026-10-31)."""
    _, owner = await _person(client, owner_db)
    project = (
        await client.post(
            "/v1/research/projects",
            json={"code": f"P{uuid.uuid4().hex[:5].upper()}", "title": "Codes"},
            headers=owner,
        )
    ).json()
    form = (
        await client.post(
            f"/v1/research/projects/{project['id']}/forms",
            json={"code": "cd", "title": "Coded"},
            headers=owner,
        )
    ).json()
    await client.put(
        f"/v1/research/forms/{form['id']}/draft", json={"definition": DEFINITION}, headers=owner
    )
    await client.post(f"/v1/research/forms/{form['id']}/publish", headers=owner)
    patched = (
        await client.patch(
            f"/v1/research/forms/{form['id']}", json={"collect_access": "code"}, headers=owner
        )
    ).json()

    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    p.side = "research"
    # Unknown to the server yet: the code is refused.
    assert (await _join(client, p, patched["access_code"])).status_code == 404

    profile = {
        "entity": "collector_profile",
        "op": "insert",
        "id": p.collector,
        "data": {
            "collector_key": p.collector,
            "collector_snapshot": p.origin()["collector_snapshot"],
        },
    }
    assert (await p.push([profile]))["results"][0]["status"] == "applied"
    assert (await _join(client, p, patched["access_code"])).status_code == 200

    # Only for itself: another key under this id is refused.
    other = {**profile, "id": str(uuid.uuid4())}
    result = (await p.push([other]))["results"][0]
    assert (result["status"], result["reason"]) == ("rejected", "invalid:collector_key")


async def test_access_and_sharing_stay_with_the_team(
    client: AsyncClient, owner_db: Database
) -> None:
    """An IT admin outside the team sees a form but may not change who
    collects with it, its code, sharing, editors or the team (2026-10-31)."""
    _, owner = await _person(client, owner_db)
    _, admin = await _person(client, owner_db, "it_admin")
    project = (
        await client.post(
            "/v1/research/projects",
            json={"code": f"C{uuid.uuid4().hex[:5].upper()}", "title": "Confidential"},
            headers=owner,
        )
    ).json()
    form = (
        await client.post(
            f"/v1/research/projects/{project['id']}/forms",
            json={"code": "cf", "title": "Private"},
            headers=owner,
        )
    ).json()
    await client.put(
        f"/v1/research/forms/{form['id']}/draft", json={"definition": DEFINITION}, headers=owner
    )
    await client.post(f"/v1/research/forms/{form['id']}/publish", headers=owner)
    mine = (
        await client.patch(
            f"/v1/research/forms/{form['id']}", json={"collect_access": "code"}, headers=owner
        )
    ).json()
    assert mine["can_share"] and mine["access_code"]

    seen = await client.get(f"/v1/research/forms/{form['id']}", headers=admin)
    assert seen.status_code == 200
    assert not seen.json()["can_share"]
    assert seen.json()["access_code"] is None

    fid = form["id"]
    refused = [
        await client.patch(
            f"/v1/research/forms/{fid}", json={"collect_access": "open"}, headers=admin
        ),
        await client.post(f"/v1/research/forms/{fid}/code", headers=admin),
        await client.post(
            f"/v1/research/forms/{fid}/editors", json={"username": "x"}, headers=admin
        ),
        await client.delete(f"/v1/research/forms/{fid}/editors/{uuid.uuid4()}", headers=admin),
        await client.post(
            f"/v1/research/forms/{fid}/shares", json={"username": "x"}, headers=admin
        ),
        await client.delete(f"/v1/research/forms/{fid}/shares/{uuid.uuid4()}", headers=admin),
        await client.post(
            f"/v1/research/forms/{fid}/collectors",
            json={"collector_key": str(uuid.uuid4())},
            headers=admin,
        ),
        await client.delete(f"/v1/research/forms/{fid}/collectors/{uuid.uuid4()}", headers=admin),
        await client.post(
            f"/v1/research/projects/{project['id']}/members",
            json={"username": "x", "role": "supervisor"},
            headers=admin,
        ),
    ]
    assert [r.status_code for r in refused] == [403] * len(refused), [r.text for r in refused]
    assert (await client.get(f"/v1/research/forms/{fid}", headers=owner)).json()[
        "collect_access"
    ] == "code"
