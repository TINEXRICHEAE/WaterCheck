"""P6: sync push and pull (SPEC §8, ADR-011).

Idempotent pushes (resending a batch 3 times creates nothing new),
parents-before-children within a batch, per-record answers, the §8.4
conflict policy, clock flags, scoped pulls and a commit-order-safe cursor.
"""

import gzip
import json
import uuid
from collections.abc import AsyncIterator
from datetime import UTC, datetime, timedelta
from pathlib import Path
from typing import Any

import pytest_asyncio
from httpx2 import ASGITransport, AsyncClient
from sqlalchemy import text

from app.core.config import Settings
from app.db.database import Database, Principal
from app.main import create_app
from app.seed import load_seed
from tests.helpers import make_area, signed_headers, signed_in

SEED = Path(__file__).resolve().parents[2] / "infra" / "seed"
PROFILE = "ba9093d7-4551-54b4-9da1-3c14a7041644"  # US201-2008-ClassII


@pytest_asyncio.fixture
async def seeded(owner_db: Database) -> None:
    async with owner_db.transaction(Principal.system()) as conn:
        await load_seed(conn, SEED)


@pytest_asyncio.fixture
async def client(db: Database) -> AsyncIterator[AsyncClient]:
    app = create_app(Settings(environment="test"))
    app.state.db = db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


class Phone:
    """An activated installation that signs its requests."""

    def __init__(
        self,
        client: AsyncClient,
        installation_id: str,
        secret: str,
        village: str,
        village_code: str = "",
    ):
        self.client = client
        self.id = installation_id
        self.secret = secret
        self.village = village
        self.village_code = village_code
        self.collector = str(uuid.uuid4())

    async def push(self, changes: list[dict[str, Any]], *, compress: bool = False) -> Any:
        body = json.dumps({"batch_id": str(uuid.uuid4()), "changes": changes}).encode()
        headers = {
            "Content-Type": "application/json",
            **signed_headers(
                self.id, self.secret, "POST", "/v1/sync/push", body, nonce=uuid.uuid4().hex
            ),
        }
        if compress:
            body = gzip.compress(body)
            headers["Content-Encoding"] = "gzip"
        r = await self.client.post("/v1/sync/push", content=body, headers=headers)
        assert r.status_code == 200, r.text
        return r.json()

    async def pull(self, stream: str, cursor: str | None = None, limit: int = 500) -> Any:
        query = f"stream={stream}&limit={limit}" + (f"&cursor={cursor}" if cursor else "")
        r = await self.client.get(
            f"/v1/sync/pull?{query}",
            headers=signed_headers(
                self.id, self.secret, "GET", f"/v1/sync/pull?{query}", nonce=uuid.uuid4().hex
            ),
        )
        return r

    def origin(self) -> dict[str, Any]:
        return {
            "installation_id": self.id,
            "collector_key": self.collector,
            "collector_snapshot": json.dumps({"full_name": "Example Collector"}),
        }


async def phone(client: AsyncClient, owner_db: Database, district: dict[str, Any]) -> Phone:
    village = await make_area(owner_db, "village", parent=district["id"])
    admin = await signed_in(client, owner_db, role="it_admin")
    code = (
        await client.post(
            "/v1/admin/activation-codes", json={"area_code": village["code"]}, headers=admin
        )
    ).json()["code"]
    a = (await client.post("/v1/installations/activate", json={"code": code})).json()
    return Phone(client, a["installation_id"], a["secret"], str(village["id"]), village["code"])


async def _second_phone(
    client: AsyncClient, owner_db: Database, village_id: str
) -> tuple[str, str, str]:
    async with owner_db.transaction(Principal.system()) as conn:
        code = (
            await conn.execute(
                text("SELECT code FROM admin_unit WHERE id = :id"), {"id": village_id}
            )
        ).scalar_one()
    admin = await signed_in(client, owner_db, role="it_admin")
    activation_code = (
        await client.post("/v1/admin/activation-codes", json={"area_code": code}, headers=admin)
    ).json()["code"]
    a = (await client.post("/v1/installations/activate", json={"code": activation_code})).json()
    return a["installation_id"], a["secret"], village_id


