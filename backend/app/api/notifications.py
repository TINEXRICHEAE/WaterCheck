"""/v1/notifications, /v1/push-tokens and the SMS webhook (F-ALR-4, §8.5)."""

from __future__ import annotations

import hmac
from datetime import datetime
from enum import StrEnum
from typing import Annotated, Literal
from urllib.parse import parse_qs
from uuid import UUID

import structlog
from fastapi import APIRouter, HTTPException, Query, Request, status
from pydantic import BaseModel, Field
from sqlalchemy import text

from app.api.deps import DbDep, SettingsDep, UserDep
from app.core.security import SecretBox
from app.db.database import Principal
from app.services import sms

log = structlog.get_logger()
router = APIRouter(prefix="/v1", tags=["notifications"])


class NotificationOut(BaseModel):
    id: UUID
    alert_id: UUID | None
    kind: str
    title: str
    body: str
    created_at: datetime
    read_at: datetime | None


class Inbox(BaseModel):
    unread: int
    items: list[NotificationOut]


class PushTokenIn(BaseModel):
    token: str = Field(min_length=10, max_length=4096)
    platform: Literal["android", "web"]


class SmsProviderName(StrEnum):
    """Inbound SMS adapters (``test`` is the fake used in tests)."""

    AFRICASTALKING = "africastalking"
    TEST = "test"


class SmsAck(BaseModel):
    status: str
    reason: str | None = None


@router.get("/notifications")
async def inbox(user: UserDep, db: DbDep, limit: Annotated[int, Query(ge=1, le=200)] = 50) -> Inbox:
    """The signed-in user's in-app notifications, newest first."""
    async with db.transaction(user) as conn:
        rows = await conn.execute(
            text(
                "SELECT id, alert_id, kind, title, body, created_at, read_at FROM notification "
                "WHERE user_id = :u AND channel = 'in_app' ORDER BY created_at DESC LIMIT :n"
            ),
            {"u": user.user_id, "n": limit},
        )
        items = [NotificationOut(**r._mapping) for r in rows]
        unread = (
            await conn.execute(
                text(
                    "SELECT count(*) FROM notification WHERE user_id = :u "
                    "AND channel = 'in_app' AND read_at IS NULL"
                ),
                {"u": user.user_id},
            )
        ).scalar_one()
    return Inbox(unread=unread, items=items)


@router.post("/notifications/{notification_id}/read", status_code=status.HTTP_204_NO_CONTENT)
async def mark_read(notification_id: UUID, user: UserDep, db: DbDep) -> None:
    async with db.transaction(user) as conn:
        await conn.execute(
            text(
                "UPDATE notification SET read_at = coalesce(read_at, now()) "
                "WHERE id = :id AND user_id = :u"
            ),
            {"id": notification_id, "u": user.user_id},
        )


@router.post("/notifications/read-all", status_code=status.HTTP_204_NO_CONTENT)
async def mark_all_read(user: UserDep, db: DbDep) -> None:
    async with db.transaction(user) as conn:
        await conn.execute(
            text(
                "UPDATE notification SET read_at = now() WHERE user_id = :u "
                "AND channel = 'in_app' AND read_at IS NULL"
            ),
            {"u": user.user_id},
        )


@router.post("/push-tokens", status_code=status.HTTP_204_NO_CONTENT)
async def register_push_token(body: PushTokenIn, user: UserDep, db: DbDep) -> None:
    """Registers this device for push (FCM; Android and web Console)."""
    async with db.transaction(user) as conn:
        await conn.execute(
            text(
                "INSERT INTO push_token (token, user_id, platform) VALUES (:t, :u, :p) "
                "ON CONFLICT (token) DO UPDATE SET user_id = EXCLUDED.user_id, "
                "last_seen_at = now()"
            ),
            {"t": body.token, "u": user.user_id, "p": body.platform},
        )


@router.delete("/push-tokens/{token}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_push_token(token: str, user: UserDep, db: DbDep) -> None:
    async with db.transaction(user) as conn:
        await conn.execute(
            text("DELETE FROM push_token WHERE token = :t AND user_id = :u"),
            {"t": token, "u": user.user_id},
        )


@router.post("/sms/inbound/{provider}")
async def sms_inbound(
    provider: SmsProviderName,
    request: Request,
    db: DbDep,
    settings: SettingsDep,
    token: Annotated[str, Query(max_length=200)],
) -> SmsAck:
    """Webhook for incoming SMS (form-encoded: ``from``, ``text``, ``id``).

    The provider does not sign callbacks, so the URL carries a secret token.
    The SMS itself must carry the installation's HMAC code (§8.5).
    """
    expected = settings.sms_webhook_token.get_secret_value()
    if not hmac.compare_digest(token.encode(), expected.encode()):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "bad_token")
    fields = {k: v[0] for k, v in parse_qs((await request.body()).decode(errors="replace")).items()}
    body = fields.get("text", "")
    if not body:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "no_text")
    async with db.transaction(Principal.system()) as conn:
        result = await sms.receive(
            conn,
            SecretBox(settings.secret_key.get_secret_value()),
            provider=provider.value,
            provider_id=fields.get("id"),
            sender=fields.get("from"),
            body=body,
        )
    log.info("sms_inbound", provider=provider.value, status=result.status, reason=result.reason)
    return SmsAck(status=result.status, reason=result.reason)
