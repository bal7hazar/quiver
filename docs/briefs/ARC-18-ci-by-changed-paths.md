# ARC-18 — CI jobs run only when files that concern them changed

## Agent
Title: `ARC-18 CI by changed paths` · Profile: `impl-sonnet` (no model tag in titles).
**Starts after** ARC-17 is merged (it edits `tooling.yml` too) **and** after the project manager
confirms that threads may modify workflows. Branch from `main` once both hold.

## Goal
The owner's rule: "CI tests must absolutely run only if files related to the tests were modified,
so docs should skip all tests". After this lot, on a pull request each test job runs only when a
changed path concerns it, and one light job per workflow always runs and summarises, so
`gh pr checks` always has a result and `gh pr checks <n> && gh pr merge …` works. Pushes to
`main`, the schedule, a manual run and the release tag run what they run today.

## Context
Lines are read on `main` (3d3c42e).
- `cairo.yml`: triggers 9-16 (pull request, push to main, daily schedule, dispatch, `workflow_call`).
  `affected` (32-84) always runs: checkout, `setup-scarb`, the unit tests of `test_affected.py` and
  `scripts/test_gas.py` (54-58), then `affected.py matrix` on the base branch's copy (67-84).
  `package` (86-148, matrix) runs `if any == 'true'`: fmt, build, `snforge test`, `gas.py --check`.
  `cairo` (150-170, `if: always()`) is the summary: it needs `affected` to succeed, and `package` to
  succeed when `any`, to be skipped otherwise. So a docs-only PR already skips `package`, but still
  runs `affected` with its unit tests.
- `tooling.yml`: triggers 6-9 (pull request, push to main). `scripts` (21-176) runs shellcheck of
  `scripts/*.sh` and the launcher, slot and lock fixtures: it reads `scripts/agent.sh`, `lock.sh`,
  `scripts/profiles/*`. `links` (178-185) runs `check-links.py` on every tracked Markdown file. Both
  always run; no summary job.
