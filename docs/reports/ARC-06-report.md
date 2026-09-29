# [Opus 5.5] ARC-06 — The pattern of CAIRO.md §7: model, storage, tracked event, store

## Summary

The pattern for a stored entity (D-143) now exists. It is decided, measured, and applied to one
model, the quest definition of `quiver_quest`. The session ran as Opus 5.5 (`claude-opus-5-5`),
the model the brief names.

**The mechanism.**

- A model is **tracked** when it implements `Tracked<M> { type Event; fn event(self: @M) ->
  Self::Event }`. This is decided at compile time; nothing is looked up at run time.
- The **store** is `StoreTrait`, implemented on the component's own `ComponentState`. Arcade's
  `Store` wraps a world; here the component's state is the handle to the storage, so nothing is
  built.
- `set_x` takes the model **by value** and writes it. For a tracked model only, it then emits
  `HasComponent::emit(ref self, Tracked::event(@model))`. `Tracked::event` does not compile for a
  model without the impl, so an untracked model cannot emit. An untracked `set_x` is the write
  alone.
- The store costs **exactly what the same code costs by hand**, to the unit of gas. This holds
  for untracked and tracked models, created and overwritten slots, and reads. A tracked `set` is
  an untracked `set` plus 45 020, which is the event.

**The quest definition.** It is **one model over the three slots of 0.1.0** (A, B, C), and the
layout is unchanged. It is tracked by `QuestDefined`, whose selector, keys and data are unchanged.
The status bits of slot A (`retired`, `live_dependents`) are not part of the model. Tracking them
would emit `QuestDefined` on `retire` and on every dependent's `define`, which 0.1.0 does not do.

**Package or convention.** It is a **convention**, not a package. The store is per component and
cannot be shared; the shareable part is a four-line trait; and a package would guarantee nothing
more. The reasons are in `docs/research/ARC-06-model-store.md` §3.

**The file the owner reads:** `packages/quest/src/models/definition.cairo`, with
`packages/quest/src/models/index.cairo`, `packages/quest/src/events/index.cairo`,
`packages/quest/src/events/defined.cairo` and `packages/quest/src/store.cairo`.

**Pull request:** https://github.com/bal7hazar/quiver/pull/19. CI is green; it is not merged.

## Files changed

- `packages/quest/src/models/definition.cairo`: new. It holds `DefinitionTrait` (`new`,
  `is_active`, `interval_id`), `DefinitionTracked`, `DefinitionStorage` (`into_slots`,
  `from_slots`), `DefinitionAssert`, `mod errors`, and the helpers `task_at` and `id_at`, whose
  reason is written.
- `packages/quest/src/models/index.cairo`: new. The struct `QuestDefinition { id, schedule, tasks,
  conditions }`.
- `packages/quest/src/events/index.cairo`: new. `QuestDefined`, moved from the component and
  unchanged.
- `packages/quest/src/events/defined.cairo`: new. `DefinedTrait::new(@definition)`.
- `packages/quest/src/store.cairo`: new. `Tracked<M>`, and `StoreTrait` on `ComponentState` with
  `get_definition`, `has_definition` and `set_definition`.
- `packages/quest/src/lib.cairo`: declares `store`, `models` and `events`.
- `packages/quest/src/component.cairo`:
  - `define` now uses `DefinitionTrait::new`, `has_definition` and `set_definition`; the
    prerequisites' slot A stays hand-written, as in 0.1.0.
  - `QuestDefined` is re-exported (`pub use`), so the path
    `QuestComponent::QuestDefined` is unchanged.
  - The import of `definition_new` is removed.
- `packages/quest/tests/mock_store.cairo`: new.
  - `ModelsComponent`, `MockModels`: the convention applied to one untracked and one tracked
    model, each with a hand-written twin.
  - `MockDefinitionStore`: the store set against 0.1.0's hand-written code.
- `packages/quest/tests/test_store.cairo`: new. The mechanism's behaviour and benchmarks.
- `packages/quest/tests/test_store_definition.cairo`: new. The definition store's behaviour and
  benchmarks.
- `packages/quest/tests/test_model_definition.cairo`: new. The model's checks, the oracles, the
  storage layout and the event.
- `packages/quest/tests/*.cairo` (existing): the budgets of the tests that got cheaper are lowered
  to `ceil(1.05 × measured)`. None was raised.
