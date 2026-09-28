# ARC-01 — `quest` and `achievement`: analysis, and the API of `quiver_quest` and `quiver_achievement`

| | |
|---|---|
| Task | ARC-01 ([brief](../briefs/ARC-01-quest-achievement.md)) |
| Written by | `[Opus 5.5]`, profile `research`, 2026-09-28 |
| Reference | `cartridge-gg/arcade` at `c53fadc` (2026-07-22), `packages/quest/` and `packages/achievement/` |
| Game documents | `bal7hazar/grimworld` at `e8a6a72`: ADR-0004, ADR-0007, `docs/needs/arcade.md`, design/06, 13, 14, `docs/briefs/ORCH-quiver.md`, PLAN § Track ARC |
| Readers | The owner, deciding at gate A-G1; the implementers of ARC-02, ARC-03 and ARC-04 |

**Method.** Everything said here about the Dojo packages comes from **reading the source**.
Nothing was built or run. A citation `quest/src/component.cairo:224` means
`ref/arcade/packages/quest/src/component.cairo`, line 224, at `c53fadc`. Costs are
**estimates from the layouts**, labelled as such; the measurements come with ARC-03 and ARC-04.

**Summary for the gate.**

- ADR-0004 points 3 and 4 are **all confirmed** in the source: event mode is never tested,
  unlocks fire on every decrement, an inactive dependent reverts the prerequisite's progress
  call, and a recurring prerequisite underflows a one-off dependent's lock counter. Reading
  also found **ten further findings**, D-5 to D-14 (§2). Point 5 is about `social` and is out of scope.
- The proposed native API (§3) keeps the concepts (tasks with a target, windows, intervals,
  AND prerequisites, completion, claim, hooks, a mode per call). It changes four things:
  - **Prerequisites are evaluated lazily.** A dependent is unlocked when each prerequisite
    has been completed at least once. Nothing is pushed to dependents when a prerequisite
    completes. This removes three of the four ADR-0004 defects by construction.
  - **Identifiers are `u32` and every record is packed** into one storage slot.
  - There is an **optional accept step**.
  - **Access control is built in**: a registry of reporters, plus two authorization hooks.
- Both names, `quiver_quest` and `quiver_achievement`, are **free on scarbs.xyz** today
  (§6.5).
- Seventeen open questions for A-G1 are listed in §7, each with a recommendation.

---

## 1. The two Dojo packages as they are

### 1.1 Layout of each package

Both packages share one layout: `src/component.cairo` (a Starknet component with empty
storage and events), `src/store.cairo` (a wrapper over the Dojo world), `src/models/` (Dojo
models and their logic), `src/events/` (Dojo events), `src/types/` (task, metadata, reward)
and `src/tests/` (a Dojo contract, a world setup, component tests). Sources:
`quest/src/lib.cairo:1-33` and `achievement/src/lib.cairo:1-31`.

The component holds **no state of its own**. `Storage {}` and `Event {}` are empty
(`quest/src/component.cairo:24-31`, `achievement/src/component.cairo:24-31`). Every function
takes a `WorldStorage` argument and reads and writes models through the world.

### 1.2 Data model of `quest`

All models are in `quest/src/models/index.cairo`. Dojo stores each model as its serialized
felts. **Nothing is packed.** Each field is at least one felt, and `ByteArray` and `Span`
fields are several.

| Model | Keys | Fields (type) | Cited |
|---|---|---|---|
| `QuestDefinition` | `id: felt252` | `start: u64`, `end: u64`, `duration: u64`, `interval: u64`, `tasks: Span<Task>`, `conditions: Span<felt252>` | `models/index.cairo:7-18` |
| `QuestCompletion` | `player_id: felt252`, `quest_id: felt252`, `interval_id: u64` | `timestamp: u64` (0 = not completed), `unclaimed: bool`, `lock_count: u32` | `models/index.cairo:20-32` |
| `QuestAdvancement` | `player_id`, `quest_id`, `task_id: felt252`, `interval_id: u64` | `count: u128`, `timestamp: u64` (0 = task not completed) | `models/index.cairo:34-47` |
| `QuestAssociation` | `task_id: felt252` | `quests: Array<felt252>`: the quests using this task | `models/index.cairo:49-55` |
| `QuestCondition` | `quest_id: felt252` | `quests: Array<felt252>`: the quests that **depend on** this one (reverse index) | `models/index.cairo:57-63` |

Types:

- `Task { id: felt252, total: u128, description: ByteArray }` (`quest/src/types/task.cairo:3-8`).
  `id != 0`, `total > 0` and a non-empty description are checked by `TaskTrait::new`
  (`task.cairo:23-30`).
- `QuestMetadata { name, description, icon: ByteArray, registry: ContractAddress, rewards: Span<QuestReward> }`
  (`quest/src/types/metadata.cairo:10-16`) is serialized to JSON with the `graffiti` library
  (`metadata.cairo:53`) and emitted only.
- `QuestReward { name, description, icon: ByteArray }` (`quest/src/types/reward.cairo:8-12`).

The state of a completion is read from its fields:

- **Undefined**: `timestamp == 0 && !unclaimed` (`models/completion.cairo:44-46`), which is
  the zero value of the model.
- **Completed**: `timestamp != 0` (`completion.cairo:34-36`).
- **Unlocked**: `lock_count == 0` (`completion.cairo:39-41`).

A new completion starts with `unclaimed = true` and `lock_count = conditions.len()`
(`completion.cairo:16-31`, `store.cairo:49-58`).

### 1.3 Data model of `achievement`

All models are in `achievement/src/models/index.cairo`. Like `quest`, nothing is packed.

| Model | Keys | Fields | Cited |
|---|---|---|---|
| `AchievementDefinition` | `id: felt252` | `start: u64`, `end: u64`, `tasks: Span<Task>` | `models/index.cairo:7-15` |
| `AchievementCompletion` | `player_id`, `achievement_id: felt252` | `timestamp: u64`, `unclaimed: bool` | `models/index.cairo:17-26` |
| `AchievementAdvancement` | `player_id`, `achievement_id`, `task_id: felt252` | `count: u128`, `timestamp: u64` | `models/index.cairo:28-39` |
| `AchievementAssociation` | `task_id: felt252` | `achievements: Array<felt252>` | `models/index.cairo:41-47` |

`Task` is identical to the quest's (`achievement/src/types/task.cairo:3-8`).

`AchievementMetadata` is `{ title: felt252, description: ByteArray, icon: felt252, points: u16, hidden: bool, index: u8, group: felt252, rewards: Span<AchievementReward>, data: ByteArray }`
(`achievement/src/types/metadata.cairo:9-19`), with `points <= 100` (`metadata.cairo:95`).

Achievements have **no intervals and no prerequisites**. **Tiers** are not a concept of the
package. A tier is a separate achievement that uses the same `task_id` with a different
`total`: the association lists every achievement that uses a task
(`achievement/src/component.cairo:131-135`).

### 1.4 Storage and event modes, call by call

`to_store: bool` is an argument of `create` and of `progress`. `claim` has no mode.

| Call | `to_store = false` (event mode) | `to_store = true` (storage mode) | Cited |
|---|---|---|---|
| quest `create` | Validates the definition and emits `QuestCreation` (definition and JSON metadata), then returns | Also writes `QuestDefinition`, inserts the quest in each task's `QuestAssociation` and in each condition's `QuestCondition` | `quest/src/component.cairo:145-184` |
| quest `progress` | Emits `QuestProgression { player_id, task_id, count, time }` and returns: **no read, no write, no hook** | Emits the same event, **then** updates advancements, completions, unlocks and hooks (§1.6) | `quest/src/component.cairo:204-273` |
| quest `claim` | — | Always reads storage. After event-mode creation or progress it reverts: no definition (`'Quest: does not exist'`) or not completed | `quest/src/component.cairo:276-309` |
| achievement `create` | Emits `TrophyCreation` (all metadata fields except `rewards`) and returns | Also writes `AchievementDefinition` and the associations | `achievement/src/component.cairo:101-136` |
| achievement `progress` | Emits `TrophyProgression` and returns | Emits, then updates (§1.6) | `achievement/src/component.cairo:156-219` |
| achievement `claim` | — | Always reads storage | `achievement/src/component.cairo:229-259` |

In event mode, a contract **cannot read anything back**. `is_completed` returns false
(`quest/src/component.cairo:71-81`), a claim reverts, hooks do not fire, and prerequisites
and windows are not enforced. The indexer (Torii plus Cartridge's controller in the
original) recomputes everything from `*Progression` events and the creation event. This
matches ADR-0004 § What exists.

### 1.5 Intervals (quest only)

The schedule is `start`, `end`, `duration` and `interval`, all `u64` seconds.

- **Validity** (`quest/src/models/definition.cairo:106-117`): `end > start || end == 0`, and
  `duration` and `interval` are both zero or both non-zero. The second check is written
  `(duration + interval) == 0 || (interval * duration) != 0`, a `u64` product that can
  overflow. `duration > interval` is accepted.
- **Active** (`definition.cairo:72-80`): `start <= time`, and `time < end` unless `end == 0`,
  and `(time - start) % interval < duration` when `interval != 0`.
- **Interval id** (`definition.cairo:83-91`): `(time - start) / interval`, or `0` for a
  one-off quest. It **asserts** that the quest is active (`'Quest: not active'`,
  `definition.cairo:85`), which is the source of defect D-3.
- **"Aligned".** Intervals are aligned on **`start`**, not on a calendar. A daily quest
  (`interval = duration = 86 400`) rolls over at 00:00 UTC only if `start` is a multiple of
  86 400: `start = 0`, the Unix epoch, is 1970-01-01 00:00 UTC. ADR-0004's mapping ("aligned
  on UTC midnight") holds under that condition, which the package does not check.
- `quest/docs/cases.md:21-43` lists the 8 valid combinations. `definition.cairo:204-511`
  tests `is_active` and `compute_interval_id` for each.

`achievement` has only a window, with its own rule: `(time >= start || start == 0) && (time < end || end == 0)`
(`achievement/src/models/definition.cairo:26-28`).

### 1.6 Progress, completion and prerequisites (storage mode)

**Quest `progress(player_id, task_id, count)`** (`quest/src/component.cairo:196-274`):

1. Reads `QuestAssociation(task_id)` (`:215`).
2. First pass (`:218-229`). For each associated quest: read the definition, skip it if it is
   inactive, then read or create the player's completion for the current interval
   (`get_completion_or_new`, `store.cairo:49-58`). Skip it if it is locked or already
   completed.
