"""Shared form links (2026-11-01): a guest view, joining from a link with
the team's approval, and asking to edit from an editor link."""

from __future__ import annotations

import json
import uuid
from typing import Any

import pytest
from httpx2 import AsyncClient

from app.db.database import Database
from tests.helpers import make_area
from tests.test_research import DEFINITION, _join, _person
from tests.test_sync import Phone, phone, seeded

__all__ = ["seeded"]  # the fixture, used by name


async def _form(
    client: AsyncClient, owner: dict[str, str], access: str = "code"
) -> tuple[dict[str, Any], dict[str, Any]]:
    project = (
        await client.post(
            "/v1/research/projects",
            json={"code": f"L{uuid.uuid4().hex[:5].upper()}", "title": "Linked"},
            headers=owner,
        )
    ).json()
    form = (
        await client.post(
            f"/v1/research/projects/{project['id']}/forms",
            json={"code": "hh", "title": "Household"},
            headers=owner,
        )
    ).json()
    await client.put(
        f"/v1/research/forms/{form['id']}/draft", json={"definition": DEFINITION}, headers=owner
    )
    await client.post(f"/v1/research/forms/{form['id']}/publish", headers=owner)
    form = (
        await client.patch(
            f"/v1/research/forms/{form['id']}", json={"collect_access": access}, headers=owner
        )
    ).json()
    return project, form


async def _research_phone(client: AsyncClient, owner_db: Database) -> Phone:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    p.side = "research"
    profile = {
        "entity": "collector_profile",
        "op": "insert",
        "id": p.collector,
        "data": {
            "collector_key": p.collector,
            "collector_snapshot": json.dumps(
                {"collector_key": p.collector, "full_name": "Friend", "side": "research"}
            ),
        },
    }
    assert (await p.push([profile]))["results"][0]["status"] == "applied"
    return p


def _record(p: Phone, form: dict[str, Any]) -> dict[str, Any]:
    return {
        "entity": "research_record",
        "op": "insert",
        "id": str(uuid.uuid4()),
        "data": {
            "form_id": form["id"],
            "form_version": 1,
            "number": f"N-{uuid.uuid4().hex[:6]}",
            "started_at": "2026-11-10T08:00:00Z",
            "finished_at": "2026-11-10T08:05:00Z",
            "answers": {"consent": "yes", "has_latrine": "yes", "people": 6},
            **p.origin(),
        },
    }


async def _join_link(client: AsyncClient, p: Phone, token: str) -> Any:
    return await p.post("/v1/research/join-link", {"token": token, "collector_key": p.collector})


@pytest.mark.usefixtures("seeded")
async def test_a_collector_link_is_seen_as_a_guest_and_joined_with_approval(
    client: AsyncClient, owner_db: Database
) -> None:
    _, owner = await _person(client, owner_db)
    _, form = await _form(client, owner)
    assert form["join_approval"] is True  # new forms ask for approval
    link = (
        await client.post(
            f"/v1/research/forms/{form['id']}/links", json={"kind": "collect"}, headers=owner
        )
    ).json()
    # The same maker gets the same link again.
    again = await client.post(
        f"/v1/research/forms/{form['id']}/links", json={"kind": "collect"}, headers=owner
    )
    assert again.json()["token"] == link["token"]

    # Anyone, signed in or not, sees the questions and nothing else.
    seen = await client.get(f"/v1/public/links/{link['token']}")
    assert seen.status_code == 200, seen.text
    preview = seen.json()
    assert preview["kind"] == "collect" and preview["form_id"] == form["id"]
    assert preview["definition"]["fields"]
    assert "records" not in preview

    # A friend joins from it: the form reaches the phone, waiting.
    p = await _research_phone(client, owner_db)
    joined = await _join_link(client, p, link["token"])
    assert joined.status_code == 200, joined.text
    assert joined.json()["status"] == "pending"
    access = await p.get("/v1/research/device/forms")
    assert form["id"] in access["allowed"] and form["id"] in access["pending"]
    assert form["id"] not in {f["id"] for f in access["locked"]}
    pulled = (await p.pull("research", None)).json()["changes"]
    assert ("research_form", form["id"]) in {(c["entity"], c["id"]) for c in pulled}

    # Records wait on the phone until the team approves.
    held = (await p.push([_record(p, form)]))["results"][0]
    assert (held["status"], held["reason"]) == ("rejected", "awaiting_approval")
    collectors = (
        await client.get(f"/v1/research/projects/{form['project_id']}/collectors", headers=owner)
    ).json()
    mine = next(c for c in collectors if c["collector_key"] == p.collector)
    assert mine["forms"][0]["status"] == "pending" and mine["forms"][0]["via"] == "link"
    approved = await client.post(
        f"/v1/research/forms/{form['id']}/collectors/{p.collector}/approve", headers=owner
    )
    assert approved.status_code == 204
    assert (await p.get("/v1/research/device/forms"))["pending"] == []
    assert (await p.push([_record(p, form)]))["results"][0]["status"] == "applied"