- `packages/quest/GAS.md`: regenerated with `scripts/gas.py --write` (470 tests). It gains a
  hand-written ARC-06 section, and the 0.1.0 cost-model section is re-attached unchanged.
- `packages/quest/CHANGELOG.md`: the change, under `Unreleased`. The version stays 0.1.0.
- `docs/research/ARC-06-model-store.md`: new (AC-1).
- `docs/BUDGETS.md`: a section for the store.

## Commands run

- `scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build`: `Finished`, with no
  warning.
- `cd packages/quest && snforge test` (final): `Tests: 470 passed, 0 failed, 0 ignored, 0
  filtered out`. Before the new tests there were 423, all passing.
- `scripts/gas.py packages/quest --write`, then `--check`: `quiver_quest: 470 tests within
  budget, GAS.md up to date`.
- `scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check`: no output, clean.
- `python3 .github/ci/check-links.py`: `check-links: 0 broken link(s)`. Before the commit it
  reported the new research file as missing, because the file was not yet tracked.
- `gh pr checks 19 --watch --interval 30`: affected, cairo, `package (packages/quest)`, links and
  scripts all `pass`.
- Experiments in a scratch package (`target/scratch06`, since deleted):
  - `#[inline(always)]` on a generic helper with impl generics was refused (E2143);
  - the component's `EventEmitter` is not found outside the component module (E2311);
  - `HasComponent::emit` works from outside the component;
  - `ComponentState` is not `Copy` (E3003);
  - a `Store` struct needs `unsafe_new_component_state` and an explicit type argument (E2314).
- Measured alternatives, recorded in the research doc §2.3:
  - passing the model to `set` by snapshot: +300 on every set;
  - removing `#[inline]`: every `define` test +15 700 to +455 300;
  - a presence check through `get_definition`: the revert paths +30 190 to +60 570;
  - `has_definition`: every path cheaper.

## Cost

All figures are L2 gas from snforge 0.61. A cost is the benchmark minus its baseline, both called
through a dispatcher.

| Entrypoint or algorithm | Before | After | Budget | Note |
|---|---|---|---|---|
| `set` untracked, created (`bench_store_set_untracked_created` − `baseline_models`) | 454 530 by hand | 454 530 | 771 530 (test) | store − hand = 0 |
| `set` untracked, overwritten (`bench_store_set_untracked_overwritten` − `baseline_models_existing`) | 52 530 by hand | 52 530 | 1 226 012 (test) | 0 |
| `set` tracked, created | 499 550 by hand | 499 550 | 818 801 (test) | 0; the event is 45 020 |
| `set` tracked, overwritten | 97 550 by hand | 97 550 | 1 273 283 (test) | 0; the event is 45 020 |
| `get` (`bench_store_get` − `baseline_models_existing`) | 32 590 by hand | 32 590 | 1 205 075 (test) | 0 |
| Quest definition write, 3 tasks and 7 conditions (`bench_store_set_definition_worst` − `baseline_definition`) | 1 657 450 (0.1.0 code) | 1 652 890 | 2 093 385 (test) | −4 560 |
| Quest definition read (`bench_store_get_definition_worst` − `baseline_definition_defined`) | 69 240 (0.1.0 code) | 69 210 | 2 338 424 (test) | −30 |
| `define`, worst (`bench_define_worst`) | 2 590 440 | 2 583 680 | 26 399 628 (test) | −6 760 |
| `progress_many`, worst, H = 4, created | 6 213 063 | 6 213 063 | 17 027 591 (test) | unchanged |
| `progress_many`, H = 4, existing | 2 997 063 | 2 997 063 | 17 186 456 (test) | unchanged |
| `progress_many`, H = 8, created | 11 430 213 | 11 430 213 | 29 387 120 (test) | unchanged |
| `progress_many`, H = 8, existing | 4 998 213 | 4 998 213 | 29 702 929 (test) | unchanged |
| `retire`, worst | 1 003 240 | 1 003 240 | 27 533 659 (test) | unchanged |

Every existing test is cheaper or unchanged compared with GAS.md at `21f3066`. For example,
`quest_define_rejects_invalid_input` went from 3 894 240 to 3 733 270, and
`quest_batch_bound_accepted` from 557 956 576 to 553 473 176. These are setup costs: the call
figures above are unchanged. No budget was raised; the budgets of the cheaper tests were lowered.

