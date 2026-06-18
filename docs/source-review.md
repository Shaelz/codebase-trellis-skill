# Source review

Date: 2026-06-18

This file records which public sources influenced the design of `codebase-trellis`, what was borrowed, what was adapted, and what was avoided. No public skill was copied wholesale.

## Legend

- Adopt: use the idea almost directly.
- Adapt: use the pattern but rewrite for this project's safety model.
- Avoid: do not copy the behavior.
- Verify: use official docs or live repo state before claiming.

## Public skill sources

| Source | Useful area | Decision | Notes |
|---|---|---|---|
| `obra/superpowers/using-git-worktrees` | Worktree isolation | Adopt/adapt | Strong detection and "do not fight the harness" posture. Added stricter approval before `.gitignore` edits. |
| `obra/superpowers/finishing-a-development-branch` | Branch finishing | Adopt/adapt | Good test-first and cleanup-provenance logic. Expanded options for PR prep. |
| `sd0xdev/sd0x-dev-flow/skills/smart-commit` | Commit planning | Adopt/adapt | Best source for manual default, approval gates, sensitive excludes, grouping, identity diagnostics. Removed project-specific state assumptions. |
| `sd0xdev/sd0x-dev-flow/skills/push-ci` | Push authorization | Adopt/adapt | Strong push gate. Kept "push is privileged" idea. Made default manual. |
| `vasilyu1983/AI-Agents-public/dev-git-workflow` | Broad Git workflow | Adapt | Good reference/checklist source. Too broad for runtime. Some thresholds used as warnings, not hard universal rules. |
| `majiayu000/claude-skill-registry/repository-organization` | Repo organization | Adapt | Good checklist seed. Not operational enough for direct use. |
| `majiayu000/claude-skill-registry/git-workflow-management` | Git automation | Avoid as behavior | Too eager around quick stage/commit/push. Useful as anti-pattern reference. |
| `mhattingpete/claude-skills-marketplace/git-pushing` | Push wrapper | Avoid | Too narrow; bundles staging/commit/push behind a script without sufficient gates. |

## Official documentation sources

| Source | Use |
|---|---|
| GitHub Docs, Best practices for repositories | Official baseline for README, security features, branch workflow, protected branches, Git LFS. |
| GitHub Docs, About rulesets | Official baseline for rulesets, branch/tag controls, push rulesets, plan caveats. |
| GitHub Docs, About merge queues | Merge queue vs PR-head check distinction. |
| Claude Code Docs, Extend Claude with skills | Official baseline for skill layout, frontmatter fields, supporting files, invocation control. |

## Borrowed design ideas

### From worktree sources

- Detect existing worktree before creating another.
- Distinguish submodule from worktree via `GIT_DIR` vs `GIT_COMMON`.
- Verify `.worktrees/` is gitignored before creating project-local worktrees.
- Run baseline checks after setup.
- Cleanup only with provenance: only remove worktrees created by this session or clearly project-local.

### From commit sources

- Manual by default; execute requires explicit flag.
- Show plan before action.
- Exact file lists only; no broad path commands.
- Sensitive-file exclusion with explicit warning list.
- Partial-staging detection as a stop condition.
- Identity and signing diagnostics before execute.
- Cohesive grouping: feature/module, source plus tests, docs, config, dependencies.
- No AI attribution by default.
- Post-commit verification of SHA and message.

### From push sources

- Push is a privileged operation, separate from commit.
- Protected branches require separate warning and typed branch-name confirmation.
- `git push --force` is always forbidden.
- `--force-with-lease` only on explicit request.
- Show branch/remote/HEAD/ahead count before push.
- Monitor CI after push; do not merge automatically.
- Stop on failed push; do not infer force push from failure.

### From repo hygiene sources

- README and project metadata.
- Branch/ruleset protection visibility.
- Required status checks and required reviews.
- CODEOWNERS for sensitive paths.
- Dependabot alerts, secret scanning, push protection, code scanning.
- SECURITY.md.
- Git LFS for large files.

## What was not copied

- No public skill was vendored wholesale.
- No install script fetches or executes remote code.
- No hidden shell commands embedded in Markdown.
- No over-eager `git add .` or bundled stage/commit/push shortcuts.
- No invented test results or hallucinated GitHub posture.

## Open design questions resolved

1. One skill with mode arguments for v1 (not a router plus sub-skills).
2. Execute mode included in v1 for commit only; push execute deferred to v1.1 or gated heavily.
3. No automatic hook installation in v1.
4. GitHub posture audit only; no settings mutation.
5. AI co-author trailer off by default; `--ai-co-author` flag possible later if demand exists.
