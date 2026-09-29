# Changelog

All notable changes to `quiver_quest` are recorded here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Changes to results, storage layout,
events and error strings are named.

## [Unreleased]

Nothing yet.

## [0.1.0] - 2026-09-29

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
