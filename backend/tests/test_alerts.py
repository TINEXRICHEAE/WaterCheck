"""P8: server alerts, notifications, escalation and the SMS fallback
(SPEC §4.7, §8.5, F-ALR-1/3/4, ADR-013)."""

import json
import uuid
from collections.abc import AsyncIterator
from datetime import UTC, datetime, timedelta
from typing import Any
from urllib.parse import urlencode

import pytest_asyncio
from httpx2 import ASGITransport, AsyncClient
from pydantic import SecretStr
from sqlalchemy import text

from app.core.config import Settings
from app.db.database import Database, Principal
from app.main import create_app
from app.services.alerts import alert_id
from app.services.channels import Channels, FakeSender
from app.services.sms import sms_code
from app.services.users import NewUser, create_user
from app.worker import Worker
from tests.helpers import NEW_PASSWORD, make_area, signed_headers
from tests.test_sync import Phone, phone, seeded, visit

__all__ = ["seeded"]
TOKEN = "test-webhook-token-0123456789"  # noqa: S105 - test-only token


@pytest_asyncio.fixture
async def client(db: Database) -> AsyncIterator[AsyncClient]:
    app = create_app(Settings(environment="test", sms_webhook_token=SecretStr(TOKEN)))
    app.state.db = db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


@pytest_asyncio.fixture
async def channels() -> Channels:
    return Channels(email=FakeSender("email"), push=FakeSender("push"), sms=FakeSender("sms"))


async def person(
    client: AsyncClient,
    owner_db: Database,
    *,
    areas: tuple[str, ...] = (),
    responsibilities: tuple[str, ...] = ("water",),
    role: str = "stakeholder",
    phone_number: str | None = None,
) -> tuple[uuid.UUID, dict[str, str], str]:
    username = f"p-{uuid.uuid4().hex[:8]}@example.org"
    async with owner_db.transaction(Principal.system()) as conn:
        made = await create_user(
            conn,
            NewUser(
                username=username,
                full_name="Officer",
                role=role,
                area_codes=areas,
                responsibilities=responsibilities,
                phone=phone_number,
            ),
        )
    first = await client.post(
        "/v1/auth/login", json={"username": username, "password": made.temporary_password}
    )
    changed = await client.post(
        "/v1/auth/change-password",
        json={"current_password": made.temporary_password, "new_password": NEW_PASSWORD},
        headers={"Authorization": f"Bearer {first.json()['access_token']}"},
    )
    return made.id, {"Authorization": f"Bearer {changed.json()['access_token']}"}, username


async def rows(owner_db: Database, sql: str, **params: Any) -> list[Any]:
    async with owner_db.transaction(Principal.system()) as conn:
        return list(await conn.execute(text(sql), params))


def unsafe_visit(p: Phone, *, with_alert: bool = False) -> list[dict[str, Any]]:
    changes = visit(p)
    changes[0]["data"]["code"] = f"S-{uuid.uuid4().hex[:6].upper()}"
    if not with_alert:
        changes = [c for c in changes if c["entity"] not in ("alert", "alert_event")]
    return changes


async def act(client: AsyncClient, headers: dict[str, str], aid: uuid.UUID, kind: str) -> Any:
    r = await client.post(
        "/v1/sync/push",
        json={
            "batch_id": str(uuid.uuid4()),
            "changes": [
                {
                    "entity": "alert_event",
                    "op": "insert",
                    "id": str(uuid.uuid4()),
                    "data": {"alert_id": str(aid), "event_type": kind, "note": "{}"},
                }
            ],
        },
        headers=headers,
    )
    return r.json()["results"][0]


def test_alert_ids_match_the_phone() -> None:
    # Shared with packages/data (alertIdFor).
    assert str(alert_id("01a1aaaa-0000-7000-8000-000000000003", "unsafe")) == (
        "e5a06055-3d8d-58a8-8f9b-de57d18f7b2a"
    )


