# [Opus 5.5] ARC-07b — `quiver_achievement` 0.2.0 on the pattern of CAIRO.md §7

> **Archived by the orchestrator** (2026-10-01). The task worktree was removed after the merge with
> `REPORT.md` uncommitted. The first part below is the agent's `REPORT.md` as the orchestrator read it
> at 08:05 UTC. The fix loops are the agent's sections of the pull request's description, as
> merged in #25.


## Summary

`quiver_achievement` is now organised as `quiver_quest` 0.2.0 is. It is version 0.2.0 and is not
published. Pull request: **https://github.com/bal7hazar/quiver/pull/25**, with CI green on every
check. The session ran as Opus 5.5 (`claude-opus-5-5`), as the brief names.

- **No `logic/` folder.**
  - `models/`: `index`, `definition`, `status`, `reporter`.
  - `events/`: `index`, plus one file per event.
  - `types/`: `window`, `task`, `batch`.
  - `helpers/bits`.
  - One `store.cairo`.
  - `component.cairo` holds entrypoints and access control only.
  - No free function remains in the library except the constant tables of `helpers::bits`, whose
    reason is written there.
- **Every stored entity is a model, read and written only through the store:**
  - `AchievementDefinition { id, window, tasks, points }`: tracked. `AchievementDefined` is built
    from the model.
  - `AchievementStatus { id, defined, retired }`: untracked. It shares slot A, is read once per
    path, and is written as the whole of A.
  - `AchievementReporter`: tracked.
  - Progress is not stored: event mode only.
- **`points` is stored** in slot A, bits [196, 212). The reserved-bit check now covers
  [212, 252). The view `achievement_definition` returns `(HeadSlot, Span<AchievementTask>)`, with
  one more felt in its output.
- **Optional tracking.**
  - `store::AchievementTracking { const DEFINITION; const REPORTER; }`.
  - The ready impls are in `store::tracking::{TrackAll, TrackNone}`.
  - The component's three impls take it as an impl parameter.
  - **Measured to the unit against hand-written twins**: the definition with 1 and with 3 tasks,
    and the reporter, under both choices.
  - The action events (`AchievementProgressed`, `AchievementRetired`) are emitted whatever the
    choice.
- **Tests placed by D-167** (the first lot under the rule).
  - 54 unit tests are in their modules under `#[cfg(test)] mod tests`.
  - The 81 tests in `tests/` all deploy a contract.
  - All 102 tests of 0.1.0 are kept (one renamed); 33 are new; 135 in total.
  - `scripts/gas.py --check` counts and fails tests in `src/`, so it needed no change.
- **Costs.** Progress, the worst call, is 0.1.0's cost to the unit. So are `set_reporter`, the
  reporter view and the game's results calls. `define` of 1 task is 4 370 cheaper. Storing
  `points` costs `define` of 3 tasks +1 610, `retire` +2 570 and the definition view +3 610.

**The paths the owner should read:**

- The tracking trait and the store: `packages/achievement/src/store.cairo`. It holds `Tracked`,
  `AchievementTracking`, `tracking::{TrackAll, TrackNone}`, `set_definition` and `set_reporter`
  (`if Tracking::X`).
- The definition model with `points`: `packages/achievement/src/models/definition.cairo`.
  - `HeadSlot`, with the layout of A including `points` [196, 212).
  - `DefinitionTrait::new`, `DefinitionStorage::into_slots` and `from_slots`.
  - `HeadPacking` (the reserved check is the `u16` downcast of what is left above bit 196).
  - Its `mod tests`: the constructor, the packing oracle, and the benchmarks.
- The models' structs: `src/models/index.cairo`. The status sharing A: `src/models/status.cairo`.
- The tracking measures: `tests/test_tracking.cairo` with `tests/mock_tracking.cairo`;
  `tests/test_store_models.cairo`; `tests/test_component_track_none.cairo`.

## Files changed

