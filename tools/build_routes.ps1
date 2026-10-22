# Road routes for the maps (2026-10-22, ADR-021): Valhalla routing data for
# all of Uganda. One data set serves every way of travelling (motorbike/car
# and walking), read from disk, so the running service needs little memory.
# (OSRM was tried first: its build ran Docker out of memory on the 3.8 GB
# dev machine, and it needs one service per way of travelling.)
#
#   .\tools\build_routes.ps1
#
# Writes infra/routing/valhalla/ (git-ignored): valhalla.json and the tiles,
# read by the `routing` service. Rebuild after a map update. Peak disk about
# 2 GB; the extract is deleted at the end. Map data © OpenStreetMap
# contributors (ODbL).
param(
    [string]$Extract = "https://download.geofabrik.de/africa/uganda-latest.osm.pbf",
    [string]$Image = "ghcr.io/valhalla/valhalla:3.5.1",
    # Fewer threads, less memory while building.
    [int]$Threads = 2
)
# Native tools write progress to stderr, which Windows PowerShell 5.1 turns
# into errors; exit codes are checked instead.
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$routing = Join-Path $root "infra\routing"
$work = Join-Path $routing "work"
$out = Join-Path $routing "valhalla"
New-Item -ItemType Directory -Force $work, $out | Out-Null
$pbf = Join-Path $work "uganda.osm.pbf"
try {
    if (-not (Test-Path $pbf)) {
        Write-Host "Downloading the Uganda extract..."
        curl.exe -L --fail -sS --ssl-no-revoke --retry 50 --retry-all-errors --retry-delay 5 -C - -o "$pbf.part" $Extract
        if ($LASTEXITCODE -ne 0) { throw "download failed" }
        Move-Item "$pbf.part" $pbf
    }
    Write-Host "Writing the Valhalla configuration..."
    docker run --rm -v "${out}:/data" $Image sh -c (
        "valhalla_build_config --mjolnir-tile-dir /data/tiles " +
        "--mjolnir-tile-extract /data/tiles.tar " +
        "--mjolnir-concurrency $Threads " +
        "--mjolnir-admin /data/admins.sqlite --mjolnir-timezone /data/tz.sqlite " +
        "--httpd-service-listen tcp://*:8002 " +
        "--loki-actions route,status > /data/valhalla.json"
    )
    if ($LASTEXITCODE -ne 0) { throw "valhalla_build_config failed" }
    Write-Host "Building the routing tiles (some minutes)..."
    docker run --rm -v "${out}:/data" -v "${work}:/osm:ro" $Image `
        valhalla_build_tiles -c /data/valhalla.json /osm/uganda.osm.pbf
    if ($LASTEXITCODE -ne 0) { throw "valhalla_build_tiles failed" }
    Write-Host "Packing the tiles into one file..."
    docker run --rm -v "${out}:/data" $Image `
        valhalla_build_extract -c /data/valhalla.json -v
    if ($LASTEXITCODE -ne 0) { throw "valhalla_build_extract failed" }
    # The service reads tiles.tar; the loose tiles are no longer needed.
    Remove-Item (Join-Path $out "tiles") -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Done. Start it: cd infra; docker compose --profile routing up -d"
} catch {
    Write-Host "Failed: $_ (the download is kept in $work)"
    exit 1
}