def visit(p: Phone, *, tested: datetime | None = None, ph: str = "9.4") -> list[dict[str, Any]]:
    """One field visit as Collect queues it: source, session, result,
    readings, alert, a checklist event and an inspection."""
    now = tested or datetime.now(UTC)
    at = now.isoformat()
    src, ses, res, alert = (str(uuid.uuid4()) for _ in range(4))
    o = p.origin()
    return [
        {
            "entity": "water_source",
            "op": "insert",
            "id": src,
            "data": {
                "id": src,
                "village_id": p.village,
                "code": "ENT-001",
                "name": "Main borehole",
                "source_type": "borehole",
                "lat": 2.7,
                "lon": 33.6,
                "location_accuracy_m": 8.0,
                "functional_status": "functional",
                "is_active": True,
                "version": 1,
                "created_at_device": at,
                "updated_at_device": at,
                **o,
            },
        },
        {
            "entity": "test_session",
            "op": "insert",
            "id": ses,
            "data": {
                "id": ses,
                "source_id": src,
                "reference_standard_id": PROFILE,
                "calibrated": False,
                "lat": 2.7,
                "lon": 33.6,
                "tested_at_device": at,
                **o,
            },
        },
        {
            "entity": "test_result",
            "op": "insert",
            "id": res,
            "data": {
                "id": res,
                "session_id": ses,
                "overall": "unsafe",
                "standard_id": PROFILE,
                "flags": '["not_calibrated"]',
                "created_at_device": at,
            },
        },
        *[
            {
                "entity": "reading",
                "op": "insert",
                "id": rid,
                "data": {
                    "id": rid,
                    "session_id": ses,
                    "result_id": res,
                    "parameter_code": code,
                    "value": value,
                    "unit": unit,
                    "result": result,
                },
            }
            for rid, code, value, unit, result in [
                (str(uuid.uuid4()), "ph", ph, "pH", "high"),
                (str(uuid.uuid4()), "tds", "300", "mg/L", "ok"),
            ]
        ],
        {
            "entity": "alert",
            "op": "insert",
            "id": alert,
            "data": {
                "id": alert,
                "source_id": src,
                "trigger_result_id": res,
                "trigger_rule": "unsafe_result",
                "severity": "high",
                "status": "open",
                "opened_at": at,
                **o,
            },
        },
        {
            "entity": "alert_event",
            "op": "insert",
            "id": str(uuid.uuid4()),
            "data": {
                "alert_id": alert,
                "event_type": "action_taken",
                "note": json.dumps({"actions": ["advised_households"]}),
                "occurred_at_device": at,
                **o,
            },
        },
        {
            "entity": "sanitary_inspection",
            "op": "insert",
            "id": str(uuid.uuid4()),
            "data": {
                "source_id": src,
                "answers": json.dumps({"latrine_within_30m": True}),
                "inspected_at_device": at,
                **o,
            },
        },
    ]


async def count(owner_db: Database, table: str, **where: Any) -> int:
    clause = " AND ".join(f"{k} = :{k}" for k in where) or "true"
    async with owner_db.transaction(Principal.system()) as conn:
        n: int = (
            await conn.execute(text(f"SELECT count(*) FROM {table} WHERE {clause}"), where)  # noqa: S608 - test helper
        ).scalar_one()
    return n


