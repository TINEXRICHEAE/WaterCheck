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

import psycopg
import pytest_asyncio
from httpx2 import ASGITransport, AsyncClient
from sqlalchemy import text

from app.core.config import Settings
from app.db.database import Database, Principal
from app.main import create_app
from app.seed import load_seed
from tests.helpers import NEW_PASSWORD, make_area, signed_headers, signed_in

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
        # The tester profile's side (ADR-031).
        self.side = "water"

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

    async def post(self, path: str, payload: dict[str, Any]) -> Any:
        body = json.dumps(payload).encode()
        return await self.client.post(
            path,
            content=body,
            headers={
                "Content-Type": "application/json",
                **signed_headers(self.id, self.secret, "POST", path, body, nonce=uuid.uuid4().hex),
            },
        )

    async def get(self, path: str) -> Any:
        r = await self.client.get(
            path,
            headers=signed_headers(self.id, self.secret, "GET", path, nonce=uuid.uuid4().hex),
        )
        assert r.status_code == 200, r.text
        return r.json()

    def origin(self) -> dict[str, Any]:
        return {
            "installation_id": self.id,
            "collector_key": self.collector,
            "collector_snapshot": json.dumps(
                {"full_name": "Example Collector"}
                | ({"side": self.side} if self.side != "water" else {})
            ),
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


async def test_a_phone_works_anywhere_in_uganda_and_adds_new_places(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """ADR-019: a phone activated in one district records a source in
    another, below a parish and village it adds; both are marked new."""
    async with owner_db.transaction(Principal.system()) as conn:
        abim = (
            await conn.execute(text("SELECT id FROM admin_unit WHERE code = 'UG-ABIM'"))
        ).scalar_one()
        butagaya = (
            await conn.execute(
                text(
                    "SELECT s.id, s.code FROM admin_unit s JOIN admin_unit d ON d.id = s.parent_id "
                    "WHERE s.name = 'Butagaya' AND d.name = 'Jinja'"
                )
            )
        ).one()
    a = await phone(client, owner_db, {"id": abim})
    parish, village = str(uuid.uuid4()), str(uuid.uuid4())
    places = [
        {
            "entity": "admin_unit",
            "op": "insert",
            "id": pid,
            "data": {
                "level": level,
                "name": name,
                "code": f"{butagaya.code}-{name.upper()[:6]}",
                "parent_id": parent,
                **a.origin(),
            },
        }
        for pid, level, name, parent in [
            (parish, "parish", "Nawangoma", str(butagaya.id)),
            (village, "village", "Kitanaba", parish),
        ]
    ]
    source = visit(a)[0]
    source["data"]["village_id"] = village
    # The source comes first in the batch; places are applied before it.
    out = (await a.push([source, *places]))["results"]
    assert [r["status"] for r in out] == ["applied", "applied", "applied"], out
    assert await count(owner_db, "admin_unit", id=uuid.UUID(village), review_status="new") == 1
    # The other district can be read too.
    jinja = (await a.pull(f"area:{butagaya.id}")).json()["changes"]
    assert [c["entity"] for c in jinja] == ["water_source"]
    # The IT admin sees the new places for review, with where they sit and
    # who added them, and accepts one; the device lists its collector.
    admin = await signed_in(client, owner_db, role="it_admin")
    new = (await client.get("/v1/admin/areas/new", headers=admin)).json()
    added = {n["name"]: n for n in new}
    assert added["Kitanaba"]["path"] == "Jinja, Butagaya, Nawangoma"
    assert added["Kitanaba"]["added_by"] == "Example Collector"
    assert added["Kitanaba"]["sources"] == 1
    r = await client.post(f"/v1/admin/areas/{village}/official", headers=admin)
    assert r.status_code == 204
    names = {n["name"] for n in (await client.get("/v1/admin/areas/new", headers=admin)).json()}
    assert "Kitanaba" not in names
    people = (await client.get(f"/v1/admin/installations/{a.id}/collectors", headers=admin)).json()
    assert [(c["full_name"], c["sources"]) for c in people] == [("Example Collector", 1)]
    # Found by search from anywhere, with its district to sync.
    hits = await a.get("/v1/sources/search?q=" + source["data"]["code"][:6])
    hit = next(h for h in hits if h["id"] == source["id"])
    assert hit["village"] == "Kitanaba"
    assert hit["district"] == "Jinja"
    assert hit["latest"] is None
    assert await a.get("/v1/sources/search?q=%25") == []
    # A place must sit below a known one, one level down.
    bad: dict[str, Any] = {
        **places[1],
        "id": str(uuid.uuid4()),
        "data": {**places[1]["data"], "parent_id": str(abim), "code": "X-1"},  # type: ignore[dict-item]
    }
    assert (await a.push([bad]))["results"][0]["reason"] == "invalid_value"


async def test_records_outside_the_area_list_are_refused(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    # Test areas outside Uganda's tree: neither phone's scope covers the
    # other's (in production every area is under Uganda).
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
    # (A phone may read all of Uganda, ADR-019; test areas sit outside it.)
    ours = {c["id"] for c in seen}
    assert not [c for c in (await b.pull("scope")).json()["changes"] if c["id"] in ours]
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


async def test_a_collector_gets_back_in_on_another_phone_with_a_code(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """ADR-020: an IT admin issues a one-time code; on another phone the
    collector comes back with the same key and details."""
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    b = await phone(client, owner_db, district)
    await a.push(visit(a))
    admin = await signed_in(client, owner_db, role="it_admin")
    r = await client.post(f"/v1/collectors/{a.collector}/recovery-code", headers=admin)
    assert r.status_code == 201, r.text
    issued = r.json()
    assert issued["full_name"] == "Example Collector"
    assert len(issued["code"]) == 11 and issued["code"][5] == "-"

    # Typed in lower case without the dash: still the same code.
    r = await b.post("/v1/collectors/recover", {"code": issued["code"].replace("-", "").lower()})
    assert r.status_code == 200, r.text
    back = r.json()
    assert back["collector_key"] == a.collector
    assert back["snapshot"]["full_name"] == "Example Collector"
    # Once only.
    again = await b.post("/v1/collectors/recover", {"code": issued["code"]})
    assert again.status_code == 404
    assert await count(owner_db, "audit_log", action="collector.recovered") == 1

    # Any water user may (areas no longer limit, ADR-031); a research
    # account may not, for a water tester.
    water = await signed_in(client, owner_db)
    r = await client.post(f"/v1/collectors/{a.collector}/recovery-code", headers=water)
    assert r.status_code == 201, r.text
    other = await signed_in(client, owner_db, side="research")
    r = await client.post(f"/v1/collectors/{a.collector}/recovery-code", headers=other)
    assert r.status_code == 403


async def test_the_credentials_ledger_shows_codes_devices_and_accounts(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """ADR-022: every activation code with the devices that used it, every
    account with whether it was used; a code can be withdrawn."""
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    admin = await signed_in(client, owner_db, role="it_admin")
    ledger = (await client.get("/v1/admin/credentials", headers=admin)).json()
    code = next(c for c in ledger["codes"] if any(d["id"] == a.id for d in c["devices"]))
    assert code["used_count"] == 1
    assert code["created_by"]
    me = next(u for u in ledger["accounts"] if u["role"] == "it_admin" and u["first_sign_in_done"])
    assert me["last_sign_in_at"]
    r = await client.post(f"/v1/admin/activation-codes/{code['id']}/revoke", headers=admin)
    assert r.status_code == 204
    again = await client.post(f"/v1/admin/activation-codes/{code['id']}/revoke", headers=admin)
    assert again.status_code == 404


async def test_only_the_author_removes_a_picture_and_a_test_keeps_its_no_photo_reason(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """ADR-022: a picture records who added it; only they can remove it
    (it is kept, marked); a test can say why it has no picture."""
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    changes = visit(a)
    session = next(c for c in changes if c["entity"] == "test_session")
    session["data"]["no_photo_reason"] = "Camera not working"
    picture: dict[str, Any] = {
        "entity": "attachment",
        "op": "insert",
        "id": str(uuid.uuid4()),
        "data": {
            "owner_type": "test_session",
            "owner_id": session["id"],
            "sha256": "a" * 64,
            "bytes": 1000,
            "mime": "image/jpeg",
            # Where and when it was taken (ADR-029).
            "taken_lat": 0.4512,
            "taken_lon": 33.2041,
            "taken_accuracy_m": 6.5,
            "taken_altitude_m": 1143.0,
            "taken_speed_mps": 0.0,
            "taken_heading_deg": 271.0,
            "taken_at": "2026-10-25T08:30:00Z",
            **a.origin(),
        },
    }
    half = {**picture, "id": str(uuid.uuid4())}
    half["data"] = {**picture["data"], "taken_lon": None}
    out = (await a.push([*changes, picture, half]))["results"]
    assert [r["status"] for r in out[:-1]] == ["applied"] * len(changes) + ["applied"], out
    assert out[-1]["reason"] == "invalid:taken_lat"
    remove = {"entity": "attachment", "op": "update", "id": picture["id"]}
    # Someone else on the device cannot remove it.
    other = {**a.origin(), "collector_key": str(uuid.uuid4())}
    refused = (await a.push([{**remove, "data": {"removed": True, **other}}]))["results"][0]
    assert refused["reason"] == "not_creator"
    done = (await a.push([{**remove, "data": {"removed": True, **a.origin()}}]))["results"][0]
    assert done["status"] == "applied"
    pulled = (await a.pull(f"area:{a.village}")).json()["changes"]
    pic = next(c for c in pulled if c["entity"] == "attachment")
    assert pic["data"]["removed_at"]
    assert (pic["data"]["taken_lat"], pic["data"]["taken_altitude_m"]) == (0.4512, 1143.0)
    assert pic["data"]["taken_at"].startswith("2026-10-25T08:30:00")
    ses = next(c for c in pulled if c["entity"] == "test_session")
    assert ses["data"]["no_photo_reason"] == "Camera not working"


async def test_a_typed_other_value_is_listed_until_the_admin_adds_it(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """ADR-022: "Other" means type it. The typed value is stored as it is,
    listed for the IT admin, and once added it is in the shared list
    (before "Other") that devices pull, and no longer listed."""
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    changes = visit(a)
    source = next(c for c in changes if c["entity"] == "water_source")
    source["data"]["source_type"] = "Hand-dug well"
    out = (await a.push(changes))["results"]
    assert all(r["status"] == "applied" for r in out), out
    admin = await signed_in(client, owner_db, role="it_admin")
    typed = (await client.get("/v1/admin/typed-values", headers=admin)).json()
    assert {"list": "source_types", "value": "Hand-dug well"}.items() <= next(
        t for t in typed if t["value"] == "Hand-dug well"
    ).items()
    assert not any(t["value"] == "borehole" for t in typed)
    r = await client.post(
        "/v1/admin/typed-values",
        json={"list": "source_types", "value": "Hand-dug well"},
        headers=admin,
    )
    assert r.status_code == 204
    typed = (await client.get("/v1/admin/typed-values", headers=admin)).json()
    assert not any(t["value"] == "Hand-dug well" for t in typed)
    lists = (await client.get("/v1/reference/config/lists", headers=admin)).json()
    codes = [i["code"] for i in lists["source_types"]]
    assert codes.index("Hand-dug well") == codes.index("other") - 1


async def test_threads_on_a_test_and_a_source_reach_both_sides(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """ADR-022: a collector writes on their test, a Console user answers on
    the source; both reach the area's devices and the Console, with who
    wrote. Unknown subjects and empty messages are refused."""
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    changes = visit(a)
    out = (await a.push(changes))["results"]
    assert all(r["status"] == "applied" for r in out), out
    session = next(c for c in changes if c["entity"] == "test_session")
    source = next(c for c in changes if c["entity"] == "water_source")

    def message(kind: str, subject: str, body: str, origin: dict[str, Any]) -> dict[str, Any]:
        return {
            "entity": "message",
            "op": "insert",
            "id": str(uuid.uuid4()),
            "data": {"subject_type": kind, "subject_id": subject, "body": body, **origin},
        }

    asked = message("test", session["id"], "The strip looked faded.", a.origin())
    bad = message("test", str(uuid.uuid4()), "Lost?", a.origin())
    empty = message("source", source["id"], "   ", a.origin())
    res = (await a.push([asked, bad, empty]))["results"]
    assert [r["status"] for r in res] == ["applied", "rejected", "rejected"]
    assert res[1]["reason"] == "not_found"
    assert res[2]["reason"] == "invalid_body"

    admin = await signed_in(client, owner_db, role="it_admin")
    reply = message("source", source["id"], "Please test again tomorrow.", {})
    r = await client.post(
        "/v1/sync/push",
        json={"batch_id": str(uuid.uuid4()), "changes": [reply]},
        headers=admin,
    )
    assert r.json()["results"][0]["status"] == "applied", r.text

    pulled = (await a.pull(f"area:{a.village}")).json()["changes"]
    got = {c["id"]: c["data"] for c in pulled if c["entity"] == "message"}
    assert got[asked["id"]]["body"] == "The strip looked faded."
    assert got[asked["id"]]["author_name"] == "Example Collector"
    assert got[reply["id"]]["subject_type"] == "source"
    assert got[reply["id"]]["author_name"] == "Officer"
    assert got[reply["id"]]["author_user_id"]


async def test_map_places_are_found_by_name_and_placed_in_their_subcounty(
    client: AsyncClient, owner_db: Database, owner_conn_str: str, seeded: None, tmp_path: Path
) -> None:
    """ADR-023: names from the map, loaded once per build, are suggested
    with their sub-county and district; a point is located in its
    sub-county; devices get the names of the districts they hold."""
    from app.places_load import load

    async with owner_db.transaction(Principal.system()) as conn:
        country = (
            await conn.execute(text("SELECT id FROM admin_unit WHERE level = 'country' LIMIT 1"))
        ).scalar_one()
    # Under the country, as every real district: a device may pull it.
    district = await make_area(owner_db, "district", parent=country)
    sub = await make_area(owner_db, "subcounty", parent=district["id"])
    pcode = f"UGT{uuid.uuid4().hex[:8]}"
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text("UPDATE admin_unit SET pcode = :p, name = 'Test Sub' WHERE id = :id"),
            {"p": pcode, "id": sub["id"]},
        )
    # A small square in the far north-east, away from other tests' places.
    jitter = uuid.uuid4().int % 1000 / 100_000
    lat0, lon0 = 4.1 + jitter, 34.9 + jitter
    square = [[lon0, lat0], [lon0 + 0.01, lat0], [lon0 + 0.01, lat0 + 0.01], [lon0, lat0 + 0.01]]
    (tmp_path / "subcounties.geojson").write_text(
        json.dumps(
            {
                "features": [
                    {
                        "properties": {"pcode": pcode},
                        "geometry": {"type": "Polygon", "coordinates": [[*square, square[0]]]},
                    }
                ]
            }
        )
    )
    osm = 10**12 + uuid.uuid4().int % 10**12
    (tmp_path / "places.json").write_text(
        json.dumps(
            {
                "places": [
                    {
                        "osm_id": osm + i,
                        "name": name,
                        "kind": kind,
                        "lat": lat0 + 0.005,
                        "lon": lon0 + 0.002 * (i + 1),
                        "subcounty_pcode": pcode,
                    }
                    for i, (name, kind) in enumerate(
                        [("Kabojjatest", "village"), ("Kabojjatest Trading Centre", "locality")]
                    )
                ]
            }
        )
    )
    with psycopg.connect(owner_conn_str) as pg:
        assert "2 map places (2 new or changed)" in load(pg, tmp_path)
    with psycopg.connect(owner_conn_str) as pg:
        assert load(pg, tmp_path) == "places: already loaded"

    a = await phone(client, owner_db, district)
    hits = await a.get(f"/v1/places/search?q=kabojjatest&near_lat={lat0}&near_lon={lon0}")
    assert [h["name"] for h in hits] == ["Kabojjatest", "Kabojjatest Trading Centre"]
    assert hits[0]["subcounty"] == "Test Sub"
    assert hits[0]["district_id"] == str(district["id"])
    assert hits[0]["source"] == "map"
    # A parish and village (as added from a phone) come with their
    # sub-county and district, so any device can place them.
    parish = await make_area(owner_db, "parish", parent=sub["id"])
    village = await make_area(owner_db, "village", parent=parish["id"])
    for area in (parish, village):
        found = await a.get(f"/v1/places/search?q={area['code'].lower()}")
        assert [(h["source"], h["subcounty"], h["district_id"]) for h in found] == [
            ("official", "Test Sub", str(district["id"]))
        ]

    admin = await signed_in(client, owner_db, role="it_admin")
    at = await client.get(
        "/v1/places/locate", params={"lat": lat0 + 0.004, "lon": lon0 + 0.004}, headers=admin
    )
    assert at.json()["subcounty_id"] == str(sub["id"])
    away = await client.get("/v1/places/locate", params={"lat": 51.5, "lon": 0.1}, headers=admin)
    assert away.status_code == 404

    pulled = (await a.pull(f"area:{district['id']}")).json()["changes"]
    names = {c["data"]["name"] for c in pulled if c["entity"] == "place_name"}
    assert names == {"Kabojjatest", "Kabojjatest Trading Centre"}

    # ADR-028: a place added from the map is put in its sub-county by the
    # server and found by everyone, with who added it.
    added = str(uuid.uuid4())

    def place(pid: str, lat: float, lon: float, kind: str = "trading_centre") -> dict[str, Any]:
        return {
            "entity": "place_name",
            "op": "insert",
            "id": pid,
            "data": {
                "name": "  Kabojjatest   Market ",
                "kind": kind,
                "lat": lat,
                "lon": lon,
                **a.origin(),
            },
        }

    out = (
        await a.push(
            [
                place(added, lat0 + 0.006, lon0 + 0.006),
                place(str(uuid.uuid4()), 51.5, 0.1),
                place(str(uuid.uuid4()), lat0 + 0.006, lon0 + 0.006, kind="castle"),
            ]
        )
    )["results"]
    assert [r["status"] for r in out] == ["applied", "rejected", "rejected"]
    assert [r["reason"] for r in out[1:]] == ["outside_uganda", "invalid_value"]
    again = (await a.push([place(added, lat0 + 0.006, lon0 + 0.006)]))["results"][0]
    assert again["status"] == "duplicate"
    hits = await a.get("/v1/places/search?q=kabojjatest%20market")
    assert [(h["name"], h["source"], h["added_by"], h["subcounty"]) for h in hits] == [
        ("Kabojjatest Market", "added", "Example Collector", "Test Sub")
    ]
    pulled = (await a.pull(f"area:{district['id']}")).json()["changes"]
    mine = next(c for c in pulled if c["id"] == added)
    assert mine["data"]["added_by_name"] == "Example Collector"
    assert mine["data"]["removed_at"] is None

    # An IT admin renames or removes an added place; names from the map
    # are corrected at the source.
    stakeholder = await signed_in(client, owner_db, role="stakeholder")
    r = await client.patch(f"/v1/places/{added}", json={"name": "X"}, headers=stakeholder)
    assert r.status_code == 403
    r = await client.patch(f"/v1/places/{added}", json={"name": "Kabojja Market"}, headers=admin)
    assert r.status_code == 204, r.text
    from_map = await a.get("/v1/places/search?q=kabojjatest%20trading")
    r = await client.delete(f"/v1/places/{from_map[0]['id']}", headers=admin)
    assert r.status_code == 409
    r = await client.delete(f"/v1/places/{added}", headers=admin)
    assert r.status_code == 204
    assert await a.get("/v1/places/search?q=kabojja%20market") == []
    pulled = (await a.pull(f"area:{district['id']}")).json()["changes"]
    gone = next(c for c in pulled if c["id"] == added)
    assert gone["data"]["name"] == "Kabojja Market" and gone["data"]["removed_at"]


async def _registered(client: AsyncClient, village: str) -> Phone:
    r = await client.post(
        "/v1/installations/register", json={"platform": "web", "device_label": "Test device"}
    )
    assert r.status_code == 201, r.text
    return Phone(client, r.json()["installation_id"], r.json()["secret"], village)


async def test_a_tester_on_any_device_is_assigned_and_signs_in_elsewhere(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """ADR-024: a device registers itself and works at once; an assignment
    code puts the tester (not the device) in an area; the tester's own code
    signs them in on another device, recorded; signing a device out needs
    the code an IT admin sees, and then that device's records for them are
    refused."""
    async with owner_db.transaction(Principal.system()) as conn:
        country = (
            await conn.execute(text("SELECT id FROM admin_unit WHERE level = 'country' LIMIT 1"))
        ).scalar_one()
    district = await make_area(owner_db, "district", parent=country)
    village = await make_area(owner_db, "village", parent=district["id"])
    a = await _registered(client, str(village["id"]))
    me = await a.get("/v1/installations/me")
    assert me["area"] is None
    out = (await a.push(visit(a)))["results"]
    assert all(r["status"] == "applied" for r in out), out
    pulled = (await a.pull(f"area:{district['id']}")).json()["changes"]
    assert any(c["entity"] == "water_source" for c in pulled)

    admin = await signed_in(client, owner_db, role="it_admin")
    code = (
        await client.post(
            "/v1/admin/activation-codes",
            json={"area_code": district["code"], "max_installations": 3},
            headers=admin,
        )
    ).json()["code"]
    key = a.collector
    assigned = (await a.post(f"/v1/collectors/{key}/assign", {"code": code})).json()
    assert [x["area_id"] for x in assigned] == [str(district["id"])]
    again = (await a.post(f"/v1/collectors/{key}/assign", {"code": code})).json()
    assert len(again) == 1, "assigned once"

    own = await a.post(f"/v1/collectors/{key}/recovery-code/own", {})
    assert own.status_code == 201, own.text
    b = await _registered(client, str(village["id"]))
    back = await b.post("/v1/collectors/recover", {"code": own.json()["code"]})
    assert back.json()["collector_key"] == key
    reused = await b.post("/v1/collectors/recover", {"code": own.json()["code"]})
    assert reused.status_code == 404

    devices = await a.get(f"/v1/collectors/{key}/devices")
    assert {d["installation_id"] for d in devices} == {a.id, b.id}
    assert next(d for d in devices if d["installation_id"] == b.id)["signed_in_via"] == "own_code"
    req = (
        await a.post(f"/v1/collectors/{key}/devices/sign-out", {"installation_ids": [b.id]})
    ).json()
    access = (await client.get(f"/v1/admin/collectors/{key}/access", headers=admin)).json()
    assert [s["via"] for s in access["sign_ins"]] == ["own_code"]
    pending = next(p for p in access["pending"] if p["id"] == req["request_id"])
    confirm = f"/v1/collectors/{key}/devices/sign-out/{req['request_id']}/confirm"
    wrong = "000000" if pending["code"] != "000000" else "111111"
    assert (await a.post(confirm, {"code": wrong})).status_code == 400
    done = await a.post(confirm, {"code": pending["code"]})
    assert done.json()["signed_out"] == 1

    b.collector = key
    refused = (await b.push(visit(b)))["results"]
    # The source is refused for the tester; what hangs off it with it.
    assert all(r["status"] == "rejected" for r in refused)
    assert refused[0]["reason"] == "collector_signed_out"


async def test_people_manage_their_own_profiles(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """ADR-025: a Console user edits their details; a new phone waits for a
    code an IT admin sees; an area change is a request the admin decides;
    closing the account stops sign-in. A tester confirms a phone, signs out
    of a device and deletes their profile; their records are then refused."""
    async with owner_db.transaction(Principal.system()) as conn:
        country = (
            await conn.execute(text("SELECT id FROM admin_unit WHERE level = 'country' LIMIT 1"))
        ).scalar_one()
    district = await make_area(owner_db, "district", parent=country)
    village = await make_area(owner_db, "village", parent=district["id"])
    admin = await signed_in(client, owner_db, role="it_admin")
    me = await signed_in(client, owner_db, role="stakeholder")

    r = await client.put(
        "/v1/me/profile",
        json={"full_name": "Grace  Atim", "organisation": "DHO", "position": "Inspector"},
        headers=me,
    )
    assert r.status_code == 204
    assert (await client.get("/v1/me", headers=me)).json()["full_name"] == "Grace Atim"
    assert (await client.get("/v1/me", headers=me)).json()["legal_version"] == 0
    assert (await client.post("/v1/me/legal", json={"version": 2}, headers=me)).status_code == 204
    assert (await client.get("/v1/me", headers=me)).json()["legal_version"] == 2
    bad = await client.post(
        "/v1/me/contacts", json={"channel": "phone", "value": "123"}, headers=me
    )
    assert bad.status_code == 422
    pending = (
        await client.post(
            "/v1/me/contacts", json={"channel": "phone", "value": "0772 123456"}, headers=me
        )
    ).json()
    profile = (await client.get("/v1/me", headers=me)).json()
    assert profile["phone"] == "+256772123456"
    assert profile["phone_confirmed"] is False
    codes = (await client.get("/v1/admin/codes-to-pass", headers=admin)).json()
    code = next(c for c in codes if c["id"] == pending["id"])
    assert code["kind"] == "contact"
    assert code["who"] == "Grace Atim"
    confirm = f"/v1/me/contacts/{pending['id']}/confirm"
    wrong_code = "000000" if code["code"] != "000000" else "111111"
    assert (await client.post(confirm, json={"code": wrong_code}, headers=me)).status_code == 400
    done = await client.post(confirm, json={"code": code["code"]}, headers=me)
    assert done.status_code == 204, done.text
    assert (await client.get("/v1/me", headers=me)).json()["phone_confirmed"] is True

    asked = await client.post(
        "/v1/me/area-requests",
        json={"area_ids": [str(district["id"])], "reason": "I cover this district"},
        headers=me,
    )
    assert asked.status_code == 201, asked.text
    open_ = (await client.get("/v1/admin/area-requests", headers=admin)).json()
    req = next(x for x in open_ if x["full_name"] == "Grace Atim")
    decided = await client.post(
        f"/v1/admin/area-requests/{req['id']}/decide", json={"approve": True}, headers=admin
    )
    assert decided.status_code == 200
    areas = (await client.get("/v1/me", headers=me)).json()["areas"]
    assert [a["id"] for a in areas] == [str(district["id"])]

    wrong = await client.post("/v1/me/close", json={"password": "nope"}, headers=me)
    assert wrong.status_code == 401
    closed = await client.post("/v1/me/close", json={"password": NEW_PASSWORD}, headers=me)
    assert closed.status_code == 204
    # Sessions end and sign-in is refused (an access token already given
    # lapses within its 15 minutes).
    username = profile["username"]
    again = await client.post(
        "/v1/auth/login", json={"username": username, "password": NEW_PASSWORD}
    )
    assert again.status_code == 401

    # A tester on a device.
    a = await _registered(client, str(village["id"]))
    assert all(r["status"] == "applied" for r in (await a.push(visit(a)))["results"])
    key = a.collector
    tester = (
        await a.post(f"/v1/collectors/{key}/contacts", {"channel": "email", "value": "t@x.org"})
    ).json()
    codes = (await client.get("/v1/admin/codes-to-pass", headers=admin)).json()
    tcode = next(c for c in codes if c["id"] == tester["id"])["code"]
    ok = await a.post(f"/v1/collectors/{key}/contacts/{tester['id']}/confirm", {"code": tcode})
    assert ok.status_code == 204
    assert (await a.get(f"/v1/collectors/{key}/contacts/status"))["email"] == "t@x.org"
    gone = await a.post(f"/v1/collectors/{key}/close", {})
    assert gone.status_code == 204
    refused = (await a.push(visit(a)))["results"]
    assert refused[0]["reason"] == "collector_signed_out"


async def test_research_records_sync_with_their_point_and_stay_with_the_team(
    client: AsyncClient, owner_db: Database, owner_conn_str: str, seeded: None
) -> None:
    """ADR-030 R1: the sample project's forms reach phones; a record keeps
    where and when the interview was; a number used twice is kept and
    flagged; another device does not see it; the project's managers (here
    an IT admin) read projects, records, pictures and points; others do not."""
    from app.research.seed import load

    with psycopg.connect(owner_conn_str) as pg:
        load(pg)
    with psycopg.connect(owner_conn_str) as pg:
        assert load(pg) == "research samples: up to date"

    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    pulled = (await a.pull("research")).json()["changes"]
    forms = {c["data"]["code"]: c["data"] for c in pulled if c["entity"] == "research_form"}
    assert set(forms) >= {"LOG", "HQ", "OC"}
    # The phone needs the project too: it lists forms under it.
    assert "ENT" in {c["data"]["code"] for c in pulled if c["entity"] == "research_project"}
    versions = [c for c in pulled if c["entity"] == "research_form_version"]
    hq = forms["HQ"]
    definition = next(v["data"]["definition"] for v in versions if v["data"]["form_id"] == hq["id"])
    assert definition["settings"]["number_label"] == "Household code"

    def record(number: str) -> dict[str, Any]:
        return {
            "entity": "research_record",
            "op": "insert",
            "id": str(uuid.uuid4()),
            "data": {
                "form_id": hq["id"],
                "form_version": hq["current_version"],
                "number": number,
                "started_at": "2026-11-10T08:00:00Z",
                "finished_at": "2026-11-10T08:16:00Z",
                "lat": 2.7019,
                "lon": 33.6531,
                "accuracy_m": 6.0,
                "answers": {"consent": "yes", "A2": 2, "B2": ["boiling"]},
                **a.origin(),
            },
        }

    first, second = record("H-001"), record(" H-001 ")
    picture = {
        "entity": "attachment",
        "op": "insert",
        "id": str(uuid.uuid4()),
        "data": {
            "owner_type": "research_record",
            "owner_id": first["id"],
            "field_name": "H_photo",
            "sha256": "b" * 64,
            "bytes": 2000,
            "mime": "image/jpeg",
            **a.origin(),
        },
    }
    bad = record("H-002")
    bad["data"]["form_version"] = 99
    out = (await a.push([first, second, picture, bad]))["results"]
    assert [(r["status"], r.get("reason")) for r in out] == [
        ("applied", None),
        ("applied", "number_clash"),
        ("applied", None),
        ("rejected", "unknown_version"),
    ]
    again = (await a.push([first]))["results"][0]
    assert again["status"] == "duplicate"

    mine = (await a.pull("research")).json()["changes"]
    numbers = sorted(c["data"]["number"] for c in mine if c["entity"] == "research_record")
    assert numbers == ["H-001", "H-001"]
    assert any(c["entity"] == "attachment" for c in mine)

    # Another device sees the forms, not these records.
    b = await phone(client, owner_db, await make_area(owner_db, "district"))
    theirs = (await b.pull("research")).json()["changes"]
    assert not [c for c in theirs if c["entity"] == "research_record"]

    admin = await signed_in(client, owner_db, role="it_admin")
    projects = (await client.get("/v1/research/projects", headers=admin)).json()
    ent = next(p for p in projects if p["code"] == "ENT")
    assert ent["forms"] == 3 and ent["records"] >= 2
    listed = (
        await client.get(
            f"/v1/research/forms/{hq['id']}/records", params={"q": "h-001"}, headers=admin
        )
    ).json()
    assert listed["total"] >= 2
    row = next(r for r in listed["items"] if r["id"] == first["id"])
    assert (row["number"], row["collector"], row["declined"]) == (
        "H-001",
        "Example Collector",
        False,
    )
    detail = (await client.get(f"/v1/research/records/{first['id']}", headers=admin)).json()
    assert detail["answers"]["B2"] == ["boiling"]
    assert detail["definition"]["title"] == "Household Questionnaire"
    assert [p["field_name"] for p in detail["pictures"]] == ["H_photo"]
    points = (await client.get(f"/v1/research/projects/{ent['id']}/points", headers=admin)).json()
    assert any(p["number"] == "H-001" and p["lat"] == 2.7019 for p in points)
    form = (await client.get(f"/v1/research/forms/{hq['id']}", headers=admin)).json()
    assert form["definition"]["fields"][1]["type"] == "consent"

    # A water account has no research pages; a research account outside
    # the project sees none of it.
    water = await signed_in(client, owner_db, role="stakeholder")
    r = await client.get("/v1/research/projects", headers=water)
    assert (r.status_code, r.json()["detail"]) == (403, "research_accounts_only")
    other = await signed_in(client, owner_db, role="stakeholder", side="research")
    assert not [
        p
        for p in (await client.get("/v1/research/projects", headers=other)).json()
        if p["code"] == "ENT"
    ]
    r = await client.get(f"/v1/research/records/{first['id']}", headers=other)
    assert r.status_code == 404
