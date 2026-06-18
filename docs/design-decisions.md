# Design decisions

Date: 2026-06-18

Short ADR-style entries for key design choices in `codebase-trellis`.

---

## 1. One skill with mode arguments for v1

Decision: implement a single skill `codebase-trellis` with mode-based arguments (`audit`, `start`, `commit`, `push`, `finish`, `recover`) rather than separate sub-skills.

Rationale: keeps installation simple, avoids premature splitting, and lets the skill evolve as a unit before the mode boundaries are well understood from real use. Split later if one mode becomes large or frequently used independently.

---

## 2. Manual-first, read-only by default

Decision: every mode defaults to inspection and planning output. State-changing operations require an explicit `--execute` flag or user approval gate.

Rationale: the primary failure mode in AI-assisted Git work is accidental or premature mutation. Making inspection the default makes the skill safe by default, even when invoked without careful thought.

---

## 3. Execute modes deferred or gated

Decision: `commit --execute` is supported in v1. Push `--execute`, merge, branch deletion, worktree cleanup, and PR creation all require explicit approval at each step and are never automatic consequences of other operations.

Rationale: the chain commit -> push -> merge is where most irreversible damage happens. Keeping each step a separate explicit decision prevents cascade failures.

---

## 4. No remote code execution or auto-update

Decision: no install script fetches or executes remote code. No auto-update mechanism in v1.

Rationale: skill files are executable-like instructions. An update that fetches remote content could silently change the skill's behavior in ways that bypass the safety model. Installation requires an exact local copy from a tagged release.

---

## 5. GitHub posture audit only; no settings mutation

Decision: Trellis audits GitHub repo posture (branch protection, rulesets, security features) and reports findings and exact fix commands. It does not modify GitHub settings.

Rationale: GitHub settings changes are high blast-radius and poorly reversible. The skill's role is to make the posture visible, not to change it without human review.

---

## 6. No hard dependency on sister skills

Decision: Trellis must work in any Git repo without `codebase-orient` or `codebase-visualize` artifacts.

Rationale: making Trellis depend on orient/visualize output would couple the skill to a prior workflow step and prevent standalone use. Orientation and visualization are useful context, not required infrastructure.

---

## 7. Trellis report as signature output

Decision: every inspection or planning pass should converge on the structured Root/Tangle/Growth/Gate/Canopy/Next Trellis report format.

Rationale: a consistent output format makes the skill's findings predictable across sessions, easy to resume from, and unambiguous about what was checked vs assumed. The stop form gives a parallel structure for refusals.

---

## 8. Enforcement layers are distinct

Decision: the skill explicitly names four safety layers (skill discipline, local Git hooks, Claude Code hooks, GitHub protections) and states their non-equivalence.

Rationale: agents commonly conflate these. A passing local grep is not equivalent to GitHub secret scanning. A skill rule is not equivalent to a protected branch. Making the distinction explicit prevents false safety claims.

---

## 9. Simple vs structured classification

Decision: classify each invocation before running any workflow. Default to simple; promote to structured if inspection proves the work is larger.

Rationale: over-engineering small tasks wastes time and produces noise. Under-structuring large tasks creates safety risk. The classification triggers the right depth of inspection and reporting without requiring the user to specify it explicitly.

---

## 10. Security visibility boundary

Decision: Trellis reports visible security signals but never claims "no secrets" or "no vulnerabilities" from local grep or visible checks alone.

Rationale: false negatives here are worse than silence. Trellis is not a dedicated security scanner. Overstating confidence would be actively harmful.

---

## 11. ASCII-only tracked text

Decision: all tracked Markdown, scripts, and configuration files must be ASCII-only (no smart punctuation, no Unicode math symbols, no curly quotes, no non-breaking spaces).

Rationale: non-ASCII characters in SKILL.md or prompt-facing text can cause invisible rendering differences across tools. Enforcement via `check-ascii-punctuation` scripts catches regressions early.

---

## Source influences

The design draws on three categories of source material:

Public skill patterns (used as research inputs, not vendored source):
- `obra/superpowers`: worktree detection, finish-branch workflow, cleanup provenance.
- `sd0xdev/sd0x-dev-flow`: manual-default commit posture, push authorization, sensitive-file exclusion.
- `vasilyu1983/AI-Agents-public`: broad Git workflow checklist, repo baseline security/reliability.

Official documentation:
- GitHub Docs: branch/ruleset protection, secret scanning, Dependabot, merge queue, Git LFS.
- Claude Code Docs: skill package structure, frontmatter fields, supporting files.

Anti-patterns (what to avoid, derived from reviewing over-eager public skills):
- bundled stage/commit/push happy paths
- `git add .` as default
- invented test results
- merging without fresh checks

See `docs/source-review.md` for the full source matrix.
