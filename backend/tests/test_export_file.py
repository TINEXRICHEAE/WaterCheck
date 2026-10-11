"""The server can read what Collect exports before a wipe (ADR-010)."""

import json
from pathlib import Path

import pytest

from app.services.export_file import ExportFileError, decrypt_export, read_header

VECTOR = json.loads(
    (
        Path(__file__).resolve().parents[2]
        / "packages"
        / "data"
        / "test"
        / "vectors"
        / "export_v1.json"
    ).read_text(encoding="utf-8")
)


def test_decrypts_the_dart_vector() -> None:
    assert decrypt_export(VECTOR["file"], VECTOR["secret"]) == VECTOR["content"]
    assert read_header(VECTOR["file"])["installation_id"] == VECTOR["installation_id"]


def test_wrong_secret_or_tampering_is_refused() -> None:
    with pytest.raises(ExportFileError):
        decrypt_export(VECTOR["file"], "wrong-secret")
    env = json.loads(VECTOR["file"])
    env["installation_id"] = "someone-else"
    with pytest.raises(ExportFileError):
        decrypt_export(json.dumps(env), VECTOR["secret"])
    with pytest.raises(ExportFileError):
        read_header("{}")
    with pytest.raises(ExportFileError):
        read_header("not json")
