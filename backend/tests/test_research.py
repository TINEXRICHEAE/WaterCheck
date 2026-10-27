"""Research in the Console (ADR-030 R2): a researcher builds and publishes a
form, gives it to collectors (named, or by access code), works with a team,
clones a public form, reads the records' data and talks with the collector
about a record."""

from __future__ import annotations

import json
import uuid
from typing import Any

import pytest
from httpx2 import AsyncClient

from app.db.database import Database, Principal
from app.services.users import NewUser, create_user
from tests.helpers import NEW_PASSWORD, make_area, signed_headers
from tests.test_sync import Phone, phone, seeded

__all__ = ["seeded"]  # the fixture, used by name


async def _person(
    client: AsyncClient, owner_db: Database, role: str = "stakeholder"
) -> tuple[str, dict[str, str]]:
    """A Console user: their sign-in name and auth headers."""
    username = f"r-{uuid.uuid4().hex[:8]}@example.org"
    async with owner_db.transaction(Principal.system()) as conn:
        created = await create_user(
            conn,
            NewUser(
                username=username,
                full_name=f"Researcher {username[:6]}",
                role=role,
                side="research",
            ),
        )
    first = await client.post(
        "/v1/auth/login",
        json={"username": username, "password": created.temporary_password, "side": "research"},
    )
    changed = await client.post(
        "/v1/auth/change-password",
        json={"current_password": created.temporary_password, "new_password": NEW_PASSWORD},
        headers={"Authorization": f"Bearer {first.json()['access_token']}"},
    )
    return username, {"Authorization": f"Bearer {changed.json()['access_token']}"}


async def _join(client: AsyncClient, p: Phone, code: str) -> Any:
    body = json.dumps({"code": code, "collector_key": p.collector}).encode()
    return await client.post(
        "/v1/research/join",
        content=body,
        headers={
            "Content-Type": "application/json",
            **signed_headers(
                p.id, p.secret, "POST", "/v1/research/join", body, nonce=uuid.uuid4().hex
            ),
        },
    )


DEFINITION = {
    "schema": 1,
    "title": "Latrine check",
    "settings": {"numbering": "generated"},
    "fields": [
        {"name": "consent", "type": "consent", "label": "Agree?"},
        {"name": "has_latrine", "type": "yes_no", "label": "Latrine?"},
        {"name": "people", "type": "integer", "label": "People", "min": 0},
    ],
}


