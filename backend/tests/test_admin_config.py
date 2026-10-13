"""Configuration, health and audit for the IT admin (SPEC P11)."""

from __future__ import annotations

import uuid

from httpx2 import AsyncClient
from sqlalchemy import text

from app.db.database import Database, Principal
from tests.helpers import NEW_PASSWORD, make_area, signed_in
from tests.test_sync import PROFILE, client, phone, seeded, visit

__all__ = ["client", "seeded"]


async def test_audit_log_filters_and_exports(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    await client.post(
        "/v1/admin/users",
        json={"username": f"a-{uuid.uuid4().hex[:6]}@example.org", "full_name": "Audited"},
        headers=admin,
    )
    rows = (await client.get("/v1/admin/audit?action=user.&limit=50", headers=admin)).json()
    assert rows and all(r["action"].startswith("user.") for r in rows)
    assert any(r["action"] == "user.created" and r["actor_name"] for r in rows)
    csv = await client.get("/v1/admin/audit.csv?action=user.", headers=admin)
    assert csv.status_code == 200
    assert csv.text.startswith("﻿at_utc,actor,")
    assert "user.created" in csv.text
    noted = (await client.get("/v1/admin/audit?action=audit.exported", headers=admin)).json()
    assert noted
    stakeholder = await signed_in(client, owner_db)
    assert (await client.get("/v1/admin/audit", headers=stakeholder)).status_code == 403


async def test_health_reports_the_system(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    await phone(client, owner_db, await make_area(owner_db, "district"))
    admin = await signed_in(client, owner_db, role="it_admin")
    h = (await client.get("/v1/admin/health", headers=admin)).json()
    assert h["database"] is True
    assert h["phones_total"] >= 1
    assert sum(h["app_versions"].values()) == h["phones_total"]
    assert h["last_backup_at"] is None


async def test_villages_are_added_below_the_official_list(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    async with owner_db.transaction(Principal.system()) as conn:
        sub = (
            await conn.execute(text("SELECT id FROM admin_unit WHERE code = 'UG-ABIM-ALEREK'"))
        ).scalar_one()
    parish = await client.post(
        "/v1/admin/areas",
        json={"parent_id": str(sub), "level": "parish", "name": "Alerek Central"},
        headers=admin,
    )
    assert parish.status_code == 201
    assert parish.json()["code"] == "UG-ABIM-ALEREK-ALEREK-CENTRAL"
    village = await client.post(
        "/v1/admin/areas",
        json={"parent_id": parish.json()["id"], "level": "village", "name": "Lotim"},
        headers=admin,
    )
    assert village.status_code == 201
    again = await client.post(
        "/v1/admin/areas",
        json={"parent_id": parish.json()["id"], "level": "village", "name": "Lotim"},
        headers=admin,
    )
    assert again.status_code == 409
    upward = await client.post(
        "/v1/admin/areas",
        json={"parent_id": village.json()["id"], "level": "parish", "name": "Up"},
        headers=admin,
    )
    assert upward.status_code == 422
    renamed = await client.patch(
        f"/v1/admin/areas/{village.json()['id']}", json={"name": "Lotim West"}, headers=admin
    )
    assert renamed.json()["name"] == "Lotim West"
    vid = village.json()["id"]
    url = f"/v1/admin/areas/{vid}/default-profile"
    assert (await client.get(url, headers=admin)).json() == {"standard_id": None}
    class_ii = "ba9093d7-4551-54b4-9da1-3c14a7041644"
    put = await client.put(url, json={"standard_id": class_ii}, headers=admin)
    assert put.status_code == 204
    assert (await client.get(url, headers=admin)).json() == {"standard_id": class_ii}


async def test_routing_and_responsibilities(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    code = f"r{uuid.uuid4().hex[:6]}"
    made = await client.post(
        "/v1/admin/responsibilities", json={"code": code, "name": "Schools"}, headers=admin
    )
    assert made.status_code == 201
    before = (await client.get("/v1/admin/routing", headers=admin)).json()
    rules = [*before["rules"], {"trigger_rule": "ecoli", "responsibility_code": code}]
    assert (
        await client.put("/v1/admin/routing", json={"rules": rules}, headers=admin)
    ).status_code == 204
    after = (await client.get("/v1/admin/routing", headers=admin)).json()
    assert {"trigger_rule": "ecoli", "responsibility_code": code} in after["rules"]
    bad = await client.put(
        "/v1/admin/routing",
        json={"rules": [{"trigger_rule": "earthquake", "responsibility_code": code}]},
        headers=admin,
    )
    assert bad.status_code == 422
    # Leave the shared database as it was.
    await client.put("/v1/admin/routing", json={"rules": before["rules"]}, headers=admin)


async def test_security_settings_apply_at_the_next_sign_in(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    original = (await client.get("/v1/admin/security", headers=admin)).json()
    out_of_range = await client.put(
        "/v1/admin/security", json={**original, "max_failed_logins": 1}, headers=admin
    )
    assert out_of_range.status_code == 422
    try:
        tight = {**original, "max_failed_logins": 3}
        assert (await client.put("/v1/admin/security", json=tight, headers=admin)).json()[
            "max_failed_logins"
        ] == 3
        made = (
            await client.post(
                "/v1/admin/users",
                json={"username": f"lock-{uuid.uuid4().hex[:6]}@example.org", "full_name": "L"},
                headers=admin,
            )
        ).json()
        username = made["user"]["username"]
        codes = [
            (
                await client.post(
                    "/v1/auth/login", json={"username": username, "password": "wrong-pass-1"}
                )
            ).json()["detail"]
            for _ in range(3)
        ]
        assert codes[-1] == "locked"
        # A longer minimum password applies to the next change.
        user = await signed_in(client, owner_db)
        idle = {**original, "console_idle_minutes": 15}
        await client.put("/v1/admin/security", json=idle, headers=admin)
        me = (await client.get("/v1/me", headers=user)).json()
        assert me["console_idle_minutes"] == 15
        longer = {**original, "password_min_length": 20}
        await client.put("/v1/admin/security", json=longer, headers=admin)
        weak = await client.post(
            "/v1/auth/change-password",
            json={"current_password": NEW_PASSWORD, "new_password": "Shorter2026x"},
            headers=user,
        )
        assert weak.json()["detail"] == "weak_password"
    finally:
        await client.put("/v1/admin/security", json=original, headers=admin)


async def test_custom_parameters_are_reviewed_and_cards_edited(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    code = f"custom:{uuid.uuid4()}"
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "INSERT INTO parameter_definition (code, name, category_code, default_unit, "
                "value_type, is_custom, review_status, server_seq) VALUES "
                "(:c, 'Silica', 'chemical', 'mg/L', 'numeric', true, 'pending', 0)"
            ),
            {"c": code},
        )
    # A collector's reading of it, before the review.
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    field = visit(p)
    reading = next(c for c in field if c["entity"] == "reading" and c["data"]["unit"] == "mg/L")
    reading["data"]["parameter_code"] = code
    assert {r["status"] for r in (await p.push(field))["results"]} == {"applied"}
    pending = (await client.get("/v1/admin/parameters/pending", headers=admin)).json()
    assert code in {p["code"] for p in pending}
    merged = await client.post(
        f"/v1/admin/parameters/{code}/review",
        json={"action": "merge", "merge_into": "tds"},
        headers=admin,
    )
    assert merged.status_code == 204
    async with owner_db.transaction(Principal.system()) as conn:
        row = (
            await conn.execute(
                text("SELECT merged_into, review_status FROM parameter_definition WHERE code = :c"),
                {"c": code},
            )
        ).one()
        # P11 gate: the reading keeps its original code and value, and
        # counts as the parameter it was merged into.
        kept = (
            await conn.execute(
                text(
                    "SELECT r.parameter_code, r.value, COALESCE(d.merged_into, d.code) "
                    "FROM reading r JOIN parameter_definition d ON d.code = r.parameter_code "
                    "WHERE r.id = :id"
                ),
                {"id": reading["id"]},
            )
        ).one()
    assert tuple(row) == ("tds", "approved")
    assert (kept[0], str(kept[1]), kept[2]) == (code, "300", "tds")

    cards = (await client.get("/v1/admin/response-cards", headers=admin)).json()
    card = cards[0]
    edited = await client.put(
        f"/v1/admin/response-cards/{card['id']}",
        json={
            **{k: card["content"].get(k) for k in ("report_to", "report_note")},
            "title": card["content"]["title"],
            "actions": ["Boil the water."],
        },
        headers=admin,
    )
    assert edited.json()["version"] == card["version"] + 1
    assert edited.json()["content"]["actions"] == ["Boil the water."]
    await client.put(
        f"/v1/admin/response-cards/{card['id']}",
        json={k: card["content"].get(k) for k in ("title", "actions", "report_to", "report_note")},
        headers=admin,
    )


CLASS_I = "1c8c532b-bc51-58ba-94f4-c9e9093073c8"


async def test_an_area_default_changes_only_new_tests(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """P11 gate: past results keep the limit set they were judged by."""
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    before = visit(p)
    assert {r["status"] for r in (await p.push(before))["results"]} == {"applied"}

    admin = await signed_in(client, owner_db, role="it_admin")
    put = await client.put(
        f"/v1/admin/areas/{district['id']}/default-profile",
        json={"standard_id": CLASS_I},
        headers=admin,
    )
    assert put.status_code == 204

    # Phones learn the default with the area.
    defaults: dict[str, str | None] = {}
    cursor = None
    while True:
        page = (await p.pull("reference", cursor, limit=1000)).json()
        defaults |= {
            c["id"]: c["data"]["default_standard_id"]
            for c in page["changes"]
            if c["entity"] == "admin_unit"
        }
        cursor = page["next_cursor"]
        if not page["has_more"]:
            break
    assert defaults[str(district["id"])] == CLASS_I

    # A new test starts with it; the earlier one keeps its own.
    after = visit(p)
    for change in after:
        for key in ("reference_standard_id", "standard_id"):
            if key in change["data"]:
                change["data"][key] = CLASS_I
    assert {r["status"] for r in (await p.push(after))["results"]} == {"applied"}
    async with owner_db.transaction(Principal.system()) as conn:
        used: dict[str, str] = dict(
            (
                await conn.execute(
                    text(
                        "SELECT id::text, standard_id::text FROM test_result WHERE id IN (:a, :b)"
                    ),
                    {"a": before[2]["id"], "b": after[2]["id"]},
                )
            ).all()
        )
    assert used == {before[2]["id"]: PROFILE, after[2]["id"]: CLASS_I}


async def test_theme_and_time_zone_follow_the_user(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    user = await signed_in(client, owner_db)
    me = (await client.get("/v1/me", headers=user)).json()
    assert (me["theme"], me["time_zone"]) == ("system", "Africa/Kampala")
    put = await client.put(
        "/v1/me/appearance", json={"theme": "dark", "time_zone": "auto"}, headers=user
    )
    assert put.status_code == 204
    me = (await client.get("/v1/me", headers=user)).json()
    assert (me["theme"], me["time_zone"]) == ("dark", "auto")
    bad = await client.put(
        "/v1/me/appearance", json={"theme": "dark", "time_zone": "Mars/Base"}, headers=user
    )
    assert bad.status_code == 422
