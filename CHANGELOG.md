# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.0.1] - 2026-06-19

### Changed

- Updated the quickstart to install from the exact `v1.0.1` release tag and documented
  that the pin must move with future releases.
- Changed force installs to replace the validated destination directory so stale files
  cannot survive across versions.
- Added a GitHub hardening checklist for repository-side enforcement alongside Trellis.

## [1.0.0] - 2026-06-19

First stable release of `codebase-trellis`.

### Added

- **codebase-trellis skill package** -- installable Claude Code skill with user-level and project-local install scripts for bash and PowerShell
- **audit mode** -- read-only inspection of local Git state and optional GitHub/CI posture reporting; GitHub posture checks never assume features are enabled; all non-configured, plan-limited, and permission-limited states reported honestly
- **start mode** -- guided branch or worktree creation with pre-check, linked worktree detection, exact per-operation approval contract, and stop conditions for naming conflicts
- **commit mode** -- dirty-state classification, sensitive file exclusion, pre-existing file detection, partially staged file detection, package/workspace boundary grouping for monorepos, manual planning by default; `--execute` enables gated group-by-group execution
- **push mode** -- remote/upstream/ahead check, protected branch detection, three-tier approval contract (plain/with-upstream/protected), `--execute` enables gated push with pre-push re-check; no force push under any condition
- **finish mode** -- five-option menu (PR plan, push + PR plan, keep branch as-is, local merge, typed discard); checks freshness gate; typed confirmation for discard; worktree-first cleanup ordering
- **recover mode** -- read-first preflight detecting all in-progress operations (merge, rebase, cherry-pick, revert) via marker files; lock file detection; three-tier recovery menu (safe/caution/destructive); exact approval phrases and typed confirmation for destructive actions
- **Trellis report format** -- Root / Tangle / Growth / Gate / Canopy / Next output contract used consistently across all modes; short form for minimal state
- **live-fire hardening** -- seven disposable-repo scenarios covering clean repos, dirty state, sensitive files, pre-existing dirty files, linked worktrees, private GitHub repos, and monorepos; three genuine gaps found and fixed
- **safety model** -- no `git add .`, no silent staging, no commit without plan, no push from commit mode, no force push, no GitHub settings mutation; approval phrases required per operation; typed confirmation required for destructive actions; sensitive files excluded at both commit and audit time

### Security

- Sensitive file patterns (`.env*`, `*.key`, `*.pem`, API token shapes, etc.) excluded from all staging plans
- No "no secrets found" claim from local grep alone
- No CI-is-green claim without verified SHA and required checks
- No branch-protection-exists claim without direct API verification
- GitHub posture findings reported with honest labels: verified / not-configured / unavailable / plan-limited / permission-limited / not-verified
