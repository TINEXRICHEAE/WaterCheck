"""Accepts gzip-compressed request bodies (sync pushes over 2G, SPEC §8.1).

Clients sign the uncompressed JSON and then compress it, so signature checks
and handlers see the plain body. The decompressed size is capped to stop
"zip bombs".
"""

from __future__ import annotations

import zlib

from starlette.types import ASGIApp, Message, Receive, Scope, Send

MAX_BODY = 8 * 1024 * 1024


class GzipRequestMiddleware:
    def __init__(self, app: ASGIApp, max_body: int = MAX_BODY) -> None:
        self.app = app
        self.max_body = max_body

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return
        headers = dict(scope.get("headers") or [])
        if headers.get(b"content-encoding", b"").lower() != b"gzip":
            await self.app(scope, receive, send)
            return

        compressed = bytearray()
        more = True
        while more:
            message = await receive()
            compressed += message.get("body", b"")
            more = message.get("more_body", False)
            if len(compressed) > self.max_body:
                await _refuse(send, 413, b'{"detail":"body_too_large"}')
                return
        inflater = zlib.decompressobj(16 + zlib.MAX_WBITS)
        try:
            body = inflater.decompress(bytes(compressed), self.max_body + 1)
        except zlib.error:
            await _refuse(send, 400, b'{"detail":"invalid_gzip"}')
            return
        if len(body) > self.max_body or inflater.unconsumed_tail:
            await _refuse(send, 413, b'{"detail":"body_too_large"}')
            return

        new_headers = [
            (k, v)
            for k, v in scope["headers"]
            if k.lower() not in (b"content-encoding", b"content-length")
        ] + [(b"content-length", str(len(body)).encode())]
        sent = False

        async def replay() -> Message:
            nonlocal sent
            if sent:
                return await receive()
            sent = True
            return {"type": "http.request", "body": body, "more_body": False}

        await self.app({**scope, "headers": new_headers}, replay, send)


async def _refuse(send: Send, status: int, body: bytes) -> None:
    await send(
        {
            "type": "http.response.start",
            "status": status,
            "headers": [(b"content-type", b"application/json")],
        }
    )
    await send({"type": "http.response.body", "body": body})
