"""People by username, private by default, and messages between them
(ADR-032); form editors and who published each version."""

from __future__ import annotations

import uuid
from typing import Any

import pytest
from httpx2 import AsyncClient
from sqlalchemy import text

from app.db.database import Database, Principal
from tests.helpers import make_area
from tests.test_research import DEFINITION, _person
from tests.test_sync import Phone, phone, seeded

__all__ = ["seeded"]  # the fixture, used by name


async def _research_phone(client: AsyncClient, owner_db: Database) -> Phone:
    """A phone whose research tester has synced once (so the server knows
    their profile)."""
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
    return p


async def _put(p: Phone, path: str, payload: dict[str, Any]) -> Any:
    import json

    from tests.helpers import signed_headers

    body = json.dumps(payload).encode()
    return await p.client.put(
        path,
        content=body,
        headers={
            "Content-Type": "application/json",
            **signed_headers(p.id, p.secret, "PUT", path, body, nonce=uuid.uuid4().hex),
        },
    )


@pytest.mark.usefixtures("seeded")
async def test_everyone_has_a_username_and_is_anonymous_by_default(
    client: AsyncClient, owner_db: Database
) -> None:
    _, me = await _person(client, owner_db)
    _, other = await _person(client, owner_db)
    mine = (await client.get("/v1/me/identity", headers=me)).json()
    assert mine["public"] is False
    assert len(mine["handle"].split("-")) == 3, mine

    # Someone else sees the username only, until it goes public.
    def find(people: list[dict[str, Any]], handle: str | None = None) -> dict[str, Any]:
        return next(x for x in people if x["handle"] == (handle or mine["handle"]))

    seen = find(
        (await client.get("/v1/people", params={"q": mine["handle"]}, headers=other)).json()
    )
    assert (seen["kind"], seen["full_name"]) == ("user", None)
    by_name = (
        await client.get("/v1/people", params={"q": mine["full_name"]}, headers=other)
    ).json()
    assert mine["handle"] not in {x["handle"] for x in by_name}

    # A chosen username: checked, unique, and the other account cannot take it.
    wanted = f"field-{uuid.uuid4().hex[:6]}"
    bad = await client.put("/v1/me/identity", json={"handle": "x"}, headers=me)
    assert bad.status_code == 422
    changed = (
        await client.put(
            "/v1/me/identity", json={"handle": wanted.upper(), "public": True}, headers=me
        )
    ).json()
    assert (changed["handle"], changed["public"]) == (wanted, True)
    taken = await client.put("/v1/me/identity", json={"handle": wanted}, headers=other)
    assert taken.status_code == 409
    check = (
        await client.get("/v1/people/handle-check", params={"handle": wanted}, headers=other)
    ).json()
    assert check["free"] is False
    public = find(
        (await client.get("/v1/people", params={"q": wanted}, headers=other)).json(), wanted
    )
    assert public["full_name"] == mine["full_name"]


@pytest.mark.usefixtures("seeded")
async def test_people_write_to_each_other_across_apps(
    client: AsyncClient, owner_db: Database
) -> None:
    _, me = await _person(client, owner_db)
    p = await _research_phone(client, owner_db)
    tester = await p.get(f"/v1/device/collectors/{p.collector}/identity")

    # The tester is on the research list, anonymous.
    listed = (await client.get("/v1/people", params={"q": tester["handle"]}, headers=me)).json()
    assert [(x["kind"], x["id"], x["full_name"]) for x in listed] == [
        ("collector", p.collector, None)
    ]

    chat = (
        await client.post(
            "/v1/chats", json={"to_kind": "collector", "to_id": p.collector}, headers=me
        )
    ).json()
    assert chat["other"]["handle"] == tester["handle"]
    sent = await client.post(
        f"/v1/chats/{chat['id']}/messages", json={"body": "Can you help in Abim?"}, headers=me
    )
    assert sent.status_code == 201, sent.text
    # Starting again finds the same chat.
    again = (
        await client.post(
            "/v1/chats", json={"to_kind": "collector", "to_id": p.collector}, headers=me
        )
    ).json()
    assert again["id"] == chat["id"]

    # The phone sees it unread, reads it and answers.
    q = f"side=research&collector_key={p.collector}"
    theirs = await p.get(f"/v1/device/chats?{q}")
    assert [(c["id"], c["unread"]) for c in theirs] == [(chat["id"], 1)]
    read = await p.get(f"/v1/device/chats/{chat['id']}/messages?collector_key={p.collector}")
    assert [(m["mine"], m["body"]) for m in read] == [(False, "Can you help in Abim?")]
    answer = await p.post(
        f"/v1/device/chats/{chat['id']}/messages?collector_key={p.collector}", {"body": "Yes"}
    )
    assert answer.status_code == 201, answer.text
    mine = (await client.get(f"/v1/chats/{chat['id']}/messages", headers=me)).json()
    assert [m["body"] for m in mine] == ["Can you help in Abim?", "Yes"]
    assert mine[0]["read_at"] is not None

    # Nobody else reads it.
    _, stranger = await _person(client, owner_db)
    hidden = await client.get(f"/v1/chats/{chat['id']}/messages", headers=stranger)
    assert hidden.status_code == 404