async def test_end_to_end_unsafe_result_to_closed_alert(
    client: AsyncClient, owner_db: Database, seeded: None, channels: Channels
) -> None:
    """P8 gate: synced → the right people told within 5 min → acknowledge →
    action → close, every step with its time and actor."""
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    officer, officer_headers, officer_email = await person(
        client, owner_db, areas=(district["code"],)
    )
    other_district = await make_area(owner_db, "district")
    outsider, _, _ = await person(client, owner_db, areas=(other_district["code"],))

    changes = unsafe_visit(p)
    await p.push(changes)
    result_id = changes[2]["id"]
    aid = alert_id(result_id, "unsafe")
    created = await rows(
        owner_db, "SELECT created_at_server, provisional FROM alert WHERE id = :id", id=aid
    )
    assert len(created) == 1 and created[0].provisional is False

    worker = Worker(owner_db, channels)
    await worker.run_due(limit=500)
    told = await rows(
        owner_db,
        "SELECT user_id, channel, status, sent_at FROM notification WHERE alert_id = :a",
        a=aid,
    )
    by_user = {(r.user_id, r.channel): r for r in told}
    assert by_user[(officer, "in_app")].status == "sent"
    assert by_user[(officer, "email")].status == "sent"
    assert not any(r.user_id == outsider for r in told)
    assert by_user[(officer, "email")].sent_at - created[0].created_at_server < timedelta(minutes=5)
    assert any(m.to == officer_email for m in channels.email.sent)  # type: ignore[union-attr]

    inbox = (await client.get("/v1/notifications", headers=officer_headers)).json()
    assert inbox["unread"] >= 1
    item = next(i for i in inbox["items"] if i["alert_id"] == str(aid))
    assert item["title"].startswith("Unsafe water result")

    for step in ("acknowledged", "action_in_progress", "closed"):
        assert (await act(client, officer_headers, aid, step))["status"] == "applied"
    alert = (
        await rows(
            owner_db, "SELECT status, acknowledged_at, closed_at FROM alert WHERE id = :id", id=aid
        )
    )[0]
    assert alert.status == "closed" and alert.acknowledged_at and alert.closed_at
    events = await rows(
        owner_db,
        "SELECT event_type, actor_id, created_at_server FROM alert_event WHERE alert_id = :id "
        "ORDER BY created_at_server",
        id=aid,
    )
    assert [(e.event_type, e.actor_id) for e in events] == [
        ("acknowledged", officer),
        ("action_in_progress", officer),
        ("closed", officer),
    ]

    await client.post(f"/v1/notifications/{item['id']}/read", headers=officer_headers)
    again = (await client.get("/v1/notifications", headers=officer_headers)).json()
    assert next(i for i in again["items"] if i["id"] == item["id"])["read_at"] is not None