- `packages/achievement/Scarb.toml`: version 0.2.0.
- `Scarb.lock`: one line, the package's version (as in ARC-07a; see Deviations).
- `src/lib.cairo`: the module tree of §7.
- `src/logic.cairo` and `src/logic/types.cairo`: removed.
- `src/logic/{bits,batch,window,definition}.cairo` moved to `src/helpers/bits.cairo`,
  `src/types/batch.cairo`, `src/types/window.cairo` and `src/models/definition.cairo`, then
  rewritten as traits.
- `src/types/task.cairo`: new (`AchievementTask`, `TaskAssert`).
- `src/models/index.cairo`, `status.cairo`, `reporter.cairo`: new.
- `src/events/index.cairo`, `defined.cairo`, `progressed.cairo`, `retired.cairo`,
  `reporter_set.cairo`: new.
- `src/store.cairo`: new.
- `src/component.cairo`: entrypoints and access control only, through the store, with the
  tracking parameter.
- `src/interface.cairo`: new paths; the view returns `HeadSlot`.
- `src/constants.cairo` and `src/errors.cairo`: their tests moved in.
- `tests/test_batch.cairo`, `test_bench.cairo`, `test_constants.cairo`, `test_errors.cairo`,
  `test_definition.cairo`, `test_packing.cairo`: removed, their tests moved into `src/`.
- `tests/mocks.cairo`: each mock names its tracking choice; adds `MockBenchSilent` (`TrackNone`).
- `tests/mock_tracking.cairo`: new (`MockStoreAll`, `MockStoreNone`, each with store paths and
  hand-written twins).
- `tests/test_tracking.cairo`, `test_store_models.cairo`, `test_component_track_none.cairo`: new.
- `tests/helpers.cairo`, `setup.cairo`, `test_component_bench.cairo`: new import paths.
- `tests/test_component_define.cairo`: new import paths, and `HeadSlot` with `points` in the
  view's check.
- `tests/test_component_retire.cairo`: also checks that `points` is kept by a retirement.
- Remeasured budgets in `tests/test_component_{access,define,progress,retire}.cairo`.
- `packages/achievement/GAS.md`: the regenerated table; a hand section for 0.2.0 (tracking,
  before and after, `points`, where the tests went); 0.1.0's cost model kept below it.
- `packages/achievement/README.md`: the layout, the models, the tracking choice, the consumer's
  sketch with `impl AchievementTracking = TrackAll`, slot A's layout, the figures.
- `packages/achievement/CHANGELOG.md`: section `[0.2.0] - Unreleased`.
- `docs/BUDGETS.md`: the `quiver_achievement` tables refreshed, with a tracking table.
- `docs/research/ARC-01-quest-achievement.md`: amendments by ARC-07b to §3.1, §3.10 (the
  0.1.0 → 0.2.0 mapping, `points`), §3.11 (slot names, `points`, the view, the tracking
  parameter) and §5.2 (figures).
- `docs/research/ARC-06-model-store.md`: §8 "Optional tracking, ARC-07b", figures only.

## Commands run

Before any change, at `dd503a4` (0.1.0):

```
$ time scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml build   # target/ empty
    Finished `dev` profile target(s) in 2 seconds
real 0m2.397s
$ cd packages/achievement && time snforge test        # cold
    Finished `dev` profile target(s) in 8 seconds
Running 102 test(s) from tests/
Running 0 test(s) from src/
Tests: 102 passed, 0 failed, 0 ignored, 0 filtered out
real 0m9.921s
$ time snforge test                                    # warm
real 0m4.041s
```

After the move, at `859abce`:

