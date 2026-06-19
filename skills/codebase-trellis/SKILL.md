---
name: codebase-trellis
description: 'Use when staging, committing, pushing, reviewing PRs, checking CI, finishing branches, or auditing Git/GitHub repo posture for AI-assisted work. Inspect first, propose second, mutate only after explicit approval. Good triggers: dirty working tree, commit planning, push planning, PR prep, branch cleanup, worktree setup, Git state review, CI inspection, repo posture audit. Trigger phrases: commit, push, stage, PR, branch, worktree, finish, recover, git status, git audit, trellis.'
---

# Codebase Trellis

Structure, support, and safely integrate AI-assisted code changes.

Ecosystem:
- `codebase-orient` understands the codebase.
- `codebase-visualize` maps the codebase.
- `codebase-trellis` supports safe change growth and integration.

---

## When to use this skill

### Use this skill when

- Files have changed and need safe staging, commit planning, or commit execution.
- A branch or worktree needs to be set up, finished, or cleaned up.
- A push, PR, or CI state needs inspection or preparation.
- Git/GitHub repo posture needs an audit.
- A long-running agent session needs a structured state review before continuing.
- The working tree is dirty and the right next step is unclear.

### Skip this skill when

- The task is a tiny, single-file, known fix with no Git state uncertainty.
- Read-only exploration is happening and no commit/push/cleanup work is planned.
- Another skill (`codebase-orient`, `codebase-visualize`) was just invoked and no Git work follows.

---

## Simple vs structured classification

Classify each invocation before running any workflow.

Simple pass:
- localized bug fix
- docs-only or copy-only change
- dependency bump
- small refactor
- test-only change
- already-scoped commit preparation

Structured pass:
- broad multi-file change
- multiple packages
- UI plus API plus tests
- migration or generated files
- long-running agent work
- multiple commits expected
- resume or handoff likely needed

Default to simple when unsure. Promote to structured if inspection proves the work is larger than it appeared. Never demote from structured after safety state has been established.

---

## Enforcement layers

Trellis operates within a 4-layer safety model. These layers are not equivalent and no layer substitutes for another.

**Layer 1: Skill discipline** (core v1 layer)

The skill inspects, reports, and gates risky operations. Works in any normal Git repo without extra hooks or GitHub access. This is behavioral -- it depends on the agent following the skill.

**Layer 2: Local Git hooks**

Repository-local hooks can run during commit or push. Trellis may recommend hooks but does not require or install them in v1. Hooks can be missing, bypassed with `--no-verify`, or not shared across clones.

**Layer 3: Claude Code hooks**

Host-level hooks can act around tool use, file changes, and permissions. Optional hardening only -- not required for the standalone core. Do not assume they are installed.

**Layer 4: GitHub protections**

GitHub-side enforcement: branch protection, rulesets, required checks, required reviews, signed commits, force-push restrictions, merge queue, secret scanning, code scanning, Dependabot. Inspect and report when API access allows; never assume protections exist.

**Non-equivalence rule:**

- Skill discipline is not a hook.
- A local hook is not GitHub branch protection.
- A passing local grep is not secret scanning.
- PR-head checks are not merge-queue checks.
- A visible green check is not proof that all required checks passed for the relevant SHA.

If a layer is unavailable or unverified, say so plainly.

---

## Interoperability boundary

### Standalone core

Codebase Trellis must work in any normal Git repo without requiring sister-skill artifacts. It owns:

- Git status and dirty-state inspection
- staged, unstaged, untracked, ignored, generated, sensitive, and pre-existing change detection
- commit grouping and commit-plan handoff
- branch/worktree safety
- push/PR/CI gates
- cleanup rules
- Trellis report output

### Optional advisory reads

If sister-skill artifacts exist, Trellis may read them as advisory context only.

From `codebase-orient` (examples: `docs/ai/CODEBASE_MAP.md`, `docs/ai/CHANGE_SURFACES.md`, `docs/ai/OPEN_QUESTIONS.md`):
- repo layout and package/workspace structure
- known checks and generated-doc policy
- important conventions and danger zones

From `codebase-visualize` (examples: `docs/ai/visualize/codebase-graph.json`):
- blast radius and affected modules
- docs-to-code edges and high-centrality files

Rules:
- Do not require these files.
- Do not regenerate them.
- Do not silently modify them.
- Do not block routine commit planning because visualization is absent.
- Do not treat them as more authoritative than source/config/canonical docs.

### Handoff triggers

- Suggest `/codebase-orient` when repo structure is unclear, known checks are unknown, or the agent lacks enough context to classify risk.
- Suggest `/codebase-visualize` when change impact is broad or architectural, dependency relationships matter, or blast radius would improve the decision.

---

## Universal rules

Always:

1. Start by identifying repo root, branch, and dirty state.
2. Show state before proposing commands.
3. Separate staged, unstaged, untracked, deleted, and ignored files.
4. Treat partially staged files as ambiguous and risky.
5. Exclude sensitive files from all commit plans.
6. Prefer exact file lists over broad path commands.
7. Stop on command failure.
8. Say when `gh` is unavailable or lacks permission.
9. Keep reports short and actionable.
10. Report what is known and what is unknown; do not collapse unknowns into assumed safety.

Never:

1. Run `git add .` without explicit approval of the exact file list.
2. Commit without showing the planned files and commit message.
3. Push as part of commit.
4. Merge as part of push.
5. Use `git push --force`.
6. Infer `--force-with-lease`; it must be explicitly requested.
7. Delete branches without typed confirmation of the branch name.
8. Remove worktrees not created by this session or not clearly project-local disposable worktrees.
9. Include `.env`, keys, tokens, credentials, or ignored files in a commit plan.
10. Claim tests, CI, or GitHub settings passed unless verified.
11. Claim "no secrets" or "no vulnerabilities" from a local grep or visible checks alone.
12. Report CI as green unless the relevant SHA and required checks are both known.
13. Silently include pre-existing dirty files.
14. Silently include untracked files.

---

## Risk gates

**Read-only** -- no approval needed:

- `git status`, `git diff --stat`, `git log`, `git remote -v`
- `gh pr view`, `gh run list`, `gh repo view`
- Any inspection or diagnostic command that does not change state

**Low state change** -- visible plan and approval required in execute mode:

- Create local branch
- Create local worktree
- Stage explicitly listed files
- Create commit from approved plan

**High state change** -- explicit approval required:

- Push (any branch)
- Create PR
- Merge branch
- Rebase branch
- Edit branch protection or rulesets
- Delete branch
- Remove worktree

