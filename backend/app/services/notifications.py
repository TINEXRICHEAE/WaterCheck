"""Who is told about an alert, how, and escalation (SPEC §4.7, F-ALR-4).

- **Recipients:** active stakeholders whose area covers the source and whose
  responsibilities match the alert's routing rules. A stakeholder with no
  responsibilities set, or an alert type with no rule, reaches everyone in
  the area (SPEC §4.7 default).
- **Escalation:** an alert still not acknowledged after
  `escalation_hours[n]` reaches level n+1, which re-notifies and widens the
  circle: level 1 adds everyone at district level or above, level 2 the IT
  admins.
- **Channels:** in-app always; email when an address is known; push to
  registered devices; SMS for severities listed in the configuration. Each
  delivery is its own job, so one failing channel never blocks the others.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.services.channels import ChannelError, Channels, Outgoing
from app.services.jobs import enqueue

TRIGGER_TEXT = {
    "ecoli": "E. coli detected",
    "unsafe": "Unsafe water result",
    "baseline_jump": "Sudden change from the usual readings",
    "sms": "Alert reported by SMS",
}


@dataclass(frozen=True)
class Recipient:
    user_id: UUID
    email: str | None
    phone: str | None
    notify_email: bool = True
    notify_push: bool = True
    notify_sms: bool = True


async def config(conn: AsyncConnection) -> dict[str, Any]:
    doc = (
        await conn.execute(text("SELECT document FROM config_document WHERE key = 'notifications'"))
    ).scalar_one_or_none()
    if doc is None:
        return {"escalation_hours": [48, 96], "channels": {"sms_for_severities": ["critical"]}}
    result: dict[str, Any] = json.loads(doc) if isinstance(doc, str) else doc
    return result


async def recipients(conn: AsyncConnection, alert_id: UUID, level: int) -> list[Recipient]:
    rows = await conn.execute(
        text(
            """
            WITH a AS (
              SELECT al.trigger_rule, w.village_id FROM alert al
              JOIN water_source w ON w.id = al.source_id WHERE al.id = :id
            ),
            routed AS (
              SELECT responsibility_code FROM alert_routing_rule r, a
              WHERE r.trigger_rule = a.trigger_rule
            )
            SELECT DISTINCT u.id, coalesce(u.email, CASE WHEN u.username LIKE '%@%'
                   THEN u.username END) AS email,
                   coalesce(u.phone, CASE WHEN u.username LIKE '+%'
                   THEN u.username END) AS phone,
                   u.notify_email, u.notify_push, u.notify_sms
            FROM app_user u, a
            WHERE u.is_active AND (
              -- Level 0: stakeholders in the area with a routed responsibility.
              (u.role = 'stakeholder'
               AND EXISTS (SELECT 1 FROM user_scope s
                           WHERE s.user_id = u.id AND wc_under(a.village_id, s.admin_unit_id))
               AND (NOT EXISTS (SELECT 1 FROM routed)
                    -- No responsibilities set: everything in the area.
                    OR NOT EXISTS (SELECT 1 FROM user_responsibility ur0
                                   WHERE ur0.user_id = u.id)
                    OR EXISTS (SELECT 1 FROM user_responsibility ur JOIN routed rt
                               ON rt.responsibility_code = ur.responsibility_code
                               WHERE ur.user_id = u.id)))
              -- Level 1: anyone covering it from district level or above.
              OR (:level >= 1 AND EXISTS (
                    SELECT 1 FROM user_scope s JOIN admin_unit au ON au.id = s.admin_unit_id
                    WHERE s.user_id = u.id AND wc_under(a.village_id, s.admin_unit_id)
                      AND au.level IN ('district', 'region', 'country', 'national')))
              -- Level 2: the IT admins.
              OR (:level >= 2 AND u.role = 'it_admin')
            )
            ORDER BY u.id
            """
        ),
        {"id": alert_id, "level": level},
    )
    return [
        Recipient(r.id, r.email, r.phone, r.notify_email, r.notify_push, r.notify_sms) for r in rows
    ]


async def _message(conn: AsyncConnection, alert_id: UUID, level: int) -> tuple[str, str, str]:
    a = (
        await conn.execute(
            text(
                "SELECT al.trigger_rule, al.severity, al.opened_at, al.provisional, w.code, "
                "w.name, v.name AS village FROM alert al "
                "JOIN water_source w ON w.id = al.source_id "
                "JOIN admin_unit v ON v.id = w.village_id WHERE al.id = :id"
            ),
            {"id": alert_id},
        )
    ).one()
    what = TRIGGER_TEXT.get(a.trigger_rule, a.trigger_rule)
    where = f"{a.name} ({a.code})" if a.name else a.code
    prefix = f"ESCALATED (level {level}): " if level else ""
    title = f"{prefix}{what}: {where}, {a.village}"
    body = (
        f"{what} at {where} in {a.village}, reported {a.opened_at:%d %b %Y %H:%M}.\n"
        f"Severity: {a.severity}."
        + ("\nProvisional: received by SMS; the full record will follow." if a.provisional else "")
        + "\nOpen WaterCheck Console to acknowledge it and record the action taken."
    )
    return title, body, a.severity


async def notify_alert(
    conn: AsyncConnection, alert_id: UUID, level: int, *, sms_ok: bool = True
) -> int:
    """Creates the notifications for an alert at an escalation level and
    queues their delivery. Returns how many people were told."""
    cfg = await config(conn)
    title, body, severity = await _message(conn, alert_id, level)
    kind = "escalation" if level else "alert"
    channels_cfg = cfg.get("channels", {})
    told = 0
    for r in await recipients(conn, alert_id, level):
        wanted = ["in_app"]
        if r.email and r.notify_email and channels_cfg.get("email", True):
            wanted.append("email")
        has_token = (
            await conn.execute(
                text("SELECT 1 FROM push_token WHERE user_id = :u LIMIT 1"), {"u": r.user_id}
            )
        ).first()
        if has_token and r.notify_push and channels_cfg.get("push", True):
            wanted.append("push")
        if (
            sms_ok
            and r.phone
            and r.notify_sms
            and severity in channels_cfg.get("sms_for_severities", [])
        ):
            wanted.append("sms")
        new_for_user = False
        for channel in wanted:
            row = (
                await conn.execute(
                    text(
                        "INSERT INTO notification (user_id, alert_id, kind, channel, title, body, "
                        "status, sent_at, escalation_level) VALUES (:u, :a, :k, :c, :t, :b, "
                        ":s, CASE WHEN :c = 'in_app' THEN now() END, :lvl) "
                        "ON CONFLICT DO NOTHING RETURNING id"
                    ),
                    {
                        "u": r.user_id,
                        "a": alert_id,
                        "k": kind,
                        "c": channel,
                        "t": title,
                        "b": body,
                        "s": "sent" if channel == "in_app" else "pending",
                        "lvl": level,
                    },
                )
            ).first()
            if row is None:
                continue
            new_for_user = True
            if channel != "in_app":
                await enqueue(conn, "deliver", {"notification_id": str(row.id)})
        told += new_for_user
    return told


async def deliver(conn: AsyncConnection, channels: Channels, notification_id: UUID) -> str:
    """Sends one queued notification. Raises ChannelError to be retried."""
    n = (
        await conn.execute(
            text(
                "SELECT n.channel, n.title, n.body, n.status, n.alert_id, u.id AS user_id, "
                "coalesce(u.email, CASE WHEN u.username LIKE '%@%' THEN u.username END) AS email, "
                "coalesce(u.phone, CASE WHEN u.username LIKE '+%' THEN u.username END) AS phone "
                "FROM notification n JOIN app_user u ON u.id = n.user_id WHERE n.id = :id "
                "FOR UPDATE OF n"
            ),
            {"id": notification_id},
        )
    ).one()
    if n.status != "pending":
        return str(n.status)
    data = {"alert_id": str(n.alert_id)} if n.alert_id else {}
    status, error = "sent", None
    if n.channel == "email":
        if channels.email is None or not n.email:
            status, error = "skipped", "email not configured"
        else:
            await channels.email.send(Outgoing(n.email, n.title, n.body, data))
    elif n.channel == "push":
        if channels.push is None:
            status, error = "skipped", "push not configured"
        else:
            tokens = [
                t[0]
                for t in await conn.execute(
                    text("SELECT token FROM push_token WHERE user_id = :u"), {"u": n.user_id}
                )
            ]
            for token in tokens:
                await channels.push.send(Outgoing(token, n.title, n.body, data))
    elif n.channel == "sms":
        if channels.sms is None or not n.phone:
            status, error = "skipped", "sms not configured"
        else:
            # SMS is short: the title is enough.
            provider_id = await channels.sms.send(Outgoing(n.phone, n.title, n.title, data))
            await conn.execute(
                text(
                    "INSERT INTO sms_message (direction, provider, provider_id, phone_last3, "
                    "body, status, alert_id) VALUES ('outbound', :p, :pid, :l3, :b, 'sent', :a)"
                ),
                {
                    "p": channels.sms.name,
                    "pid": provider_id,
                    "l3": n.phone[-3:],
                    "b": n.title,
                    "a": n.alert_id,
                },
            )
    await conn.execute(
        text(
            "UPDATE notification SET status = :s, error = :e, "
            "sent_at = CASE WHEN :s = 'sent' THEN now() END WHERE id = :id"
        ),
        {"s": status, "e": error, "id": notification_id},
    )
    return status


async def mark_failed(conn: AsyncConnection, notification_id: UUID, error: str) -> None:
    await conn.execute(
        text("UPDATE notification SET status = 'failed', error = :e WHERE id = :id"),
        {"e": error, "id": notification_id},
    )


async def escalation_sweep(conn: AsyncConnection, now: datetime) -> list[UUID]:
    """Escalates open alerts nobody acknowledged in time (F-ALR-4)."""
    hours = [int(h) for h in (await config(conn)).get("escalation_hours", [48, 96])]
    escalated = []
    for level, h in enumerate(hours, start=1):
        due = await conn.execute(
            text(
                "SELECT id FROM alert WHERE status = 'open' AND escalation_level = :prev "
                "AND opened_at <= :cutoff ORDER BY opened_at FOR UPDATE SKIP LOCKED"
            ),
            {"prev": level - 1, "cutoff": now - timedelta(hours=h)},
        )
        for (alert_id,) in due.all():
            await conn.execute(
                text(
                    "UPDATE alert SET escalation_level = :lvl, escalated_at = :now, "
                    "version = version + 1 WHERE id = :id"
                ),
                {"lvl": level, "now": now, "id": alert_id},
            )
            await conn.execute(
                text(
                    "INSERT INTO alert_event (id, alert_id, event_type, note, server_seq) "
                    "VALUES (gen_random_uuid(), :id, 'escalated', :note, 0)"
                ),
                {"id": alert_id, "note": json.dumps({"level": level, "after_hours": h})},
            )
            await notify_alert(conn, alert_id, level)
            escalated.append(alert_id)
    return escalated


__all__ = [
    "ChannelError",
    "Recipient",
    "config",
    "deliver",
    "escalation_sweep",
    "mark_failed",
    "notify_alert",
    "recipients",
]
