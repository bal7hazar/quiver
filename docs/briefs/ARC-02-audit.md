# ARC-02 audit — workspace, CI by affected package, gas tool, release pipeline

## Agent
Title: `[GPT-6-Luna] Audit ARC-02 quality and security` · Model: `gpt-6-luna`, reasoning high ·
Profile: `audit` (codex, read-only sandbox). You cannot write files: your final message is
your report.

## What you audit
Pull request #4, checked out in your working directory: the deliverable of
`docs/briefs/ARC-02-workspace.md`. Read the brief first: it is the specification. You receive
the deliverable and the specification, not the author's reasoning. The files:
`Scarb.toml`, `Scarb.lock`, `.tool-versions`, `packages/**`, `.github/workflows/cairo.yml`,
`.github/workflows/release.yml`, `.github/ci/*.py`, `.github/ci/install-snforge.sh`,
`scripts/gas.py`, `scripts/test_gas.py`, `docs/WORKSPACE.md`. Context: `docs/CAIRO.md` §2 and
§6, `docs/research/ARC-01-quest-achievement.md` §6.

## Lenses
Quality and security of tooling (the game's OPERATIONS §6: "Tooling / CI"). Check, with
evidence:

1. **Affected packages.** Does `.github/ci/affected.py` implement the brief's rules in every
   case: a file in a package, a shared file, documentation only, dependents transitively, a
   renamed or deleted file, a new package directory, the first commit of a branch? Can a pull
   request make the CI skip a package it changed? Is the `cairo` summary job correct for every
   combination of results (failure, cancellation, skipped)?
2. **Inputs from a pull request.** Everything a pull request controls (`.tool-versions`,
   manifests, branch names, file names, the tag on a release) must be validated before a step
   uses it; no expression injection in `run:` steps; `permissions` minimal; actions pinned by
   commit SHA; the snforge installer verifies what it downloads.
3. **Gas tool.** Does `scripts/gas.py --check` enforce `docs/CAIRO.md` §2 exactly (every test
   has a budget; budget within `[measured, ceil(1.05 × measured)]`; `GAS.md` equal to the
   measures)? Can a test escape the check (a test without `available_gas`, a test that
   snforge skips or ignores, a test name the parser misreads, output of a failing run)? Is the
   parser tested against real snforge 0.61 output?
4. **Release.** Does `release.yml` refuse a tag whose version or changelog does not match, and
   is it impossible for it to publish or to reach a secret? Does a tag run the workspace
   checks once or twice, and does it matter?
5. **Workspace.** Manifests as in ARC-01 §6.1; `snforge_std` a dev-dependency only; versions
   exact; the constants equal to the accepted API's bounds (ARC-01 §3.1, §3.2, §3.10).
6. **Repository hygiene.** Anything committed that should not be (build outputs, caches,
   generated files); `.gitignore`; `docs/WORKSPACE.md` accurate against the workflows.

## Report
Your final message, in this form (the game's OPERATIONS §6):

```markdown
# [GPT-6-Luna] Audit — ARC-02 — quality and security

## Verdict
PASS | PASS WITH FINDINGS | FAIL

## Findings
| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |

## Coverage
What was reviewed, what was not, and why.
```

Severities: `blocker`, `major` (wrong in a reachable case; a check that can be escaped),
`minor`, `note`. Every finding needs evidence: a file and line, a scenario, or a quoted rule.
