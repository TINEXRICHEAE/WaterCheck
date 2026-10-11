"""/v1/attachments: resumable photo upload and download (SPEC §8.3, ADR-012)."""

from __future__ import annotations

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, Request, Response, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from app.api.deps import DbDep
from app.api.reference import AnyPrincipal
from app.services import attachments
from app.services.attachments import MAX_CHUNK, AttachmentError, UploadState
from app.services.object_store import ObjectStore

router = APIRouter(prefix="/v1/attachments", tags=["attachments"])

_STATUS = {
    "not_found": status.HTTP_404_NOT_FOUND,
    "offset_mismatch": status.HTTP_409_CONFLICT,
    "incomplete": status.HTTP_409_CONFLICT,
    "chunk_too_large": status.HTTP_413_CONTENT_TOO_LARGE,
    "too_many_bytes": status.HTTP_422_UNPROCESSABLE_CONTENT,
    "empty_chunk": status.HTTP_422_UNPROCESSABLE_CONTENT,
}


class UploadStateOut(BaseModel):
    received_bytes: int
    bytes: int
    # `pending`, `uploaded` or `rejected`.
    status: str
    reason: str | None = None

    @classmethod
    def of(cls, s: UploadState) -> UploadStateOut:
        return cls(received_bytes=s.received_bytes, bytes=s.bytes, status=s.status, reason=s.reason)


def _fail(e: AttachmentError) -> JSONResponse:
    # The current offset tells the phone where to resume.
    return JSONResponse(
        {"detail": e.code, "received_bytes": e.received_bytes},
        status_code=_STATUS.get(e.code, status.HTTP_400_BAD_REQUEST),
    )


def _store(request: Request) -> ObjectStore:
    store: ObjectStore | None = request.app.state.store
    if store is None:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "storage_unavailable")
    return store


@router.get("/{attachment_id}/upload")
async def upload_state(attachment_id: UUID, principal: AnyPrincipal, db: DbDep) -> UploadStateOut:
    """How many bytes the server holds: the phone resumes from here."""
    try:
        async with db.transaction(principal) as conn:
            return UploadStateOut.of(await attachments.state(conn, attachment_id))
    except AttachmentError as e:
        raise HTTPException(_STATUS.get(e.code, 400), e.code) from e


@router.put(
    "/{attachment_id}/upload",
    response_model=UploadStateOut,
    responses={409: {"description": "offset_mismatch: resume at received_bytes"}},
    openapi_extra={
        "requestBody": {
            "required": True,
            "content": {
                "application/octet-stream": {"schema": {"type": "string", "format": "binary"}}
            },
        }
    },
)
async def upload_chunk(
    attachment_id: UUID,
    request: Request,
    principal: AnyPrincipal,
    db: DbDep,
    offset: Annotated[int, Query(ge=0)],
) -> UploadStateOut | JSONResponse:
    """Appends up to 256 KB at `offset` (signed like every Collect request)."""
    data = await request.body()
    if len(data) > MAX_CHUNK:
        return _fail(AttachmentError("chunk_too_large"))
    try:
        async with db.transaction(principal) as conn:
            return UploadStateOut.of(await attachments.append(conn, attachment_id, offset, data))
    except AttachmentError as e:
        return _fail(e)


@router.post("/{attachment_id}/complete", response_model=UploadStateOut)
async def complete_upload(
    attachment_id: UUID, request: Request, principal: AnyPrincipal, db: DbDep
) -> UploadStateOut | JSONResponse:
    """Verifies size, type and SHA-256, then stores the photo."""
    store = _store(request)
    try:
        async with db.transaction(principal) as conn:
            return UploadStateOut.of(await attachments.complete(conn, store, attachment_id))
    except AttachmentError as e:
        return _fail(e)


@router.get(
    "/{attachment_id}/content",
    response_class=Response,
    responses={200: {"content": {"image/jpeg": {}}}},
)
async def attachment_content(
    attachment_id: UUID, request: Request, principal: AnyPrincipal, db: DbDep
) -> Response:
    """The photo, for anyone who can see its source or test."""
    store = _store(request)
    try:
        async with db.transaction(principal) as conn:
            data, mime = await attachments.content(conn, store, attachment_id)
    except AttachmentError as e:
        raise HTTPException(status.HTTP_404_NOT_FOUND, e.code) from e
    return Response(data, media_type=mime, headers={"Cache-Control": "private, max-age=86400"})
