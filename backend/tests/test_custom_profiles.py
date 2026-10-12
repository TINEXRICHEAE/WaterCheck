"""Who may create a custom limit set (O2, the lead, 2026-10-12): only a
stakeholder, recorded with their identity and comment."""

from __future__ import annotations

import json
import uuid
from typing import Any

from httpx2 import AsyncClient
from sqlalchemy import text

from app.db.database import Database, Principal
from tests.helpers import make_area, signed_in
from tests.test_sync import client, phone, seeded

__all__ = ["client", "seeded"]

CLASS_II = "ba9093d7-4551-54b4-9da1-3c14a7041644"


async def _custom(owner_db: Database, reason: str) -> dict[str, Any]:
    async with owner_db.transaction(Principal.system()) as conn:
        doc = (
            await conn.execute(
                text("SELECT document FROM reference_standard WHERE id = :id"), {"id": CLASS_II}
            )
        ).scalar_one()
    base = json.loads(doc) if isinstance(doc, str) else dict(doc)
    pid = str(uuid.uuid4())
    limits = [
        {**lim, "max": 9.0} if lim["parameter_code"] == "ph" else lim for lim in base["limits"]
    ]
    return {
        "entity": "reference_standard",
        "op": "insert",
        "id": pid,
        "data": {
            **base,
            "id": pid,
            "code": f"CUSTOM-{pid[-8:].upper()}",
            "is_custom": True,
            "based_on_id": CLASS_II,
            "custom_reason": reason,
            "limits": limits,
        },
    }


async def _push(client: AsyncClient, headers: dict[str, str], change: dict[str, Any]) -> Any:
    r = await client.post(
        "/v1/sync/push",
        json={"batch_id": str(uuid.uuid4()), "changes": [change]},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    return r.json()["results"][0]


async def test_only_a_stakeholder_creates_a_custom_limit_set(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    # A phone on its own: refused.
    refused = (await p.push([await _custom(owner_db, "Calibrated against lab samples")]))[
        "results"
    ][0]
    assert (refused["status"], refused["reason"]) == ("rejected", "stakeholder_required")

    # An IT admin is not a stakeholder: refused too.
    admin = await signed_in(client, owner_db, role="it_admin")
    not_admin = await _push(client, admin, await _custom(owner_db, "Admin trying it out"))
    assert not_admin["reason"] == "stakeholder_required"

    officer = await signed_in(client, owner_db, area_codes=(district["code"],))
    short = await _push(client, officer, await _custom(owner_db, "ok"))
    assert short["reason"] == "invalid:custom_reason"

    change = await _custom(owner_db, "Field kit reads pH 0.4 high against the lab")
    change["data"]["via"] = "collect"
    ok = await _push(client, officer, change)
    assert ok["status"] == "applied"
    me = (await client.get("/v1/me", headers=officer)).json()
    async with owner_db.transaction(Principal.system()) as conn:
        row = (
            await conn.execute(
                text(
                    "SELECT created_by, custom_reason, installation_id FROM reference_standard "
                    "WHERE id = :id"
                ),
                {"id": change["id"]},
            )
        ).one()
        audit = (
            await conn.execute(
                text(
                    "SELECT actor_id, platform, after FROM audit_log "
                    "WHERE action = 'reference_profile.created' AND entity_id = :id"
                ),
                {"id": change["id"]},
            )
        ).one()
    assert str(row.created_by) == me["id"]
    assert row.custom_reason == "Field kit reads pH 0.4 high against the lab"
    assert row.installation_id is None
    assert (str(audit.actor_id), audit.platform) == (me["id"], "collect")
    assert audit.after["reason"] == row.custom_reason

    # The new set reaches phones with the reference data.
    seen: set[str] = set()
    cursor = None
    while True:
        page = (await p.pull("reference", cursor, limit=1000)).json()
        seen |= {c["id"] for c in page["changes"] if c["entity"] == "reference_standard"}
        cursor = page["next_cursor"]
        if not page["has_more"]:
            break
    assert change["id"] in seen
