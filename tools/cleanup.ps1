# Frees disk space after code updates, builds and image rebuilds. Run it at
# the end of every work session or phase. Keeps only what the project needs
# to continue: the dev stack's images and data volumes, .dart_tool, and the
# web previews Caddy serves (apps/*/build/web).
#
#   .\tools\cleanup.ps1             # routine
#   .\tools\cleanup.ps1 -Previews   # also delete the web previews
param(
  [switch]$Previews,
  [switch]$Caches
)
$root = Split-Path -Parent $PSScriptRoot
$before = (Get-PSDrive C).Free

# Flutter build output (Windows, Android, intermediates). The web previews
# stay unless -Previews.
foreach ($app in 'console', 'collect') {
  $build = Join-Path $root "apps\$app\build"
  if (Test-Path $build) {
    # Android plugin folders nest deeper than PowerShell's path limit:
    # `cmd /c rd` removes them reliably.
    Get-ChildItem $build -Force |
      Where-Object { $Previews -or $_.Name -ne 'web' } |
      ForEach-Object { cmd /c rd /s /q "\\?\$($_.FullName)" 2>$null }
  }

  # Android/Gradle intermediates live outside Flutter's app build directory.
  # They are reproducible and can be large after failed or repeated builds.
  foreach ($generated in 'android\app\build', 'android\build', 'android\.gradle') {
    $path = Join-Path $root "apps\$app\$generated"
    if (Test-Path $path) {
      cmd /c rd /s /q "\\?\$path" 2>$null
    }
  }

  # A crashed Gradle JVM can leave a large diagnostic report beside the
  # Android project. It is useful during diagnosis, but not after review.
  Get-ChildItem (Join-Path $root "apps\$app\android") -Filter 'hs_err_pid*.log' -File -ErrorAction SilentlyContinue |
    Remove-Item -Force -ErrorAction SilentlyContinue
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

# Gradle caches are safe to regenerate but can grow after repeated Android
# builds. Keep the wrapper distributions so the next build does not need to
# download Gradle itself again. Do this only when disk space is constrained.
if ($Caches) {
  Remove-Item -Recurse -Force (Join-Path $env:USERPROFILE '.gradle\caches') -ErrorAction SilentlyContinue
  Remove-Item -Recurse -Force (Join-Path $env:USERPROFILE '.gradle\.tmp') -ErrorAction SilentlyContinue
}

# Map tile work files, if a build was interrupted.
Remove-Item -Recurse -Force (Join-Path $root 'infra\tiles\work') -ErrorAction SilentlyContinue

$after = (Get-PSDrive C).Free
"Freed {0:N2} GB; {1:N1} GB free on C:" -f (($after - $before) / 1GB), ($after / 1GB)
