"""Times the web Console dashboard under 3G-like throttling (P9 gate).

Drives headless Chrome over the DevTools protocol:
  1. signs a stakeholder in through the API from the page (web cookie
     session, as the sign-in screen does);
  2. with Chrome's "Fast 3G" profile on, reloads /console/ and times until
     the dashboard shows at least --sources sources (first sync included);
  3. reloads once more (app files cached) and times again.
Flutter's accessibility tree is switched on to read the screen.

    cd backend
    uv run python ../tools/measure_web_dashboard.py --username u --password p

Dev tool; needs the dev stack, a web preview build and Chrome.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import shutil
import subprocess
import tempfile
import time
import urllib.request
from itertools import count
from typing import Any

import websockets

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
# Chrome DevTools "Fast 3G": 1.44 Mbps down, 675 kbps up, 562.5 ms RTT.
FAST_3G = {
    "offline": False,
    "latency": 562.5,
    "downloadThroughput": 1.44e6 / 8,
    "uploadThroughput": 675e3 / 8,
}

READY = """(() => {
  const ph = document.querySelector('flt-semantics-placeholder');
  if (ph) ph.click();
  const text = Array.from(document.querySelectorAll('flt-semantics, [aria-label]'))
    .map(e => (e.getAttribute('aria-label') || '') + ' ' + (e.textContent || ''))
    .join(' ');
  const m = text.match(/of (\\d+) sources/);
  return m ? Number(m[1]) : -1;
})()"""


class Cdp:
    def __init__(self, ws: Any) -> None:
        self.ws = ws
        self.ids = count(1)

    async def call(self, method: str, **params: Any) -> dict[str, Any]:
        i = next(self.ids)
        await self.ws.send(json.dumps({"id": i, "method": method, "params": params}))
        while True:
            msg = json.loads(await self.ws.recv())
            if msg.get("id") == i:
                if "error" in msg:
                    raise RuntimeError(msg["error"])
                result: dict[str, Any] = msg.get("result", {})
                return result

    async def eval(self, expr: str) -> Any:
        r = await self.call("Runtime.evaluate", expression=expr, awaitPromise=True)
        return r.get("result", {}).get("value")


async def wait_dashboard(cdp: Cdp, sources: int, timeout: float) -> float:
    start = time.perf_counter()
    while time.perf_counter() - start < timeout:
        n = await cdp.eval(READY)
        if isinstance(n, int) and n >= sources:
            return time.perf_counter() - start
        await asyncio.sleep(0.1)
    raise TimeoutError(f"dashboard did not show {sources} sources in {timeout:.0f} s")


async def run(a: argparse.Namespace) -> None:
    profile = tempfile.mkdtemp(prefix="wc-perf-")
    chrome = subprocess.Popen(  # noqa: S603 - fixed local binary
        [
            CHROME,
            "--headless=new",
            f"--user-data-dir={profile}",
            "--remote-debugging-port=9333",
            "--window-size=1280,900",
            "about:blank",
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    try:
        for _ in range(50):
            try:
                with urllib.request.urlopen("http://127.0.0.1:9333/json") as r:  # noqa: S310
                    targets = json.load(r)
                break
            except OSError:
                await asyncio.sleep(0.2)
        page = next(t for t in targets if t["type"] == "page")
        async with websockets.connect(page["webSocketDebuggerUrl"], max_size=None) as ws:
            cdp = Cdp(ws)
            await cdp.call("Network.enable")
            await cdp.call("Page.enable")
            await cdp.call("Page.navigate", url=a.url)
            await asyncio.sleep(1)
            # Sign in the way the web Console does (refresh token in a cookie).
            body = json.dumps({"username": a.username, "password": a.password})
            status = await cdp.eval(
                f"fetch('/api/v1/auth/login', {{method: 'POST', credentials: 'include',"
                f" headers: {{'content-type': 'application/json', 'x-token-transport': 'cookie'}},"
                f" body: {json.dumps(body)}}}).then(r => r.status)"
            )
            if status != 200:
                raise SystemExit(f"sign-in failed: {status}")
            await cdp.call("Network.emulateNetworkConditions", **FAST_3G)
            for label in ("first visit (app download + sync)", "return visit (app cached)"):
                if label.startswith("first"):
                    await cdp.call("Network.clearBrowserCache")
                await cdp.call("Page.reload", ignoreCache=False)
                took = await wait_dashboard(cdp, a.sources, a.timeout)
                print(f"{label}: dashboard with >= {a.sources} sources in {took:.1f} s")
    finally:
        chrome.terminate()
        chrome.wait(10)
        shutil.rmtree(profile, ignore_errors=True)


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--url", default="http://localhost/console/")
    p.add_argument("--username", required=True)
    p.add_argument("--password", required=True)
    p.add_argument("--sources", type=int, default=50)
    p.add_argument("--timeout", type=float, default=180)
    asyncio.run(run(p.parse_args()))


if __name__ == "__main__":
    main()
