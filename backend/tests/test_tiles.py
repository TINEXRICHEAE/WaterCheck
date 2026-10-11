"""The map tile endpoint reads the MBTiles file (ADR-014)."""

from __future__ import annotations

import sqlite3
from pathlib import Path

import pytest
from httpx2 import ASGITransport, AsyncClient

from app.core.config import Settings
from app.main import create_app

PNG = b"\x89PNG\r\n\x1a\nfake"


@pytest.fixture
def mbtiles(tmp_path: Path) -> Path:
    f = tmp_path / "area.mbtiles"
    db = sqlite3.connect(f)
    db.executescript(
        "CREATE TABLE metadata (name TEXT, value TEXT);"
        "CREATE TABLE tiles (zoom_level INT, tile_column INT, tile_row INT, tile_data BLOB);"
    )
    db.executemany(
        "INSERT INTO metadata VALUES (?, ?)",
        [
            ("name", "Abim"),
            ("format", "png"),
            ("minzoom", "8"),
            ("maxzoom", "14"),
            ("bounds", "33.45,2.50,34.15,3.05"),
        ],
    )
    # z10 x=607 y=503 (XYZ) is TMS row 1023 - 503 = 520.
    db.execute("INSERT INTO tiles VALUES (10, 607, 520, ?)", (PNG,))
    db.commit()
    db.close()
    return f


def _client(path: str) -> AsyncClient:
    app = create_app(Settings(environment="test", tiles_path=path))
    return AsyncClient(transport=ASGITransport(app=app), base_url="http://t")


async def test_tiles_info_tile_and_download(mbtiles: Path) -> None:
    whole = mbtiles.read_bytes()  # noqa: ASYNC240 (test setup)
    async with _client(str(mbtiles)) as c:
        info = (await c.get("/v1/tiles/info")).json()
        assert info["minzoom"] == 8 and info["maxzoom"] == 14
        assert info["bounds"] == "33.45,2.50,34.15,3.05"
        r = await c.get("/v1/tiles/10/607/503.png")
        assert r.status_code == 200 and r.content == PNG
        assert r.headers["content-type"] == "image/png"
        assert "max-age" in r.headers["cache-control"]
        assert (await c.get("/v1/tiles/10/607/504.png")).status_code == 404
        assert (await c.get("/v1/tiles/2/9/0.png")).status_code == 404
        d = await c.get("/v1/tiles/area.mbtiles")
        assert d.status_code == 200 and d.content == whole


async def test_no_tiles_built(tmp_path: Path) -> None:
    async with _client(str(tmp_path / "missing.mbtiles")) as c:
        r = await c.get("/v1/tiles/info")
        assert r.status_code == 404
        assert r.json()["detail"] == "tiles_not_built"
