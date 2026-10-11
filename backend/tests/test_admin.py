"""The IT admin manages people and sees phones from the Console (P11)."""

from __future__ import annotations

from httpx2 import AsyncClient

from app.db.database import Database
from tests.helpers import NEW_PASSWORD, make_area, signed_in
from tests.test_sync import client, phone, seeded

__all__ = ["client", "seeded"]


async def test_admin_creates_a_stakeholder_who_must_change_the_password(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    region = await make_area(owner_db, "region")
    district = await make_area(owner_db, "district", parent=region["id"])
    made = await client.post(
        "/v1/admin/users",
        json={
            "username": "district.officer@example.org",
            "full_name": "District Officer",
            "organisation": "Abim District",
            "area_ids": [str(district["id"]), str(region["id"])],
            "responsibilities": ["water"],
        },
        headers=admin,
    )
    assert made.status_code == 201
    body = made.json()
    temp = body["temporary_password"]
    assert body["user"]["must_change_password"] is True
    assert {a["level"] for a in body["user"]["areas"]} == {"district", "region"}
    assert body["user"]["responsibilities"] == ["water"]
    # The same username again is refused.
    again = await client.post(
        "/v1/admin/users",
        json={"username": "DISTRICT.officer@example.org", "full_name": "X"},
        headers=admin,
    )
    assert again.status_code == 409

    login = await client.post(
        "/v1/auth/login", json={"username": "district.officer@example.org", "password": temp}
    )
    assert login.json()["must_change_password"] is True
    changed = await client.post(
        "/v1/auth/change-password",
        json={"current_password": temp, "new_password": NEW_PASSWORD},
        headers={"Authorization": f"Bearer {login.json()['access_token']}"},
    )
    assert changed.status_code == 200
    me = await client.get(
        "/v1/me", headers={"Authorization": f"Bearer {changed.json()['access_token']}"}
    )
    assert me.json()["full_name"] == "District Officer"

    listed = (await client.get("/v1/admin/users", headers=admin)).json()
    row = next(u for u in listed if u["username"] == "district.officer@example.org")
    assert row["last_sign_in_at"] is not None
    assert row["must_change_password"] is False


async def test_update_disable_and_reset(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    village = await make_area(owner_db, "village")
    made = (
        await client.post(
            "/v1/admin/users",
            json={"username": "vht.lead@example.org", "full_name": "VHT Lead"},
            headers=admin,
        )
    ).json()
    uid = made["user"]["id"]
    # Areas at any level, here a village; and back to no responsibilities.
    upd = await client.patch(
        f"/v1/admin/users/{uid}",
        json={"area_ids": [str(village["id"])], "position": "VHT coordinator"},
        headers=admin,
    )
    assert upd.status_code == 200
    assert upd.json()["areas"][0]["level"] == "village"
    assert upd.json()["position"] == "VHT coordinator"
    # Nulls from a generated client leave required fields alone.
    keep = await client.patch(
        f"/v1/admin/users/{uid}",
        json={"full_name": None, "role": None, "is_active": None, "phone": "+256700000001"},
        headers=admin,
    )
    assert keep.status_code == 200
    assert (keep.json()["full_name"], keep.json()["phone"]) == ("VHT Lead", "+256700000001")
    bad = await client.patch(
        f"/v1/admin/users/{uid}", json={"responsibilities": ["juggling"]}, headers=admin
    )
    assert bad.status_code == 422

    # Disabled: cannot sign in.
    off = await client.patch(f"/v1/admin/users/{uid}", json={"is_active": False}, headers=admin)
    assert off.json()["is_active"] is False
    login = await client.post(
        "/v1/auth/login",
        json={"username": "vht.lead@example.org", "password": made["temporary_password"]},
    )
    assert login.status_code in (401, 403)
    await client.patch(f"/v1/admin/users/{uid}", json={"is_active": True}, headers=admin)

    # A reset gives a new temporary password; the old one stops working.
    reset = (await client.post(f"/v1/admin/users/{uid}/reset-password", headers=admin)).json()
    assert reset["temporary_password"] != made["temporary_password"]
    old = await client.post(
        "/v1/auth/login",
        json={"username": "vht.lead@example.org", "password": made["temporary_password"]},
    )
    assert old.status_code == 401
    new = await client.post(
        "/v1/auth/login",
        json={"username": "vht.lead@example.org", "password": reset["temporary_password"]},
    )
    assert new.status_code == 200 and new.json()["must_change_password"] is True


async def test_only_admins_and_no_self_lockout(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    stakeholder = await signed_in(client, owner_db)
    assert (await client.get("/v1/admin/users", headers=stakeholder)).status_code == 403
    admin = await signed_in(client, owner_db, role="it_admin")
    me = (await client.get("/v1/me", headers=admin)).json()
    own = await client.patch(
        f"/v1/admin/users/{me['id']}", json={"is_active": False}, headers=admin
    )
    assert own.status_code == 422
    assert own.json()["detail"] == "cannot_lock_yourself_out"


async def test_phones_and_codes_are_listed(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    admin = await signed_in(client, owner_db, role="it_admin")
    phones = (await client.get("/v1/admin/installations", headers=admin)).json()
    mine = next(i for i in phones if i["id"] == p.id)
    assert mine["area"]["code"] == p.village_code
    assert mine["revoked_at"] is None
    codes = (await client.get("/v1/admin/activation-codes", headers=admin)).json()
    assert any(c["area"]["code"] == p.village_code and c["used_count"] >= 1 for c in codes)
    revoked = await client.post(f"/v1/admin/installations/{p.id}/revoke", headers=admin)
    assert revoked.status_code == 204
    phones = (await client.get("/v1/admin/installations", headers=admin)).json()
    assert next(i for i in phones if i["id"] == p.id)["revoked_at"] is not None


async def test_chain_view_shows_each_level_and_the_gaps(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    national = await make_area(owner_db, "country")
    region = await make_area(owner_db, "region", parent=national["id"])
    district = await make_area(owner_db, "district", parent=region["id"])
    village = await make_area(owner_db, "village", parent=district["id"])
    for name, area in (("Village VHT", village), ("National Officer", national)):
        await client.post(
            "/v1/admin/users",
            json={
                "username": f"{name.replace(' ', '.').lower()}@example.org",
                "full_name": name,
                "area_ids": [str(area["id"])],
            },
            headers=admin,
        )
    c = (await client.get(f"/v1/admin/areas/{village['id']}/chain", headers=admin)).json()
    assert [lv["area"]["level"] for lv in c["levels"]] == [
        "village",
        "district",
        "region",
        "country",
    ]
    assert [p["full_name"] for p in c["levels"][0]["people"]] == ["Village VHT"]
    assert c["first_notice"]["id"] == str(village["id"])
    assert {g["level"] for g in c["gaps"]} == {"district", "region"}
