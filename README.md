# codebase-trellis

`codebase-trellis` is a reusable skill for **Claude Code** that gives the agent a safe support structure for moving code changes through Git and GitHub.

Instead of improvising Git operations, this skill tells the agent what to inspect first, which operations require explicit approval, what to exclude, and when to stop. It is for developers who want AI-assisted work to stay coherent, auditable, and safe to integrate.

> [!NOTE]
> Installing a skill copies skill files into your tool's skill directory only. Running `/codebase-trellis` does not modify your Git state or GitHub settings without showing you a plan and receiving explicit approval first. In audit mode (the default), it is read-only.

## What it does

`codebase-trellis` gives Claude a decision-gated workflow for:

- inspecting dirty working tree state before any staging or commit
- detecting sensitive files, pre-existing dirty files, and partially staged files
- planning cohesive commits grouped by logical concern
- gating staging, commits, pushes, PRs, and branch cleanup behind explicit approval
- reporting GitHub/CI posture without assuming what is protected
- finishing or discarding branches with clean lifecycle rules
- recovering from common Git mistakes without improvising destructive commands

It is not a Git command wrapper. The default behavior is inspection and planning. Execution requires deliberate flags or approval.

## Quickstart

Install the skill at the user level (available in all projects):

**Claude Code - PowerShell**

```powershell
.\scripts\install-user.ps1
```

**Claude Code - bash**

```bash
bash scripts/install-user.sh
```

Then restart Claude Code and type `/codebase-trellis` in any project.

## Install paths

| Goal | Command |
|---|---|
| User-level (Claude Code, PowerShell) | `.\scripts\install-user.ps1` |
| User-level (Claude Code, bash) | `bash scripts/install-user.sh` |
| Project-local (Claude Code, PowerShell) | `.\path\to\install-project.ps1` |
| Project-local (Claude Code, bash) | `bash path/to/install-project.sh` |

If an installation already exists, the scripts exit with an error unless you pass `-Force` (PowerShell) or `--force` (bash).

## Usage

```
/codebase-trellis              # audit mode (default) - read-only inspection
/codebase-trellis audit        # same as above
/codebase-trellis start        # set up isolated branch or worktree
/codebase-trellis commit       # plan commits (manual/read-only by default)
/codebase-trellis commit --execute   # plan and execute commits after approval
/codebase-trellis push         # plan push (manual by default)
/codebase-trellis finish       # finish branch: PR, merge, keep, or discard
/codebase-trellis recover      # recover from Git mistakes
```

## Relationship to sister skills

This skill belongs to a suite of three:

- `/codebase-orient` - understands the codebase structure before broad work
- `/codebase-visualize` - maps the codebase as an interactive graph
- `/codebase-trellis` - supports safe change growth and integration

`codebase-trellis` is standalone. It does not require `codebase-orient` or `codebase-visualize` to be installed. If their artifacts exist in `docs/ai/`, Trellis may read them as optional context.

## Safety model

Trellis operates within four safety layers:

1. **Skill discipline** - what the agent inspects and gates (core v1 layer)
2. **Local Git hooks** - repo-local checks during commit or push (recommended, not required)
3. **Claude Code hooks** - host-level hardening (optional)
4. **GitHub protections** - branch protection, rulesets, secret scanning, merge queue

These layers are not equivalent. A skill rule does not substitute for a protected branch. A local grep does not substitute for GitHub secret scanning.

## What Trellis never does without explicit approval

- `git add .`
- committing without showing the planned file list and message
- pushing as part of commit
- merging as part of push
- `git push --force`
- deleting branches or worktrees
- enabling auto-merge or adding to a merge queue
- including `.env`, keys, tokens, or ignored files in a commit plan
- claiming CI is green without verifying the relevant SHA and required checks

## Non-goals

- Not a Git command cookbook.
- Not a deploy or release automation tool.
- Not a replacement for branch protection rules.
- Not a secret scanner.
- Does not install Git hooks automatically.
- Does not modify GitHub repository settings.
- Does not add AI co-author trailers by default.

## Verification

```bash
bash scripts/verify-skill-package.sh
bash scripts/check-ascii-punctuation.sh
```

## Repository

https://github.com/Shaelz/codebase-trellis-skill

## License

MIT
