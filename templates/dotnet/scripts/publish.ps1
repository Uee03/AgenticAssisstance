#requires -Version 5.1
<#
.SYNOPSIS
  Build self-contained, single-file release binaries for each runtime and zip them into publish/.
.EXAMPLE
  powershell -File scripts/publish.ps1 -Project src/App/App.csproj -Version 1.2.0 -Runtimes win-x64,linux-x64
#>
param(
    [string]$Project = "src/App/App.csproj",
    [string]$Version = "1.0.0",
    [string[]]$Runtimes = @("win-x64", "linux-x64", "osx-arm64")
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root "publish"
New-Item -ItemType Directory -Force -Path $out | Out-Null
$name = [System.IO.Path]::GetFileNameWithoutExtension($Project)

foreach ($rid in $Runtimes) {
    Write-Host "Publishing $rid ..." -ForegroundColor Cyan
    $dir = Join-Path $out $rid
    dotnet publish $Project -c Release -r $rid --self-contained true `
        -p:PublishSingleFile=true -p:Version=$Version -o $dir
    if ($LASTEXITCODE -ne 0) { throw "publish failed for $rid" }

    $zip = Join-Path $out "$name-$Version-$rid.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path (Join-Path $dir '*') -DestinationPath $zip
    Write-Host "Created $zip" -ForegroundColor Green
}
