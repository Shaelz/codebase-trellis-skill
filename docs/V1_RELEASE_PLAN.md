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

## Phase 2 - Commit planning manual mode

Deliverables:
- `commit` mode, manual default
- recent commit style detection
- staged/unstaged/untracked/deleted classification
- sensitive-file exclusion
- partial-staged detection
- grouping by cohesion
- commit-message generation
- post-execution checklist

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

## Phase 3 - Commit execute mode

Deliverables:
- `commit --execute`
- full commit plan approval
- one group at a time
- stop on first failure
- final `git status --short`
- post-commit message verification

Acceptance:
- execution requires deliberate flag
- approval text names files and messages
- final report includes commit SHAs
- never pushes

## Phase 4 - Worktree lifecycle

Deliverables:
- `start` mode
- worktree/submodule detection
- `.worktrees/` ignore verification
- setup command detection
- baseline checks
- claim conflict detection

Acceptance:
- no nested accidental worktrees
- no unignored worktree contents
- no pretending failing baseline is fine
- stops when another agent appears to own the branch/worktree

## Phase 5 - Push and CI

Deliverables:
- `push` mode
- branch/remote/upstream/ahead detection
- protected branch warning
- explicit push plan
- optional `--execute`
- CI watch using `gh run list/view` when available

Acceptance:
- never `git push --force`
- push execution requires explicit approval
- protected branch requires typed branch name
- CI monitoring never runs after failed push

## Phase 6 - Finish branch

Deliverables:
- `finish` mode
- fresh checks requirement
- environment detection
- base branch detection
- option menu
- PR preparation
- local merge path
- cleanup path
- discard path

Acceptance:
- no merge with failing tests
- no cleanup after PR creation
- worktree removed before branch deletion
- discard requires typed confirmation

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