async def test_phone_and_server_raise_one_alert(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    changes = unsafe_visit(p, with_alert=True)
    result_id = changes[2]["id"]
    alert_change = next(c for c in changes if c["entity"] == "alert")
    # The phone uses the same deterministic ID (ADR-013).
    alert_change["id"] = alert_change["data"]["id"] = str(alert_id(result_id, "unsafe"))
    for c in changes:
        if c["entity"] == "alert_event":
            c["data"]["alert_id"] = alert_change["id"]
    out = await p.push(changes)
    assert {r["status"] for r in out["results"]} == {"applied"}
    alerts = await rows(owner_db, "SELECT id FROM alert WHERE trigger_result_id = :r", r=result_id)
    assert len(alerts) == 1
    jobs = await rows(
        owner_db,
        "SELECT count(*) AS n FROM job WHERE kind = 'notify_alert' AND payload->>'alert_id' = :a",
        a=alert_change["id"],
    )
    assert jobs[0].n == 1


async def test_routing_follows_responsibilities(
    client: AsyncClient, owner_db: Database, seeded: None, channels: Channels
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    sanitation, _, _ = await person(
        client, owner_db, areas=(district["code"],), responsibilities=("sanitation",)
    )
    health, _, _ = await person(
        client, owner_db, areas=(district["code"],), responsibilities=("health_inspection",)
    )
    everything, _, _ = await person(
        client, owner_db, areas=(district["code"],), responsibilities=()
    )
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "DELETE FROM alert_routing_rule WHERE trigger_rule = 'unsafe' "
                "AND responsibility_code = 'sanitation'"
            )
        )
    try:
        changes = unsafe_visit(p)
        await p.push(changes)
        await Worker(owner_db, channels).run_due(limit=500)
        aid = alert_id(changes[2]["id"], "unsafe")
        told = {
            r.user_id
            for r in await rows(
                owner_db, "SELECT user_id FROM notification WHERE alert_id = :a", a=aid
            )
        }
        assert health in told
        assert sanitation not in told
        # No responsibilities set: the area default, everything.
        assert everything in told
    finally:
        async with owner_db.transaction(Principal.system()) as conn:
            await conn.execute(
                text(
                    "INSERT INTO alert_routing_rule (trigger_rule, responsibility_code) "
                    "VALUES ('unsafe', 'sanitation') ON CONFLICT DO NOTHING"
                )
            )


async def _told_at(
    owner_db: Database, channels: Channels, aid: uuid.UUID, opened: datetime, hours: float
) -> set[tuple[uuid.UUID, int]]:
    """Runs the worker as if [hours] had passed; who has been told, at which step."""
    w = Worker(owner_db, channels, clock=lambda: opened + timedelta(hours=hours))
    await w.schedule_periodic()
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "UPDATE job SET run_at = now() "
                "WHERE kind = 'escalation_sweep' AND status = 'queued'"
            )
        )
    await w.run_due(limit=1000)
    return {
        (r.user_id, r.escalation_level)
        for r in await rows(
            owner_db,
            "SELECT user_id, escalation_level FROM notification WHERE alert_id = :a "
            "AND channel = 'in_app'",
            a=aid,
        )
    }


async def _chain_area(owner_db: Database) -> dict[str, dict[str, Any]]:
    """national > region > district (a village under it comes with the phone)."""
    national = await make_area(owner_db, "country")
    region = await make_area(owner_db, "region", parent=national["id"])
    district = await make_area(owner_db, "district", parent=region["id"])
    return {"national": national, "region": region, "district": district}


async def test_unacknowledged_alerts_climb_the_chain(
    client: AsyncClient, owner_db: Database, seeded: None, channels: Channels
) -> None:
    """Village first; 48 h → the next level that has someone (district);
    96 h → region; 144 h → national; then nothing more (G16)."""
    area = await _chain_area(owner_db)
    p = await phone(client, owner_db, area["district"])
    village, _, _ = await person(client, owner_db, areas=(p.village_code,))
    district, _, _ = await person(client, owner_db, areas=(area["district"]["code"],))
    region, _, _ = await person(client, owner_db, areas=(area["region"]["code"],))
    national, _, _ = await person(client, owner_db, areas=(area["national"]["code"],))
    admin, _, _ = await person(client, owner_db, role="it_admin", responsibilities=())
    changes = unsafe_visit(p)
    await p.push(changes)
    aid = alert_id(changes[2]["id"], "unsafe")
    opened = (await rows(owner_db, "SELECT opened_at FROM alert WHERE id = :id", id=aid))[0][0]

    told = await _told_at(owner_db, channels, aid, opened, 1)
    assert {u for u, _ in told} == {village}
    told = await _told_at(owner_db, channels, aid, opened, 49)
    assert (district, 1) in told and (region, 2) not in told
    told = await _told_at(owner_db, channels, aid, opened, 97)
    assert (region, 2) in told
    told = await _told_at(owner_db, channels, aid, opened, 145)
    assert (national, 3) in told
    told = await _told_at(owner_db, channels, aid, opened, 400)
    assert {u for u, _ in told} == {village, district, region, national}
    assert admin not in {u for u, _ in told}
    level = await rows(owner_db, "SELECT escalation_level FROM alert WHERE id = :id", id=aid)
    assert level[0][0] == 3
    events = await rows(
        owner_db,
        "SELECT note FROM alert_event WHERE alert_id = :id AND event_type = 'escalated' "
        "ORDER BY (note::jsonb ->> 'level')::int",
        id=aid,
    )
    assert [json.loads(e.note)["to"] for e in events] == ["district", "region", "national"]


