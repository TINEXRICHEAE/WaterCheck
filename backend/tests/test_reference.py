"""Seed loader, reference endpoints, server classification and the collector
registry (P4)."""

from __future__ import annotations

import json
import uuid
from pathlib import Path
from typing import Any

import pytest_asyncio
from httpx2 import AsyncClient
from sqlalchemy import text

from app.db.database import Database, Principal
from app.seed import load_seed
from app.services.classification import classify_result
from tests.helpers import signed_headers, signed_in

SEED = Path(__file__).resolve().parents[2] / "infra" / "seed"
VILLAGE = "ABIM-ENT"
CLASS_I = "US201-2008-ClassI"
CLASS_II = "US201-2008-ClassII"


@pytest_asyncio.fixture
async def seeded(owner_db: Database) -> None:
    async with owner_db.transaction(Principal.system()) as conn:
        await load_seed(conn, SEED)


async def _id(owner_db: Database, sql: str, **params: Any) -> uuid.UUID:
    async with owner_db.transaction(Principal.system()) as conn:
        value = (await conn.execute(text(sql), params)).scalar_one()
    return uuid.UUID(str(value))


async def _test_session(
    owner_db: Database,
    *,
    tds: str,
    profile_code: str,
    collector_key: uuid.UUID,
    name: str = "Example Collector",
) -> uuid.UUID:
    """A source in the seeded village with one session, result and the core
    four readings; returns the result ID."""
    village = await _id(owner_db, "SELECT id FROM admin_unit WHERE code = :c", c=VILLAGE)
    standard = await _id(
        owner_db, "SELECT id FROM reference_standard WHERE code = :c", c=profile_code
    )
    src, inst, sess, res = uuid.uuid4(), uuid.uuid4(), uuid.uuid4(), uuid.uuid4()
    snapshot = json.dumps(
        {"full_name": name, "phone": "+256772123456", "collector_type": "vht", "village": "Entebbe"}
    )
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "INSERT INTO installation (id, admin_unit_id, secret_encrypted) "
                "VALUES (:i, :v, 'x')"
            ),
            {"i": inst, "v": village},
        )
        await conn.execute(
            text(
                "INSERT INTO water_source (id, village_id, code, source_type) "
                "VALUES (:s, :v, :code, 'borehole')"
            ),
            {"s": src, "v": village, "code": f"ABIM-ENT-{uuid.uuid4().hex[:4]}"},
        )
        await conn.execute(
            text(
                "INSERT INTO test_session (id, source_id, installation_id, collector_key, "
                "collector_snapshot, reference_standard_id, calibrated, tested_at_device) "
                "VALUES (:id, :s, :i, :k, CAST(:snap AS jsonb), :std, true, now())"
            ),
            {
                "id": sess,
                "s": src,
                "i": inst,
                "k": collector_key,
                "snap": snapshot,
                "std": standard,
            },
        )
        await conn.execute(
            text(
                "INSERT INTO test_result (id, session_id, overall, standard_id, created_at_device) "
                "VALUES (:id, :s, 'safe', :std, now())"
            ),
            {"id": res, "s": sess, "std": standard},
        )
        for code, unit, value in [
            ("temp", "°C", "25"),
            ("ph", "pH", "7.1"),
            ("ec", "µS/cm", "800"),
            ("tds", "mg/L", tds),
        ]:
            await conn.execute(
                text(
                    "INSERT INTO reading (id, session_id, result_id, parameter_code, value, unit, "
                    "result) VALUES (gen_random_uuid(), :s, :r, :p, CAST(:v AS numeric), :u, 'ok')"
                ),
                {"s": sess, "r": res, "p": code, "v": value, "u": unit},
            )
    return res


async def test_seed_loader_is_idempotent(owner_db: Database, seeded: None) -> None:
    async with owner_db.transaction(Principal.system()) as conn:
        await load_seed(conn, SEED)
        counts = {
            t: (await conn.execute(text(f"SELECT count(*) FROM {t}"))).scalar_one()  # noqa: S608
            for t in [
                "parameter_definition",
                "reference_standard",
                "response_card",
                "tester_profile",
            ]
        }
    assert counts == {
        "parameter_definition": 42,
        "reference_standard": 2,
        "response_card": 3,
        "tester_profile": 1,
    }


