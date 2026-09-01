#requires -Version 5.1
<#
.SYNOPSIS
  Production-build the Angular app and zip the dist output into publish/.
.NOTES
  Angular emits to dist/<project>/browser. Adjust -DistPath if your project name differs.
#>
param(
    [string]$Name = "app",
    [string]$Version = "1.0.0",
    [string]$DistPath = ""
)
$ErrorActionPreference = "Stop"

npm run build
if ($LASTEXITCODE -ne 0) { throw "ng build failed" }

if (-not $DistPath) {
    $DistPath = (Get-ChildItem -Path "dist" -Directory | Select-Object -First 1).FullName
    $browser = Join-Path $DistPath "browser"
    if (Test-Path $browser) { $DistPath = $browser }
}

$out = "publish"
New-Item -ItemType Directory -Force -Path $out | Out-Null
$zip = Join-Path $out "$Name-$Version-web.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $DistPath '*') -DestinationPath $zip
Write-Host "Created $zip" -ForegroundColor Green
