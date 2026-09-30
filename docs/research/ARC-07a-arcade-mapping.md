# Arcade's quest models and events → `quiver_quest` 0.2.0

| | |
|---|---|
| Asked by | The owner's review of ARC-07a, D-167 (remark 1), 2026-09-30 |
| Written by | The orchestrator `[Opus 5.5]`, from [ARC-01 §1](ARC-01-quest-achievement.md#1-the-two-dojo-packages-as-they-are) (the Dojo package read line by line) and `packages/quest/` at `main` |
| Reference | `cartridge-gg/arcade` at `c53fadc`, `packages/quest/src/models/index.cairo`, `events/index.cairo` |

The reasons, abbreviated in the tables:

- **A-G1**: the API accepted at gate A-G1 (D-131, [decision](../decisions/2026-09-28-A-G1-api.md)),
  from the defects of ARC-01 §2 and its questions Q-1 to Q-20.
- **D-135**: the cost cap, the worst call under 20M L2 gas: a player holds at most 4 quests, and
  progress walks what the player holds, never what a task fans out to
  ([decision](../decisions/2026-09-28-quest-cost-cap.md)).
- **Native**: no Dojo world. Starknet storage is keyed slots of one packed felt, where a new slot
  costs about 453 500 L2 gas on Sepolia. Dojo stores every field as at least one felt and does not
  pack.
- **Indexer**: what an indexer reads from events or views, so the contract does not store or emit it.

## Models

| Arcade (Dojo) | `quiver_quest` 0.2.0 | Why |
|---|---|---|
| `QuestDefinition { id, start, end, duration, interval, tasks, conditions }` | `QuestDefinition { id, schedule, tasks, conditions }`, in slots A, B, C | **Kept**, packed (Native). Ids are `u32`, not short strings (A-G1, Q-1). Tasks are bounded to 3 and conditions to 7 (A-G1 §3.1) |
| — | `QuestStatus { id, defined, retired, live_dependents }`, sharing slot A | **New**. `retire` is the only change allowed after definition, and redefinition is refused (A-G1, Q-9, Q-14). `live_dependents` blocks retiring a quest that live quests name as a condition. The bits sit in A's free bits, which costs no slot (Native) |
| `QuestAdvancement { player, quest, task, interval → count, timestamp }`, one model per task | `QuestProgress { player_id, quest_id, interval_id, c0, c1, c2, completed, claimed }`, slot P | **Merged**: the three task counters and the state of the interval in one slot, which costs one slot per interval instead of up to three (Native, D-135) |
| `QuestCompletion { player, quest, interval → timestamp, unclaimed, lock_count }` | The `completed` and `claimed` bits of `QuestProgress`, and `QuestRecord` | **Split**. The state of one interval sits with its counters in P. A boolean replaces the `timestamp`, which the block of `QuestCompleted` gives (Indexer). `lock_count` is gone (next row) |
| — | `QuestRecord { player_id, quest_id, completions, claims, unlocked }`, slot R | **New**. Prerequisites mean "completed at least once, ever", checked at `accept` and cached in `unlocked`. This replaces the per-interval `lock_count` decremented by every completion of a prerequisite, which was ARC-01's defects D-2 to D-4 (A-G1, Q-5). The counters let a hook price a repeat (A-G1: no Arcade hook received a count) |
| `QuestAssociation { task_id → quests: Array }` | **Dropped**; replaced by `QuestHeldSlot` | Progress walked every quest of a task, with no bound, so a popular task made the worst call unbounded (D-135). Progress now walks the quests the player holds |
| — | `QuestHeldSlot { player_id, index, e0, e1, counter, kept }`, slot H | **New** (D-135). Acceptance is mandatory, and a player holds at most 4 quests. The list is the only thing progress walks |
| `QuestCondition { quest_id → dependents: Array }` | **Dropped** | It was the reverse index for the unlock fan-out. Unlocking is now lazy, at `accept` (A-G1, Q-5) |
| — (world writer permission) | `QuestReporter { reporter, allowed }` | **New**. Arcade had no access control beyond Dojo's namespace permission. The component checks reporters and uses two authorization hooks (A-G1 §3.6) |
| `QuestMetadata`, `QuestReward`, `Task.description` (ByteArray, JSON via `graffiti`) | **Dropped** | Names, descriptions, icons and rewards are presentation. Building JSON costs gas on every definition, and a git dependency cannot be published. The game keeps content in its own registry (A-G1 §3.9) |

## Events

| Arcade (Dojo) | `quiver_quest` 0.2.0 | Why |
|---|---|---|
| `QuestCreation { id, definition, metadata (JSON) }` | `QuestDefined { quest_id, schedule, tasks, conditions }` | **Kept without the metadata** (models row above). It is now the tracked model's event, emitted on each write when the consumer tracks the definition (D-147) |
| `QuestProgression { player, task, count, time }`, on every progress in both modes | `QuestProgressed { player_id, task_id, count }`, in `Mode::Event` only | In storage mode a view gives the same data, so an event on every call cost gas for nothing (A-G1, Q-6). `time` is dropped here and below, because the indexer has the block's timestamp (Indexer) |
| `QuestUnlocked { player, quest, interval, time }` | **Dropped** | It needed the unlock fan-out that caused D-2 to D-4. Availability is a view, `quest_is_unlocked` (A-G1, Q-5) |
| `QuestCompleted { player, quest, interval, time }` | `QuestCompleted { player_id, quest_id, interval_id }` | **Kept**, as an action event emitted once per completion |
| `QuestClaimed { player, quest, interval, time }` | `QuestClaimed { player_id, quest_id, interval_id }` | **Kept**, as an action event emitted once per claim |
| — | `QuestRetired { quest_id }` | **New**, with `retire` (A-G1, Q-9, Q-14) |
| — | `QuestReporterSet { reporter, allowed }` | **New**, with the reporter registry. It is the tracked model's event |

## Also dropped

- **Hooks**: `on_quest_unlock` is gone along with `QuestUnlocked`.
- **Model methods**: `update` and `nullify` are gone, because the components never called them.
- **Claims**: `are_completed` over one interval is gone, because it gave a misleading answer
  across intervals (D-14).
- **Definition mode**: `to_store` on `create` is gone, because definitions are always stored.

ARC-01 §3.9 gives each of these in full.