async def test_the_chain_skips_levels_with_nobody(
    client: AsyncClient, owner_db: Database, seeded: None, channels: Channels
) -> None:
    """No village or district officer: the region is first, national next."""
    area = await _chain_area(owner_db)
    p = await phone(client, owner_db, area["district"])
    region, _, _ = await person(client, owner_db, areas=(area["region"]["code"],))
    national, _, _ = await person(client, owner_db, areas=(area["national"]["code"],))
    changes = unsafe_visit(p)
    await p.push(changes)
    aid = alert_id(changes[2]["id"], "unsafe")
    opened = (await rows(owner_db, "SELECT opened_at FROM alert WHERE id = :id", id=aid))[0][0]
    assert await _told_at(owner_db, channels, aid, opened, 1) == {(region, 0)}
    assert (national, 1) in await _told_at(owner_db, channels, aid, opened, 49)


async def test_it_admins_are_told_only_when_nobody_covers_the_source(
    client: AsyncClient, owner_db: Database, seeded: None, channels: Channels
) -> None:
    area = await _chain_area(owner_db)
    p = await phone(client, owner_db, area["district"])
    admin, _, _ = await person(client, owner_db, role="it_admin", responsibilities=())
    changes = unsafe_visit(p)
    await p.push(changes)
    aid = alert_id(changes[2]["id"], "unsafe")
    opened = (await rows(owner_db, "SELECT opened_at FROM alert WHERE id = :id", id=aid))[0][0]
    told = await _told_at(owner_db, channels, aid, opened, 1)
    assert (admin, 0) in told
    # Nothing to escalate to.
    assert await _told_at(owner_db, channels, aid, opened, 200) == told


