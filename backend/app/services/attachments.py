"""Resumable photo uploads through the API (SPEC §8.3, ADR-012).

1. The metadata (id, owner, sha256, size, MIME) arrives by sync push.
2. The phone asks how many bytes the server holds, then sends the rest in
   chunks at that offset, so an interrupted upload continues where it
   stopped.
3. On ``complete`` the server checks size, MIME (magic bytes) and SHA-256,
   writes the photo to object storage and drops the staged chunks. A
   mismatch marks the attachment ``rejected``, with the reason.
"""

from __future__ import annotations

import hashlib
from dataclasses import dataclass
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.services.object_store import ObjectStore

MAX_CHUNK = 256 * 1024
# What a phone may upload, by MIME type, with the file's first bytes.
MAGIC = {"image/jpeg": b"\xff\xd8\xff"}


class AttachmentError(Exception):
    def __init__(self, code: str, received_bytes: int | None = None) -> None:
        super().__init__(code)
        self.code = code
        self.received_bytes = received_bytes


@dataclass(frozen=True)
class UploadState:
    received_bytes: int
    bytes: int
    status: str
    reason: str | None = None


_ROW = "SELECT received_bytes, bytes, upload_status, rejected_reason FROM attachment WHERE id = :id"
_ROW_LOCKED = _ROW + " FOR UPDATE"


async def _row(conn: AsyncConnection, attachment_id: UUID, *, lock: bool = False) -> UploadState:
    row = (await conn.execute(text(_ROW_LOCKED if lock else _ROW), {"id": attachment_id})).first()
    if row is None:
        raise AttachmentError("not_found")
    return UploadState(row[0], row[1], row[2], row[3])


async def state(conn: AsyncConnection, attachment_id: UUID) -> UploadState:
    return await _row(conn, attachment_id)


async def append(
    conn: AsyncConnection, attachment_id: UUID, offset: int, data: bytes
) -> UploadState:
    current = await _row(conn, attachment_id, lock=True)
    if current.status != "pending":
        return current
    if not data:
        raise AttachmentError("empty_chunk", current.received_bytes)
    if len(data) > MAX_CHUNK:
        raise AttachmentError("chunk_too_large", current.received_bytes)
    if offset != current.received_bytes:
        # The phone resumes from what the server holds.
        raise AttachmentError("offset_mismatch", current.received_bytes)
    if offset + len(data) > current.bytes:
        raise AttachmentError("too_many_bytes", current.received_bytes)
    await conn.execute(
        text('INSERT INTO attachment_chunk (attachment_id, "offset", data) VALUES (:id, :o, :d)'),
        {"id": attachment_id, "o": offset, "d": data},
    )
    received = offset + len(data)
    await conn.execute(
        text("UPDATE attachment SET received_bytes = :r WHERE id = :id"),
        {"r": received, "id": attachment_id},
    )
    return UploadState(received, current.bytes, "pending")


async def _reject(conn: AsyncConnection, attachment_id: UUID, reason: str) -> None:
    await conn.execute(
        text("DELETE FROM attachment_chunk WHERE attachment_id = :id"), {"id": attachment_id}
    )
    await conn.execute(
        text(
            "UPDATE attachment SET upload_status = 'rejected', rejected_reason = :r WHERE id = :id"
        ),
        {"r": reason, "id": attachment_id},
    )


async def complete(conn: AsyncConnection, store: ObjectStore, attachment_id: UUID) -> UploadState:
    current = await _row(conn, attachment_id, lock=True)
    if current.status != "pending":
        return current  # idempotent
    if current.received_bytes != current.bytes:
        raise AttachmentError("incomplete", current.received_bytes)
    meta = (
        await conn.execute(
            text("SELECT sha256, mime, object_key FROM attachment WHERE id = :id"),
            {"id": attachment_id},
        )
    ).one()
    chunks = await conn.execute(
        text('SELECT data FROM attachment_chunk WHERE attachment_id = :id ORDER BY "offset"'),
        {"id": attachment_id},
    )
    data = b"".join(bytes(r[0]) for r in chunks)
    reason = None
    if len(data) != current.bytes:
        reason = "size_mismatch"
    elif hashlib.sha256(data).hexdigest() != meta.sha256:
        reason = "hash_mismatch"
    elif not data.startswith(MAGIC.get(meta.mime, b"\x00invalid")):
        reason = "not_an_image"
    if reason:
        await _reject(conn, attachment_id, reason)
        return UploadState(current.received_bytes, current.bytes, "rejected", reason)
    # If storage fails the transaction rolls back and the phone retries.
    await store.put(meta.object_key, data, meta.mime)
    await conn.execute(
        text("DELETE FROM attachment_chunk WHERE attachment_id = :id"), {"id": attachment_id}
    )
    await conn.execute(
        text(
            "UPDATE attachment SET upload_status = 'uploaded', uploaded_at = now() WHERE id = :id"
        ),
        {"id": attachment_id},
    )
    return UploadState(current.bytes, current.bytes, "uploaded")


async def content(
    conn: AsyncConnection, store: ObjectStore, attachment_id: UUID
) -> tuple[bytes, str]:
    row = (
        await conn.execute(
            text("SELECT upload_status, object_key, mime FROM attachment WHERE id = :id"),
            {"id": attachment_id},
        )
    ).first()
    if row is None or row.upload_status != "uploaded":
        raise AttachmentError("not_found")
    data = await store.get(row.object_key)
    if data is None:
        raise AttachmentError("not_found")
    return data, row.mime
