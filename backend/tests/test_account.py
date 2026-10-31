"""Account security in the Console profile (2026-10-29): sessions with
their device, signing them out, recent activity, and a forgotten password
reset with a code."""

from __future__ import annotations

from typing import Any

import pytest
from httpx2 import AsyncClient

from app.db.database import Database
from tests.helpers import NEW_PASSWORD, signed_in
from tests.test_research import _person
from tests.test_sync import seeded

__all__ = ["seeded"]  # the fixture, used by name

EDGE = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
)
PHONE = (
    "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/131.0.0.0 Mobile Safari/537.36"
)


async def _sign_in(client: AsyncClient, username: str, agent: str) -> dict[str, Any]:
    r = await client.post(
        "/v1/auth/login",
        json={"username": username, "password": NEW_PASSWORD, "side": "research"},
        headers={"User-Agent": agent},
    )
    assert r.status_code == 200, r.text
    tokens: dict[str, Any] = r.json()
    return tokens


def _auth(tokens: dict[str, Any]) -> dict[str, str]:
    return {"Authorization": f"Bearer {tokens['access_token']}"}


@pytest.mark.usefixtures("seeded")
async def test_sessions_show_their_device_and_can_be_signed_out(
    client: AsyncClient, owner_db: Database
) -> None:
    username, _ = await _person(client, owner_db)
    laptop = await _sign_in(client, username, EDGE)
    phone = await _sign_in(client, username, PHONE)

    seen = (await client.get("/v1/me/sessions", headers=_auth(laptop))).json()
    devices = {s["device"]: s["current"] for s in seen}
    assert devices["Edge on Windows"] is True
    assert devices["Chrome on Android"] is False
    assert seen[0]["current"] is True

    # Every other sign-in ends; the phone can no longer renew its access.
    ended = (await client.post("/v1/me/sessions/sign-out-others", headers=_auth(laptop))).json()
    assert ended["ended"] >= 2  # the phone and the sign-in made by _person
    again = await client.post("/v1/auth/refresh", json={"refresh_token": phone["refresh_token"]})
    assert again.status_code == 401
    left = (await client.get("/v1/me/sessions", headers=_auth(laptop))).json()
    assert [s["device"] for s in left] == ["Edge on Windows"]

    # One session by itself.
    tablet = await _sign_in(client, username, PHONE)
    tablet_id = next(
        s["id"]
        for s in (await client.get("/v1/me/sessions", headers=_auth(tablet))).json()
        if s["current"]
    )
    r = await client.post(f"/v1/me/sessions/{tablet_id}/sign-out", headers=_auth(laptop))
    assert r.status_code == 204
    gone = await client.post("/v1/auth/refresh", json={"refresh_token": tablet["refresh_token"]})
    assert gone.status_code == 401

    activity = [
        a["action"] for a in (await client.get("/v1/me/activity", headers=_auth(laptop))).json()
    ]
    assert "auth.login" in activity
    assert "auth.sessions_ended" in activity
    assert "auth.session_ended" in activity


@pytest.mark.usefixtures("seeded")
async def test_a_forgotten_password_is_reset_with_a_code(
    client: AsyncClient, owner_db: Database
) -> None:
    username, _ = await _person(client, owner_db)
    other = await _sign_in(client, username, PHONE)
    admin = await signed_in(client, owner_db, role="it_admin")

    # Unknown accounts get the same answer and no code.
    unknown = await client.post(
        "/v1/auth/password-reset", json={"username": "nobody@example.org", "side": "research"}
    )
    assert unknown.status_code == 202

    asked = await client.post(
        "/v1/auth/password-reset", json={"username": username, "side": "research"}
    )
    assert asked.status_code == 202

    def reset_codes(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
        return [c for c in rows if c["kind"] == "password_reset" and username in c["detail"]]

    codes = reset_codes(
        (
            await client.get("/v1/admin/codes-to-pass", params={"side": "research"}, headers=admin)
        ).json()
    )
    assert len(codes) == 1
    code = codes[0]["code"]
    # Asking again at once keeps the same code.
    await client.post("/v1/auth/password-reset", json={"username": username, "side": "research"})
    again = reset_codes((await client.get("/v1/admin/codes-to-pass", headers=admin)).json())
    assert [c["code"] for c in again] == [code]

    wrong = "000000" if code != "000000" else "111111"
    new = "Another-Strong-Pass-2026"
    bad = await client.post(
        "/v1/auth/password-reset/confirm",
        json={"username": username, "side": "research", "code": wrong, "new_password": new},
    )
    assert bad.status_code == 400
    weak = await client.post(
        "/v1/auth/password-reset/confirm",
        json={"username": username, "side": "research", "code": code, "new_password": "short"},
    )
    assert weak.status_code == 422
    ok = await client.post(
        "/v1/auth/password-reset/confirm",
        json={"username": username, "side": "research", "code": code, "new_password": new},
    )
    assert ok.status_code == 204, ok.text

    # The old password and every earlier sign-in stop working.
    old = await client.post(
        "/v1/auth/login",
        json={"username": username, "password": NEW_PASSWORD, "side": "research"},
    )
    assert old.status_code == 401
    assert (
        await client.post("/v1/auth/refresh", json={"refresh_token": other["refresh_token"]})
    ).status_code == 401
    fresh = await client.post(
        "/v1/auth/login", json={"username": username, "password": new, "side": "research"}
    )
    assert fresh.status_code == 200
    # The code works once.
    reused = await client.post(
        "/v1/auth/password-reset/confirm",
        json={"username": username, "side": "research", "code": code, "new_password": new + "x"},
    )
    assert reused.status_code == 400
    activity = [
        a["action"]
        for a in (await client.get("/v1/me/activity", headers=_auth(fresh.json()))).json()
    ]
    assert "auth.password_reset" in activity and "auth.password_reset_requested" in activity
