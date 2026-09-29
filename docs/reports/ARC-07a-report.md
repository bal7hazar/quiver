# [Opus 5.5] ARC-07a — `quiver_quest` 0.2.0 on the pattern of CAIRO.md §7

## Summary

`quiver_quest` is now version 0.2.0, organised as D-143 and the owner's review D-147 ask. The model
that ran was Opus 5.5 (`claude-opus-5-5`), as the brief names. Pull request:
https://github.com/bal7hazar/quiver/pull/20 (CI green; not merged).

- **No `logic/`.** The layers of §7:
  - `models/`, one file per stored entity (`definition`, `status`, `progress`, `record`, `held`,
    `reporter`), with the structs in `models/index.cairo`;
  - `events/`, one file per event, the structs in `events/index.cairo`;
  - `types/` (`mode`, `schedule`, `task`, `batch`, `held`) and `helpers/bits.cairo`;
  - one `store.cairo`, and the `component`.

  Everything is scoped in traits. The only free function left is the component's private
  `assert_player` (0.1.0's), with its reason written.
- **Every stored entity is a model, read and written only through the store.** The six models:
  - `QuestDefinition`: tracked, slots A, B, C.
  - `QuestStatus`: untracked, the status bits of A. A path reads A once
    (`get_definition_head`, then `head.status(id)`) and writes the whole of A back from that read
    (`set_status(status, head)`).
  - `QuestProgress` (P), `QuestRecord` (R) and `QuestHeldSlot` (H): untracked, keys first.
  - `QuestReporter`: tracked.

  Nothing in the component touches a storage member.
- **Optional tracking, chosen by the consumer at compile time.** The trait is
  `store::QuestTracking<TContractState> { const DEFINITION: bool; const REPORTER: bool; }`, with
  `store::tracking::TrackAll` and `TrackNone`. `set_definition` and `set_reporter` emit
  `if Tracking::X`. The component's three impls take the choice as an impl parameter, like the
  hooks. Action events (`QuestProgressed`, `QuestCompleted`, `QuestClaimed`, `QuestRetired`) are
  emitted by the component whatever the choice.
- **Both mechanisms were measured first**: the constant, and an emitter impl per model
  (`Emit`/`Silent`). Both meet the criterion to the unit. The constant is adopted.
- **What 0.1.0 does is kept.**
  - Behaviour, events (selectors, keys, data), error strings and storage layouts are 0.1.0's.
  - The views serialise as in 0.1.0; they return the slots under their new names.
  - Every test was kept (moved and renamed where paths changed). 501 tests now, 475 before.
  - No worst call is raised.

**The paths the owner should read:**

1. `packages/quest/src/store.cairo`: `Tracked`, `QuestTracking`, `tracking::{TrackAll, TrackNone}`,
   and the store (`set_definition` and `set_reporter` are the two tracked writes).
2. `packages/quest/src/models/status.cairo`: the model sharing slot A, and its three rules.
3. `packages/quest/src/models/progress.cairo`: a keyed, untracked model with its slot, behaviour,
   checks and packing.
4. `packages/quest/src/models/definition.cairo` with `models/index.cairo`: the tracked model and
   slots A, B, C.
5. `packages/quest/src/component.cairo`: the component on the store.
6. The research: `docs/research/ARC-06-model-store.md` §7 ("Optional tracking, ARC-07a").

## Files changed

- `packages/quest/src/logic.cairo`, `src/logic/*`: removed (`bits.cairo` moved to `helpers/`).
- `packages/quest/src/lib.cairo`: the modules of the new layout.
- `packages/quest/src/store.cairo`: `QuestTracking`, `tracking::{TrackAll, TrackNone}`, get/set for every model.
- `packages/quest/src/component.cairo`: the component on the store and models; `Tracking` impl parameter.
- `packages/quest/src/interface.cairo`: the new type paths; views return `HeadSlot`, `ProgressSlot`, `RecordSlot`.
- `packages/quest/src/models/{index,definition,status,progress,record,held,reporter}.cairo`: the models (status, progress, record, held and reporter are new).
- `packages/quest/src/events/{index,progressed,completed,claimed,retired,reporter_set}.cairo`: one file per event (`defined.cairo` kept).
- `packages/quest/src/types/{mode,schedule,task,batch,held}.cairo`: the value types and their traits.
- `packages/quest/src/helpers/bits.cairo`: the power tables, `BitsTrait::split`, and the packing errors.
- `packages/quest/tests/*`: every test ported to the new paths.
  - New: `mock_tracking.cairo`, `test_tracking.cairo`, `test_store_models.cairo`, and `oracle.cairo`
    (0.1.0's functions, kept as oracles and as the hand-written baseline).
  - `mock_store.cairo`: every model through the store, plus `MockSilentStore` (`TrackNone`).
  - `helpers.cairo`: wrappers that run the models' code on 0.1.0's slot values.
- `packages/quest/Scarb.toml`: version 0.2.0.
- `packages/quest/README.md`: the layout, the models, the tracking choice, the consumer's sketch with both choices, the integration budget refreshed.
- `packages/quest/CHANGELOG.md`: `[0.2.0] - Unreleased` (it takes in ARC-06's Unreleased section): breaking paths and names, the tracking choice, costs.
- `packages/quest/GAS.md`: the table regenerated; a new section "`quiver_quest` 0.2.0 (ARC-07a)" (tracking, every entrypoint before and after, grid, cap, budgets); the ARC-06 and 0.1.0 sections kept.
- `docs/BUDGETS.md`: the `quiver_quest` tables refreshed (component, library); a section on optional tracking.
- `docs/research/ARC-06-model-store.md`: §7 "Optional tracking, ARC-07a" (mechanism, measurements, answers to §5); header note.
- `docs/research/ARC-01-quest-achievement.md`: §3.1, §3.2 (a mapping table from 0.1.0 to 0.2.0), §3.3, §3.4, §3.5, §3.7 and §3.8 amended.
- `Scarb.lock`: one line, `quiver_quest` 0.1.0 → 0.2.0 (see Deviations).

## Commands run

```
scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build
   Compiling quiver_quest v0.2.0 (…/packages/quest/Scarb.toml)
    Finished `dev` profile target(s) in 2 seconds

cd packages/quest && snforge test                       (before the work)
Tests: 475 passed, 0 failed, 0 ignored, 0 filtered out

cd packages/quest && snforge test test_tracking         (both mechanisms, first measurement)
bench_track_none_hand_silent l2_gas ~734790 · by_constant ~734790 · by_emitter ~734790
bench_track_all_hand_emitted l2_gas ~779810 · by_constant ~779810 · by_emitter ~779810
baseline_track_none / baseline_track_all ~280260

scripts/gas.py packages/quest --write      → quiver_quest: wrote packages/quest/GAS.md (501 tests)
scripts/gas.py packages/quest --check      → quiver_quest: 501 tests within budget, GAS.md up to date
scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check   → exit=0
python3 .github/ci/check-links.py          → check-links: 0 broken link(s)

gh pr checks 20 --watch --interval 30
affected pass · cairo pass · package (packages/quest) pass 2m44s ·
package (packages/achievement) pass · links pass · scripts pass
```

Two measurements along the way:

- **`ProgressTrait::add` not inlined.** `bench_progress_many_worst_held4` was 6 217 963 (+4 900
  against the base); with `#[inline]`, 6 205 843.
- **Reading `retired` straight from the slot instead of the status model.** `grid_h8_*` were the
  same to the unit, so building the status model costs nothing. Reverted.

## Cost

Call = benchmark − baseline, L2 gas, snforge 0.61. "Before" is `GAS.md` at `6f4d93a` (ARC-06 on
`main`; 0.1.0's everywhere but `define`, 2 590 440 in 0.1.0). Budget = the benchmark test's.

| Entrypoint or algorithm | Before | After | Budget (test) | Note |
|---|---|---|---|---|
| `progress_many`, worst, H = 4, created | 6 213 063 | 6 205 843 | 16 958 764 | −7 220 |
| `progress_many`, H = 4, created, hook writes one slot | 8 027 983 | 8 020 763 | 18 864 430 | −7 220 |
| `progress_many`, H = 8, created | 11 430 213 | 11 416 073 | 29 286 037 | −14 140 |
| `progress_many`, H = 8, created, hook writes one slot | 15 060 053 | 15 045 913 | 33 097 369 | −14 140 |
| `progress_many`, §5.1 witness | 5 630 846 | 5 623 626 | 581 105 623 | −7 220 |
| Grim World's case | 4 553 406 | 4 546 186 | 85 374 616 | −7 220 |
| `accept`, worst (growth, K = 7) | 1 921 540 | 1 917 170 | 31 839 363 | −4 370 |
| `abandon`, worst | 574 060 | 564 150 | 9 848 549 | −9 910 |
| `claim` | 364 020 | 364 520 | 4 808 597 | +500 |
| `define`, worst | 2 583 680 | 2 583 680 | 26 324 710 | 0 |
| `retire`, worst | 1 003 240 | 1 003 540 | 27 378 826 | +300 |
| `set_reporter`, new | 608 210 | 608 210 | 1 546 797 | 0 |
| `progress`, nothing held | 226 756 | 227 256 | 2 405 494 | +500 |
| `progress`, event mode, 1 entry | 212 366 | 212 866 | 1 131 161 | +500 |
| view `quest_is_unlocked`, K = 7 | 492 490 | 496 790 | 40 993 508 | +4 300: seven record models with their keys |
| view `quest_progress` + `quest_record` | 288 290 | 289 090 | 40 775 423 | +800 |
| grid H = 8, all completed earlier (dead) | 1 955 713 | 1 960 853 | 15 413 342 | +5 140 (+640 per entry) |
| grid H = 8, all expired | 1 606 193 | 1 607 653 | 11 501 693 | +1 460 |
| grid H = 8, none in the batch | 3 061 953 | 3 034 453 | 13 030 241 | −27 500 |
| Tracking, one slot, `TrackNone`, store / hand (no event code) | — | 454 530 / 454 530 | 771 530 | **0**, the constant; the emitter also 454 530 |
| Tracking, one slot, `TrackAll`, store / hand (write + `emit`) | — | 499 550 / 499 550 | 818 801 | **0**, both mechanisms |
| `QuestReporter`, `TrackNone`, store / hand | — | 454 630 / 454 630 | 770 364 | **0** |
| `QuestReporter`, `TrackAll`, store / hand | 498 230 (hand) | 498 230 / 498 230 | 816 144 | **0** |
| `QuestDefinition` worst, `TrackNone`, store / 0.1.0 hand without `emit` | — | 1 497 390 / 1 502 350 | 1 930 110 | −4 960 |
| `QuestDefinition` worst, `TrackAll`, store / 0.1.0 hand | 1 652 890 / 1 657 450 | 1 652 890 / 1 657 450 | 2 093 385 | unchanged |
| `ProgressTrait::add` (was `progress_add`), benchmark | 156 430 | 155 990 | 163 790 | −440 |
| `DefinitionTrait::new` + `into_slots` (was `definition_new`), benchmark | 150 760 | 149 300 | 156 765 | −1 460 |
| `RecordTrait::all_completed` (was `prerequisites_met`), 7 records | 29 700 | 34 800 | 36 540 | **gas: raised**, models carry two keys |
| `test_record::prerequisites_met_when_each_completed_once` | 37 080 | 43 680 | 45 864 | **gas: raised**, same reason |
| `test_record::quest_prerequisites_all_required_logic` | 27 020 | 30 720 | 32 256 | **gas: raised**, same reason |

Budgets: 26 new tests budgeted, 193 lowered to `ceil(1.05 × measured)`, 3 raised with their
`// gas: raised` notes (the last three rows). Every other test is within its 0.1.0 budget. All are
in `packages/quest/GAS.md`.

## Acceptance criteria

- **AC-1** No `logic/` folder; the layers of §7; no free function without a written reason.
  - `ls packages/quest/src` shows `component.cairo constants.cairo errors.cairo events helpers
    interface.cairo lib.cairo models store.cairo types`.
  - A grep of `src` for module-level `fn` finds only `QuestComponent::assert_player`, documented.
- **AC-2** Every stored entity is a model read and written only through the store.
  - A grep for `.Quest_*.read|write` in `src` finds matches only in `store.cairo`.
  - Tests: `test_store_models` (every model's get and set, 0.1.0's slot felts),
    `test_store_definition`.
- **AC-3** Optional tracking at compile time; an untracked write costs exactly a write with no
  event code; tests for `TrackAll` and `TrackNone`.
  - Measured: `test_tracking` (0 difference, both mechanisms) and `test_store_models` (the
    reporter: 0 difference).
  - Emission tests: `track_all_emits_once_per_write`, `track_none_emits_nothing`,
    `track_all_reporter_emits_once_per_write`, `track_none_definition_emits_nothing`,
    `track_none_reporter_emits_nothing`, `store_set_definition_emits_quest_defined_once`.
  - Untracked models never emit: `untracked_{status,progress,record,held_slot}_emits_nothing`.
- **AC-4** Behaviour, events, errors and layouts of 0.1.0 kept; every test kept; worst calls not
  raised beyond noise.
  - All 475 tests of the base pass under their names; 501 in all.
  - `test_component_events` (keys and data), `test_errors`, `test_packing` (layouts) and
    `test_store_definition` (0.1.0's felts) all pass.
  - Every worst call is cheaper or equal, except `retire` +300 (3 steps).
- **AC-5** README, CHANGELOG `[0.2.0]`, GAS.md, BUDGETS refreshed, ARC-01 amended; version
  0.2.0. See "Files changed"; `Compiling quiver_quest v0.2.0`.
- **AC-6** The pull request's CI is green: `gh pr checks 20`, every check `pass`.

## Deviations from the brief

- **`Scarb.lock`** (outside the allowlist): one line changed, `quiver_quest` `version = "0.2.0"`.
  The version bump the brief asks for (item 7) rewrites it on build, and the CI builds from it.
- **The ready choices sit in `store::tracking`**, not next to `QuestTracking`. Next to the trait,
  the compiler found `TrackAll` as well as the consumer's own impl and refused the call as
  ambiguous (E2313). The consumer's path is `quiver_quest::store::tracking::TrackAll`.
- **The tracked setters are generic per function** (`fn set_definition<impl Tracking: …>`), so the
  store's reads need no tracking choice. `QuestViewImpl` still takes the `Tracking` parameter,
  because the views call `InternalImpl`, which has it.
- **The views return the slots** (`HeadSlot`, `ProgressSlot`, `RecordSlot`), not the models, so
  that the ABI's output serialises as in 0.1.0. Returning models would add their keys to the
  output; that is not done.
- **The tests of 0.1.0's pure functions run the models' code through small wrappers** in
  `tests/helpers.cairo`, which convert 0.1.0's slot values to models and back, so that their
  assertions are unchanged. 0.1.0's `definition_new`, `tasks_span`, `conditions_span` and schedule
  functions are kept verbatim in `tests/oracle.cairo`, as oracles and as the hand-written baseline
  of the store's benchmarks.
- **The CHANGELOG's ARC-06 `[Unreleased]` section is folded into `[0.2.0] - Unreleased`**: both
  lots ship in 0.2.0.

## Escalations

- **I could not read the owner's review D-147.** The brief's command (`cd /home/claude/projects/
  grimworld && git fetch … && git show origin/pm/client-visual-track:…arc-06-owner-review.md`) and
  its `git -C` forms were refused by my profile. I worked from the brief's summary of it: (1)
  `logic/` disappears; (2) a model's event is optional for the consumer. If the review says more,
  it is not reflected here.
- **The three raised budgets need the orchestrator's agreement** (CAIRO.md §2):
  `bench_prerequisites_met_seven`, `prerequisites_met_when_each_completed_once` and
  `quest_prerequisites_all_required_logic`. Records are models carrying two keys, so a span of them
  costs more to build. The component does not use that function.

## Open questions

- `quest_is_unlocked` is 4 300 more (0.9 %), and a held entry already completed costs about 640
  more per progress call (the grid's "done" column): each record or progress read builds its model
  with its keys. Both are within noise of their calls. Returning to raw slot reads on those two
  paths would undo the rule "read through a model", so I left them. Is that the right trade?
- The consumer sketch in ARC-01 §3.8 (Grim World's contract) shows `TrackAll` with a comment that
  the choice is the game's own. Grim World's actual choice is for the game to make.
- `RecordTrait::all_completed` (0.1.0's `prerequisites_met`) is kept as the component's oracle and
  as public API, but the component does not call it. Should 0.2.0 keep it public?

## Fix loop 1

The audits of GPT-6-Sol (organisation) and GPT-6-Astra (cost), four points, all addressed.
Same branch, same allowlist. Commits `af6b619` (code and tests) and `66368ce` (documents). CI is
green on pull request #20 (runs of 12:08: `affected`, `cairo`, `package (packages/quest)`,
`package (packages/achievement)`, `links`, `scripts`, all `pass`). The model that ran is Opus 5.5.

### 1 (major, organisation): the component keeps only the orchestration

- **The helpers `PrivateImpl` held move to the store, with their bodies unchanged.** They are
  storage access across several slots:

  | Before, in the component | Now, in the store |
  |---|---|
  | `held_entries` | `get_held(player_id)` |
  | `held_read` | `get_held_list(player_id) -> HeldList { entries, counter, kept }` (a new value type in `types/held.cairo`) |
  | `held_write` | `set_held_list(player_id, before, after, after_counter)`, which builds each slot with the model's `HeldSlotTrait::new` |
  | `still_held` | `is_still_held` |
  | `held_is_live` | `is_held_live` (A, then P) |
  | `prerequisites_are_met` | `prerequisites_met` (C, then each R) |

- **`PrivateImpl` keeps only `progress_held`**, the orchestration of one held quest's step of
  `progress_many`. It reads through the store, applies `ProgressTrait::add` and
  `RecordTrait::complete`, writes, emits `QuestCompleted` and calls the hook.
- **The entrypoints only orchestrate the store and the models.** `accept` and `abandon` call
  `get_held_list` and `set_held_list`; `accept` and `is_unlocked` call `prerequisites_met`.
- **Costs stay as measured.** The moved methods keep their attributes, not `#[inline]`, as in the
  component; the store's module doc says so. Before the change in point 3, every one of the 501
  existing tests measured the same to the unit (`target` run `fl1_run1`: only the 9 new tests
  differed).
- **Tests first**: `store_held_list_writes_only_the_slots_that_change` and
  `store_prerequisites_met_reads_each_record` (`test_store_models`, through `MockDefinitionStore`).
  They failed to compile before the store methods existed.

### 2 (major, organisation): the event tests

- **`track_all_definition_rewritten_emits_once_per_write`.** One definition written three times at
  the same id, through the store: created, changed (schedule, tasks, conditions), then unchanged.
  Three `QuestDefined`, each with the values written. This is only possible through the store: the
  component's `define` refuses an id already defined (`'Quest: already defined'`), as 0.1.0 does,
  and the test's doc says so.
- **`test_component_track_none.cairo`**, on a new mock `MockBenchSilent` (`MockBench` under
  `TrackNone`):
  - `track_none_component_emits_action_events_only`. `set_reporter` and two `define` emit
    nothing, and `accept` emits nothing either. Then `progress_many` (storage mode, completing)
    emits `QuestCompleted`, `claim` emits `QuestClaimed`, `progress` in event mode emits
    `QuestProgressed`, and `retire` emits `QuestRetired`: exactly 4 events, each with 0.1.0's keys
    and data. The state written is the one `TrackAll` writes.
  - `track_none_component_revoked_reporter_emits_nothing`: registering, revoking and revoking
    again emit nothing.

### 3 (major, cost): the definition to the unit

- **Both arms now build the model the same way.** Each calls `DefinitionTrait::new` inside the
  measured call:
  - the store arm: `set_definition`;
  - the hand arm (`hand_set_model_definition_silent`, `hand_set_model_definition`): the model's
    slots written by hand (`into_slots`, the three writes), then, tracked, `QuestDefined` built
    from the model's fields and emitted through the component (`HasComponent::emit`), as 0.1.0's
    `define` did.
- **The first measurement found 400 on the tracked arm.** The store measured 1 652 890 against
  1 652 490 by hand (the silent arms were already equal, 1 497 390 each).
- **Localised**:
  - the hand arm's event built with `DefinedTrait::new(@definition)`: equal to the store;
  - the emit through the contract or through the component: no difference;
  - `#[inline(always)]` on the event path: no difference, reverted.

  So the cost was `DefinedTrait::new` desnapping each field of the snapshot.
- **The fix**: `DefinedTrait::new` desnaps the model once (`let QuestDefinition { id, schedule,
  tasks, conditions } = *definition;`).
- **Now** (benchmark − baseline 340 810):

  | Choice | Store | Hand, same model | Store − hand |
  |---|---|---|---|
  | `TrackNone` | 1 497 390 | 1 497 390 (no event code) | **0** |
  | `TrackAll` | 1 652 490 | 1 652 490 (write, then `emit`) | **0** |

  The event is 155 100, equal to 0.1.0's (1 657 450 − 1 502 350). Against 0.1.0's own code
  (`definition_new`), the store stays 4 960 cheaper under both choices.
- **Side effect: every `define` is 400 cheaper.** `bench_define_worst` is 2 583 280 (before
  2 583 680). Setups that define quests are 400 cheaper per definition.

### 4 (minor, cost): the budgets described as they are

- `GAS.md` (0.2.0 section, "Budgets") and `docs/BUDGETS.md` (its header) now say that a budget
  lies between the measured value and `ceil(1.05 × measured)`, which is what
  `scripts/gas.py --check` checks. It is set to `ceil(1.05 × measured)` when written, and a later
  measurement lower by under 5 % leaves it valid and tighter.
- After this loop, **34 of 510** budgets are tighter (for example `bench_held_slot_last`: 30 700
  measured, budget 31 458). None was raised to match the prose.
- The generated header of `GAS.md` still reads "`N = ceil(1.05 x measured)`": it is written by
  `scripts/gas.py` (`render`), outside my allowlist. See Escalations below.

### Cost after fix loop 1

Call = benchmark − baseline. "Before FL1" is this pull request before the loop (`469ff60`).

| Entrypoint or algorithm | Before FL1 | After | Budget (test) | Note |
|---|---|---|---|---|
| `define`, worst | 2 583 680 | 2 583 280 | 26 319 219 | −400: the event desnapped once |
| `progress_many`, worst, H = 4 / H = 8 | 6 205 843 / 11 416 073 | the same | 16 958 764 / 29 286 037 | the held list through the store: unchanged to the unit |
| `accept`, worst / `abandon`, worst | 1 917 170 / 564 150 | the same | 31 832 422 / 9 848 549 | unchanged to the unit |
| `retire`, `claim`, views, grid | as before | the same | — | unchanged to the unit |
| `QuestDefinition` `TrackNone`, store / hand (same model) | — | 1 497 390 / 1 497 390 | 1 930 110 / 1 930 110 | **0** |
| `QuestDefinition` `TrackAll`, store / hand (same model) | 1 652 890 / — | 1 652 490 / 1 652 490 | 2 092 965 / 2 092 965 | **0** |
| New tests (component `TrackNone`, rewrite, held list, prerequisites) | — | 6 752 172; 804 770; 3 063 990; 2 831 240; 3 939 460 | ceil(1.05 ×) | — |

**No budget was raised in this loop**; 202 budgets were set: the 9 new tests, and those that the
400 of `define` took out of the 5 % range, lowered. The three raises of the first pass stand,
with their notes. `scripts/gas.py packages/quest --check`: "510 tests within budget, GAS.md up to
date". `scarb fmt --check`: exit 0. `check-links`: 0 broken.

### Commands run (fix loop 1)

```
cd packages/quest && snforge test            → Tests: 510 passed, 0 failed, 0 ignored, 0 filtered out
snforge test set_model_definition            → store 1993700 / hand 1993300 (before the fix); 1993300 / 1993300 (after)
scripts/gas.py packages/quest --write        → wrote packages/quest/GAS.md (510 tests)
scripts/gas.py packages/quest --check        → 510 tests within budget, GAS.md up to date
scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check   → exit 0
python3 .github/ci/check-links.py            → 0 broken link(s)
gh pr checks 20 --watch --interval 30        → every check pass (runs 36566169212, 36566169330)
```

### Deviations (fix loop 1)

- The store's cross-slot methods are not `#[inline]`, unlike the one-model methods, so that their
  cost stays as it was in the component; the store's doc says so.
- `DefinedTrait::new` changed: point 3's fix, a saving of 400 per `define`.

### Escalations (fix loop 1)

- **The generated header of `GAS.md`** says the budget is `ceil(1.05 × measured)`. Describing it
  accurately needs a change to `scripts/gas.py` (`render`), a file outside my allowlist. The
  hand-written sections now say how budgets really stand.