```
$ rm -rf target/dev && time scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml build
    Finished `dev` profile target(s) in 2 seconds
real 0m2.272s
$ cd packages/achievement && time snforge test        # cold
    Finished `dev` profile target(s) in 9 seconds
Running 54 test(s) from src/
Running 81 test(s) from tests/
Tests: 135 passed, 0 failed, 0 ignored, 0 filtered out
real 0m11.266s
$ rm -rf target/dev && time snforge test               # cold, again
    Finished `dev` profile target(s) in 9 seconds
real 0m11.628s
$ time snforge test                                    # warm
real 0m2.586s

$ scripts/gas.py packages/achievement --check
quiver_achievement: 135 tests within budget, GAS.md up to date
$ scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml fmt --check   # no output, exit 0
$ python3 .github/ci/check-links.py
check-links: 0 broken link(s)
```

`gas.py --check` on tests in `src/`, shown with two temporary edits that were then reverted
(`git checkout`): a budget above its ceiling on `types::batch::tests::batch_merge_saturates`, and
no budget on `types::window::tests::window_is_active_bounds`:

```
quiver_achievement: quiver_achievement::types::batch::tests::batch_merge_saturates budget 99999 is above ceil(1.05 x 80115) = 84121
quiver_achievement: quiver_achievement::types::window::tests::window_is_active_bounds has no #[available_gas(l2_gas: N)] budget
quiver_achievement: quiver_achievement::types::batch::tests::batch_merge_saturates GAS.md says measured/budget (80115, 84121), now (80115, 99999)
quiver_achievement: quiver_achievement::types::window::tests::window_is_active_bounds GAS.md says measured/budget (15640, 16422), now (15640, None)
exit 1
```

A budget below the measure fails `snforge` itself. `gas.py` reads budgets in `src/` correctly:
it was not changed.

CI on PR #25 (`gh pr checks 25 --watch --interval 30`):

```
affected  pass   cairo  pass   links  pass   scripts  pass
package (packages/achievement)  pass 1m16s   package (packages/quest)  pass 2m51s
```

**Build and test times (D-167).**

| | 0.1.0 (tests in `tests/`) | 0.2.0 (unit tests in `src/`) |
|---|---|---|
| `scarb build`, cold (what a consumer compiles) | 2.4 s | 2.3 s |
| `snforge test`, cold: compile step / wall | 8 s / 9.9 s | 9 s / 11.3 s and 11.6 s |
| `snforge test`, warm | 4.0 s | 2.6 s |

- The library build is unchanged: `#[cfg(test)]` modules are not compiled by `scarb build`, nor
  into a consumer's build.
- The cold test run is about 1.5 s longer. It also has 33 more tests and three more mock
  contracts in `tests/` (`MockStoreAll`, `MockStoreNone`, `MockBenchSilent`), so the share due to
  the move alone is not isolated. The machine is shared; one sample before, two after.

## Cost

L2 gas, snforge 0.61. A call is its benchmark minus its baseline, under `TrackAll` (`MockBench`).
"Before" was measured on this branch at `dd503a4`.

| Entrypoint or algorithm | Before | After | Budget (test) | Note |
|---|---|---|---|---|
| **`progress_many`, the worst** (late collision) | 1 816 813 | 1 816 813 | 2 736 734 | Unchanged to the unit |
| `progress_many`, late duplicate | 1 759 993 | 1 759 993 | 2 677 073 | 0 |
| `progress_many`, 16 distinct | 1 245 486 | 1 245 486 | 2 136 841 | 0 |
| `progress_many`, with 48 definitions | 1 816 613 | 1 816 613 | 63 268 583 | 0 |
| `progress` | 209 236 | 209 236 | 1 048 778 | 0 |
| `define`, 3 tasks | 1 197 030 | 1 198 640 | 2 085 962 | +1 610 (+0.13 %), `points` packed |
| `define`, 1 task | 707 640 | 703 270 | 1 567 514 (lowered) | −4 370 |
| `retire` | 240 760 | 243 330 | 2 338 949 | +2 570 (+1.1 %), `points` unpacked and packed |
| `set_reporter`, new / revoked / unchanged | 607 410 / −195 270 / 206 530 | the same | unchanged | 0 |
| `achievement_definition`, 3 tasks | 214 130 | 217 740 | 2 310 987 | +3 610 (+1.7 %), `points` unpacked and returned |
| `achievement_is_reporter` | 124 690 | 124 690 | 960 005 | 0 |
| The game's results call / 16 tasks | 829 728 / 1 245 286 | the same | lowered | 0 |
| The game's 26 tiers defined | 18 525 730 | 18 412 110 | 20 161 796 (lowered) | −113 620; 92.1 % of the 20 M cap |
| `BatchTrait::merge`, worst (own cost) | 701 533 | 701 533 | 789 100 | 0, moved to `src/` |
| `DefinitionTrait::new` + `into_slots`, 3 tasks (was `definition_new`) | 20 920 | 20 120 | 21 126 (lowered) | −800 |
| `HeadSlot` pack + unpack (was `AchievementDefinition`) | 34 120 | 34 790 | 35 826 | +670, `points` |
| `TasksSlot` pack + unpack | 24 930 | 24 930 | 26 177 | 0 |

