"""/v1/auth and /v1/me (F-AUTH-1, F-AUTH-3).

Windows and Android Console receive the refresh token in the response body
and keep it in secure storage. The web Console sends
``X-Token-Transport: cookie`` instead: the refresh token is then set as an
httpOnly, SameSite=Strict cookie that scripts cannot read, and refreshing with
it needs the double-submit CSRF token (``wc_csrf`` cookie echoed in
``X-CSRF-Token``) (ADR-010)."""

from __future__ import annotations

import secrets
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Cookie, Header, HTTPException, Request, Response, status
from pydantic import BaseModel, Field
from sqlalchemy import text

from app.api.deps import AnyUserDep, DbDep, SettingsDep, UserDep
from app.core.config import Settings
from app.services.auth import AuthError, AuthService, TokenPair
from app.services.policy import security_policy

router = APIRouter(prefix="/v1", tags=["auth"])

_STATUS = {
    "invalid_credentials": status.HTTP_401_UNAUTHORIZED,
    "invalid_token": status.HTTP_401_UNAUTHORIZED,
    "locked": status.HTTP_423_LOCKED,
    "weak_password": status.HTTP_422_UNPROCESSABLE_CONTENT,
    "same_password": status.HTTP_422_UNPROCESSABLE_CONTENT,
}

REFRESH_COOKIE = "wc_refresh"
CSRF_COOKIE = "wc_csrf"
TransportHeader = Annotated[str | None, Header(alias="X-Token-Transport")]


class LoginRequest(BaseModel):
    username: str = Field(min_length=1, max_length=200)
    password: str = Field(min_length=1, max_length=200)


class RefreshRequest(BaseModel):
    # Absent (or the body is `{}` or empty): the web cookie is used.
    refresh_token: str | None = Field(default=None, min_length=10, max_length=200)


class PasswordHelpRequest(BaseModel):
    username: str = Field(min_length=1, max_length=200)


class ChangePasswordRequest(BaseModel):
    current_password: str = Field(min_length=1, max_length=200)
    new_password: str = Field(min_length=1, max_length=200)


class TokenResponse(BaseModel):
    access_token: str
    # Absent when the refresh token was set as a cookie (web Console).
    refresh_token: str | None = None
    token_type: str = "bearer"  # noqa: S105 - OAuth token type, not a secret
    expires_in: int
    must_change_password: bool

    @classmethod
    def of(cls, pair: TokenPair) -> TokenResponse:
        return cls(
            access_token=pair.access_token,
            refresh_token=pair.refresh_token,
            expires_in=pair.expires_in,
            must_change_password=pair.must_change_password,
        )


class Area(BaseModel):
    id: UUID
    level: str
    name: str
    code: str


# How times are shown; stored per user (UTC underneath). Plain strings in
# the API so clients get readable values.
THEME = r"^(system|light|dark)$"
TIME_ZONE = r"^(auto|Africa/Kampala|Africa/Nairobi|UTC)$"


class MeResponse(BaseModel):
    id: UUID
    username: str
    full_name: str
    organisation: str | None
    position: str | None
    role: str
    must_change_password: bool
    responsibilities: list[str]
    areas: list[Area]
    phone: str | None = None
    email: str | None = None
    # Confirmed with a code (ADR-025); alerts go only to confirmed contacts.
    phone_confirmed: bool = False
    email_confirmed: bool = False
    # Privacy Policy and Terms of Use version accepted (0: never).
    legal_version: int = 0
    notify_email: bool = True
    notify_push: bool = True
    notify_sms: bool = True
    # Set by the IT admin (P11); the Console signs out or locks after it.
    console_idle_minutes: int = 30
    # How this person sees the apps (2026-10-13).
    theme: str = "system"
    time_zone: str = "Africa/Kampala"


class AppearanceIn(BaseModel):
    """Theme and time zone; they follow the person to any device."""

    theme: str = Field(pattern=THEME)
    time_zone: str = Field(pattern=TIME_ZONE)


