"""SMS fallback for alerts that cannot sync (SPEC §8.5, ADR-013).

A collector whose alert has been stuck offline for hours sends a structured
SMS from the phone's own SMS app::

    WC1 I:7Q2K ALERT ABIM-ENT-003 20261104T0912Z PH7.1 TDS1820 EC2600 UNSAFE #8F2C1A

- ``I:`` is the installation's short code;
- the time is the test time in UTC;
- readings are optional `CODEvalue` tokens;
- the status is ``UNSAFE``, ``ECOLI`` or ``JUMP``;
- ``#`` carries the first 6 hex characters of HMAC-SHA256(installation
  secret, everything before ``#`` with single spaces).

The server checks the code, then opens a **provisional** alert (stakeholders
are told at once). When the full record syncs, the provisional alert is
closed and linked to the real one: one alert, never two. A forged, malformed
or revoked-installation SMS is refused and logged.
"""

from __future__ import annotations

import hashlib
import hmac
import json
import re
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.core.security import SecretBox
from app.services.alerts import MATCH_WINDOW, add_event, notify_new, reconcile
from app.services.notifications import TRIGGER_TEXT

STATUS_TRIGGER = {"UNSAFE": "unsafe", "ECOLI": "ecoli", "JUMP": "baseline_jump"}
SEVERITY = {"unsafe": "high", "ecoli": "critical", "baseline_jump": "medium"}
_FORMAT = re.compile(
    r"^WC1 I:(?P<inst>[A-Z0-9]{4}) ALERT (?P<source>[A-Z0-9-]{1,40}) "
    r"(?P<time>\d{8}T\d{4}Z)(?P<readings>(?: [A-Z]{1,8}-?\d+(?:\.\d+)?)*) "
    r"(?P<status>UNSAFE|ECOLI|JUMP)(?: A:(?P<actions>[A-Z,]{1,40}))? #(?P<code>[0-9A-F]{6})$"
)


def sms_code(secret: str, message: str) -> str:
    """The 6-hex verification code of an SMS body (everything before ``#``)."""
    canonical = " ".join(message.split())
    return hmac.new(secret.encode(), canonical.encode(), hashlib.sha256).hexdigest()[:6].upper()


@dataclass(frozen=True)
class ParsedSms:
    short_code: str
    source_code: str
    tested_at: datetime
    readings: dict[str, str]
    trigger: str
    actions: tuple[str, ...]
    code: str
    signed_part: str


def parse(body: str) -> ParsedSms | None:
    clean = " ".join(body.strip().upper().split())
    m = _FORMAT.match(clean)
    if m is None:
        return None
    try:
        tested_at = datetime.strptime(m["time"], "%Y%m%dT%H%MZ").replace(tzinfo=UTC)
    except ValueError:
        return None
    readings = {}
    for token in m["readings"].split():
        name = re.match(r"[A-Z]+", token)
        assert name is not None  # noqa: S101 - the pattern guarantees it
        readings[name.group(0).lower()] = token[name.end() :]
    return ParsedSms(
        short_code=m["inst"],
        source_code=m["source"],
        tested_at=tested_at,
        readings=readings,
        trigger=STATUS_TRIGGER[m["status"]],
        actions=tuple(a for a in (m["actions"] or "").split(",") if a),
        code=m["code"],
        signed_part=clean[: clean.rindex(" #")],
    )


@dataclass(frozen=True)
class InboundResult:
    status: str  # accepted | duplicate | rejected
    reason: str | None = None
    alert_id: UUID | None = None


