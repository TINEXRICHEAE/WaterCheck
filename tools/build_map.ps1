# The map for all of Uganda (plan P9 "Map update", ADR-014).
#
#   .\tools\build_map.ps1 -Vector
#       Builds infra/tiles/uganda.mbtiles: OpenStreetMap vector tiles for the
#       whole country (Geofabrik extract -> tilemaker, OpenMapTiles schema).
#       The `tiles` service (tileserver-gl) renders labelled map images from
#       it on demand, for every zoom level. Peak disk ~5 GB, freed at the end.
#
#   .\tools\build_map.ps1 -Pack -Name abim -Bbox 33.35,2.40,34.20,3.15
#       Renders an offline pack for devices, infra/tiles/packs/<name>.mbtiles
#       (raster, with labels), from the running `tiles` service.
#
# Map data © OpenStreetMap contributors (ODbL); the apps show the credit.
param(
    [switch]$Vector,
    [switch]$Pack,
    [string]$Name = "Abim District",
    # west,south,east,north
    [string]$Bbox = "33.35,2.40,34.20,3.15",
    [int]$MinZoom = 8,
    [int]$MaxZoom = 16,
    [string]$Extract = "https://download.geofabrik.de/africa/uganda-latest.osm.pbf",
    [string]$TilesUrl = "http://localhost/tiles"
)
# Native tools write progress to stderr, which Windows PowerShell 5.1 turns
# into errors; exit codes are checked instead.
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$tiles = Join-Path $root "infra\tiles"
$work = Join-Path $tiles "work"

if ($Vector) {
    $tilemaker = "ghcr.io/systemed/tilemaker:master"
    New-Item -ItemType Directory -Force $work | Out-Null
    $built = $false
    try {
        $pbf = Join-Path $work "uganda.osm.pbf"
        if (-not (Test-Path $pbf)) {
            Write-Host "Downloading $Extract"
            curl.exe -L --fail -sS --ssl-no-revoke --retry 50 --retry-all-errors --retry-delay 5 -C - -o "$pbf.part" $Extract
            if ($LASTEXITCODE -ne 0) { throw "download failed" }
            Move-Item "$pbf.part" $pbf
        }
        # The connection here drops often: retry the pull.
        for ($i = 0; $i -lt 8; $i++) {
            docker pull -q $tilemaker | Out-Null
            if ($LASTEXITCODE -eq 0) { break }
            Start-Sleep -Seconds 10
        }
        if ($LASTEXITCODE -ne 0) { throw "could not pull $tilemaker" }
        Write-Host "tilemaker image: $(docker image inspect $tilemaker --format '{{index .RepoDigests 0}}')"
        # On-disk store and two threads: Docker Desktop here has under 4 GB.
        docker run --rm -v "${work}:/data" $tilemaker /data/uganda.osm.pbf `
            --output /data/uganda.mbtiles --store /data/store --threads 2
        if ($LASTEXITCODE -ne 0) { throw "tilemaker failed" }
        Move-Item -Force (Join-Path $work "uganda.mbtiles") (Join-Path $tiles "uganda.mbtiles")
        $built = $true
        Write-Host "Done: infra/tiles/uganda.mbtiles. Restart: docker compose up -d tiles"
    } finally {
        # A failed run keeps only the (partial) download, so a rerun resumes.
        if ($built) {
            Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
        } else {
            Get-ChildItem $work -Exclude "uganda.osm.pbf*" -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
        docker rmi $tilemaker 2>&1 | Out-Null
        docker image prune -f | Out-Null
    }
}

if ($Pack) {
    $style = (Invoke-RestMethod "$TilesUrl/styles.json")[0].id
    $out = Join-Path $tiles "area.mbtiles"
    python -I (Join-Path $PSScriptRoot "render_tiles.py") `
        --url "$TilesUrl/styles/$style/256/{z}/{x}/{y}.png" --name $Name `
        --bbox $Bbox --minzoom $MinZoom --maxzoom $MaxZoom --out $out
    if ($LASTEXITCODE -ne 0) { throw "rendering failed" }
}
