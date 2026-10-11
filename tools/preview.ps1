# Rebuilds the web previews served by Caddy, so the latest frontend can be
# viewed in a browser without the Android emulator:
#   http://localhost/console/   WaterCheck Console (a real web target)
#   http://localhost/collect/   WaterCheck Collect (dev-only preview, ADR-006)
#
# Usage (from the repo root):
#   .\tools\preview.ps1              # both apps
#   .\tools\preview.ps1 -App collect # one app
# Requires the dev stack: cd infra; docker compose up -d
param(
  [ValidateSet('all', 'collect', 'console')]
  [string]$App = 'all'
)
# Not 'Stop': PowerShell 5.1 turns flutter's informational stderr into errors.
# Failure is detected from $LASTEXITCODE instead.
$root = Split-Path -Parent $PSScriptRoot
$apps = if ($App -eq 'all') { @('console', 'collect') } else { @($App) }

foreach ($name in $apps) {
  Write-Host "Building $name web preview..."
  Push-Location (Join-Path $root "apps\$name")
  try {
    flutter build web --base-href "/$name/" --no-pub
    if ($LASTEXITCODE -ne 0) { throw "flutter build web failed for $name" }
    # Keep only build/web (what Caddy serves); intermediates fill the disk.
    Get-ChildItem build -Force | Where-Object { $_.Name -ne 'web' } |
      Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  } finally {
    Pop-Location
  }
}

Write-Host ''
foreach ($name in $apps) { Write-Host "Ready: http://localhost/$name/  (refresh the browser tab)" }
Write-Host 'Live editing with hot reload instead: cd apps\<app>; flutter run -d chrome'
