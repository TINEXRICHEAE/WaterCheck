"""How notifications leave the server (SPEC §4.7, F-ALR-4, ADR-013).

Each channel has a real adapter and a fake for tests:

- email: SMTP (Mailpit in dev, a transactional provider in production);
- push: Firebase Cloud Messaging HTTP v1 (Android and web Console; not
  Windows, errata G14, where in-app and email cover it);
- SMS: a provider-agnostic ``SmsGateway`` (Africa's Talking first, §8.5).

Credentials come from settings (``infra/.env``), never the repository. A
channel without credentials is simply not configured.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from email.message import EmailMessage
from typing import Protocol

import aiosmtplib
import anyio
import httpx2

from app.core.config import Settings


class ChannelError(Exception):
    """A delivery failed and may be retried."""


@dataclass(frozen=True)
class Outgoing:
    to: str
    title: str
    body: str
    data: dict[str, str] = field(default_factory=dict)


class EmailSender(Protocol):
    async def send(self, message: Outgoing) -> str | None: ...


class PushSender(Protocol):
    async def send(self, message: Outgoing) -> str | None: ...


class SmsGateway(Protocol):
    name: str

    async def send(self, message: Outgoing) -> str | None:
        """Sends one SMS; returns the provider's message ID."""
        ...


# ------------------------------------------------------------------ email
class SmtpEmailSender:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    async def send(self, message: Outgoing) -> str | None:
        email = EmailMessage()
        email["From"] = self.settings.smtp_from
        email["To"] = message.to
        email["Subject"] = message.title
        email.set_content(message.body)
        try:
            await aiosmtplib.send(
                email,
                hostname=self.settings.smtp_host,
                port=self.settings.smtp_port,
                username=self.settings.smtp_username or None,
                password=self.settings.smtp_password.get_secret_value() or None,
                start_tls=self.settings.smtp_starttls,
                timeout=30,
            )
        except (aiosmtplib.SMTPException, OSError) as e:
            raise ChannelError(f"smtp: {type(e).__name__}") from e
        return None


# ------------------------------------------------------------------- push
class FcmPushSender:
    """FCM HTTP v1 with a service-account key file."""

    def __init__(self, settings: Settings) -> None:
        from google.oauth2 import service_account

        path = settings.fcm_service_account_file
        assert path is not None  # noqa: S101 - only built when configured
        self._credentials = service_account.Credentials.from_service_account_file(  # type: ignore[no-untyped-call]
            path, scopes=["https://www.googleapis.com/auth/firebase.messaging"]
        )
        with open(path, encoding="utf-8") as f:
            self._project = json.load(f)["project_id"]

    async def _token(self) -> str:
        from google.auth.transport.requests import Request

        def refresh() -> str:
            if not self._credentials.valid:
                self._credentials.refresh(Request())
            token: str = self._credentials.token
            return token

        return await anyio.to_thread.run_sync(refresh)

    async def send(self, message: Outgoing) -> str | None:
        url = f"https://fcm.googleapis.com/v1/projects/{self._project}/messages:send"
        body = {
            "message": {
                "token": message.to,
                "notification": {"title": message.title, "body": message.body},
                "data": message.data,
            }
        }
        async with httpx2.AsyncClient(timeout=30) as client:
            r = await client.post(
                url, json=body, headers={"Authorization": f"Bearer {await self._token()}"}
            )
        if r.status_code >= 400:
            raise ChannelError(f"fcm: {r.status_code}")
        name: str | None = r.json().get("name")
        return name


# -------------------------------------------------------------------- SMS
class AfricasTalkingGateway:
    """Africa's Talking bulk SMS (sandbox or live)."""

    name = "africastalking"

    def __init__(
        self, settings: Settings, transport: httpx2.AsyncBaseTransport | None = None
    ) -> None:
        self.settings = settings
        self._transport = transport
        sandbox = settings.sms_username == "sandbox"
        self.url = (
            "https://api.sandbox.africastalking.com/version1/messaging"
            if sandbox
            else "https://api.africastalking.com/version1/messaging"
        )

    async def send(self, message: Outgoing) -> str | None:
        form = {"username": self.settings.sms_username, "to": message.to, "message": message.body}
        if self.settings.sms_sender_id:
            form["from"] = self.settings.sms_sender_id
        async with httpx2.AsyncClient(timeout=30, transport=self._transport) as client:
            r = await client.post(
                self.url,
                data=form,
                headers={
                    "apiKey": self.settings.sms_api_key.get_secret_value(),
                    "Accept": "application/json",
                },
            )
        if r.status_code >= 400:
            raise ChannelError(f"africastalking: {r.status_code}")
        recipients = r.json().get("SMSMessageData", {}).get("Recipients", [])
        if not recipients or recipients[0].get("status") != "Success":
            raise ChannelError("africastalking: not accepted")
        msg_id: str | None = recipients[0].get("messageId")
        return msg_id


# ------------------------------------------------------------------ fakes
@dataclass
class FakeSender:
    """Records what would have been sent; can be told to fail."""

    name: str = "fake"
    sent: list[Outgoing] = field(default_factory=list)
    fail: bool = False

    async def send(self, message: Outgoing) -> str | None:
        if self.fail:
            raise ChannelError(f"{self.name}: failing on purpose")
        self.sent.append(message)
        return f"{self.name}-{len(self.sent)}"


@dataclass
class Channels:
    email: EmailSender | None = None
    push: PushSender | None = None
    sms: SmsGateway | None = None


def channels_from(settings: Settings) -> Channels:
    sms: SmsGateway | None = None
    if settings.sms_provider == "africastalking" and settings.sms_username:
        sms = AfricasTalkingGateway(settings)
    return Channels(
        email=SmtpEmailSender(settings) if settings.smtp_host else None,
        push=FcmPushSender(settings) if settings.fcm_service_account_file else None,
        sms=sms,
    )