**Dangerous** -- typed confirmation and prefer outputting commands over executing:

- Push to protected branch (requires typed branch name)
- `--force-with-lease` push (must be explicitly requested)
- `git reset --hard`
- `git clean -fd` or any untracked-file removal
- Delete branch with unmerged commits
- Rewrite public history
- Secret-history remediation

`git push --force` is always forbidden.

---

## Sensitive file patterns

Never include these in a commit plan. If the user overrides after a warning, warn again and recommend against it.

```
.env
.env.*
*.pem
*.key
*.p12
*.pfx
id_rsa*
*.cert
.aws/credentials
credentials.json
*.secret
token.txt
.npmrc
auth.json
service-account*.json
```

Also exclude: ignored files, build output, caches, and dependency folders unless the repo intentionally tracks them.

Common excludes:
```
node_modules/
dist/
build/
.cache/
.svelte-kit/
.next/
coverage/
__pycache__/
*.pyc
```

---

## Security visibility boundary

Trellis may report visible security signals. Trellis is not a full security scanner.

Report when visible:
- secret-shaped files in the local diff (file names or patterns matching `.env`, `*.key`, etc.)
- whether GitHub secret scanning and push protection appear enabled
- whether CodeQL or code scanning is configured
- whether Dependabot alerts or security updates are visible
- whether dependency files changed in this diff

Never claim:
- "no secrets found" solely because local grep found nothing
- "no vulnerabilities" solely because visible GitHub checks are green
- security posture is clean unless verified through a dedicated security tool

---

## GitHub/CI visibility boundary

Report what can and cannot be verified. Do not collapse unknown protection state into assumed safety.

CI modes are different questions -- do not conflate them:

PR-level readiness:
- Is this PR merge-ready?
- Are required checks passing for this SHA?
- Are pending, skipped, or cancelled checks relevant?

Workflow-run inspection:
- Why did this run fail?
- Which job or step failed?
- Are logs or artifacts available?

GitHub protection state -- report one of:
- `Protection state: verified -- <summary of what was found>`
- `Protection state: not verified. Do not assume main is protected.`

Merge queue -- if a merge queue is required, PR-head checks are not the final signal. Report separately:
- PR head checks
- required checks
- merge-queue or merge-group checks if present
- whether the checked SHA matches the commit being discussed

Never add to merge queue, enable auto-merge, or merge without explicit user approval.

---

## Trellis report

The Trellis report is the signature output of every inspection or planning pass.

### Full form

```
Trellis report

Root check
- Repo root:
- Branch:
- Remote/upstream:
- Worktree state:
- Identity/signing state:
- Baseline dirty files (pre-existing):

Tangle check
- Staged changes:
- Unstaged changes:
- Untracked files:
- Ignored/generated files of note:
- Sensitive-looking files:
- Partially staged files:
- Mixed concerns:

Growth plan
- Suggested change groups:
- Suggested commit boundaries:
- Suggested PR shape:
- Files excluded from scope:
- Files requiring user decision:

Gate check
- Safe to inspect/read: yes
- Requires approval before staging:
- Requires approval before commit:
- Requires approval before push:
- Requires approval before merge/auto-merge:
- Requires approval before cleanup/delete:

Canopy check
- GitHub repository/PR visibility:
- Required checks:
- CI state and SHA checked:
- Branch protection/ruleset state:
- Merge queue state:
- Security signals visible:
- Unknowns/unverified protections:

Next safe action
- Recommendation:
- Exact commands (read-only only, or with gate annotation):
- Decision required from user:
```

### Short form

Use for simple passes or small working trees.

```
Trellis report
- Root: <repo / branch / worktree summary>
- Tangle: <staged / unstaged / untracked / sensitive / mixed-concern summary>
- Growth: <commit/PR grouping recommendation>
- Gates: <operations requiring approval>
- Canopy: <GitHub/CI/protection state if known, or "not verified">
- Next: <one safe next action>
```

### Stop form

Use when Trellis cannot or must not continue.

```
Trellis stop
- Stop reason:
- Evidence:
- Risk if ignored:
- Safe recovery options:
- Recommended option:
```

Stop reasons include:
- Sensitive-looking file would be staged.
- Pre-existing dirty file would be silently included.
- Partially staged file makes intent ambiguous.
- Target branch is protected or unknown and a push/merge was requested.
- Force-like operation was requested without explicit risk acceptance.
- Claimed push or CI state refers to a different SHA.
- Another branch, worktree, or PR appears to own the same task.

---

## Mode routing

Read `$ARGUMENTS`.

If no mode is supplied, run `audit`.

Supported modes:
- `audit`: read-only local Git and GitHub posture review
- `start`: prepare isolated work using a branch or worktree
- `commit`: plan or execute cohesive commits
- `push`: prepare or execute push and CI monitoring
- `finish`: finish branch through PR, local merge, keep, or discard
- `recover`: recover from Git mistakes

---

## `audit` mode

Run read-only diagnostics. Produce a Trellis report. Never modify any local or remote state.

### Audit preflight -- local Git

Always run first, regardless of `gh` availability:

```bash
git rev-parse --show-toplevel 2>/dev/null || echo "ERROR: not a git repo"
git branch --show-current
git status --short
git diff --stat
git diff --cached --stat
git log --oneline -10
git remote -v
git config --show-origin --show-scope --get user.name 2>/dev/null || echo "unset"
git config --show-origin --show-scope --get user.email 2>/dev/null || echo "unset"
git config commit.gpgsign 2>/dev/null || echo "unset"
```

### Audit preflight -- community file checks

Check presence/absence of each file locally. Presence/absence is a verified fact; content quality is not:

```bash
test -f README.md && echo "present" || echo "absent"
test -f LICENSE && echo "present" || echo "absent"
test -f SECURITY.md && echo "present" || echo "absent"
test -f CODE_OF_CONDUCT.md && echo "present" || echo "absent"
test -f CONTRIBUTING.md || test -f .github/CONTRIBUTING.md && echo "present" || echo "absent"
test -f .github/PULL_REQUEST_TEMPLATE.md && echo "present" || echo "absent"
test -d .github/ISSUE_TEMPLATE && echo "present" || echo "absent"
test -f CODEOWNERS || test -f .github/CODEOWNERS || test -f docs/CODEOWNERS && echo "present" || echo "absent"
test -f .github/dependabot.yml || test -f .github/dependabot.yaml && echo "present" || echo "absent"
test -d .github/workflows && echo "present" || echo "absent"
```

### GitHub posture -- availability gate