3. Second pass, for each kept quest (`:231-273`):
   - Read `QuestAdvancement(player, quest, task, interval)`, add `count`, and set its
     `timestamp` if `count >= total` (`advancement.cairo:49-57`). Write it (`:238`).
   - If this task is done, **read the advancement of every task of the quest** (`:244-250`).
   - If all tasks are done: read the completion again, set `timestamp = time`, write it
     (`:255-257`), call `on_quest_complete` (`:259`) and emit `QuestCompleted` (`:260`).
   - **Unlock**: read `QuestCondition(quest_id)`. For each dependent: read its definition,
     compute **its** interval id (asserting that it is active), read or create its
     completion, `lock_count -= 1`, write it, call `on_quest_unlock` and emit
     `QuestUnlocked` (`:262-272`). None of this checks whether `lock_count` reached zero.

**How prerequisites are counted.** A dependent's completion starts with
`lock_count = conditions.len()`. It is created lazily, the first time anything reads it with
`get_completion_or_new`. Each completion of a prerequisite, **in any interval of that
prerequisite**, subtracts one from the dependent's completion **for the dependent's current
interval**. The logic is AND only (`quest/docs/conditions.md:32`). Cycles are not prevented
(`conditions.md:35`).

**Achievement `progress`** (`achievement/src/component.cairo:148-219`) does the same without
intervals or unlocks. For each associated, active, uncompleted achievement it:

- adds to the advancement and writes it (`:185-188`);
- **writes the completion even when it did not change** (`:192`, `:205`);
- when every task is done, completes, writes, calls `on_completion` and emits
  `AchievementCompleted` (`:209-217`).

### 1.7 Claim

Quest `claim(player_id, quest_id, interval_id)` (`quest/src/component.cairo:276-309`):

1. Asserts that the definition exists, that the completion is completed and that it is not
   claimed (`:287-295`).
2. Sets `unclaimed = false` and writes (`:298-299`).
3. Calls `on_quest_claim` (`:301`) and emits `QuestClaimed` (`:305-308`).

Any past interval can be claimed: nothing checks that `interval_id` is current. Achievement
`claim` is the same without an interval (`achievement/src/component.cairo:229-259`).

**Nobody is checked**: the component does not see a caller. The test contracts expose
`create`, `progress` and `claim` to anyone (`quest/src/tests/contract.cairo:119-162`,
`achievement/src/tests/contract.cairo:14-37`). The only permission in play is Dojo's writer
permission on the namespace (`quest/src/tests/setup.cairo:51-52`).

### 1.8 Hooks

| Package | Hook | Fires | Arguments | Cited |
|---|---|---|---|---|
| quest | `on_quest_unlock` | On **every** decrement of a dependent's lock counter (defect D-2) | `player_id, quest_id, interval_id: u64` | `component.cairo:34-39`, `:270` |
| quest | `on_quest_complete` | Once per completion, after the completion is written | same | `:40-45`, `:259` |
| quest | `on_quest_claim` | On claim, after the claim is written | same | `:46-51`, `:301` |
| achievement | `on_completion` | Once per completion | `player_id, achievement_id` | `achievement/src/component.cairo:36-38`, `:214` |
| achievement | `on_claim` | On claim | same | `:39-41`, `:254` |

The hooks take `ref self: ComponentState<TContractState>`. The consumer reaches its own state
with `get_contract_mut()` (`quest/src/tests/contract.cairo:87-88`). **No hook receives a
completion count**, so a reward that diminishes on repeat cannot be computed from the hook's
arguments.

### 1.9 Events

| Event (Dojo) | Keys | Data | Emitted | Cited |
|---|---|---|---|---|
| `QuestCreation` | `id` | `definition: QuestDefinition`, `metadata: ByteArray` (JSON) | Every create | `quest/src/events/index.cairo:5-12` |
| `QuestProgression` | `player_id`, `task_id` | `count: u128`, `time: u64` | **Every progress, both modes** | `:14-23` |
| `QuestUnlocked` | `player_id`, `quest_id`, `interval_id` | `time` | Every decrement | `:25-35` |
| `QuestCompleted` | same | `time` | Completion | `:37-47` |
| `QuestClaimed` | same | `time` | Claim | `:49-59` |
| `TrophyCreation` | `id` | `hidden, index: u8, points: u16, start, end, group, icon, title: felt252, description: ByteArray, tasks: Span<Task>, data: ByteArray` | Every create | `achievement/src/events/index.cairo:7-23` |
| `TrophyProgression` | `player_id`, `task_id` | `count: u128`, `time: u64` | Every progress, both modes | `:25-34` |
| `AchievementCompleted` | `player_id`, `achievement_id` | `time` | Completion | `:36-44` |
| `AchievementClaimed` | same | `time` | Claim | `:46-54` |

### 1.10 Every dependency on Dojo, and what replaces it

| Dependency | Where | Native replacement |
|---|---|---|
| `WorldStorage`, passed to every function | `quest/src/component.cairo:6`, `:73`, `:134`, `:198`, `:278`; `achievement/src/component.cairo:6`, `:54`, `:93`, `:150`, `:231` | The component's own `#[storage]` through `ComponentState`. No world argument |
| `ModelStorage::read_model`, `write_model` | `quest/src/store.cairo:4`, `:32-95`; `achievement/src/store.cairo:4`, `:29-82` | `starknet::storage::Map` entries of packed `felt252` values (`StorePacking`) |
| `#[dojo::model]` (5 in quest, 4 in achievement) | `quest/src/models/index.cairo:8-62`; `achievement/src/models/index.cairo:8-46` | Plain structs, packed by hand; the layout is documented (§3.3) |
| `#[dojo::event]`, `EventStorage::emit_event` | `quest/src/events/index.cairo:6-50`, `quest/src/store.cairo:98-118`, `quest/src/component.cairo:160`, `:208`; the same in achievement | The component's `#[event] enum Event` and `self.emit(...)` |
| `Introspect`, `DojoStore` derives on `Task` | `quest/src/types/task.cairo:3`; `achievement/src/types/task.cairo:3` | `Drop, Copy, Serde, PartialEq` on a `u32`/`u32` task; storage through packing |
| World permissions (writer of the namespace), the only access control | `quest/src/tests/setup.cairo:51-52`; `achievement/src/tests/setup.cairo:47` | A reporter registry and two authorization hooks (§3.6) |
| `#[dojo::contract]`, `self.world(@NAMESPACE())` | `quest/src/tests/contract.cairo:40`, `:175-177`; `achievement/src/tests/contract.cairo:39` | `#[starknet::contract]` mock consumers in the tests |
| `dojo_cairo_test` (`spawn_test_world`, `NamespaceDef`, `TestResource`, `ContractDefTrait`, `sync_perms_and_inits`, `dns`) | `quest/src/tests/setup.cairo:2-6`, `:29-66`; `achievement/src/tests/setup.cairo:4-5` | snforge 0.61: `declare`, `deploy`, `spy_events`, `start_cheat_caller_address`, `start_cheat_block_timestamp` |
| `starknet::testing::set_block_timestamp` | `quest/src/tests/test_component.cairo:1`; `achievement/src/tests/test_component.cairo:1` | snforge's `start_cheat_block_timestamp` |
| Manifest: `dojo`, `dojo_cairo_test`, `build-external-contracts = ["dojo::world::world_contract::world"]`, Cairo 2.13.1 | `quest/Scarb.toml:7`, `:12`, `:18`; `achievement/Scarb.toml:7`, `:12`, `:18`; root `Scarb.toml` | Scarb 2.19.4, `starknet` only; `snforge_std` as a dev-dependency |
| (Not Dojo) `graffiti` JSON builder, a git dependency | `quest/Scarb.toml:9`; `quest/src/types/metadata.cairo:3`, `reward.cairo:3`; the same in achievement | Dropped: no JSON is built on-chain (§3.9) |

---

## 2. Defects: ADR-0004 points 3 to 5, and others

ADR-0004 point 5 concerns `social`, which is out of scope. Points 3 and 4 give four defects,
**all confirmed**. Each defect becomes one or more **test cases** with a name, a given, a
when and a then. Tests prefixed `quest_` belong to ARC-03 and `achievement_` to ARC-04. They
are written against the native API of §3. Where the native design removes a defect by
construction, the test checks that the removal holds.

### D-1 — Event mode untested (ADR-0004 point 3): **confirmed**

In both suites, every call to `create` and `progress` passes `to_store = true`: for example
`quest/src/tests/test_component.cairo:25`, `:40`, `:94`, `:190`, and
`achievement/src/tests/test_component.cairo:29`, `:70`, `:158`. A search for `, false)` in
both `src/tests/` folders finds only assertions (`quest/.../test_component.cairo:42`, `:120`,
`:228`, `:288`, `:294`, `:475`, `:572`, `:601`; `achievement/.../test_component.cairo:72`,
`:166`). The only event tests are unit tests of event constructors
(`quest/src/events/progression.cairo:45-58`, `achievement/src/events/progress.cairo:45-58`).

What reading says event mode does (§1.4): one event and nothing else. A claim after
event-mode progress reverts.

| Test | Given | When | Then |
|---|---|---|---|
| `quest_event_mode_emits_only_progressed` | Quest Q (task T, total 10) defined; spy on events | `progress(P, T, 3, Mode::Event)` | Exactly one event, `QuestProgressed { player_id: P, task_id: T, count: 3 }`; `quest_progress(P, Q, 0)` is all zero |
| `quest_event_mode_calls_no_hook` | As above; the mock consumer counts hook calls | `progress(P, T, 10, Mode::Event)` | No hook called; no `QuestCompleted` |
| `quest_event_mode_cannot_be_claimed` | As above, after event-mode progress of 10 | `claim(P, Q, 0)` | Reverts `'Quest: not completed'` |
| `quest_modes_do_not_mix` | Q, total 10 | `progress(P, T, 6, Event)` then `progress(P, T, 6, Storage)` | Stored count is 6, not completed |
| `achievement_event_mode_emits_only_progressed` (and the three above, for achievements) | Achievement A (task T) | Same | Same |

### D-2 — Unlock fires on every decrement (point 4a): **confirmed**

`quest/src/component.cairo:262-272` decrements, writes, calls `on_quest_unlock` and emits
`QuestUnlocked` for every dependent, whatever `lock_count` becomes. The package's own
documentation says the event fires only when the counter reaches 0
(`quest/docs/conditions.md:127`, `:307`, `:311`). The Dojo test of this case
(`test_questable_conditions_convergent`, `test_component.cairo:553-580`) checks
`is_unlocked` only, not hooks or events.

**Scenario.** C has conditions `[A, B]`. The player completes A. C's `lock_count` goes from
2 to 1, yet `on_quest_unlock(C)` is called and `QuestUnlocked(C)` emitted while C is still
locked. A consumer that grants something on unlock grants it twice, once per prerequisite.

Native: there is no unlock hook and no unlock event. Unlocking is evaluated lazily (§3.2).

| Test | Given | When | Then |
|---|---|---|---|
| `quest_prerequisites_all_required` | A, B one-off; C with conditions `[A, B]` | P completes A | `quest_is_unlocked(P, C) == false`; `progress(P, T_C, 1, Storage)` leaves C's count at 0; no hook other than `on_quest_complete(A)` |
| `quest_prerequisites_unlock_after_last` | Same | P completes A, then B | `quest_is_unlocked(P, C) == true`; progress on `T_C` counts |

