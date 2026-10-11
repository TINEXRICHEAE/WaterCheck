"""P5: web Console sessions use an httpOnly refresh cookie with double-submit
CSRF (ADR-010); "forgot password" leaves a request for the IT admin."""

import uuid
from collections.abc import AsyncIterator

import pytest_asyncio
from httpx2 import ASGITransport, AsyncClient
from sqlalchemy import text

from app.core.config import Settings
from app.db.database import Database, Principal
from app.main import create_app
from app.services.users import NewUser, create_user

from .helpers import NEW_PASSWORD

COOKIE = {"X-Token-Transport": "cookie"}


@pytest_asyncio.fixture
async def web(db: Database) -> AsyncIterator[AsyncClient]:
    # The test transport is plain http, so Secure cookies would not be sent.
    app = create_app(
        Settings(environment="test", cookie_secure=False, refresh_cookie_path="/v1/auth")
    )
    app.state.db = db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


async def _user(owner_db: Database) -> tuple[str, str]:
    username = f"web-{uuid.uuid4().hex[:8]}@example.org"
    async with owner_db.transaction(Principal.system()) as conn:
        created = await create_user(
            conn, NewUser(username=username, full_name="Web Officer", role="stakeholder")
        )
    return username, created.temporary_password


async def _signed_in(web: AsyncClient, owner_db: Database) -> str:
    username, temp = await _user(owner_db)
    first = await web.post(
        "/v1/auth/login", json={"username": username, "password": temp}, headers=COOKIE
    )
    assert first.status_code == 200
    changed = await web.post(
        "/v1/auth/change-password",
        json={"current_password": temp, "new_password": NEW_PASSWORD},
        headers={**COOKIE, "Authorization": f"Bearer {first.json()['access_token']}"},
    )
    assert changed.status_code == 200
    return username


async def test_cookie_login_keeps_the_refresh_token_out_of_scripts(
    web: AsyncClient, owner_db: Database
) -> None:
    username, temp = await _user(owner_db)
    r = await web.post(
        "/v1/auth/login", json={"username": username, "password": temp}, headers=COOKIE
    )
    assert r.status_code == 200
    assert r.json()["refresh_token"] is None
    cookies = r.headers.get_list("set-cookie")
    refresh = next(c for c in cookies if c.startswith("wc_refresh="))
    csrf = next(c for c in cookies if c.startswith("wc_csrf="))
    assert "HttpOnly" in refresh
    assert "samesite=strict" in refresh.lower()
    assert "Path=/v1/auth" in refresh
    assert "HttpOnly" not in csrf


async def test_native_login_still_returns_the_refresh_token(
    web: AsyncClient, owner_db: Database
) -> None:
    username, temp = await _user(owner_db)
    r = await web.post("/v1/auth/login", json={"username": username, "password": temp})
    assert r.json()["refresh_token"]
    assert not r.headers.get_list("set-cookie")


async def test_cookie_refresh_needs_the_csrf_token(web: AsyncClient, owner_db: Database) -> None:
    await _signed_in(web, owner_db)
    csrf = web.cookies["wc_csrf"]

    missing = await web.post("/v1/auth/refresh")
    assert missing.status_code == 403
    assert missing.json()["detail"] == "csrf_failed"
    wrong = await web.post("/v1/auth/refresh", headers={"X-CSRF-Token": "not-the-token"})
    assert wrong.status_code == 403

    ok = await web.post("/v1/auth/refresh", headers={"X-CSRF-Token": csrf})
    assert ok.status_code == 200
    assert ok.json()["refresh_token"] is None
    assert ok.json()["must_change_password"] is False
    # The cookie was rotated together with a fresh CSRF token.
    assert web.cookies["wc_csrf"] != csrf
    me = await web.get("/v1/me", headers={"Authorization": f"Bearer {ok.json()['access_token']}"})
    assert me.status_code == 200


async def test_web_refresh_and_logout_accept_an_empty_json_body(
    web: AsyncClient, owner_db: Database
) -> None:
    """The web Console's generated client sends `{}` when there is no token
    in the body; that must mean "use the cookie" (it was a 422, so a page
    reload lost the session)."""
    await _signed_in(web, owner_db)
    csrf = web.cookies["wc_csrf"]
    ok = await web.post("/v1/auth/refresh", json={}, headers={"X-CSRF-Token": csrf})
    assert ok.status_code == 200
    out = await web.post(
        "/v1/auth/logout", json={}, headers={"X-CSRF-Token": web.cookies["wc_csrf"]}
    )
    assert out.status_code == 204
    again = await web.post("/v1/auth/refresh", headers={"X-CSRF-Token": csrf})
    assert again.status_code in (401, 403)


async def test_a_stolen_old_cookie_ends_the_session(web: AsyncClient, owner_db: Database) -> None:
    await _signed_in(web, owner_db)
    old_refresh = web.cookies["wc_refresh"]
    csrf = web.cookies["wc_csrf"]
    assert (await web.post("/v1/auth/refresh", headers={"X-CSRF-Token": csrf})).status_code == 200

    # Replaying the old cookie is refresh-token reuse: the family is revoked.
    web.cookies.set("wc_refresh", old_refresh)
    web.cookies.set("wc_csrf", csrf)
    reused = await web.post("/v1/auth/refresh", headers={"X-CSRF-Token": csrf})
    assert reused.status_code == 401


async def test_cookie_logout_clears_the_session(web: AsyncClient, owner_db: Database) -> None:
    await _signed_in(web, owner_db)
    csrf = web.cookies["wc_csrf"]
    out = await web.post("/v1/auth/logout", headers={"X-CSRF-Token": csrf})
    assert out.status_code == 204
    assert "wc_refresh" not in web.cookies
    again = await web.post("/v1/auth/refresh", headers={"X-CSRF-Token": csrf})
    assert again.status_code in (401, 403)


async def test_refresh_without_a_cookie_is_refused(web: AsyncClient) -> None:
    r = await web.post("/v1/auth/refresh", headers={"X-CSRF-Token": "x"})
    assert r.status_code == 401


async def test_password_help_is_recorded_without_revealing_accounts(
    web: AsyncClient, owner_db: Database
) -> None:
    username, _ = await _user(owner_db)
    known = await web.post("/v1/auth/password-help", json={"username": username.upper()})
    unknown = await web.post("/v1/auth/password-help", json={"username": "nobody@example.org"})
    assert known.status_code == unknown.status_code == 202
    async with owner_db.transaction(Principal.system()) as conn:
        count = (
            await conn.execute(
                text(
                    "SELECT count(*) FROM audit_log a JOIN app_user u ON u.id = a.entity_id "
                    "WHERE a.action = 'auth.password_help_requested' AND u.username = :u"
                ),
                {"u": username},
            )
        ).scalar_one()
    assert count == 1