Before running any `gh` command:

1. Check if a GitHub remote is present: `git remote -v | grep github.com`
2. Check if `gh` is available: `gh auth status 2>/dev/null`

If no GitHub remote is detected: report all GitHub posture fields as `unavailable -- non-GitHub remote`.

If `gh` is unavailable or auth fails: report all GitHub posture fields as `unavailable -- gh not authenticated`.

Do not attempt any `gh` call if the gate fails.

### GitHub posture -- repository identity

```bash
gh repo view --json nameWithOwner,visibility,defaultBranchRef,isArchived,isFork,mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed,autoMergeAllowed,deleteBranchOnMerge,hasIssuesEnabled,hasWikiEnabled,hasDiscussionsEnabled 2>/dev/null
```

Report each field. If any field is absent or the call fails, mark that field as `not verified`.

### GitHub posture -- branch protection

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null)
gh api repos/:owner/:repo/branches/$DEFAULT/protection 2>/dev/null
```

Interpret:

- HTTP 200 with data: report each sub-field (required status checks, required reviews, signed commits, force-push restrictions, deletion restrictions) as `verified` with the value.
- HTTP 403 "plan-limited": mark branch protection state as `plan-limited`.
- HTTP 403 permission gap: mark as `permission-limited`.
- HTTP 404 "branch not protected": mark as `not configured`.
- Any other error: mark as `not verified` with the error summary.

Never infer protection state from a failure. Absence of data is `not verified`, not `not configured`.

### GitHub posture -- rulesets

```bash
gh api repos/:owner/:repo/rulesets 2>/dev/null
```

Interpret:

- HTTP 200 with data: count active rulesets and note they may overlap with branch protection.
- HTTP 200 empty array: mark as `not configured`.
- HTTP 403 plan-limited: mark as `plan-limited`.
- HTTP 403 permission: mark as `permission-limited`.
- HTTP 404: mark as `unavailable`.

Note: rulesets and branch protection rules can coexist. A clean ruleset result does not mean branch protection is absent.

### GitHub posture -- CI and required checks

```bash
gh workflow list 2>/dev/null
gh run list --branch "$DEFAULT" --limit 10 2>/dev/null
```

Interpret:

- Workflows absent: report `no .github/workflows/ directory detected locally` (cross-check with local file check).
- Runs present: summarize recent runs by status and branch. Always include the SHA of each run.
- Never treat "workflow exists" as "required check exists."
- Never treat "recent run green" as "required checks passed."
- Required checks are only verified if branch protection or ruleset data proves they are configured.

### GitHub posture -- security features

Run each call separately. Categorize each independently:

```bash
gh api repos/:owner/:repo/dependabot/alerts 2>/dev/null
gh api repos/:owner/:repo/secret-scanning/alerts 2>/dev/null
gh api repos/:owner/:repo/code-scanning/alerts 2>/dev/null
gh api repos/:owner/:repo/security-advisories 2>/dev/null
```

Categorize each result using the error shape rules below.

Never claim "no alerts found" means "clean." An empty result may mean no alerts or may mean the feature is not configured or not accessible.

### GitHub posture -- error shape categorization

Classify every `gh` / `gh api` failure by shape. Do not infer from one category to another:

| Error shape | Label |
|---|---|
| `gh auth status` fails / not logged in | `unavailable -- gh not authenticated` |
| 403 + "Upgrade to GitHub Pro" or "make this repository public" | `plan-limited` |
| 403 + "needs the ... scope" | `permission-limited -- missing OAuth scope` |
| 403 + "disabled for this repository" | `not configured -- feature off` |
| 403 + "not enabled for this repository" | `not configured -- feature not enabled` |
| 404 + "Branch not protected" | `not configured` |
| 404 (other cause unclear) | `not verified -- endpoint unavailable` |
| 200 + empty list | `no data -- feature may be configured but no results` |
| Non-GitHub remote | `unavailable -- not a GitHub remote` |

Report the label and the raw error fragment. Do not rephrase failures as safety assertions.

### GitHub posture output contract

Produce this block in the Canopy check:

```
GitHub posture
  Repository:    <owner/name> (<visibility: public/private/internal>) [archived: yes/no] [fork: yes/no]
  Default branch: <name>
  Branch protection: <verified -- <summary> / not configured / plan-limited / permission-limited / not verified>
    Required status checks:   <verified / not configured / not verified>
    Required approving reviews: <verified -- N / not configured / not verified>
    Signed commits required:  <verified / not configured / not verified>
    Force-push restrictions:  <verified / not configured / not verified>
    Deletion restrictions:    <verified / not configured / not verified>
  Rulesets:      <verified -- N active / not configured / plan-limited / permission-limited / unavailable>
  Required checks: <verified -- <list> / not configured / not verified>
  Recent CI:     <runs summary with SHA, or not verified>
  Merge settings: <merge-commit: yes/no | squash: yes/no | rebase: yes/no | auto-merge: yes/no | delete-on-merge: yes/no, or not verified>
  Community files:
    README:           <present / absent>
    LICENSE:          <present / absent>
    SECURITY.md:      <present / absent>
    CODE_OF_CONDUCT:  <present / absent>
    CONTRIBUTING:     <present / absent>
    CODEOWNERS:       <present / absent>
    PR template:      <present / absent>
    Issue templates:  <present / absent>
    Dependabot config: <present / absent>
    Workflows dir:    <present / absent>
  Security features:
    Secret scanning:  <verified -- enabled/disabled / not configured / plan-limited / permission-limited / unavailable>
    Push protection:  <verified / not configured / plan-limited / permission-limited / unavailable>
    Dependabot alerts: <verified / not configured / plan-limited / permission-limited / unavailable>
    Code scanning:    <verified / not configured / plan-limited / permission-limited / unavailable>
    Security advisories: <verified / not configured / plan-limited / permission-limited / unavailable>
  Repository settings (if visible):
    Issues: <enabled/disabled/not verified> | Wiki: <enabled/disabled/not verified> | Discussions: <enabled/disabled/not verified>
  Unknowns: <explicit list of fields that could not be verified>
```

### Posture recommendations

After the GitHub posture block, include:

```
Posture recommendations
  Required before public release:  <list -- suggestions only, not commands>
  Useful before public release:    <list>
  Optional / later:                <list>
  Not verified / check manually:   <list>
