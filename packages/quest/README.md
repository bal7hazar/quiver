# quiver_quest

Quests for Starknet games: tasks, intervals, prerequisites, claim. Pure Cairo and Starknet, no
Dojo.

**Not implemented yet.** Today the package holds only its bounds, in `quiver_quest::constants`
(`MAX_TASKS`, `MAX_CONDITIONS`, `QUESTS_PER_PAGE`, `MAX_PAGES`, `MAX_ENTRIES`). The logic and the
component are written by ARC-03. The accepted API is in
[ARC-01 §3](../../docs/research/ARC-01-quest-achievement.md).

## Library

`quiver_quest::logic` is the pure library, without storage: state in, state out
([ARC-01 §3.2](../../docs/research/ARC-01-quest-achievement.md)). It holds the types (`Mode`,
`QuestSchedule`, `QuestTask`, `QuestDefinition`, `QuestTasks`, `QuestConditions`, `QuestIdPage`,
`QuestProgress`, `QuestRecord`, `TaskProgress`), their packing into one felt each
(`StorePacking<T, felt252>`, layouts of §3.3), and the functions on schedules, definitions,
batches, progress, records, claims and pages. Error strings are in `quiver_quest::errors`.

Every loop is bounded: `batch_merge` by `MAX_ENTRIES` (checked first; at most `MAX_ENTRIES²`
comparisons when a task id repeats, one pass otherwise); the lookups of a merged batch
(`batch_count_of`, `batch_first_position`, `progress_add`) by `MAX_ENTRIES`; the condition checks
of `definition_new` by `MAX_CONDITIONS` (checked first); `prerequisites_met` by the one record per
condition the caller passes, `MAX_CONDITIONS`. Tasks and pages are unrolled, without loops. The
gas of every function on its worst case is in [GAS.md](GAS.md) (`test_bench`).
