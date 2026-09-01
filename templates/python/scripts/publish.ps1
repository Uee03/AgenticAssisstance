#requires -Version 5.1
<#
.SYNOPSIS
  Build a standalone executable with PyInstaller into publish/<platform>/ and zip it.
.NOTES
  Cross-platform binaries must be built on each target OS (or via CI). This builds for the host OS.
#>
param(
    [string]$Entry = "src/__project__/__main__.py",
    [string]$Name = "__project__",
    [string]$Version = "0.1.0"
)
$ErrorActionPreference = "Stop"
$platform = "win-x64"
$out = Join-Path "publish" $platform
New-Item -ItemType Directory -Force -Path $out | Out-Null

uv run pyinstaller --onefile --name $Name --distpath $out --workpath (Join-Path "build" "pyi") $Entry
if ($LASTEXITCODE -ne 0) { throw "pyinstaller failed" }

$zip = Join-Path "publish" "$Name-$Version-$platform.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $out '*') -DestinationPath $zip
Write-Host "Created $zip" -ForegroundColor Green
