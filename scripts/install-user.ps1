#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the codebase-trellis skill to the user-level Claude Code skills directory.

.PARAMETER Force
    Overwrite an existing installation. Without this flag the script exits if the
    destination already exists.

.EXAMPLE
    .\scripts\install-user.ps1
    .\scripts\install-user.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir  = Join-Path $scriptDir '..\skills\codebase-trellis'
$destDir    = Join-Path $HOME '.claude\skills\codebase-trellis'

$sourceDir = (Resolve-Path $sourceDir).Path

Write-Host "Source : $sourceDir"
Write-Host "Dest   : $destDir"

if (Test-Path $destDir) {
    if (-not $Force) {
        Write-Error "Destination already exists: $destDir`nRe-run with -Force to overwrite."
        exit 1
    }
    Write-Host "[-Force] Overwriting existing installation."
}

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

Copy-Item -Path (Join-Path $sourceDir '*') -Destination $destDir -Recurse -Force
Write-Host "  Copied skill contents."

Write-Host ""
Write-Host "Installation complete."
Write-Host ""
Write-Host "Verification:"
Write-Host "  1. Restart Claude Code if it is currently running."
Write-Host "  2. Open any project and type: /codebase-trellis"
Write-Host "  3. The skill should activate and begin the trellis workflow."
