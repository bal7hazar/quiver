# Changelog

All notable changes to `quiver_quest` are recorded here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Changes to results, storage layout,
events and error strings are named.

## [Unreleased]

Nothing yet.

## [0.1.0] - not yet released

The first version: the API accepted at gate A-G1
([ARC-01 §3](../../docs/research/ARC-01-quest-achievement.md)).

### Added

- **Bounds** (`quiver_quest::constants`): `MAX_TASKS = 3` tasks per quest, `MAX_CONDITIONS = 7`
  prerequisites per quest, `QUESTS_PER_PAGE = 7` and `MAX_PAGES = 4` (28 live quests per task),
  `MAX_ENTRIES = 16` entries per `progress_many` call. **Not final**: the A-G1 amendment of
  2026-09-28 requires the worst call to stay under 20 M L2 gas, which these bounds do not meet
  (683 M measured). The caps of 0.1.0 and their definition-time refusals are pending a decision
  and will be recorded here before the release.
- **Library** `quiver_quest::logic`, pure, without storage (ARC-01 §3.2): the types `Mode`,
  `QuestSchedule`, `QuestTask`, `QuestDefinition`, `QuestTasks`, `QuestConditions`,
  `QuestIdPage`, `QuestProgress`, `QuestRecord`, `TaskProgress`; their packing into one felt each
  (`StorePacking<T, felt252>`, exported as `QuestDefinitionPacking`, `QuestTasksPacking`,
  `QuestConditionsPacking`, `QuestIdPagePacking`, `QuestProgressPacking`, `QuestRecordPacking`;
  layouts of §3.3, with the presence bits `defined` and `retired` of `QuestDefinition`); the
  functions `schedule_validate`, `schedule_is_active`, `schedule_interval_id`, `definition_new`,
  `tasks_index_of`, `tasks_span`, `conditions_span`, `batch_merge`, `batch_count_of`,
  `batch_first_position`, `progress_add`, `progress_is_complete`, `prerequisites_met`,
  `record_is_accepted`, `record_complete`, `record_accept`, `record_abandon`, `claim`,
  `page_push`, `page_span`, `page_position`, `page_set`, `page_pop`.
- **Errors** `quiver_quest::errors`, the strings of ARC-01 §3.5: `'Quest: invalid id'`,
  `'Quest: invalid tasks'`, `'Quest: invalid window'`, `'Quest: invalid interval'`,
  `'Quest: invalid condition'`, `'Quest: too many conditions'`, `'Quest: already defined'`,
  `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: has live dependents'`,
  `'Quest: too many dependents'`, `'Quest: invalid task'`, `'Quest: task full'`,
  `'Quest: too many entries'`, `'Quest: no accept step'`, `'Quest: not active'`,
  `'Quest: locked'`, `'Quest: already accepted'`, `'Quest: already completed'`,
  `'Quest: not accepted'`, `'Quest: not completed'`, `'Quest: already claimed'`,
  `'Quest: not reporter'`, `'Quest: not admin'`, `'Quest: not authorized'`. Packing also panics
  `'Packing: field out of range'` and `'Packing: reserved bits set'`, which the component never
  reaches.
- **Component** `quiver_quest::component::QuestComponent` (ARC-01 §3.3 to §3.7):
  - storage members `Quest_definitions`, `Quest_tasks`, `Quest_conditions`, `Quest_task_pages`,
    `Quest_progress`, `Quest_records`, `Quest_reporters`, each value one felt;
  - events `QuestDefined` (key `quest_id`), `QuestProgressed` (keys `player_id`, `task_id`),
    `QuestCompleted` and `QuestClaimed` (keys `player_id`, `quest_id`), `QuestRetired` (key
    `quest_id`), `QuestReporterSet` (key `reporter`);
  - the hooks trait `QuestHooksTrait`: `authorize_admin`, `authorize_player`,
    `on_quest_complete` (with `completions`), `on_quest_claim` (with `claim_index`);
  - the trusted internal layer `InternalImpl`: `define`, `retire`, `set_reporter`, `progress`,
    `progress_many`, `accept`, `abandon`, `claim`, `assert_reporter`, and the reads
    `definition`, `progress_of`, `record_of`, `current_interval`, `is_unlocked`,
    `is_accepted`;
  - the optional external impls `QuestImpl` (`IQuest`, access-checked) and `QuestViewImpl`
    (`IQuestView`);
  - `progress_many` skips a quest retired since its task's pages were read, for instance by a
    hook of an earlier quest in the same call: it counts nothing, completes nothing and calls no
    hook;
  - the prerequisites of a quest are read in order and the reading stops at the first one never
    completed (`progress_many`, `accept`, `quest_is_unlocked`): the same results with fewer
    reads for a locked quest.
- **Interfaces** `quiver_quest::interface`: `IQuest` (`define`, `retire`, `set_reporter`,
  `progress`, `progress_many`, `accept`, `abandon`, `claim`) and `IQuestView`
  (`quest_definition`, `quest_progress`, `quest_record`, `quest_current_interval`,
  `quest_is_unlocked`, `quest_is_accepted`, `quest_is_reporter`), with their dispatchers.