async def test_acknowledged_alerts_do_not_escalate(
    client: AsyncClient, owner_db: Database, seeded: None, channels: Channels
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    _, headers, _ = await person(client, owner_db, areas=(district["code"],))
    changes = unsafe_visit(p)
    await p.push(changes)
    aid = alert_id(changes[2]["id"], "unsafe")
    await act(client, headers, aid, "acknowledged")
    opened = (await rows(owner_db, "SELECT opened_at FROM alert WHERE id = :id", id=aid))[0][0]
    w = Worker(owner_db, channels, clock=lambda: opened + timedelta(hours=200))
    await w.schedule_periodic()
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(text("UPDATE job SET run_at = now() WHERE kind = 'escalation_sweep'"))
    await w.run_due(limit=1000)
    level = (await rows(owner_db, "SELECT escalation_level FROM alert WHERE id = :id", id=aid))[0][
        0
    ]
    assert level == 0


async def test_failed_deliveries_are_retried_then_marked(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    officer, _, _ = await person(client, owner_db, areas=(district["code"],))
    failing = Channels(email=FakeSender("email", fail=True))
    changes = unsafe_visit(p)
    await p.push(changes)
    aid = alert_id(changes[2]["id"], "unsafe")
    now = datetime.now(UTC)
    for minutes in range(0, 600, 30):
        moment = now + timedelta(minutes=minutes)

        def clock(t: datetime = moment) -> datetime:
            return t

        await Worker(owner_db, failing, clock=clock).run_due(limit=1000)
    email = (
        await rows(
            owner_db,
            "SELECT n.status, n.error FROM notification n WHERE n.alert_id = :a "
            "AND n.user_id = :u AND n.channel = 'email'",
            a=aid,
            u=officer,
        )
    )[0]
    assert email.status == "failed"
    job = (
        await rows(
            owner_db,
            "SELECT attempts, status FROM job WHERE kind = 'deliver' "
            "AND payload->>'notification_id' = (SELECT id::text FROM notification "
            "WHERE alert_id = :a AND user_id = :u AND channel = 'email')",
            a=aid,
            u=officer,
        )
    )[0]
    assert (job.attempts, job.status) == (8, "failed")


# ------------------------------------------------------------------ SMS
async def short_code(p: Phone) -> str:
    r = await p.client.get(
        "/v1/installations/me",
        headers=signed_headers(
            p.id, p.secret, "GET", "/v1/installations/me", nonce=uuid.uuid4().hex
        ),
    )
    code: str = r.json()["short_code"]
    return code


def compose_sms(
    p: Phone, short: str, source_code: str, at: datetime, status: str = "UNSAFE"
) -> str:
    signed = f"WC1 I:{short} ALERT {source_code} {at:%Y%m%dT%H%MZ} PH9.4 TDS300 {status} A:ADV"
    return f"{signed} #{sms_code(p.secret, signed)}"


async def inbound(client: AsyncClient, body: str) -> Any:
    form = {"from": "+256700000123", "text": body, "id": uuid.uuid4().hex}
    return await client.post(
        f"/v1/sms/inbound/test?token={TOKEN}",
        content=urlencode(form),
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )


async def test_sms_opens_a_provisional_alert_then_reconciles_without_duplicate(
    client: AsyncClient, owner_db: Database, seeded: None, channels: Channels
) -> None:
    """P8 gate: SMS round trip (fake gateway): provisional alert, then the
    full record reconciles it; one alert stays."""
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    officer, _, _ = await person(client, owner_db, areas=(district["code"],))
    changes = unsafe_visit(p)
    source = changes[0]
    await p.push([source])  # the source synced earlier; the test is stuck
    tested = datetime.now(UTC).replace(second=0, microsecond=0)
    for c in changes[1:]:
        for key in ("tested_at_device", "created_at_device"):
            if key in c["data"]:
                c["data"][key] = tested.isoformat()
    short = await short_code(p)

    r = await inbound(client, compose_sms(p, short, source["data"]["code"], tested))
    assert r.json() == {"status": "accepted", "reason": None}
    provisional = await rows(
        owner_db,
        "SELECT id, status FROM alert WHERE source_id = :s AND provisional",
        s=source["id"],
    )
    assert len(provisional) == 1
    await Worker(owner_db, channels).run_due(limit=500)
    told = await rows(
        owner_db,
        "SELECT 1 FROM notification WHERE alert_id = :a AND user_id = :u",
        a=provisional[0].id,
        u=officer,
    )
    assert told

    # The same SMS delivered twice by the gateway changes nothing.
    again = await inbound(client, compose_sms(p, short, source["data"]["code"], tested))
    assert again.json()["status"] == "duplicate"

    # Later the full record syncs.
    await p.push(changes[1:])
    open_alerts = await rows(
        owner_db,
        "SELECT id, provisional, linked_alert_id FROM alert WHERE source_id = :s "
        "AND status = 'open'",
        s=source["id"],
    )
    assert len(open_alerts) == 1 and open_alerts[0].provisional is False
    closed = await rows(
        owner_db,
        "SELECT status, linked_alert_id FROM alert WHERE id = :id",
        id=provisional[0].id,
    )
    assert (closed[0].status, closed[0].linked_alert_id) == ("closed", open_alerts[0].id)
    # People were told once, about the provisional alert.
    await Worker(owner_db, channels).run_due(limit=500)
    repeat = await rows(
        owner_db, "SELECT 1 FROM notification WHERE alert_id = :a", a=open_alerts[0].id
    )
    assert repeat == []


async def test_an_sms_after_the_full_record_is_noted_not_duplicated(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    changes = unsafe_visit(p)
    await p.push(changes)
    tested = datetime.fromisoformat(changes[1]["data"]["tested_at_device"])
    r = await inbound(
        client, compose_sms(p, await short_code(p), changes[0]["data"]["code"], tested)
    )
    assert r.json() == {"status": "duplicate", "reason": "already_known"}
    alerts = await rows(owner_db, "SELECT id FROM alert WHERE source_id = :s", s=changes[0]["id"])
    assert len(alerts) == 1


async def test_forged_or_bad_sms_are_rejected_and_logged(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    """P8 gate: bad HMAC, unknown or revoked installation are refused and
    logged; so is anything malformed or sent with a wrong webhook token."""
    district = await make_area(owner_db, "district")
    p = await phone(client, owner_db, district)
    source = unsafe_visit(p)[0]
    await p.push([source])
    short = await short_code(p)
    now = datetime.now(UTC)
    good = compose_sms(p, short, source["data"]["code"], now)

    forged = good[:-6] + ("000000" if not good.endswith("000000") else "111111")
    cases = {
        "bad_code": forged,
        "unknown_installation": good.replace(f"I:{short}", "I:ZZZZ"),
        "malformed": "hello, the water is bad",
        "unknown_source": compose_sms(p, short, "NO-SUCH-SOURCE", now),
    }
    for reason, body in cases.items():
        r = await inbound(client, body)
        assert r.json() == {"status": "rejected", "reason": reason}, reason

    admin_headers = (await person(client, owner_db, role="it_admin", responsibilities=()))[1]
    await client.post(f"/v1/admin/installations/{p.id}/revoke", headers=admin_headers)
    revoked = await inbound(client, compose_sms(p, short, source["data"]["code"], now))
    assert revoked.json() == {"status": "rejected", "reason": "revoked_installation"}

    logged = await rows(
        owner_db,
        "SELECT reason, phone_last3, phone_hash FROM sms_message WHERE status = 'rejected' "
        "AND installation_id = :i",
        i=p.id,
    )
    reasons = {r.reason for r in logged}
    assert {"bad_code", "unknown_source", "revoked_installation"} <= reasons
    assert all(r.phone_last3 == "123" and len(r.phone_hash) == 64 for r in logged)
    audits = await rows(
        owner_db,
        "SELECT count(*) AS n FROM audit_log "
        "WHERE action = 'sms.rejected' AND installation_id = :i",
        i=p.id,
    )
    assert audits[0].n >= 3
    no_alerts = await rows(
        owner_db, "SELECT 1 FROM alert WHERE source_id = :s AND provisional", s=source["id"]
    )
    assert no_alerts == []

    wrong_token = await client.post(
        "/v1/sms/inbound/test?token=wrong",
        content=urlencode({"text": good}),
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    assert wrong_token.status_code == 403


async def test_push_tokens_are_per_user(client: AsyncClient, owner_db: Database) -> None:
    _, headers, _ = await person(client, owner_db, areas=())
    token = "fcm-" + uuid.uuid4().hex * 2
    r = await client.post(
        "/v1/push-tokens", json={"token": token, "platform": "android"}, headers=headers
    )
    assert r.status_code == 204
    assert len(await rows(owner_db, "SELECT 1 FROM push_token WHERE token = :t", t=token)) == 1
    await client.delete(f"/v1/push-tokens/{token}", headers=headers)
    assert await rows(owner_db, "SELECT 1 FROM push_token WHERE token = :t", t=token) == []


def test_sms_code_matches_the_phone() -> None:
    # Shared with apps/collect (sms_fallback_test.dart).
    signed = "WC1 I:7Q2K ALERT ABIM-ENT-003 20261104T0912Z PH7.1 TDS1820 EC2600 UNSAFE"
    assert sms_code("test-only-secret", signed) == "1714FE"
