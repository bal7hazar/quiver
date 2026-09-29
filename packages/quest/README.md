# quiver_quest

Quests for Starknet games: tasks, intervals, prerequisites, acceptance, claim. Pure Cairo and
Starknet, no Dojo. The accepted API is [ARC-01 §3](https://github.com/bal7hazar/quiver/blob/main/docs/research/ARC-01-quest-achievement.md),
as amended by D-135.

A quest has:

- 1 to 3 **tasks**, each a task id and a target;
- a **schedule**: one-off, or recurring in intervals;
- up to 7 **prerequisites**: quests completed at least once, ever.

**A player accepts a quest before it counts**, and holds at most `MAX_HELD` = 4 quests at once.
The game reports progress on tasks. The component counts it on the quests the player holds,
completes them, and lets the player claim them. Rewards are the game's: it grants them in its
hooks.

## Layout

Since 0.2.0 the package is organised as the owner's rule D-143 says (docs/CAIRO.md §7), the layout
of the Arcade packages without Dojo:

| Module | What |
|---|---|
| `quiver_quest::models` | One file per stored entity: its struct (all in `models::index`), its constructor and behaviour (`...Trait`), its checks (`...Assert`), its `errors`, its storage (the slot type and its packing), its `Tracked` impl when it has an event |
| `quiver_quest::events` | One file per event (the structs in `events::index`), each with its `new` |
| `quiver_quest::types` | The value types that are not stored on their own: `Mode`, `QuestSchedule`, `QuestTask`, `TaskProgress` and the batch, `QuestHeld` and the held list |
| `quiver_quest::helpers` | What belongs to no entity: `bits`, the powers of two of the packings |
| `quiver_quest::store` | The only access to storage: `get_x`, `set_x` per model on the component's state; `Tracked`, `QuestTracking` and its two ready choices |
| `quiver_quest::component::QuestComponent` | The Starknet component: storage, hooks, the trusted internal layer, the optional external ABI with its access control |
| `quiver_quest::interface` | `IQuest` and `IQuestView`, with their dispatchers |
| `quiver_quest::errors`, `quiver_quest::constants` | The error strings (API) and the bounds |

**The models.**

| Model | Key | Slot | Tracked, with |
|---|---|---|---|
| `QuestDefinition { id, schedule, tasks, conditions }` | `id` | A (its schedule and counts), B, C | `QuestDefined` |
| `QuestStatus { id, defined, retired, live_dependents }` | `id` | A (the status bits), shared with the definition: read with it in one read, written back as the whole of A | no |
| `QuestProgress { player_id, quest_id, interval_id, c0, c1, c2, completed, claimed }` | `(player_id, quest_id, interval_id)` | P | no |
| `QuestRecord { player_id, quest_id, completions, claims, unlocked }` | `(player_id, quest_id)` | R | no |
| `QuestHeldSlot { player_id, index, e0, e1, counter, kept }` | `(player_id, index)` | H | no |
| `QuestReporter { reporter, allowed }` | `reporter` | the registry | `QuestReporterSet` |

The slots and their layouts are those of 0.1.0; the slot types are named for their slots:
`HeadSlot` (A), `TasksSlot` (B), `ConditionsSlot` (C), `ProgressSlot` (P), `RecordSlot` (R),
`HeldSlot` (H). `QuestCompleted`, `QuestClaimed`, `QuestRetired` and `QuestProgressed` are action
events: the component emits them where 0.1.0 does, whatever the consumer tracks.

## Tracking: the consumer's choice

A tracked model's event is optional: whether a write emits it is **the consumer's choice, made at
compile time**, by its impl of `quiver_quest::store::QuestTracking`, one constant per tracked
model:

| Choice | `define` emits `QuestDefined` | `set_reporter` emits `QuestReporterSet` |
|---|---|---|
| `quiver_quest::store::tracking::TrackAll` (as 0.1.0) | yes | yes |
| `quiver_quest::store::tracking::TrackNone` | no | no |
| An impl of its own (`const DEFINITION: bool = true; const REPORTER: bool = false;`) | as it says | as it says |

The constant is folded by the compiler: a write the consumer does not track costs exactly the
write with no event code, and a tracked one the write plus the event (measured to the unit,
[GAS.md](GAS.md#optional-tracking)). An indexer that reads the definitions from `QuestDefined`
(event mode, below) needs the definition tracked.

## Usage

Embed the component, implement `QuestHooksTrait`, choose the tracked models' events
(`QuestTracking`), and choose what to expose. This consumer, like
Grim World's (ARC-01 §3.8), exposes only the views and calls the internal layer from its own
entrypoints, after its own checks:

```cairo
#[starknet::contract]
mod Game {
    use quiver_quest::component::QuestComponent;
    use quiver_quest::types::batch::TaskProgress;
    use quiver_quest::types::mode::Mode;
    use starknet::storage::StoragePointerReadAccess;
    use starknet::{ContractAddress, get_caller_address};

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    #[abi(embed_v0)]
    impl QuestViewImpl = QuestComponent::QuestViewImpl<ContractState>;
    impl QuestInternalImpl = QuestComponent::InternalImpl<ContractState>;

    // The tracked models' events: every one, as 0.1.0 ...
    impl QuestTracking = quiver_quest::store::tracking::TrackAll<ContractState>;
    // ... or none, the writes alone (the action events are emitted either way):
    // impl QuestTracking = quiver_quest::store::tracking::TrackNone<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        quest: QuestComponent::Storage,
        results: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        QuestEvent: QuestComponent::Event,
    }

    impl QuestHooks of QuestComponent::QuestHooksTrait<ContractState> {
        // Used by the external QuestImpl only, which this consumer does not embed
        fn authorize_admin(
            self: @QuestComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            false
        }
        fn authorize_player(
            self: @QuestComponent::ComponentState<ContractState>,
            caller: ContractAddress,
            player_id: felt252,
        ) -> bool {
            false
        }
        fn on_quest_complete(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252, quest_id: u32, interval_id: u64, completions: u64,
        ) { // e.g. count completions for a title: self.get_contract_mut()
        }
        fn on_quest_claim(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252, quest_id: u32, interval_id: u64, claim_index: u64,
        ) { // grant the rewards; diminish them with claim_index; panic to refuse
        }
    }

    #[external(v0)]
    fn submit_results(ref self: ContractState, player_id: felt252, progress: Span<TaskProgress>) {
        assert(get_caller_address() == self.results.read(), 'not results');
        // Aggregated by task id, at most MAX_ENTRIES entries: one call per player per transaction
        self.quest.progress_many(player_id, progress, Mode::Storage);
    }

    #[external(v0)]
    fn accept_quest(ref self: ContractState, player_id: felt252, quest_id: u32) {
        // The game's checks first: the caller owns player_id, the quest is on today's board, ...
        // Refused when the player already holds MAX_HELD live quests ('Quest: too many held')
        self.quest.accept(player_id, quest_id);
    }

    #[external(v0)]
    fn claim_quest(ref self: ContractState, player_id: felt252, quest_id: u32, interval_id: u64) {
        // The game's checks first: the caller owns player_id, the place allows a claim, ...
        self.quest.claim(player_id, quest_id, interval_id);
    }
}
```

A consumer that wants the access-checked ABI embeds `QuestImpl` as well:

```cairo
#[abi(embed_v0)]
impl QuestImpl = QuestComponent::QuestImpl<ContractState>;
```

## Access control, and the trusted internal layer

| Action | Through `QuestImpl` (external) | Through `InternalImpl` |
|---|---|---|
| `define`, `retire`, `set_reporter` | `authorize_admin(caller)`, or `'Quest: not admin'` | **Nothing is checked** |
| `progress`, `progress_many` | A registered reporter (`set_reporter`), or `'Quest: not reporter'` | **Nothing is checked** |
| `accept`, `abandon`, `claim` | `authorize_player(caller, player_id)`, or `'Quest: not authorized'` | **Nothing is checked** |

**The internal layer is trusted.** `InternalImpl` checks no caller: it is for the consumer's own
entrypoints, which make their own checks first. It is not reachable from outside unless the
consumer writes an entrypoint that calls it; embedding `QuestViewImpl` alone exposes only views.
The consumer decides who its admin is and who owns a `player_id`, in `authorize_admin` and
`authorize_player`. `assert_reporter(caller)` is there for a consumer that wants the reporter
registry on its own entrypoints.

**Hooks** run after the state is written: `on_quest_complete` once per completion, with
`completions` (1 for the first), and `on_quest_claim` once per claim, with `claim_index` (0 for
the first claim of that quest by that player). A hook that panics reverts the whole call: that is
how a consumer refuses a claim.

A hook may re-enter the component, since the state is written first.

- A quest completed by a re-entrant `progress` is not completed again by the outer call.
- The rest of the call that ran a hook skips a quest the hook retired or abandoned.
- A quest the hook accepted is not progressed by that call: its batch was reported before the
  acceptance. The next call counts it. This holds for a quest the hook abandons and accepts again
  in the same interval too: each acceptance has its own number, and the call compares it. The
  number is 30 bits: it wraps to 0 only after about 1.07 × 10⁹ acceptances by one player. An
  acceptance is identified by its whole entry, quest, interval and number.
- A re-entrant `claim` of the claim being made, or `accept` of the quest just completed, is
  refused (`'Quest: already claimed'`, `'Quest: already completed'`). That reverts the whole
  outer call.

## Modes

`progress` and `progress_many` take a `Mode`, per call.

| | `Mode::Storage` | `Mode::Event` |
|---|---|---|
| Reads, writes | The player's held list; each held quest's progress and record read and written at most once | **None** |
| Events | `QuestCompleted` per completion | `QuestProgressed { player_id, task_id, count }` per merged, non-zero entry |
| Hooks | `on_quest_complete` | None |
| Windows, intervals, prerequisites, acceptance | Enforced | Not enforced: the indexer applies them from `QuestDefined` and its own record of acceptances (`accept` emits no event) |
| Completion, claim, views | Yes | No: `quest_progress` stays zero, a claim reverts `'Quest: not completed'` |

Feed a quest in one mode only: progress in one mode is invisible to the other. Definitions are
always stored, and emitted when the consumer tracks them (`TrackAll`): an indexer fed in event
mode needs them.

## One call per player per transaction

Each progress and record is written at most once **per call**. For that to hold per transaction,
the consumer aggregates its results by task id, one entry per task, and calls `progress_many`
**once per player per transaction**. More than `MAX_ENTRIES` entries revert
(`'Quest: too many entries'`), duplicates included: there is no fallback to a second call. The
package cannot see across calls; a second call in the same transaction is the consumer's error.

Progress never reverts for a quest-level reason. A held quest that is retired, outside the
interval of its acceptance, or already completed in the interval is skipped; a quest not held is
not read. Counts saturate at each task's total.

## Schedules, and the daily alignment on 00:00 UTC

A schedule is `start`, `end` (0 = never), `duration` and `interval` in seconds. One-off:
`duration = interval = 0`, interval id 0. Recurring: `0 < duration <= interval`; the quest is
active for `duration` seconds at the start of each interval, and its interval id is
`(time - start) / interval`, a `u64`.

Intervals are aligned on `start`, not on a calendar. **A daily quest (`duration = interval =
86 400`) rolls over at 00:00 UTC only when `start` is a multiple of 86 400**; the package does
not check it. Progress, completion and claim are per interval. **An acceptance holds only in the
interval in which it was made**: an unfinished acceptance is lost at rollover, with the progress
of that interval, and the quest must be accepted again.

## Acceptance, the held list, prerequisites, retirement

**Acceptance.** Every quest needs acceptance: progress counts only on the quests a player holds.
`accept` refuses, in this order:

1. `'Quest: does not exist'`, `'Quest: retired'`;
2. `'Quest: not active'`, outside the schedule;
3. `'Quest: locked'`, prerequisites not met;
4. `'Quest: already accepted'`, held and live in this interval;
5. `'Quest: already completed'`, this interval;
6. `'Quest: too many held'`, `MAX_HELD` live quests held.

An acceptance ends at completion, at `abandon`, at retirement, or at rollover (A-11).

**The held list.** A player's list holds at most `MAX_HELD` = 4 live quests, two per storage
slot, in the order of acceptance.

- `quest_held(player_id)` returns it, dead entries included; `quest_is_accepted` tells whether an
  entry is live.
- An entry dies when its quest completes, expires at rollover or is retired. It stays in the
  list until the player's next `accept`, which prunes every dead entry before it counts the room
  left. Progress never writes the list.
- `abandon` removes the quest, and the later entries move up.

**Prerequisites.** A quest with conditions is unlocked when each of them has been completed at
least once, at any time, before or after the quest was defined.

- `accept` checks the prerequisites and caches the unlock in the player's record. Progress does
  not read them.
- `quest_is_unlocked` evaluates them without writing.
- Conditions must be defined, live, distinct and not the quest itself, so no cycle can form.

**Retirement.** `retire` is refused while a live quest names the quest as a condition (`'Quest:
has live dependents'`): retire dependents first. A retired quest:

- counts no progress, and its held entries are dead;
- cannot be accepted, redefined or used as a condition;
- keeps its completed intervals claimable.

Any number of quests may use a task: tasks have no cap and no index. Only the quests a player
holds cost anything on progress.

## Bounds

Every loop is bounded:

| Bound | Value | Bounds |
|---|---|---|
| `MAX_TASKS` | 3 | Tasks per quest; unrolled |
| `MAX_CONDITIONS` | 7 | Prerequisites per quest: records read by `accept` to evaluate them, dependents' counters updated by `define` and `retire` |
| `MAX_ENTRIES` | 16 | Entries of one `progress_many` call, checked first; the merge makes at most 16² comparisons |
| `MAX_HELD` | 4 | Live quests a player holds (`'Quest: too many held'` above): the quests one progress call can count and complete |
| `MAX_HELD_LIMIT`, `HELD_SLOTS` | 8, 4 | What the held list's layout holds: 4 slots of 2 entries. The walk of the list reads at most 4 slots, whatever `MAX_HELD` is: the code works for any `MAX_HELD` up to 8 |
| live dependents | 65 535 | Live quests naming one quest as a condition (`'Quest: too many dependents'`) |

## Integration budget

**The network's limit.** A Starknet transaction may use at most **1.1 × 10⁹ L2 gas** ("Max L2
gas per transaction", docs.starknet.io, Learn > Cheatsheets > Chain info,
<https://docs.starknet.io/learn/cheatsheets/chain-info>, read on 2026-09-28; the page gives it for
Mainnet 0.14.2 and Sepolia 0.14.3, and 6 × 10⁹ per block). The project's own cap is far lower:
the worst call the package allows must stay **under 20 × 10⁶ L2 gas**
([A-G1 amendment](https://github.com/bal7hazar/quiver/blob/main/docs/decisions/2026-09-28-A-G1-amendment-cost-cap.md)). For scale, Grim
World's worst tick is 5.1 × 10⁶ as a whole transaction.

**The package's worst call.** It is `progress_many` with 16 entries (the slowest merge), every
held quest completing, each quest with 3 tasks. Measured through a dispatcher with snforge
([GAS.md](GAS.md#quiver_quest-020-arc-07a); the cost model is 0.1.0's, [GAS.md](GAS.md#cost-model-of-quiver_quest-010-arc-03c-d-135)). The network's estimate reprices
each written slot at the prices below. "Created" means the player's progress and record slots
are new (the worst); "existing" means they are overwritten.

| Case | Created: snforge / network | Existing: snforge / network |
|---|---|---|
| `MAX_HELD` = 4, hooks empty | **6 205 843** / 6 160 995 | 2 989 843 / 2 788 995 |
| `MAX_HELD` = 4, `on_quest_complete` writing one new slot | **8 020 763** / 7 953 491 | 4 804 763 / 4 581 491 |
| 8 held (the layout's limit), hooks empty | **11 416 073** / 11 326 377 | 4 984 073 / 4 582 377 |
| 8 held, `on_quest_complete` writing one new slot | **15 045 913** / 14 911 369 | 8 613 913 / 8 167 369 |
| Grim World's use: 16 entries, 3 quests and a daily contract completing, 0 to 2 prerequisites | 4 546 186 / 4 462 338 (6 slots created, 2 overwritten) | — |

**Each held quest adds at most 1.31 × 10⁶ L2 gas.** Most of that is its two storage writes, its
progress and its record. A written slot costs, per transaction:

| Written slot | snforge (the figures above) | The network (the game's FND-04, 149 Sepolia transactions) |
|---|---|---|
| **Created**: zero before, non-zero after | 459 106 | about 453 500 |
| Overwritten, zeroed or unchanged | 57 106 | about 32 000 |

The worst call creates both slots of each quest: its first count in the interval and its first
completion. A quest whose slots exist already costs about 0.8 × 10⁶ less. The quests a player
does not hold cost nothing, however many share the reported tasks. The worst call is a property
of `MAX_HELD`, not of how many quests use a task.

**The held list is never zeroed.** A slot of the held list keeps a marker once it has held an
entry, so the list growing back into it overwrites the slot instead of creating it: 703 980
instead of 1 084 240 for that `accept`.

The one slot the package zeroes is a reporter's, when `set_reporter(reporter, false)` revokes it.

**Other entrypoints, at their worst** (snforge / network):

| Entrypoint | L2 gas |
|---|---|
| `accept` (7 prerequisites checked; creates a never-used list slot and the record) | 1 917 170 / 1 880 852 |
| `abandon` | 564 150 / 513 938 |
| `claim` | 364 520 / 314 308 |
| `define` (3 tasks, 7 conditions; `TrackAll`) | 2 583 280 / 2 390 720 |
| `retire` (7 conditions) | 1 003 540 / 802 692 |

**The consumer's transaction must fit.** The whole transaction counts: the consumer's own
entrypoint and logic, the package's calls, the hooks (`on_quest_complete` runs once per completed
quest, so its cost multiplies with them), and the account's validation and execution. A consumer
measures its own worst transaction, and in particular the cost of its `on_quest_complete` times
`MAX_HELD`.

**The reporter check in event mode.** The external `progress` and `progress_many` of `QuestImpl`
read the reporter registry once (one storage read), in `Mode::Event` too, before emitting. Called
through the internal layer, event mode reads and writes nothing.

## Types, models and their behaviour

What was 0.1.0's `quiver_quest::logic` is scoped in the traits of the types and models
([ARC-01 §3.2](https://github.com/bal7hazar/quiver/blob/main/docs/research/ARC-01-quest-achievement.md),
amended by ARC-07a, has the table from one to the other):

- `QuestSchedule`: `ScheduleTrait::is_active`, `interval_id`; `ScheduleAssert::assert_valid`;
- a batch, `Span<TaskProgress>`: `BatchTrait::merge`, `count_of`, `first_position`;
- the held list, `Span<QuestHeld>`: `HeldTrait::position`, `contains`, `remove`;
- `QuestDefinition`: `DefinitionTrait::new` (the checks of 0.1.0, in order), `DefinitionStorage`;
- `QuestProgress`: `ProgressTrait::add`, `is_complete`, `claim`;
- `QuestRecord`: `RecordTrait::complete`, `claim`, `unlock`, `has_completed`, `all_completed`;
- `QuestStatus`: `StatusTrait::retire`, `add_dependent`, `remove_dependent`; `StatusAssert`;
- `QuestHeldSlot`: `HeldSlotTrait::new`;
- each slot's packing into one felt (`StorePacking<T, felt252>`, layouts of ARC-01 §3.3).

Error strings are in `quiver_quest::errors`; each model's `errors` module names the ones it uses.

Every loop is bounded: `BatchTrait::merge` by `MAX_ENTRIES` (checked first; at most
`MAX_ENTRIES²` comparisons when a task id repeats or two ids are equal modulo 128, one pass
otherwise); the lookups of a merged batch (`count_of`, `first_position`, `ProgressTrait::add`) by
`MAX_ENTRIES`; the condition checks of `DefinitionTrait::new` by `MAX_CONDITIONS` (checked
first); `RecordTrait::all_completed` by the one record per condition the caller passes,
`MAX_CONDITIONS`; the held list's functions by the entries of the list, `MAX_HELD_LIMIT`. Tasks
are unrolled, without loops.

## Gas

Every test has a budget; the figures are in [GAS.md](GAS.md): optional tracking in
`test_tracking` and `test_store_models`, the store in `test_store` and `test_store_definition`,
the types' and models' benchmarks in `test_bench`, the component's in `test_component_bench`, one per entrypoint on the worst case of
ARC-01 §5.1; the grid over the held list in `test_component_grid`; Grim World's case in
`test_component_game`. Per entrypoint, the measure and the budget are in
[docs/BUDGETS.md](https://github.com/bal7hazar/quiver/blob/main/docs/BUDGETS.md).
