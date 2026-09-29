# ARC-06 — The pattern of CAIRO.md §7: model, storage, tracked event, store

| | |
|---|---|
| Task | ARC-06 ([brief](../briefs/ARC-06-model-store.md)) |
| Written by | `[Opus 5.5]`, profile `implement`, 2026-09-29 |
| Rule | [CAIRO.md](../CAIRO.md) §7 and §8 (the owner's rule D-143) |
| Reference | `cartridge-gg/arcade` at `c53fadc`, `packages/quest/src/`: `models/definition.cairo`, `models/index.cairo`, `store.cairo`, `events/` |
| Reference model | [`packages/quest/src/models/definition.cairo`](../../packages/quest/src/models/definition.cairo), with [`models/index.cairo`](../../packages/quest/src/models/index.cairo), [`events/`](../../packages/quest/src/events/) and [`store.cairo`](../../packages/quest/src/store.cairo) |
| Figures | [`packages/quest/GAS.md`](../../packages/quest/GAS.md#the-store-and-the-definition-model-arc-06), snforge 0.61, L2 gas, commit `852f546` (fix loop 1) |
| Fix loop 1 | The audits of GPT-6-Sol (organisation) and GPT-6-Astra (cost): §1.2, §1.3, §1.4, §4, §5 and §6 changed or added |
| ARC-07a | §7: optional tracking, and the answers to §5. §1 to §6 keep ARC-06's names: in 0.2.0, `logic::QuestDefinition` is `models::definition::HeadSlot`, `set_definition_status` is `set_status` with the status model, and the tracked `set_x` emits when the consumer tracks the model |

**Summary.**

- **Tracked is a trait impl.** A model is tracked when it implements `Tracked<M>`, whose
  associated type `Event` is its event and whose `event(@model)` builds it. This is known at
  compile time; nothing is looked up at run time.
- **The component's state is the store.** `StoreTrait` is implemented on the component's
  `ComponentState`; nothing is built. `set_x` writes the model. For a tracked model only, it then
  emits `Tracked::event(@model)` through `HasComponent::emit`.
- **What the compiler enforces, and what it does not.** The compiler fixes each tracked model's
  one event type, and refuses `Tracked::event` for a model without the impl. It does not force a
  tracked `set_x` to emit, nor prevent a double emit or a hand-written emit in an untracked
  setter: that is the convention, checked by one test per model (§1.2, §1.4).
- **Every read of definition data goes through the store.** Paths that need less than the model
  use focused methods named for what they return: `get_definition_head` (slot A),
  `get_definition_tasks` (B), `get_definition_conditions` (C). The quest's status is written by
  `set_definition_status`. Every benchmark of the component is the same to the unit.
- **Cost.** The store costs **exactly** what the same code costs by hand, to the unit of gas. This
  holds for an untracked and a tracked model, for a created and an overwritten slot, and for a
  read. A tracked `set` costs the untracked `set` plus 45 020, which is the event.
- **A tracked model holds every field its event carries** (§6). For the achievement's `points`,
  that is 16 free bits of a slot written anyway: +200 on a created `set`, measured on an
  equivalent model.
- **The model is passed to `set_x` by value.** Passing it by snapshot costs 3 steps more.
- **The quest definition is one model over the three slots of 0.1.0**, whose layout is
  unchanged. Writing it through the store is 4 560 cheaper than 0.1.0's code. `define` is 6 760
  cheaper (worst case). The worst calls of the package are unchanged to the unit.
- **A convention, not a package.** The only part that can be shared is a trait of four lines;
  the store belongs to each component. Correctness is checked by one test per model and by the
  auditor's lens §8.3.

## 1. The mechanism

### 1.1 Tracked, at compile time

```cairo
// quiver_quest::store
pub trait Tracked<M> {
    type Event;
    fn event(self: @M) -> Self::Event;
}

// quiver_quest::models::definition
pub impl DefinitionTracked of Tracked<QuestDefinition> {
    type Event = QuestDefined;
    fn event(self: @QuestDefinition) -> QuestDefined {
        DefinedTrait::new(self)
    }
}
```

The impl sits next to the model: being tracked is a property of the model (§7). The associated
type makes the event unique: a model cannot be tracked by two events. The event's constructor,
`DefinedTrait::new` in `events/defined.cairo`, is arcade's `CreationTrait::new`. It carries the
model's key and its values.

The list of tracked models is the list of `impl … of Tracked<…>` in a package. It is part of the
interface of the indexer (D-130).

### 1.2 The store over the component's storage

Arcade's `Store` is a `Copy` struct that wraps a `WorldStorage`. Here the component's own state
is the store:

```cairo
#[generate_trait]
pub impl StoreImpl<TContractState, +HasComponent<TContractState>, +Drop<TContractState>>
    of StoreTrait<TContractState> {
    // The model
    fn get_definition(self: @ComponentState<TContractState>, id: u32) -> QuestDefinition { … }
    fn set_definition(ref self: ComponentState<TContractState>, definition: QuestDefinition) {
        // the writes of the model, then, because it is tracked:
        HasComponent::emit(ref self, Tracked::event(@definition));
    }
    // Focused reads, named for what they return, for paths that need less than the model
    fn has_definition(self: @…, id: u32) -> bool { … }                                   // A
    fn get_definition_head(self: @…, id: u32) -> DefinitionHead { … }                    // A
    fn get_definition_tasks(self: @…, id: u32) -> QuestTasks { … }                       // B
    fn get_definition_conditions(self: @…, id: u32, condition_count: u8) -> Span<u32> { … } // C
    // The quest's status in A, untracked (§1.3)
    fn set_definition_status(ref self: …, id: u32, head: DefinitionHead) { … }
}
```

`DefinitionHead` is slot A of 0.1.0 (`quiver_quest::logic::QuestDefinition`): the definition's
schedule and counts, and the quest's status. Since fix loop 1 **the component reads and writes no
definition slot by hand**:

| Path | Store method | Slots |
|---|---|---|
| `define`: presence | `has_definition` | A |
| `define`: each prerequisite's status | `get_definition_head`, `set_definition_status` | A of the prerequisite: 1 read, 1 write |
| `define`: the definition | `set_definition` | A, B, C (with conditions), `QuestDefined` |
| `retire` | `get_definition_head`, `get_definition_conditions`, `set_definition_status` | A; C with conditions; A of each prerequisite |
| `accept`, `abandon`, `progress_many` (per held quest), `held_is_live`, `is_unlocked`, `is_accepted`, `current_interval` | `get_definition_head` | A, once |
| `progress_many`: the tasks of a held quest | `get_definition_tasks` | B |
| `prerequisites_are_met` | `get_definition_conditions` | C |
| the view `quest_definition` | `get_definition_head`, `get_definition_tasks`, `get_definition_conditions` | A, B, C with conditions: the reads of 0.1.0 |

The focused methods keep the reads of 0.1.0: every benchmark of the component is the same to the
unit as before fix loop 1 (`GAS.md`). The view returns slot A with its status, so it reads the
head rather than the model; `get_definition` is the model's read.

Inside the component, a call is `self.set_definition(definition)`. An untracked model's `set_x` is
the write alone (`MockModels::set_plain` in the tests).

**What the compiler enforces:**

- a tracked model has exactly one event type, its `Tracked` impl's `Event`;
- `Tracked::event(@x)` does not compile for a model without the impl;
- the impl must be imported where it is used, so the imports of `store.cairo` name the tracked
  models.

**What it does not enforce, and the convention and the tests do:**

- that a tracked model's `set_x` emits at all: `set_x` could forget the call;
- that it emits once: a second `emit` compiles;
- that an untracked model's `set_x` emits nothing: a hand-written `emit` of any event compiles.

The convention: a tracked `set_x` ends with the one line `HasComponent::emit(ref self,
Tracked::event(@x))`, and no other `set_x` calls `emit`. The check each package needs is one test
per model. For a tracked model, its `set_x` emits exactly its event once per write: created,
changed, and rewritten unchanged. For an untracked model, its `set_x` emits nothing (§1.4). The
store's doc comment says the same.

### 1.3 A model over several slots

The quest definition of 0.1.0 is spread over three slots, all keyed by the quest id:

- **A** holds the schedule, the counts, and the status: `defined`, `retired`, `live_dependents`.
- **B** holds the tasks.
- **C** holds the conditions, and is written only when the quest has conditions.

Three options were considered.

| Option | Verdict |
|---|---|
| **One model over A, B, C** (`QuestDefinition { id, schedule, tasks, conditions }`, arcade's shape), `DefinitionStorage::into_slots` and `from_slots` | **Chosen.** `get_definition` reads A, then B, then C only with conditions: as 0.1.0's view. `set_definition` writes C only with conditions: as 0.1.0's `define`. Reads 130 400 against 130 430 by hand; writes 1 652 890 against 1 657 450 |
| One model per slot (A, B, C) | Rejected. `QuestDefined` carries all three, so it would be the event of none of them, and a tracked model must emit its own event on every write |
| One model that includes the status (`retired`, `live_dependents`) | Rejected. A tracked model emits on every write. In 0.1.0, A's status is written by `retire`, which emits `QuestRetired`, and by the `define` of every dependent quest (`live_dependents + 1`), which emits nothing. Tracking the status with `QuestDefined` would add events that 0.1.0 does not emit |

So **the definition model is the content that `define` writes and that never changes
afterwards**, and it is tracked. **The status stays in A**, because the hot paths (`accept`,
`progress_many`) read the schedule and `retired` in one read. It is not part of the definition
model: `from_slots` ignores it (test `definition_reads_the_same_whatever_the_status`), and
`set_definition` writes the status of a new quest. That is why `define` calls it only for a
quest not yet defined.

The storage conversion reuses the packings of 0.1.0 (`QuestDefinitionPacking`,
`QuestTasksPacking`, `QuestConditionsPacking`). `into_slots` produces exactly the slots of 0.1.0's
`definition_new`, for 1 to 3 tasks and 0 to 7 conditions (`definition_storage_is_the_layout_of_0_1_0`).
The store also writes exactly 0.1.0's felts (`store_set_definition_writes_the_slots_of_0_1_0`).

**The status in ARC-06.** It stays outside the definition model, and is read and written through
the store:

- `get_definition_head` returns A, status included, in one read;
- `set_definition_status` writes A back with a changed status. It is untracked and emits nothing
  (`store_status_write_emits_nothing_and_keeps_the_definition`);
- `retire` emits `QuestRetired` itself, as an action event (§6).

**How ARC-07 models it.** A model `QuestStatus { id, defined, retired, live_dependents }`,
untracked, **sharing slot A with the definition**. Slot A is then the storage of two models: the
definition's schedule and counts, written once by `set_definition`, and the status, written by a
dependent's `define` and by `retire`. The rules:

1. **Slot A is read once per path.** A path that needs the schedule and the status (`accept`,
   `progress_many`, `retire`) reads A once and gets both, as `get_definition_head` does now.
   Reading the status and the definition's head separately would double that read.
2. **The status is written as the whole of A, from the A that was read**, with the definition's
   bits written back unchanged, in one write. Writing the status bits alone would need a second
   read of A, about 30 000 per prerequisite in `define` and `retire`, because a storage write
   sets a whole felt.
3. **The status is untracked.** Its writes emit nothing; `retire` emits `QuestRetired` as an
   action event.

**Presence.** `get_definition` of a quest not defined reads A alone and returns a model with no
task. The `define` check uses `has_definition`, which reads A alone. It is cheaper on every path
than `get_definition(..).assert_does_not_exist()` (§2.3).

### 1.4 How correctness is checked

| Property | Checked by |
|---|---|
| An untracked `set` emits nothing | `store_untracked_set_emits_nothing` (created, overwritten, rewritten unchanged: 0 events); the quest's status: `store_status_write_emits_nothing_and_keeps_the_definition` |
| A tracked `set` emits exactly its event on every write | `store_tracked_set_emits_its_event_on_every_write` (4 writes: overwritten, created, changed, rewritten unchanged; 4 events with their keys and data); `store_set_definition_emits_quest_defined_once` (1 event after one write, 2 after two); `test_component_events` (0.1.0's keys and data of `QuestDefined`, unchanged) |
| The store writes and reads what the hand writes | `store_writes_what_the_hand_writes`, `store_set_definition_writes_the_slots_of_0_1_0`, `store_get_definition_reads_the_model_back`, `store_focused_reads_return_the_slots` |
| The model's checks, their order and strings are those of 0.1.0 | `test_model_definition` (`definition_rejects_*`, `definition_errors_are_those_of_0_1_0`) and the component's existing tests, all passing unchanged |
| The model's behaviour | `definition_schedule_matches_the_oracle`: `is_active` and `interval_id` against `schedule_is_active` and `schedule_interval_id` (8 schedules × 17 times) |

For an auditor (§8.3), `grep -n "of Tracked<"` lists the tracked models. Every `set_x` of those
models must call `Tracked::event` once, and no other `set_x` may call `emit`. The tests above
are the check the compiler does not make.

## 2. Options considered

### 2.1 How a model says it is tracked

| Option | Verdict |
|---|---|
| **A trait with an associated type** (`Tracked<M> { type Event; fn event }`) | **Chosen.** Compiles in Cairo 2.19; the event is unique per model; no run-time cost |
| An associated constant `TRACKED: bool` and `if TRACKED { emit }` in one generic `set` | Rejected. An untracked model would still need an event type to type-check the branch, and removing the branch relies on constant folding |
| Negative impls (`-Tracked<M>`), for one generic `set` with a tracked and an untracked impl | Rejected. Negative impls are an experimental feature of Cairo 2.19; this was not tried |
| A generic helper `emit_tracked<T, TEvent, M, +EventEmitter<T, TEvent>, +Tracked<M>, …>` shared by every store | Rejected after trying it (scratch build, `target/`). The component's `EventEmitter` impl is not found outside the component module (E2311), and `#[inline(always)]` is refused on a function with impl generics (E2143). `HasComponent::emit` works from `store.cairo` and needs no helper |

### 2.2 What replaces arcade's `Store`

| Option | Verdict |
|---|---|
| **A trait of the component's state** (`StoreImpl of StoreTrait<TContractState>` on `ComponentState`) | **Chosen.** Nothing is built; the state is already the handle to the storage |
| A struct `Store<T> { state: ComponentState<T> }`, as arcade | Rejected after trying it. `ComponentState` is not `Copy` (E3003), so `new` must build a fresh state with the plugin's `unsafe_new_component_state`. A call also needs the type argument, `StoreTrait::<TContractState>::new()` (E2314). It works, at no cost, but it adds an `unsafe_` call and noise for nothing the trait does not do |

### 2.3 Measured choices

| Choice | Measured | Kept |
|---|---|---|
| `set_x(model: M)` or `set_x(model: @M)` | By snapshot: +300 (3 steps) on every `set`, created or overwritten, tracked or not. By value: 0 | By value (models are `Copy`, spans included) |
| `#[inline]` on the store's functions and the model's constructor | Without it: every `define` test more expensive, by 15 700 to 455 300 | `#[inline]` |
| The presence check of `define`: `get_definition(id).assert_does_not_exist()` or `has_definition(id)` | With `get_definition`: successful calls a little cheaper, but the tests whose `define` reverts cost more (+30 000 to +60 570), the admin check included. Sierra charges a branch's static cost up front, and `get_definition` rebuilds the spans. With `has_definition` (A alone): every path cheaper than 0.1.0 | `has_definition` |

## 3. A package or a convention

**A convention**, written in each package, like arcade's layout. The reasons:

1. **The store cannot be shared.** It is implemented on one component's `ComponentState` and
   emits into that component's `Event` enum. Each component writes its own `store.cairo`.
2. **What could be shared is the `Tracked` trait, four lines.** A package `quiver_model` (the name
   under D-126) would hold nothing else. Every package, and the game in another repository, would
   depend on it by version. Every change would need a publication (D-132), for four lines.
3. **A package would guarantee no more.** Without negative impls, no generic signature can forbid
   an untracked model from emitting or oblige a tracked one to emit. The check is the same test
   either way.

The cost of the convention: each package declares its own `Tracked`, so a trait of `quiver_quest`
and one of `quiver_achievement` are different types. Nothing needs them to be the same one; the
indexer reads events, not traits. If a shared package is later wanted, `quiver_model` would hold
`Tracked` and its tests, and the stores would stay in the packages.

**The convention, as the reference applies it:**

1. `models/index.cairo`: the structs, a key first (`id`), named as the design names them.
2. `models/<x>.cairo`:
   - `XImpl of XTrait` with `new` and the behaviour;
   - `XAssert of AssertTrait`;
   - `mod errors`, whose names are scoped (`DEFINITION_INVALID_ID`) and whose values are the
     package's API strings;
   - `XStorage` (model ↔ slots) when the model spans several slots, `StorePacking` when it is
     one;
   - for a tracked model, `XTracked of Tracked<X>`.
3. `events/index.cairo`: the event structs. `events/<x>.cairo` holds each event's `new`.
4. `store.cairo`: `Tracked`, then `StoreImpl` on `ComponentState`. It has `get_x`, `set_x`
   (model by value), and `has_x` when presence is cheaper than the model. A tracked `set_x` ends
   with `HasComponent::emit(ref self, Tracked::event(@x))`. Every function is `#[inline]`.
5. Tests: per tracked model, its `set_x` emits exactly its event once per write; per untracked
   model, its `set_x` emits nothing; the model's checks in order; the storage against its layout.
6. Focused reads, named for what they return (`get_definition_head`), where a path needs less
   than the model, so that no path reads more than 0.1.0 did.
7. A tracked model holds every field its event carries (§6).

## 4. Cost

From the table of `packages/quest/GAS.md` (commit `852f546`). A cost is the benchmark minus its
baseline, both through a dispatcher.

Since fix loop 1, reads are measured against baselines of the same shape: an id in, a value
out, asserted (`baseline_models_get`, `baseline_definition_read`). Before, they were measured
against write-shaped no-ops, which gave 32 590 for `get`, and 69 240 and 69 210 for the
definition's read. Those absolute figures were wrong; the comparison between hand and store was
not.

| Operation | Slot | By hand | Store | Store − hand |
|---|---|---|---|---|
| `set`, untracked | created | 454 530 | 454 530 | 0 |
| `set`, untracked | overwritten | 52 530 | 52 530 | 0 |
| `set`, tracked (write + event) | created | 499 550 | 499 550 | 0 |
| `set`, tracked (write + event) | overwritten | 97 550 | 97 550 | 0 |
| `get` | existing | 29 420 | 29 420 | 0 |
| quest definition, write (3 tasks, 7 conditions; A, B, C created; `QuestDefined`) | created | 1 657 450 | 1 652 890 | −4 560 |
| quest definition, read (A, B, C) | existing | 130 430 | 130 400 | −30 |
| `set` untracked, a third field (u16) in free bits | created | — | 454 730 | +200 against two fields |

The tracked `set` minus the untracked `set` is 45 020, created or overwritten: the event, and
nothing else.

| Entrypoint of `quiver_quest` | 0.1.0 | Now |
|---|---|---|
| `define`, 3 tasks, 7 conditions (`bench_define_worst`) | 2 590 440 | 2 583 680 |
| `progress_many`, the worst, H = 4, created | 6 213 063 | 6 213 063 |
| `progress_many`, H = 8, created | 11 430 213 | 11 430 213 |
| `retire`, 7 conditions | 1 003 240 | 1 003 240 |

No test of the package is more expensive than in 0.1.0's table. After fix loop 1, every test is
the same to the unit as at `0227486`, except one test that was extended to write twice. Its
budget was raised, with its `// gas: raised` note.

## 5. Questions for ARC-07

1. **The status model over A**: as §1.3 says, sharing slot A with the definition, read once,
   written as the whole of A.
2. **The name `QuestDefinition`.** It is now two types: the model
   (`quiver_quest::models::definition::QuestDefinition`) and slot A of 0.1.0
   (`quiver_quest::logic::QuestDefinition`, public, returned by the view `quest_definition`).
   ARC-07 should rename slot A to the status model.
3. **The view `definition()`** reads through the store's focused methods, because it returns
   slot A with its status. With the status model, it becomes one read of A, plus B and C.
4. **`QuestRetired` and the other events of the component** are not model events. They stay
   events of actions, like arcade's `store.complete`, emitted by the store without a model (§6).
5. **The cost audit's notes** (GPT-6-Astra, fix loop 1):
   - **Keep selective reads.** Read B only for a held quest, C only with conditions, R only on
     completion. No path reads a whole model it does not need.
   - **Read slot A once** when the status model is added (§1.3, rule 1).
   - **Distinguish model writes from action events.** The prerequisites' counter and partial
     progress emit nothing today, and must not start to. Tracking progress or the record must
     not add events, nor duplicate `QuestCompleted` (§6).

## 6. Events that carry a field not stored, and the other models (fix loop 1)

**The case.** `quiver_achievement` 0.1.0 emits `AchievementDefined { achievement_id, window,
tasks, points }`, but does not store `points`. Its slot A holds `start`, `end`, `task_count`,
`defined`, `retired` and `t0`; bits [196, 252) are reserved. A definition read back by `get_x`
therefore cannot produce its event: `Tracked::event(@model)` cannot build it from the model.

**Two ways**, and the choice:

| Rule | Verdict |
|---|---|
| **A tracked model holds every field its event carries** | **Chosen.** The event is then a function of the model, so a model read back and written again produces the same event, as a Dojo world's `write_model` does. `Tracked::event(@x)` needs nothing else. For achievements, `points` (u16) goes in 16 free bits of slot A, [196, 212), which `define` writes anyway: no extra slot. Measured here on an equivalent model, a third u16 field in the free bits of a one-felt model (`bench_store_set_wide_created`): **+200** on a created `set`, 2 steps of packing. `quiver_achievement` is outside this task's allowlist; ARC-07 measures its `define` with the field |
| `Tracked::event` takes what the store does not hold (`fn event(self: @M, extra: …)`) | Rejected. The event would no longer be a function of the model, the signature of `Tracked` would differ per model, and a model rewritten by another path could not emit its event |

**The rule for any model** whose event carries a field it does not store:

1. **Store the field in the model**, in free bits of a slot the model writes anyway, when there
   are free bits. The cost is the packing, a few steps.
2. **When there are no free bits** and the field would need a slot of its own (459 106 to
   create), **the event is not the model's**. The model is untracked, and the entrypoint emits
   that event as an **action event**, through a store method named for the action (arcade's
   `store.complete`), with the reason written next to it.

**Every other model of both packages**, against the convention:

| Model (package, slot) | Written by | Events today | Fits as |
|---|---|---|---|
| Quest definition (`quiver_quest`, A's head, B, C) | `define` | `QuestDefined`, on every write | **Tracked** (this task) |
| Quest status (`quiver_quest`, A's `defined`, `retired`, `live_dependents`) | `define` (sets `defined`, and a dependent's `+1`), `retire` (sets `retired`, and the prerequisites' `−1`) | `QuestRetired` on `retire` only; nothing on the counter | **Untracked**, sharing slot A (§1.3). `QuestRetired` is an action event |
| Quest progress P (`quiver_quest`, per player, quest, interval) | `progress_many` (every count), `claim` | `QuestCompleted` on completion only, `QuestClaimed` on claim; nothing on a partial count | **Untracked**. Tracking it would emit on every partial count, which 0.1.0 does not do. `QuestCompleted` and `QuestClaimed` stay action events, emitted once |
| Quest record R (`quiver_quest`, per player, quest) | completion, `claim`, the unlock cached by `accept` | `QuestCompleted` and `QuestClaimed` (the same actions as P); nothing on the unlock | **Untracked**. Tracking it would duplicate `QuestCompleted`, since P and R are written by the same completion, and add an event on the unlock |
| Held list (`quiver_quest`, per player, slot) | `accept`, `abandon` | none | **Untracked**: nothing is indexed |
| Quest reporters (`quiver_quest`) | `set_reporter` | `QuestReporterSet { reporter, allowed }`, on every write | **Tracked**: the event carries the key and the one stored value, on every write |
| Achievement definition (`quiver_achievement`, A, B) | `define`, `retire` | `AchievementDefined` (with `points`, not stored); `AchievementRetired` | **Tracked**, once `points` is stored in A's free bits (rule 1). Its `retired` bit is status: an untracked status sharing A, as for quests, with `AchievementRetired` as an action event |
| Achievement reporters (`quiver_achievement`) | `set_reporter` | `AchievementReporterSet`, on every write | **Tracked**, as quest reporters |
| Achievement progress (`quiver_achievement`, event mode only) | nothing stored | `AchievementProgressed` | Not a model: an action event |

## 7. Optional tracking, ARC-07a

| | |
|---|---|
| Task | ARC-07a ([brief](../briefs/ARC-07a-quest-0.2.0.md)), `[Opus 5.5]`, 2026-09-29 |
| Rule | The owner's review of ARC-06 (D-147): a model's event is optional for the consumer |
| Code | [`packages/quest/src/store.cairo`](../../packages/quest/src/store.cairo) (`QuestTracking`, `tracking::TrackAll`, `tracking::TrackNone`, `set_definition`, `set_reporter`) |
| Figures | [`packages/quest/GAS.md`](../../packages/quest/GAS.md#quiver_quest-020-arc-07a), snforge 0.61, L2 gas |

**The mechanism.** A model's `Tracked<M>` impl (§1.1) says **which** event it has. Whether a
write **emits** it is the consumer's choice, made at compile time:

```cairo
// quiver_quest::store
pub trait QuestTracking<TContractState> {
    const DEFINITION: bool;   // QuestDefined on define
    const REPORTER: bool;     // QuestReporterSet on set_reporter
}
pub mod tracking {
    pub impl TrackAll<TContractState> of super::QuestTracking<TContractState> { … true … }
    pub impl TrackNone<TContractState> of super::QuestTracking<TContractState> { … false … }
}

fn set_definition<impl Tracking: QuestTracking<TContractState>>(ref self: …, definition: QuestDefinition) {
    // the writes of A, B, C
    if Tracking::DEFINITION {
        HasComponent::emit(ref self, Tracked::event(@definition));
    }
}
```

The component's impls (`InternalImpl`, `QuestImpl`, `QuestViewImpl`) take the choice as an impl
parameter, like the hooks; the consumer writes `impl QuestTracking = TrackAll<ContractState>;`
(or `TrackNone`, or an impl of its own that tracks one model and not the other).

**Why the ready impls sit in a module of their own.** In a first build they were next to the
trait. The compiler looks for impls in the trait's module, found `TrackAll` there as well as the
consumer's alias, and refused the call as ambiguous (E2313). In `store::tracking` they are found
only where the consumer names them.

**Both mechanisms, measured first** (`tests/mock_tracking.cairo`, `tests/test_tracking.cairo`: one
model of one slot, created, each choice in its own contract with its hand-written twins):

| Choice | Mechanism | Store | By hand | Store − hand |
|---|---|---|---|---|
| Untracked (`TrackNone`) | the constant, `if Tracking::LOGGED` | 454 530 | 454 530 (the write, no event code) | **0** |
| Untracked (`TrackNone`) | an emitter impl per model, `Silent` (empty body) | 454 530 | 454 530 | **0** |
| Tracked (`TrackAll`) | the constant | 499 550 | 499 550 (the write, then `emit`) | **0** |
| Tracked (`TrackAll`) | an emitter impl per model, `Emit` | 499 550 | 499 550 | **0** |

Each figure is the benchmark minus its contract's baseline (280 260). The untracked write is
ARC-06's hand-written baseline to the unit (454 530, §4), and the tracked one ARC-06's tracked
`set` (499 550). **The compiler folds the constant**: the branch and the event code are gone from
the untracked choice. Both mechanisms meet the criterion; **the constant is adopted**, one trait
for all the tracked models instead of one impl parameter per model.

**On the package's own tracked models** (`tests/test_store_models.cairo`, `MockDefinitionStore`
under `TrackAll`, `MockSilentStore` under `TrackNone`):

| Model | Choice | Store | 0.1.0 by hand | Store − hand |
|---|---|---|---|---|
| `QuestReporter`, created | `TrackNone` | 454 630 | 454 630 (the write alone) | **0** |
| `QuestReporter`, created | `TrackAll` | 498 230 | 498 230 (the write, then `emit`) | **0** |
| `QuestDefinition`, 3 tasks, 7 conditions, A, B, C created | `TrackNone` | 1 497 390 | 1 502 350 (`definition_new`, the three writes) | −4 960 |
| `QuestDefinition`, the same | `TrackAll` | 1 652 890 | 1 657 450 (the same, then `emit`) | −4 560 |

The reporter is the write alone to the unit when untracked, and the write plus its event (43 600)
when tracked. The definition through the store is cheaper than 0.1.0's code under both choices:
`DefinitionTrait::new` validates for less than `definition_new` (ARC-06, §4). Its event costs
155 500 through the model and 155 100 by hand: the event is built from the model's fields rather
than from the call's arguments, 4 steps more, on the tracked choice only.

**What the tests check** (§1.4, extended): under `TrackAll`, each tracked `set_x` emits its event
once per write, created, changed and rewritten unchanged, with 0.1.0's keys and data
(`track_all_reporter_emits_once_per_write`, `store_set_definition_emits_quest_defined_once`,
`test_component_events`); under `TrackNone`, nothing, and the same felts are written
(`track_none_definition_emits_nothing`, `track_none_reporter_emits_nothing`); every untracked
model emits nothing whatever the choice and writes 0.1.0's layout
(`untracked_status_emits_nothing`, `untracked_progress_emits_nothing`,
`untracked_record_emits_nothing`, `untracked_held_slot_emits_nothing`). The component's own
tests run under `TrackAll`, as 0.1.0 behaves.

**The questions of §5, as ARC-07a answers them.**

1. The status model: `QuestStatus { id, defined, retired, live_dependents }`, untracked, in slot
   A. A path reads A once (`get_definition_head`) and takes the status from it
   (`head.status(id)`); `set_status(status, head)` writes the whole of A in one write.
2. `QuestDefinition` is the model only; slot A is `HeadSlot`, and the other slots `TasksSlot`,
   `ConditionsSlot`, `ProgressSlot`, `RecordSlot`, `HeldSlot`.
3. The view `quest_definition` reads A once, then B, and C with conditions, and returns
   `(HeadSlot, tasks, conditions)`, serialised as in 0.1.0.
4. `QuestProgressed`, `QuestCompleted`, `QuestClaimed` and `QuestRetired` stay action events,
   emitted by the component where 0.1.0 emits them, whatever the consumer tracks.
5. The cost audit's notes are kept: B is read only for a held quest, C only with conditions, R
   only on completion; A once per path; no model's write emits an action event, and the
   untracked models emit nothing.
