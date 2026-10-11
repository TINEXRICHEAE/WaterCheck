"""P8 smoke test against the running dev stack (through Caddy, with Mailpit).

    python tools/smoke_alerts.py --admin you@example.org --admin-password ... \
        --stakeholder officer@example.org --stakeholder-password ...

The stakeholder must cover ABIM-ENT (e.g. created by the CLI with
--area UG-ABIM). The webhook token is read from infra/.env. Steps:

1. a phone syncs an unsafe test, and the server raises the alert;
2. the worker emails the stakeholder (Mailpit), timed against the 5 min gate;
3. the stakeholder acknowledges, starts action and closes it;
4. SMS fallback: a provisional alert, then the full record reconciles it;
5. a forged SMS is refused.

Uses only the standard library.
"""

from __future__ import annotations

import argparse
import hashlib
import hmac
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

BASE = "http://localhost/api"
MAILPIT = "http://localhost:8025/api/v1"
PROFILE = "ba9093d7-4551-54b4-9da1-3c14a7041644"


def call(
    method: str,
    path: str,
    body: Any = None,
    headers: dict[str, str] | None = None,
    raw: bytes | None = None,
    content_type: str = "application/json",
) -> tuple[int, Any]:
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    req = urllib.request.Request(BASE + path, data=data, method=method)  # noqa: S310
    req.add_header("Content-Type", content_type)
    for k, v in (headers or {}).items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req) as r:  # noqa: S310 - fixed local URL
            out = r.read()
            return r.status, json.loads(out) if out else None
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read() or b"null")


def check(label: str, ok: bool) -> None:
    print(f"{'ok ' if ok else 'FAIL'} {label}")
    if not ok:
        sys.exit(1)


def login(user: str, password: str) -> dict[str, str]:
    s, t = call("POST", "/v1/auth/login", {"username": user, "password": password})
    check(f"signed in as {user}", s == 200 and not t["must_change_password"])
    return {"Authorization": f"Bearer {t['access_token']}"}


class Phone:
    def __init__(self, admin: dict[str, str]) -> None:
        _, code = call("POST", "/v1/admin/activation-codes", {"area_code": "ABIM-ENT"}, admin)
        _, a = call("POST", "/v1/installations/activate", {"code": code["code"]})
        self.id, self.secret = a["installation_id"], a["secret"]
        self.village, self.short = a["area"]["id"], a["short_code"]
        self.collector = str(uuid.uuid4())

    def signed(self, method: str, path: str, body: bytes = b"") -> dict[str, str]:
        ts, nonce = str(int(time.time())), uuid.uuid4().hex
        message = "\n".join([method, path, ts, hashlib.sha256(body).hexdigest(), nonce])
        sig = hmac.new(self.secret.encode(), message.encode(), hashlib.sha256).hexdigest()
        return {
            "X-Installation-Id": self.id,
            "X-Timestamp": ts,
            "X-Signature": sig,
            "X-Nonce": nonce,
        }

    def push(self, changes: list[dict[str, Any]]) -> list[dict[str, Any]]:
        raw = json.dumps({"batch_id": str(uuid.uuid4()), "changes": changes}).encode()
        s, out = call("POST", "/v1/sync/push", raw=raw, headers=self.signed("POST", "/v1/sync/push", raw))
        assert s == 200, out
        results: list[dict[str, Any]] = out["results"]
        return results


def visit(p: Phone, code: str, at: datetime) -> list[dict[str, Any]]:
    src, ses, res = (str(uuid.uuid4()) for _ in range(3))
    origin = {
        "collector_key": p.collector,
        "collector_snapshot": json.dumps({"full_name": "Smoke Collector"}),
    }
    t = at.isoformat()
    return [
        {"entity": "water_source", "op": "insert", "id": src, "data": {
            "village_id": p.village, "code": code, "name": f"Smoke {code}",
            "source_type": "borehole", "created_at_device": t, "updated_at_device": t, **origin}},
        {"entity": "test_session", "op": "insert", "id": ses, "data": {
            "source_id": src, "reference_standard_id": PROFILE, "calibrated": True,
            "tested_at_device": t, **origin}},
        {"entity": "test_result", "op": "insert", "id": res, "data": {
            "session_id": ses, "overall": "unsafe", "standard_id": PROFILE, "flags": "[]",
            "created_at_device": t}},
        {"entity": "reading", "op": "insert", "id": str(uuid.uuid4()), "data": {
            "session_id": ses, "result_id": res, "parameter_code": "ph", "value": "9.6",
            "unit": "pH", "result": "high"}},
    ]


