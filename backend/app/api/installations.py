"""Collect activation, signed requests and admin control (F-AUTH-4/7, F-ADM-4)."""

from __future__ import annotations

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel, Field
from sqlalchemy import text

from app.api.deps import AdminDep, DbDep, SettingsDep
from app.db.database import Principal
from app.services.installations import (
    InstallationError,
    InstallationService,
    create_activation_code,
    ensure_short_code,
)

router = APIRouter(prefix="/v1", tags=["installations"])

_STATUS = {
    "invalid_code": status.HTTP_404_NOT_FOUND,
    "expired_code": status.HTTP_410_GONE,
    "code_used_up": status.HTTP_409_CONFLICT,
    "unknown_area": status.HTTP_404_NOT_FOUND,
    "unsigned_request": status.HTTP_401_UNAUTHORIZED,
    "stale_request": status.HTTP_401_UNAUTHORIZED,
    "invalid_signature": status.HTTP_401_UNAUTHORIZED,
    "replayed_request": status.HTTP_401_UNAUTHORIZED,
    # 403 with this code tells Collect to offer export, then wipe (F-AUTH-4).
    "installation_revoked": status.HTTP_403_FORBIDDEN,
}


def _fail(e: InstallationError) -> HTTPException:
    return HTTPException(_STATUS.get(e.code, status.HTTP_400_BAD_REQUEST), e.code)


async def current_installation(request: Request, db: DbDep, settings: SettingsDep) -> Principal:
    """A request signed by an activated, non-revoked Collect installation."""
    try:
        return await InstallationService(db, settings).verify(
            installation_id=request.headers.get("x-installation-id"),
            timestamp=request.headers.get("x-timestamp"),
            signature=request.headers.get("x-signature"),
            method=request.method,
            # The query string is signed too (stream, cursor, …).
            path=request.url.path + (f"?{request.url.query}" if request.url.query else ""),
            body=await request.body(),
            nonce=request.headers.get("x-nonce"),
        )
    except InstallationError as e:
        raise _fail(e) from e


InstallationDep = Annotated[Principal, Depends(current_installation)]


class ActivateRequest(BaseModel):
    code: str = Field(min_length=4, max_length=40)
    platform: str | None = Field(default=None, max_length=40)
    app_version: str | None = Field(default=None, max_length=40)


class AreaOut(BaseModel):
    id: UUID
    code: str
    name: str
    level: str


class ActivateResponse(BaseModel):
    installation_id: UUID
    # Shown once; Collect keeps it in secure storage and signs every request.
    secret: str
    area: AreaOut
    server_time: datetime
    # Short ID used in the SMS fallback (SPEC §8.5).
    short_code: str


class InstallationMe(BaseModel):
    installation_id: UUID
    area: AreaOut
    short_code: str


class NewCodeRequest(BaseModel):
    area_code: str
    max_installations: int = Field(default=5, ge=1, le=100)
    expires_in_days: int | None = Field(default=None, ge=1, le=60)


class NewCodeResponse(BaseModel):
    id: UUID
    code: str
    expires_at: datetime
    max_installations: int


@router.post("/installations/activate")
async def activate(body: ActivateRequest, db: DbDep, settings: SettingsDep) -> ActivateResponse:
    try:
        a = await InstallationService(db, settings).activate(
            body.code, platform=body.platform, app_version=body.app_version
        )
    except InstallationError as e:
        raise _fail(e) from e
    return ActivateResponse(
        installation_id=a.installation_id,
        secret=a.secret,
        area=AreaOut(id=a.area_id, code=a.area_code, name=a.area_name, level=a.area_level),
        server_time=a.server_time,
        short_code=a.short_code,
    )


@router.get("/installations/me")
async def installation_me(installation: InstallationDep, db: DbDep) -> InstallationMe:
    async with db.transaction(installation) as conn:
        area = (
            await conn.execute(
                text(
                    "SELECT a.id, a.code, a.name, a.level FROM installation i "
                    "JOIN admin_unit a ON a.id = i.admin_unit_id WHERE i.id = :id"
                ),
                {"id": installation.installation_id},
            )
        ).one()
        assert installation.installation_id is not None  # noqa: S101 - set by verify()
        short_code = await ensure_short_code(conn, installation.installation_id)
    assert installation.installation_id is not None  # noqa: S101 - set by verify()
    return InstallationMe(
        installation_id=installation.installation_id,
        area=AreaOut(id=area.id, code=area.code, name=area.name, level=area.level),
        short_code=short_code,
    )


@router.post("/admin/activation-codes", status_code=status.HTTP_201_CREATED)
async def new_activation_code(
    body: NewCodeRequest, admin: AdminDep, db: DbDep, settings: SettingsDep
) -> NewCodeResponse:
    try:
        async with db.transaction(admin) as conn:
            issued = await create_activation_code(
                conn,
                settings,
                area_code=body.area_code,
                created_by=admin.user_id,
                max_installations=body.max_installations,
                days=body.expires_in_days,
            )
    except InstallationError as e:
        raise _fail(e) from e
    return NewCodeResponse(
        id=issued.id,
        code=issued.code,
        expires_at=issued.expires_at,
        max_installations=issued.max_installations,
    )


@router.post(
    "/admin/installations/{installation_id}/revoke", status_code=status.HTTP_204_NO_CONTENT
)
async def revoke_installation(
    installation_id: UUID, admin: AdminDep, db: DbDep, settings: SettingsDep
) -> None:
    if not await InstallationService(db, settings).revoke(installation_id, by=admin.user_id):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found_or_already_revoked")
