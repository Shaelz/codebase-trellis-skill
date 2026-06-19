# Future branches for codebase-trellis

This file preserves the idea space. Not everything here belongs in v1.

Use these categories:

- Core v1: required for the first trustworthy release.
- Near-term: likely next after v1.
- Nice-to-have: useful or cool, but not release-blocking.
- Experimental: promising but uncertain, risky, or dependent on external tooling.
- Rejected / avoid: tempting but likely harmful or out of scope.

## Core v1

Required for a trustworthy first release.

- Canonical `codebase-trellis` naming everywhere.
- Standalone skill core with no hard dependency on sister skills.
- Optional advisory reads from `codebase-orient` and `codebase-visualize` artifacts.
- Root/Tangle/Growth/Gate/Canopy/Next-safe-action Trellis report.
- Dirty-state inspection: staged, unstaged, untracked, ignored, generated, sensitive, and pre-existing changes.
- Clear rule that no staging, commit, push, merge, cleanup, or force-like operation happens without explicit approval.
- Manual-first commit planning.
- Logical commit grouping by cohesion.
- Sensitive-file warning list.
- Partially staged file detection.
- Simple-vs-structured invocation classification.
- GitHub/CI visibility boundary: report what can and cannot be verified.
- Security visibility boundary: Trellis is not a full security scanner.
- ASCII-only tracked repo docs unless the repo explicitly decides otherwise.
- Release-quality README, install instructions, non-goals, and release checklist.

## Near-term

Strong candidates after the core is stable.

- Optional GitHub ruleset/protection configuration guidance or mutation support, with explicit approval gates; read-only posture visibility already shipped in v1.
- Merge queue awareness.
- PR-level required-check reporting.
- Workflow-run failure inspection and summarized failing steps.
- Subagent result acceptance checklist.
- Claim conflict checks for existing branches, worktrees, PRs, and handoff folders.
- Structured-pass checkpointing for long runs.
- Optional generated `docs/ai/trellis/` handoff artifacts.
- Project-local safety profile, such as `.trellis/profile.md` or `docs/ai/trellis/PROFILE.md`.
- Known dirty baseline tracking for long agent sessions.
- PR handoff template with summary, tests, risks, rollback, and unresolved questions.
- CI artifact/log fetch guidance when GitHub tooling is available.

## Nice-to-have

Useful, cool, or quality-of-life features that should not block release.

- Repo hygiene scorecard.
- Stale branch pruning dashboard.
- Release-readiness scorecard.
- PR review-thread summary and unresolved-comment checklist.
- Dependency-change risk lens.
- Generated file policy detector.
- Deeper commit-style analytics and repository-specific commit-template discovery beyond the conservative recent-history inference shipped in v1.
- Signing identity diagnostics.
- Conventional commit suggestion mode.
- Optional risk labels for PRs, such as `risk:low`, `risk:medium`, `risk:high`.
- Optional PR label suggestions based on touched areas.
- Optional CODEOWNERS-aware reviewer suggestion.
- Optional package/workspace-aware affected-check recommendation.
- Optional diff-size thresholds and split recommendations.
- Optional "branch garden" report for old local branches, stale remotes, and abandoned worktrees.

## Experimental

Interesting, but uncertain or risky.

- Claude Code hook pack for Trellis hardening.
- Local Git hook installer.
- Pre-push hook that blocks unsafe pushes unless confirmed outside Claude permission caching.
- Commit-msg hook that blocks AI attribution trailers unless explicitly allowed.
- Secret-shaped diff scanner with configurable patterns.
- Machine-readable Trellis report JSON.
- Cross-agent session markers to avoid collisions between Claude, Codex, and other agents.
- Agent acceptance protocol for one-commit executor workflows.
- Merge-queue readiness simulator.
- Ruleset/protection drift detector.
- Automatic PR body updater after CI changes.
- Branch naming policy detector and suggester.
- Worktree provenance registry.
- Trellis learning cache for repo-specific safety conventions.

## Rejected / avoid

Tempting, but likely harmful or out of scope.

- Default `git add .`.
- Default automatic commits.
- Default automatic pushes.
- Default automatic merges or auto-merge enablement.
- `git push --force`.
- Hook installation as a default v1 behavior.
- Treating local grep as proof of no secrets.
- Treating visible CI as proof of full correctness.
- Treating PR-head checks as final when merge queue is required.
- Silently including pre-existing dirty files.
- Silently including untracked files.
- Silently overwriting existing hooks, branches, worktrees, or run folders.
- Generated handoff/cache files becoming canonical truth.
- Making `codebase-orient` or `codebase-visualize` a hard dependency.
- Turning the skill into a generic Git tutorial.
- Turning the skill into a deploy/release automation tool before change-integration safety is mature.

## Parking rule

When a new idea appears, do not silently drop it because it is not part of v1. Add it to the correct section with enough context that future work can recover the idea.
