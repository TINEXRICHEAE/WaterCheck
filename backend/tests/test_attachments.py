"""P7: resumable photo uploads through the API (SPEC §8.3, ADR-012)."""

import hashlib
import uuid
from collections.abc import AsyncIterator
from typing import Any

import pytest_asyncio
from httpx2 import ASGITransport, AsyncClient

from app.core.config import Settings
from app.db.database import Database
from app.main import create_app
from app.services.object_store import MemoryObjectStore
from tests.helpers import make_area, signed_headers
from tests.test_sync import Phone, phone, seeded, visit

__all__ = ["seeded"]

# A tiny JPEG-shaped payload: the magic bytes, then filler.
PHOTO = b"\xff\xd8\xff\xe0" + bytes(range(256)) * 400  # ~100 KB


@pytest_asyncio.fixture
async def store() -> MemoryObjectStore:
    return MemoryObjectStore()


@pytest_asyncio.fixture
async def client(db: Database, store: MemoryObjectStore) -> AsyncIterator[AsyncClient]:
    app = create_app(Settings(environment="test"))
    app.state.db = db
    app.state.store = store
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


def meta(owner_id: str, data: bytes = PHOTO, **extra: Any) -> dict[str, Any]:
    aid = str(uuid.uuid4())
    return {
        "entity": "attachment",
        "op": "insert",
        "id": aid,
        "data": {
            "id": aid,
            "owner_type": "water_source",
            "owner_id": owner_id,
            "sha256": hashlib.sha256(data).hexdigest(),
            "bytes": len(data),
            "mime": "image/jpeg",
            **extra,
        },
    }


async def call(p: Phone, method: str, path: str, body: bytes = b"") -> Any:
    headers = signed_headers(p.id, p.secret, method, path, body, nonce=uuid.uuid4().hex)
    return await p.client.request(method, path, content=body, headers=headers)


async def test_an_interrupted_upload_resumes_and_the_hash_matches(
    client: AsyncClient, owner_db: Database, seeded: None, store: MemoryObjectStore
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    source = visit(p)[0]
    photo = meta(source["id"])
    out = await p.push([source, photo])
    assert [r["status"] for r in out["results"]] == ["applied", "applied"]
    aid = photo["id"]
    base = f"/v1/attachments/{aid}/upload"

    half = len(PHOTO) // 2
    first = await call(p, "PUT", f"{base}?offset=0", PHOTO[: half // 2])
    assert first.json()["received_bytes"] == half // 2
    second = await call(p, "PUT", f"{base}?offset={half // 2}", PHOTO[half // 2 : half])
    assert second.status_code == 200
    # Connection lost at 50%. The phone asks where to resume.
    state = (await call(p, "GET", base)).json()
    assert state == {
        "received_bytes": half,
        "bytes": len(PHOTO),
        "status": "pending",
        "reason": None,
    }

    # A stale offset is refused with the right one.
    stale = await call(p, "PUT", f"{base}?offset=0", PHOTO[:100])
    assert stale.status_code == 409
    assert stale.json() == {"detail": "offset_mismatch", "received_bytes": half}

    early = await call(p, "POST", f"/v1/attachments/{aid}/complete")
    assert early.status_code == 409
    assert early.json()["detail"] == "incomplete"

    for start in range(half, len(PHOTO), 64 * 1024):
        r = await call(p, "PUT", f"{base}?offset={start}", PHOTO[start : start + 64 * 1024])
        assert r.status_code == 200, r.text
    done = await call(p, "POST", f"/v1/attachments/{aid}/complete")
    assert done.json()["status"] == "uploaded"
    # Completing again is harmless.
    assert (await call(p, "POST", f"/v1/attachments/{aid}/complete")).json()["status"] == (
        "uploaded"
    )

    stored, mime = store.objects[f"attachments/{aid}.jpg"]
    assert hashlib.sha256(stored).hexdigest() == photo["data"]["sha256"]
    assert mime == "image/jpeg"
    content = await call(p, "GET", f"/v1/attachments/{aid}/content")
    assert content.status_code == 200
    assert content.content == PHOTO
    assert content.headers["content-type"] == "image/jpeg"

    # The metadata travels with the area (status included).
    page = (await p.pull(f"area:{p.village}")).json()
    pulled = next(c for c in page["changes"] if c["entity"] == "attachment")
    assert pulled["data"]["upload_status"] == "uploaded"


async def test_bad_photos_are_rejected_with_a_reason(
    client: AsyncClient, owner_db: Database, seeded: None, store: MemoryObjectStore
) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    source = visit(p)[0]
    wrong_hash = meta(source["id"], sha256="0" * 64)
    not_jpeg_bytes = b"GIF89a" + bytes(100)
    not_jpeg = meta(source["id"], not_jpeg_bytes)
    await p.push([source, wrong_hash, not_jpeg])

    for change, data, reason in (
        (wrong_hash, PHOTO, "hash_mismatch"),
        (not_jpeg, not_jpeg_bytes, "not_an_image"),
    ):
        aid = change["id"]
        for start in range(0, len(data), 200 * 1024):
            await call(
                p,
                "PUT",
                f"/v1/attachments/{aid}/upload?offset={start}",
                data[start : start + 200 * 1024],
            )
        out = (await call(p, "POST", f"/v1/attachments/{aid}/complete")).json()
        assert (out["status"], out["reason"]) == ("rejected", reason)
        assert (await call(p, "GET", f"/v1/attachments/{aid}/content")).status_code == 404
    assert store.objects == {}

    big = await call(
        p, "PUT", f"/v1/attachments/{wrong_hash['id']}/upload?offset=0", bytes(300 * 1024)
    )
    assert big.status_code == 413


async def test_metadata_is_checked_and_scoped(
    client: AsyncClient, owner_db: Database, seeded: None
) -> None:
    district = await make_area(owner_db, "district")
    a = await phone(client, owner_db, district)
    source = visit(a)[0]
    png = meta(source["id"], mime="image/png")
    huge = meta(source["id"], bytes=5 * 1024 * 1024)
    ok = meta(source["id"])
    out = {r["id"]: r for r in (await a.push([source, png, huge, ok]))["results"]}
    assert out[png["id"]]["reason"] == "unsupported_type"
    assert out[huge["id"]]["reason"] == "invalid_value"
    assert out[ok["id"]]["status"] == "applied"

    # Another district's phone can neither attach to nor read it.
    b = await phone(client, owner_db, await make_area(owner_db, "district"))
    foreign = meta(source["id"])
    assert (await b.push([foreign]))["results"][0]["reason"] == "missing_parent"
    assert (await call(b, "GET", f"/v1/attachments/{ok['id']}/upload")).status_code == 404
    put = await call(b, "PUT", f"/v1/attachments/{ok['id']}/upload?offset=0", PHOTO[:10])
    assert put.status_code == 404


async def test_uploads_need_storage(client: AsyncClient, owner_db: Database, seeded: None) -> None:
    p = await phone(client, owner_db, await make_area(owner_db, "district"))
    source = visit(p)[0]
    photo = meta(source["id"], PHOTO[:1000])
    await p.push([source, photo])
    await call(p, "PUT", f"/v1/attachments/{photo['id']}/upload?offset=0", PHOTO[:1000])
    client._transport.app.state.store = None  # type: ignore[attr-defined]
    r = await call(p, "POST", f"/v1/attachments/{photo['id']}/complete")
    assert r.status_code == 503
