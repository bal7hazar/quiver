# [Sonnet 5.5] ARC-18 — CI jobs run only when files that concern them changed

## Summary
`affected.py changes` writes `cairo`, `tooling` and `links` (true/false) from the files a pull request
changed, deleted and renamed ones included; every other event gets all `true` with no `git diff`.
`cairo.yml` and `tooling.yml` each gain a `changes` job (base branch's copy of the script, fail
closed: all `true` when the base has no script or no `changes` subcommand, or it fails), `if:`/`needs:`
lines on `affected`, `package`, `scripts` and `links`, and an always-running summary (`cairo`, kept,
and a new `tooling`) that is expected-versus-result. `docs/WORKSPACE.md` §4 says what a pull request
runs now. `release.yml` is unchanged.

## Files changed
- `.github/ci/affected.py`: `changes` subcommand, `deleted_files`, the path rules.
- `.github/ci/test_affected.py`: cases for every path rule, deletions and renames, the
  non-pull-request mode, the fail-closed paths of the command.
- `.github/workflows/cairo.yml`, `.github/workflows/tooling.yml`: edited with the file-editing tool.
- `docs/WORKSPACE.md`: §4.
- `docs/reports/ARC-18-report.md`: this report.

## Commands run
- `python3 -m unittest discover -s .github/ci`: 50 tests OK.
- `python3 -m unittest scripts/test_gas.py`: 47 tests OK.
- The shell snippets of the workflows (the `changes` step and the two summaries) were NOT run
  locally: a local check by a script was refused by the permission system, and the project manager
  decided to skip it. They are proved by this pull request's CI and the acceptance draft PRs.

## Cost
—

## Acceptance criteria
- AC-7: unit tests above (every path rule, deletions, fail-closed command paths).
- AC-1 to AC-6: shown on GitHub by the acceptance draft PRs `ARC-18 acceptance: <case>`, listed in
  the thread report with their `gh pr checks` (they cannot be known before this commit). AC-5 is after
  the merge.

## Deviations from the brief
None. The `cairo` summary step is rewritten (old step removed) to include `changes` and the
not-needed case, as design point 4 asks.

## Escalations
None for the lot. The local check of the snippets was refused (see Commands run).

## Open questions
- A failing `changes` step falls back to all `true` (fail closed); a `git` or Python error there
  therefore runs every job instead of failing the workflow. Intended, noted for the reviewer.