```

Recommendations are suggestions only. Do not execute them.

Output: full Trellis report with the GitHub posture block in Canopy check. Use short form only if the repo is entirely local with no GitHub remote.

---

## `start` mode

Prepare isolated work using a branch or worktree. This mode is read-only until explicit per-operation approval is given.

### Start preflight

Run all of the following before proposing anything:

```bash
git rev-parse --show-toplevel 2>/dev/null || echo "ERROR: not a git repo"
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
git branch --show-current
git remote -v
git rev-parse --show-superproject-working-tree 2>/dev/null
git status --short
git worktree list
```

Interpretation:

- If `rev-parse --show-toplevel` fails, emit a Trellis stop: not inside a Git repo.
- If `rev-parse --show-superproject-working-tree` returns a path, the current directory is inside a submodule. Report this and treat as a normal repo unless the user explicitly intends submodule work.
- If `GIT_DIR != GIT_COMMON` and the repo is not a submodule, the current checkout is already a linked worktree. Report this. Do not create another worktree adjacent to or nested under it unless the user explicitly requests it and the path is verified safe.
- If `git status --short` returns any output, see "Dirty state handling" below.

### Dirty state handling

If dirty state exists:

1. Report all dirty files.
2. Present this decision before any branch or worktree operation:

```
Dirty working tree detected. Choose before continuing:
  a) Commit the changes first -- run /codebase-trellis commit
  b) Stash -- git stash push -m "<description>"
  c) Continue in place -- worktree can be created from a clean base ref; dirty files stay in the current checkout
  d) Abort

Branch switching is not safe over a dirty working tree.
Worktree creation from a clean base ref is safe only if the dirty files remain untouched in the current checkout.
```

3. Do not switch branches. Do not create anything. Wait for the user's decision.

### Claim conflict detection

Before proposing any creation command, run:

```bash
# Local branch check
git branch --list "<requested-name>"

# Remote branch check (only if a remote exists)
git branch -r --list "origin/<requested-name>"

# All worktrees -- detects path and branch conflicts
git worktree list

# Path existence check
test -e "<requested-path>" && echo "path exists"
```

If `gh` is available:

```bash
gh pr list --head "<requested-name>" --json number,title,state 2>/dev/null
```

Conflict cases and handling:

| Conflict | Action |
|---|---|
| Local branch exists | Trellis stop |
| Remote branch exists | Trellis stop; intent unclear |
| Branch checked out in another worktree | Trellis stop; cannot create second checkout |
| Requested path exists (file or directory) | Trellis stop |
| Open PR for the branch | Trellis stop; may be active work |

If any conflict is found, emit a Trellis stop and do not create anything.

### Worktree path selection

Priority order:

1. Explicit user-provided path
2. Existing `.worktrees/` directory at the repo root
3. Existing `worktrees/` directory at the repo root
4. Default `.worktrees/` (to be created)

Before using any project-local path, check ignore status:

```bash
git check-ignore -q .worktrees 2>/dev/null && echo "ignored" || echo "not-ignored"
git check-ignore -q worktrees 2>/dev/null && echo "ignored" || echo "not-ignored"
```

If the chosen path is not gitignored:

1. Warn: the worktree directory is not gitignored. Its contents may surface as untracked files in the main checkout.
2. Propose adding the path to `.gitignore`. Show the exact line to add.
3. Do not edit `.gitignore` without explicit approval.
4. Do not create the worktree inside an unignored project-local directory unless the user explicitly approves the tracking risk.

### Branch-only vs worktree decision

Recommend branch-only when:
- The repo is clean.
- The user needs a normal branch and no parallel work is required.
- No agent or session separation is needed.

Recommend worktree when:
- The user wants isolated parallel work without touching the current checkout.
- The current branch must remain untouched.
- Agent or session separation matters.
- Dirty state exists on the current checkout and must not be disturbed.

If the user does not specify, ask:

```
Do you want:
  (a) branch only -- switches the current checkout to a new branch
  (b) worktree    -- creates an isolated copy of the repo on a new branch
```

### Start-mode output contract

After running the preflight, output in this order:

**1. Trellis report** -- full form when worktree state, dirty state, or conflicts were detected; short form for a clean simple-branch start:

```
Trellis report

Root check
- Repo root:
- Branch:
- Remote/upstream:
- Git dir:
- Common git dir:
- Linked-worktree status: <yes -- already a linked worktree at <path> / no>
- Submodule/superproject: <yes -- superproject at <path> / no>
- Dirty state: <files listed, or clean>

Tangle check
- Dirty files: <list or none>
- Ignored/generated notes:
- Pre-existing ambiguity:
- Branch/worktree conflicts found: <list or none>

Growth plan
- Recommended isolation: <branch-only / worktree / decision-required>
- Suggested branch name:
- Suggested worktree path (if worktree):
- .worktrees/ ignore status: <ignored / not-ignored / N/A>
- Baseline checks to run after creation:

Gate check
- Safe to inspect/read: yes
- Requires approval before branch creation: <exact command and approval phrase>
- Requires approval before worktree creation: <exact command and approval phrase>
- Requires approval before .gitignore edit: yes if needed

Canopy check
- Remote state: <remote URL / none>
- Open PR/branch conflict: <found / not found / gh not available>
- Protection state: <verified -- ... / not verified. Do not assume main is protected.>

Next safe action
- Recommendation:
- Decision required from user:
```

**2. Creation plan:**

Branch-only plan:

```
Branch creation plan
  Branch name: <name>
  Base:        <current branch or HEAD>
  Command:     git checkout -b <name>

Approve?
Reply exactly: create branch <name>
```

Worktree plan:

```
Worktree creation plan
  Branch name:    <name>
  Worktree path:  <path>
  Command:        git worktree add <path> -b <name>
  .gitignore edit needed: <yes / no>

Approve?
Reply exactly: create worktree <name> at <path>
```

**3. Post-creation report:**

After successful creation:

```
Created: <branch / worktree>
  Branch:           <name>
  Path (worktree):  <absolute path>
  Status:           <git branch output or git worktree list output>

Baseline checks recommended:
  <list based on repo conventions, e.g.:
    package.json present -- run: npm install
    Gemfile present      -- run: bundle install
    Cargo.toml present   -- run: cargo build
    requirements.txt present -- run: pip install -r requirements.txt
    go.mod present       -- run: go build ./...>