class PreferencesIn(BaseModel):
    """How the user wants alerts besides the in-app inbox (always on)."""

    notify_email: bool
    notify_push: bool
    notify_sms: bool


def _fail(e: AuthError) -> HTTPException:
    return HTTPException(_STATUS.get(e.code, status.HTTP_400_BAD_REQUEST), e.code)


def _wants_cookie(transport: str | None) -> bool:
    return (transport or "").lower() == "cookie"


def _respond(
    pair: TokenPair, response: Response, settings: Settings, *, cookie: bool
) -> TokenResponse:
    out = TokenResponse.of(pair)
    if not cookie:
        return out
    max_age = settings.refresh_token_days * 86400
    response.set_cookie(
        REFRESH_COOKIE,
        pair.refresh_token,
        max_age=max_age,
        path=settings.refresh_cookie_path,
        secure=settings.cookie_secure,
        httponly=True,
        samesite="strict",
    )
    # Readable by the page so it can echo it back (double-submit CSRF).
    response.set_cookie(
        CSRF_COOKIE,
        secrets.token_urlsafe(24),
        max_age=max_age,
        path="/",
        secure=settings.cookie_secure,
        httponly=False,
        samesite="strict",
    )
    out.refresh_token = None
    return out


def _clear_cookies(response: Response, settings: Settings) -> None:
    response.delete_cookie(REFRESH_COOKIE, path=settings.refresh_cookie_path)
    response.delete_cookie(CSRF_COOKIE, path="/")


def _cookie_token(
    refresh_cookie: str | None, csrf_cookie: str | None, csrf_header: str | None
) -> str:
    if not refresh_cookie:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "invalid_token")
    if (
        not csrf_cookie
        or not csrf_header
        or not secrets.compare_digest(csrf_cookie.encode(), csrf_header.encode())
    ):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "csrf_failed")
    return refresh_cookie


RefreshCookie = Annotated[str | None, Cookie(alias=REFRESH_COOKIE)]
CsrfCookie = Annotated[str | None, Cookie(alias=CSRF_COOKIE)]
CsrfHeader = Annotated[str | None, Header(alias="X-CSRF-Token")]


@router.post("/auth/login")
async def login(
    body: LoginRequest,
    request: Request,
    response: Response,
    db: DbDep,
    settings: SettingsDep,
    transport: TransportHeader = None,
) -> TokenResponse:
    ip = request.client.host if request.client else None
    try:
        pair = await AuthService(db, settings).login(body.username, body.password, ip=ip)
    except AuthError as e:
        raise _fail(e) from e
    return _respond(pair, response, settings, cookie=_wants_cookie(transport))


@router.post("/auth/refresh")
async def refresh(
    response: Response,
    db: DbDep,
    settings: SettingsDep,
    body: RefreshRequest | None = None,
    refresh_cookie: RefreshCookie = None,
    csrf_cookie: CsrfCookie = None,
    csrf_header: CsrfHeader = None,
) -> TokenResponse:
    """With a token in the body: from secure storage (Windows, Android).
    Without one: the web cookie (a `{}` body counts as none)."""
    in_body = body.refresh_token if body else None
    from_cookie = in_body is None
    token = _cookie_token(refresh_cookie, csrf_cookie, csrf_header) if in_body is None else in_body
    try:
        pair = await AuthService(db, settings).refresh(token)
    except AuthError as e:
        if from_cookie:
            _clear_cookies(response, settings)
        raise _fail(e) from e
    return _respond(pair, response, settings, cookie=from_cookie)


@router.post("/auth/change-password")
async def change_password(
    body: ChangePasswordRequest,
    response: Response,
    user: AnyUserDep,
    db: DbDep,
    settings: SettingsDep,
    transport: TransportHeader = None,
) -> TokenResponse:
    if user.user_id is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "not_signed_in")
    try:
        pair = await AuthService(db, settings).change_password(
            user.user_id, body.current_password, body.new_password
        )
    except AuthError as e:
        raise _fail(e) from e
    return _respond(pair, response, settings, cookie=_wants_cookie(transport))


