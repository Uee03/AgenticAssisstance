#requires -Version 5.1
<#
.SYNOPSIS
  Build a signed Android App Bundle (.NET MAUI) into publish/android/.
.NOTES
  Keystore passwords are read from environment variables — NEVER hardcode them:
    $env:ANDROID_KEYSTORE_PASSWORD  (store password)
    $env:ANDROID_KEY_PASSWORD       (key/alias password)
  Place your keystore at .key/upload-keystore.jks (see .key/README.md). This runs only for MAUI apps.
#>
param(
    [string]$Project = "src/App/App.csproj",
    [string]$Version = "1.0.0",
    [string]$Keystore = ".key/upload-keystore.jks",
    [string]$KeyAlias = "upload"
)
$ErrorActionPreference = "Stop"

if (-not $env:ANDROID_KEYSTORE_PASSWORD) { throw "Set env var ANDROID_KEYSTORE_PASSWORD first." }
if (-not $env:ANDROID_KEY_PASSWORD) { throw "Set env var ANDROID_KEY_PASSWORD first." }
if (-not (Test-Path $Keystore)) { throw "Keystore not found at $Keystore (see .key/README.md)." }

$out = "publish/android"
New-Item -ItemType Directory -Force -Path $out | Out-Null

dotnet publish $Project -f net10.0-android -c Release `
    -p:Version=$Version `
    -p:AndroidKeyStore=true `
    -p:AndroidSigningKeyStore=$Keystore `
    -p:AndroidSigningKeyAlias=$KeyAlias `
    -p:AndroidSigningStorePass=$env:ANDROID_KEYSTORE_PASSWORD `
    -p:AndroidSigningKeyPass=$env:ANDROID_KEY_PASSWORD `
    -o $out
if ($LASTEXITCODE -ne 0) { throw "android publish failed" }
Write-Host "Signed AAB/APK written to $out" -ForegroundColor Green