Next step: Work in <path or current checkout on new branch>.
```

### Approval contract

Branch creation:

- Show the exact `git checkout -b <name>` command.
- Require exact phrase: `create branch <name>`
- `yes`, `ok`, `go`, or vague approval is not sufficient.

Worktree creation:

- Show the exact `git worktree add <path> -b <name>` command.
- Require exact phrase: `create worktree <name> at <path>`
- `yes`, `ok`, `go`, or vague approval is not sufficient.

`.gitignore` edit:

- Show the exact line to be added.
- Do not edit without explicit approval.

Approval for one operation does not approve any other operation in the same session.

### Start-mode stop conditions

Emit a Trellis stop and halt when:

- Not inside a Git repo.
- Current checkout is already a linked worktree and creating another is unsafe.
- Submodule/superproject state is ambiguous and user has not clarified intent.
- Dirty state exists and branch switching was requested without a commit/stash decision.
- Requested branch name already exists locally.
- Requested branch name already exists on remote and intent is unclear.
- Requested branch is already checked out in another worktree.
- Requested worktree path already exists.
- Chosen worktree path is not gitignored and user has not approved the tracking risk.
- Branch name or path contains `..`, `//`, or other path-traversal characters.
- `git worktree add` fails.
- Baseline checks fail after creation and user has not chosen to continue.

### Never in start mode

- `git push`
- `git merge`
- `git rebase`
- deleting branches or worktrees
- cleaning up or removing worktrees
- editing `.gitignore` without approval
- creating a branch or worktree without showing the plan and receiving exact approval
- silently resolving dirty state
- silently proceeding after a conflict is detected

---

## `commit` mode

Default: manual mode. Do not execute `git add`, `git commit`, or any other Git state-changing command. Output a commit plan and copyable commands for user review only.

If `--execute` is passed, see the execute sub-mode at the end of this section.

### Preflight

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --short
git diff --name-status
git diff --cached --name-status
git log --oneline -15
git config --show-origin --show-scope --get-all user.name 2>/dev/null || echo "unset"
git config --show-origin --show-scope --get-all user.email 2>/dev/null || echo "unset"
git config --show-origin --get commit.gpgsign 2>/dev/null || echo "unset"
git config --show-origin --get user.signingkey 2>/dev/null || echo "unset"
```

### Dirty-state classification

Classify every file from `git status --short` output into exactly one category before proposing any grouping. The two-character prefix encodes index state (first char) and worktree state (second char):

| Category | Prefix example | Handling |
|---|---|---|
| Staged added | `A ` | Treat as user intent; check not sensitive |
| Staged modified | `M ` | Treat as user intent; audit for mixed concern |
| Staged deleted | `D ` | Include in group; confirm intentional |
| Staged renamed | `R ` | Confirm both old and new paths |
| Unstaged modified | ` M` | Primary candidates for grouping |
| Unstaged deleted | ` D` | Ask whether intentional or accidental |
| Untracked | `??` | Never include silently; ask first |
| Partially staged | `MM`, `AM`, `MD`, etc. | Stop -- intent is ambiguous |
| Sensitive-looking | any status | Exclude from all groups |
| Generated/build | any status | Flag and ask before including |

Partially staged detection: a file is partially staged when both characters in the status prefix are non-space and the file is not untracked. Identify all such files before attempting any grouping.

Pre-existing dirty files: if the conversation context indicates a file was already dirty before the current session's changes began, do not silently include it. Flag it under "Files requiring user decision."

### Sensitive file detection

Before grouping, check every candidate file against the sensitive file patterns defined in the "Sensitive file patterns" section. If any file matches:

1. Exclude it from all commit groups.
2. Report it under "Sensitive-looking files" in the Tangle check.
3. Do not include it in any staging command even if the user asks.
4. If the user insists after warning, warn again. You may list the command so the user can run it manually, but exclude the file from the proposed group.

### Generated and build output detection

Before grouping, check candidate files against common generated or build output patterns:

Paths to flag: `dist/`, `build/`, `.next/`, `.svelte-kit/`, `out/`, `target/`, `node_modules/`, `__pycache__/`, `.cache/`, `coverage/`, `.nyc_output/`

Extensions to flag: `.pyc`, `.class`, `.o`, `.a`, `.so`, `.dylib`

If the repo's recent commit history includes these paths, treat them as intentionally tracked and note that in the plan. Otherwise, place them under "Generated (policy unknown)" and ask the user before including.

Lock files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`, `poetry.lock`) are usually intentionally tracked. Check recent commits before flagging them.

### Grouping priorities

Apply in order after classification:

1. Already staged files: respect as user intent. Audit for mixed concerns. If staged files span unrelated concerns, warn and ask whether to split.
2. Same feature or module: files sharing a package, directory, or named feature belong together.
3. Source plus corresponding tests: a source file and its matching test file changed together belong in one group.
4. Pure docs: markdown, prose, or comment-only changes without corresponding source changes -- one group.
5. Pure config or dependencies: config files and lock file updates -- one group per concern.
6. Remaining files: do not force-fit. Split conservatively and ask the user.

Do not produce a grouping that:
- Mixes a feature change with unrelated docs or config.
- Mixes a bug fix with a refactor.
- Mixes multiple unrelated features.
- Includes generated or build output without explicit user consent.

When grouping is ambiguous, split and ask rather than merging into a large commit.

### Commit message inference

```bash
git log --oneline -15
```

- If recent commits follow conventional commit format (`type(scope): subject`), suggest that.
- If recent commits use plain imperative style, suggest that.
- Match capitalization, punctuation, and length from recent messages.
- Subject describes the change, not the file list. Keep under 72 characters.
- Never add AI attribution, `Generated by Claude`, robot tags, or co-author trailers unless the user explicitly requests them.

### Commit plan output contract

After classification and grouping, output in this order:

**1. Trellis report** -- short form for simple passes; full form when dirty state is complex, concerns are mixed, or stop conditions were encountered.

**2. Commit plan:**

```
Commit plan
Author: <name> <<email>>
Signing: <gpg enabled / unset>
Style detected: <conventional / plain / unknown>

Group 1 -- <label>
  Files:
    path/to/file1
    path/to/file2
  Suggested message: "type(scope): subject"

Group 2 -- <label>
  Files:
    path/to/file3
  Suggested message: "type(scope): subject"

Excluded from all groups:
  Sensitive: <list or none>
  Generated (policy unknown): <list or none>
  Untracked (need explicit approval): <list or none>
  Pre-existing dirty (not in scope): <list or none>
  Ignored: <list or none>

Files requiring user decision:
  path/to/file -- <reason>
```

**3. Manual commands (not executed):**

Emit one block per group only when no stop condition applies and grouping is unambiguous:

```bash
# Group 1 -- <label>
git add path/to/file1 path/to/file2
git commit -m "$(cat <<'EOF'
type(scope): subject

EOF
)"
```

End with: `These commands are not executed. Review and adjust as needed, then run manually.`

