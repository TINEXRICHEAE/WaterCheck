# Builds infra/tiles/area.mbtiles: the raster map background of the pilot
# area (plan P9 ★, ADR-014). Run once, and again only to refresh the map.
#
#   .\tools\build_tiles.ps1                # Abim District, zoom 8-14
#
# Light on disk and memory (peak about 2.5 GB, all removed at the end):
#   1. only the area is downloaded, from the Overpass API (tens of MB);
#   2. pyosmium converts it to .osm.pbf;
#   3. tilemaker (Docker) cuts OpenMapTiles vector tiles;
#   4. tileserver-gl (Docker) renders them with its basic style;
#   5. tools/render_tiles.py packs the PNG tiles into one MBTiles file.
# Afterwards the work files and both Docker images are deleted.
# Map data © OpenStreetMap contributors (ODbL); the apps show the credit.

param(
    # west,south,east,north
    [string]$Bbox = "33.35,2.40,34.20,3.15",
    [int]$MinZoom = 8,
    [int]$MaxZoom = 14,
    [int]$Port = 8091,
    [switch]$KeepImages
)
# Native tools write progress to stderr, which Windows PowerShell 5.1 turns
# into errors; exit codes are checked instead.
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$tiles = Join-Path $root "infra\tiles"
$work = Join-Path $tiles "work"
New-Item -ItemType Directory -Force $work | Out-Null

$tilemaker = "ghcr.io/systemed/tilemaker:master"
$tileserver = "maptiler/tileserver-gl:v5.6.0"
$name = "wc-tileserver"

try {
    $w, $s, $e, $n = $Bbox.Split(",")
    $osm = Join-Path $work "area.osm"
    Write-Host "Downloading OpenStreetMap data for $Bbox (Overpass API)"
    $query = "[out:xml][timeout:600];(node($s,$w,$n,$e);way($s,$w,$n,$e);" +
        "rel($s,$w,$n,$e)[type=multipolygon];);(._;>;);out;"
    curl.exe -sS --fail -A "WaterCheck-map-build/1.0 (research pilot; one-off area extract)" -o $osm --data-urlencode "data=$query" https://overpass-api.de/api/interpreter
    if ($LASTEXITCODE -ne 0) { throw "Overpass download failed" }
    "  {0:N1} MB" -f ((Get-Item $osm).Length / 1MB) | Write-Host

    $pbf = Join-Path $work "area.osm.pbf"
    uv run --no-project --with osmium python -I (Join-Path $PSScriptRoot "osm_to_pbf.py") $osm $pbf
    if ($LASTEXITCODE -ne 0) { throw "conversion to PBF failed" }
    Remove-Item $osm

    Write-Host "Cutting vector tiles"
    docker pull -q $tilemaker | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "could not pull $tilemaker" }
    $digest = docker image inspect $tilemaker --format "{{index .RepoDigests 0}}"
    Write-Host "  tilemaker image: $digest"
    docker run --rm -v "${work}:/data" $tilemaker `
        /data/area.osm.pbf --output /data/vector.mbtiles --bbox $Bbox --threads 4
    if ($LASTEXITCODE -ne 0) { throw "tilemaker failed" }

    Write-Host "Rendering raster tiles"
    docker rm -f $name 2>&1 | Out-Null
    docker run -d --name $name -p "127.0.0.1:${Port}:8080" -v "${work}:/data" $tileserver `
        --file /data/vector.mbtiles | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "could not start $tileserver" }
    $ready = $false
    for ($i = 0; $i -lt 90 -and -not $ready; $i++) {
        Start-Sleep -Seconds 2
        try {
            Invoke-WebRequest "http://127.0.0.1:${Port}/styles.json" -UseBasicParsing | Out-Null
            $ready = $true
        } catch {}
    }
    if (-not $ready) { throw "tileserver-gl did not start" }
    $style = (Invoke-RestMethod "http://127.0.0.1:${Port}/styles.json")[0].id
    python -I (Join-Path $PSScriptRoot "render_tiles.py") `
        --url "http://127.0.0.1:${Port}/styles/$style/256/{z}/{x}/{y}.png" `
        --bbox $Bbox --minzoom $MinZoom --maxzoom $MaxZoom `
        --out (Join-Path $tiles "area.mbtiles")
    if ($LASTEXITCODE -ne 0) { throw "rendering failed" }
    Write-Host "Done. Restart the API (docker compose up -d api) to serve the new map."
} finally {
    # Leave nothing behind but area.mbtiles.
    docker rm -f $name 2>&1 | Out-Null
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
    if (-not $KeepImages) {
        docker rmi $tileserver $tilemaker 2>&1 | Out-Null
        docker image prune -f | Out-Null
    }
}