### D-3 — An inactive dependent reverts the whole progress call (point 4b): **confirmed**

At `quest/src/component.cairo:264-266` the unlock loop calls `compute_interval_id` on the
dependent, which asserts `is_active` (`definition.cairo:85`). `get_completion_or_new`
computes it a second time (`store.cairo:52`). If the dependent is not active at the time the
prerequisite completes, the call panics with `'Quest: not active'`, and the
**prerequisite's completion reverts with it**.

**Scenario.** A is permanent. B has conditions `[A]` and `start = now + 1 week`. The player
reports the last kill of A: the whole transaction reverts. **A cannot be completed until B's
window opens.** If B is recurring with `duration < interval`, A can be completed only while
B's window is open.

| Test | Given | When | Then |
|---|---|---|---|
| `quest_inactive_dependent_does_not_revert` | A permanent; B conditions `[A]`, `start = t0 + 604 800` | At `t0`, `progress(P, T_A, total, Storage)` | Succeeds; A completed; `on_quest_complete(A)` called once |
| `quest_dependent_unlocks_when_window_opens` | Same, after A completed | At `t0 + 604 800`, `progress(P, T_B, 1, Storage)` | B counts 1 |
| `quest_inactive_quest_skipped_not_reverted` | Q1 active and Q2 not yet active share task T | `progress(P, T, 1, Storage)` | Q1 counts 1, Q2 untouched, no revert |

### D-4 — A recurring prerequisite underflows the lock counter of a one-off quest (point 4c): **confirmed**

**Scenario.** P recurs weekly (`interval = 1 week`, `duration = 1 day`). D is one-off with
conditions `[P]`.

- In week 0 the player completes P. D's interval-0 completion goes `lock_count` 1 → 0 and is
  written (`component.cairo:266-268`).
- In week 1 the player completes P again. `get_completion_or_new` returns **the existing**
  completion of D (`store.cairo:53-56`), and `unlock` computes `0 - 1` on a `u32`
  (`completion.cairo:49-51`). That is an underflow panic.

The progress call reverts, so **P can never again be completed by that player**, in any
later interval.

| Test | Given | When | Then |
|---|---|---|---|
| `quest_recurring_prerequisite_completes_every_interval` | P weekly, D one-off with `[P]` | P completed in week 0, then in week 1 and week 2 | Each call succeeds; `quest_record(Player, P).completions == 3`; D unlocked |
| `quest_recurring_prerequisite_after_dependent_completed` | Same; D completed in week 0 | P completed in week 1 | Succeeds; D's record unchanged |

### D-5 — A recurring dependent of a one-off prerequisite is locked from its second interval: **confirmed** (new)

A new interval's completion is created with `lock_count = conditions.len()`
(`store.cairo:57`), and only a new completion of a prerequisite decrements it
(`component.cairo:262-272`). A one-off prerequisite completes once, so from its second
interval on the dependent is **locked for ever**. The unlock also reaches only the
dependent's interval **current at the time** of the prerequisite's completion
(`component.cairo:265`).

| Test | Given | When | Then |
|---|---|---|---|
| `quest_recurring_dependent_stays_unlocked` | A one-off; D daily with `[A]`; A completed on day 0 | On day 1 and day 5, `progress(P, T_D, total, Storage)` | D completes on each day |

### D-6 — A quest defined after its prerequisite was completed is locked for ever: **confirmed** (new)

The lock counter is initialised at `conditions.len()` when the dependent's completion is
first read (`store.cairo:57`). Completions of the prerequisite that happened **before** the
dependent was created never decrement it. This matters for the game, whose quests are added
as regions open.

| Test | Given | When | Then |
|---|---|---|---|
| `quest_prerequisite_completed_before_definition` | A completed by P | B defined with `[A]`, then `progress(P, T_B, 1, Storage)` | B counts 1 |

### D-7 — Conditions are not validated: **confirmed** (new)

`DefinitionTrait::new` checks the id, the tasks, the window and the interval, but not the
conditions (`definition.cairo:19-43`). `create` inserts them unchecked
(`component.cairo:179-183`). The consequences:

- A **self-condition** locks the quest for ever. The module's own unit tests build one:
  `CONDITIONS()` is `[QUEST_ID]` (`definition.cairo:154-156`).
- A **duplicate** condition `[A, A]` sets `lock_count = 2`, but `QuestCondition.insert`
  deduplicates (`condition.cairo:25-29`), so A's completion decrements once: **locked for
  ever**.
- An **unknown** quest id also locks the dependent for ever.

| Test | Given | When | Then |
|---|---|---|---|
| `quest_define_rejects_self_condition` | — | `define(Q, …, conditions: [Q])` | Reverts `'Quest: invalid condition'` |
| `quest_define_rejects_duplicate_condition` | A defined | `define(B, …, [A, A])` | Reverts `'Quest: invalid condition'` |
| `quest_define_rejects_unknown_condition` | — | `define(B, …, [99])` | Reverts `'Quest: invalid condition'` |
| `quest_define_rejects_too_many_conditions` | 8 quests defined | `define(B, …, [8 ids])` | Reverts `'Quest: too many conditions'` |

A cycle needs a quest that refers to one defined after it. Requiring conditions to be
**already defined** makes cycles impossible without a graph search. That rule is in the API
(§3.2).

### D-8 — Redefinition silently overwrites and leaves stale indexes: **confirmed** (new)

`create` writes the definition whether or not one exists (`quest/src/component.cairo:169`;
`achievement/src/component.cairo:128`). Associations and conditions have no removal
(`association.cairo` has only `insert`), so a task dropped from the quest still lists it.
Progress on that task then writes advancements that can never complete, because
`compute_completion` returns false for a task that is not in the quest
(`advancement.cairo:39-45`).

| Test | Given | When | Then |
|---|---|---|---|
| `quest_define_twice_reverts` | Q defined | `define(Q, …)` | Reverts `'Quest: already defined'` |
| `achievement_define_twice_reverts` | A defined | `define(A, …)` | Reverts `'Achievement: already defined'` |

### D-9 — Count overflow reverts the call: **confirmed** (new, minor)

`advancement.add` is `self.count += count` on a `u128` (`quest/.../advancement.cairo:60-62`;
`achievement/.../advancement.cairo:58-61`). An overflow panics and reverts every other quest
of the call. Native counts **saturate at the task's total** (§3.2).

| Test | Given | When | Then |
|---|---|---|---|
| `quest_count_saturates_at_total` | Q (T, total 10) | `progress(P, T, 7)` twice | Count is 10, completed once, one `QuestCompleted` |
| `quest_count_max_value` | Q (T, total `0xffffffff`) | `progress(P, T, 0xffffffff)` twice | No revert; count `0xffffffff` |

### D-10 — Achievement writes an unchanged completion on every progress: **confirmed** (new, cost)

`achievement/src/component.cairo:192` and `:205` write the completion when nothing changed,
so that a new completion is no longer "undefined" (`completion.cairo:31-33`). That is one
extra model write per associated achievement per call. Quest has the same double read
(`quest/src/component.cairo:224`, `:255`) but writes only on completion.

| Test | Given | When | Then |
|---|---|---|---|
| `achievement_progress_writes_one_slot` | A (1 task) | `progress(P, T, 1, Storage)`, not completing | Gas within the budget of "1 write" (§5); `achievement_progress(P, A)` is the only changed entry |

### D-11 — Achievement validation is inconsistent between event and storage mode: **confirmed** (new)

- `CreationAssert::assert_valid_tasks` exists but `CreationTrait::new` never calls it
  (`achievement/src/events/creation.cairo:40-46`, `:71-74`). An **event-mode** achievement
  with no task is accepted. Storage mode rejects it later (`definition.cairo:19`).
- The window check is `end > start` in the event (`creation.cairo:77-78`) but `end >= start`
  in the definition (`definition.cairo:44-45`).
- `rewards` is never emitted: the component passes metadata fields one by one and drops it
  (`achievement/src/component.cairo:102-115`).

| Test | Given | When | Then |
|---|---|---|---|
| `achievement_define_rejects_no_task` | — | `define(A, window, [], 10)` | Reverts `'Achievement: invalid tasks'` |
| `achievement_define_rejects_empty_window` | — | `define(A, {start: 100, end: 100}, …)` | Reverts `'Achievement: invalid window'` |

### D-12 — Interval validation overflows, and `duration > interval` is accepted: **confirmed** (new, minor)

`assert_valid_interval` multiplies two `u64` (`quest/.../definition.cairo:112-117`), which
panics on large inputs instead of returning the named error. A `duration` larger than the
`interval` makes the quest always active, which is never what a designer means.

| Test | Given | When | Then |
|---|---|---|---|
| `quest_define_rejects_duration_above_interval` | — | `define(Q, {duration: 2, interval: 1, …})` | Reverts `'Quest: invalid interval'` |
| `quest_define_rejects_half_recurring` | — | `duration = 0, interval = 86 400` | Reverts `'Quest: invalid interval'` |

### D-13 — No access control in the component: **confirmed** (by design, informational)

See §1.7. Anyone who can reach a consumer's entrypoint can progress, create or claim for any
`player_id`. Native: see §3.6.

| Test | Given | When | Then |
|---|---|---|---|
| `quest_progress_rejects_unregistered_caller` | Mock embeds `QuestImpl`; caller X not a reporter | X calls `progress` | Reverts `'Quest: not reporter'` |
| `quest_progress_accepts_registered_reporter` | `set_reporter(R, true)` by the admin | R calls `progress` | Counts |
| `quest_set_reporter_admin_only` | Caller X, `authorize_admin(X) == false` | `set_reporter(Y, true)` | Reverts `'Quest: not admin'` |
| `quest_reporter_revoked` | R registered, then `set_reporter(R, false)` | R calls `progress` | Reverts `'Quest: not reporter'` |
| `quest_claim_requires_player_authorization` | `authorize_player(X, P) == false` | X calls `claim(P, Q, 0)` | Reverts `'Quest: not authorized'` |
| `quest_define_admin_only` | `authorize_admin(X) == false` | X calls `define` | Reverts `'Quest: not admin'` |
| (the same six for `achievement_`) | | | |

### D-14 — Minor points, kept as notes

These are defects of reading and documentation. None needs a test.

- The README of `quest` documents a `rewarder` field that does not exist
  (`quest/README.md:32`, `:64`).
- `are_completed` applies one `interval_id` to quests that may have different intervals
  (`quest/src/component.cairo:96-110`).
- Progress to a task that is already done, in an unfinished quest, still adds and writes
  (`quest/src/component.cairo:234-238`).
- `QuestMetadata` requires a non-zero `registry` address that nothing uses
  (`quest/src/types/metadata.cairo:90`).

### Also tested, to pin behaviours the game relies on

