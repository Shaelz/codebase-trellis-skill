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

Run read-only diagnostics. Produce a Trellis report.

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --short
git diff --stat
git diff --cached --stat
git log --oneline -10
git remote -v
git config --show-origin --show-scope --get user.name 2>/dev/null || echo "unset"
git config --show-origin --show-scope --get user.email 2>/dev/null || echo "unset"
```

If `gh` is available, run read-only GitHub diagnostics:

```bash
gh repo view --json nameWithOwner,visibility,defaultBranchRef
gh pr status
gh run list --limit 5
```

If supported and authorized, also inspect repository protection posture:

```bash
gh api repos/:owner/:repo/branches
gh api repos/:owner/:repo/rulesets
gh api repos/:owner/:repo/dependabot/alerts
gh api repos/:owner/:repo/secret-scanning/alerts
gh api repos/:owner/:repo/code-scanning/alerts
```

If a `gh api` call fails, report the limitation. Do not infer safety from failure. Categorize by error shape:

- `"Upgrade to GitHub Pro or make this repository public"` (403): plan limitation -- feature unavailable on free private repos.
- `"needs the ... scope"` in message (403): permission gap -- suggest `gh auth refresh -h github.com -s <scope>`.
- `"disabled for this repository"` (403/404): feature is off -- enable in repo settings if desired.
- `"not enabled for this repository"` (403): feature not configured -- enable in repo settings if desired.
- Any other failure: report raw error and continue.

Always report as: `Protection state: not verified. Do not assume main is protected.`

Output: full or short Trellis report as appropriate.

---

## `start` mode

Prepare isolated work. Before creating anything:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
git branch --show-current
git rev-parse --show-superproject-working-tree 2>/dev/null
git status --short
```

Interpretation:
- If not in a Git repo, stop.
- If inside a submodule, treat as normal repo unless user intended submodule work.
- If `GIT_DIR != GIT_COMMON` and not a submodule, report already in a linked worktree and do not create another.
- If dirty state exists, ask whether to commit, stash, or continue in place. Do not switch branches over dirty state.

Claim conflict check -- before creating a branch or worktree, check for existing ownership:
- existing local branch with the same name
- existing remote branch with the same name
- existing worktree path
- open PR for the same branch
- pending CI for the same head SHA

If another owner appears active, stop and ask before continuing.

Worktree directory priority:
1. explicit user path
2. existing `.worktrees/`
3. existing `worktrees/`
4. default `.worktrees/`

Before creating a project-local worktree:

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

If not ignored, propose adding the chosen worktree directory to `.gitignore`. Do not edit `.gitignore` without approval.

Create only after approval:

```bash
git worktree add <path> -b <branch-name>
```

After creation, run project setup and baseline checks based on repo conventions. If checks fail, report and stop unless the user explicitly chooses to continue.

---

## `commit` mode

Default: manual mode. Do not execute `git add`, `git commit`, or any other Git state-changing command. Output a commit plan and copyable commands for user review only.

If `--execute` is passed, see the execute sub-mode at the end of this section. Execute mode is not yet available.

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

Not yet available. If `--execute` is passed, output the manual plan and add:

`Execute mode is not yet available. The manual plan above contains exact commands you can run.`

Never run `git add` or `git commit` in manual mode regardless of flags or requests.

Never push from commit mode.

---

## `push` mode

Default: manual plan only. Do not execute push unless `--execute` is present.

Preflight:

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git status --short
git remote -v
git rev-parse HEAD
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no-upstream"
git rev-list --count @{u}..HEAD 2>/dev/null || echo "new-or-no-upstream"
```

Protected branch patterns -- these require a separate warning:
```
main
master
develop
release/*
```

If the current branch matches a protected pattern, require a typed branch-name confirmation before any execute path.

Push rules:
- `git push --force` is forbidden.
- `--force-with-lease` is allowed only when explicitly requested and approved.
- If there is no upstream, propose `git push -u origin <branch>`.
- If push fails, stop. Do not try `--force-with-lease` automatically.

Push plan:

```
Push plan:
- branch:
- remote:
- upstream:
- commits ahead:
- HEAD SHA:
- command:
```

After successful push, if `gh` is available:

```bash
gh run list --branch "$BRANCH" --limit 5
```

If a matching CI run exists, report the status. Do not merge automatically.

---

## `finish` mode

Before presenting options, verify checks are fresh enough for the change type. If tests or checks fail, stop and report.

Detect environment:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
git branch --show-current
git status --short
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Present options:

```
Branch finish options:
1. Prepare PR only
2. Push and create PR
3. Keep branch as-is
4. Merge locally after checks
5. Discard work (requires typed confirmation)
```

Rules:
- If detached HEAD, do not offer local merge.
- If dirty state exists, do not merge.
- For PR path, do not remove worktree (iteration may continue).
- For local merge, run checks before and after merge.
- For cleanup, remove worktree before deleting branch.
- For discard, require typed confirmation: `discard <branch-name>`.

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
