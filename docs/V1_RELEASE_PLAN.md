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

## Phase 7 - GitHub posture audit

Deliverables:
- read-only checks for branch protection, rulesets, required checks
- review requirements
- security feature visibility
- SECURITY.md, CODEOWNERS, PR template presence

Acceptance:
- no settings changed automatically
- limitations reported if `gh` lacks permissions
- no overclaiming on plan-dependent features

## Phase 8 - Recovery playbook

Deliverables:
- `recover` mode
- in-progress merge/rebase/cherry-pick detection
- reflog-based recovery guidance
- stale lock handling
- soft reset guidance
- accidentally staged file guidance

Acceptance:
- read-only first
- destructive operations require typed confirmation
- no force push as recovery default

## Phase 9 - Live-fire and hardening

Test cases:
- clean tiny repo
- dirty repo with unrelated files
- repo with `.env` and ignored files
- repo with pre-existing dirty state
- repo with failing tests
- monorepo
- worktree repo
- private GitHub repo with limited `gh` permissions
- public repo with branch protections

Acceptance:
- no unintended tracked changes
- no accidental push
- no hidden file inclusion
- no hallucinated GitHub posture
- reports are concise enough to use repeatedly

---

## Release checklist (v1.0)

Before tagging v1.0.0:

- [ ] All phases through Phase 9 complete and validated
- [ ] `bash scripts/verify-skill-package.sh` passes
- [ ] `bash scripts/check-ascii-punctuation.sh` passes on all tracked files
- [ ] Install scripts tested on Windows (PowerShell) and macOS/Linux (bash)
- [ ] User-level install and project-local install both verified
- [ ] README install instructions match actual script behavior
- [ ] No old identity strings in any tracked file
- [ ] CHANGELOG updated with v1.0.0 entry
- [ ] SECURITY.md finalized for public release
- [ ] CODE_OF_CONDUCT.md finalized for public release
- [ ] `.github/` community files reviewed
- [ ] Git tag `v1.0.0` created
- [ ] GitHub repo visibility set to public (if applicable)

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
