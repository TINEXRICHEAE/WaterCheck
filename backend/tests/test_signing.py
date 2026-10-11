"""Known signing vectors shared with packages/api_client (Dart)."""

from app.core.security import sign_request


def test_signing_vectors_match_the_dart_client() -> None:
    assert (
        sign_request("secret", "get", "/v1/installations/me", "1700000000", b"")
        == "5bc7f73b822f76fa98f4aedce19b03ffadc8f6b0ba723eb2ec20f3927c257502"
    )
    assert (
        sign_request("secret", "POST", "/v1/sync/push", "1700000000", b'{"a":1}')
        == "a845dcb8bfb592410e47b4209d1cb111bf700b6a7ec4bca7f08aa961b3cc8031"
    )
    # With a query string and a nonce (ADR-011).
    assert (
        sign_request(
            "secret",
            "GET",
            "/v1/sync/pull?stream=scope&limit=500",
            "1700000000",
            b"",
            "0123456789abcdef",
        )
        == "0fbf51d3814aa5ff2a58826da1cc8fd1c79239172e3cbf58648be47d6304978b"
    )
