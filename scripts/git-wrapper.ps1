# Git wrapper — intercepts git commit to auto-sync design docs
# Source this in your PowerShell profile to activate.
# Run scripts\install-hooks.ps1 to set it up automatically.

$RepoRoot = "D:\MAXNATE\Dev\Systems\acumen"
$SyncScript = "$RepoRoot\sync-design.ps1"

function Invoke-AcumenGit {
    $isCommit = ($args[0] -eq 'commit')

    if ($isCommit -and (Test-Path $SyncScript)) {
        $currentDir = (Get-Location).Path
        if ($currentDir -eq $RepoRoot -or $currentDir.StartsWith("$RepoRoot\")) {
            & $SyncScript -Silent
        }
    }

    & "git.exe" @args
}

Remove-Item -Path Alias:git -Force -ErrorAction SilentlyContinue
Set-Alias -Name git -Value Invoke-AcumenGit -Scope Global -Option AllScope