| Test | Given | When | Then |
|---|---|---|---|
| `quest_daily_interval_aligned_on_utc_midnight` | Q with `start = 0`, `interval = duration = 86 400` | Progress at `86 400 × k − 1` and `86 400 × k` | Interval ids `k − 1` and `k` |
| `quest_one_off_completes_once` | Q one-off, completed | More progress | No second `QuestCompleted`, no hook |
| `quest_recurring_completes_each_interval` | Q weekly | Complete in weeks 0, 1, 2 | Three completions; `completions == 3` |
| `quest_claim_index_counts_claims` | Q daily, completed on days 0 and 1 | Claim day 1 then day 0 | Hook receives `claim_index` 0 then 1 |
| `quest_claim_twice_reverts` | Q completed and claimed | Claim again | Reverts `'Quest: already claimed'` |
| `quest_claim_uncompleted_reverts` | Q not completed | Claim | Reverts `'Quest: not completed'` |
| `quest_accept_required` | Q with `needs_accept` | Progress before `accept` | Not counted; counted after `accept` |
| `quest_completion_releases_acceptance` | Q with `needs_accept`, accepted | Completes | `record.active == false` |
| `quest_task_shared_by_max_quests` | `MAX_QUESTS_PER_TASK` quests on T | One progress | All count; gas within the worst-case budget |
| `quest_define_rejects_association_overflow` | `MAX_QUESTS_PER_TASK` quests on T | Define one more on T | Reverts `'Quest: task full'` |
| `achievement_tiers_share_task` | A1 (T, 10), A2 (T, 50), A3 (T, 100) | `progress(P, T, 60)` | A1 and A2 completed, A3 at 60 |
| `achievement_tier_kept` | A1 completed | Any later progress | A1 stays completed |

---

## 3. The API of the native packages

### 3.1 Principles

| | |
|---|---|
| Two layers per package | `logic`: types and pure functions, state in and state out, no storage, tested without a deployment. `component`: storage, events, hooks and access control around `logic` |
| No Dojo, no `graffiti` | `starknet` (Cairo 2.19) only; `snforge_std` as a dev-dependency |
| Identifiers | `player_id: felt252` (A-3: the game passes an adventurer id or an account). `quest_id`, `achievement_id`, `task_id`: **`u32`** (docs/CAIRO.md §4 "u32 identifiers"; they make packing possible, §5). Id `0` is invalid (the empty-slot sentinel). Open question Q-1 |
| Time | `u64` seconds from `starknet::get_block_timestamp()`. Interval ids are `u32` |
| Counts | `u32` per call and per task, **saturating at the task's total** |
| Bounds | `MAX_TASKS = 3` per quest or achievement; `MAX_CONDITIONS = 7` per quest; `MAX_QUESTS_PER_TASK = 28` (4 pages of 7). Every loop is bounded by one of these; the bounds are in each package's README |
| Mode per call | `enum Mode { Storage, Event }` on `progress`. Definitions are always stored (Q-7) |
| Never revert for a quest-level reason | Progress skips a quest that is inactive, locked, not accepted or already complete. It reverts only on access control or malformed input |
| Checks, effects, hooks | State is written before a hook is called, so that a hook sees the new state and a re-entrant call sees it too |

### 3.2 `quiver_quest` — library (`quiver_quest::logic`)

**Types.** All are `Drop, Copy, Serde, PartialEq, Debug`.

```cairo
pub const MAX_TASKS: u8 = 3;
pub const MAX_CONDITIONS: u8 = 7;
pub const QUESTS_PER_PAGE: u8 = 7;
pub const MAX_PAGES: u8 = 4;               // MAX_QUESTS_PER_TASK = 28

#[derive(Drop, Copy, Serde, PartialEq, Debug, starknet::Store)]
pub enum Mode { #[default] Storage, Event }

pub struct QuestSchedule {
    pub start: u64,      // first second of the quest; 0 = from the epoch
    pub end: u64,        // first second after the quest; 0 = never ends
    pub duration: u32,   // seconds active in each interval; 0 = one-off
    pub interval: u32,   // seconds between interval starts; 0 = one-off
}

pub struct QuestTask { pub task_id: u32, pub total: u32 }

pub struct QuestDefinition {           // storage slot A
    pub schedule: QuestSchedule,
    pub task_count: u8,                // 1..=MAX_TASKS
    pub condition_count: u8,           // 0..=MAX_CONDITIONS
    pub needs_accept: bool,
}

pub struct QuestTasks {                // storage slot B; unused entries are zero
    pub t0: QuestTask, pub t1: QuestTask, pub t2: QuestTask,
}

pub struct QuestConditions {           // storage slot C; unused entries are zero
    pub q0: u32, pub q1: u32, pub q2: u32, pub q3: u32, pub q4: u32, pub q5: u32, pub q6: u32,
}

pub struct QuestIdPage {               // association page: quests using a task
    pub len: u8,                       // 0..=7
    pub ids: QuestConditions,          // same 7 × u32 shape
}

pub struct QuestProgress {             // per (player, quest, interval)
    pub c0: u32, pub c1: u32, pub c2: u32,   // counts, saturated at each total
    pub completed: bool,
    pub claimed: bool,
}

pub struct QuestRecord {               // per (player, quest), across intervals
    pub completions: u32,              // completions in all intervals
    pub claims: u32,                   // claims in all intervals
    pub unlocked: bool,                // prerequisites seen met (cache)
    pub active: bool,                  // accepted and not yet completed or abandoned
}

pub struct TaskProgress { pub task_id: u32, pub count: u32 }
```

**Functions.** All are pure, and none reads storage.

```cairo
// schedule
pub fn schedule_validate(schedule: @QuestSchedule);
    // panics 'Quest: invalid window'   unless end == 0 || end > start
    // panics 'Quest: invalid interval' unless (duration == 0 && interval == 0)
    //                                  || (duration > 0 && duration <= interval)
pub fn schedule_is_active(schedule: @QuestSchedule, time: u64) -> bool;
    // start <= time && (end == 0 || time < end)
    //   && (interval == 0 || (time - start) % interval < duration)
pub fn schedule_interval_id(schedule: @QuestSchedule, time: u64) -> Option<u32>;
    // None when inactive (never panics); Some(0) for one-off;
    // Some((time - start) / interval) otherwise

// definition
pub fn definition_new(
    quest_id: u32,
    schedule: QuestSchedule,
    tasks: Span<QuestTask>,
    conditions: Span<u32>,
    needs_accept: bool,
) -> (QuestDefinition, QuestTasks, QuestConditions);
    // panics 'Quest: invalid id'            quest_id == 0
    // panics 'Quest: invalid tasks'         tasks empty, > MAX_TASKS, a task_id 0, a total 0,
    //                                       or a task_id repeated
    // panics 'Quest: too many conditions'   conditions.len() > MAX_CONDITIONS
    // panics 'Quest: invalid condition'     a condition 0, == quest_id, or repeated
    // (existence of each condition is checked by the component, which has storage)
pub fn tasks_index_of(tasks: @QuestTasks, task_count: u8, task_id: u32) -> Option<u8>;
pub fn tasks_span(tasks: @QuestTasks, task_count: u8) -> Span<QuestTask>;
pub fn conditions_span(conditions: @QuestConditions, count: u8) -> Span<u32>;

// progress
pub fn progress_add(
    progress: QuestProgress, tasks: @QuestTasks, task_count: u8, index: u8, count: u32,
) -> (QuestProgress, bool /* changed */, bool /* completed by this call */);
    // saturating: c[index] = min(c[index] + count, total[index]), computed without overflow;
    // completed by this call when every c[j] == total[j] for j < task_count
    // and progress.completed was false; sets progress.completed
pub fn progress_is_complete(progress: @QuestProgress, tasks: @QuestTasks, task_count: u8) -> bool;

// record
pub fn prerequisites_met(records: Span<QuestRecord>) -> bool;   // every completions > 0
pub fn record_complete(record: QuestRecord) -> QuestRecord;     // completions + 1, active = false
pub fn record_accept(record: QuestRecord) -> QuestRecord;       // panics 'Quest: already active'
pub fn record_abandon(record: QuestRecord) -> QuestRecord;      // panics 'Quest: not active'

// claim
pub fn claim(progress: QuestProgress, record: QuestRecord)
    -> (QuestProgress, QuestRecord, u32 /* claim_index = record.claims before */);
    // panics 'Quest: not completed', 'Quest: already claimed'

// pages
pub fn page_push(page: QuestIdPage, quest_id: u32) -> QuestIdPage;   // panics when len == 7
pub fn page_span(page: @QuestIdPage) -> Span<u32>;
```

Packing is done with `impl … of starknet::storage_access::StorePacking<T, felt252>` for
`QuestDefinition`, `QuestTasks`, `QuestConditions`, `QuestIdPage`, `QuestProgress` and
`QuestRecord`. The layouts are in §3.3. A round-trip test for each is mandatory.

**Semantics that differ from Dojo, on purpose:**

| Rule | Dojo | Native | Why |
|---|---|---|---|
| Prerequisite met | A per-interval lock counter decremented at each prerequisite completion | Each prerequisite has `completions > 0` for the player, **checked when progress on the dependent is attempted**; once true, `record.unlocked` caches it | Removes D-2, D-3, D-4, D-5 and D-6 by construction; no fan-out at completion |
| Condition validity | None | Non-zero, not self, not repeated, ≤ 7, **already defined** | D-7; cycles become impossible |
| Redefinition | Overwrites | Reverts | D-8 |
| Counts | `u128`, unbounded, `+=` | `u32`, saturating at the total | D-9; packs three per slot |
| Inactive quest at progress | Skipped, but the unlock of an inactive dependent reverts | Skipped; never reverts | D-3 |
| `duration > interval` | Accepted | Rejected | D-12 |

### 3.3 `quiver_quest` — component storage

