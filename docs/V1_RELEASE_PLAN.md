# V1 release plan

Skill: `codebase-trellis`
Target: first stable public release

---

## Phase 0 - Repo creation and source audit (complete)

Deliverables:
- `README.md`
- `LICENSE`
- `docs/source-review.md`
- `docs/design-decisions.md`
- initial `skills/codebase-trellis/SKILL.md`
- ASCII/text hygiene check scripts
- install scripts (user-level and project-local, PowerShell and bash)

Acceptance:
- public sources referenced, not vendored
- no public skill copied wholesale
- no install script executes remote code
- all tracked text is ASCII

## Phase 1 - Read-only audit MVP (complete)

Deliverables:
- `audit` mode in SKILL.md
- GitHub CLI read-only posture checks where `gh` is available
- Trellis report format (full, short, stop)
- `scripts/verify-skill-package.sh` and `.ps1`

Acceptance:
- no state-changing commands without gates
- output is short but actionable
- risks clearly separated from recommendations
- verification scripts pass on the package itself

## Phase 2 - Commit planning manual mode (complete)

Deliverables:
- `commit` mode, manual default
- recent commit style detection
- staged/unstaged/untracked/deleted classification
- sensitive-file exclusion
- partial-staged detection
- generated/build output detection
- grouping by cohesion with reject conditions
- commit plan output contract (author, signing, groups, exclusions, files requiring decision)
- manual commands block with explicit "not executed" note

Acceptance:
- refuses or warns on sensitive files
- separates unrelated docs/code/config changes
- respects already staged files
- warns on pre-existing dirty files
- outputs copy-pasteable commands
- no `git add .`
- no direct commit execution
- exact file lists in all commands
- no AI trailer by default
- execute mode stubbed with "not yet available" note

## Phase 3 - Commit execute mode (complete)

Deliverables:
- `commit --execute`
- full commit plan approval
- one group at a time
- stop on first failure
- pre-stage index check before each group
- final `git status --short`
- post-commit message verification

Acceptance:
- execution requires deliberate flag
- approval text names files and messages
- final report includes commit SHAs
- never pushes

## Phase 4 - Worktree lifecycle (complete)

Deliverables:
- `start` mode with full branch-only and worktree paths
- linked-worktree and submodule detection
- dirty-state gating with commit/stash/continue-in-place decision
- `.worktrees/` ignore verification and `.gitignore` proposal
- claim conflict detection (local branch, remote branch, path, checked-out branch)
- exact per-operation approval phrases
- baseline check recommendations after creation
- start-mode stop conditions and Never list

Acceptance:
- no nested accidental worktrees
- no unignored worktree contents
- no pretending failing baseline is fine
- stops when another agent appears to own the branch/worktree
- dirty state does not cross branch boundary without decision
- all six smoke scenarios passed (A: branch, B: worktree, C: dirty gate, D: local branch conflict, E: path conflict, F: branch-in-worktree conflict)

## Phase 5 - Push and CI (complete)

