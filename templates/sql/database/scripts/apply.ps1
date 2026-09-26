#requires -Version 5.1
<#
.SYNOPSIS
  Windows parity for apply.sh. Applies SQL in a fixed order:
  Tables -> Functions -> StoredProcedures -> BAU/Pending, in filename order per folder.
  See ../../.github/skills/postgres-sql-deployment.

.PARAMETER Service    docker compose service name (docker mode). Default: postgres.
.PARAMETER Database   target database. Default: $POSTGRES_DB or "app".
.PARAMETER User       DB user (docker mode). Default: $POSTGRES_USER or "app".
.PARAMETER SkipBau    apply object folders only.
.PARAMETER Direct     use a local psql client -> real DB (CI) instead of docker compose.
.PARAMETER Connection connection string (implies -Direct). Default: $env:DATABASE_URL.
.PARAMETER Journal    record applied BAU scripts in app.bau_script_log and skip already-applied.

.EXAMPLE
  ./apply.ps1                                  # local docker; archive BAU to Executed/
.EXAMPLE
  ./apply.ps1 -SkipBau                         # object folders only
.EXAMPLE
  ./apply.ps1 -Direct -Journal                 # CI: psql via PG* env vars, journal BAU
.EXAMPLE
  ./apply.ps1 -Connection $env:DATABASE_URL -Journal
#>
[CmdletBinding()]
param(
    [string]$Service = "postgres",
    [string]$Database = "",
    [string]$User = "",
    [switch]$SkipBau,
    [switch]$Direct,
    [string]$Connection = $env:DATABASE_URL,
    [switch]$Journal
)

$ErrorActionPreference = "Stop"
$mode = if ($Direct -or $Connection) { "direct" } else { "docker" }

$ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DatabaseDir = Split-Path -Parent $ScriptsDir
$EnvFile = Join-Path $DatabaseDir ".env"
if (Test-Path $EnvFile) {
    foreach ($line in Get-Content $EnvFile) {
        $t = $line.Trim()
        if ($t -and -not $t.StartsWith("#") -and $t.Contains("=")) {
            $i = $t.IndexOf("=")
            [Environment]::SetEnvironmentVariable($t.Substring(0, $i).Trim(), $t.Substring($i + 1).Trim())
        }
    }
}
if (-not $Database) { $Database = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "app" } }
if (-not $User)     { $User     = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "app" } }

function Invoke-Psql {
    param([string[]]$PsqlArgs = @(), [string]$StdinFile)
    if ($mode -eq "direct") {
        $exe = "psql"
        $cmd = @()
        if ($Connection) { $cmd += $Connection }
        $cmd += @("-v", "ON_ERROR_STOP=1") + $PsqlArgs
    } else {
        $exe = "docker"
        $cmd = @("compose", "exec", "-T", $Service, "psql", "-v", "ON_ERROR_STOP=1", "-U", $User, "-d", $Database) + $PsqlArgs
    }
    if ($StdinFile) { Get-Content -Raw -LiteralPath $StdinFile | & $exe @cmd }
    else { & $exe @cmd }
    if ($LASTEXITCODE -ne 0) { throw "psql exited with code $LASTEXITCODE" }
}

function Apply-File {
    param([string]$Path)
    Write-Host "  -> $(Split-Path -Leaf $Path)"
    if ($mode -eq "direct") { Invoke-Psql -PsqlArgs @("-f", $Path) }
    else { Invoke-Psql -StdinFile $Path }
}

function Apply-Folder {
    param([string]$Name)
    $folder = Join-Path $ScriptsDir $Name
    if (-not (Test-Path $folder)) { return }
    $files = @(Get-ChildItem -Path $folder -Filter *.sql -File | Sort-Object Name)
    if ($files.Count -eq 0) { Write-Host "$Name : (no scripts)"; return }
    Write-Host "$Name :"
    foreach ($f in $files) { Apply-File $f.FullName }
}

function Initialize-Journal {
    Invoke-Psql -PsqlArgs @("-c", "CREATE SCHEMA IF NOT EXISTS app; CREATE TABLE IF NOT EXISTS app.bau_script_log (script_name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now());") | Out-Null
}
function Test-BauApplied {
    param([string]$Name)
    $out = Invoke-Psql -PsqlArgs @("-tAc", "SELECT 1 FROM app.bau_script_log WHERE script_name = '$Name';")
    return (($out | Out-String).Trim() -eq "1")
}
function Add-BauRecord {
    param([string]$Name)
    Invoke-Psql -PsqlArgs @("-c", "INSERT INTO app.bau_script_log (script_name) VALUES ('$Name') ON CONFLICT DO NOTHING;") | Out-Null
}

Push-Location $DatabaseDir
try {
    Apply-Folder "Tables"; Apply-Folder "Functions"; Apply-Folder "StoredProcedures"
    if (-not $SkipBau) {
        $pending = Join-Path $ScriptsDir "BAU/Pending"
        $executed = Join-Path $ScriptsDir "BAU/Executed"
        $bau = @()
        if (Test-Path $pending) { $bau = @(Get-ChildItem -Path $pending -Filter *.sql -File | Sort-Object Name) }
        if ($bau.Count -gt 0) {
            Write-Host "BAU/Pending :"
            if ($Journal) { Initialize-Journal }
            foreach ($f in $bau) {
                $name = $f.Name
                if ($Journal) {
                    if (Test-BauApplied $name) { Write-Host "  -- $name (already applied, skipping)"; continue }
                    Apply-File $f.FullName; Add-BauRecord $name; Write-Host "     journaled -> app.bau_script_log"
                } else {
                    Apply-File $f.FullName
                    if (-not (Test-Path $executed)) { New-Item -ItemType Directory -Path $executed | Out-Null }
                    $dest = Join-Path $executed ("{0}_{1}" -f (Get-Date -Format "yyyyMMdd"), $name)
                    Move-Item -LiteralPath $f.FullName -Destination $dest
                    Write-Host "     moved -> BAU/Executed/$(Split-Path -Leaf $dest)"
                }
            }
        } else { Write-Host "BAU/Pending : (nothing to run)" }
    }
    Write-Host "Done."
} finally { Pop-Location }