## Acceptance criteria

- **AC-1: met.** `docs/research/ARC-06-model-store.md` covers:
  - §1, the mechanism;
  - §2, the options, some tried and some measured;
  - §3, the choice of a convention and its reasons;
  - §4, the cost.
- **AC-2: met.**
  - `Tracked` is an impl, so tracking is known at compile time.
  - `store_untracked_set_emits_nothing` shows 0 events after 3 writes.
  - `store_tracked_set_emits_its_event_on_every_write` shows 4 writes (overwritten, created,
    changed, rewritten unchanged) give 4 events, with their keys and data.
  - `store_set_definition_emits_quest_defined_once` shows 1 event, with 0.1.0's keys and data.
  - `test_component_events` passes unchanged.
- **AC-3: met.** The table above and GAS.md: the store adds 0 in all five cases. The
  definition-level differences (−4 560 and −30) are in the store's favour. The explanation is
  that the model validates and builds its slots separately, where 0.1.0's `definition_new` does
  both in one pass.
- **AC-4: met.**
  - Files: `models/definition.cairo`, `models/index.cairo`, `events/index.cairo`,
    `events/defined.cairo`, `store.cairo`.
  - Scoped names: `DefinitionTrait::new`, `definition.is_active(time)`,
    `definition.interval_id(time)`, `DefinitionAssert`, `errors::DEFINITION_*`.
  - The only new free functions are `task_at` and `id_at` in `models/definition.cairo`. They read
    a span entry or return zero; no type owns them, and the reason is written above them.
- **AC-5: met.**
  - Every new test has a budget of `ceil(1.05 × measured)`.
  - `scripts/gas.py packages/quest --check` passes.
  - The worst calls are unchanged to the unit (table above).
  - No new package, so no second gas check.
- **AC-6: met.** PR #19 checks all pass.

## Deviations from the brief

- **The decision file D-143 was not read.** The command `git -C /home/claude/projects/grimworld
  show origin/main:docs/decisions/2026-09-29-code-organisation.md` was refused by the profile,
  and the `cd … && git show` form of the brief asked for approval. I worked from `docs/CAIRO.md`
  §7 and §8, which state the rule.
- **The model does not hold the whole of slot A.** The status (`retired`, `live_dependents`)
  stays out of the definition model, for the event reason given in the summary.
  - Because of this, `set_definition` writes the status of a new quest. It is documented to be
    called only for a quest that is not defined, and `define` checks this with `has_definition`.
  - The prerequisites' slot A is still read and written by hand in `define`, and `retire` is
    untouched. Both belong to ARC-07's status model.
- **The view `definition()` still reads its slots by hand.** It returns 0.1.0's slot A, status
  included. Going through `get_definition` would need a second read of A until the status model
  exists. I read "the reads of a definition go through the store" as covering `define`'s reads,
  which now go through the store (`has_definition`), and the model's own `get_definition`.
- **The presence check of `define` is `Store::has_definition`, which reads A.** It is not
  `get_definition(..).assert_does_not_exist()` as in arcade. The arcade form made the revert
  paths more expensive by 30 190 to 60 570. `DefinitionAssert::assert_does_exist` and
  `assert_does_not_exist` exist and are tested.
- **The model's `is_active`, `interval_id` and checks duplicate code in `src/logic/`.** The
  brief says the rest of the logic stays, so it is kept, and it serves as the tests' oracle.
  ARC-07 removes the duplicate.

## Escalations

- **The two tables of `docs/BUDGETS.md` for `quiver_quest`** still show `21f3066`'s "test
  measured" and "test budget", and `define`'s call as 2 590 440. The brief allowed only a line for
  the mechanism, so I added a section and did not rewrite those tables.
  - The call figures are unchanged, except `define`, which is now 2 583 680.
  - The test figures and budgets are now lower.
  - The orchestrator may refresh the tables from `packages/quest/GAS.md`.
- **The name `QuestDefinition` now names two public types:** the model
  (`quiver_quest::models::definition::QuestDefinition`) and slot A of 0.1.0
  (`quiver_quest::logic::QuestDefinition`, returned by the view). This is noted in the changelog.
  ARC-07 should rename slot A when it becomes the status model.

## Open questions

These are for ARC-07; the research doc §5 has the detail.

