# quiver_achievement

Achievements for Starknet games, **reported as events**: tasks, tiers, definitions kept on chain,
progress derived by an indexer. Pure Cairo and Starknet, no Dojo. The accepted API is
[ARC-01 §3.10 and §3.11](https://github.com/bal7hazar/quiver/blob/main/docs/research/ARC-01-quest-achievement.md#310-quiver_achievement--library-quiver_achievementlogic),
as amended by the
[decision of 2026-09-29](https://github.com/bal7hazar/quiver/blob/main/docs/decisions/2026-09-29-achievement-event-only.md).

An achievement has:

- 1 to 3 **tasks**, each a task id and a target count;
- a **window**, `start` and `end` in seconds (0 = open on that side);
- **points**, stored with the definition (since 0.2.0) and emitted when it is defined; shown,
  never read by a rule.

Tiers are separate achievements on one task: a title of three tiers is three achievements on the
same task, with three targets. Any number of achievements may use a task.

## Event mode only

`quiver_achievement` has **one mode: events** (0.1.0 and 0.2.0).

- **Definitions are stored** (so that they are read on chain and cannot be defined twice) and
  emitted.
- **Progress is emitted, not stored.** `progress` and `progress_many` emit one
  `AchievementProgressed { player_id, task_id, count }` per task with a non-zero count, and read
  and write nothing else: no per-player storage, no completion, no claim, no hook.
- **An indexer derives the tiers**, from `AchievementDefined`, `AchievementRetired` and
  `AchievementProgressed` (below).

**There is no storage mode, and nothing in the package lets a consumer ask for one.** There is no
`Mode` type and no `mode` parameter, no per-player record, no completion event and no claim
entrypoint: the code that would do it does not exist, so a consumer cannot reach it by
configuration or by a call. The design accepted at A-G1 had a storage mode whose worst call is
about 200 M L2 gas, ten times the project's cap; it is not published.

**A storage design is planned for a later version**: per-task counters, one packed slot per
(player, task), with the tiers as thresholds on that count (option (b) of the decision). It will
come when a consumer needs an achievement that a rule of its contract reads. **Its layout is not
reserved**: no storage member, key or bit is set aside for it, and a later version may add
members of its own.

## Layout

Since 0.2.0 the package is organised as the owner's rule D-143 says (docs/CAIRO.md §7), as
`quiver_quest` 0.2.0 is: the layout of the Arcade packages, without Dojo.

| Module | What |
|---|---|
| `quiver_achievement::models` | One file per stored entity: its struct (all in `models::index`), its constructor and behaviour (`...Trait`), its checks (`...Assert`), its `errors`, its storage (the slot types and their packing), its `Tracked` impl when it has an event |
| `quiver_achievement::events` | One file per event (the structs in `events::index`), each with its `new` |
| `quiver_achievement::types` | The value types that are not stored on their own: `AchievementWindow`, `AchievementTask`, `TaskProgress` and the batch |
| `quiver_achievement::helpers` | What belongs to no entity: `bits`, the powers of two of the packings |
| `quiver_achievement::store` | The only access to storage: `get_x`, `set_x` per model on the component's state; `Tracked`, `AchievementTracking` and its two ready choices |
| `quiver_achievement::component::AchievementComponent` | The Starknet component: storage, the hook, the trusted internal layer, the optional external ABI with its access control |
| `quiver_achievement::interface` | `IAchievement` and `IAchievementView`, with their dispatchers |
| `quiver_achievement::errors`, `quiver_achievement::constants` | The error strings (API) and the bounds |

**The models.**

| Model | Key | Slot | Tracked, with |
|---|---|---|---|
| `AchievementDefinition { id, window, tasks, points }` | `id` | A (window, first task, points), B (second and third tasks, only for 2 or 3) | `AchievementDefined` |
| `AchievementStatus { id, defined, retired }` | `id` | A (the status bits), shared with the definition: read with it in one read, written back as the whole of A | no |
| `AchievementReporter { reporter, allowed }` | `reporter` | the registry | `AchievementReporterSet` |

Progress is not a model: nothing of it is stored. `AchievementProgressed` and
`AchievementRetired` are action events: the component emits them where 0.1.0 does, whatever the
consumer tracks. The slot types are named for their slots: `HeadSlot` (A), `TasksSlot` (B).

The unit tests of a module are in its file, under `#[cfg(test)] mod tests` (D-167): they are not
compiled into a consumer's build. `tests/` holds what deploys a contract.

## Tracking: the consumer's choice

A tracked model's event is optional: whether a write emits it is **the consumer's choice, made at
compile time**, by its impl of `quiver_achievement::store::AchievementTracking`, one constant per
tracked model:

| Choice | `define` emits `AchievementDefined` | `set_reporter` emits `AchievementReporterSet` |
|---|---|---|
| `quiver_achievement::store::tracking::TrackAll` (as 0.1.0) | yes | yes |
| `quiver_achievement::store::tracking::TrackNone` | no | no |
| An impl of its own (`const DEFINITION: bool = true; const REPORTER: bool = false;`) | as it says | as it says |

The constant is folded by the compiler: a write the consumer does not track costs exactly the
write with no event code, and a tracked one the write plus the event (measured to the unit,
[GAS.md](GAS.md#optional-tracking)). **An indexer that derives the tiers reads the definitions from
`AchievementDefined`: it needs the definition tracked.** `AchievementProgressed` is emitted
whatever the choice: in event mode it is the only record of progress.

## Usage, with an indexer

Embed the component, implement `AchievementHooksTrait` (one function, `authorize_admin`), choose
what to track, and choose what to expose. This consumer, like Grim World's, tracks every model,
exposes only the views and calls the internal layer from its own entrypoints, after its own
checks:

```cairo
#[starknet::contract]
mod Game {
    use quiver_achievement::component::AchievementComponent;
    use quiver_achievement::types::batch::TaskProgress;
    use quiver_achievement::types::task::AchievementTask;
    use quiver_achievement::types::window::AchievementWindow;
    use starknet::storage::StoragePointerReadAccess;
    use starknet::{ContractAddress, get_caller_address};

    component!(path: AchievementComponent, storage: achievement, event: AchievementEvent);

    #[abi(embed_v0)]
    impl AchievementViewImpl = AchievementComponent::AchievementViewImpl<ContractState>;
    impl AchievementInternalImpl = AchievementComponent::InternalImpl<ContractState>;

    // The indexer reads AchievementDefined: every tracked model emits, as 0.1.0
    impl AchievementTracking = quiver_achievement::store::tracking::TrackAll<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        achievement: AchievementComponent::Storage,
        results: ContractAddress,
        admin: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AchievementEvent: AchievementComponent::Event,
    }

    impl AchievementHooks of AchievementComponent::AchievementHooksTrait<ContractState> {
        // Used by the external AchievementImpl only, which this consumer does not embed
        fn authorize_admin(
            self: @AchievementComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            false
        }
    }

    #[external(v0)]
    fn define_title_tier(
        ref self: ContractState, achievement_id: u32, task_id: u32, total: u32, points: u16,
    ) {
        assert(get_caller_address() == self.admin.read(), 'not admin');
        let window = AchievementWindow { start: 0, end: 0 };
        self.achievement.define(achievement_id, window, array![AchievementTask { task_id, total }].span(), points);
    }

    #[external(v0)]
    fn submit_results(ref self: ContractState, player_id: felt252, progress: Span<TaskProgress>) {
        assert(get_caller_address() == self.results.read(), 'not results');
        // Aggregated by task id, at most MAX_ENTRIES entries: one call per player per transaction
        self.achievement.progress_many(player_id, progress);
    }
}
```

A consumer that wants the access-checked ABI embeds `AchievementImpl` as well:

```cairo
#[abi(embed_v0)]
impl AchievementImpl = AchievementComponent::AchievementImpl<ContractState>;
```

**What the indexer computes.** For a player and an achievement:

1. From `AchievementDefined`: its tasks and targets, its window, its points.
2. For each of its tasks, the sum of the `count` of the player's `AchievementProgressed` on that
   task, counting an event only when its block's timestamp is in the window (`start <= time` and
   `end == 0 || time < end`, as `WindowTrait::is_active` states) and before an
   `AchievementRetired` of the achievement; each sum saturated at the task's target.
3. The achievement is reached when every task is at its target. A tier once reached is kept.

The package checks neither windows nor retirement on progress: it reads no definition there,
which is what keeps a progress call's cost independent of the achievements defined. A task no
achievement uses is still emitted.

**Counts are increments.** The consumer reports what happened, not a total. A counter of
distinct things (design/13 T-2) reports `count = 1` only when a new thing is counted; a track
that resets keeps its best tier by reporting only the increments above the best value reached.

## Access control, and the trusted internal layer

| Action | Through `AchievementImpl` (external) | Through `InternalImpl` |
|---|---|---|
| `define`, `retire`, `set_reporter` | `authorize_admin(caller)`, or `'Achievement: not admin'` | **Nothing is checked** |
| `progress`, `progress_many` | A registered reporter (`set_reporter`), or `'Achievement: not reporter'` | **Nothing is checked** |

**The internal layer is trusted.** `InternalImpl` checks no caller: it is for the consumer's own
entrypoints, which make their own checks first. It is not reachable from outside unless the
consumer writes an entrypoint that calls it; embedding `AchievementViewImpl` alone exposes only
views. The consumer decides who its admin is, in `authorize_admin`. A reporter is revoked with
`set_reporter(reporter, false)` and refused from the next call. `assert_reporter(caller)` is
there for a consumer that wants the reporter registry on its own entrypoints.

**Progress never comes from a client.** Anyone who can call a progress entrypoint can emit
progress for any `player_id`, and an indexer trusts these events: register only the contracts
that cause the progress.

## Definitions and retirement

`define` refuses, in this order: `'Achievement: invalid id'` (id 0), `'Achievement: invalid
window'` (`end != 0` and `end <= start`), `'Achievement: invalid tasks'` (none, more than 3, a task
id 0, a target 0, a task repeated), `'Achievement: already defined'` (retired or not).

`retire` refuses `'Achievement: does not exist'` and `'Achievement: retired'`; it sets the
`retired` bit and emits `AchievementRetired`. A retired achievement cannot be defined again; its
definition stays readable, with `retired` set.

`achievement_definition(id)` returns slot A (`HeadSlot`: the window, the first task, `points`,
`defined`, `retired`) and the tasks, or reverts `'Achievement: does not exist'`: a slot never
written reads as undefined. Since 0.2.0 the struct carries `points`, one more felt in the output.

## Storage layout

| Member | Key | Value |
|---|---|---|
| `Achievement_definitions` | `achievement_id` | Slot A, one felt: `start` [0, 64) · `end` [64, 128) · `task_count` [128, 130) · `defined` [130] · `retired` [131] · `t0.task_id` [132, 164) · `t0.total` [164, 196) · `points` [196, 212) (since 0.2.0); [212, 252) reserved |
| `Achievement_extra_tasks` | `achievement_id` | Slot B, one felt, only for 2 or 3 tasks: `t1` [0, 64) · `t2` [64, 128); [128, 252) reserved |
| `Achievement_reporters` | reporter address | `bool` |

No member is keyed by a player. A single-task achievement, every tier of a title, is one slot.

## Bounds

Every loop is bounded:

| Bound | Value | Bounds |
|---|---|---|
| `MAX_TASKS` | 3 | Tasks per achievement; unrolled |
| `MAX_ENTRIES` | 16 | Entries of one `progress_many` call, counted before merging and checked first (`'Achievement: too many entries'`); the merge makes at most 16² comparisons |

A task id 0 in a batch is refused (`'Achievement: invalid task'`). Duplicate task ids are merged,
their counts summed and saturated at `0xffffffff`; zero counts are dropped.

**One call per player per transaction.** The consumer aggregates its results by task id, one
entry per task, and calls `progress_many` once per player per transaction. More than
`MAX_ENTRIES` entries revert, duplicates included: there is no fallback to a second call.

## Integration budget

**The network's limit.** A Starknet transaction may use at most **1.1 × 10⁹ L2 gas** ("Max L2
gas per transaction", docs.starknet.io, Learn > Cheatsheets > Chain info,
<https://docs.starknet.io/learn/cheatsheets/chain-info>, read on 2026-09-28). The project's own
cap is far lower: the worst call the package allows must stay **under 20 × 10⁶ L2 gas**
([A-G1 amendment](https://github.com/bal7hazar/quiver/blob/main/docs/decisions/2026-09-28-A-G1-amendment-cost-cap.md)).

Measured through a dispatcher with snforge, under `TrackAll`
([GAS.md](GAS.md#quiver_achievement-020-arc-07b); the cost model in
[GAS.md](GAS.md#cost-model-of-quiver_achievement-010-arc-04-event-mode-only)). The network's
estimate reprices each written slot: a created slot about 453 500 (snforge 459 106), an
overwritten one about 32 000 (snforge 57 106).

| Call | snforge / network | Against 20 M |
|---|---|---|
| **The worst `progress_many`**: 16 entries, the slowest merge, 16 events | **1 816 813** / 1 816 813 (nothing written) | 9.1 % |
| `progress`, 1 entry | 209 236 / 209 236 | 1.0 % |
| Grim World's results transaction: 6 character and 2 account tasks, two calls | 829 728 / 829 728 | 4.1 % |
| `define`, 3 tasks (2 slots created) | 1 198 640 / 1 187 428 | 6.0 % |
| `define`, 1 task (1 slot created) | 703 270 / 697 664 | 3.5 % |
| `retire` | 243 330 / 218 224 | 1.2 % |
| `set_reporter`, a new reporter | 607 410 / 601 804 | 3.0 % |

Under `TrackNone`, `define` costs 70 180 less on 1 task and 94 760 less on 3 (no
`AchievementDefined`), `set_reporter` 41 200 less; progress and `retire` cost the same.

**Progress costs the same whatever is defined.** It reads the reporter (on the external ABI
only), merges the batch and emits; about 69 000 per distinct entry. The achievements on a task
cost a progress call nothing.

**Definitions in bulk.** Each `define` creates one or two slots. Defining Grim World's 26 tiers
in one transaction costs 18 412 110 (18 266 354 at the network's prices), 92.1 % of the cap:
define over several transactions, at most about 25 single-task achievements or 16 of three tasks
in one.

**The consumer's transaction must fit.** The whole transaction counts: the consumer's own
entrypoint and logic, the package's calls, and the account's validation and execution.

**The reporter check.** The external `progress` and `progress_many` of `AchievementImpl` read the
reporter registry once (one storage read) before emitting. Called through the internal layer,
progress reads and writes nothing.

## Types, models and their behaviour

No storage is read or written outside the store; everything else is state in, state out:

- `types::window`: `AchievementWindow`, `WindowAssert::assert_valid`, `WindowTrait::is_active`
  (the indexer's rule);
- `types::task`: `AchievementTask`, `TaskAssert::assert_valid`;
- `types::batch`: `TaskProgress`, `BatchTrait::merge` and `count_of`;
- `models::definition`: `DefinitionTrait::new` (the checks of `define`, in their order),
  `is_active`; `DefinitionStorage::into_slots` and `from_slots`; `HeadSlotTrait::tasks`; the slot
  types `HeadSlot` and `TasksSlot` and their packing into one felt each (`HeadPacking`,
  `TasksPacking`): a field wider than its bits is refused (`'Packing: field out of range'`), and
  a felt with a reserved bit set is refused on unpacking (`'Packing: reserved bits set'`);
- `models::status`: `StatusTrait::retire`, `StatusAssert`, `StatusStorage` (the status in A);
- `models::reporter`: `ReporterAssert::assert_is_allowed`.

Every loop is bounded: `BatchTrait::merge` by `MAX_ENTRIES` (checked first; at most
`MAX_ENTRIES²` comparisons when a task id repeats or two ids are equal modulo 128, one pass
otherwise), `count_of` by the entries of a merged batch. Tasks are unrolled, without loops.

## Gas

Every test has a budget; the figures are in [GAS.md](GAS.md): the library's benchmarks in their
modules (`types::batch::tests`, `models::definition::tests`), the component's and the game's use
in `test_component_bench`, the tracking choices in `test_tracking`. Per entrypoint, the measure
and the budget are in
[docs/BUDGETS.md](https://github.com/bal7hazar/quiver/blob/main/docs/BUDGETS.md).
