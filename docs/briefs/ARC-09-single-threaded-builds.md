# ARC-09 — Measured and packaged builds single-threaded (D-176)

## Agent
Title: `[Sonnet 5.5] ARC-09 single-threaded builds` · Model: Sonnet 5.5 (`claude-sonnet-5-5`) · Profile:
`implement`

## Goal
After this lot, every build of `quiver` whose output is measured or packaged runs the Cairo compiler
**single-threaded** (`RAYON_NUM_THREADS=1`), as the game's decision D-176 requires of the three
repositories, and `quiver` knows **whether that changes any gas figure** of `quiver_quest` 0.2.0 or
`quiver_achievement` 0.2.0. If a figure moves, `GAS.md` and `docs/BUDGETS.md` are measured again
single-threaded. The 0.2.0 publications follow this lot when it moves a figure.

## Context
- **The cause** (D-176, the game's
  `docs/decisions/2026-09-29-compiler-determinism.md`, section "D-176"; read it with
  `cd /home/claude/projects/grimworld && git fetch -q origin && git show origin/pm/d-176-rayon-pin:docs/decisions/2026-09-29-compiler-determinism.md`
  until it is merged on the game's `main`, then `origin/main`). Scarb 2.19's compiler chooses
  which function of a call-graph cycle gets the `withdraw_gas` check by the lowest intern id.
  With several rayon threads, the ids, and so the choice, follow thread order. One commit can
  therefore build into several programs with different gas. With `RAYON_NUM_THREADS=1`, one
  program.
- **The rule**: [docs/CAIRO.md](../CAIRO.md) §2, the row "Measured and declared builds are
  single-threaded" (synced by the orchestrator with this brief).
- **What measures or packages in `quiver`**:
  - `.github/workflows/cairo.yml`, job `package`: steps `build`, `test` (snforge), `gas`
    (`scripts/gas.py --check`, which runs snforge).
  - `.github/workflows/release.yml`: step `scarb package`.
  - `docs/WORKSPACE.md`: the release section, which says how `scarb package` and the publication
    are run by hand.
- **The state**: both packages are 0.2.0, not published. `quiver_quest` has its unit tests moved
  into its modules (ARC-07c), and `quiver_achievement` was rewritten (ARC-07b). Both are merged on
  `main` before this lot starts.

## Scope

**In:**

1. **The pin in CI.** `RAYON_NUM_THREADS: "1"` in the environment of every step that compiles in
   the `package` job: at job level, or on `build`, `test` and `gas`. Also on `release.yml`'s
   `scarb package`. A comment above each cites D-176 in one line.
2. **The pin in the manual steps.** In `docs/WORKSPACE.md`, the `scarb package` and `scarb publish`
   commands of the release section run with `RAYON_NUM_THREADS=1`, with one line of reason.
   `scripts/gas.py` sets it for the snforge it runs, when the variable is not already set, so a
   local `--write` or `--check` measures as CI does. Add a test of that in `scripts/test_gas.py`.
3. **Does it change a figure?** For each package, on this machine, record each run's measures
   (`snforge test`, after removing `target/` before each run):
   - **3 clean runs with the default thread count, and 3 with `RAYON_NUM_THREADS=1`.**
   - Compare every test's l2_gas across the six runs, and say:
     - whether the default runs vary among themselves;
     - whether the single-threaded runs give one value;
     - whether that value differs from today's `GAS.md`.
   Keep the comparison script out of the repository, under `target/`. Write the counts and the
   differing tests, if any, in the report.
4. **If any figure differs from `GAS.md`**:
   - Run `scripts/gas.py <pkg> --write` single-threaded.
   - Re-measure the hand-written figures of `GAS.md` and `README.md`, and the tables of
     `docs/BUDGETS.md`, that are affected.
   - Budgets: a measure above its budget is a raise, which needs its `// gas: raised, D-176
     single-threaded build` note. A measure far below is lowered.
   - Add a section "Single-threaded builds (ARC-09)" to each changed `GAS.md`.
   - Add a line under `[0.2.0]` in each `CHANGELOG.md` saying the figures are single-threaded
     measures.
   If nothing differs, say so in each `GAS.md`, with no other change.
5. **The slowdown**: the `package` job's duration before and after on the pull request, and the
   local `snforge test` time in both modes.

**Out**: the code of either package; the published 0.1.0 versions; publication (never by an
agent: D-132). Whether a figure moving calls for a patch of 0.1.0 is the project manager's call.
Report the facts.

**Allowlist**: `.github/workflows/cairo.yml`, `.github/workflows/release.yml`, `scripts/gas.py`,
`scripts/test_gas.py`, `docs/WORKSPACE.md`. Only if a figure moves, also `packages/*/GAS.md`,
`packages/*/README.md`, `packages/*/CHANGELOG.md`, `packages/*/tests/**` and `packages/*/src/**`
(budget attributes only), and `docs/BUDGETS.md`. Anything else is an escalation.

## Acceptance criteria
- [ ] AC-1 `RAYON_NUM_THREADS=1` on every compiling step of the `package` job and on `scarb package`
      in `release.yml`, each with its one-line reason.
- [ ] AC-2 `docs/WORKSPACE.md`'s manual steps are pinned. `scripts/gas.py` pins snforge unless the
      caller set the variable, with a test.
- [ ] AC-3 The comparison is in the report: 3 default and 3 single-threaded clean runs per package,
      with the tests that differ, if any.
- [ ] AC-4 If a figure differs, the tables are re-measured single-threaded, and every budget raise
      is noted. If none differs, each `GAS.md` says so.
- [ ] AC-5 The slowdown is measured in CI and locally.
- [ ] AC-6 The pull request's CI is green.

## Verification
`python3 -m unittest scripts/test_gas.py`, `python3 scripts/gas.py packages/quest --check`,
`python3 scripts/gas.py packages/achievement --check`, `python3 .github/ci/check-links.py`; then
`gh pr checks <n> --watch --interval 30` until green.

## Report
`REPORT.md` (COMMON.md §6): the pins (file and line), the comparison table per package, the figures
that moved (if any) and the budgets changed, the slowdown, deviations, escalations. Branch
`feat/ARC-09-single-threaded-builds`; pull request `[Sonnet 5.5] ARC-09 single-threaded builds`.
Foreground only; your turn ends when `REPORT.md` is written.
