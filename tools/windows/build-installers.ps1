param(
  [string]$VcRedist = ""
)

$ErrorActionPreference = "Stop"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$iscc = Get-Command iscc.exe -ErrorAction SilentlyContinue
if ($null -eq $iscc) {
  $knownIscc = @(
    "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
  ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
  if ($knownIscc) {
    $iscc = Get-Item -LiteralPath $knownIscc
  }
}
if ($null -eq $iscc) {
  throw "Inno Setup compiler (iscc.exe) was not found. Install Inno Setup, then rerun this script."
}
$isccPath = if ($iscc.PSObject.Properties.Name -contains "Source") {
  $iscc.Source
} else {
  $iscc.FullName
}

if (-not (Test-Path -LiteralPath (Join-Path $repo "apps\collect\build\windows\x64\runner\Release"))) {
  throw "Collect release bundle is missing. Build it from apps\collect first."
}
if (-not (Test-Path -LiteralPath (Join-Path $repo "apps\console\build\windows\x64\runner\Release"))) {
  throw "Console release bundle is missing. Build it from apps\console first."
}
if ($VcRedist -and -not (Test-Path -LiteralPath $VcRedist)) {
  throw "The Visual C++ redistributable was not found: $VcRedist"
}
if ($VcRedist) {
  $VcRedist = (Resolve-Path -LiteralPath $VcRedist).Path
}

$dist = Join-Path $repo "dist\windows"
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$common = @("/DReleaseDir=$repo\apps\collect\build\windows\x64\runner\Release")
if ($VcRedist) { $common += "/DVcRedist=$VcRedist" }
& $isccPath @common (Join-Path $PSScriptRoot "WaterCheck-Collect.iss")
if ($LASTEXITCODE -ne 0) { throw "Collect installer compilation failed." }

$common = @("/DReleaseDir=$repo\apps\console\build\windows\x64\runner\Release")
if ($VcRedist) { $common += "/DVcRedist=$VcRedist" }
& $isccPath @common (Join-Path $PSScriptRoot "WaterCheck-Console.iss")
if ($LASTEXITCODE -ne 0) { throw "Console installer compilation failed." }

Get-ChildItem $dist -Filter "WaterCheck-*-Setup.exe" | Select-Object FullName,
  @{Name = "SizeMB"; Expression = { [math]::Round($_.Length / 1MB, 2) }}