@pytest.mark.usefixtures("seeded")
async def test_links_stop_with_a_new_code_or_when_turned_off(
    client: AsyncClient, owner_db: Database
) -> None:
    _, owner = await _person(client, owner_db)
    _, form = await _form(client, owner)
    link = (
        await client.post(
            f"/v1/research/forms/{form['id']}/links", json={"kind": "collect"}, headers=owner
        )
    ).json()
    await client.post(f"/v1/research/forms/{form['id']}/code", headers=owner)
    assert (await client.get(f"/v1/public/links/{link['token']}")).status_code == 404
    fresh = (
        await client.post(
            f"/v1/research/forms/{form['id']}/links", json={"kind": "collect"}, headers=owner
        )
    ).json()
    assert fresh["token"] != link["token"]
    assert (await client.get(f"/v1/public/links/{fresh['token']}")).status_code == 200
    off = await client.post(f"/v1/research/links/{fresh['id']}/off", headers=owner)
    assert off.status_code == 204
    assert (await client.get(f"/v1/public/links/{fresh['token']}")).status_code == 404
    listed = (await client.get(f"/v1/research/forms/{form['id']}/links", headers=owner)).json()
    assert [x["active"] for x in listed] == [False, False]


@pytest.mark.usefixtures("seeded")
async def test_forms_that_let_collectors_in_at_once_and_collectors_sharing(
    client: AsyncClient, owner_db: Database
) -> None:
    _, owner = await _person(client, owner_db)
    _, form = await _form(client, owner)
    await client.patch(
        f"/v1/research/forms/{form['id']}", json={"join_approval": False}, headers=owner
    )
    first = await _research_phone(client, owner_db)
    assert (await _join(client, first, form["access_code"])).json()["status"] == "approved"
    # A collector who has the form shares it on.
    shared = await first.post(
        f"/v1/research/device/forms/{form['id']}/link", {"collector_key": first.collector}
    )
    assert shared.status_code == 200, shared.text
    friend = await _research_phone(client, owner_db)
    joined = await _join_link(client, friend, shared.json()["token"])
    assert joined.json()["status"] == "approved"
    assert (await friend.push([_record(friend, form)]))["results"][0]["status"] == "applied"
    # A collector waiting for approval cannot share yet.
    await client.patch(
        f"/v1/research/forms/{form['id']}", json={"join_approval": True}, headers=owner
    )
    waiting = await _research_phone(client, owner_db)
    assert (await _join(client, waiting, form["access_code"])).json()["status"] == "pending"
    refused = await waiting.post(
        f"/v1/research/device/forms/{form['id']}/link", {"collector_key": waiting.collector}
    )
    assert refused.status_code == 403


@pytest.mark.usefixtures("seeded")
async def test_an_editor_link_asks_the_owner(client: AsyncClient, owner_db: Database) -> None:
    _, owner = await _person(client, owner_db)
    project, form = await _form(client, owner)
    sup_name, supervisor = await _person(client, owner_db)
    await client.post(
        f"/v1/research/projects/{project['id']}/members",
        json={"username": sup_name, "role": "supervisor"},
        headers=owner,
    )
    # Editor links are the owner's to make.
    refused = await client.post(
        f"/v1/research/forms/{form['id']}/links", json={"kind": "edit"}, headers=supervisor
    )
    assert refused.status_code == 403
    link = (
        await client.post(
            f"/v1/research/forms/{form['id']}/links", json={"kind": "edit"}, headers=owner
        )
    ).json()
    assert (await client.get(f"/v1/public/links/{link['token']}")).json()["kind"] == "edit"

    _, guest = await _person(client, owner_db)
    asked = await client.post(
        "/v1/research/edit-requests", json={"token": link["token"]}, headers=guest
    )
    assert asked.json() == {"form_id": form["id"], "status": "requested"}
    requests = (
        await client.get(f"/v1/research/forms/{form['id']}/edit-requests", headers=owner)
    ).json()
    assert len(requests) == 1
    who = requests[0]["user_id"]
    approved = await client.post(
        f"/v1/research/forms/{form['id']}/edit-requests/{who}/approve", headers=owner
    )
    assert approved.status_code == 204
    detail = (await client.get(f"/v1/research/forms/{form['id']}", headers=guest)).json()
    assert detail["can_edit"] is True
    # Asking again once an editor says so.
    again = await client.post(
        "/v1/research/edit-requests", json={"token": link["token"]}, headers=guest
    )
    assert again.json()["status"] == "editor"
    # A collector link cannot be used to ask to edit.
    collect = (
        await client.post(
            f"/v1/research/forms/{form['id']}/links", json={"kind": "collect"}, headers=owner
        )
    ).json()
    wrong = await client.post(
        "/v1/research/edit-requests", json={"token": collect["token"]}, headers=guest
    )
    assert wrong.status_code == 404