**Tracking** (`test_tracking`; created; each figure is the benchmark minus the contract's
baseline):

| Model | `TrackNone`: store / hand | `TrackAll`: store / hand | The event |
|---|---|---|---|
| Definition, 1 task | 467 910 / 467 910 | 538 090 / 538 090 | 70 180 |
| Definition, 3 tasks | 926 590 / 926 590 | 1 021 350 / 1 021 350 | 94 760 |
| Reporter | 454 630 / 454 630 | 495 830 / 495 830 | 41 200 |

**Budgets.**

- Every test has one; `gas.py --check` passes.
- **One raise**, noted `// gas: raised` above the attribute:
  `models::definition::tests::achievement_packing_round_trip_definition`, 7 879 452 → 9 068 105.
  Its `u256` oracle now packs `points` too; the packing itself is `bench_pack_unpack_definition`.
- The other changed budgets were lowered, or set for the 33 new tests at `ceil(1.05 × measured)`.
- A moved test whose code did not change costs in `src/` exactly what it cost in `tests/`. The
  full per-test table is in `GAS.md`, "Where the tests went".

## Acceptance criteria

- **AC-1: met.**
  - There is no `src/logic`.
  - The layers and names follow `quiver_quest` 0.2.0: `HeadSlot`, `TasksSlot`,
    `DefinitionTrait`, `DefinitionAssert`, `DefinitionStorage`, `DefinitionTracked`, `StatusTrait`,
    `StatusAssert`, `StatusStorage`, `ReporterAssert`, `ReporterTracked`, `BatchTrait::merge`,
    `count_of`, `WindowTrait::is_active`, `WindowAssert::assert_valid`, `TaskAssert::assert_valid`,
    and events with their `new`.
  - The only free items in the library are the constant tables of `helpers::bits`, with their
    reason written there. The test modules have free builder functions (test code).
- **AC-2: met.**
  - The component has no storage access of its own: every read and write goes through
    `StoreTrait` (`get_definition`, `get_definition_head`, `get_definition_tasks`,
    `set_definition`, `get_status`, `set_status`, `get_reporter`, `set_reporter`).
  - `points` is in A [196, 212): `models::definition::tests::achievement_packing_points_at_their_position`
    and `test_store_models::track_none_definition_emits_nothing_and_writes_the_same` check the
    packed felt.
  - `AchievementDefined` comes from `DefinedTrait::new(@definition)`.
- **AC-3: met.**
  - Tracking is chosen at compile time by an impl parameter.
  - `test_tracking`: store − hand = 0 in all six cases.
  - `test_store_models`: one event per write under `TrackAll` (created, changed, rewritten
    unchanged) with 0.1.0's keys and data; none under `TrackNone`, with the same felts; the
    untracked status never emits.
  - `test_component_track_none`: only action events under `TrackNone`.
- **AC-4: met, with `points` named and measured.**
  - Event mode only.
  - Every test of 0.1.0 is kept: 102, one renamed (see Deviations).
  - Events, keys, data and error strings are unchanged: the component's event tests and
    `errors::tests` pass unchanged.
  - The worst call (`progress_many`) is unchanged to the unit.
  - `define` of 3 tasks is +0.13 %. `retire` (+1.1 %) and the definition view (+1.7 %) rise
    because of `points`, the change the brief names.
