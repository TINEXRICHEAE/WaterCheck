"""P4 gate: login, forced password change, refresh rotation, reuse detection
and lockout; passwords are never stored in plain text."""

import uuid
from collections.abc import AsyncIterator

import pytest
import pytest_asyncio
from httpx2 import ASGITransport, AsyncClient
from sqlalchemy import text

from app.core.config import Settings
from app.db.database import Database, Principal
from app.main import create_app
from app.services.users import NewUser, create_user


@pytest_asyncio.fixture
async def client(db: Database) -> AsyncIterator[AsyncClient]:
    app = create_app(Settings(environment="test", max_failed_logins=5))
    app.state.db = db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


async def _make_user(owner_db: Database, role: str = "stakeholder") -> tuple[str, str]:
    username = f"user-{uuid.uuid4().hex[:8]}@example.org"
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "INSERT INTO responsibility (code, name) VALUES ('water', 'Water') "
                "ON CONFLICT DO NOTHING"
            )
        )
        created = await create_user(
            conn,
            NewUser(
                username=username, full_name="Test Officer", role=role, responsibilities=("water",)
            ),
        )
    return username, created.temporary_password


async def _login(client: AsyncClient, username: str, password: str) -> dict[str, object]:
    r = await client.post("/v1/auth/login", json={"username": username, "password": password})
    assert r.status_code == 200, r.text
    body: dict[str, object] = r.json()
    return body


async def test_first_sign_in_forces_a_password_change(
    client: AsyncClient, owner_db: Database
) -> None:
    username, temp = await _make_user(owner_db)
    tokens = await _login(client, username, temp)
    assert tokens["must_change_password"] is True
    auth = {"Authorization": f"Bearer {tokens['access_token']}"}

    me = await client.get("/v1/me", headers=auth)
    assert me.status_code == 200
    assert me.json()["must_change_password"] is True
    assert me.json()["responsibilities"] == ["water"]

    weak = await client.post(
        "/v1/auth/change-password",
        json={"current_password": temp, "new_password": "short"},
        headers=auth,
    )
    assert weak.status_code == 422
    changed = await client.post(
        "/v1/auth/change-password",
        json={"current_password": temp, "new_password": "BoreholeWater2026"},
        headers=auth,
    )
    assert changed.status_code == 200
    assert changed.json()["must_change_password"] is False

    # The temporary password no longer works; the new one does.
    bad = await client.post("/v1/auth/login", json={"username": username, "password": temp})
    assert bad.status_code == 401
    good = await _login(client, username, "BoreholeWater2026")
    assert good["must_change_password"] is False


async def test_refresh_rotates_and_reuse_revokes_the_family(
    client: AsyncClient, owner_db: Database
) -> None:
    username, temp = await _make_user(owner_db)
    first = await _login(client, username, temp)
    r1 = await client.post("/v1/auth/refresh", json={"refresh_token": first["refresh_token"]})
    assert r1.status_code == 200
    second = r1.json()
    assert second["refresh_token"] != first["refresh_token"]

    # Replaying the first token is treated as theft: the whole family ends.
    replay = await client.post("/v1/auth/refresh", json={"refresh_token": first["refresh_token"]})
    assert replay.status_code == 401
    after = await client.post("/v1/auth/refresh", json={"refresh_token": second["refresh_token"]})
    assert after.status_code == 401


async def test_five_wrong_passwords_lock_the_account(
    client: AsyncClient, owner_db: Database
) -> None:
    username, temp = await _make_user(owner_db)
    codes = []
    for _ in range(5):
        r = await client.post("/v1/auth/login", json={"username": username, "password": "wrong"})
        codes.append(r.status_code)
    assert codes == [401, 401, 401, 401, 423]
    # Even the right password is refused while locked.
    locked = await client.post("/v1/auth/login", json={"username": username, "password": temp})
    assert locked.status_code == 423
    assert locked.json()["detail"] == "locked"


async def test_unknown_user_and_wrong_password_look_the_same(
    client: AsyncClient, owner_db: Database
) -> None:
    username, _ = await _make_user(owner_db)
    a = await client.post(
        "/v1/auth/login", json={"username": "nobody@example.org", "password": "x"}
    )
    b = await client.post("/v1/auth/login", json={"username": username, "password": "x"})
    assert (a.status_code, a.json()) == (b.status_code, b.json())


async def test_passwords_are_stored_hashed(owner_db: Database) -> None:
    username, temp = await _make_user(owner_db)
    async with owner_db.transaction(Principal.system()) as conn:
        stored = (
            await conn.execute(
                text("SELECT password_hash FROM app_user WHERE username = :u"), {"u": username}
            )
        ).scalar_one()
    assert temp not in stored
    assert stored.startswith("$argon2id$")


async def test_must_change_password_blocks_other_endpoints(
    client: AsyncClient, owner_db: Database
) -> None:
    from fastapi import APIRouter

    from app.api.deps import UserDep

    username, temp = await _make_user(owner_db)
    tokens = await _login(client, username, temp)
    router = APIRouter()

    @router.get("/v1/probe")
    async def probe(user: UserDep) -> dict[str, str]:
        return {"ok": "yes"}

    client._transport.app.include_router(router)  # type: ignore[attr-defined]
    r = await client.get("/v1/probe", headers={"Authorization": f"Bearer {tokens['access_token']}"})
    assert r.status_code == 403
    assert r.json()["detail"] == "password_change_required"
    missing = await client.get("/v1/probe")
    assert missing.status_code == 401


@pytest.mark.parametrize("env", ["staging", "prod"])
def test_production_refuses_development_secrets(env: str) -> None:
    with pytest.raises(RuntimeError, match="secrets"):
        create_app(Settings(environment=env))