Storage members are prefixed so that they do not collide in the consumer's storage
(OpenZeppelin's convention). Every value is **one felt** (one storage slot).

```cairo
#[storage]
pub struct Storage {
    Quest_definitions: Map<u32, QuestDefinition>,            // slot A, key quest_id
    Quest_tasks: Map<u32, QuestTasks>,                       // slot B, key quest_id
    Quest_conditions: Map<u32, QuestConditions>,             // slot C, key quest_id
    Quest_task_pages: Map<(u32, u8), QuestIdPage>,           // key (task_id, page)
    Quest_progress: Map<(felt252, u32, u32), QuestProgress>, // key (player_id, quest_id, interval_id)
    Quest_records: Map<(felt252, u32), QuestRecord>,         // key (player_id, quest_id)
    Quest_reporters: Map<ContractAddress, bool>,
}
```

| Slot | Bits (from 0) | Width and reason |
|---|---|---|
| **A** `QuestDefinition` | `start` [0, 64) · `end` [64, 128) · `duration` [128, 160) · `interval` [160, 192) · `task_count` [192, 194) · `condition_count` [194, 197) · `needs_accept` [197] · `defined` [198] | Times stay `u64` as Starknet gives them; `duration` and `interval` fit `u32` (136 years); counts fit 2 and 3 bits under the bounds; `defined` tells an existing quest from the zero value, since all other fields may be 0. **199 bits** |
| **B** `QuestTasks` | `t{i}.task_id` [64i, 64i + 32) · `t{i}.total` [64i + 32, 64i + 64), i = 0..3 | Three tasks of two `u32`. **192 bits**. A fourth task at `u32` would need 256 bits > 251: hence `MAX_TASKS = 3` (Q-2) |
| **C** `QuestConditions` | `q{i}` [32i, 32i + 32), i = 0..7 | Seven `u32` ids. **224 bits**. Read only while `record.unlocked` is false |
| Page `QuestIdPage` | `ids.q{i}` [32i, 32i + 32), i = 0..7 · `len` [224, 227) | Seven quest ids per page. **227 bits**. Pages 0..3 are read in order until a page with `len < 7` |
| `QuestProgress` | `c0` [0, 32) · `c1` [32, 64) · `c2` [64, 96) · `completed` [96] · `claimed` [97] | All counts of one quest in one interval, so one read and one write per quest per call. **98 bits**. The completion time is not stored: it is in the block of `QuestCompleted` |
| `QuestRecord` | `completions` [0, 32) · `claims` [32, 64) · `unlocked` [64] · `active` [65] | **66 bits** |
| `Quest_reporters` | `bool` | One slot per reporter |

Packing is done with arithmetic (multiplying and dividing by powers of two from a constant
table), as docs/CAIRO.md §3 says. No `u256` is needed: every packed value is below 2^251 and
fits a `felt252`, with one `u128` split at most.

### 3.4 `quiver_quest` — events

Events are kept small: keys for what the indexer filters on, no `time` (the block has it),
no metadata (§3.9).

```cairo
#[event]
#[derive(Drop, starknet::Event)]
pub enum Event {
    QuestDefined: QuestDefined,
    QuestProgressed: QuestProgressed,
    QuestCompleted: QuestCompleted,
    QuestClaimed: QuestClaimed,
    QuestReporterSet: QuestReporterSet,
}

#[derive(Drop, starknet::Event)]
pub struct QuestDefined {
    #[key] pub quest_id: u32,
    pub schedule: QuestSchedule,
    pub tasks: Span<QuestTask>,
    pub conditions: Span<u32>,
    pub needs_accept: bool,
}
#[derive(Drop, starknet::Event)]
pub struct QuestProgressed {           // Mode::Event only
    #[key] pub player_id: felt252,
    #[key] pub task_id: u32,
    pub count: u32,
}
#[derive(Drop, starknet::Event)]
pub struct QuestCompleted {            // Mode::Storage, once per completion
    #[key] pub player_id: felt252,
    #[key] pub quest_id: u32,
    pub interval_id: u32,
}
#[derive(Drop, starknet::Event)]
pub struct QuestClaimed {
    #[key] pub player_id: felt252,
    #[key] pub quest_id: u32,
    pub interval_id: u32,
}
#[derive(Drop, starknet::Event)]
pub struct QuestReporterSet {
    #[key] pub reporter: ContractAddress,
    pub allowed: bool,
}
```

Accept and abandon emit nothing. The player's own quests are read by view calls
(ADR-0007 § Events are an interface); open question Q-6 covers events in storage mode.

### 3.5 `quiver_quest` — entrypoints and hooks

**Hooks.** The consumer implements this trait, and the component's impls are generic over it:

```cairo
pub trait QuestHooksTrait<TContractState> {
    /// May `caller` define quests and set reporters? Used by the external `QuestImpl` only.
    fn authorize_admin(
        self: @ComponentState<TContractState>, caller: ContractAddress,
    ) -> bool;
    /// May `caller` accept, abandon or claim for `player_id`? Used by the external `QuestImpl` only.
    fn authorize_player(
        self: @ComponentState<TContractState>, caller: ContractAddress, player_id: felt252,
    ) -> bool;
    /// After a completion is written. `completions` includes this one (1 for the first).
    fn on_quest_complete(
        ref self: ComponentState<TContractState>,
        player_id: felt252, quest_id: u32, interval_id: u32, completions: u32,
    );
    /// After a claim is written. `claim_index` is 0 for the first claim of this quest by this player.
    fn on_quest_claim(
        ref self: ComponentState<TContractState>,
        player_id: felt252, quest_id: u32, interval_id: u32, claim_index: u32,
    );
}
```

A hook that panics reverts the whole call. That is the consumer's way to refuse, for example
when a claim is made away from a guild board.

**Internal functions.** These are trusted: they check no caller. The consumer calls them from
its own entrypoints, after its own checks.

```cairo
#[generate_trait]
pub impl InternalImpl<
    TContractState, +HasComponent<TContractState>, impl Hooks: QuestHooksTrait<TContractState>,
    +Drop<TContractState>,
> of InternalTrait<TContractState> {
    fn define(
        ref self: ComponentState<TContractState>,
        quest_id: u32, schedule: QuestSchedule, tasks: Span<QuestTask>,
        conditions: Span<u32>, needs_accept: bool,
    );  // validates (§3.2) + each condition defined + not already defined + room in each task's pages;
        // writes A, B, C (if conditions), one page per task; emits QuestDefined
    fn set_reporter(ref self: ComponentState<TContractState>, reporter: ContractAddress, allowed: bool);
    fn progress(
        ref self: ComponentState<TContractState>,
        player_id: felt252, task_id: u32, count: u32, mode: Mode,
    );  // count == 0 or unknown task: no effect; Event: emits QuestProgressed only
    fn progress_many(
        ref self: ComponentState<TContractState>,
        player_id: felt252, entries: Span<TaskProgress>, mode: Mode,
    );  // the same, for the results interface; bounded by entries.len(), which the consumer bounds
    fn accept(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32);
        // panics 'Quest: does not exist', 'Quest: no accept step', 'Quest: not active' (schedule),
        // 'Quest: locked', 'Quest: already active'
    fn abandon(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32);
        // panics 'Quest: not active'; the counts of the interval are kept
    fn claim(
        ref self: ComponentState<TContractState>,
        player_id: felt252, quest_id: u32, interval_id: u32,
    ) -> u32;   // returns claim_index; writes progress and record, emits QuestClaimed,
                // then calls on_quest_claim
    fn assert_reporter(self: @ComponentState<TContractState>, caller: ContractAddress);
        // panics 'Quest: not reporter'
    // Reads (also used by QuestViewImpl)
    fn definition(self: @ComponentState<TContractState>, quest_id: u32)
        -> (QuestDefinition, Span<QuestTask>, Span<u32>);   // panics 'Quest: does not exist'
    fn progress_of(self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32, interval_id: u32)
        -> QuestProgress;
    fn record_of(self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32) -> QuestRecord;
    fn current_interval(self: @ComponentState<TContractState>, quest_id: u32) -> Option<u32>;
    fn is_unlocked(self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32) -> bool;
}
```

**Progress in storage mode, step by step** (the specification ARC-03 implements):

1. If `count == 0`, return. Set `time = get_block_timestamp()`.
2. Read pages `(task_id, 0..)` while `len == 7` (at most 4). This gives the quest ids.
3. For each quest `q`, in page order:
   1. Read A. If `schedule_interval_id(time)` is `None`, skip.
   2. If `needs_accept` or `condition_count > 0`, read the record `R(player, q)`:
      - If `needs_accept && !R.active`, skip.
      - If `condition_count > 0 && !R.unlocked`: read C, and read `R(player, p)` for each
        prerequisite `p`. If `prerequisites_met` is false, skip. Otherwise set
        `R.unlocked = true` and mark R to be written.
   3. Read `P(player, q, iid)`. If it is completed, skip.
   4. Read B and find the task's index. Apply `progress_add`. If nothing changed and R is
      not marked, skip.
   5. If the quest is completed by this call: read R if not yet read, apply
      `R = record_complete(R)`, and mark R.
   6. Write P, and write R if it is marked.
   7. If the quest was completed: emit `QuestCompleted`, then call
      `on_quest_complete(player, q, iid, R.completions)`.

**External ABI.** This is optional: the consumer embeds `QuestImpl`, `QuestViewImpl`, both,
or neither.

```cairo
#[starknet::interface]
pub trait IQuest<TState> {
    fn define(ref self: TState, quest_id: u32, schedule: QuestSchedule, tasks: Span<QuestTask>,
              conditions: Span<u32>, needs_accept: bool);            // authorize_admin(caller)
    fn set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool); // authorize_admin(caller)
    fn progress(ref self: TState, player_id: felt252, task_id: u32, count: u32, mode: Mode);
                                                                     // caller is a registered reporter
    fn progress_many(ref self: TState, player_id: felt252, entries: Span<TaskProgress>, mode: Mode);
                                                                     // caller is a registered reporter
    fn accept(ref self: TState, player_id: felt252, quest_id: u32);  // authorize_player(caller, player_id)
    fn abandon(ref self: TState, player_id: felt252, quest_id: u32); // authorize_player
    fn claim(ref self: TState, player_id: felt252, quest_id: u32, interval_id: u32) -> u32; // authorize_player
}

#[starknet::interface]
pub trait IQuestView<TState> {
    fn quest_definition(self: @TState, quest_id: u32) -> (QuestDefinition, Span<QuestTask>, Span<u32>);
    fn quest_progress(self: @TState, player_id: felt252, quest_id: u32, interval_id: u32) -> QuestProgress;
    fn quest_record(self: @TState, player_id: felt252, quest_id: u32) -> QuestRecord;
    fn quest_current_interval(self: @TState, quest_id: u32) -> Option<u32>;
    fn quest_is_unlocked(self: @TState, player_id: felt252, quest_id: u32) -> bool;
    fn quest_is_reporter(self: @TState, reporter: ContractAddress) -> bool;
}
```

Error strings are short-string constants in `quiver_quest::errors`: `'Quest: invalid id'`,
`'Quest: invalid tasks'`, `'Quest: invalid window'`, `'Quest: invalid interval'`,
`'Quest: invalid condition'`, `'Quest: too many conditions'`, `'Quest: already defined'`,
`'Quest: does not exist'`, `'Quest: task full'`, `'Quest: no accept step'`,
`'Quest: not active'`, `'Quest: locked'`, `'Quest: already active'`,
`'Quest: not completed'`, `'Quest: already claimed'`, `'Quest: not reporter'`,
`'Quest: not admin'`, `'Quest: not authorized'`. They are API, like events (COMMON §4).

### 3.6 Access control

| Action | Who, when the consumer embeds `QuestImpl` | Enforced by the component | Left to the consumer |
|---|---|---|---|
| Define a quest | A caller for whom `authorize_admin` is true | Calls the hook and reverts `'Quest: not admin'` | Who the admin is (Ownable, AccessControl, a registry role: Q-08 of the game) |
| Register or revoke a reporter | Same | Same | Same |
| Report progress | **Only a registered reporter** (A-5) | `Quest_reporters[caller]` or reverts `'Quest: not reporter'` | Which contracts to register |
| Accept, abandon | A caller for whom `authorize_player(caller, player_id)` is true | Calls the hook, reverts `'Quest: not authorized'` | Ownership of `player_id` (adventurer or account) |
| Claim | Same | Same, plus completed and not claimed | Where and when a claim is allowed (at a guild board: design/06), by panicking in `on_quest_claim` or checking before calling |
| Internal functions | Anyone the consumer lets through | **Nothing**: they are the trusted layer | Everything; documented as such in the README |

**For Grim World (A-5).** The persistent contract accepts results only from the ephemeral
contract registered for it (ADR-0007 § Access control). Its results entrypoint makes that
check and then calls the internal `progress_many`. The component's reporter registry is not
needed on that path, but it exists for consumers that expose `progress` directly. Either
way, **progress never comes from a client**. The tests of D-13 cover the external layer.
ARC-03 also tests that the internal layer is not reachable from the ABI unless the consumer
exposes it.

### 3.7 Modes

| | `Mode::Storage` | `Mode::Event` |
|---|---|---|
| Reads, writes | As in §3.5 | **None** |
| Events | `QuestCompleted` on completion only | `QuestProgressed { player_id, task_id, count }` once per call |
| Hooks | `on_quest_complete` | None |
| Windows, intervals, prerequisites, acceptance | Enforced | **Not enforced**: the indexer must apply them from `QuestDefined` |
| Completion, claim, views | Yes | No: `quest_progress` stays zero; a claim reverts `'Quest: not completed'` |
| Chosen | Per call (A-6) | Per call |

A quest must be fed in one mode only. The package cannot tell the two apart, and progress in
one mode is invisible to the other (test `quest_modes_do_not_mix`). Definitions are always
stored and always emitted, in both modes (Q-7).

### 3.8 A consumer, sketched (Grim World's persistent contract)

```cairo
#[starknet::contract]
mod Persistent {
    use quiver_quest::component::QuestComponent;
    use quiver_quest::logic::{Mode, TaskProgress};
    use starknet::{ContractAddress, get_caller_address};

    component!(path: QuestComponent, storage: quest, event: QuestEvent);
    #[abi(embed_v0)]
    impl QuestViewImpl = QuestComponent::QuestViewImpl<ContractState>;
    impl QuestInternalImpl = QuestComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)] quest: QuestComponent::Storage,
        ephemeral: ContractAddress,
        admin: ContractAddress,
        // … the game's own state: adventurers, active quest count, merit …
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event { #[flat] QuestEvent: QuestComponent::Event }

    impl QuestHooks of QuestComponent::QuestHooksTrait<ContractState> {
        fn authorize_admin(self: @QuestComponent::ComponentState<ContractState>, caller: ContractAddress) -> bool {
            false   // QuestImpl is not embedded: the game's own entrypoints call the internals
        }
        fn authorize_player(self: @QuestComponent::ComponentState<ContractState>, caller: ContractAddress, player_id: felt252) -> bool {
            false
        }
        fn on_quest_complete(ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252, quest_id: u32, interval_id: u32, completions: u32) {
            let mut game = self.get_contract_mut();
            // free one of the 3 active slots of the adventurer (design/06)
        }
        fn on_quest_claim(ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252, quest_id: u32, interval_id: u32, claim_index: u32) {
            let mut game = self.get_contract_mut();
            // grant xp, gold, items; merit diminished by claim_index (design/06 § Rules)
        }
    }

    #[external(v0)]
    fn submit_results(ref self: ContractState, adventurer_id: felt252, progress: Span<TaskProgress>) {
        assert(get_caller_address() == self.ephemeral.read(), 'not ephemeral');   // A-5
        self.quest.progress_many(adventurer_id, progress, Mode::Storage);
    }

    #[external(v0)]
    fn accept_quest(ref self: ContractState, adventurer_id: felt252, quest_id: u32) {
        // game checks: caller owns adventurer; rank; in a hub; fewer than 3 active; skills on accept
        self.quest.accept(adventurer_id, quest_id);
    }

    #[external(v0)]
    fn claim_quest(ref self: ContractState, adventurer_id: felt252, quest_id: u32, interval_id: u32) {
        // game checks: caller owns adventurer; at a guild board
        self.quest.claim(adventurer_id, quest_id, interval_id);
    }
}
```

### 3.9 Not kept from the Dojo packages, and why

| Not kept | Why |
|---|---|
| The world, models, `Store`, `dojo_cairo_test` | D-124, ADR-0007 |
| `graffiti` and JSON metadata built on-chain (`QuestMetadata`, `QuestReward`, `AchievementMetadata`, `AchievementReward`, names, descriptions, icons, `hidden`, `index`, `group`, `data`, `registry`) | Presentation, not mechanics. Building JSON costs gas at every definition, and a git dependency cannot be published on the registry. The consumer emits its own content events or keeps content in its registry. Achievement `points` are kept in the definition event, because titles are shown with them (Q-8) |
| `Task.description: ByteArray` in storage | Read on every Dojo progress call as part of the definition. Presentation belongs to the consumer |
| `on_quest_unlock` and `QuestUnlocked` | Unlocking is lazy (§3.2). An unlock event would need the fan-out that caused D-2 to D-4. Availability is a view (`quest_is_unlocked`) (Q-5) |
| `QuestCondition` (the reverse index of dependents) | Only the unlock fan-out used it |
| `to_store` on `create` | Definitions are always stored: once, at registration (docs/CAIRO.md §1) (Q-7) |
| `QuestProgression` in storage mode | One event on every progress call, for data a view gives (Q-6) |
| `time` in events | The block's timestamp is available to the indexer |
| Completion `timestamp` in storage | Only shown, so it is in the block of `QuestCompleted`. A boolean suffices for the rules |
| `are_completed(…, one interval_id)` | Misleading across intervals (D-14). `quest_progress` per quest replaces it |
| `update` and `nullify` on models (`quest/src/models/definition.cairo:45-69`, `completion.cairo:68-71`, `advancement.cairo:69-73`) | Never called by the components. Redefinition is refused (Q-9) |
| `felt252` short-string ids for quests, tasks and achievements | `u32` (Q-1) |
| Unbounded tasks, conditions and associations | Bounds (§3.1), stated and tested |

### 3.10 `quiver_achievement` — library (`quiver_achievement::logic`)

The same shape as quest, without intervals, prerequisites or acceptance. `Mode` and
`TaskProgress` are defined again in this package, so that it does not depend on
`quiver_quest` (Q-13).

```cairo
pub const MAX_TASKS: u8 = 3;
pub const ACHIEVEMENTS_PER_PAGE: u8 = 7;
pub const MAX_PAGES: u8 = 4;               // MAX_ACHIEVEMENTS_PER_TASK = 28

pub enum Mode { #[default] Storage, Event }
pub struct AchievementWindow { pub start: u64, pub end: u64 }    // 0 = open on that side
pub struct AchievementTask { pub task_id: u32, pub total: u32 }
pub struct AchievementDefinition {          // slot A: window, count and the first task inline
    pub window: AchievementWindow,
    pub task_count: u8,                     // 1..=MAX_TASKS
    pub t0: AchievementTask,
}
pub struct AchievementExtraTasks { pub t1: AchievementTask, pub t2: AchievementTask }  // slot B
pub struct AchievementIdPage { pub len: u8, pub a0: u32, pub a1: u32, pub a2: u32, pub a3: u32,
                               pub a4: u32, pub a5: u32, pub a6: u32 }
pub struct AchievementProgress { pub c0: u32, pub c1: u32, pub c2: u32,
                                 pub completed: bool, pub claimed: bool }
pub struct TaskProgress { pub task_id: u32, pub count: u32 }

pub fn window_validate(window: @AchievementWindow);          // 'Achievement: invalid window' unless
                                                             // end == 0 || end > start
pub fn window_is_active(window: @AchievementWindow, time: u64) -> bool;  // start <= time && (end == 0 || time < end)
pub fn definition_new(achievement_id: u32, window: AchievementWindow, tasks: Span<AchievementTask>)
    -> (AchievementDefinition, AchievementExtraTasks);
    // 'Achievement: invalid id', 'Achievement: invalid tasks' (empty, > 3, id 0, total 0, repeated)
pub fn task_index_of(definition: @AchievementDefinition, extra: @AchievementExtraTasks, task_id: u32) -> Option<u8>;
pub fn progress_add(progress: AchievementProgress, definition: @AchievementDefinition,
                    extra: @AchievementExtraTasks, index: u8, count: u32)
    -> (AchievementProgress, bool /* changed */, bool /* completed by this call */);   // saturating
pub fn claim(progress: AchievementProgress) -> AchievementProgress;
    // 'Achievement: not completed', 'Achievement: already claimed'
pub fn page_push(page: AchievementIdPage, achievement_id: u32) -> AchievementIdPage;
pub fn page_span(page: @AchievementIdPage) -> Span<u32>;
```

### 3.11 `quiver_achievement` — component

**Storage:**

```cairo
#[storage]
pub struct Storage {
    Achievement_definitions: Map<u32, AchievementDefinition>,          // slot A
    Achievement_extra_tasks: Map<u32, AchievementExtraTasks>,          // slot B, only if task_count > 1
    Achievement_task_pages: Map<(u32, u8), AchievementIdPage>,
    Achievement_progress: Map<(felt252, u32), AchievementProgress>,    // key (player_id, achievement_id)
    Achievement_reporters: Map<ContractAddress, bool>,
}
```

| Slot | Bits | Width and reason |
|---|---|---|
| A `AchievementDefinition` | `start` [0, 64) · `end` [64, 128) · `task_count` [128, 130) · `defined` [130] · `t0.task_id` [131, 163) · `t0.total` [163, 195) | **195 bits**. The first task is inline, so a single-task achievement (every tier of a title) costs one definition read |
| B `AchievementExtraTasks` | `t1` [0, 64) · `t2` [64, 128) | 128 bits, read only when `task_count > 1` |
| Page | 7 × `u32` [0, 224) · `len` [224, 227) | As for quests |
| `AchievementProgress` | `c0..c2` [0, 96) · `completed` [96] · `claimed` [97] | 98 bits. Completion is permanent: **a tier once reached is kept** (T-3) |

**Events:**

```cairo
pub enum Event {
    AchievementDefined: AchievementDefined,       // #[key] achievement_id: u32, window, tasks: Span<AchievementTask>, points: u16
    AchievementProgressed: AchievementProgressed, // Mode::Event: #[key] player_id: felt252, #[key] task_id: u32, count: u32
    AchievementCompleted: AchievementCompleted,   // Mode::Storage: #[key] player_id, #[key] achievement_id: u32
    AchievementClaimed: AchievementClaimed,       // #[key] player_id, #[key] achievement_id: u32
    AchievementReporterSet: AchievementReporterSet, // #[key] reporter: ContractAddress, allowed: bool
}
```

`points: u16` is emitted, not stored: it is shown and never read by a rule. There is no cap
of 100: that was a limit of Cartridge's controller (`achievement/src/events/creation.cairo:8`,
`:82-84`), not a rule of the mechanics.

