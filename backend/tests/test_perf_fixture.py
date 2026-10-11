"""The P9 performance fixture loads through the normal push (plan P9)."""

from __future__ import annotations

from sqlalchemy import text

from app.db.database import Database, Principal
from app.services.perf_fixture import load_perf_fixture
from tests.helpers import make_area
from tests.test_sync import seeded

__all__ = ["seeded"]


async def test_fixture_loads_2000_readings_and_is_rerunnable(
    owner_db: Database, seeded: None
) -> None:
    village = await make_area(owner_db)
    async with owner_db.transaction(Principal.system()) as conn:
        r = await load_perf_fixture(conn, village_code=village["code"])
    assert (r.sources, r.tests, r.readings) == (50, 500, 2000)
    assert r.rejected == 0
    assert r.applied == 50 + 500 * 2 + 2000
    async with owner_db.transaction(Principal.system()) as conn:
        counts = (
            await conn.execute(
                text(
                    "SELECT count(DISTINCT s.id), count(DISTINCT t.id), count(r.id), "
                    "count(DISTINCT t.collector_key), count(DISTINCT c.result_id) "
                    "FROM water_source s JOIN test_session t ON t.source_id = s.id "
                    "JOIN reading r ON r.session_id = t.id "
                    "LEFT JOIN classification c ON c.result_id = r.result_id "
                    "WHERE s.village_id = :v"
                ),
                {"v": village["id"]},
            )
        ).one()
        assert tuple(counts) == (50, 500, 2000, 6, 500)
        again = await load_perf_fixture(conn, village_code=village["code"])
    assert again.applied == 0 and again.rejected == 0
