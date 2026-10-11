"""The server dashboard summary the web Console opens with (P9 web gate)."""

from __future__ import annotations

from httpx2 import AsyncClient

from app.db.database import Database
from tests.helpers import make_area
from tests.test_alerts import client, person, unsafe_visit
from tests.test_sync import phone, seeded

__all__ = ["client", "seeded"]


async def test_summary_matches_the_area_and_is_scoped(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    _, officer, _ = await person(client, owner_db, areas=(district["code"],))
    _, outsider, _ = await person(
        client, owner_db, areas=((await make_area(owner_db, "district"))["code"],)
    )
    changes = unsafe_visit(p)
    await p.push(changes)
    source = changes[0]["id"]

    s = (await client.get("/v1/dashboard/summary", headers=officer)).json()
    assert s["sources"] == 1
    assert (s["tested_in_period"], s["unsafe_in_period"]) == (1, 1)
    assert s["open_alerts"] == 1
    assert s["median_ack_seconds"] is None
    # Tested today: not overdue.
    assert s["overdue"] == []
    assert s["latest_tests"][0]["source_id"] == source
    assert s["latest_tests"][0]["overall"] == "unsafe"
    issue = s["latest_issue"]
    assert issue["source_id"] == source
    assert (issue["trigger_rule"], issue["lat"], issue["lon"]) == ("unsafe", 2.7, 33.6)
    assert len(s["collectors"]) == 1 and s["collectors"][0]["submissions"] == 1

    # One area of several: the same filter as the app's area selector.
    only = await client.get(f"/v1/dashboard/summary?area_id={p.village}", headers=officer)
    assert only.json()["sources"] == 1
    # Nothing outside the user's areas.
    other = (await client.get("/v1/dashboard/summary", headers=outsider)).json()
    assert other["sources"] == 0 and other["latest_issue"] is None