async def test_a_visit_syncs_once_even_out_of_order_and_resent(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    changes = visit(p)
    # Children first: the server applies parents before children anyway.
    shuffled = list(reversed(changes))
    first = await p.push(shuffled, compress=True)
    assert {r["status"] for r in first["results"]} == {"applied"}
    assert [r["id"] for r in first["results"]] == [c["id"] for c in shuffled]

    result_id = changes[2]["id"]
    # The server classified the result itself (ADR-005).
    assert await count(owner_db, "classification", result_id=result_id, computed_by="server") >= 1

    # Resending the same batch 3 times changes nothing (P6 gate).
    for _ in range(3):
        again = await p.push(shuffled)
        assert {r["status"] for r in again["results"]} == {"duplicate"}
    assert await count(owner_db, "reading", result_id=result_id) == 2
    assert await count(owner_db, "test_session", id=changes[1]["id"]) == 1


async def test_one_bad_record_does_not_sink_the_batch(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    changes = visit(p)
    changes[3]["data"]["parameter_code"] = "no_such_parameter"
    changes[4]["data"]["result"] = "not_a_result"
    out = {r["id"]: r for r in (await p.push(changes))["results"]}
    assert out[changes[3]["id"]] == {
        "id": changes[3]["id"],
        "entity": "reading",
        "status": "rejected",
        "server_version": None,
        "reason": "missing_parent",
    }
    assert out[changes[4]["id"]]["reason"] == "invalid_value"
    others = [c["id"] for i, c in enumerate(changes) if i not in (3, 4)]
    assert {out[i]["status"] for i in others} == {"applied"}

    # A session without its collector is refused, and so are its children.
    second = visit(p)
    second[0]["data"]["code"] = "ENT-002"
    del second[1]["data"]["collector_key"]
    out = {r["id"]: r for r in (await p.push(second))["results"]}
    assert out[second[1]["id"]]["reason"] == "missing:collector"
    assert out[second[2]["id"]]["reason"] == "missing_parent"
    assert out[second[0]["id"]]["status"] == "applied"
    assert out[second[-1]["id"]]["status"] == "applied"


async def test_records_outside_the_phone_area_are_refused(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    b = await phone(client, owner_db, district)
    source = visit(a)[0]
    source["data"]["village_id"] = b.village
    out = (await a.push([source]))["results"][0]
    assert out["status"] == "rejected"
    assert out["reason"] == "out_of_scope"


async def test_wrong_clocks_are_flagged_not_lost(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    year = timedelta(days=365)
    for skew, flag in ((year, "device_time_in_future"), (-year, "device_time_too_old")):
        changes = visit(p, tested=datetime.now(UTC) + skew)
        changes[0]["data"]["code"] = f"SKEW-{flag}"
        assert {r["status"] for r in (await p.push(changes))["results"]} == {"applied"}
        async with owner_db.transaction(Principal.system()) as conn:
            flags = (
                await conn.execute(
                    text("SELECT clock_flags FROM test_session WHERE id = :id"),
                    {"id": changes[1]["id"]},
                )
            ).scalar_one()
        assert flags == [flag]


async def test_two_devices_edit_one_source(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """Chaos #3: the stale edit keeps the server's status and records a
    conflict; the name is last-writer-wins."""
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    source = visit(a)[0]
    await a.push([source])
    sid = source["id"]

    def edit(base: int, **data: Any) -> dict[str, Any]:
        return {
            "entity": "water_source",
            "op": "update",
            "id": sid,
            "base_version": base,
            "data": {**data, "updated_at_device": datetime.now(UTC).isoformat(), **a.origin()},
        }

    first = (await a.push([edit(1, functional_status="broken")]))["results"][0]
    assert first == {
        "id": sid,
        "entity": "water_source",
        "status": "applied",
        "server_version": 2,
        "reason": None,
    }
    # A second phone still at version 1 says it works and renames it.
    second = (await a.push([edit(1, functional_status="functional", name="New name")]))["results"][
        0
    ]
    assert second["status"] == "conflict"
    assert second["reason"] == "kept_server:functional_status"
    assert second["server_version"] == 3
    async with owner_db.transaction(Principal.system()) as conn:
        row = (
            await conn.execute(
                text("SELECT functional_status, name FROM water_source WHERE id = :id"),
                {"id": sid},
            )
        ).one()
        conflict = (
            await conn.execute(
                text("SELECT server_value, client_value FROM sync_conflict WHERE entity_id = :id"),
                {"id": sid},
            )
        ).one()
    assert tuple(row) == ("broken", "New name")
    assert tuple(conflict) == ("broken", "functional")


async def test_an_edit_in_the_same_batch_follows_its_insert(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    source = visit(p)[0]
    edit = {
        "entity": "water_source",
        "op": "update",
        "id": source["id"],
        "base_version": 1,
        "data": {"functional_status": "broken", **p.origin()},
    }
    out = (await p.push([source, edit]))["results"]
    assert [r["status"] for r in out] == ["applied", "applied"]
    assert out[1]["server_version"] == 2


async def test_same_code_from_two_phones_is_kept_and_renamed(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    one, two = visit(p)[0], visit(p)[0]
    await p.push([one])
    out = (await p.push([two]))["results"][0]
    assert out["status"] == "applied"
    assert out["reason"] == "code_renamed"
    assert await count(owner_db, "water_source", village_id=p.village) == 2


async def test_console_actions_follow_the_alert_state_machine(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    changes = visit(p)
    await p.push(changes)
    alert_id = changes[5]["id"]
    officer = await signed_in(client, owner_db, area_codes=(district["code"],))

    async def act(event_type: str) -> dict[str, Any]:
        r = await client.post(
            "/v1/sync/push",
            json={
                "batch_id": str(uuid.uuid4()),
                "changes": [
                    {
                        "entity": "alert_event",
                        "op": "insert",
                        "id": str(uuid.uuid4()),
                        "data": {"alert_id": alert_id, "event_type": event_type},
                    }
                ],
            },
            headers=officer,
        )
        assert r.status_code == 200, r.text
        result: dict[str, Any] = r.json()["results"][0]
        return result

    assert (await act("closed"))["reason"] == "invalid_transition:open->closed"
    assert (await act("acknowledged"))["status"] == "applied"
    assert (await act("closed"))["status"] == "applied"
    reopened = await act("reopened")
    assert reopened["reason"].startswith("new_alert:")
    new_id = reopened["reason"].removeprefix("new_alert:")
    assert await count(owner_db, "alert", id=new_id, linked_alert_id=alert_id) == 1

    # A user cannot push field records.
    r = await client.post(
        "/v1/sync/push",
        json={"batch_id": str(uuid.uuid4()), "changes": [changes[1]]},
        headers=officer,
    )
    assert r.json()["results"][0]["reason"] == "not_allowed"


async def test_pull_is_scoped_paged_and_resumable(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    await a.push(visit(a))

    # Page through the phone's area three changes at a time.
    seen: list[dict[str, Any]] = []
    cursor = None
    while True:
        r = await a.pull(f"area:{a.village}", cursor, limit=3)
        assert r.status_code == 200, r.text
        page = r.json()
        seen += page["changes"]
        cursor = page["next_cursor"]
        if not page["has_more"]:
            break
    entities = sorted({c["entity"] for c in seen})
    assert entities == [
        "alert",
        "alert_event",
        "classification",
        "reading",
        "sanitary_inspection",
        "test_result",
        "test_session",
        "water_source",
    ]
    source = next(c for c in seen if c["entity"] == "water_source")["data"]
    assert source["lat"] == 2.7
    assert source["collector_snapshot"] == {"full_name": "Example Collector"}
    reading = next(c for c in seen if c["entity"] == "reading")["data"]
    assert isinstance(reading["value"], str)
    # Nothing new: the cursor is stable.
    again = (await a.pull(f"area:{a.village}", cursor)).json()
    assert again["changes"] == []
    assert again["next_cursor"] == cursor

    # A second phone in the same village gets the records but not the other
    # collector's personal details.
    same = Phone(client, *(await _second_phone(client, owner_db, a.village)))
    shared = (await same.pull(f"area:{a.village}")).json()["changes"]
    assert any(c["entity"] == "water_source" for c in shared)
    assert all(c["data"].get("collector_snapshot") is None for c in shared)

    # Another phone in another district sees nothing of it.
    b = await phone(client, owner_db, await make_area(owner_db, "district"))
    assert (await b.pull(f"area:{a.village}")).status_code == 403
    assert (await b.pull("scope")).json()["changes"] == []
    assert (await b.pull("galaxy")).status_code == 400

    # A deactivated source travels as a tombstone.
    src = seen[0]["id"] if seen[0]["entity"] == "water_source" else source["id"]
    await a.push(
        [
            {
                "entity": "water_source",
                "op": "update",
                "id": src,
                "base_version": 1,
                "data": {"is_active": False, **a.origin()},
            }
        ]
    )
    # ...with its edit trail row (ADR-018).
    later = (await a.pull(f"area:{a.village}", cursor)).json()["changes"]
    assert sorted((c["entity"], c["op"]) for c in later) == [
        ("change_trail", "upsert"),
        ("water_source", "tombstone"),
    ]
    trail = next(c for c in later if c["entity"] == "change_trail")
    assert trail["data"]["field"] == "is_active"


async def test_reference_stream(client: AsyncClient, owner_db: Database, seeded: None) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    changes: list[dict[str, Any]] = []
    cursor = None
    while True:
        page = (await p.pull("reference", cursor, limit=1000)).json()
        changes += page["changes"]
        cursor = page["next_cursor"]
        if not page["has_more"]:
            break
    by_entity: dict[str, int] = {}
    for c in changes:
        by_entity[c["entity"]] = by_entity.get(c["entity"], 0) + 1
    assert by_entity["reference_standard"] >= 2
    assert by_entity["parameter_definition"] >= 42
    assert by_entity["config_document"] == 3  # rules, lists, notifications
    assert by_entity["admin_unit"] >= 2
    tester = next(c for c in changes if c["entity"] == "tester_profile")["data"]
    assert isinstance(tester["parameters"], list)


async def test_a_late_commit_is_never_skipped(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """A transaction that took its change number first but commits last
    must still reach a client that pulled in between (ADR-011)."""
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    start = (await p.pull("scope")).json()["next_cursor"]

    slow_id = uuid.uuid4()
    async with owner_db.engine.connect() as slow:
        tx = await slow.begin()
        await slow.execute(
            text(
                "INSERT INTO water_source (id, village_id, code, source_type, server_seq) "
                "VALUES (:id, :v, 'SLOW-1', 'borehole', 0)"
            ),
            {"id": slow_id, "v": p.village},
        )
        # Meanwhile the phone pushes and pulls: the newer row must wait.
        fast = visit(p)[0]
        await p.push([fast])
        mid = (await p.pull("scope", start)).json()
        assert mid["changes"] == []
        assert mid["next_cursor"] == start
        await tx.commit()

    after = (await p.pull("scope", start)).json()["changes"]
    assert {c["id"] for c in after} == {str(slow_id), fast["id"]}
