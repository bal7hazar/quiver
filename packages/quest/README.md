# quiver_quest

Quests for Starknet games: tasks, intervals, prerequisites, an optional accept step, claim. Pure
Cairo and Starknet, no Dojo. The accepted API is
[ARC-01 §3](../../docs/research/ARC-01-quest-achievement.md).

A quest has 1 to 3 **tasks** (a task id and a target), a **schedule** (one-off, or recurring in
intervals), up to 7 **prerequisites** (quests completed at least once, ever), and optionally an
**accept step**. The game reports progress on tasks; the component counts it on every live quest
that uses the task, completes quests, and lets players claim them. Rewards are the game's: it
grants them in its hooks.

## Two layers

| Module | What |
|---|---|
| `quiver_quest::logic` | The pure library: types, their packing into one felt each, functions. State in, state out, no storage |
| `quiver_quest::component::QuestComponent` | The Starknet component: storage, events, hooks, the trusted internal layer, the optional external ABI |
| `quiver_quest::interface` | `IQuest` and `IQuestView`, with their dispatchers |
| `quiver_quest::errors`, `quiver_quest::constants` | The error strings (API) and the bounds |

## Usage

Embed the component, implement `QuestHooksTrait`, and choose what to expose. This consumer, like
Grim World's (ARC-01 §3.8), exposes only the views and calls the internal layer from its own
entrypoints, after its own checks:

```cairo
#[starknet::contract]
mod Game {
    use quiver_quest::component::QuestComponent;
    use quiver_quest::logic::{Mode, TaskProgress};
    use starknet::storage::StoragePointerReadAccess;
    use starknet::{ContractAddress, get_caller_address};

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    #[abi(embed_v0)]
    impl QuestViewImpl = QuestComponent::QuestViewImpl<ContractState>;
    impl QuestInternalImpl = QuestComponent::InternalImpl<ContractState>;

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

## Modes

`progress` and `progress_many` take a `Mode`, per call.

| | `Mode::Storage` | `Mode::Event` |
|---|---|---|
| Reads, writes | Each affected progress and record read and written at most once | **None** |
| Events | `QuestCompleted` per completion | `QuestProgressed { player_id, task_id, count }` per merged, non-zero entry |
| Hooks | `on_quest_complete` | None |
| Windows, intervals, prerequisites, acceptance | Enforced | Not enforced: the indexer applies them from `QuestDefined` |
| Completion, claim, views | Yes | No: `quest_progress` stays zero, a claim reverts `'Quest: not completed'` |

Feed a quest in one mode only: progress in one mode is invisible to the other. Definitions are
always stored and emitted.

## One call per player per transaction

Each progress and record is written at most once **per call**. For that to hold per transaction,
the consumer aggregates its results by task id, one entry per task, and calls `progress_many`
**once per player per transaction**. More than `MAX_ENTRIES` entries revert
(`'Quest: too many entries'`), duplicates included: there is no fallback to a second call. The
package cannot see across calls; a second call in the same transaction is the consumer's error.

Progress never reverts for a quest-level reason: a quest outside its schedule, locked, not
accepted or already completed in the interval is skipped. Counts saturate at each task's total.

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

## Prerequisites, acceptance, retirement

- A quest with conditions is unlocked when each of them has been completed at least once, at any
  time, before or after the quest was defined. It is evaluated when progress or `accept` reaches
  the quest, and then cached in the player's record. `quest_is_unlocked` evaluates without
  writing. Conditions must be defined, live, distinct and not the quest itself: no cycle can form.
- With `needs_accept`, progress counts only while the quest is accepted in the current interval.
  An acceptance ends at completion, at `abandon`, or at rollover. A completed interval cannot be
  accepted again. A limit on active quests is the consumer's: use `quest_is_accepted`, not the
  raw bits of `quest_record`.
- `retire` takes a quest off its tasks' pages, freeing its slot, and is refused while a live quest
  names it as a condition (`'Quest: has live dependents'`): retire dependents first. A retired
  quest counts no progress and cannot be accepted, redefined or used as a condition; its
  completed intervals stay claimable.

## Bounds

Every loop is bounded:

| Bound | Value | Bounds |
|---|---|---|
| `MAX_TASKS` | 3 | Tasks per quest; unrolled |
| `MAX_CONDITIONS` | 7 | Prerequisites per quest: records read to evaluate them, dependents' counters updated by `define` and `retire` |
| `QUESTS_PER_PAGE` × `MAX_PAGES` | 7 × 4 = 28 | Live quests per task (`'Quest: task full'` above); pages read per task |
| `MAX_ENTRIES` | 16 | Entries of one `progress_many` call, checked first; the merge makes at most 16² comparisons |
| live dependents | 65 535 | Live quests naming one quest as a condition (`'Quest: too many dependents'`) |

The worst case of one `progress_many` call is 16 tasks × 28 quests, each with 7 prerequisites
evaluated for the first time: 5 440 storage reads and 896 writes, measured (`quest_batch_bound_accepted`).

## Library

`quiver_quest::logic` is the pure library, without storage: state in, state out
([ARC-01 §3.2](../../docs/research/ARC-01-quest-achievement.md)). It holds the types (`Mode`,
`QuestSchedule`, `QuestTask`, `QuestDefinition`, `QuestTasks`, `QuestConditions`, `QuestIdPage`,
`QuestProgress`, `QuestRecord`, `TaskProgress`), their packing into one felt each
(`StorePacking<T, felt252>`, layouts of §3.3), and the functions on schedules, definitions,
batches, progress, records, claims and pages. Error strings are in `quiver_quest::errors`.

Every loop is bounded: `batch_merge` by `MAX_ENTRIES` (checked first; at most `MAX_ENTRIES²`
comparisons when a task id repeats or two ids are equal modulo 128, one pass otherwise); the lookups of a merged batch
(`batch_count_of`, `batch_first_position`, `progress_add`) by `MAX_ENTRIES`; the condition checks
of `definition_new` by `MAX_CONDITIONS` (checked first); `prerequisites_met` by the one record per
condition the caller passes, `MAX_CONDITIONS`. Tasks and pages are unrolled, without loops.

## Gas

Every test has a budget; the figures are in [GAS.md](GAS.md): the library's benchmarks in
`test_bench`, the component's in `test_component_bench`, one per entrypoint on the worst case of
ARC-01 §5.1. Per entrypoint, the measure and the budget are in
[docs/BUDGETS.md](../../docs/BUDGETS.md).
