# Frees disk space after code updates, builds and image rebuilds. Run it at
# the end of every work session or phase. Keeps only what the project needs
# to continue: the dev stack's images and data volumes, .dart_tool, and the
# web previews Caddy serves (apps/*/build/web).
#
#   .\tools\cleanup.ps1             # routine
#   .\tools\cleanup.ps1 -Previews   # also delete the web previews
param([switch]$Previews)
$root = Split-Path -Parent $PSScriptRoot
$before = (Get-PSDrive C).Free

# Flutter build output (Windows, Android, intermediates). The web previews
# stay unless -Previews.
foreach ($app in 'console', 'collect') {
  $build = Join-Path $root "apps\$app\build"
  if (Test-Path $build) {
    Get-ChildItem $build -Force |
      Where-Object { $Previews -or $_.Name -ne 'web' } |
      Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  }
}
Get-ChildItem (Join-Path $root 'packages') -Directory | ForEach-Object {
  Remove-Item -Recurse -Force (Join-Path $_.FullName 'build') -ErrorAction SilentlyContinue
}

# Flutter's temporary folders (tests and builds).
Get-ChildItem $env:TEMP -Directory -Filter 'flutter_tools.*' -ErrorAction SilentlyContinue |
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Docker: old image layers left by rebuilds, and the build cache. Volumes
# (database, photos) are never touched.
docker image prune -f | Out-Null
docker builder prune -af | Out-Null

# Map tile work files, if a build was interrupted.
Remove-Item -Recurse -Force (Join-Path $root 'infra\tiles\work') -ErrorAction SilentlyContinue

$after = (Get-PSDrive C).Free
"Freed {0:N2} GB; {1:N1} GB free on C:" -f (($after - $before) / 1GB), ($after / 1GB)