Deliverables:
- `push` mode with full branch/remote/upstream/ahead/behind detection
- protected branch pattern matching (main, master, develop, release/*)
- explicit push plan output (new upstream vs existing upstream)
- approval contract with exact per-type phrases
- execute mode with pre-push state re-check and post-push verification
- push-mode stop conditions (15 conditions)
- optional CI inspection via `gh run list` after successful push
- Never-in-push-mode list

Acceptance:
- never `git push --force`
- push execution requires explicit approval phrase
- protected branch requires stronger phrase: push protected branch <name>
- CI not claimed green without pushed SHA and required checks verified
- CI monitoring skipped on push failure
- all six smoke scenarios passed (A: manual plan no upstream, B: execute new upstream, C: execute existing upstream, D: dirty gate, E: protected branch warning, F: behind/diverged gate)

## Phase 6 - Finish branch (complete)

Deliverables:
- `finish` mode with full preflight and checks freshness gate
- base branch detection (PR baseRefName > main > master > ask user)
- linked-worktree detection via GIT_DIR vs GIT_COMMON comparison
- finish options menu (5 options with blocked-option display)
- Option 1: Prepare PR only (plan-only)
- Option 2: Prepare push + PR plan (plan-only, refers to /codebase-trellis push)
- Option 3: Keep branch as-is (no mutation)
- Option 4: Merge locally with checks gate and exact approval phrase
- Option 5: Discard with typed confirmation and worktree-first cleanup order
- finish-mode stop conditions (15 conditions)
- Never-in-finish-mode list

Acceptance:
- no merge with stale/failed/absent checks except explicit scratch acceptance
- no PR creation executed (plan-only)
- no push from finish mode
- worktree removed before branch deletion (worktree-first order verified)
- discard requires exact phrase: discard <branch-name>
- no worktree removal after PR preparation
- all eight smoke scenarios passed (A: PR plan-only, B: push+PR plan-only, C: keep as-is, D: local merge, E: discard normal branch, F: discard linked worktree, G: dirty gate, H: PR state unavailable)

## Phase 7 - GitHub posture audit (complete)

Deliverables:
- expanded `audit` mode with full GitHub posture checks when `gh` is available
- local community file checks (README/LICENSE/SECURITY/CODE_OF_CONDUCT/CONTRIBUTING/CODEOWNERS/PR template/issue templates/Dependabot config/workflows dir)
- GitHub availability gate (non-GitHub remote or gh unavailable handled explicitly)
- repository identity check (nameWithOwner/visibility/archived/fork)
- branch protection check with per-field reporting
- rulesets check with active count
- CI/workflow presence check
- security feature checks: Dependabot alerts, secret scanning, code scanning, security advisories
- error shape categorization table (7 categories: auth / plan-limited / permission-limited / not-configured / not-verified / no-data / non-GitHub)
- GitHub posture output contract with all fields and honest labels
- posture recommendations block (required / useful / optional / not-verified)

Acceptance:
- no GitHub settings changed
- plan-limited reported as plan-limited (not as disabled or not configured)
- permission-limited reported separately from feature-disabled
- no claim that "no alerts = clean"
- workflows absent != no CI == green
- branch protection unavailability not collapsed into "not protected"
- real-repo read-only smoke verified: Shaelz/codebase-trellis-skill (PRIVATE, branch protection plan-limited, rulesets plan-limited, no workflows, Dependabot/secret scanning/code scanning all not-configured)

## Phase 8 - Recovery playbook (complete)

Deliverables:
- `recover` mode with full preflight (all in-progress operations, lock files, staged/unstaged/untracked, reflog)
- in-progress detection: merge/rebase/cherry-pick/revert via marker files and directories
- linked-worktree awareness: GIT_DIR vs GIT_COMMON distinction for lock file inspection
- recovery output contract: Root check / Tangle check / Recovery menu / Gate check / Next safe action
- approval contracts: exact phrases for safe/caution/destructive tiers
- safe commands: unstage, abort (merge/rebase/cherry-pick/revert), soft reset
- caution commands: restore specific file, remove stale lock (with pre-conditions)
- destructive commands: hard reset (typed), specific-path clean (typed), branch delete (typed)
- post-recovery verification for each action
- recover-mode stop conditions (14 conditions)
- Never-in-recover-mode list (11 items)

Acceptance:
- read-only first
- in-progress operations detected via marker files
- lock file removal requires no-in-progress confirmation and path inside GIT_DIR
- hard reset does not remove untracked files
- only exact-path clean allowed (no git clean -fdx or broad clean)
- branch deletion blocked for current branch
- no force push as recovery default
- all nine smoke scenarios passed (A: unstage, B: merge abort, C: rebase abort, D: cherry-pick abort, E: soft reset, F: stale lock removal, G: hard reset, H: exact-path clean, I: branch-delete stop condition)

## Phase 9 - Live-fire and hardening (complete)

Test cases run:
- A: clean tiny repo (no remote) -- audit + start
- B: dirty repo with unrelated files -- audit + commit
- C: repo with .env.local + ignored files -- audit + commit
- D: repo with pre-existing dirty state + agent change -- commit
- E: linked worktree repo -- audit + start + finish plan-only
- F: private GitHub repo (codebase-trellis-skill) -- audit read-only
- H: monorepo (apps/ + packages/) -- audit + commit

Gaps found and fixed:
1. Audit mode Tangle check: added explicit instruction to surface sensitive-looking untracked files (not just in commit mode)
2. Root check in linked worktrees: added Main repo field showing GIT_COMMON parent, so worktree path vs. main repo root is unambiguous
3. Commit grouping: added package/workspace boundary as primary grouping axis for monorepo structured passes (step 2, before same-feature grouping)

Acceptance:
- no unintended tracked changes
- no accidental push
- no hidden file inclusion
- no hallucinated GitHub posture
- reports are concise enough to use repeatedly
- sensitive untracked files surface in audit Tangle check, not only in commit mode
- linked worktree root vs main repo root is reported separately
- monorepo changes grouped by package boundary first

---

## Release checklist (v1.0.0)

### Done for RC (complete as of 2026-06-19)

- [x] All phases through Phase 9 complete and validated
- [x] `bash scripts/verify-skill-package.sh` passes
- [x] `bash scripts/check-ascii-punctuation.sh` passes on all tracked files
- [x] Install scripts verified on Windows (PowerShell) and bash
- [x] User-level install and project-local install both work and do not copy local settings
- [x] README install instructions match actual script behavior (clone + run script)
- [x] All modes listed in README: audit, start, commit, commit --execute, push, push --execute, finish, recover
- [x] No old identity strings in any tracked file
- [x] CHANGELOG updated with v1.0.0 entry covering Phases 1-9
- [x] SECURITY.md finalized for public release
- [x] CODE_OF_CONDUCT.md finalized for public release
- [x] `.github/` community files reviewed (CONTRIBUTING.md, PR template, issue templates)
- [x] LICENSE is MIT with correct year and name
- [x] docs/FUTURE_BRANCHES.md contains only non-v1 items; all v1 core items are implemented

### Pre-tag checklist (historical; required steps completed 2026-06-19)

The annotated `v1.0.0` tag was created and pushed after the required checks. It points at commit `fb498c9`. The optional clean-clone smoke install was not recorded as part of the final tag operation.

- [x] Final run of `bash scripts/verify-skill-package.sh`
- [x] Final run of `bash scripts/check-ascii-punctuation.sh skills docs README.md CHANGELOG.md SECURITY.md CODE_OF_CONDUCT.md`
- [x] Confirm `git tag --list` shows no existing v1.0.0 tag
- [x] Confirm `git status` is clean
- [ ] Optional: smoke-install from a clean clone into a temp directory to verify the install path end-to-end
- [x] Review CHANGELOG entry for accuracy -- remove "-rc.1" suffix if releasing as final
- [x] Create tag: `git tag -a v1.0.0 -m "v1.0.0"` (only after review above)
- [x] Push tag: `git push origin v1.0.0` (only after tag is confirmed)

### Must do before making the repository public

- [ ] Decide branch protection / ruleset posture for `main` (require PR, require checks, no force push)
- [ ] Decide whether to add `CODEOWNERS` (for single-maintainer: optional; for team: recommended)
- [ ] Decide whether to add Dependabot config (`.github/dependabot.yml`; no runtime deps in v1, low urgency)
- [x] Add a minimal CI workflow that runs package and ASCII verification on pushes to `main` and pull requests
- [ ] Review all tracked files once more for any private paths, email addresses, or local machine artifacts
- [ ] Confirm repo description, topics, and website field in GitHub settings are set
- [ ] Change repo visibility to public (GitHub Settings > Danger Zone > Change visibility)

### Must do immediately after making the repository public

- [ ] Enable GitHub private vulnerability reporting before announcing or treating the public release as complete

### Optional after public release

- [ ] Create a GitHub release from the v1.0.0 tag with the CHANGELOG entry as release notes
- [ ] Add GitHub repo topics: `claude-code`, `git`, `skill`, `developer-tools`
- [ ] Post announcement if relevant
- [ ] Add CI badge to README if a workflow is added

## Non-goals for v1

- No auto-merge to main.
- No default `git add .`.
- No default push after commit.
- No automatic force push.
- No branch deletion without typed confirmation.
- No replacement of GitHub branch protection or rulesets.
- No AI co-author trailer by default.
- No secret cleanup automation.
- No hook installation without explicit user request.
- No modification of GitHub repository settings.