If a stop condition applies to any group, omit the command block for that group and emit a Trellis stop for it instead.

### Stop conditions

Emit a Trellis stop (stop form) and omit staging commands for affected files when:

- A sensitive-looking file is in the candidate set without explicit user acknowledgment.
- Partially staged files are present and intent is ambiguous.
- Generated or build output is present and tracking policy is unknown.
- An untracked file would be silently included without explicit user consent.
- A pre-existing dirty file would be silently included without explicit acknowledgment.
- Multiple unrelated concerns cannot be separated cleanly and the user has not provided grouping intent.
- No changes exist at all.

### Execute mode

Active only when `--execute` is explicitly passed. Manual mode is the default and remains read-only.

**Step 1 -- Plan first**

Run the full read-only preflight and commit plan (same as manual mode). Show all groups, stop conditions, and exclusions before any mutation. Do not begin execution until the plan is shown.

If any stop condition is present, output the relevant Trellis stop forms. Groups with stop conditions cannot be executed. Groups without stop conditions may proceed if explicitly approved.

**Step 2 -- Pre-execution state check**

Before executing any group, re-verify the working tree matches the planned state:

```bash
git status --short
```

If the output differs from the classified state in the plan, stop:

```
Trellis stop
- Stop reason: Working tree changed since the plan was generated.
- Evidence: <diff between plan state and current git status output>
- Risk if ignored: Staging from a stale plan may capture or miss changes not in the approved group.
- Safe recovery options: Re-run /codebase-trellis commit --execute to generate a fresh plan.
- Recommended option: Re-run.
```

**Step 3 -- Per-group approval**

Before executing each group, display the group contents and require exact typed approval:

```
Ready to execute Group <N> -- <label>:
  Files:
    <file1>
    <file2>
  Message: "<commit message>"

Approve executing Group <N> only?
Reply exactly: execute group <N>
```

Approval rules:

- `yes`, `ok`, `go`, `sure`, or any vague approval is not sufficient.
- The reply must contain the exact phrase `execute group <N>` where N matches the group number shown.
- Approval for one group does not carry to any later group. Ask again before each.
- If the user requests all groups at once (`execute all groups` or similar), stop and request one group at a time.
- Ambiguous or mismatched approval means stop.

**Step 4 -- Execute each approved group**

For each approved group, in order:

1. Before staging, check whether any files outside the approved group are already in the index:

```bash
git diff --cached --name-status
```

If any staged files appear that are not in the approved group's exact file list, stop:

```
Trellis stop
- Stop reason: Pre-existing staged files outside the approved group.
- Evidence: <list of unexpected staged files from git diff --cached --name-status>
- Risk if ignored: Committing would include staged changes not in the approved group.
- Safe recovery options:
    a) git restore --staged <unexpected-file> -- unstage the extra file(s), then re-approve this group.
    b) Re-plan to include the pre-staged files in a group.
- Recommended option: (a) then re-approve this group.
```

2. Stage the exact listed files only:

```bash
git add <file1> <file2> ...
```

Never use `git add .`. Never stage any file not in the approved group's exact file list.
Never stage sensitive-looking, generated-policy-unknown, undecided-untracked, partially staged, or excluded files regardless of approval.

3. If `git add` fails for any file, emit a Trellis stop and do not proceed to commit.

4. Commit with the approved message:

```bash
git commit -m "$(cat <<'EOF'
<message>

EOF
)"
```

5. If `git commit` fails, emit a Trellis stop and do not proceed to the next group.

6. After a successful commit, verify and report:

```bash
git log --oneline -1
git log -1 --format='%H'
git log -1 --format='%B'
git status --short
```

7. Report the result in this format:

```
Group <N> committed.
SHA: <full commit SHA>
Message: <commit subject>
Remaining dirty files: <list from git status --short, or "none">
```

8. Do not proceed to the next group automatically. Show the remaining group plan and ask for fresh approval before each subsequent group.

**Execute mode stop conditions**

Emit a Trellis stop and halt for the affected group when:

- Approval is absent, vague, or does not match `execute group <N>`.
- The group contains sensitive-looking files.
- The group contains generated-policy-unknown files.
- The group contains undecided untracked files.
- The group contains a partially staged file.
- Working tree state changed since the plan was generated.
- Files outside the approved group are already staged in the index.
- `git add` fails.
- `git commit` fails.
- Post-commit SHA verification fails or is not returned.

**Never in execute mode**

- `git add .`
- staging any file not in the approved group's exact file list
- executing a group that has a stop condition
- proceeding to the next group without fresh explicit approval
- pushing to any remote
- merging, rebasing, deleting branches, or removing worktrees

Never run `git add` or `git commit` in manual mode regardless of flags or requests.

Never push from commit mode.

---

## `push` mode

Default: manual plan only. Read-only unless `--execute` is explicitly passed.

### Push preflight

Run all of the following before proposing anything:

```bash
git rev-parse --show-toplevel 2>/dev/null || echo "ERROR: not a git repo"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
git status --short
git remote -v
git rev-parse HEAD 2>/dev/null
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no-upstream"
git rev-list --count @{u}..HEAD 2>/dev/null || echo "no-upstream"
git rev-list --count HEAD..@{u} 2>/dev/null || echo "no-upstream"
```

Interpretation:

- If not in a Git repo, emit a Trellis stop and halt.
- If HEAD is detached (`BRANCH` is empty or `HEAD`), emit a Trellis stop.
- If `git status --short` returns any output, emit a Trellis stop: dirty working tree.
- If `git remote -v` is empty, emit a Trellis stop: no remote configured.
- If upstream is `no-upstream`, propose `git push -u origin <branch>` and require explicit approval.
- If ahead count is 0 and upstream exists and no new upstream is needed, emit a Trellis stop: nothing to push.
- If behind count is greater than 0 and ahead count is 0, emit a Trellis stop: branch is behind upstream.
- If both ahead and behind counts are non-zero, emit a Trellis stop: branch has diverged from upstream.

### Protected branch detection

Check whether the current branch matches any of these patterns:

```
main
master
develop
release/*
```

Matching is exact for `main`, `master`, `develop`, and prefix-based for `release/*`.

If matched:

1. Report the match prominently in the Tangle check.
2. In execute mode, require the stronger approval phrase: `push protected branch <branch-name>`
3. The normal `push branch <branch-name>` phrase is not sufficient for protected branches.

### Push plan output

After preflight, produce the push plan. Use the correct form based on upstream state.

**New upstream (no upstream configured):**

