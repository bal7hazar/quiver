# Changelog

All notable changes to `quiver_quest` are recorded here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Changes to results, storage layout,
events and error strings are named.

## [Unreleased]

### Changed

- The rule of the optional slot C (a quest with no condition has none) is written once, in the
  store (`get_definition_slots`), and the view `quest_definition` and `Store::get_definition` both
  use it (ARC-07d). **Results, events, error strings and storage layout are unchanged.** View cost,
  per call of `quest_definition` (L2 gas): +1 770 for a defined quest with no condition, +1 200 with
  seven conditions, lower for a quest not defined; `Store::get_definition` +1 140 (`GAS.md`).

### Tests

- A refusal is tested under `TrackNone`.

## [0.2.0] - 2026-10-02

Not yet released. The package organised as the owner's rule D-143 says (docs/CAIRO.md §7) and as
the owner's review of ARC-06 asks (D-147): no `logic`, every stored entity a model read and
written only through the store, and each tracked model's event optional for the consumer
(ARC-06, ARC-07a; [docs/research/ARC-06-model-store.md](https://github.com/bal7hazar/quiver/blob/main/docs/research/ARC-06-model-store.md)).
**Behaviour, events (selectors, keys, data), error strings and storage layouts are those of
0.1.0**; the ABI's inputs and outputs serialise as in 0.1.0. The **Cairo** paths and names change,
and the component's impls take a tracking choice: a consumer's code must be updated (below).

### Breaking: paths and names

- **`quiver_quest::logic` is removed.** Its items are now:

  | 0.1.0 | 0.2.0 |
  |---|---|
  | `logic::Mode` | `types::mode::Mode` |
  | `logic::QuestSchedule`, `schedule_validate`, `schedule_is_active`, `schedule_interval_id` | `types::schedule::QuestSchedule`, `ScheduleAssert::assert_valid`, `ScheduleTrait::is_active`, `ScheduleTrait::interval_id` |
  | `logic::QuestTask` | `types::task::QuestTask` |
  | `logic::TaskProgress`, `batch_merge`, `batch_count_of`, `batch_first_position` | `types::batch::TaskProgress`, `BatchTrait::merge`, `count_of`, `first_position` |
  | `logic::QuestHeld`, `HELD_EMPTY`, `held_position`, `held_contains`, `held_remove` | `types::held::QuestHeld`, `HELD_EMPTY`, `HeldTrait::position`, `contains`, `remove` |
  | `logic::QuestDefinition` (slot A) | `models::definition::HeadSlot` |
  | `logic::QuestTasks`, `QuestConditions`, `tasks_span`, `tasks_index_of`, `conditions_span` | `models::definition::TasksSlot`, `ConditionsSlot`, `TasksSlotTrait::tasks`, `index_of`, `ConditionsSlotTrait::ids` |
  | `logic::definition_new` | `models::definition::DefinitionTrait::new`, then `into_slots` |
  | `logic::QuestProgress`, `progress_add`, `progress_is_complete` | `models::progress::ProgressSlot`; the model `QuestProgress`: `ProgressTrait::add`, `is_complete` |
  | `logic::QuestRecord`, `record_complete`, `prerequisites_met` | `models::record::RecordSlot`; the model `QuestRecord`: `RecordTrait::complete`, `all_completed` |
  | `logic::claim` | `ProgressTrait::claim`, then `RecordTrait::claim` |
  | `logic::QuestHeldSlot`, `held_slot` | `models::held::HeldSlot`; the model `QuestHeldSlot`: `HeldSlotTrait::new` |
  | `logic::QuestDefinitionPacking`, `QuestTasksPacking`, `QuestConditionsPacking`, `QuestProgressPacking`, `QuestRecordPacking`, `QuestHeldSlotPacking` | `HeadPacking`, `TasksPacking`, `ConditionsPacking`, `ProgressPacking`, `RecordPacking`, `HeldPacking` |
  | `logic::MAX_*`, `HELD_SLOTS`, `HELD_INTERVAL_LIMIT`, `ACCEPTANCE_LIMIT` | `constants::` (as in 0.1.0) |

- **`QuestProgress`, `QuestRecord` and `QuestHeldSlot` are now models**, with their keys first;
  `QuestDefinition` is the model only. The views and the internal reads return the slots under
  their new names: `quest_definition` → `(HeadSlot, Span<QuestTask>, Span<u32>)`,
  `quest_progress` → `ProgressSlot`, `quest_record` → `RecordSlot`. Their serialisation is 0.1.0's.
- **The component's impls take the tracking choice.** `InternalImpl`, `QuestImpl` and
  `QuestViewImpl` have a second impl parameter, `impl Tracking: QuestTracking<TContractState>`. A
  consumer adds one line to its contract, `impl QuestTracking =
  quiver_quest::store::tracking::TrackAll<ContractState>;` for 0.1.0's events.
- The event structs are declared in `quiver_quest::events` (one file each, `events::index`); they
  are still exported from `quiver_quest::component::QuestComponent`, with the same selectors.

### Added

- **Optional tracking** (D-147). `quiver_quest::store::QuestTracking<TContractState>`, one
  constant per tracked model (`DEFINITION`, `REPORTER`), and its ready choices
  `store::tracking::TrackAll` (every tracked model emits, as 0.1.0) and `TrackNone`. Under
  `TrackNone`, `define` does not emit `QuestDefined` and `set_reporter` does not emit
  `QuestReporterSet`; the action events (`QuestProgressed`, `QuestCompleted`, `QuestClaimed`,
  `QuestRetired`) are emitted whatever the choice. The compiler folds the constant: an untracked
  write costs exactly the write with no event code, a tracked one the write plus the event
  (measured to the unit, `GAS.md`).
- **Models** (`quiver_quest::models`, structs in `models::index`): `QuestDefinition` (tracked, slots
  A, B, C), `QuestStatus` (untracked, the status bits of slot A, shared with the definition),
  `QuestProgress` (P), `QuestRecord` (R), `QuestHeldSlot` (H), all untracked, and `QuestReporter`
  (tracked). Each with its behaviour, checks, `errors` (the strings of `quiver_quest::errors`) and
  storage.
- **The store** (`quiver_quest::store`, `StoreTrait` on the component's state): `Tracked<M>`;
  `get_definition`, `has_definition`, `get_definition_head` (A), `get_definition_tasks` (B),
  `get_definition_conditions` (C), `set_definition`; `get_status`, `set_status(status, head)`;
  `get_progress`, `set_progress`; `get_record`, `set_record`; `get_held_slot`, `set_held_slot`;
  `get_reporter`, `set_reporter`. The component reads and writes storage only through it.
- `quiver_quest::types` (`mode`, `schedule`, `task`, `batch`, `held`) and `quiver_quest::helpers::bits`.

### Changed

- Every entrypoint reads and writes the same slots, in the same order, with the same checks and
  events (under `TrackAll`) as 0.1.0. Slot A is read once per path, and the status is written as
  the whole of A, from the A that was read.
- **Built with Scarb 2.20.1** (Cairo 2.20.0, `snforge_std` 0.64.0; D-180, ARC-10). Behaviour, events
  and layouts are unchanged. **Costs rise on this toolchain: a storage write costs 15 000 L2 gas
  more and a read 6 000 more** (snforge 0.64: a created slot 474 106, was 459 106; an overwritten
  one 72 106, was 57 106). Re-measured, every worst call is **under the 20 M cap**: `progress_many`
  at `MAX_HELD` = 4, created, hooks empty: 6 460 843 (32 %); with a hook writing one slot 8 335 763
  (42 %); at 8 held 11 917 073 and 15 666 913 (60 % and 78 %); `accept` 2 061 170, `abandon`
  621 030, `claim` 404 920, `define` (3 tasks, 7 conditions) 2 779 560, `retire` 1 175 940; Grim
  World's use 4 801 186 (24 %). The figures of the bullet below are the ones measured on Scarb
  2.19.4. 30 test budgets were raised for the toolchain (`// gas: raised, D-180 Scarb 2.20.1`).
- **Costs on Scarb 2.19.4.** No worst call is raised: `progress_many` is 7 220 L2 gas cheaper at `MAX_HELD` = 4
  (6 205 843) and 14 140 at 8 held; `accept` 4 370 (1 917 170), `abandon` 9 910 (564 150);
  `define` is 2 583 280 (2 590 440 in 0.1.0); `set_reporter` is unchanged, `retire` 300 more. The
  largest rise is the view `quest_is_unlocked`, +4 300 (0.9 %). Detail in `GAS.md`.

## [0.1.0] - 2026-09-29

Published on [scarbs.xyz](https://scarbs.xyz/packages/quiver_quest) from commit `364462f`
(sha256 `494228f198376611f338d75a4c8511cd02eec1bc8ee666c4bd6c7973eeb4379c`); tag `quiver_quest-v0.1.0`.

The first version: the API accepted at gate A-G1
([ARC-01 §3](https://github.com/bal7hazar/quiver/blob/main/docs/research/ARC-01-quest-achievement.md)), amended by D-135 (every quest is
accepted before it progresses; a player holds at most 4 quests; progress walks them).

### Added

- **Bounds** (`quiver_quest::constants`):
  - `MAX_TASKS = 3` tasks per quest;
  - `MAX_CONDITIONS = 7` prerequisites per quest;
  - `MAX_ENTRIES = 16` entries per `progress_many` call;
  - `MAX_HELD = 4` quests a player holds at once;
  - `MAX_HELD_LIMIT = 8` and `HELD_SLOTS = 4`: the held list's layout, and the bound of its walk.

  The worst call the package allows, with the player's slots created, is measured at 6.3 M L2
  gas at `MAX_HELD = 4` and 11.7 M at 8 (8.1 M and 15.3 M with a completion hook writing one new
  slot); with the slots existing, 3.1 M and 5.2 M. All are under the 20 M of the A-G1
  amendment. Any number of quests may use a task.
- **Library** `quiver_quest::logic`, pure, without storage (ARC-01 §3.2):
  - the types `Mode`, `QuestSchedule`, `QuestTask`, `QuestDefinition`, `QuestTasks`,
    `QuestConditions`, `QuestProgress`, `QuestRecord`, `QuestHeld`, `QuestHeldSlot`,
    `TaskProgress`;
  - their packing into one felt each (`StorePacking<T, felt252>`), exported as
    `QuestDefinitionPacking`, `QuestTasksPacking`, `QuestConditionsPacking`,
    `QuestProgressPacking`, `QuestRecordPacking`, `QuestHeldSlotPacking`. The layouts are those of
    §3.3, with the presence bits `defined` and `retired` of `QuestDefinition`;
  - the functions `schedule_validate`, `schedule_is_active`, `schedule_interval_id`,
    `definition_new`, `tasks_index_of`, `tasks_span`, `conditions_span`, `batch_merge`,
    `batch_count_of`, `batch_first_position`, `progress_add`, `progress_is_complete`,
    `prerequisites_met`, `record_complete`, `claim`, `held_position`, `held_contains`,
    `held_remove`, `held_slot`, and the constant `HELD_EMPTY`.
- **Errors** `quiver_quest::errors`, the strings of ARC-01 §3.5:
  - `'Quest: invalid id'`, `'Quest: invalid tasks'`, `'Quest: invalid window'`,
    `'Quest: invalid interval'`, `'Quest: invalid condition'`, `'Quest: too many conditions'`;
  - `'Quest: already defined'`, `'Quest: does not exist'`, `'Quest: retired'`,
    `'Quest: has live dependents'`, `'Quest: too many dependents'`;
  - `'Quest: invalid task'`, `'Quest: too many entries'`;
  - `'Quest: too many held'`, `'Quest: not active'`, `'Quest: locked'`,
    `'Quest: already accepted'`, `'Quest: already completed'`, `'Quest: not accepted'`;
  - `'Quest: not completed'`, `'Quest: already claimed'`;
  - `'Quest: not reporter'`, `'Quest: not admin'`, `'Quest: not authorized'`.

  Packing also panics `'Packing: field out of range'` and `'Packing: reserved bits set'`, which
  the component never reaches.
- **Component** `quiver_quest::component::QuestComponent` (ARC-01 §3.3 to §3.7):
  - storage members `Quest_definitions`, `Quest_tasks`, `Quest_conditions`, `Quest_progress`,
    `Quest_records`, `Quest_held` (the held list, key `(player_id, slot)`), `Quest_reporters`,
    each value one felt;
  - events:
    - `QuestDefined` (key `quest_id`; data: schedule, tasks, conditions);
    - `QuestProgressed` (keys `player_id`, `task_id`);
    - `QuestCompleted` and `QuestClaimed` (keys `player_id`, `quest_id`);
    - `QuestRetired` (key `quest_id`);
    - `QuestReporterSet` (key `reporter`);
  - the hooks trait `QuestHooksTrait`: `authorize_admin`, `authorize_player`,
    `on_quest_complete` (with `completions`), `on_quest_claim` (with `claim_index`);
  - the trusted internal layer `InternalImpl`: `define`, `retire`, `set_reporter`, `progress`,
    `progress_many`, `accept`, `abandon`, `claim`, `assert_reporter`, and the reads
    `definition`, `progress_of`, `record_of`, `current_interval`, `is_unlocked`,
    `is_accepted`, `held_of`;
  - the optional external impls `QuestImpl` (`IQuest`, access-checked) and `QuestViewImpl`
    (`IQuestView`).
- **Acceptance is required for every quest.**
  - `accept` checks the schedule, retirement and prerequisites (and caches the unlock), refuses
    an interval already completed and a full list (`'Quest: too many held'`), prunes the list's
    dead entries (completed, expired at rollover, retired), and appends the quest.
  - `abandon` removes the quest from the list.
  - An acceptance ends at completion, abandon, retirement or rollover.
- **`progress_many` walks the player's held list**, in the order of acceptance, and reads no
  prerequisite; the quests a player does not hold are not read. It never writes the list.
  - It skips a held quest retired since the call started, for instance by a hook of an earlier
    quest in the same call: it counts nothing, completes nothing and calls no hook.
  - It skips a quest a hook abandoned, and does not progress a quest a hook accepted, even one
    the hook abandoned and accepted again in the same interval: each held entry carries the
    player's acceptance number (`QuestHeld::acceptance`), from a counter kept in slot 0 of the
    list (`QuestHeldSlot::counter`), and the call compares whole entries. The number and the
    counter have 30 bits (the counter wraps to 0 after 2^30 − 1, about 1.07 × 10⁹ acceptances by
    one player); a held entry stores its interval id on 48 bits (`HELD_INTERVAL_LIMIT`), and
    `accept` refuses an interval id at or above 2^48 as not active. The slot layout is
    `e0` [0, 110), `counter` [110, 140), `e1` [140, 250), `kept` [250]. Constants
    `HELD_INTERVAL_LIMIT` and `ACCEPTANCE_LIMIT`.
  - A slot of the held list is never zeroed: `QuestHeldSlot::kept` [250] is set once the slot
    has held an entry, so the list growing back into it overwrites the slot instead of creating
    it.
- The prerequisites of a quest are read in order, and the reading stops at the first one never
  completed (`accept`, `quest_is_unlocked`). The results are the same, with fewer reads for a
  locked quest.
- **Interfaces** `quiver_quest::interface`, with their dispatchers:
  - `IQuest`: `define`, `retire`, `set_reporter`, `progress`, `progress_many`, `accept`,
    `abandon`, `claim`;
  - `IQuestView`: `quest_definition`, `quest_progress`, `quest_record`,
    `quest_current_interval`, `quest_is_unlocked`, `quest_is_accepted`, `quest_held`,
    `quest_is_reporter`.

### Changed before the release (D-135, from the API accepted at A-G1)

These change the API of the unreleased 0.1.0 and are recorded for the readers of ARC-01 and of
earlier drafts of this changelog:

- `define`, `definition_new`, `IQuest::define` and `QuestDefined` lose `needs_accept`. Every quest
  needs acceptance, and `'Quest: no accept step'` is removed.
- `QuestDefinition` loses `needs_accept`. Its layout is now `defined` [197], `retired` [198] and
  `live_dependents` [199, 215).
- `QuestRecord` loses `active` and `accepted_interval`, since the held list holds acceptance. Its
  layout is `completions` [0, 64), `claims` [64, 128), `unlocked` [128].
- The functions `record_is_accepted`, `record_accept` and `record_abandon` are removed.
- The task pages are removed: `Quest_task_pages`, `QuestIdPage`, `QuestIdPagePacking`,
  `page_push`, `page_span`, `page_position`, `page_set`, `page_pop`, `QUESTS_PER_PAGE`,
  `MAX_PAGES` and `'Quest: task full'`. `define` and `retire` no longer touch tasks.
- Added: `MAX_HELD`, `MAX_HELD_LIMIT`, `HELD_SLOTS`, `QuestHeld`, `QuestHeldSlot`, the held-list
  functions, `Quest_held`, `'Quest: too many held'`, `held_of` and `quest_held`.