@pytest.mark.usefixtures("seeded")
async def test_editors_publish_and_are_credited(client: AsyncClient, owner_db: Database) -> None:
    _, owner = await _person(client, owner_db)
    editor_name, editor = await _person(client, owner_db)
    _, stranger = await _person(client, owner_db)
    project = (
        await client.post(
            "/v1/research/projects",
            json={"code": f"E{uuid.uuid4().hex[:5].upper()}", "title": "Editors"},
            headers=owner,
        )
    ).json()
    form = (
        await client.post(
            f"/v1/research/projects/{project['id']}/forms",
            json={"code": "ed", "title": "Edited"},
            headers=owner,
        )
    ).json()
    await client.put(
        f"/v1/research/forms/{form['id']}/draft", json={"definition": DEFINITION}, headers=owner
    )
    await client.patch(
        f"/v1/research/forms/{form['id']}", json={"visibility": "public"}, headers=owner
    )
    await client.post(f"/v1/research/forms/{form['id']}/publish", headers=owner)

    # Not an editor yet: may see and copy, not change.
    seen = (await client.get(f"/v1/research/forms/{form['id']}", headers=editor)).json()
    assert (seen["can_edit"], seen["can_manage"], seen["my_copy"]) == (False, False, None)
    refused = await client.put(
        f"/v1/research/forms/{form['id']}/draft", json={"definition": DEFINITION}, headers=editor
    )
    assert refused.status_code == 403

    added = (
        await client.post(
            f"/v1/research/forms/{form['id']}/editors",
            json={"username": editor_name},
            headers=owner,
        )
    ).json()
    assert len(added["editors"]) == 1
    changed = {**DEFINITION, "title": "Latrine check, round 2"}
    saved = await client.put(
        f"/v1/research/forms/{form['id']}/draft", json={"definition": changed}, headers=editor
    )
    assert saved.status_code == 200, saved.text
    out = await client.post(f"/v1/research/forms/{form['id']}/publish", headers=editor)
    assert out.json()["current_version"] == 2
    # Access and sharing stay with the owning team.
    patch = await client.patch(
        f"/v1/research/forms/{form['id']}", json={"visibility": "private"}, headers=editor
    )
    assert patch.status_code in (403, 404)

    # Each version names who published it; strangers see usernames only.
    owner_handle = (await client.get("/v1/me/identity", headers=owner)).json()["handle"]
    editor_handle = (await client.get("/v1/me/identity", headers=editor)).json()["handle"]
    versions = (
        await client.get(f"/v1/research/forms/{form['id']}/versions", headers=stranger)
    ).json()
    assert [v["published_by"] for v in versions] == [editor_handle, owner_handle]

    # A copy is remembered, so it is not made twice.
    my_project = (
        await client.post(
            "/v1/research/projects",
            json={"code": f"C{uuid.uuid4().hex[:5].upper()}", "title": "Mine"},
            headers=stranger,
        )
    ).json()
    copy = await client.post(
        f"/v1/research/forms/{form['id']}/clone",
        json={"project_id": my_project["id"], "code": "CP"},
        headers=stranger,
    )
    assert copy.status_code == 201, copy.text
    seen = (await client.get(f"/v1/research/forms/{form['id']}", headers=stranger)).json()
    assert seen["my_copy"] == copy.json()["id"]


@pytest.mark.usefixtures("seeded")
async def test_old_sync_cursors_start_again_with_names_by_username(
    client: AsyncClient, owner_db: Database
) -> None:
    p = await _research_phone(client, owner_db)
    stream = "research"
    old = await p.pull(stream, cursor="1.1")
    assert old.status_code == 200, old.text
    assert old.json()["next_cursor"].startswith("2:")
    async with owner_db.transaction(Principal.system()) as conn:
        handle = (
            await conn.execute(
                text("SELECT handle FROM collector_profile WHERE collector_key = :k"),
                {"k": p.collector},
            )
        ).scalar_one()
    assert handle


async def test_ip_location_is_unknown_without_the_city_database(client: AsyncClient) -> None:
    """Devices without GPS ask where their connection is (2026-10-28); with
    no database on the server the answer is a plain 404."""
    r = await client.get("/v1/places/ip-location", headers={"X-Forwarded-For": "10.0.0.5"})
    assert r.status_code == 404
    assert r.json()["detail"] == "ip_location_unknown"