async def receive(
    conn: AsyncConnection,
    box: SecretBox,
    *,
    provider: str,
    provider_id: str | None,
    sender: str | None,
    body: str,
) -> InboundResult:
    """Handles one inbound SMS as the system principal."""
    if provider_id:
        seen = (
            await conn.execute(
                text(
                    "SELECT 1 FROM sms_message WHERE direction = 'inbound' AND provider = :p "
                    "AND provider_id = :id"
                ),
                {"p": provider, "id": provider_id},
            )
        ).first()
        if seen:
            return InboundResult("duplicate", "already_received")

    result, installation_id = await _process(conn, box, body)
    await conn.execute(
        text(
            "INSERT INTO sms_message (direction, provider, provider_id, phone_hash, phone_last3, "
            "body, status, reason, installation_id, alert_id) VALUES ('inbound', :p, :pid, "
            ":ph, :l3, :b, :s, :r, :inst, :a)"
        ),
        {
            "p": provider,
            "pid": provider_id,
            "ph": hashlib.sha256((sender or "").encode()).hexdigest() if sender else None,
            "l3": sender[-3:] if sender else None,
            "b": body[:480],
            "s": result.status,
            "r": result.reason,
            "inst": installation_id,
            "a": result.alert_id,
        },
    )
    if result.status == "rejected":
        await conn.execute(
            text(
                "INSERT INTO audit_log (installation_id, platform, action, entity, after) "
                "VALUES (:i, 'sms', 'sms.rejected', 'sms_message', CAST(:a AS jsonb))"
            ),
            {"i": installation_id, "a": json.dumps({"reason": result.reason})},
        )
    return result


async def _process(
    conn: AsyncConnection, box: SecretBox, body: str
) -> tuple[InboundResult, UUID | None]:
    parsed = parse(body)
    if parsed is None:
        return InboundResult("rejected", "malformed"), None
    inst = (
        await conn.execute(
            text(
                "SELECT id, admin_unit_id, secret_encrypted, revoked_at FROM installation "
                "WHERE short_code = :c"
            ),
            {"c": parsed.short_code},
        )
    ).first()
    if inst is None:
        return InboundResult("rejected", "unknown_installation"), None
    expected = sms_code(box.open(inst.secret_encrypted), parsed.signed_part)
    if not hmac.compare_digest(expected, parsed.code):
        return InboundResult("rejected", "bad_code"), inst.id
    if inst.revoked_at is not None:
        return InboundResult("rejected", "revoked_installation"), inst.id
    source = (
        await conn.execute(
            text("SELECT id FROM water_source WHERE code = :code AND wc_under(village_id, :area)"),
            {"code": parsed.source_code, "area": inst.admin_unit_id},
        )
    ).first()
    if source is None:
        return InboundResult("rejected", "unknown_source"), inst.id

    note = json.dumps({"via": "sms", "readings": parsed.readings, "actions": list(parsed.actions)})
    # The full record arrived first: note the SMS on that alert, no new one.
    existing = (
        await conn.execute(
            text(
                "SELECT id FROM alert WHERE source_id = :s AND trigger_rule = :t "
                "AND NOT provisional AND opened_at BETWEEN :lo AND :hi LIMIT 1"
            ),
            {
                "s": source.id,
                "t": parsed.trigger,
                "lo": parsed.tested_at - MATCH_WINDOW,
                "hi": parsed.tested_at + MATCH_WINDOW,
            },
        )
    ).first()
    if existing is None:
        existing = (
            await conn.execute(
                text(
                    "SELECT id FROM alert WHERE source_id = :s AND trigger_rule = :t "
                    "AND provisional AND sms_code = :c LIMIT 1"
                ),
                {"s": source.id, "t": parsed.trigger, "c": parsed.code},
            )
        ).first()
    if existing is not None:
        await add_event(conn, existing.id, "sms_received", note)
        return InboundResult("duplicate", "already_known", existing.id), inst.id

    alert_id = uuid.uuid4()
    await conn.execute(
        text(
            "INSERT INTO alert (id, source_id, trigger_rule, severity, status, opened_at, "
            "installation_id, provisional, sms_code, server_seq) VALUES (:id, :s, :t, :sev, "
            "'open', :at, :inst, true, :code, 0)"
        ),
        {
            "id": alert_id,
            "s": source.id,
            "t": parsed.trigger,
            "sev": SEVERITY[parsed.trigger],
            "at": parsed.tested_at,
            "inst": inst.id,
            "code": parsed.code,
        },
    )
    await add_event(conn, alert_id, "sms_received", note)
    await notify_new(conn, alert_id)
    return InboundResult("accepted", None, alert_id), inst.id


__all__ = ["MATCH_WINDOW", "TRIGGER_TEXT", "parse", "receive", "reconcile", "sms_code"]
