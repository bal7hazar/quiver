# ARC-07b — `quiver_achievement` 0.2.0 on the pattern of CAIRO.md §7

## Agent
Title: `[Opus 5.5] ARC-07b achievement 0.2.0` · Model: Opus 5.5 (`claude-opus-5-5`) · Profile: `implement`

ARC-07 rewrites both packages on the pattern settled by ARC-06 and reviewed by the owner (D-147).
**ARC-07a** rewrote `quiver_quest` as 0.2.0 ([#20](https://github.com/bal7hazar/quiver/pull/20)), and
the owner reviewed that lot (below). **ARC-07b** (this brief) rewrites `quiver_achievement` the same
way, applying what ARC-07a settled and what the owner's verdict adds.

## Goal
After this lot, `quiver_achievement` is organised as `quiver_quest` 0.2.0 is: **no `logic/` folder**;
every stored entity a model in `models/` in the arcade layout, value types in `types/`, what belongs
to no entity in `helpers/`, all scoped in traits with short names; one store; **each tracked model's
event optional for the consumer**, chosen at compile time, at no cost on a write. The package stays
**in event mode only** (the decision of 2026-09-29): progress is emitted, never stored. Behaviour,
events, error strings, storage layouts, tests and gas caps of 0.1.0 are kept, except where the
pattern needs a change, measured and named (one is known: `points` stored, below). The package's
version becomes **0.2.0** (its module paths change).

## Context
- **The rule**: [docs/CAIRO.md](../CAIRO.md) §7 and §8; the owner's rule D-143; the owner's review of
  ARC-06, D-147 (`logic/` removed; a model's event optional for the consumer).
- **The owner's verdict on ARC-07a, D-167** (`cd /home/claude/projects/grimworld && git fetch -q origin && git show origin/pm/d-167-tests-in-file:docs/decisions/2026-09-30-arc-07a-owner-review.md`
  until it is merged on the game's `main`, then `origin/main`): ARC-07a is **accepted** ("clean and
  close to the target"); follow its shape. It adds **the rule of tests** (docs/CAIRO.md §2, "Where a
  test lives"), which this lot is the first to apply (below). The owner is shown this lot.
- **The finished example, to follow in shape and names**: `packages/quest/` at `main` (0.2.0):
  `src/store.cairo` (`Tracked`, `QuestTracking`, `store::tracking::{TrackAll, TrackNone}`,
  `get_x`/`set_x` on the component's state), `src/models/` (`index.cairo`, `definition.cairo`,
  `status.cairo`, `reporter.cairo`), `src/events/`, `src/types/`, `src/helpers/`, `README.md`
  ("Layout", "Tracking: the consumer's choice"), `CHANGELOG.md` `[0.2.0]`, and the tests
  `tests/test_tracking.cairo`, `tests/mock_tracking.cairo`, `tests/test_store_models.cairo`,
  `tests/test_component_track_none.cairo`. Its report: `docs/reports/ARC-07a-report.md`.
- **The pattern and its reasons**: [docs/research/ARC-06-model-store.md](../research/ARC-06-model-store.md):
  §1 the mechanism, §6 **the rule for an event field not stored** and the classification of the
  achievement's models, §7 optional tracking (the constant folded by the compiler, why the ready
  impls sit in `store::tracking`: error E2313 otherwise).
- **What exists**: `packages/achievement/` (`quiver_achievement` 0.1.0, published from `50017e7`):
  `src/logic/` (`types.cairo` with slot A `AchievementDefinition` and slot B
  `AchievementExtraTasks`, `definition.cairo`, `window.cairo`, `batch.cairo`, `bits.cairo`),
  `src/component.cairo` (storage, the four events, the hook `authorize_admin`, the internal and
  external layers), 102 tests with budgets, `GAS.md`.
- The arcade reference, read-only in `ref/arcade/` of your worktree (`cartridge-gg/arcade` at
  `c53fadc`, `packages/achievement/src/`).

## The models, as ARC-06 §6 classifies them

| Model | Storage | Tracked | Event |
|---|---|---|---|
| Achievement definition: window, tasks, **`points`** | slot A's head, slot B (2 or 3 tasks only) | **Yes**, constant `DEFINITION` | `AchievementDefined`, on every write, 0.1.0's keys and data |
| Achievement status: `defined`, `retired` | slot A, shared with the definition (read once per path, written as the whole of A, as `QuestStatus`) | No | none; `AchievementRetired` stays an **action event** of `retire` |
| Reporters | `Map<ContractAddress, bool>` | **Yes**, constant `REPORTER` | `AchievementReporterSet`, on every write |
| Progress | nothing stored (event mode) | not a model | `AchievementProgressed`, an **action event**, one per merged non-zero entry as 0.1.0 |

**`points` is stored** (ARC-06 §6, rule 1: a tracked model holds every field its event carries): 16
bits of slot A, **[196, 212)**, which `define` writes anyway; no new slot. This is the one known
change of layout: name it in the CHANGELOG, measure `define` with it (ARC-06 measured +200 on an
equivalent model), and keep the reserved-bit check on the rest, [212, 252). The view
`achievement_definition` returns slot A with its `points`; name that change of its ABI.

## Optional tracking

As ARC-07a, with the package's own names: `pub trait AchievementTracking<TContractState> { const
DEFINITION: bool; const REPORTER: bool; }` in `quiver_achievement::store`, the ready impls in
`store::tracking` (`TrackAll`, as 0.1.0; `TrackNone`), taken by the component's impls as an impl
parameter like the hook; `set_x` of a tracked model emits `if Tracking::X`. **The criterion**: under
`TrackNone` a write costs exactly the write with no event code, measured to the unit against a
hand-written twin; under `TrackAll` the write plus the event. ARC-07a measured the constant folded by
the compiler on Cairo 2.19: measure it again here on this package's models (definition with 1 and 3
tasks, reporter), in the tables of `GAS.md`.

**Action events stay emitted whatever the consumer tracks**, as in `quiver_quest` 0.2.0, which the
owner accepted: `AchievementRetired` and `AchievementProgressed` (in event mode, the only record of
progress) are not the consumer's choice.

## Where tests live (D-167, docs/CAIRO.md §2)

This lot is the first under the owner's rule, and the owner reads it for that too:

- **The unit tests of a module are in that module's file**, under `#[cfg(test)] mod tests` at its
  end: a model's constructor, checks, packing and behaviour in `models/<x>.cairo`, a type's in
  `types/<x>.cairo`, the bit helpers and the batch merge in theirs, the store's own in `store.cairo`.
  Whoever changes the code sees its tests.
- **Only what needs a deployed contract or several packages stays in `tests/`**: the component
  through its entrypoints (access, define, retire, progress, the events emitted), the mocks, the
  entrypoint gas benchmarks, the tracking benchmarks against their hand-written twins.
- A test kept in `tests/` for a performance reason says so in a comment above it.
- Every test keeps its budget, moved with it. **`scripts/gas.py` reads budgets in `src/`**: it scans
  `src/` and `tests/` and follows inline `mod tests { .. }` blocks, naming `src/models/x.cairo`'s
  tests `quiver_achievement::models::x::tests::<fn>`. The orchestrator checked its parser on a
  sample; no real run has one yet: show it (a test in `src/` over or without a budget fails
  `--check`), and if it does not hold, fix `scripts/gas.py` with a case in its own tests and say
  so in the report.
- State in the report the build time and the test run time of the package, before and after the
  move (D-167: "a measured compile-time cost of tests in `src/` that the owner judges too high"
  would reverse the rule).
- `quiver_quest`'s own tests move in a later lot of their own (ARC-07c), not in this one.

## Scope

**In** (all in `packages/achievement/` unless named):

1. **`src/logic/` removed.** Its contents go to: `models/` (one file per stored entity, arcade's
   shape: struct in `models/index.cairo`, `...Impl of ...Trait`, `...Assert`, `mod errors`, its slot
   types and their packing, its `Tracked` impl when it has an event), `types/` (window, task, the
   progress entry), `helpers/` (bits, the batch merge if no type owns it), each scoped in traits;
   `events/` one file per event. No free function without a written reason.
2. **The models of the table above**, each read and written only through the store; the component
   holds entrypoints and access control only.
3. **Optional tracking** as above, with tests: under `TrackAll` each tracked `set_x` emits exactly
   once per write (created, changed, rewritten unchanged) with 0.1.0's keys and data; under
   `TrackNone` nothing, and the same felts are written; an untracked model never emits.
4. **Names**: as `quiver_quest` 0.2.0: `AchievementDefinition` is the model only; 0.1.0's slot types
   get slot-specific names (`HeadSlot`, `TasksSlot`, as the quest package); short, scoped, the
   design's words.
5. **Tests placed by the rule above**: unit tests in their module's file, the rest in `tests/`.
6. **Kept**: event mode only (no storage mode, no per-player storage, nothing reserved for one);
   behaviour, events and their fields, error strings, storage layouts (except `points`, named),
   every test (moved where the rule or the paths say, renamed only where the paths change), every gas budget (no raise without a
   `// gas: raised, <reason>` note); the worst calls of 0.1.0 (`progress_many` 1.82M, `define`,
   `retire`, the views) not raised beyond noise, remeasured and stated.
7. **Documents**: README (the layout, the consumer's sketch with the tracking choice), `CHANGELOG.md`
   section `[0.2.0]` (not yet released: the breaking changes of paths and names, `points` stored,
   the view's ABI, the tracking choice), `GAS.md`, **`docs/BUDGETS.md`'s `quiver_achievement`
   tables refreshed**, ARC-01 §3.10–3.11 amended where the paths and names change, and a section
   "Optional tracking, ARC-07b" in `docs/research/ARC-06-model-store.md` (the figures only; the
   mechanism is §7's).
8. `Scarb.toml` version `0.2.0`.

**Out**: `quiver_quest` (its tests move in ARC-07c); a storage mode; publication
(never by an agent: D-132).

**Allowlist**: `packages/achievement/**`, `docs/BUDGETS.md`, `docs/research/ARC-06-model-store.md`,
the `achievement` parts of `docs/research/ARC-01-quest-achievement.md`; `scripts/gas.py` and its
tests only if it does not read budgets in `src/`. Anything else is an escalation.

## Acceptance criteria
- [ ] AC-1 No `logic/` folder; the layers of §7, in the shape and names of `quiver_quest` 0.2.0; no
      free function without a written reason.
- [ ] AC-2 Every stored entity is a model read and written only through the store; `points` stored in
      slot A [196, 212), and `AchievementDefined` built from the model.
- [ ] AC-3 Optional tracking chosen by the consumer at compile time; an untracked write costs exactly
      a write with no event code (measured); tests for `TrackAll` and `TrackNone`.
- [ ] AC-4 Event mode only; behaviour, events, errors and layouts of 0.1.0 kept (or each change named
      and measured); every test kept; worst calls not raised beyond noise.
- [ ] AC-5 Unit tests in their module's file under `#[cfg(test)] mod tests`; `tests/` holds only
      what needs a deployed contract; `scripts/gas.py --check` counts the tests in `src/` (shown);
      build and test times before and after in the report.
- [ ] AC-6 README, CHANGELOG `[0.2.0]`, GAS.md, BUDGETS refreshed, ARC-01 amended, ARC-06 research
      section; version 0.2.0.
- [ ] AC-7 The pull request's CI is green.

## Verification
`scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml build`,
`cd packages/achievement && snforge test`, `scripts/gas.py packages/achievement --check`,
`scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml fmt --check`,
`python3 .github/ci/check-links.py`; then `gh pr checks <n> --watch --interval 30` until green.

## Report
`REPORT.md` (COMMON.md §6): the layout, the tracking figures against 0.1.0, **the paths the owner
should read** (the tracking trait, the definition model with `points`, the store), the gas table
against 0.1.0, where the tests went and the build and test times, deviations, escalations. Branch `feat/ARC-07b-achievement-0.2.0`; pull request
`[Opus 5.5] ARC-07b achievement 0.2.0`. Foreground only; your turn ends when `REPORT.md` is written.
