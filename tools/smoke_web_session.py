"""P5 smoke test: a stakeholder's web Console session through Caddy.

    python tools/smoke_web_session.py --username demo-officer@example.org --password <temporary>

Signs in in cookie mode as the web Console does, is forced to change the
temporary password, reads /v1/me (role and areas), refreshes with the
httpOnly cookie plus the CSRF header, is refused the admin API, and signs
out. Cookies are handled by hand because the cookies are Secure and this
script talks plain http to localhost. Uses only the standard library.
"""

from __future__ import annotations

import argparse
import json
import secrets
import sys
import urllib.error
import urllib.request
from http.cookies import SimpleCookie
from typing import Any

BASE = "http://localhost/api"


class Browser:
    """Just enough of a browser: a cookie jar and JSON calls."""

    def __init__(self) -> None:
        self.cookies: dict[str, dict[str, str]] = {}

    def call(
        self, method: str, path: str, body: Any = None, headers: dict[str, str] | None = None
    ) -> tuple[int, Any]:
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(BASE + path, data=data, method=method)  # noqa: S310
        req.add_header("Content-Type", "application/json")
        url_path = "/api" + path
        jar = [
            f"{k}={v['value']}" for k, v in self.cookies.items() if url_path.startswith(v["path"])
        ]
        if jar:
            req.add_header("Cookie", "; ".join(jar))
        for k, v in (headers or {}).items():
            req.add_header(k, v)
        try:
            with urllib.request.urlopen(req) as r:  # noqa: S310
                self._keep(r.headers.get_all("Set-Cookie") or [])
                raw = r.read()
                return r.status, json.loads(raw) if raw else None
        except urllib.error.HTTPError as e:
            self._keep(e.headers.get_all("Set-Cookie") or [])
            return e.code, json.loads(e.read() or b"null")

    def _keep(self, headers: list[str]) -> None:
        for h in headers:
            c: SimpleCookie = SimpleCookie()
            c.load(h)
            for name, morsel in c.items():
                if morsel.value == "" or morsel["max-age"] == "0":
                    self.cookies.pop(name, None)
                    continue
                self.cookies[name] = {
                    "value": morsel.value,
                    "path": morsel["path"] or "/",
                    "httponly": str(bool(morsel["httponly"])),
                }


def check(label: str, ok: bool) -> None:
    print(f"{'ok ' if ok else 'FAIL'} {label}")
    if not ok:
        sys.exit(1)


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--username", required=True)
    p.add_argument("--password", required=True)
    a = p.parse_args()
    new_password = "Smoke" + secrets.token_urlsafe(9) + "7"
    b = Browser()
    web = {"X-Token-Transport": "cookie"}

    s, t = b.call("POST", "/v1/auth/login", {"username": a.username, "password": a.password}, web)
    check("1. sign-in in cookie mode", s == 200 and t["refresh_token"] is None)
    check(
        "   refresh cookie is httpOnly, scoped to /api/v1/auth",
        b.cookies.get("wc_refresh", {}).get("httponly") == "True"
        and b.cookies["wc_refresh"]["path"] == "/api/v1/auth",
    )
    check("2. temporary password must be changed", t["must_change_password"] is True)
    auth = {"Authorization": f"Bearer {t['access_token']}"}
    s, _ = b.call("GET", "/v1/collectors", headers=auth)
    check("   other endpoints refused until then (403)", s == 403)
    s, t = b.call(
        "POST",
        "/v1/auth/change-password",
        {"current_password": a.password, "new_password": new_password},
        {**web, **auth},
    )
    check("   password changed", s == 200 and t["must_change_password"] is False)

    auth = {"Authorization": f"Bearer {t['access_token']}"}
    s, me = b.call("GET", "/v1/me", headers=auth)
    areas = [x["code"] for x in me["areas"]]
    check(f"3. /v1/me: role {me['role']}, areas {areas}", me["role"] == "stakeholder")

    s, _ = b.call("POST", "/v1/auth/refresh")
    check("4. refresh without the CSRF header is refused (403)", s == 403)
    s, t = b.call("POST", "/v1/auth/refresh", headers={"X-CSRF-Token": b.cookies["wc_csrf"]["value"]})
    check("   refresh with cookie + CSRF header", s == 200 and t["refresh_token"] is None)

    auth = {"Authorization": f"Bearer {t['access_token']}"}
    s, body = b.call("POST", "/v1/admin/activation-codes", {"area_code": "ABIM-ENT"}, auth)
    check(f"5. admin API refused for a stakeholder ({s} {body['detail']})", s == 403)

    s, _ = b.call("POST", "/v1/auth/password-help", {"username": a.username})
    check("6. forgot-password request accepted (202)", s == 202)

    s, _ = b.call("POST", "/v1/auth/logout", headers={"X-CSRF-Token": b.cookies["wc_csrf"]["value"]})
    check("7. signed out; cookie cleared", s == 204 and "wc_refresh" not in b.cookies)
    print(f"Done. The new password (dev only, shown once): {new_password}")


if __name__ == "__main__":
    main()
