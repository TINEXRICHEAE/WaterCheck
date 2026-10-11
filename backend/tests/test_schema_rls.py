"""P4 gate: RLS isolation by area (direct SQL as the API role) and
immutability of insert-only tables."""

import uuid
from typing import Any

import psycopg
import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError

from app.db.database import Database, Principal

U = uuid.uuid4


def _seed(owner: str) -> dict[str, Any]:
    """Two districts (A, B), each with one village and one source with a
    test session; one Collect installation in village A."""
    ids: dict[str, Any] = {
        k: U()
        for k in [
            "country",
            "dist_a",
            "vil_a",
            "dist_b",
            "vil_b",
            "src_a",
            "src_b",
            "inst_a",
            "std",
            "sess_a",
            "sess_b",
            "res_a",
            "res_b",
        ]
    }
    with psycopg.connect(owner, autocommit=True) as c:
        c.execute(
            "INSERT INTO admin_unit (id, level, name, code, parent_id) VALUES "
            "(%(country)s,'country','Uganda','UG-'||%(country)s::text,NULL),"
            "(%(dist_a)s,'district','A','A-'||%(dist_a)s::text,%(country)s),"
            "(%(vil_a)s,'village','VA','VA-'||%(vil_a)s::text,%(dist_a)s),"
            "(%(dist_b)s,'district','B','B-'||%(dist_b)s::text,%(country)s),"
            "(%(vil_b)s,'village','VB','VB-'||%(vil_b)s::text,%(dist_b)s)",
            ids,
        )
        c.execute(
            "INSERT INTO reference_standard (id, code, title, version, document) "
            "VALUES (%(std)s, 'S-'||%(std)s::text, 'Std', 1, '{}')",
            ids,
        )
        c.execute(
            "INSERT INTO installation (id, admin_unit_id, secret_encrypted) "
            "VALUES (%(inst_a)s, %(vil_a)s, 'x')",
            ids,
        )
        for s, v, sess, res in [
            ("src_a", "vil_a", "sess_a", "res_a"),
            ("src_b", "vil_b", "sess_b", "res_b"),
        ]:
            c.execute(
                "INSERT INTO water_source (id, village_id, code, source_type) "
                "VALUES (%s, %s, 'C-1', 'borehole')",
                (ids[s], ids[v]),
            )
            c.execute(
                "INSERT INTO test_session (id, source_id, installation_id, collector_key, "
                "collector_snapshot, reference_standard_id, calibrated, tested_at_device) "
                "VALUES (%s, %s, %s, gen_random_uuid(), '{}', %s, true, now())",
                (ids[sess], ids[s], ids["inst_a"], ids["std"]),
            )
            c.execute(
                "INSERT INTO test_result (id, session_id, overall, standard_id, "
                "created_at_device) VALUES (%s, %s, 'safe', %s, now())",
                (ids[res], ids[sess], ids["std"]),
            )
    return ids


@pytest.fixture(scope="module")
def world(owner_conn_str: str) -> dict[str, Any]:
    return _seed(owner_conn_str)


async def _visible(db: Database, principal: Principal, table: str) -> set[uuid.UUID]:
    async with db.transaction(principal) as conn:
        rows = await conn.execute(text(f"SELECT id FROM {table}"))  # noqa: S608
        return {r[0] for r in rows}


@pytest.mark.parametrize("table", ["water_source", "test_session", "test_result"])
async def test_stakeholder_sees_only_their_district(
    db: Database, world: dict[str, Any], table: str
) -> None:
    a = Principal(kind="user", user_id=U(), role="stakeholder", scope_units=(world["dist_a"],))
    seen = await _visible(db, a, table)
    key = {"water_source": "src", "test_session": "sess", "test_result": "res"}[table]
    assert world[f"{key}_a"] in seen
    assert world[f"{key}_b"] not in seen


async def test_national_scope_sees_everything_below_the_country(
    db: Database, world: dict[str, Any]
) -> None:
    national = Principal(
        kind="user", user_id=U(), role="stakeholder", scope_units=(world["country"],)
    )
    assert {world["src_a"], world["src_b"]} <= await _visible(db, national, "water_source")


async def test_installation_sees_only_its_village(db: Database, world: dict[str, Any]) -> None:
    inst = Principal(
        kind="installation", installation_id=world["inst_a"], scope_units=(world["vil_a"],)
    )
    assert await _visible(db, inst, "water_source") >= {world["src_a"]}
    assert world["src_b"] not in await _visible(db, inst, "water_source")


async def test_no_context_sees_nothing(db: Database, world: dict[str, Any]) -> None:
    nobody = Principal(kind="user", user_id=U(), role="stakeholder")
    assert await _visible(db, nobody, "water_source") == set()
    assert await _visible(db, nobody, "app_user") == set()


async def test_writing_outside_scope_is_refused(db: Database, world: dict[str, Any]) -> None:
    a = Principal(kind="user", user_id=U(), role="stakeholder", scope_units=(world["dist_a"],))
    with pytest.raises(DBAPIError, match="row-level security"):
        async with db.transaction(a) as conn:
            await conn.execute(
                text(
                    "INSERT INTO water_source (id, village_id, code, source_type) "
                    "VALUES (:id, :v, 'X-1', 'tap')"
                ),
                {"id": U(), "v": world["vil_b"]},
            )


async def test_api_role_cannot_bypass_rls(db: Database) -> None:
    async with db.transaction(Principal.auth()) as conn:
        row = (
            await conn.execute(
                text("SELECT rolbypassrls, rolsuper FROM pg_roles WHERE rolname = current_user")
            )
        ).one()
    assert row == (False, False)


async def test_insert_only_tables_reject_update_and_delete(
    db: Database, world: dict[str, Any]
) -> None:
    for statement in [
        "UPDATE test_result SET overall = 'unsafe'",
        "DELETE FROM test_session",
        "DELETE FROM water_source",
    ]:
        # The API role is refused by grants or by the triggers.
        with pytest.raises(DBAPIError, match=r"insert-only|never deleted|permission denied"):
            async with db.transaction(Principal.system()) as conn:
                await conn.execute(text(statement))


def test_triggers_hold_even_for_the_owner(owner_conn_str: str, world: dict[str, Any]) -> None:
    for statement in [
        "UPDATE test_result SET overall = 'unsafe'",
        "DELETE FROM test_session",
        "DELETE FROM water_source",
    ]:
        with psycopg.connect(owner_conn_str) as c, pytest.raises(psycopg.errors.RestrictViolation):
            c.execute(statement)


async def test_every_insert_gets_a_change_sequence(
    owner_conn_str: str, world: dict[str, Any]
) -> None:
    with psycopg.connect(owner_conn_str) as c:
        a = c.execute(
            "SELECT server_seq FROM water_source WHERE id = %s", (world["src_a"],)
        ).fetchone()
        b = c.execute(
            "SELECT server_seq FROM water_source WHERE id = %s", (world["src_b"],)
        ).fetchone()
    assert a is not None and b is not None
    assert b[0] > a[0]