- `release.yml`: on a tag it calls `cairo.yml` (`workspace`, 18-19), then `package` (21-55). Never
  runs on a PR. Both workflows hold the ARC-15 concurrency group (a PR's superseded run is cancelled).
- ARC-17 (open) adds to `tooling.yml` a shellcheck of `.githooks/pre-push` and
  `.github/ci/install-snforge.sh` and a step running `scripts/test_hook.py`: read `main` after it
  merges and give those steps the `scripts` job's concern below.

## The paths that concern each job (pull requests)
A path concerns a job when the job reads it, or is the job's own code. Superset is safe: a missed
path lets a red change through, an extra path only costs minutes.
- **Cairo** (`affected`, `package`): `packages/**` except the `README.md` and `CHANGELOG.md` of a
  package (no Cairo step reads their text: check it, see AC-6; `GAS.md` stays, `gas.py --check`
  compares it), `Scarb.toml`, `Scarb.lock`, `.tool-versions`, `.github/ci/**` (affected.py,
  install-snforge.sh, their tests), `scripts/gas.py`, `scripts/test_gas.py` (its unit tests run in
  `affected`), `.github/workflows/cairo.yml`, `.github/workflows/release.yml` (today's `ALL_FILES`).
  `affected.py`'s own rules (which packages, dependents) stay as they are.
- **Tooling `scripts`**: `scripts/**`, `.githooks/**`, `.github/ci/**` (install-snforge.sh, the
  Python tests), `.github/workflows/tooling.yml`. Not `cairo.yml` or `release.yml`: the job reads
  neither (decision of this brief; the Cairo jobs already run on them).
- **Tooling `links`**: any `*.md`; `.github/ci/check-links.py`; `tooling.yml`; and **any deleted or
  renamed file** of any kind (a link can break when its target goes with no Markdown change).
- **A docs-only PR** (Markdown, `docs/**`, `LICENSE`, `.gitignore`, package READMEs and changelogs)
  runs: the path job, `links` if a Markdown file changed, and the two summaries. No test job.
  `links` counts as the test of the documents. A PR touching only `scripts/**` runs the tooling
  `scripts` job and, for `scripts/gas.py` or `scripts/test_gas.py`, the Cairo unit tests.

## Design
1. **Paths come from `affected.py`**: a new subcommand `changes` in `.github/ci/affected.py` writes
   the outputs `cairo`, `tooling`, `links` (`true`/`false`) from `changed_files()` (add the deleted
   files with `--diff-filter=D --name-only`). Pure functions, tested in `test_affected.py`. Not a
   third-party path-filter action (supply chain; the repository pins actions by SHA already). On
   any event but `pull_request` all three are `true` with no `git diff`.
2. **A job `changes` in each workflow** (checkout `fetch-depth: 0`, no `setup-scarb`, 5 min),
   running the base branch's copy of `affected.py` as `affected` does (cairo.yml 67-84): fail
   closed, **all outputs `true`** when the base has no such script or lacks the `changes`
   subcommand (so the ARC-18 PR itself, and any PR before it merges, runs everything). Each workflow
   keeps its own `changes` job (jobs cannot be shared across workflows).
3. **`if:` conditions**: `cairo.yml` `affected` and `package` gain `needs.changes.outputs.cairo ==
   'true'` (`package` keeps `any == 'true'`); the `affected` job keeps its unit tests. `tooling.yml`
   `scripts` and `links` get `needs.changes.outputs.tooling` / `links == 'true'`. No workflow-level
   `paths:` filter: a workflow it skips leaves no check at all.
4. **Summary jobs** (`if: always()`, `needs` every job, 5 min): `cairo` (existing name, kept) and a
   new one named `tooling`. Each is expected-versus-result, as `cairo` is today: `changes`
   must be `success`; a job whose output says it was needed must be `success`; a job not needed must
   be `skipped`; anything else (`failure`, `cancelled`, a skipped job that was needed, because an
   upstream failed) fails. Plain "success or skipped" is wrong: a failed `changes` skips all.
5. **ARC-15 concurrency**: the group blocks stay unchanged. A superseded run is cancelled with its
   summary; its head is stale, and the standard's merge command pins the head, so only the new run's
   summary counts.
6. **Pushes to main, schedule, dispatch, `workflow_call`**: every job runs, as today (outputs all
   `true`). Through `workflow_call` from `release.yml` the event is the caller's `push`, so a tag runs
   every package and `cairo` still summarises. `release.yml` is **not changed**.

## Scope
**In:** the above. `docs/WORKSPACE.md` §4 (table and the paragraph on `affected.py`) says what a
pull request runs now and what a docs-only PR runs.
**Out:** `release.yml`; triggers; permissions; action pins; timeouts; any check weakened;
`continue-on-error`; packages; the content of any step except the `if:`/`needs` lines. The
required-check setting of the repository (owner's).

**Allowlist**: `.github/workflows/cairo.yml`, `.github/workflows/tooling.yml` (the only two
workflows this lot changes, per nexus #60: nothing else in them changes), `.github/ci/affected.py`,
`.github/ci/test_affected.py`, `docs/WORKSPACE.md`, the report. Anything else is an escalation.

**Workflow-edit rule**: edit the two workflows with the file-editing tool (Edit) only, never a
script that rewrites them. If an edit is refused, stop and send the exact refusal text; do not
retry by another means.

## Acceptance criteria
Each is shown on GitHub, on throwaway **draft** pull requests **based on the ARC-18 branch** (so
the base has the new script and the diff is one file), listed in the report with `gh pr checks`.
Poll CI at most once per PR every 5 minutes, no loop. Closing them may be refused: leave them as
drafts and list them for the project manager.
- [ ] AC-1 A Markdown-only change: no `scripts`, `affected` or `package` job runs; `links` and both
      summaries pass.
- [ ] AC-2 A change under `scripts/` (not `gas.py`): only `scripts`, the two `changes` jobs and the
      summaries run; `cairo` passes with `affected` skipped.
- [ ] AC-3 A change in one package's `src/`: that package's `package` jobs (and dependents) run, and
      `tooling` runs no job but `changes`.
- [ ] AC-4 A deliberately failing needed job (a shellcheck error in a script, in a throwaway PR) makes
      the `tooling` summary fail; a failing package test makes `cairo` fail.
- [ ] AC-5 After the merge, the run on `main` shows every job of both workflows ran, as before.
- [ ] AC-6 A package `README.md`-only and a `CHANGELOG.md`-only change skip every Cairo job; and
      `scarb build` with those files emptied still passes (shows no step reads their text).
- [ ] AC-7 Unit tests: `python3 -m unittest discover -s .github/ci` passes with new cases for every
      path rule above, deletions included, and the fail-closed paths.

## Verification
`python3 -m unittest discover -s .github/ci`; `python3 -m unittest scripts/test_gas.py`;
`python3 .github/ci/check-links.py`; `scripts/prepush.sh`; `git diff origin/main --stat` shows only
the allowlist; `git diff origin/main -- .github/workflows` shows only `changes`, `if:`/`needs`
lines, the two summaries, nothing removed. Then `gh pr checks <n>` (once per 5 minutes).

## Report
Per acceptance criterion the PR and run that shows it; the diff of the workflows; any point where
the workflows were ambiguous; the first run time of a docs-only PR before and after.

## Audit
None: **review only** (D-177), by a model other than the writer's. No value, access-control logic or
published interface changes; but the reviewer reads every `.github/workflows` hunk, since a wrong
`if:` silently skips a test.

Branch `feat/ARC-18-ci-by-changed-paths`; pull request `ARC-18 CI by changed paths`. Commit the final
report BEFORE the review is asked. Foreground only; your turn ends when the report is written.
