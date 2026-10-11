"""Writes the OpenAPI spec to docs/api/ (the Dart client is generated from it).

python -m app.openapi [--out ../docs/api]
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import yaml

from app.core.config import Settings
from app.main import create_app


def export(out: Path) -> None:
    spec = create_app(Settings(environment="dev")).openapi()
    out.mkdir(parents=True, exist_ok=True)
    (out / "openapi.json").write_text(json.dumps(spec, indent=2) + "\n", encoding="utf-8")
    (out / "openapi.yaml").write_text(
        yaml.safe_dump(spec, sort_keys=False, allow_unicode=True), encoding="utf-8"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", default="../docs/api")
    export(Path(parser.parse_args().out))
