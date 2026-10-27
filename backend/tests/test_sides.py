"""Sides of FieldQuire (ADR-031): open sign-up per side, separate but linked
accounts, switching, each side's documents accepted once, and what each
side may see."""

from __future__ import annotations

import json
import uuid

import pytest
from httpx2 import AsyncClient, Response

from app.core.sides import LEGAL_VERSIONS
from app.db.database import Database
from tests.helpers import NEW_PASSWORD, make_area, signed_in
from tests.test_sync import phone, seeded, visit

__all__ = ["seeded"]  # the fixture, used by name


def _auth(r: Response) -> dict[str, str]:
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


async def _register(client: AsyncClient, side: str, email: str, **extra: object) -> Response:
    return await client.post(
        "/v1/auth/register",
        json={
            "side": side,
            "username": email,
            "full_name": "Akello Grace",
            "password": NEW_PASSWORD,
            "accepted_legal": LEGAL_VERSIONS[side],
            **extra,
        },
    )


@pytest.mark.usefixtures("seeded")
async def test_sign_up_join_and_switch_between_sides(client: AsyncClient) -> None:
    email = f"s-{uuid.uuid4().hex[:8]}@example.org"
    # The documents must be ticked.
    refused = await _register(client, "water", email, accepted_legal=0)
    assert refused.status_code == 422
    r = await _register(client, "water", email)
    assert r.status_code == 201, r.text
    water = _auth(r)
    me = (await client.get("/v1/me", headers=water)).json()
    assert (me["side"], me["legal_due"], me["linked_sides"]) == ("water", [], [])
    assert me["legal"] == {"water": LEGAL_VERSIONS["water"]}
    assert me["must_change_password"] is False
    again = await _register(client, "water", email)
    assert again.status_code == 409

    # The water account cannot sign in to research, nor use research pages.
    wrong = await client.post(
        "/v1/auth/login", json={"username": email, "password": NEW_PASSWORD, "side": "research"}
    )
    assert wrong.status_code == 401
    assert (await client.get("/v1/research/projects", headers=water)).status_code == 403
    assert (
        await client.post("/v1/auth/switch", json={"side": "research"}, headers=water)
    ).status_code == 404

    # Joining research: the password again and the research documents.
    bad = await client.post(
        "/v1/auth/join",
        json={"side": "research", "password": "wrong", "accepted_legal": 1},
        headers=water,
    )
    assert bad.status_code == 401
    r = await client.post(
        "/v1/auth/join",
        json={"side": "research", "password": NEW_PASSWORD, "accepted_legal": 1},
        headers=water,
    )
    assert r.status_code == 200, r.text
    research = _auth(r)
    me = (await client.get("/v1/me", headers=research)).json()
    assert (me["side"], me["linked_sides"]) == ("research", ["water"])
    assert (await client.get("/v1/research/projects", headers=research)).status_code == 200

    # Both accounts sign in on their side with the same email; switching
    # needs no password.
    for side in ("water", "research"):
        r = await client.post(
            "/v1/auth/login", json={"username": email, "password": NEW_PASSWORD, "side": side}
        )
        assert r.status_code == 200
    r = await client.post("/v1/auth/switch", json={"side": "water"}, headers=research)
    assert r.status_code == 200
    assert (await client.get("/v1/me", headers=_auth(r))).json()["side"] == "water"

    # Someone else may sign up on research with an email already used on
    # water, as a separate person.
    other = f"o-{uuid.uuid4().hex[:8]}@example.org"
    assert (await _register(client, "water", other)).status_code == 201
    assert (await _register(client, "research", other)).status_code == 201


