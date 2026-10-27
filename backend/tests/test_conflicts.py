"""Stakeholders review and resolve kept-server source changes (ADR-011)."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any

from httpx2 import AsyncClient
from sqlalchemy import text

from app.db.database import Database, Principal
from tests.helpers import make_area, signed_in
from tests.test_sync import client, phone, seeded, visit

__all__ = ["client", "seeded"]


async def test_area_stakeholder_resolves_a_conflict(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    source = visit(p)[0]
    await p.push([source])
    sid = source["id"]

    def edit(status: str) -> dict[str, Any]:
        return {
            "entity": "water_source",
            "op": "update",
            "id": sid,
            "base_version": 1,
            "data": {
                "functional_status": status,
                "updated_at_device": datetime.now(UTC).isoformat(),
                **p.origin(),
            },
        }

    await p.push([edit("broken")])
    assert (await p.push([edit("functional")]))["results"][0]["status"] == "conflict"

    officer = await signed_in(client, owner_db, area_codes=(district["code"],))
    # Areas no longer limit water users (ADR-031); someone on the research
    # side is the outsider now.
    outsider = await signed_in(client, owner_db, side="research")
    assert (await client.get("/v1/conflicts", headers=outsider)).json() == []
    listed = (await client.get(f"/v1/conflicts?source_id={sid}", headers=officer)).json()
    assert len(listed) == 1
    c = listed[0]
    assert (c["field"], c["server_value"], c["client_value"]) == (
        "functional_status",
        "broken",
        "functional",
    )
    assert c["from_phone"] is True
    # Someone outside the area cannot resolve it either.
    r = await client.post(
        f"/v1/conflicts/{c['id']}/resolve", json={"keep": "client"}, headers=outsider
    )
    assert r.status_code == 404

    r = await client.post(
        f"/v1/conflicts/{c['id']}/resolve", json={"keep": "client"}, headers=officer
    )
    assert r.status_code == 200
    again = await client.post(
        f"/v1/conflicts/{c['id']}/resolve", json={"keep": "server"}, headers=officer
    )
    assert again.status_code == 409
    assert (await client.get("/v1/conflicts", headers=officer)).json() == []
    async with owner_db.transaction(Principal.system()) as conn:
        row = (
            await conn.execute(
                text("SELECT functional_status, version FROM water_source WHERE id = :id"),
                {"id": sid},
            )
        ).one()
        audit = (
            await conn.execute(
                text(
                    "SELECT after FROM audit_log WHERE action = 'conflict.resolved' "
                    "AND entity_id = :id"
                ),
                {"id": sid},
            )
        ).scalar_one()
    assert row.functional_status == "functional"
    assert row.version == 3  # 1 created, 2 broken, 3 resolved (the losing push changed nothing)
    assert audit == {"field": "functional_status", "kept": "client"}