async def test_reference_endpoints_for_users(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    user = await signed_in(client, owner_db, area_codes=(VILLAGE,))
    catalogue = (await client.get("/v1/reference/catalogue", headers=user)).json()
    assert len(catalogue["parameters"]) == 42
    assert {p["code"] for p in catalogue["parameters"] if p["is_core"]} == {
        "temp",
        "ph",
        "ec",
        "tds",
    }
    profiles = (await client.get("/v1/reference/profiles", headers=user)).json()
    assert {p["code"] for p in profiles} == {CLASS_I, CLASS_II}
    assert all(p["provisional"] for p in profiles)
    testers = (await client.get("/v1/reference/tester-profiles", headers=user)).json()
    assert len(testers[0]["parameters"]) == 4
    rules = (await client.get("/v1/reference/config/rules", headers=user)).json()
    assert rules["proximity_max_m"] == 100
    cards = (await client.get("/v1/reference/response-cards", headers=user)).json()
    assert {c["trigger_rule"] for c in cards} == {"unsafe", "ecoli", "baseline_jump"}
    units = (await client.get("/v1/reference/admin-units", headers=user)).json()
    assert VILLAGE in {u["code"] for u in units}
    assert (await client.get("/v1/reference/config/other", headers=user)).status_code == 404
    assert (await client.get("/v1/reference/catalogue")).status_code == 401


async def test_reference_endpoints_for_installations(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    admin = await signed_in(client, owner_db, role="it_admin")
    code = (
        await client.post("/v1/admin/activation-codes", json={"area_code": VILLAGE}, headers=admin)
    ).json()["code"]
    a = (await client.post("/v1/installations/activate", json={"code": code})).json()
    path = "/v1/reference/catalogue"
    r = await client.get(
        path, headers=signed_headers(a["installation_id"], a["secret"], "GET", path)
    )
    assert r.status_code == 200
    assert len(r.json()["parameters"]) == 42


async def test_server_classification_uses_the_session_and_area_default(
    owner_db: Database, seeded: None
) -> None:
    # TDS 800: OK under Class II (the area default), HIGH under Class I.
    result_id = await _test_session(
        owner_db, tds="800", profile_code=CLASS_I, collector_key=uuid.uuid4()
    )
    async with owner_db.transaction(Principal.system()) as conn:
        out = await classify_result(conn, result_id)
        rows = {
            r.standard_id: r
            for r in await conn.execute(
                text(
                    "SELECT c.standard_id, c.overall, c.reading_results, c.limitation_code, s.code "
                    "FROM classification c JOIN reference_standard s ON s.id = c.standard_id "
                    "WHERE c.result_id = :r"
                ),
                {"r": result_id},
            )
        }
    assert [(o.overall, o.is_session_profile) for o in out] == [("unsafe", True), ("safe", False)]
    by_code = {r.code: r for r in rows.values()}
    assert by_code[CLASS_I].overall == "unsafe"
    tds_result = by_code[CLASS_I].reading_results
    assert (json.loads(tds_result) if isinstance(tds_result, str) else tds_result)["tds"] == "high"
    assert by_code[CLASS_II].overall == "safe"
    assert by_code[CLASS_II].limitation_code == "no_germ_test"

    # Re-running replaces, never duplicates.
    async with owner_db.transaction(Principal.system()) as conn:
        await classify_result(conn, result_id)
        n = (
            await conn.execute(
                text("SELECT count(*) FROM classification WHERE result_id = :r"), {"r": result_id}
            )
        ).scalar_one()
    assert n == 2


async def test_area_default_profile_overrides_the_rules_default(
    owner_db: Database, seeded: None
) -> None:
    result_id = await _test_session(
        owner_db, tds="800", profile_code=CLASS_II, collector_key=uuid.uuid4()
    )
    district = await _id(owner_db, "SELECT id FROM admin_unit WHERE code = 'UG-ABIM'")
    class_i = await _id(owner_db, "SELECT id FROM reference_standard WHERE code = :c", c=CLASS_I)
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text("INSERT INTO area_default_profile (admin_unit_id, standard_id) VALUES (:a, :s)"),
            {"a": district, "s": class_i},
        )
        out = await classify_result(conn, result_id)
        await conn.execute(
            text("DELETE FROM area_default_profile WHERE admin_unit_id = :a"), {"a": district}
        )
    assert [(o.overall, o.is_session_profile) for o in out] == [("safe", True), ("unsafe", False)]


async def test_collector_registry_groups_submissions(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    key = uuid.uuid4()
    for tds in ("500", "600"):
        await _test_session(
            owner_db, tds=tds, profile_code=CLASS_II, collector_key=key, name="Registry Collector"
        )
    district_user = await signed_in(client, owner_db, area_codes=("UG-ABIM",))
    rows = (await client.get("/v1/collectors", headers=district_user)).json()
    mine = [r for r in rows if r["collector_key"] == str(key)]
    assert len(mine) == 1
    assert mine[0]["sessions"] == 2
    assert mine[0]["full_name"] == "Registry Collector"

    # Someone with no area sees no collectors at all.
    outsider = await signed_in(client, owner_db)
    assert (await client.get("/v1/collectors", headers=outsider)).json() == []