1. **The status model over slot A.** It could be read and written as the whole of A, with the
   definition's bits written back unchanged: 1 read and 1 write, as 0.1.0 does. The alternative
   writes the status bits only, which needs an extra read of A, about 30 000 per prerequisite. The
   first is recommended.
2. **Should `QuestRetired`, `QuestCompleted` and the other events stay events of actions**,
   emitted by the store without a model, as arcade's `store.complete` does? Or should some of
   them become model events? Under "emits on every write", a status tracked by `QuestRetired`
   would also emit on each dependent's `define`.
3. **Is a convention acceptable to the owner, or does the owner want `quiver_model`** (the
   `Tracked` trait and its tests) as a shared package anyway, for one name across repositories?

## Fix loop 1

This loop answers the audits of GPT-6-Sol (organisation) and GPT-6-Astra (cost), on the same
branch and pull request (#19). There are two commits:

- `852f546` (code and tests);
- `d258d3b` (write-up, `GAS.md`, `BUDGETS.md`, changelog).

CI is green: affected, cairo, `package (packages/quest)`, links and scripts all pass. The pull
request is not merged.

**Some figures earlier in this report are superseded.** The read figures in the Cost table
(`get` 32 590; definition read 69 240 and 69 210) are replaced by those below. The earlier
deviations about the view and the prerequisites' hand-written slot A no longer hold: point 1
routes them through the store.

### Point by point

1. **Every read of definition data now goes through the store (major, organisation).**
   - **New store methods**, in `packages/quest/src/store.cairo`, each named for what it returns:
     - `get_definition_head(id)`: slot A, with the schedule, the counts and the status, in one
       read;
     - `get_definition_tasks(id)`: slot B;
     - `get_definition_conditions(id, condition_count)`: slot C as ids, for a count that is not
       zero;
     - `set_definition_status(id, head)`: writes slot A with a changed status. It is untracked
       and emits nothing.
   - **The component reads and writes no definition slot by hand any more.** `define` (the
     prerequisites' status), `retire`, `accept`, `abandon`, `progress_many`, `held_is_live`,
     `prerequisites_are_met` and the views all go through these methods. The table is in
     `docs/research/ARC-06-model-store.md` §1.2.
   - **Costs did not move.** Every test of the package measures the same, to the unit, as at
     `0227486`. The one exception is a test I extended (point 3). So no worst call rose: they are
     listed under "Cost" below.
   - **A first version cost more, and I corrected it.** In that version:
     - `retire` iterated an empty span where 0.1.0 skipped C: +3 970 on the retire tests with no
       conditions;
     - a redundant zero-count branch in `get_definition_conditions` cost +100 to +200.

     Both checks now sit with the callers, as in 0.1.0.
   - **The status stays outside the definition model for ARC-06**, as allowed. The write-up
     (§1.3) says how ARC-07 models it: `QuestStatus`, untracked, sharing slot A with the
     definition. Slot A is read once per path, and written whole from the A that was read.
2. **An event field that is not stored (major, organisation).**
   - **The rule chosen:** a tracked model holds every field its event carries.
   - **For achievements:** `points` (u16) goes in the free bits [196, 212) of slot A.
   - **Its cost, measured here** on an equivalent model (a third u16 field in the free bits of a
     one-felt model): **+200** on a created `set`, which is 2 steps of packing. Achievement code
     is outside the allowlist, so the cost on its own `define` is left to ARC-07.
   - **When there are no free bits**, the event is an action event and the model is untracked.
     That is the general rule for any model whose event carries a field it does not store.
   - **Every model of both packages is reviewed** in research doc §6:
     - tracked: the quest definition, quest reporters, achievement reporters, and the
       achievement definition once `points` is stored;
     - untracked: the quest status, progress P, record R and the held list;
     - not a model: achievement progress.
3. **What the compiler enforces is now stated exactly (minor).**
   - Written in `store.cairo`'s doc comment and in research doc §1.2.
   - **The compiler enforces** one event type per tracked model, and that `Tracked::event`
     compiles only for a model with the impl.
   - **Convention and tests enforce** that a tracked setter emits, that it emits only once, and
     that an untracked setter makes no hand-written emit.
   - **Tests added:**
     - `store_set_definition_emits_quest_defined_once` now checks 1 event after one write and 2
       after two;
     - `store_status_write_emits_nothing_and_keeps_the_definition` covers the untracked status;
     - `store_focused_reads_return_the_slots` covers the new reads.
4. **`task_at` and `id_at` are now scoped (minor).** They became the methods `task_or_zero` and
   `id_or_zero` of a private trait (`SlotEntries`), used only by `DefinitionStorage::into_slots`.
   No free function is left in `models/definition.cairo`.
5. **The read benchmarks now use baselines of the same shape (minor, cost).**
   - The new baselines take an id in and return a value out, which the test asserts:
     `baseline_models_get` and `baseline_definition_read`.
   - `baseline_definition_defined` is removed.
   - **Corrected figures:** `get` is 29 420 by hand and through the store. A definition read is
     130 430 by hand and 130 400 through the store.
   - The hand-against-store comparison is unchanged: 0 and −30.
   - **Why the old figures were wrong:** the old definition baseline decoded the whole definition
     as calldata, so it was more expensive than the read's own call.

**The cost audit's notes for ARC-07** are recorded in research doc §5, point 5:

- keep the reads selective;
- read slot A once when the status model is added;
- keep model writes apart from action events: the prerequisites' counter and partial progress
  emit nothing, and tracking P or R must neither add events nor duplicate `QuestCompleted`.

### Commands run

- `cd packages/quest && snforge test`: the first run gave `Tests: 475 passed, 1 failed`. The
  failure was `store_set_definition_emits_quest_defined_once` running out of gas, because the
  test now makes a second write.
- The final run: `Tests: 476 passed, 0 failed, 0 ignored, 0 filtered out`. This count was taken
  before `baseline_definition_defined` was removed; `GAS.md` now lists 475 tests.
- **Gas against the table of `0227486`:** every test is identical except
  `store_set_definition_emits_quest_defined_once` (1 891 240 → 3 101 500). Its budget was raised
  from 1 985 802 to 3 256 575, with a `// gas: raised` note.
- `scripts/gas.py packages/quest --write`: wrote `GAS.md` with 475 tests. The hand-written
  sections were re-attached and updated.
- `scripts/gas.py packages/quest --check`: `quiver_quest: 475 tests within budget, GAS.md up to
  date`.
- `scarb build`: clean. `scarb fmt --check`: clean.
- `python3 .github/ci/check-links.py`: `0 broken link(s)`.
- `gh pr checks 19 --watch --interval 30`: all five checks pass.

### Cost

| Entrypoint or algorithm | Before (`0227486`) | After | Budget | Note |
|---|---|---|---|---|
| `define`, worst (`bench_define_worst`) | 2 583 680 | 2 583 680 | 26 399 628 (test) | unchanged |
| `retire`, worst | 1 003 240 | 1 003 240 | test unchanged | unchanged |
| `progress_many`, worst: H = 4 created / H = 4 existing / H = 8 created / H = 8 existing | 6 213 063 / 2 997 063 / 11 430 213 / 4 998 213 | the same | tests unchanged | unchanged |
| `accept`, `abandon`, views (`test_component_bench`) | as in `GAS.md` | the same | unchanged | unchanged, to the unit |
| `get`, hand and store | 32 590 (write-shaped baseline) | 29 420 | 1 205 075 (test) | baseline corrected; store − hand = 0 |
| Definition read, hand / store | 69 240 / 69 210 (write-shaped baseline) | 130 430 / 130 400 | 2 338 455 / 2 338 424 (tests) | baseline corrected; −30 |
| `set` with a third u16 field in free bits, created | — | 454 730 (two fields: 454 530) | 773 042 (test) | +200: the cost of storing `points` |

### Deviations

- **`set_definition_status` takes the whole slot-A struct**, in its `head` parameter, not a
  status struct. This keeps a status write at one read and one write until ARC-07 introduces
  `QuestStatus`. Its doc comment says the definition's fields must be passed back as they were
  read. The test `store_status_write_emits_nothing_and_keeps_the_definition` checks that B, C and
  the model are unchanged by it.
- **The view `quest_definition` reads through the focused methods**, not `get_definition`. It
  returns slot A with its status, and going through `get_definition` would read A twice.

### Escalations

- **The two `quiver_quest` tables of `docs/BUDGETS.md` still carry `21f3066`'s test figures.**
  This is unchanged from the first report, and is outside the allowlisted line. Only the ARC-06
  section of that file was updated.