```
Push plan
  Branch:         <name>
  Remote:         origin
  Upstream:       none -- will be set to origin/<name>
  Commits ahead:  <N> new commits
  HEAD SHA:       <full SHA>
  Command:        git push -u origin <name>
  Protected:      <yes -- matches pattern <pattern> / no>
```

**Existing upstream:**

```
Push plan
  Branch:         <name>
  Remote:         <remote>
  Upstream:       <upstream ref>
  Commits ahead:  <N>
  Commits behind: 0
  HEAD SHA:       <full SHA>
  Command:        git push
  Protected:      <yes -- matches pattern <pattern> / no>
```

### Push approval contract

Normal branch push (existing upstream):

- Show the exact `git push` command.
- Require exact phrase: `push branch <branch-name>`

New upstream push:

- Show the exact `git push -u origin <branch-name>` command.
- Require exact phrase: `push branch <branch-name> with upstream`

Protected branch push:

- Show the exact command.
- Require exact phrase: `push protected branch <branch-name>`

`yes`, `ok`, `go`, or vague approval is not sufficient for any push type.

### Execute mode

Active only when `--execute` is explicitly passed. Manual mode is read-only.

**Step 1 -- Plan first**

Run the full read-only preflight and show the complete push plan before any mutation.

**Step 2 -- Pre-push state check**

Immediately before executing, re-run the preflight:

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git status --short
git rev-parse HEAD
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no-upstream"
git rev-list --count @{u}..HEAD 2>/dev/null || echo "no-upstream"
git rev-list --count HEAD..@{u} 2>/dev/null || echo "no-upstream"
```

If branch name, HEAD SHA, upstream, ahead/behind count, or dirty state differs from the plan, emit a Trellis stop and do not push.

**Step 3 -- Require approval**

Display the push plan and require the exact approval phrase before proceeding. Do not push without it.

**Step 4 -- Execute push**

Run only the exact planned command:

- New upstream: `git push -u origin <branch>`
- Existing upstream: `git push`
- No other arguments.
- Never add `--force`.
- Never add `--force-with-lease` unless the user explicitly requested it, the risk was explained, and the approval phrase includes an acknowledgment of the risk.

If push fails for any reason, emit a Trellis stop and do not retry.

**Step 5 -- Post-push verification**

After a successful push:

```bash
git rev-parse HEAD
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
git rev-list --count @{u}..HEAD 2>/dev/null
git rev-list --count HEAD..@{u} 2>/dev/null
```

Report:

```
Push result
  Pushed SHA:     <full SHA>
  Upstream now:   <upstream ref>
  Ahead:          <N> (expected: 0)
  Behind:         <N> (expected: 0)
  In sync:        <yes / no>
```

**Step 6 -- Optional CI inspection**

If the remote is GitHub and `gh` is available, run read-only after push:

```bash
gh run list --branch "<branch>" --limit 5
```

Interpret results:

- Run found for pushed SHA: summarize status (queued / in_progress / success / failure / cancelled).
- No run found yet: report CI not found yet for this SHA -- not green.
- `gh` unavailable or lacks permission: report that plainly.
- No workflows configured: report no workflows detected, not green.

Never claim required checks passed unless the pushed SHA and required checks are both verified.
Never create a PR. Never merge.

### Push-mode stop conditions

Emit a Trellis stop and halt when:

- Not inside a Git repo.
- HEAD is detached.
- Working tree is dirty.
- No remote is configured.
- Requested remote does not exist.
- Upstream is missing and user has not approved setting upstream with `push branch <name> with upstream`.
- Branch is behind upstream (would need pull or rebase first).
- Branch has diverged from upstream (ahead and behind simultaneously).
- No commits ahead and no new upstream needed.
- Protected branch pattern matched without the stronger `push protected branch <name>` phrase.
- Push command would include `--force`.
- `--force-with-lease` appears without explicit user request and risk acceptance.
- Branch, HEAD SHA, upstream, or ahead/behind count changed between plan and execute.
- Push fails.
- Post-push verification fails or SHA cannot be confirmed.

### Never in push mode

- `git push --force`
- `--force-with-lease` without explicit request
- creating a PR
- merging
- enabling auto-merge
- adding to merge queue
- deleting branches or worktrees
- pushing without showing the plan first
- continuing after push failure
- claiming CI is green without verifying the pushed SHA and required checks

---

## `finish` mode

Default: read-only inspection, then options menu. All destructive operations require exact approval.

### Finish preflight

Run all of the following before presenting options:

```bash
git rev-parse --show-toplevel 2>/dev/null || echo "ERROR: not a git repo"
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
git rev-parse HEAD 2>/dev/null
git status --short
git remote -v
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no-upstream"
git rev-list --count @{u}..HEAD 2>/dev/null || echo "no-upstream"
git branch --list main master
git log --oneline -10
git worktree list
gh pr list --head "$BRANCH" --json number,title,state,url,baseRefName 2>/dev/null || echo "gh-unavailable"
```

Interpretation:

- If not in a Git repo, emit a Trellis stop and halt.
- If HEAD is detached (`BRANCH` is empty or `HEAD`), emit a Trellis stop if merge or discard is requested.
- If `git status --short` returns any output, emit a Trellis stop: dirty working tree.
- If `GIT_DIR != GIT_COMMON`, current checkout is a linked worktree -- note this in Root check.
- Detect base branch: prefer `baseRefName` from open PR if `gh` available, else `main` if it exists, else `master`, else ask user.
- If current branch equals detected base branch, refuse merge/discard with a Trellis stop.

### Checks freshness gate

Before presenting merge or discard options, assess check freshness:

- If project has no configured checks (no `.github/workflows/`, no test script in `package.json`, no `Makefile` test target): report: "Checks: not configured. Acceptable for scratch smoke tests or with explicit user acceptance only. Not treated as passing."
- If project has checks, require evidence that checks ran against the current HEAD SHA.
- If checks are stale (ran against a different SHA), failed, or absent, emit a Trellis stop for merge/discard paths.
- If `gh` is available and an open PR exists, inspect: `gh pr checks <pr-number> 2>/dev/null`
- Do not claim required checks passed unless the SHA and required checks are both verified.

### Finish options menu

Present after preflight and checks assessment:

```
Branch finish options
  Branch:   <name>
  Base:     <base-branch>
  Checks:   <passed SHA / stale / not configured / not verified>
  Worktree: <linked worktree / bare checkout>

  1. Prepare PR only         (plan-only)
  2. Prepare push + PR plan  (plan-only, refers to /codebase-trellis push)
  3. Keep branch as-is       (no mutation)
  4. Merge locally           (requires exact approval; checks must pass or scratch-no-checks accepted)
  5. Discard work            (requires exact typed confirmation: discard <branch-name>)