@pytest.mark.usefixtures("seeded")
async def test_researcher_builds_publishes_and_collects(
    client: AsyncClient, owner_db: Database
) -> None:
    owner_name, owner = await _person(client, owner_db)
    code = f"T{uuid.uuid4().hex[:5].upper()}"
    r = await client.post(
        "/v1/research/projects",
        json={"code": code, "title": "Sanitation", "description": "Week checks"},
        headers=owner,
    )
    assert r.status_code == 201, r.text
    project = r.json()
    assert (project["my_role"], project["members"][0]["role"]) == ("owner", "owner")
    again = await client.post(
        "/v1/research/projects", json={"code": code.lower(), "title": "Again"}, headers=owner
    )
    assert again.status_code == 409

    # A draft form, built, then published.
    form = (
        await client.post(
            f"/v1/research/projects/{project['id']}/forms",
            json={"code": "lc", "title": "Latrine check"},
            headers=owner,
        )
    ).json()
    assert (form["code"], form["status"], form["has_draft"]) == ("LC", "draft", True)
    nothing = await client.post(f"/v1/research/forms/{form['id']}/publish", headers=owner)
    assert nothing.status_code == 422
    saved = (
        await client.put(
            f"/v1/research/forms/{form['id']}/draft",
            json={"definition": DEFINITION},
            headers=owner,
        )
    ).json()
    assert saved["draft"]["fields"][1]["name"] == "has_latrine"
    patched = (
        await client.patch(
            f"/v1/research/forms/{form['id']}",
            json={"collect_access": "code", "visibility": "public"},
            headers=owner,
        )
    ).json()
    assert patched["access_code"] and len(patched["access_code"]) == 8
    published = (
        await client.post(f"/v1/research/forms/{form['id']}/publish", headers=owner)
    ).json()
    assert (published["status"], published["current_version"], published["draft"]) == (
        "published",
        1,
        None,
    )

    # A phone joins with the code (after its tester first synced) and gets it.
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    a.side = "research"
    hello = {
        "entity": "message",
        "op": "insert",
        "id": str(uuid.uuid4()),
        "data": {
            "subject_type": "collector",
            "subject_id": a.collector,
            "body": "Ready",
            **a.origin(),
        },
    }
    assert (await a.push([hello]))["results"][0]["status"] == "applied"
    wrong = await _join(client, a, "ZZZZZZZZ")
    assert wrong.status_code == 404
    joined = await _join(client, a, patched["access_code"].lower())
    assert joined.status_code == 200, joined.text
    pulled = (await a.pull("research")).json()["changes"]
    assert form["id"] in {c["id"] for c in pulled if c["entity"] == "research_form"}

    record_id = str(uuid.uuid4())
    out = await a.push(
        [
            {
                "entity": "research_record",
                "op": "insert",
                "id": record_id,
                "data": {
                    "form_id": form["id"],
                    "form_version": 1,
                    "number": f"{code}-LC-0001",
                    "started_at": "2026-11-10T08:00:00Z",
                    "finished_at": "2026-11-10T08:05:00Z",
                    "lat": 2.70,
                    "lon": 33.65,
                    "answers": {"consent": "yes", "has_latrine": "yes", "people": 6},
                    **a.origin(),
                },
            }
        ]
    )
    assert out["results"][0]["status"] == "applied", out

    # The team: a supervisor helps, an analyst only reads.
    sup_name, supervisor = await _person(client, owner_db)
    ana_name, analyst = await _person(client, owner_db)
    for name, role in ((sup_name, "supervisor"), (ana_name, "analyst")):
        r = await client.post(
            f"/v1/research/projects/{project['id']}/members",
            json={"username": name, "role": role},
            headers=owner,
        )
        assert r.status_code == 200, r.text
    assert [m["role"] for m in r.json()["members"]] == ["owner", "supervisor", "analyst"]
    nobody = await client.post(
        f"/v1/research/projects/{project['id']}/members",
        json={"username": "nobody@example.org", "role": "analyst"},
        headers=owner,
    )
    assert nobody.status_code == 404
    denied = await client.put(
        f"/v1/research/forms/{form['id']}/draft", json={"definition": DEFINITION}, headers=analyst
    )
    assert denied.status_code == 403
    by_sup = await client.put(
        f"/v1/research/forms/{form['id']}/draft",
        json={"definition": DEFINITION},
        headers=supervisor,
    )
    assert by_sup.status_code == 200
    assert not (
        await client.post(
            f"/v1/research/projects/{project['id']}/members",
            json={"username": owner_name, "role": "analyst"},
            headers=supervisor,
        )
    ).is_success

    # Collectors, records and data for analysis.
    collectors = (
        await client.get(f"/v1/research/projects/{project['id']}/collectors", headers=analyst)
    ).json()
    assert [(c["records"], c["forms"][0]["via"]) for c in collectors] == [(1, "code")]
    records = (
        await client.get(
            f"/v1/research/projects/{project['id']}/records",
            params={"form_id": form["id"]},
            headers=analyst,
        )
    ).json()
    assert records["total"] == 1
    data = (await client.get(f"/v1/research/forms/{form['id']}/data", headers=analyst)).json()
    assert data["rows"][0]["answers"]["people"] == 6
    assert data["definitions"]["1"]["title"] == "Latrine check"
    versions = (await client.get(f"/v1/research/forms/{form['id']}/versions", headers=owner)).json()
    assert [(v["version"], v["records"]) for v in versions] == [(1, 1)]

    # A message to the collector reaches the phone; their answer comes back.
    msg_id = str(uuid.uuid4())
    thread = (
        await client.post(
            f"/v1/research/records/{record_id}/messages",
            json={"id": msg_id, "body": "Please recheck the count"},
            headers=supervisor,
        )
    ).json()
    assert (thread[0]["body"], thread[0]["from_team"], thread[0]["mine"]) == (
        "Please recheck the count",
        True,
        True,
    )
    on_phone = (await a.pull("research")).json()["changes"]
    assert msg_id in {c["id"] for c in on_phone if c["entity"] == "message"}
    reply = {
        "entity": "message",
        "op": "insert",
        "id": str(uuid.uuid4()),
        "data": {
            "subject_type": "research_record",
            "subject_id": record_id,
            "body": "Checked: six",
            "written_at_device": "2026-11-10T09:00:00Z",
            **a.origin(),
        },
    }
    assert (await a.push([reply]))["results"][0]["status"] == "applied"
    threads = (await client.get("/v1/research/messages", headers=owner)).json()
    mine = next(t for t in threads if t["record_id"] == record_id)
    assert (mine["count"], mine["last_from_team"]) == (2, False)

    # Another researcher finds the public form, and clones it as a draft.
    _, other = await _person(client, owner_db)
    library = (await client.get("/v1/research/library", headers=other)).json()
    assert form["id"] in {f["id"] for f in library}
    theirs = (
        await client.post(
            "/v1/research/projects",
            json={"code": f"U{uuid.uuid4().hex[:5].upper()}", "title": "Mine"},
            headers=other,
        )
    ).json()
    clone = (
        await client.post(
            f"/v1/research/forms/{form['id']}/clone",
            json={"project_id": theirs["id"], "code": "LC"},
            headers=other,
        )
    ).json()
    assert (clone["status"], clone["cloned_from"], clone["draft"]["title"]) == (
        "draft",
        form["id"],
        "Latrine check",
    )
    # They see the form, not its records, code or messages.
    seen = (await client.get(f"/v1/research/forms/{form['id']}", headers=other)).json()
    assert (seen["can_manage"], seen["access_code"]) == (False, None)
    assert (
        await client.get(f"/v1/research/forms/{form['id']}/data", headers=other)
    ).status_code == 404
    assert (
        await client.get(f"/v1/research/records/{record_id}/messages", headers=other)
    ).json() == []

    # Named collectors: assigned, then taken back; closing stops collection.
    found = (
        await client.get("/v1/research/testers", params={"q": "Example"}, headers=owner)
    ).json()
    assert a.collector in {t["collector_key"] for t in found}
    await client.post(
        f"/v1/research/forms/{form['id']}/collectors",
        json={"collector_key": a.collector},
        headers=owner,
    )
    collectors = (
        await client.get(f"/v1/research/projects/{project['id']}/collectors", headers=owner)
    ).json()
    assert collectors[0]["forms"][0]["via"] == "assigned"
    closed = (
        await client.patch(
            f"/v1/research/forms/{form['id']}", json={"status": "closed"}, headers=owner
        )
    ).json()
    assert closed["status"] == "closed"
    assert (await _join(client, a, patched["access_code"])).status_code == 404
