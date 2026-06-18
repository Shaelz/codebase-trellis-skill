#!/usr/bin/env bash
# verify-skill-package.sh - lightweight verification of the codebase-trellis skill package
#
# Checks:
#   - required files exist
#   - SKILL.md has required frontmatter fields (name, description)
#   - no old identity strings present
#   - no forbidden destructive patterns outside prohibited sections
#
# Usage:
#   ./scripts/verify-skill-package.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

FAIL=0

check_file() {
    if [ ! -f "$1" ]; then
        echo "FAIL  missing: $1"
        FAIL=1
    else
        echo "OK    $1"
    fi
}

echo "--- Required files ---"
check_file "skills/codebase-trellis/SKILL.md"
check_file "scripts/install-user.sh"
check_file "scripts/install-user.ps1"
check_file "scripts/install-project.sh"
check_file "scripts/install-project.ps1"
check_file "scripts/verify-skill-package.sh"
check_file "scripts/verify-skill-package.ps1"
check_file "scripts/check-ascii-punctuation.sh"
check_file "scripts/check-ascii-punctuation.ps1"
check_file "docs/FUTURE_BRANCHES.md"
check_file "docs/V1_RELEASE_PLAN.md"
check_file "docs/design-decisions.md"
check_file "docs/source-review.md"
check_file ".gitignore"
check_file "README.md"
check_file "CHANGELOG.md"
check_file "LICENSE"
check_file "SECURITY.md"
check_file "CODE_OF_CONDUCT.md"
check_file ".github/CONTRIBUTING.md"
check_file ".github/PULL_REQUEST_TEMPLATE.md"
check_file ".github/ISSUE_TEMPLATE/bug_report.yml"
check_file ".github/ISSUE_TEMPLATE/feature_request.yml"

echo ""
echo "--- SKILL.md frontmatter ---"
SKILL="skills/codebase-trellis/SKILL.md"
if grep -q '^name: codebase-trellis' "$SKILL"; then
    echo "OK    name: codebase-trellis"
else
    echo "FAIL  SKILL.md missing 'name: codebase-trellis' in frontmatter"
    FAIL=1
fi
if grep -q '^description:' "$SKILL"; then
    echo "OK    description: present"
else
    echo "FAIL  SKILL.md missing 'description:' in frontmatter"
    FAIL=1
fi

echo ""
echo "--- Old identity strings ---"
OLD_NAMES="git-github-hygiene\|git_github_hygiene\|codebase-steward\|codebase-graft\|git-guardian\|git-sentinel"
OLD_HITS=$(grep -rn "$OLD_NAMES" skills docs README.md CHANGELOG.md SECURITY.md CODE_OF_CONDUCT.md .github 2>/dev/null || true)
if [ -z "$OLD_HITS" ]; then
    echo "OK    no old identity strings found"
else
    echo "FAIL  old identity strings found:"
    echo "$OLD_HITS"
    FAIL=1
fi

echo ""
echo "--- Destructive pattern check in SKILL.md ---"
ADD_DOT=$(grep -n "git add \." "$SKILL" || true)
FORCE_PUSH=$(grep -n "push --force[^-]" "$SKILL" || true)
if [ -z "$ADD_DOT" ]; then
    echo "OK    no bare 'git add .' found in SKILL.md"
else
    echo "WARN  'git add .' found in SKILL.md (verify it is in a prohibited/warning context):"
    echo "$ADD_DOT"
fi
if [ -z "$FORCE_PUSH" ]; then
    echo "OK    no 'push --force' found in SKILL.md"
else
    echo "WARN  'push --force' found in SKILL.md (verify it is in a prohibited/warning context):"
    echo "$FORCE_PUSH"
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "verify-skill-package: all checks passed."
    exit 0
else
    echo "verify-skill-package: one or more checks failed. See above." >&2
    exit 1
fi