@router.post("/auth/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    response: Response,
    db: DbDep,
    settings: SettingsDep,
    body: RefreshRequest | None = None,
    refresh_cookie: RefreshCookie = None,
    csrf_cookie: CsrfCookie = None,
    csrf_header: CsrfHeader = None,
) -> None:
    in_body = body.refresh_token if body else None
    if in_body is None:
        token = _cookie_token(refresh_cookie, csrf_cookie, csrf_header)
        _clear_cookies(response, settings)
    else:
        token = in_body
    await AuthService(db, settings).logout(token)


@router.post("/auth/password-help", status_code=status.HTTP_202_ACCEPTED)
async def password_help(
    body: PasswordHelpRequest, request: Request, db: DbDep, settings: SettingsDep
) -> None:
    """ "Forgot password": asks the IT admin for a new temporary password.
    Answers the same for unknown usernames."""
    ip = request.client.host if request.client else None
    await AuthService(db, settings).request_password_help(body.username, ip=ip)


@router.get("/me")
async def me(user: AnyUserDep, db: DbDep, settings: SettingsDep) -> MeResponse:
    async with db.transaction(user) as conn:
        row = (
            await conn.execute(
                text(
                    "SELECT id, username, full_name, organisation, position, role, "
                    "must_change_password, phone, email, notify_email, notify_push, notify_sms, "
                    "theme, time_zone, phone_confirmed_at IS NOT NULL AS phone_confirmed, "
                    "email_confirmed_at IS NOT NULL AS email_confirmed, legal_version "
                    "FROM app_user WHERE id = :id"
                ),
                {"id": user.user_id},
            )
        ).one()
        responsibilities = [
            r[0]
            for r in await conn.execute(
                text(
                    "SELECT responsibility_code FROM user_responsibility WHERE user_id = :id "
                    "ORDER BY 1"
                ),
                {"id": user.user_id},
            )
        ]
        areas = [
            Area(id=r.id, level=r.level, name=r.name, code=r.code)
            for r in await conn.execute(
                text(
                    "SELECT a.id, a.level, a.name, a.code FROM user_scope s "
                    "JOIN admin_unit a ON a.id = s.admin_unit_id WHERE s.user_id = :id "
                    "ORDER BY a.name"
                ),
                {"id": user.user_id},
            )
        ]
        policy = await security_policy(conn, settings)
    return MeResponse(
        id=row.id,
        username=row.username,
        full_name=row.full_name,
        organisation=row.organisation,
        position=row.position,
        role=row.role,
        must_change_password=row.must_change_password,
        responsibilities=responsibilities,
        areas=areas,
        phone=row.phone,
        email=row.email,
        phone_confirmed=row.phone_confirmed,
        email_confirmed=row.email_confirmed,
        legal_version=row.legal_version,
        notify_email=row.notify_email,
        notify_push=row.notify_push,
        notify_sms=row.notify_sms,
        theme=row.theme,
        time_zone=row.time_zone,
        console_idle_minutes=policy.console_idle_minutes,
    )


@router.put("/me/appearance", status_code=status.HTTP_204_NO_CONTENT)
async def set_appearance(body: AppearanceIn, user: UserDep, db: DbDep) -> None:
    async with db.transaction(user) as conn:
        await conn.execute(
            text("UPDATE app_user SET theme = :t, time_zone = :z WHERE id = :id"),
            {"t": body.theme, "z": body.time_zone, "id": user.user_id},
        )


@router.put("/me/preferences", status_code=status.HTTP_204_NO_CONTENT)
async def set_preferences(body: PreferencesIn, user: UserDep, db: DbDep) -> None:
    async with db.transaction(user) as conn:
        await conn.execute(
            text(
                "UPDATE app_user SET notify_email = :e, notify_push = :p, notify_sms = :s "
                "WHERE id = :id"
            ),
            {
                "e": body.notify_email,
                "p": body.notify_push,
                "s": body.notify_sms,
                "id": user.user_id,
            },
        )
