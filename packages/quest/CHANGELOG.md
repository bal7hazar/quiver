# Changelog

All notable changes to `quiver_quest` are recorded here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Changes to results, storage layout,
events and error strings are named.

## [Unreleased]

### Added
- Package skeleton with the `constants` module (the bounds of the API).
- `quiver_quest::logic`, the pure library of ARC-01 §3.2: the types `Mode`, `QuestSchedule`,
  `QuestTask`, `QuestDefinition`, `QuestTasks`, `QuestConditions`, `QuestIdPage`,
  `QuestProgress`, `QuestRecord`, `TaskProgress`; their packing into one felt each
  (`StorePacking<T, felt252>`, storage layouts of §3.3, with the presence bits `defined` and
  `retired` of `QuestDefinition`); the functions `schedule_validate`, `schedule_is_active`,
  `schedule_interval_id`, `definition_new`, `tasks_index_of`, `tasks_span`, `conditions_span`,
  `batch_merge`, `batch_count_of`, `batch_first_position`, `progress_add`,
  `progress_is_complete`, `prerequisites_met`, `record_is_accepted`, `record_complete`,
  `record_accept`, `record_abandon`, `claim`, `page_push`, `page_span`, `page_position`,
  `page_set`, `page_pop`.
- `quiver_quest::errors`: the error strings of ARC-01 §3.5, as constants.
- Packing panics `'Packing: field out of range'` on a `task_count` above 3, a `condition_count`
  above 7 or a page `len` above 7, and unpacking panics `'Packing: reserved bits set'` on a felt
  with a bit above the layout of §3.3 (or a page `len` above 7). Neither is an error of the API:
  the component never packs or reads such a value.