**Hooks:**

```cairo
pub trait AchievementHooksTrait<TContractState> {
    fn authorize_admin(self: @ComponentState<TContractState>, caller: ContractAddress) -> bool;
    fn authorize_player(self: @ComponentState<TContractState>, caller: ContractAddress, player_id: felt252) -> bool;
    fn on_achievement_complete(ref self: ComponentState<TContractState>, player_id: felt252, achievement_id: u32);
    fn on_achievement_claim(ref self: ComponentState<TContractState>, player_id: felt252, achievement_id: u32);
}
```

**Internal functions.** These are trusted, as for quests:

```cairo
fn define(ref self: ComponentState<TContractState>, achievement_id: u32, window: AchievementWindow,
          tasks: Span<AchievementTask>, points: u16);
    // validates + not already defined ('Achievement: already defined') + room on each task
    // ('Achievement: task full'); writes A, B if needed, one page per task; emits AchievementDefined
fn set_reporter(ref self: ComponentState<TContractState>, reporter: ContractAddress, allowed: bool);
fn progress(ref self: ComponentState<TContractState>, player_id: felt252, task_id: u32, count: u32, mode: Mode);
fn progress_many(ref self: ComponentState<TContractState>, player_id: felt252, entries: Span<TaskProgress>, mode: Mode);
fn claim(ref self: ComponentState<TContractState>, player_id: felt252, achievement_id: u32);
fn assert_reporter(self: @ComponentState<TContractState>, caller: ContractAddress);   // 'Achievement: not reporter'
fn definition(self: @ComponentState<TContractState>, achievement_id: u32) -> (AchievementWindow, Span<AchievementTask>);
fn progress_of(self: @ComponentState<TContractState>, player_id: felt252, achievement_id: u32) -> AchievementProgress;
```

