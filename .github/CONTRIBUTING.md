# Contributing

Thanks for helping improve `codebase-trellis-skill`.

Useful contributions include:
- install and onboarding documentation fixes
- Claude Code compatibility findings
- reproducible workflow bugs
- tightly scoped improvements to the skill workflow or safety model

## Security

Do not report security vulnerabilities in public Issues.

Please follow [SECURITY.md](/Shaelz/codebase-trellis-skill/blob/main/SECURITY.md) and use GitHub private vulnerability reporting when possible.

## Useful bug reports

Please include:
- tool used: Claude Code
- operating system and shell
- installation route used
- repo tag or version tested
- exact reproduction steps
- expected result
- actual result
- sanitized logs or output

## Commit messages

Use lowercase conventional commit prefixes:

- `feat:` - new skill behavior, rules, or guidance
- `fix:` - correcting wrong or broken behavior
- `docs:` - README, CHANGELOG, community files, documentation only
- `refactor:` - restructuring without behavior change
- `chore:` - scripts, tooling, CI, non-behavioral maintenance

## Pull requests

Please keep pull requests small and focused.

- Preserve documented safety behavior unless you are intentionally changing it.
- Update docs when the public contract changes.
- Run the relevant verification for the surface you changed.

## Verification expectations

- Run `git diff --check`.
- Run the ASCII punctuation checks when tracked Markdown or script text changes.
- Run installer smoke tests when installer behavior changes.
