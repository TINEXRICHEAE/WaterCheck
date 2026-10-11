"""Test helpers shared by API tests."""

from __future__ import annotations

import time
import uuid
from typing import Any

from httpx2 import AsyncClient
from sqlalchemy import text

from app.core.security import sign_request
from app.db.database import Database, Principal
from app.services.users import NewUser, create_user

NEW_PASSWORD = "BoreholeWater2026"  # noqa: S105 - test-only password


async def make_area(
    owner_db: Database, level: str = "village", parent: uuid.UUID | None = None
) -> dict[str, Any]:
    area = {"id": uuid.uuid4(), "level": level, "code": f"T-{uuid.uuid4().hex[:10]}"}
    async with owner_db.transaction(Principal.system()) as conn:
        await conn.execute(
            text(
                "INSERT INTO admin_unit (id, level, name, code, parent_id) "
                "VALUES (:id, :level, :name, :code, :parent)"
            ),
            {**area, "name": f"Area {area['code']}", "parent": parent},
        )
    return area


async def signed_in(
    client: AsyncClient,
    owner_db: Database,
    *,
    role: str = "stakeholder",
    area_codes: tuple[str, ...] = (),
) -> dict[str, str]:
    """Creates a user, changes the temporary password, returns auth headers."""
    username = f"u-{uuid.uuid4().hex[:8]}@example.org"
    async with owner_db.transaction(Principal.system()) as conn:
        created = await create_user(
            conn, NewUser(username=username, full_name="Officer", role=role, area_codes=area_codes)
        )
    first = await client.post(
        "/v1/auth/login", json={"username": username, "password": created.temporary_password}
    )
    changed = await client.post(
        "/v1/auth/change-password",
        json={"current_password": created.temporary_password, "new_password": NEW_PASSWORD},
        headers={"Authorization": f"Bearer {first.json()['access_token']}"},
    )
    return {"Authorization": f"Bearer {changed.json()['access_token']}"}


def signed_headers(
    installation_id: str,
    secret: str,
    method: str,
    path: str,
    body: bytes = b"",
    *,
    at: int | None = None,
    nonce: str | None = None,
) -> dict[str, str]:
    ts = str(at if at is not None else int(time.time()))
    headers = {
        "X-Installation-Id": installation_id,
        "X-Timestamp": ts,
        "X-Signature": sign_request(secret, method, path, ts, body, nonce),
    }
    if nonce:
        headers["X-Nonce"] = nonce
    return headers
