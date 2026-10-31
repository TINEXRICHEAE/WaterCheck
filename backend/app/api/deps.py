"""Request dependencies: database, settings and the acting principal."""

from __future__ import annotations

from typing import Annotated

import jwt
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import Settings
from app.core.security import read_access_token
from app.db.database import Database, Principal

_bearer = HTTPBearer(auto_error=False)


def get_db(request: Request) -> Database:
    db: Database | None = request.app.state.db
    if db is None:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "database_not_configured")
    return db


def get_settings_dep(request: Request) -> Settings:
    settings: Settings = request.app.state.settings
    return settings


DbDep = Annotated[Database, Depends(get_db)]
SettingsDep = Annotated[Settings, Depends(get_settings_dep)]


def _user_principal(
    settings: Settings,
    credentials: HTTPAuthorizationCredentials | None,
    *,
    allow_password_change_only: bool,
) -> Principal:
    if credentials is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "not_signed_in")
    try:
        claims = read_access_token(settings, credentials.credentials)
    except jwt.PyJWTError as e:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "invalid_token") from e
    if claims.must_change_password and not allow_password_change_only:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "password_change_required")
    return Principal(
        kind="user",
        user_id=claims.user_id,
        role=claims.role,
        scope_units=claims.scope_units,
        side=claims.side,
        session_id=claims.session_id,
    )


def current_user(
    settings: SettingsDep,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
) -> Principal:
    """A signed-in user who has set their own password."""
    return _user_principal(settings, credentials, allow_password_change_only=False)


def current_user_any(
    settings: SettingsDep,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
) -> Principal:
    """A signed-in user, even one who must still change a temporary password."""
    return _user_principal(settings, credentials, allow_password_change_only=True)


def current_admin(principal: Annotated[Principal, Depends(current_user)]) -> Principal:
    if not principal.is_admin:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "admin_only")
    return principal


def current_researcher(principal: Annotated[Principal, Depends(current_user)]) -> Principal:
    """A Research account or an IT admin (ADR-031)."""
    if principal.side not in ("research", "all"):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "research_accounts_only")
    return principal


UserDep = Annotated[Principal, Depends(current_user)]
ResearcherDep = Annotated[Principal, Depends(current_researcher)]
AnyUserDep = Annotated[Principal, Depends(current_user_any)]
AdminDep = Annotated[Principal, Depends(current_admin)]
