# Copies the canonical seed (infra/seed) into the Flutter asset folder
# (packages/data/assets/seed). Flutter can only bundle assets inside a
# package. packages/data/test/seed_assets_test.dart fails if the two differ.
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root 'infra\seed'
$dst = Join-Path $root 'packages\data\assets\seed'
if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
New-Item -ItemType Directory -Force $dst | Out-Null
Get-ChildItem $src -Recurse -Filter *.json | ForEach-Object {
  $rel = $_.FullName.Substring($src.Length + 1)
  $target = Join-Path $dst $rel
  New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
  Copy-Item $_.FullName $target
}
Write-Host "Seed copied to $dst"
