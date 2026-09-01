#requires -Version 5.1
<#
.SYNOPSIS
  Build a Flutter target and zip it into publish/<target>/.
.PARAMETER Target
  One of: web, windows, apk
.EXAMPLE
  powershell -File scripts/publish.ps1 -Target web -Version 1.2.0 -Name myapp
#>
param(
    [ValidateSet("web", "windows", "apk")]
    [string]$Target = "web",
    [string]$Version = "1.0.0",
    [string]$Name = "app"
)
$ErrorActionPreference = "Stop"

switch ($Target) {
    "web" { flutter build web --release; $src = "build/web" }
    "windows" { flutter build windows --release; $src = "build/windows/x64/runner/Release" }
    "apk" { flutter build apk --release; $src = "build/app/outputs/flutter-apk" }
}
if ($LASTEXITCODE -ne 0) { throw "flutter build $Target failed" }

$out = Join-Path "publish" $Target
New-Item -ItemType Directory -Force -Path $out | Out-Null
Copy-Item (Join-Path $src '*') $out -Recurse -Force

$zip = Join-Path "publish" "$Name-$Version-$Target.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $out '*') -DestinationPath $zip
Write-Host "Created $zip" -ForegroundColor Green