- **AC-5: met.** 54 unit tests in `src/`; `tests/` holds the 81 that deploy a contract.
  `gas.py --check` counts and fails tests in `src/` (shown above). Times before and after are
  above.
- **AC-6: met.** README, CHANGELOG `[0.2.0]`, GAS.md, BUDGETS.md, ARC-01 (§3.1, §3.10, §3.11,
  §5.2), ARC-06 §8. `Scarb.toml` is at 0.2.0.
- **AC-7: met.** CI on PR #25 is green on every check.

## Deviations from the brief

1. **`Scarb.lock`, a shared file, changed by one line**: the package's version, a mechanical
   consequence of the bump the brief asks for. ARC-07a committed the same line for
   `quiver_quest`.
2. **One test renamed for the layout change**: `achievement_unpacking_rejects_bit_196` →
   `achievement_unpacking_rejects_bit_212`. Bit 196 is now `points`' first bit, so the first
   reserved bit is 212. Two packing tests changed their expected values for the same reason
   (`achievement_packing_widths`: A's widest value is 2^212 − 1; the round trip's oracle packs
   `points`).
3. **`points` costs more than ARC-06's estimate.**
   - ARC-06 §4 measured +200 for a `u16` added to a mock slot of two fields.
   - On slot A, `retire` rises 2 570 and `define` of 3 tasks 1 610: about 2 100 per pack and 470
     per unpack, isolated by measuring the code with only the `points` term removed. In the
     library alone, pack and unpack together cost +670.
   - Writing the term differently (folded into `t0.total`'s term) costs the same. Forcing
     `#[inline(always)]` on the pack changed nothing.
   - I kept the plain layout and named the cost. The brief lists `retire` and the views among the
     calls not to raise beyond noise, and also names `points` as the known change of layout. I
     read the two together as "the `points` change, measured and named". If the owner reads
     +1.1 % on `retire` as beyond noise, that is an open question (below).
4. **Checks by value, not by snapshot.**
   - `ReporterAssert::assert_is_allowed` and the status's methods take their model by value,
     unlike `quiver_quest`'s `@` signatures.
   - By snapshot, the reporter check cost 500 (5 steps) on every progress call. By value,
     progress is 0.1.0's to the unit. The reason is written above the function.
5. **The test builders are repeated** in the `mod tests` of `src/` (`window`, `task`, `entry`,
   `fifteen_then`, …): a test module in `src/` cannot use `tests/helpers.cairo`. They are a few
   lines each.
6. **The store's own unit test in `store.cairo` is small** (the two ready choices' constants).
   Its reads and writes need a deployed contract, so their tests are in `tests/`, as the brief's
   rule allows.
7. **New tests not asked for by name:** `window_validate_rejects_empty_window`,
   `definition_points_stored_and_read_back`, `achievement_packing_points_at_their_position`, and
   four `status` tests.
8. **I could not read the owner's verdict D-167 itself.** `git show` on the game's repository is
   refused by this profile. I worked from the brief's account of it and from docs/CAIRO.md §2,
   which carries D-167's row.

## Escalations

None blocking.

- For ARC-07c or an audit of `quiver_quest`: `quiver_quest` 0.2.0 takes the same checks by
  snapshot (`ReporterAssert::assert_is_allowed(self: @QuestReporter)`, `StatusAssert`). On this
  package, that pattern cost 5 steps per call. Whether it does so in `quiver_quest` was not
  measured here (out of scope).

## Open questions

1. Is the cost of storing `points` acceptable as measured: `retire` +2 570 (+1.1 %), the
   definition view +3 610 (+1.7 %), `define` of 3 tasks +1 610 (+0.13 %), and `define` of 1 task
   −4 370? The worst call is unaffected.