In storage mode, progress works as for quests. For each achievement on the task's pages:

1. Read A; skip the achievement if its window is inactive.
2. Read P; skip it if it is completed.
3. Read B only if the task is not `t0`.
4. Apply `progress_add`; skip if nothing changed.
5. Write P.
6. On completion: emit `AchievementCompleted`, then call `on_achievement_complete`.

**External ABI**, optional as for quests:

```cairo
#[starknet::interface]
pub trait IAchievement<TState> {
    fn define(ref self: TState, achievement_id: u32, window: AchievementWindow,
              tasks: Span<AchievementTask>, points: u16);                    // authorize_admin
    fn set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool); // authorize_admin
    fn progress(ref self: TState, player_id: felt252, task_id: u32, count: u32, mode: Mode);  // reporter
    fn progress_many(ref self: TState, player_id: felt252, entries: Span<TaskProgress>, mode: Mode); // reporter
    fn claim(ref self: TState, player_id: felt252, achievement_id: u32);        // authorize_player
}
#[starknet::interface]
pub trait IAchievementView<TState> {
    fn achievement_definition(self: @TState, achievement_id: u32) -> (AchievementWindow, Span<AchievementTask>);
    fn achievement_progress(self: @TState, player_id: felt252, achievement_id: u32) -> AchievementProgress;
    fn achievement_is_reporter(self: @TState, reporter: ContractAddress) -> bool;
}
```

Access control, modes and "not kept" are as for quests (§3.6, §3.7, §3.9). For Grim World,
titles run in **event mode** (ADR-0007, D-63 revised). The game's results path calls
`progress_many(adventurer_id or account, …, Mode::Event)`, which costs one event per task
and no storage. The indexer evaluates the tiers from `AchievementDefined`.

A consumer sketch is the same as §3.8, with `AchievementComponent` and the four hooks. For
event-mode titles, both `on_achievement_*` hooks are empty and `authorize_*` return false.

---

## 4. Against the game's needs A-1 to A-9

| # | Need | Status | How |
|---|---|---|---|
| A-1 | Quests of tasks with a target; one-shot and daily aligned on 00:00 UTC | **Covered** | `QuestTask { task_id, total }`. One-off: `interval = duration = 0`. Daily: `interval = duration = 86 400` with **`start` a multiple of 86 400** (§1.5; the README says so, and a test pins it). Alignment follows `start` (Q-17) |
| A-2 | Prerequisites (AND) | **Covered, adapted** | `conditions: Span<u32>`, AND, at most 7, already defined. Met when each prerequisite was completed at least once, evaluated lazily (§3.2), without the defects D-2 to D-7 (Q-3) |
| A-3 | Progress keyed by a `felt252` the game chooses | **Covered** | `player_id: felt252` on every call; the component never interprets it |
| A-4 | A claim hook the game implements | **Covered, adapted** | `on_quest_claim(player_id, quest_id, interval_id, claim_index)`; the game grants the rewards |
| A-5 | Progress reported by the causing contract, never the client; callable from the ephemeral contract's results interface | **Covered** | External: only registered reporters. Internal: `progress_many`, called by the persistent contract's results entrypoint after its own check (§3.6, §3.8) |
| A-6 | Storage or event mode, per call | **Covered, adapted** | `mode: Mode` on `progress` and `progress_many`. Definitions are always stored (Q-7) |
| A-7 | Achievements with tiers sharing one task | **Covered** | One achievement per tier, same `task_id`, up to 28 per task. Test `achievement_tiers_share_task` |
| A-8 | No Dojo; Cairo 2.19; `snforge_std` dev-dependency | **Covered** | §1.10, §6 |
| A-9 | The edge cases are tests | **Covered** | §2: D-1 to D-4 confirmed, each with named tests; D-5 to D-13 added |

**What the package serves, and what stays with the game:**

| Game rule | Where | How |
|---|---|---|
| **3 active quests** (design/06 § Quest board); **one contract held at a time** (design/14) | Shared | Is there an accept step? **Yes, optional per quest** (`needs_accept`). Progress then counts only for an accepted quest, which a design where one kill feeds several quests needs. The **limit** (3, or 1 contract) is the game's: its `accept_quest` counts, and `on_quest_complete` frees a slot. Skills given on acceptance (design/14) are the game's action in the same entrypoint (Q-4) |
| **Diminishing merit on repeat** (design/06 § Rules) | Game, with data from the package | Does the claim hook get a completion count? **Yes**: `claim_index` (earlier claims of that quest by that player) in `on_quest_claim`, and `completions` in `on_quest_complete`. The curve and floor are the game's |
| **Daily board draw** (3 contracts per hub per day, design/14) | Game | The package gives the day as `quest_current_interval`. Drawing from the list and offering 3 per hub are the game's, in the persistent domain; `accept_quest` refuses a contract not drawn today |
| **"Distinct" counters** (design/13 T-2) | Game | Design/13 keeps them as bitmaps keyed by registry ids. The game reports `count = 1` to the task only when a bit is newly set. The package counts increments and cannot know distinctness |
| **Tiers kept once reached** (T-3) | Package | A completion is never undone in storage mode. In event mode the indexer keeps the best tier. A track that resets (Unbroken) is the game's to express: it reports only the increments above the best value reached |
| Repeatable board quests with no interval (design/06 `repeatable`) | Not in the proposal | A-1 asks for one-shot and daily only (Q-12) |
| Claim only at a guild board (design/06) | Game | Its `claim_quest` checks the location, or `on_quest_claim` panics |
| Rank required, region unlocks (design/06) | Game | Checked in `accept_quest` (or, for quests without an accept step, by not defining them yet) |

---

## 5. Cost

**All figures in this section are estimates from the layouts, not measurements.** ARC-03 and
ARC-04 measure them, and each becomes a test budget (docs/CAIRO.md §2).

Notation:

- **N**: quests (or achievements) on the task.
- **K**: prerequisites of a quest.
- **T**: tasks of a quest (≤ 3).
- **Pg**: association pages read, `⌈N / 7⌉` (at most 4).

### 5.1 `quiver_quest`, per call

| Case | Storage reads | Storage writes | Events | Hooks |
|---|---|---|---|---|
| Event mode, any case | 0 | 0 | 1 | 0 |
| Storage, one one-off quest, one task, no prerequisite, not completing | 1 page + A + P + B = **4** | **1** (P) | 0 | 0 |
| Same, completing | 4 + R = **5** | **2** (P, R) | 1 | 1 |
| Storage, quest with K prerequisites, first progress after they are met | Pg + A + R + C + K + P + B = **5 + K** | 2 (P, R with `unlocked`) | 0 | 0 |
| Same, later calls (`unlocked` cached) | Pg + A + R + P + B = **5** | 1 | 0 | 0 |
| Storage, a locked quest (prerequisites not met) | Pg + A + R + C + K = **4 + K** | 0 | 0 | 0 |
| Daily interval | The same as the one-off rows: the interval id is arithmetic; the first call of a day writes a new P key | = | = | = |
| **Worst case**: task shared by N = 28 quests, each needing acceptance, with K = 7 unmet-then-met prerequisites, all completing in this call | Pg + N × (A + R + C + K + P + B) = 4 + 28 × 12 = **340** | N × 2 = **56** | 28 | 28 |
| Claim | P + R = **2** | **2** | 1 | 1 |
| Accept or abandon | A + R (+ C + K if not yet unlocked) = **2 to 10** | 1 | 0 | 0 |
| Define (once) | Each condition's A (K), each task's pages | A, B, C, one page per task | 1 | 0 |

### 5.2 `quiver_achievement`, per call

