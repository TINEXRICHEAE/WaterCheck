"""The Africa's Talking SMS adapter, against a mocked API (ADR-013)."""

from urllib.parse import parse_qs

import httpx2
import pytest
from pydantic import SecretStr

from app.core.config import Settings
from app.services.channels import AfricasTalkingGateway, ChannelError, Outgoing, channels_from


def _settings(**extra: object) -> Settings:
    return Settings(
        environment="test",
        sms_provider="africastalking",
        sms_username="sandbox",
        sms_api_key=SecretStr("test-only-key"),
        **extra,  # type: ignore[arg-type]
    )


async def test_sends_through_the_sandbox() -> None:
    seen: list[httpx2.Request] = []

    def handler(request: httpx2.Request) -> httpx2.Response:
        seen.append(request)
        return httpx2.Response(
            201,
            json={
                "SMSMessageData": {"Recipients": [{"status": "Success", "messageId": "ATXid_1"}]}
            },
        )

    gateway = AfricasTalkingGateway(_settings(), transport=httpx2.MockTransport(handler))
    msg_id = await gateway.send(Outgoing("+256700000123", "Alert", "Unsafe water at X"))
    assert msg_id == "ATXid_1"
    request = seen[0]
    assert str(request.url) == "https://api.sandbox.africastalking.com/version1/messaging"
    assert request.headers["apiKey"] == "test-only-key"
    form = parse_qs(request.content.decode())
    assert form == {
        "username": ["sandbox"],
        "to": ["+256700000123"],
        "message": ["Unsafe water at X"],
    }


@pytest.mark.parametrize(
    ("status", "body"),
    [
        (401, {"error": "bad key"}),
        (201, {"SMSMessageData": {"Recipients": [{"status": "InvalidPhoneNumber"}]}}),
    ],
)
async def test_refusals_are_retryable_errors(status: int, body: dict[str, object]) -> None:
    gateway = AfricasTalkingGateway(
        _settings(),
        transport=httpx2.MockTransport(lambda _: httpx2.Response(status, json=body)),
    )
    with pytest.raises(ChannelError):
        await gateway.send(Outgoing("+256700000123", "t", "b"))


def test_channels_are_configured_from_settings() -> None:
    assert channels_from(Settings(environment="test")).sms is None
    configured = channels_from(_settings(smtp_host="mailpit"))
    assert isinstance(configured.sms, AfricasTalkingGateway)
    assert configured.email is not None
    assert configured.push is None  # no Firebase key yet