def alerts_for(headers: dict[str, str], source_id: str) -> list[dict[str, Any]]:
    out, cursor = [], None
    while True:
        q = "stream=scope&limit=1000" + (f"&cursor={cursor}" if cursor else "")
        _, page = call("GET", f"/v1/sync/pull?{q}", headers=headers)
        out += [c["data"] for c in page["changes"] if c["entity"] == "alert"]
        cursor = page["next_cursor"]
        if not page["has_more"]:
            break
    latest: dict[str, dict[str, Any]] = {}
    for a in out:
        latest[a["id"]] = a
    return [a for a in latest.values() if a["source_id"] == source_id]


def mail_to(address: str, subject_part: str) -> bool:
    with urllib.request.urlopen(f"{MAILPIT}/messages?limit=200") as r:  # noqa: S310
        messages = json.loads(r.read())["messages"]
    return any(
        subject_part in m["Subject"] and any(t["Address"] == address for t in m["To"])
        for m in messages
    )


def sms(token: str, text: str) -> Any:
    form = urllib.parse.urlencode({"from": "+256700000123", "text": text, "id": uuid.uuid4().hex})
    _, out = call(
        "POST",
        f"/v1/sms/inbound/test?token={token}",
        raw=form.encode(),
        content_type="application/x-www-form-urlencoded",
    )
    return out


def main() -> None:
    a = argparse.ArgumentParser()
    a.add_argument("--admin", required=True)
    a.add_argument("--admin-password", required=True)
    a.add_argument("--stakeholder", required=True)
    a.add_argument("--stakeholder-password", required=True)
    args = a.parse_args()
    env = dict(
        line.split("=", 1)
        for line in (Path(__file__).parents[1] / "infra" / ".env").read_text().splitlines()
        if "=" in line and not line.startswith("#")
    )
    token = env["WC_SMS_WEBHOOK_TOKEN"].strip()

    admin = login(args.admin, args.admin_password)
    officer = login(args.stakeholder, args.stakeholder_password)
    phone = Phone(admin)
    tag = uuid.uuid4().hex[:5].upper()

    # 1-2. An unsafe test syncs; the worker emails the area's stakeholder.
    changes = visit(phone, f"SMK-{tag}", datetime.now(UTC))
    started = time.monotonic()
    check("unsafe test synced", {r["status"] for r in phone.push(changes)} == {"applied"})
    found = [x for x in alerts_for(officer, changes[0]["id"]) if x["trigger_rule"] == "unsafe"]
    check("the server raised the alert (stakeholder sees it)", len(found) == 1)
    alert = found[0]["id"]
    while not mail_to(args.stakeholder, f"SMK-{tag}"):
        if time.monotonic() - started > 300:
            check("email within 5 minutes", False)
        time.sleep(2)
    check(f"stakeholder emailed after {time.monotonic() - started:.1f} s (gate: 5 min)", True)
    _, inbox = call("GET", "/v1/notifications", headers=officer)
    check("in-app notification", any(i["alert_id"] == alert for i in inbox["items"]))

    # 3. Acknowledge → action → close, by the stakeholder.
    for step in ("acknowledged", "action_in_progress", "closed"):
        _, out = call("POST", "/v1/sync/push", {"batch_id": str(uuid.uuid4()), "changes": [
            {"entity": "alert_event", "op": "insert", "id": str(uuid.uuid4()),
             "data": {"alert_id": alert, "event_type": step, "note": "{}"}}]}, officer)
        check(f"  {step}", out["results"][0]["status"] == "applied")
    final = next(x for x in alerts_for(officer, changes[0]["id"]) if x["id"] == alert)
    check("alert closed with times recorded", final["status"] == "closed" and final["closed_at"])

    # 4. SMS fallback: provisional alert, then reconciliation.
    stuck = visit(phone, f"SMS-{tag}", datetime.now(UTC).replace(second=0, microsecond=0))
    phone.push(stuck[:1])  # only the source got through
    at = datetime.fromisoformat(stuck[1]["data"]["tested_at_device"])
    signed = f"WC1 I:{phone.short} ALERT SMS-{tag} {at:%Y%m%dT%H%MZ} PH9.6 UNSAFE"
    code = hmac.new(phone.secret.encode(), signed.encode(), hashlib.sha256).hexdigest()[:6]
    out = sms(token, f"{signed} #{code.upper()}")
    check(f"SMS accepted: {out}", out["status"] == "accepted")
    phone.push(stuck[1:])
    alerts = alerts_for(officer, stuck[0]["id"])
    open_ = [x for x in alerts if x["status"] == "open"]
    closed = [x for x in alerts if x["status"] == "closed"]
    check(
        "reconciled: one open alert, the SMS one closed and linked",
        len(open_) == 1 and len(closed) == 1 and closed[0]["linked_alert_id"] == open_[0]["id"],
    )

    # 5. Forged.
    out = sms(token, f"{signed} #000000")
    check(f"forged SMS refused: {out}", out == {"status": "rejected", "reason": "bad_code"})
    print("Done.")


if __name__ == "__main__":
    main()