| Case | Reads | Writes | Events |
|---|---|---|---|
| Event mode (Grim World's titles) | 0 | 0 | 1 |
| Storage, one single-task achievement, not completing | 1 page + A + P = **3** | **1** | 0 |
| Storage, a title of 3 tiers on one task | 1 + 3 × 2 = **7** | **3** | 0, or 1 per tier reached |
| Worst case: 28 achievements of 3 tasks on the task, all completing | 4 + 28 × 3 = **88** | **28** | 28 |
| Claim | P | 1 | 1 |

### 5.3 Against the Dojo packages

These counts are from `quest/src/component.cairo:196-273` and
`achievement/src/component.cairo:148-219`, and are exact as to **model** operations. How
many storage slots a model operation touches follows Dojo's model layout, one felt per
serialized field. That layout is not in `ref/` and was not read, so the slot figures are
estimates. ADR-0007 adds a permission check and a record event per model write.

| Per associated quest, storage mode, one task, not completing | Dojo | Native (estimate) |
|---|---|---|
| Model or slot reads | Definition (4 `u64` + a `Span<Task>` with descriptions + conditions: **≈ 11 felts** for one task with a short description), completion (**3 felts**), advancement (**2 felts**) | A, P, B: **3 slots** (+ 1 page per 7 quests) |
| Writes | Advancement (**2 felts**), with a permission check and a record event from the world | P: **1 slot** |
| Events | `QuestProgression` every call | 0 |
| On completion | + T advancement reads, + completion read and write (3 felts), + per dependent: definition, completion read and write, an unlock event | + R read and write, 1 event |

**What packing saves.**

| Record | Dojo | Native |
|---|---|---|
| Per (player, quest, interval) | `3 + 2T` felts (completion and one advancement per task): 5 for one task, 9 for three | 1 slot, whatever T |
| Progress call on a 3-task quest | Rewrites 2 felts, plus 3 on completion | Rewrites 1 slot |
| Definition read on every progress call | ≈ 11 felts for one task, more with descriptions | 2 slots (A, B), and 1 for a single-task achievement |

Across N quests on a task, the Dojo association costs about `N + 1` felts; the native pages
cost `⌈N / 7⌉` slots.

**Largest remaining cost.** Prerequisites read K records until the cache bit is set. After
that, a dependent costs one read more than a quest without prerequisites.

---

## 6. The workspace

### 6.1 Layout

```
quiver/
├── Scarb.toml                  # [workspace] only: members, shared package fields, shared deps
├── Scarb.lock
├── packages/
│   ├── quest/                  # package quiver_quest
│   │   ├── Scarb.toml
│   │   ├── README.md           # usage, bounds, access control, modes
│   │   ├── CHANGELOG.md        # Keep a Changelog; every change to results, layout, events, errors
│   │   ├── GAS.md              # per entrypoint and algorithm: measured, budget, date, commit
│   │   ├── src/{lib.cairo, logic/…, component.cairo, interface.cairo, errors.cairo}
│   │   └── tests/              # snforge: logic tests, component tests with a mock consumer
│   └── achievement/            # package quiver_achievement, same shape
├── docs/  (BUDGETS.md joins at ARC-03)
├── scripts/
└── .github/workflows/{tooling.yml, cairo.yml, release.yml}
```

**Root `Scarb.toml`.** ARC-02 writes it; this is the proposal:

```toml
[workspace]
members = ["packages/*"]

[workspace.package]
version = "0.0.0"               # not inherited: each package sets its own version
edition = "2024_07"
cairo-version = "2.19.0"
license = "MIT"
repository = "https://github.com/bal7hazar/quiver"

[workspace.dependencies]
starknet = "2.19.0"
snforge_std = "0.61.0"

[workspace.tool.fmt]
sort-module-level-items = true
```

**Package manifest** (`packages/quest/Scarb.toml`):

```toml
[package]
name = "quiver_quest"
version = "0.1.0"
edition.workspace = true
cairo-version.workspace = true
license.workspace = true
repository.workspace = true
description = "Quests for Starknet games: tasks, intervals, prerequisites, claim. No Dojo."

[dependencies]
starknet.workspace = true

[dev-dependencies]
snforge_std.workspace = true

[[target.starknet-contract]]    # only if tests deploy a mock consumer from src/
[lib]

[scripts]
test = "snforge test"
```

### 6.2 Dependencies between packages

Neither package depends on the other (Q-13). When one does in future:

- **Inside the workspace**: `quiver_x = { path = "../x", version = "^0.1.0" }`. The path is
  used in the workspace; the version is what a published package records. Scarb's
  documentation shows the `path` plus `version` form
  ([specifying dependencies](https://docs.swmansion.com/scarb/docs/reference/specifying-dependencies.html)).
  It does **not** say, in the pages read, what `scarb publish` does with the `path`. ARC-02
  verifies it with `scarb package` before the first release.
- **Once published**: consumers such as Grim World write `quiver_quest = "0.1.0"`. A package
  depends on another's **published interface** only (COMMON §4).

### 6.3 CI by affected package

ARC-02 builds this as `.github/workflows/cairo.yml`, beside `tooling.yml`:

| Step | How |
|---|---|
| 1. Changed files | On `pull_request`: `git diff --name-only origin/main...HEAD` |
| 2. Directly affected packages | A file under `packages/<dir>/` affects the package in that directory. A change to root `Scarb.toml`, `Scarb.lock`, `.github/workflows/cairo.yml`, `.tool-versions` or the gas tooling affects **all** packages. Documents alone affect none, and the Cairo job is skipped |
| 3. Dependents | `scarb metadata --format-version 1` lists the workspace packages and their dependencies. The job builds the reverse graph and adds every package that depends, transitively, on an affected one |
| 4. Matrix | One job per package in the closure, each running `scarb --manifest-path packages/<dir>/Scarb.toml fmt --check`, `… build`, and `snforge test` from `packages/<dir>` (gas budgets are part of the tests) |
| 5. Always | On `push` to `main`, on a release tag, and nightly: **every** package |
| 6. Required check | One summary job, `cairo`, that succeeds when every matrix job does (or when there is none), so that branch protection has a stable name |

This follows the rules of COMMON §3 locally (package-scoped checks) and puts the full gate in
CI.

### 6.4 Publication per package

| | |
|---|---|
| Versions | Semver per package, starting at **0.1.0**. Results, storage layout, events and error strings are API (COMMON §4). Before 1.0.0 a change to any of them bumps the minor version; after, the major |
| Changelog | `packages/<dir>/CHANGELOG.md`, one section per version, each change classed Added, Changed, Fixed or Removed, with **layout and event changes named** |
| `GAS.md` | Per package, updated in the release pull request: measured value, budget, date, commit per entrypoint and algorithm |
| Tags | `quiver_quest-v0.1.0`, `quiver_achievement-v0.1.0`: one tag per package release, on the merge commit |
| Release check | `release.yml` on a tag: the whole workspace is green; the tag's version equals the manifest's; `CHANGELOG.md` has that version; `scarb --manifest-path packages/<dir>/Scarb.toml package` succeeds |
| Publishing | `scarb --manifest-path packages/<dir>/Scarb.toml publish` publishes that package only; Scarb's `-p` and `--workspace` flags select packages in a workspace ([workspaces](https://docs.swmansion.com/scarb/docs/reference/workspaces.html)). It needs a token with the `publish` scope ([publishing](https://docs.swmansion.com/scarb/docs/registries/publishing.html)). **Run by the orchestrator by hand; the first publication of each package needs the project manager's go** (PLAN § Budget and rules). No token in CI |
| Irreversible | A published version cannot be replaced. A defect is fixed by a new version |

### 6.5 The names on the registry

Checked on **2026-09-28**, read-only, against scarbs.xyz's package index:

| Name | `https://scarbs.xyz/api/v1/index/qu/iv/<name>.json` | Package page | Result |
|---|---|---|---|
| `quiver_quest` | 404 Not Found | 404 | **Free** |
| `quiver_achievement` | 404 Not Found | 404 | **Free** |
| `origami_hexmap` (control) | 200, version 1.8.0 | 200 | The same query finds a known package |

A name can be taken by anyone until first publication. Q-15 covers this.

---

## 7. Open questions for gate A-G1

| # | Question | Options | Recommendation |
|---|---|---|---|
| Q-1 | Width of quest, task and achievement ids | (a) `u32`; (b) `felt252`, as in Dojo (short strings such as `'QUEST'`) | **(a)**. It makes the packing of pages, tasks and conditions possible, which is most of §5's saving; the game's registry ids are small integers. With (b), each id takes a full slot: pages hold 1 id and B holds 1 task |
| Q-2 | Tasks per quest or achievement | (a) 3, with `u32` totals, in one slot; (b) 4, with 30-bit totals; (c) unbounded, one slot per task | **(a)**. Design/14's quests have 1 or 2 objectives ("kill + collect", "reach + barter"); a title tier has 1 |
| Q-3 | When is a prerequisite met? | (a) The prerequisite has been completed at least once, ever; (b) completed in the same interval as the dependent; (c) Dojo's per-interval lock counter | **(a)**. It is what design/14's chains need, and it is the rule without D-2 to D-6. (b) can be added later as a per-quest flag if a daily chain is designed |
| Q-4 | Accept step | (a) Optional per quest (`needs_accept`), with accept and abandon; the limit of active quests is the consumer's; (b) none, and the game filters (impossible: one progress feeds every quest on the task); (c) the package also enforces a maximum of active quests per player | **(a)** |
| Q-5 | Unlock hook or event | (a) None; availability is a view; (b) emitted when the unlock is first seen lazily (on a progress call, not when the prerequisite completes) | **(a)**. (b) would fire at a confusing moment |
| Q-6 | Events in storage mode | (a) `Completed` and `Claimed` only; (b) also `Progressed` on every call, as in Dojo | **(a)**. The player's own counts are views; other players' counts are not shown anywhere in the game's design |
| Q-7 | Mode on definitions | (a) Always stored and emitted; (b) a mode on `define` too | **(a)**. It happens once per quest; storing lets event-mode progress switch to storage later |
| Q-8 | Presentation (names, descriptions, icons, groups, hidden, rewards) | (a) Not in the package: the consumer's registry or events; `points` kept in `AchievementDefined`; (b) an opaque `metadata: ByteArray` in the definition events | **(a)**. It keeps the events small and frozen; (b) is cheap to add later as a minor version |
| Q-9 | Changing a quest after definition | (a) Refused in 0.1; a later minor version may add `set_end` to retire one; (b) full update | **(a)**. An update to tasks invalidates stored progress |
| Q-10 | Ship the external ABI (`QuestImpl`, `IAchievement`) with its access control | (a) Yes, optional to embed, beside the internal layer; (b) internal only | **(a)**. The package owns access control (COMMON §4) for consumers that expose it; Grim World uses the internal layer from its results entrypoint |
| Q-11 | Claim of past intervals | (a) Allowed without limit, as Dojo; (b) only the current and previous interval | **(a)**. The game can refuse in `on_quest_claim` |
| Q-12 | Repeatable quests with no interval ("repeatable (board)", design/06) | (a) Not in 0.1; (b) a flag keying progress by run number (`record.claims`) instead of interval | **(a)**, unless the game confirms the need: A-1 asks for one-shot and daily only. **A question for the game's designer** |
| Q-13 | A shared package (`quiver_core`) for `Mode`, `TaskProgress`, pages and packing helpers | (a) No: each package is self-contained; (b) yes | **(a)** for 0.1; revisit when a third package needs them |
| Q-14 | Quests or achievements per task | (a) 28 (4 pages); (b) 56 (8 pages) | **(a)**. A kill task shared by more than 28 live quests is not in design/14 |
| Q-15 | Names | `quiver_quest`, `quiver_achievement` (free, §6.5) | **Confirm**, and publish 0.1.0 of `quiver_quest` when ARC-03 is accepted, so that the name is held |
| Q-16 | First version | 0.1.0 until Grim World integrates (GLD-02), then 1.0.0 | **0.1.0** |
| Q-17 | Daily alignment on 00:00 UTC | (a) Document that `start` must be a multiple of 86 400, and test it; (b) the package enforces it when `interval` is a multiple of 86 400 | **(a)**. (b) would forbid legitimate local-time schedules for other consumers |
