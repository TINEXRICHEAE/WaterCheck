"""Passwords, tokens and secrets (SPEC §9.1, ADR-009)."""

from __future__ import annotations

import hashlib
import hmac
import secrets
import string
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import UUID

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError
from cryptography.fernet import Fernet

from app.core.config import Settings

_hasher = PasswordHasher()  # argon2id with library defaults
_ALGORITHM = "HS256"
MIN_PASSWORD_LENGTH = 10


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password_hash: str, password: str) -> bool:
    try:
        return _hasher.verify(password_hash, password)
    except (VerificationError, InvalidHashError):
        return False


def temporary_password(length: int = 12) -> str:
    """Readable temporary password (no 0/O/1/l) for an admin to hand over."""
    alphabet = "".join(c for c in string.ascii_letters + string.digits if c not in "0O1lI")
    return "".join(secrets.choice(alphabet) for _ in range(length))


def password_problem(password: str) -> str | None:
    if len(password) < MIN_PASSWORD_LENGTH:
        return f"Use at least {MIN_PASSWORD_LENGTH} characters"
    if password.isdigit() or password.isalpha():
        return "Use both letters and numbers"
    return None


def new_token() -> str:
    """High-entropy opaque token (refresh tokens, activation codes)."""
    return secrets.token_urlsafe(32)


def token_hash(token: str) -> str:
    """SHA-256 is enough for high-entropy random tokens (not for passwords)."""
    return hashlib.sha256(token.encode()).hexdigest()


@dataclass(frozen=True)
class AccessClaims:
    user_id: UUID
    role: str
    scope_units: tuple[UUID, ...]
    must_change_password: bool


def issue_access_token(settings: Settings, claims: AccessClaims, now: datetime) -> str:
    payload: dict[str, Any] = {
        "sub": str(claims.user_id),
        "role": claims.role,
        "scope": [str(u) for u in claims.scope_units],
        "mcp": claims.must_change_password,
        "typ": "access",
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=settings.access_token_minutes)).timestamp()),
    }
    return jwt.encode(payload, settings.jwt_secret.get_secret_value(), algorithm=_ALGORITHM)


def read_access_token(settings: Settings, token: str) -> AccessClaims:
    """Raises ``jwt.PyJWTError`` when invalid or expired."""
    data = jwt.decode(
        token,
        settings.jwt_secret.get_secret_value(),
        algorithms=[_ALGORITHM],
        options={"require": ["exp", "sub", "typ"]},
    )
    if data.get("typ") != "access":
        raise jwt.InvalidTokenError("not an access token")
    return AccessClaims(
        user_id=UUID(data["sub"]),
        role=data["role"],
        scope_units=tuple(UUID(u) for u in data.get("scope", [])),
        must_change_password=bool(data.get("mcp", False)),
    )


def utcnow() -> datetime:
    return datetime.now(UTC)


class SecretBox:
    """Encrypts installation secrets at rest; the server needs the plain
    secret to verify request signatures and SMS codes (ADR-009)."""

    def __init__(self, key: str) -> None:
        self._fernet = Fernet(key.encode())

    def seal(self, secret: str) -> str:
        return self._fernet.encrypt(secret.encode()).decode()

    def open(self, sealed: str) -> str:
        return self._fernet.decrypt(sealed.encode()).decode()


def sign_request(
    secret: str, method: str, path: str, timestamp: str, body: bytes, nonce: str | None = None
) -> str:
    """HMAC-SHA256 over method, path (with query string), timestamp, the body
    hash and, when sent, a random nonce. The nonce makes two identical
    requests in the same second sign differently (ADR-011)."""
    parts = [method.upper(), path, timestamp, hashlib.sha256(body).hexdigest()]
    if nonce:
        parts.append(nonce)
    message = "\n".join(parts).encode()
    return hmac.new(secret.encode(), message, hashlib.sha256).hexdigest()


def signatures_match(a: str, b: str) -> bool:
    return hmac.compare_digest(a, b)
