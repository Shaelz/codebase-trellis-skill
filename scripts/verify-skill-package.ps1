#Requires -Version 5.1
<#
.SYNOPSIS
    Lightweight verification of the codebase-trellis skill package.

.DESCRIPTION
    Checks:
      - required files exist
      - SKILL.md has required frontmatter fields (name, description)
      - no old identity strings present
      - no forbidden destructive patterns outside prohibited sections

.EXAMPLE
    .\scripts\verify-skill-package.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $scriptDir '..')

$fail = 0

function Check-File($path) {
    if (Test-Path $path) {
        Write-Host "OK    $path"
    } else {
        Write-Host "FAIL  missing: $path"
        $script:fail = 1
    }
}

Write-Host "--- Required files ---"
Check-File "skills\codebase-trellis\SKILL.md"
Check-File "scripts\install-user.sh"
Check-File "scripts\install-user.ps1"
Check-File "scripts\install-project.sh"
Check-File "scripts\install-project.ps1"
Check-File "scripts\verify-skill-package.sh"
Check-File "scripts\verify-skill-package.ps1"
Check-File "scripts\check-ascii-punctuation.sh"
Check-File "scripts\check-ascii-punctuation.ps1"
Check-File "docs\FUTURE_BRANCHES.md"
Check-File "docs\V1_RELEASE_PLAN.md"
Check-File "docs\design-decisions.md"
Check-File "docs\source-review.md"
Check-File ".gitignore"
Check-File "README.md"
Check-File "CHANGELOG.md"
Check-File "LICENSE"
Check-File "SECURITY.md"
Check-File "CODE_OF_CONDUCT.md"
Check-File ".github\CONTRIBUTING.md"
Check-File ".github\PULL_REQUEST_TEMPLATE.md"
Check-File ".github\ISSUE_TEMPLATE\bug_report.yml"
Check-File ".github\ISSUE_TEMPLATE\feature_request.yml"

Write-Host ""
Write-Host "--- SKILL.md frontmatter ---"
$skillContent = Get-Content "skills\codebase-trellis\SKILL.md" -Raw -Encoding UTF8

if ($skillContent -match '(?m)^name: codebase-trellis') {
    Write-Host "OK    name: codebase-trellis"
} else {
    Write-Host "FAIL  SKILL.md missing 'name: codebase-trellis' in frontmatter"
    $fail = 1
}
if ($skillContent -match '(?m)^description:') {
    Write-Host "OK    description: present"
} else {
    Write-Host "FAIL  SKILL.md missing 'description:' in frontmatter"
    $fail = 1
}

Write-Host ""
Write-Host "--- Old identity strings ---"
$oldPattern = 'git-github-hygiene|git_github_hygiene|codebase-steward|codebase-graft|git-guardian|git-sentinel'
$searchTargets = @('skills', 'docs', 'README.md', 'CHANGELOG.md', 'SECURITY.md', 'CODE_OF_CONDUCT.md', '.github')
$oldHits = @()
foreach ($target in $searchTargets) {
    if (Test-Path $target) {
        $hits = Get-ChildItem $target -Recurse -File -ErrorAction SilentlyContinue |
            Select-String -Pattern $oldPattern -ErrorAction SilentlyContinue
        $oldHits += $hits
    }
}
if ($oldHits.Count -eq 0) {
    Write-Host "OK    no old identity strings found"
} else {
    Write-Host "FAIL  old identity strings found:"
    $oldHits | ForEach-Object { Write-Host "  $_" }
    $fail = 1
}

Write-Host ""
Write-Host "--- Destructive pattern check in SKILL.md ---"
$skillLines = Get-Content "skills\codebase-trellis\SKILL.md" -Encoding UTF8
$addDotHits = $skillLines | Select-String 'git add \.'
$forcePushHits = $skillLines | Select-String 'push --force[^-]'

if (-not $addDotHits) {
    Write-Host "OK    no bare 'git add .' found in SKILL.md"
} else {
    Write-Host "WARN  'git add .' found in SKILL.md (verify it is in a prohibited/warning context):"
    $addDotHits | ForEach-Object { Write-Host "  $_" }
}
if (-not $forcePushHits) {
    Write-Host "OK    no 'push --force' found in SKILL.md"
} else {
    Write-Host "WARN  'push --force' found in SKILL.md (verify it is in a prohibited/warning context):"
    $forcePushHits | ForEach-Object { Write-Host "  $_" }
}

Write-Host ""
if ($fail -eq 0) {
    Write-Host "verify-skill-package: all checks passed."
    exit 0
} else {
    Write-Host "verify-skill-package: one or more checks failed. See above." -ForegroundColor Red
    exit 1
}
