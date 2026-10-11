"""Reads Collect's encrypted export files (F-SYN-5, ADR-010).

AES-256-GCM over the UTF-8 JSON content, tag appended, installation ID as
associated data; key = HKDF-SHA256(secret, salt="watercheck-export-v1",
info="unsynced-data"). The IT admin import (P11) uses this with the
installation secret the server keeps encrypted.
"""

from __future__ import annotations

import base64
import json
from typing import Any

from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

FORMAT = "watercheck-export"
VERSION = 1


class ExportFileError(ValueError):
    pass


def export_key(secret: str) -> bytes:
    return HKDF(
        algorithm=hashes.SHA256(),
        length=32,
        salt=b"watercheck-export-v1",
        info=b"unsynced-data",
    ).derive(secret.encode())


def read_header(file_text: str) -> dict[str, Any]:
    try:
        env: dict[str, Any] = json.loads(file_text)
    except json.JSONDecodeError as e:
        raise ExportFileError("not_json") from e
    if env.get("format") != FORMAT or env.get("version") != VERSION:
        raise ExportFileError("not_an_export_file")
    return env


def decrypt_export(file_text: str, secret: str) -> dict[str, Any]:
    env = read_header(file_text)
    try:
        clear = AESGCM(export_key(secret)).decrypt(
            base64.b64decode(env["nonce"]),
            base64.b64decode(env["ciphertext"]),
            str(env["installation_id"]).encode(),
        )
    except Exception as e:  # InvalidTag, bad base64, missing keys
        raise ExportFileError("cannot_decrypt") from e
    content: dict[str, Any] = json.loads(clear)
    return content
