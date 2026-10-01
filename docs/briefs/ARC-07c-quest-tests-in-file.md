# ARC-07c — `quiver_quest`'s unit tests into their modules (D-167)

## Agent
Title: `[Sonnet 5.5] ARC-07c quest tests in-file` · Model: Sonnet 5.5 (`claude-sonnet-5-5`) · Profile:
`implement`

## Goal
After this lot, `quiver_quest` 0.2.0 follows the owner's rule of tests (D-167, docs/CAIRO.md §2,
"Where a test lives"), as `quiver_achievement` 0.2.0 does since ARC-07b: **the unit tests of a
module are in that module's file**, under `#[cfg(test)] mod tests` at its end; `tests/` keeps only
what needs a deployed contract. **A move, not a rewrite**: no code of the library changes, no test
changes what it checks, no budget changes, except where a move forces it, named.

## Context
- **The rule**: [docs/CAIRO.md](../CAIRO.md) §2, the row "Where a test lives" (D-167).
- **The example to follow**: `quiver_achievement` 0.2.0 as ARC-07b wrote it
  ([brief](ARC-07b-achievement-0.2.0.md), [#25](https://github.com/bal7hazar/quiver/pull/25), not yet
  merged: its audits wait for Codex). Read it on its branch, without checking it out:
  `git fetch -q origin && git show origin/feat/ARC-07b-achievement-0.2.0:<path>` (or `git diff
  origin/main...origin/feat/ARC-07b-achievement-0.2.0 -- packages/achievement`): its `src/**`
  `mod tests` blocks (their imports, their builders repeated where `tests/helpers.cairo` cannot be
  reached), its `GAS.md` section "Where the tests went", and, for item 5, its
  `tests/test_component_track_own.cairo` with the two mocks of `tests/mocks.cairo`. Your lot does
  not depend on #25 being merged: the allowlists are disjoint.
- **What exists**: `packages/quest/` (0.2.0, not published), 510 `#[test]` functions with budgets, all in `tests/`.
  The files whose tests deploy nothing, the likely candidates: `test_batch`, `test_bench`,
  `test_constants`, `test_definition`, `test_errors`, `test_held`, `test_model_definition`,
  `test_packing`, `test_progress`, `test_record`, `test_schedule`. The rest deploy a contract and
  stay. Check each test; this list is a reading of the files, not a decision.
- `scripts/gas.py` reads budgets in `src/` and follows `mod tests { .. }` (shown by ARC-07b).

## Scope

**In** (all in `packages/quest/`):

1. **Every unit test moved** into the file of the module it tests: a model's tests in
   `src/models/<x>.cairo`, a type's in `src/types/<x>.cairo`, the bits helpers' in
   `src/helpers/bits.cairo`, the constants' and errors' in theirs. A test that checks several
   modules goes to the one it is named for, or stays in `tests/` with the reason written above it.
2. **The library benchmarks** (`test_bench`) go with the code they measure, as ARC-07b did; the
   entrypoint benchmarks (`test_component_bench`) and everything that deploys a contract stay in
   `tests/`. A test kept in `tests/` for a performance reason says so in a comment above it.
3. **Test-only helpers** a moved test needs (builders, oracles) go into the `mod tests` that uses
   them, or in a `#[cfg(test)]` module of the package when several modules share them; say which.
   `tests/` files left with no test and no user are removed.
4. **Budgets**: every moved test keeps its `#[available_gas(l2_gas: N)]`. A test whose measure
   changes by the move (its path, its setup) is remeasured; a raise needs a `// gas: raised,
   <reason>` note. `GAS.md` regenerated, with a short section "Where the tests went" (file → module,
   count).
5. **One test gap closed, the only new tests of this lot** (ARC-07b's review, finding 1, which
   holds for `quiver_quest` too): `TrackAll` and `TrackNone` are the only impls of `QuestTracking`,
   so nothing tells `DEFINITION` from `REPORTER`. Add, in `tests/`, a mock consumer with its own impl
   (`DEFINITION = true, REPORTER = false`) and its mirror, and assert that under the first `define`
   emits `QuestDefined` once and `set_reporter` emits nothing, and the reverse under the second; as
   ARC-07b's fix loop 1 did for `quiver_achievement`. Each with its budget.
6. **Times**, as ARC-07b reported them: `scarb build` cold, `snforge test` cold and warm, before
   and after.

**Out**: any change of the library's code or behaviour; `quiver_achievement`; publication (never by
an agent: D-132). ARC-07b's report noted that `quiver_quest`'s checks by snapshot
(`ReporterAssert`, `StatusAssert`) may cost a few steps per call: **not in this lot**; the
orchestrator decides it separately.

**Allowlist**: `packages/quest/**`. Anything else is an escalation.

## Acceptance criteria
- [ ] AC-1 Every test of `tests/` that deploys no contract is in its module's file under
      `#[cfg(test)] mod tests`, or stays in `tests/` with its reason written above it.
- [ ] AC-2 No change outside `#[cfg(test)]` code in `src/`, and nothing in what any test checks:
      the same tests, listed by name before and after (snforge's count and names), the same assertions;
      plus the tests of item 5, the only new ones.
- [ ] AC-3 Every test has its budget; `scripts/gas.py packages/quest --check` passes; any raise
      noted; `GAS.md` regenerated with "Where the tests went".
- [ ] AC-4 Build and test times before and after in the report.
- [ ] AC-5 The pull request's CI is green.

## Verification
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build`,
`cd packages/quest && snforge test`, `scripts/gas.py packages/quest --check`,
`scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check`,
`python3 .github/ci/check-links.py`; then `gh pr checks <n> --watch --interval 30` until green.

## Report
`REPORT.md` (COMMON.md §6): the moves (file → module, count), the tests kept in `tests/` and why,
the test count before and after, the budgets that changed, the times, deviations, escalations.
Branch `feat/ARC-07c-quest-tests-in-file`; pull request `[Sonnet 5.5] ARC-07c quest tests in-file`.
Foreground only; your turn ends when `REPORT.md` is written.
