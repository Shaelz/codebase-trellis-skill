# GitHub hardening for Trellis

Trellis provides behavioral guidance, inspection, and approval gates for AI-assisted
Git work. GitHub branch protections and rulesets provide repository-side enforcement.
Use both when changes to protected branches must be controlled regardless of which
developer, agent, or local tool performs the Git operation.

Availability varies by repository visibility, GitHub plan, and organization settings.
Use the controls available to your repository and verify the resulting rules directly.

## Practical checklist

- Protect `main` with a branch protection rule or ruleset.
- Require pull requests before changes can merge into `main`.
- Require the existing `verify` workflow status check before merge.
- Block force pushes to protected branches.
- Block protected branch deletion where appropriate.
- Enable secret scanning and push protection where available.
- Keep GitHub Actions permissions least-privilege and read-only by default. Grant write
  access only to workflows that require it.
- Protect release tags such as `v*` from deletion or retagging where available.

Local Git hooks and Claude Code hooks can add useful checks earlier in the workflow.
They are optional companion layers, not substitutes for GitHub protections, because
local controls can be absent, bypassed, or configured differently on another machine.

After configuring protections, test them with a pull request and confirm that GitHub
blocks merge until the required `verify` check passes.
