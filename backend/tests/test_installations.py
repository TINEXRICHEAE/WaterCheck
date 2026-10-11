"""P4 gate: activation (expired, reused, max installations, revoked) and
signed Collect requests (bad signature, replay, stale time)."""

import time
import uuid

from httpx2 import AsyncClient

from app.db.database import Database
from tests.helpers import make_area, signed_headers, signed_in


async def _code(client: AsyncClient, admin: dict[str, str], area_code: str, **extra: object) -> str:
    r = await client.post(
        "/v1/admin/activation-codes", json={"area_code": area_code, **extra}, headers=admin
    )
    assert r.status_code == 201, r.text
    code: str = r.json()["code"]
    return code


async def _activate(client: AsyncClient, code: str) -> dict[str, object]:
    r = await client.post(
        "/v1/installations/activate",
        json={"code": code, "platform": "android", "app_version": "0.1.0"},
    )
    return {"status": r.status_code, **r.json()}


async def test_activate_then_sign_requests(client: AsyncClient, owner_db: Database) -> None:
    village = await make_area(owner_db)
    admin = await signed_in(client, owner_db, role="it_admin")
    code = await _code(client, admin, village["code"])
    assert len(code) == 14 and code.count("-") == 2

    # Codes are typed by people: case and spacing don't matter.
    activation = await _activate(client, code.lower().replace("-", " "))
    assert activation["status"] == 200
    inst, secret = str(activation["installation_id"]), str(activation["secret"])
    assert activation["area"] == {
        "id": str(village["id"]),
        "code": village["code"],
        "name": f"Area {village['code']}",
        "level": "village",
    }

    me = await client.get(
        "/v1/installations/me", headers=signed_headers(inst, secret, "GET", "/v1/installations/me")
    )
    assert me.status_code == 200, me.text
    assert me.json()["area"]["code"] == village["code"]


async def test_bad_signature_replay_and_stale_time_are_refused(
    client: AsyncClient, owner_db: Database
) -> None:
    village = await make_area(owner_db)
    admin = await signed_in(client, owner_db, role="it_admin")
    a = await _activate(client, await _code(client, admin, village["code"]))
    inst, secret = str(a["installation_id"]), str(a["secret"])
    path = "/v1/installations/me"

    unsigned = await client.get(path)
    assert (unsigned.status_code, unsigned.json()["detail"]) == (401, "unsigned_request")

    wrong = await client.get(path, headers=signed_headers(inst, "not-the-secret", "GET", path))
    assert wrong.json()["detail"] == "invalid_signature"

    headers = signed_headers(inst, secret, "GET", path)
    assert (await client.get(path, headers=headers)).status_code == 200
    replay = await client.get(path, headers=headers)
    assert replay.json()["detail"] == "replayed_request"

    stale = await client.get(
        path, headers=signed_headers(inst, secret, "GET", path, at=int(time.time()) - 3600)
    )
    assert stale.json()["detail"] == "stale_request"

    unknown = await client.get(path, headers=signed_headers(str(uuid.uuid4()), secret, "GET", path))
    assert unknown.status_code == 401


async def test_code_limits(client: AsyncClient, owner_db: Database) -> None:
    village = await make_area(owner_db)
    admin = await signed_in(client, owner_db, role="it_admin")

    once = await _code(client, admin, village["code"], max_installations=1)
    assert (await _activate(client, once))["status"] == 200
    reused = await _activate(client, once)
    assert (reused["status"], reused["detail"]) == (409, "code_used_up")

    nonsense = await _activate(client, "AAAA-BBBB-CCCC")
    assert (nonsense["status"], nonsense["detail"]) == (404, "invalid_code")

    expired = await _code(client, admin, village["code"])
    from sqlalchemy import text

    from app.core.security import token_hash
    from app.db.database import Principal
    from app.services.installations import normalise_code

    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "UPDATE activation_code SET expires_at = now() - interval '1 minute' "
                "WHERE code_hash = :h"
            ),
            {"h": token_hash(normalise_code(expired))},
        )
    late = await _activate(client, expired)
    assert (late["status"], late["detail"]) == (410, "expired_code")


async def test_revoked_installation_is_stopped(client: AsyncClient, owner_db: Database) -> None:
    village = await make_area(owner_db)
    admin = await signed_in(client, owner_db, role="it_admin")
    a = await _activate(client, await _code(client, admin, village["code"]))
    inst, secret = str(a["installation_id"]), str(a["secret"])

    r = await client.post(f"/v1/admin/installations/{inst}/revoke", headers=admin)
    assert r.status_code == 204
    again = await client.post(f"/v1/admin/installations/{inst}/revoke", headers=admin)
    assert again.status_code == 404

    path = "/v1/installations/me"
    stopped = await client.get(path, headers=signed_headers(inst, secret, "GET", path))
    assert (stopped.status_code, stopped.json()["detail"]) == (403, "installation_revoked")


async def test_only_admins_issue_codes(client: AsyncClient, owner_db: Database) -> None:
    village = await make_area(owner_db)
    stakeholder = await signed_in(client, owner_db, area_codes=(village["code"],))
    r = await client.post(
        "/v1/admin/activation-codes", json={"area_code": village["code"]}, headers=stakeholder
    )
    assert r.status_code == 403
    unknown = await client.post(
        "/v1/admin/activation-codes",
        json={"area_code": "NOPE"},
        headers=await signed_in(client, owner_db, role="it_admin"),
    )
    assert unknown.status_code == 404