2. The cold test run is about 1.5 s longer after the move. It also gained 33 tests and three
   contracts, and the share due to the move alone is not isolated. The library build, which a
   consumer pays, is unchanged. Is this within what D-167 accepts?

## Fix loop 1 (review by [Fable 5.1], PASS WITH FINDINGS at `ef4e3a8`)

1. **(minor) No test told `DEFINITION` from `REPORTER`.**
   - `tests/mocks.cairo` adds two consumers with their own impl of `AchievementTracking`: `MockTrackDefinitionOnly` (`DEFINITION = true, REPORTER = false`) and its mirror `MockTrackReporterOnly`.
   - `tests/test_component_track_own.cairo`: under the first, `define` emits `AchievementDefined` once, with its keys and data, and `set_reporter` emits nothing. Under the second, the reverse.
   - With the two constants swapped in `store.cairo` (a temporary edit, reverted), exactly these two tests fail and the other 136 pass.
   - These tests also compile the "impl of its own" row of the README's tracking table.
2. **(note) `DefinitionTrait::is_active` untested.** `models::definition::tests::definition_is_active_inside_and_outside_its_window` checks times inside and outside a closed window and an open-ended one.

Three tests, each with its budget (`ceil(1.05 × measured)`); no other figure moved. 138 tests: 55 in `src/`, 83 in `tests/`. `gas.py --check`, `fmt --check` and `check-links` pass.

## Fix loop 2 (organisation audit by [Opus 5.5] at `66ae1c8`, notes 2 to 4)

1. **(note 2) Status methods: by value or by snapshot, measured** on `define`, `retire` and the view.
   - `StatusAssert` by `@` costs 1 step more per check: +100 on `define` and the view, +200 on `retire`. It stays by value, with that reason written above it.
   - `StatusStorage` costs the same either way, so it now takes `@`, as `quiver_quest` does.
   - Every entrypoint figure is unchanged. The table of the four variants is in `GAS.md`, "Fix loop 2".
2. **(note 3) Unit tests in `helpers/bits.cairo` and `models/reporter.cairo`.**
   - `bits`: `POW2[i] == 2^i` for each of the 128 entries, and each `TWO_POW_*` and `NZ_*` constant against 2^n computed by doubling.
   - `reporter`: `assert_is_allowed` on an allowed reporter, and on a refused one with `'Achievement: not reporter'`.
   - Five tests, each with its budget.
3. **(note 4)** The comment in `tests/helpers.cairo` names `BatchTrait::merge`.

Notes 1 and 5 are left as the orchestrator decided. 143 tests: 60 in `src/`, 83 in `tests/`. `origin/main` is merged in. Build, `snforge test`, `gas.py --check`, `fmt --check` and `check-links` pass.

## Fix loop 3 (third review by [Fable 5.1] at `cbd420d`)

1. **(minor) The fix-loop-2 table in `GAS.md` used the wrong baseline for `define`.** Its two `define` columns subtracted `baseline_reporter_registered` instead of `baseline_deployed`, although both benchmarks call `deploy()` only. They now read 1 198 640 on 3 tasks and 703 270 on 1, with the `@` variant +100 on each. The `retire` and view columns were rechecked against `baseline_defined` and were already right. The same correction is made in `REPORT.md`.
2. **(note) "Costs the same" is now scoped.** `src/models/status.cairo` says "the same on every entrypoint". `GAS.md` names the one unit test that costs more with `StatusStorage` by `@`: `status_retire_keeps_the_definition_bits`, 27 080 → 27 480 (+400), within its budget.
3. **(note) `BitsTrait::split` tested.** `split_both_limbs` (both limbs set, the high limb at 2^123 − 1) and `split_high_limb_zero` (below 2^128, and 0), each with its budget.

No other figure moved. 145 tests: 62 in `src/`, 83 in `tests/`. `origin/main` is merged in. Build, `snforge test`, `gas.py --check`, `fmt --check` and `check-links` pass.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
