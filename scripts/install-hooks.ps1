<#
.SYNOPSIS
    Installs a git pre-commit hook that auto-syncs design docs to the private backup repo.
.DESCRIPTION
    Run once after cloning the repo. Creates a pre-commit hook in .git/hooks/
    that calls sync-design.ps1 before every commit. The sync runs silently —
    if it fails, the commit still proceeds (design backup is secondary to code work).

    Usage:
      .\scripts\install-hooks.ps1     # Install the hook
      .\scripts\install-hooks.ps1     # Safe to re-run (updates existing hook)
#>

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$HookDir = "$RepoRoot\.git\hooks"
$HookFile = "$HookDir\pre-commit"

$HookContent = "#!/bin/sh
# Auto-sync design docs to private backup before every commit.
# Always exits 0 - never blocks the commit.
powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$RepoRoot\sync-design.ps1`" -Silent
exit 0
"

if (-not (Test-Path $HookDir)) {
    Write-Host "[HOOKS] ERROR .git/hooks not found. Are you in the repo root?" -ForegroundColor Red
    exit 1
}

# Check for existing non-automated hook
if (Test-Path $HookFile) {
    $existing = [System.IO.File]::ReadAllText($HookFile)
    if ($existing -notmatch "sync-design") {
        $backup = "$HookFile.bak"
        Copy-Item -LiteralPath $HookFile -Destination $backup -Force
        Write-Host "[HOOKS] Existing hook backed up to: $backup" -ForegroundColor Yellow
    }
}

# Use .NET for correct ASCII encoding (no BOM, no UTF-8 issues)
[System.IO.File]::WriteAllText($HookFile, $HookContent, [System.Text.Encoding]::ASCII)
Write-Host "[HOOKS] OK Pre-commit hook installed at: $HookFile" -ForegroundColor Green
