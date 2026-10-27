"""P9: collector marks, submission flags and notification preferences."""

import uuid
from typing import Any

from httpx2 import AsyncClient

from app.db.database import Database
from app.services.alerts import alert_id
from app.services.channels import Channels, FakeSender
from app.worker import Worker
from tests.helpers import make_area
from tests.test_alerts import client, person, rows, unsafe_visit
from tests.test_sync import phone, seeded

__all__ = ["client", "seeded"]


async def push(client: AsyncClient, headers: dict[str, str], *changes: dict[str, Any]) -> Any:
    r = await client.post(
        "/v1/sync/push",
        json={"batch_id": str(uuid.uuid4()), "changes": list(changes)},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    return r.json()["results"]


async def pull_scope(client: AsyncClient, headers: dict[str, str]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    cursor = None
    while True:
        q = "stream=scope&limit=1000" + (f"&cursor={cursor}" if cursor else "")
        page = (await client.get(f"/v1/sync/pull?{q}", headers=headers)).json()
        out += page["changes"]
        cursor = page["next_cursor"]
        if not page["has_more"]:
            return out


async def test_marks_and_flags_reach_the_area_and_no_phone(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    changes = unsafe_visit(p)
    await p.push(changes)
    _, officer, _ = await person(client, owner_db, areas=(district["code"],))
    _, colleague, _ = await person(client, owner_db, areas=(district["code"],))
    # Areas no longer limit water users (ADR-031): the outsider is on the
    # research side.
    _, outsider, _ = await person(client, owner_db, side="research")

    flag_id = str(uuid.uuid4())
    out = await push(
        client,
        officer,
        {
            "entity": "collector_mark",
            "op": "update",
            "id": p.collector,
            "data": {"status": "known", "note": "Met at the parish meeting"},
        },
        {
            "entity": "submission_flag",
            "op": "insert",
            "id": flag_id,
            "data": {"result_id": changes[2]["id"], "reason": "pH looks copied from last week"},
        },
    )
    assert [r["status"] for r in out] == ["applied", "applied"]
    # A second decision replaces the first (versioned).
    again = await push(
        client,
        colleague,
        {
            "entity": "collector_mark",
            "op": "update",
            "id": p.collector,
            "data": {"status": "flagged", "note": "Readings implausible twice"},
        },
    )
    assert again[0]["server_version"] == 2

    seen = await pull_scope(client, colleague)
    marks = [c for c in seen if c["entity"] == "collector_mark" and c["id"] == p.collector]
    assert marks[-1]["data"]["status"] == "flagged"
    assert any(c["entity"] == "submission_flag" and c["id"] == flag_id for c in seen)

    other = await pull_scope(client, outsider)
    assert not any(c["entity"] in ("collector_mark", "submission_flag") for c in other)
    phone_view = (await p.pull(f"area:{p.village}")).json()["changes"]
    assert not any(c["entity"] in ("collector_mark", "submission_flag") for c in phone_view)

    # Phones cannot mark or flag.
    refused = await p.push(
        [
            {
                "entity": "submission_flag",
                "op": "insert",
                "id": str(uuid.uuid4()),
                "data": {"result_id": changes[2]["id"], "reason": "x"},
            }
        ]
    )
    assert refused["results"][0]["reason"] == "not_allowed"
    audit = await rows(
        owner_db,
        "SELECT count(*) AS n FROM audit_log WHERE action = 'collector.marked' AND entity_id = :k",
        k=p.collector,
    )
    assert audit[0].n == 2


async def test_preferences_switch_channels_but_not_the_inbox(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    user_id, headers, _ = await person(client, owner_db, areas=(district["code"],))
    me = (await client.get("/v1/me", headers=headers)).json()
    assert (me["notify_email"], me["notify_push"], me["notify_sms"]) == (True, True, True)
    r = await client.put(
        "/v1/me/preferences",
        json={"notify_email": False, "notify_push": True, "notify_sms": False},
        headers=headers,
    )
    assert r.status_code == 204
    assert (await client.get("/v1/me", headers=headers)).json()["notify_email"] is False

    changes = unsafe_visit(p)
    await p.push(changes)
    email = FakeSender("email")
    await Worker(owner_db, Channels(email=email)).run_due(limit=1000)
    aid = alert_id(changes[2]["id"], "unsafe")
    channels = {
        r.channel
        for r in await rows(
            owner_db,
            "SELECT channel FROM notification WHERE alert_id = :a AND user_id = :u",
            a=aid,
            u=user_id,
        )
    }
    assert channels == {"in_app"}
