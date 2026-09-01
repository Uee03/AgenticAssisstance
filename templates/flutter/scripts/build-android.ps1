#requires -Version 5.1
<#
.SYNOPSIS
  Build a signed Android App Bundle (Flutter) into publish/android/.
.NOTES
  Passwords are read from environment variables — NEVER hardcode them:
    $env:ANDROID_KEYSTORE_PASSWORD, $env:ANDROID_KEY_PASSWORD
  Keystore lives at .key/upload-keystore.jks (see .key/README.md). This script writes a git-ignored
  android/key.properties from those values, then runs `flutter build appbundle`.
  One-time: wire android/app/build.gradle(.kts) to read key.properties (snippet in .key/README.md).
#>
param(
    [string]$KeyAlias = "upload",
    [string]$Version = "1.0.0"
)
$ErrorActionPreference = "Stop"

if (-not $env:ANDROID_KEYSTORE_PASSWORD) { throw "Set env var ANDROID_KEYSTORE_PASSWORD first." }
if (-not $env:ANDROID_KEY_PASSWORD) { throw "Set env var ANDROID_KEY_PASSWORD first." }
$keystore = Resolve-Path ".key/upload-keystore.jks" -ErrorAction SilentlyContinue
if (-not $keystore) { throw "Keystore not found at .key/upload-keystore.jks (see .key/README.md)." }

$storeFile = $keystore.Path -replace '\\', '/'
@"
storePassword=$($env:ANDROID_KEYSTORE_PASSWORD)
keyPassword=$($env:ANDROID_KEY_PASSWORD)
keyAlias=$KeyAlias
storeFile=$storeFile
"@ | Set-Content -Path "android/key.properties" -Encoding ascii

flutter build appbundle --release --build-name=$Version
if ($LASTEXITCODE -ne 0) { throw "flutter build appbundle failed" }

$out = "publish/android"
New-Item -ItemType Directory -Force -Path $out | Out-Null
Copy-Item "build/app/outputs/bundle/release/app-release.aab" (Join-Path $out "app-$Version-release.aab") -Force
Write-Host "Signed AAB written to $out" -ForegroundColor Green
