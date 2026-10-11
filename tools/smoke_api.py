"""End-to-end smoke test against the running dev stack (through Caddy).

    python tools/smoke_api.py --username demo-admin@example.org --password ...

Signs in (changing the temporary password if needed), issues an activation
code, activates an installation, makes a signed request and reads reference
data. Uses only the standard library.
"""

from __future__ import annotations

import argparse
import hashlib
import hmac
import json
import sys
import time
import urllib.error
import urllib.request
from typing import Any

BASE = "http://localhost/api"


def call(method: str, path: str, body: dict[str, Any] | None = None, headers: dict[str, str] | None = None) -> tuple[int, Any]:
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(BASE + path, data=data, method=method)  # noqa: S310 - fixed local URL
    req.add_header("Content-Type", "application/json")
    for k, v in (headers or {}).items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req) as r:  # noqa: S310
            raw = r.read()
            return r.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read() or b"null")


def signed(installation_id: str, secret: str, method: str, path: str) -> dict[str, str]:
    ts = str(int(time.time()))
    message = "\n".join([method, path, ts, hashlib.sha256(b"").hexdigest()]).encode()
    return {
        "X-Installation-Id": installation_id,
        "X-Timestamp": ts,
        "X-Signature": hmac.new(secret.encode(), message, hashlib.sha256).hexdigest(),
    }


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--username", required=True)
    p.add_argument("--password", required=True)
    p.add_argument("--new-password", default="SmokeTestPass2026")
    p.add_argument("--area", default="ABIM-ENT")
    a = p.parse_args()

    status, tokens = call("POST", "/v1/auth/login", {"username": a.username, "password": a.password})
    if status != 200:
        status, tokens = call("POST", "/v1/auth/login", {"username": a.username, "password": a.new_password})
    assert status == 200, (status, tokens)
    if tokens["must_change_password"]:
        status, tokens = call(
            "POST", "/v1/auth/change-password",
            {"current_password": a.password, "new_password": a.new_password},
            {"Authorization": f"Bearer {tokens['access_token']}"},
        )
        assert status == 200, (status, tokens)
    auth = {"Authorization": f"Bearer {tokens['access_token']}"}
    print("1. signed in, password changed:", not tokens["must_change_password"])

    status, me = call("GET", "/v1/me", headers=auth)
    print("2. /v1/me role:", me["role"])

    status, code = call("POST", "/v1/admin/activation-codes", {"area_code": a.area, "max_installations": 2}, auth)
    assert status == 201, (status, code)
    print("3. activation code issued for", a.area)

    status, act = call("POST", "/v1/installations/activate", {"code": code["code"], "platform": "smoke"})
    assert status == 200, (status, act)
    print("4. installation activated in", act["area"]["name"])

    path = "/v1/installations/me"
    # Caddy strips /api, so the API sees and signs the path without it.
    status, me_inst = call("GET", path, headers=signed(act["installation_id"], act["secret"], "GET", path))
    assert status == 200, (status, me_inst)
    print("5. signed request accepted")

    path = "/v1/reference/catalogue"
    status, cat = call("GET", path, headers=signed(act["installation_id"], act["secret"], "GET", path))
    assert status == 200, (status, cat)
    print("6. catalogue parameters:", len(cat["parameters"]))

    status, _ = call("POST", f"/v1/admin/installations/{act['installation_id']}/revoke", headers=auth)
    path = "/v1/installations/me"
    status, gone = call("GET", path, headers=signed(act["installation_id"], act["secret"], "GET", path))
    print("7. after revoke:", status, gone["detail"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