```

Blocked options appear in the menu with a reason:

```
  4. Merge locally           [BLOCKED: checks stale or failed]
  5. Discard work            [BLOCKED: open PR exists -- cannot delete branch while PR is open]
```

### Option 1 -- Prepare PR only

Plan-only in this pass. If GitHub remote is detected and `gh` is available:

```
PR preparation plan
  Command: gh pr create --title "<title>" --body "<body template>" --base <base-branch>
  Status:  plan only -- not executed
```

If no GitHub remote or `gh` is unavailable: report "PR creation not available -- no GitHub remote detected or gh unavailable."

Never clean up or remove a worktree after this option. Iteration may continue.

### Option 2 -- Prepare push + PR plan

Plan-only in this pass. Do not execute push or PR creation from finish mode.

Report the safe sequence:

```
Push + PR plan (not executed)
  Step 1: /codebase-trellis push    -- run push mode for actual push execution
  Step 2: /codebase-trellis finish  -- re-run after push succeeds to prepare PR
  Or, after push: gh pr create --base <base-branch> --title "<title>"
```

Refer the user to `/codebase-trellis push` for push execution. Do not push from finish mode.

### Option 3 -- Keep branch as-is

No mutation.

```
Keep result
  Branch:        <name>
  Worktree path: <path or "N/A -- bare branch checkout">
  Next actions:
    /codebase-trellis commit  -- add more commits
    /codebase-trellis push    -- push branch
    /codebase-trellis finish  -- return here when ready to integrate
```

### Option 4 -- Merge locally after checks

Executable only when all of the following are true:

- Clean working tree.
- Known base branch.
- Fresh passing checks, or explicit scratch-only no-checks acceptance.
- Current branch differs from base branch.
- Approval phrase received: `merge branch <branch-name> into <base-branch>`

Execute sequence:

```bash
git checkout <base-branch>
git status --short
git merge --no-ff <branch-name>
git log --oneline -3
git status --short
```

After merge:

- Report merge commit SHA and new HEAD of base branch.
- Do not push.
- Do not delete the feature branch automatically.
- Do not remove worktree.

If merge would require conflict resolution, emit a Trellis stop. Do not attempt auto-resolution.

### Option 5 -- Discard work

Dangerous. Requires exact typed confirmation: `discard <branch-name>`.

Before executing:

- Show commits that would be lost: `git log <base-branch>..<branch-name> --oneline`
- Confirm no open PR exists on this branch.
- Confirm branch has been pushed or user accepts losing unmerged commits.

Execution depends on checkout type.

*Linked worktree checkout -- worktree-first order required:*

```bash
git worktree remove <worktree-path>
git branch -d <branch-name>
```

If unmerged commits and discard is confirmed: `git branch -D <branch-name>` only after worktree removal succeeds.

*Normal branch checkout:*

```bash
git checkout <base-branch>
git branch -d <branch-name>
```

If unmerged: `git branch -D <branch-name>` only after switching to base and showing the evidence.

After discard:

```bash
git branch --list <branch-name>
git worktree list
```

Report worktree removal and branch deletion results. Both commands should show the branch and worktree path as absent.

### Finish-mode stop conditions

Emit a Trellis stop and halt when:

- Not inside a Git repo.
- HEAD is detached and merge or discard is requested.
- Dirty working tree exists.
- Base branch cannot be determined and merge or discard is requested.
- Current branch is the base branch and merge or discard was requested.
- Branch has no unique commits and merge/discard intent is unclear.
- Checks are stale, failed, or absent for merge path (without explicit scratch-no-checks acceptance).
- Open PR exists and cleanup or branch deletion was requested.
- Worktree path cannot be confirmed as disposable before removal.
- Branch is checked out in another worktree and deletion was requested from the wrong context.
- Discard confirmation does not exactly match `discard <branch-name>`.
- Local merge would require conflict resolution.
- Merge fails.
- Post-merge verification fails.
- Any command would push, auto-merge, enable auto-merge, or add to merge queue.

### Never in finish mode

- executing PR creation (plan-only in this pass)
- executing push (refer to `/codebase-trellis push`)
- auto-merge or enabling auto-merge
- adding to merge queue
- removing a worktree after PR preparation
- deleting a branch without exact typed confirmation
- merging with stale/failed/absent checks except explicit scratch acceptance
- continuing after a failed merge
- pushing after merge
- `git push --force`

---

## `recover` mode

Read-only first:

```bash
git status --short
git status
git reflog -10
git log --oneline -10
```

Detect in-progress operations:

```bash
git rev-parse -q --verify MERGE_HEAD 2>/dev/null && echo "merge in progress"
git rev-parse -q --verify REBASE_HEAD 2>/dev/null && echo "rebase in progress"
git rev-parse -q --verify CHERRY_PICK_HEAD 2>/dev/null && echo "cherry-pick in progress"
```

If a Git lock exists:

```bash
test -f .git/index.lock && echo "lock exists"
```

Only advise removing a stale lock after confirming no Git process is running.

Recovery defaults:
- Prefer `git merge --abort`, `git rebase --abort`, or `git cherry-pick --abort` for in-progress operations.
- Prefer `git reset --soft HEAD~1` for "undo last commit but keep changes".
- Prefer `git restore --staged <file>` for accidental staging.
- Prefer explicit file restore commands over broad restore.
- Never run destructive reset or clean without typed confirmation.

---

## Prohibited operations

The skill must never:

- Run `git add .` without showing and receiving approval for the exact file list.
- Commit without showing the planned grouped files and commit message.
- Push as part of commit.
- Merge as part of push.
- Use `git push --force`.
- Infer `--force-with-lease` automatically.
- Delete branches without typed confirmation of the branch name.
- Delete or remove worktrees it did not create or cannot prove are project-local and disposable.
- Continue after a failed commit, push, or merge as if nothing happened.
- Include `.env`, keys, tokens, credentials, or ignored files in a commit plan.
- Claim test results it did not verify.
- Claim GitHub settings were enabled without verifying them.
- Claim CI is green without knowing the relevant SHA and required checks.
- Claim "no secrets" or "no vulnerabilities" from a local grep or visible checks alone.
- Enable auto-merge, add to merge queue, or trigger merge without explicit user approval.
- Silently include pre-existing dirty files in a commit plan.
- Silently include untracked files in a commit plan.
