"""/v1/tiles: the map background (plan P9 ★, ADR-014).

One raster MBTiles file of the pilot area, built from OpenStreetMap by
`tools/build_tiles.ps1`. Windows and Android download the whole file once
and read it offline; the web Console asks for single tiles. The data is
public map data, so no sign-in is needed (it holds nothing about people).
"""

from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, HTTPException, Response, status
from fastapi import Path as PathParam
from fastapi.responses import FileResponse
from pydantic import BaseModel

from app.api.deps import SettingsDep

router = APIRouter(prefix="/v1/tiles", tags=["tiles"])

_CACHE = "public, max-age=604800"


class TilesInfo(BaseModel):
    name: str
    format: str
    minzoom: int
    maxzoom: int
    bounds: str | None
    attribution: str | None
    bytes: int


def _file(path: str) -> Path:
    f = Path(path)
    if not f.is_file():
        raise HTTPException(status.HTTP_404_NOT_FOUND, "tiles_not_built")
    return f


def _open(f: Path) -> sqlite3.Connection:
    return sqlite3.connect(f"{f.resolve().as_uri()}?mode=ro", uri=True)


@router.get("/info")
def info(settings: SettingsDep) -> TilesInfo:
    f = _file(settings.tiles_path)
    with _open(f) as db:
        meta = dict(db.execute("SELECT name, value FROM metadata").fetchall())
    return TilesInfo(
        name=meta.get("name", "area"),
        format=meta.get("format", "png"),
        minzoom=int(meta.get("minzoom", 8)),
        maxzoom=int(meta.get("maxzoom", 14)),
        bounds=meta.get("bounds"),
        attribution=meta.get("attribution"),
        bytes=f.stat().st_size,
    )


@router.get("/area.mbtiles", response_class=FileResponse)
def download(settings: SettingsDep) -> FileResponse:
    return FileResponse(
        _file(settings.tiles_path),
        media_type="application/vnd.sqlite3",
        filename="area.mbtiles",
        headers={"Cache-Control": _CACHE},
    )


@router.get("/{z}/{x}/{y}.png")
def tile(
    settings: SettingsDep,
    z: Annotated[int, PathParam(ge=0, le=20)],
    x: Annotated[int, PathParam(ge=0)],
    y: Annotated[int, PathParam(ge=0)],
) -> Response:
    if x >= 1 << z or y >= 1 << z:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "no_tile")
    with _open(_file(settings.tiles_path)) as db:
        row = db.execute(
            "SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?",
            # MBTiles rows count from the south (TMS).
            (z, x, (1 << z) - 1 - y),
        ).fetchone()
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "no_tile")
    return Response(row[0], media_type="image/png", headers={"Cache-Control": _CACHE})