async def test_existing_accounts_accept_each_sides_documents_once(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    old = await signed_in(client, owner_db)
    me = (await client.get("/v1/me", headers=old)).json()
    assert me["legal_due"] == ["water"]
    r = await client.post(
        "/v1/me/legal", json={"version": LEGAL_VERSIONS["water"], "side": "water"}, headers=old
    )
    assert r.status_code == 204
    assert (await client.get("/v1/me", headers=old)).json()["legal_due"] == []
    admin = await signed_in(client, owner_db, role="it_admin", side="all")
    me = (await client.get("/v1/me", headers=admin)).json()
    assert (me["side"], me["legal_due"]) == ("all", ["water", "research"])


async def test_water_users_see_every_source_and_research_users_none(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """Areas no longer limit what water users see (2026-10-27)."""
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    sent = visit(p)
    await p.push(sent)
    source_id = sent[0]["id"]

    async def sources(headers: dict[str, str]) -> set[str]:
        seen: set[str] = set()
        cursor = ""
        while True:
            r = await client.get(
                f"/v1/sync/pull?stream=scope&limit=500&cursor={cursor}", headers=headers
            )
            assert r.status_code == 200, r.text
            page = r.json()
            seen |= {c["id"] for c in page["changes"] if c["entity"] == "water_source"}
            if not page["has_more"]:
                return seen
            cursor = page["next_cursor"]

    water = await signed_in(client, owner_db)  # no areas at all
    assert source_id in await sources(water)
    research = await signed_in(client, owner_db, side="research")
    assert source_id not in await sources(research)


async def test_each_acceptance_is_kept_for_accountability(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """Sign-up, joining, the one-time prompt and a phone's profile each
    leave a row: who, which side and version, how, from where, when."""
    admin = await signed_in(client, owner_db, role="it_admin", side="all")
    email = f"a-{uuid.uuid4().hex[:8]}@example.org"
    water = _auth(await _register(client, "water", email))
    me = (await client.get("/v1/me", headers=water)).json()
    r = await client.post(
        "/v1/auth/join",
        json={"side": "research", "password": NEW_PASSWORD, "accepted_legal": 1},
        headers=water,
    )
    research_id = (await client.get("/v1/me", headers=_auth(r))).json()["id"]
    rows = (
        await client.get(f"/v1/admin/legal-acceptances?user_id={me['id']}", headers=admin)
    ).json()
    assert [(x["side"], x["how"], x["terms_accepted"]) for x in rows] == [("water", "signup", True)]
    rows = (
        await client.get(f"/v1/admin/legal-acceptances?user_id={research_id}", headers=admin)
    ).json()
    assert [(x["side"], x["how"]) for x in rows] == [("research", "join")]

    # A tester's profile arriving with the documents accepted on the phone.
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    origin = p.origin()
    origin["collector_snapshot"] = json.dumps(
        {"full_name": "Example Collector", "legal_version": 4, "profile_version": 1}
    )
    msg = {
        "entity": "message",
        "op": "insert",
        "id": str(uuid.uuid4()),
        "data": {
            "subject_type": "collector",
            "subject_id": p.collector,
            "body": "Hello",
            **origin,
        },
    }
    assert (await p.push([msg]))["results"][0]["status"] == "applied"
    rows = (
        await client.get(f"/v1/admin/legal-acceptances?collector_key={p.collector}", headers=admin)
    ).json()
    assert [(x["side"], x["version"], x["how"]) for x in rows] == [("water", 4, "profile")]
    assert rows[0]["device"] is not None
    # Only IT admins read them.
    assert (
        await client.get(f"/v1/admin/legal-acceptances?user_id={me['id']}", headers=water)
    ).status_code == 403


async def test_each_sides_admin_lists_only_its_people(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """IT admins manage each side apart (ADR-031): people, devices and the
    ledger of one side only (the IT admins themselves on both)."""
    admin = await signed_in(client, owner_db, role="it_admin", side="all")
    w = f"w-{uuid.uuid4().hex[:8]}@example.org"
    r = f"r-{uuid.uuid4().hex[:8]}@example.org"
    await _register(client, "water", w)
    await _register(client, "research", r)

    async def names(side: str) -> set[str]:
        got = await client.get(f"/v1/admin/users?side={side}", headers=admin)
        return {u["username"] for u in got.json()}

    water, research = await names("water"), await names("research")
    assert w in water and w not in research
    assert r in research and r not in water
    ledger = (await client.get("/v1/admin/credentials?side=research", headers=admin)).json()
    assert ledger["codes"] == []
    assert r in {a["username"] for a in ledger["accounts"]}

    # A research tester's phone is listed on research, not on water.
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
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
    await p.push([hello])

    async def devices(side: str) -> set[str]:
        got = await client.get(f"/v1/admin/installations?side={side}", headers=admin)
        return {d["id"] for d in got.json()}

    assert p.id in await devices("research")
    assert p.id not in await devices("water")
