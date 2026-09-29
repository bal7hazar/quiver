# ARC-06 — The pattern of CAIRO.md §7: model, storage, tracked event, store

| | |
|---|---|
| Task | ARC-06 ([brief](../briefs/ARC-06-model-store.md)) |
| Written by | `[Opus 5.5]`, profile `implement`, 2026-09-29 |
| Rule | [CAIRO.md](../CAIRO.md) §7 and §8 (the owner's rule D-143) |
| Reference | `cartridge-gg/arcade` at `c53fadc`, `packages/quest/src/`: `models/definition.cairo`, `models/index.cairo`, `store.cairo`, `events/` |
| Reference model | [`packages/quest/src/models/definition.cairo`](../../packages/quest/src/models/definition.cairo), with [`models/index.cairo`](../../packages/quest/src/models/index.cairo), [`events/`](../../packages/quest/src/events/) and [`store.cairo`](../../packages/quest/src/store.cairo) |
| Figures | [`packages/quest/GAS.md`](../../packages/quest/GAS.md#the-store-and-the-definition-model-arc-06-unreleased), snforge 0.61, L2 gas, commit `0227486` |

**Summary.**

- **Tracked is a trait impl.** A model is tracked when it implements `Tracked<M>`, whose
  associated type `Event` is its event and whose `event(@model)` builds it. This is known at
  compile time; nothing is looked up at run time.
- **The component's state is the store.** `StoreTrait` is implemented on the component's
  `ComponentState`; nothing is built. `set_x` writes the model. For a tracked model only, it then
  emits `Tracked::event(@model)` through `HasComponent::emit`. A `set_x` that emits for a model
  with no `Tracked` impl does not compile.
- **Cost.** The store costs **exactly** what the same code costs by hand, to the unit of gas. This
  holds for an untracked and a tracked model, for a created and an overwritten slot, and for a
  read. A tracked `set` costs the untracked `set` plus 45 020, which is the event.
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
    fn get_definition(self: @ComponentState<TContractState>, id: u32) -> QuestDefinition { … }
    fn has_definition(self: @ComponentState<TContractState>, id: u32) -> bool { … }
    fn set_definition(ref self: ComponentState<TContractState>, definition: QuestDefinition) {
        // the writes of the model, then, because it is tracked:
        HasComponent::emit(ref self, Tracked::event(@definition));
    }
}
```

Inside the component, a call is `self.set_definition(definition)`. An untracked model's `set_x` is
the write alone (`MockModels::set_plain` in the tests).

What the compiler guarantees: `Tracked::event(@model)` resolves only for a model with a `Tracked`
impl, so an untracked model cannot emit. Cairo also requires the impl to be imported where it is
used, so the imports of `store.cairo` name the tracked models.

What it does not guarantee: that a tracked model's `set_x` does emit. One test per model covers
this (§1.4).

### 1.3 A model over several slots

The quest definition of 0.1.0 is spread over three slots, all keyed by the quest id:

- **A** holds the schedule, the counts, and the status: `defined`, `retired`, `live_dependents`.
- **B** holds the tasks.
- **C** holds the conditions, and is written only when the quest has conditions.

Three options were considered.

| Option | Verdict |
|---|---|
| **One model over A, B, C** (`QuestDefinition { id, schedule, tasks, conditions }`, arcade's shape), `DefinitionStorage::into_slots` and `from_slots` | **Chosen.** `get_definition` reads A, then B, then C only with conditions: as 0.1.0's view. `set_definition` writes C only with conditions: as 0.1.0's `define`. Reads 69 210 against 69 240 by hand; writes 1 652 890 against 1 657 450 |
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

**For ARC-07**, the status becomes its own untracked model over A. It must be read and written
as the whole of A (one read, one write, as 0.1.0 does), with the definition's bits written back
unchanged. Writing only the status bits would need a second read of A, because a storage write
sets a whole felt (§4, question 1).

**Presence.** `get_definition` of a quest not defined reads A alone and returns a model with no
task. The `define` check uses `has_definition`, which reads A alone. It is cheaper on every path
than `get_definition(..).assert_does_not_exist()` (§2.3).

### 1.4 How correctness is checked

| Property | Checked by |
|---|---|
| An untracked `set` emits nothing | `store_untracked_set_emits_nothing` (created, overwritten, rewritten unchanged: 0 events) |
| A tracked `set` emits exactly its event on every write | `store_tracked_set_emits_its_event_on_every_write` (4 writes: overwritten, created, changed, rewritten unchanged; 4 events with their keys and data); `store_set_definition_emits_quest_defined_once`; `test_component_events` (0.1.0's keys and data of `QuestDefined`, unchanged) |
| The store writes and reads what the hand writes | `store_writes_what_the_hand_writes`, `store_set_definition_writes_the_slots_of_0_1_0`, `store_get_definition_reads_the_model_back` |
| The model's checks, their order and strings are those of 0.1.0 | `test_model_definition` (`definition_rejects_*`, `definition_errors_are_those_of_0_1_0`) and the component's existing tests, all passing unchanged |
| The model's behaviour | `definition_schedule_matches_the_oracle`: `is_active` and `interval_id` against `schedule_is_active` and `schedule_interval_id` (8 schedules × 17 times) |

For an auditor (§8.3), `grep -n "of Tracked<"` lists the tracked models. Every `set_x` of those
models must call `Tracked::event`, and no other `set_x` may emit.

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
5. Tests: per model, a tracked `set` emits exactly its event on every write, or an untracked `set`
   emits nothing; the model's checks in order; the storage against its layout.

## 4. Cost

From the table of `packages/quest/GAS.md` (commit `0227486`). A cost is the benchmark minus its
baseline, both through a dispatcher.

| Operation | Slot | By hand | Store | Store − hand |
|---|---|---|---|---|
| `set`, untracked | created | 454 530 | 454 530 | 0 |
| `set`, untracked | overwritten | 52 530 | 52 530 | 0 |
| `set`, tracked (write + event) | created | 499 550 | 499 550 | 0 |
| `set`, tracked (write + event) | overwritten | 97 550 | 97 550 | 0 |
| `get` | existing | 32 590 | 32 590 | 0 |
| quest definition, write (3 tasks, 7 conditions; A, B, C created; `QuestDefined`) | created | 1 657 450 | 1 652 890 | −4 560 |
| quest definition, read (A, B, C) | existing | 69 240 | 69 210 | −30 |

The tracked `set` minus the untracked `set` is 45 020, created or overwritten: the event, and
nothing else.

| Entrypoint of `quiver_quest` | 0.1.0 | Now |
|---|---|---|
| `define`, 3 tasks, 7 conditions (`bench_define_worst`) | 2 590 440 | 2 583 680 |
| `progress_many`, the worst, H = 4, created | 6 213 063 | 6 213 063 |
| `progress_many`, H = 8, created | 11 430 213 | 11 430 213 |
| `retire`, 7 conditions | 1 003 240 | 1 003 240 |

No test of the package is more expensive than in 0.1.0's table; no budget was raised.

## 5. Questions for ARC-07

1. **The status model over A.** It could be read and written as the whole of A, with the
   definition's bits written back unchanged: 1 read, 1 write, as 0.1.0 does. The other way is to
   write the status bits only, which needs an extra read, about 30 000 per prerequisite in
   `define` and `retire`. The first is recommended.
2. **The name `QuestDefinition`.** It is now two types: the model
   (`quiver_quest::models::definition::QuestDefinition`) and slot A of 0.1.0
   (`quiver_quest::logic::QuestDefinition`, public, returned by the view `quest_definition`).
   ARC-07 should rename slot A to the status model.
3. **The view `definition()`** still reads its slots by hand, since it returns slot A with its
   status. Through the store, it would become `get_definition` plus the status model.
4. **`QuestRetired` and the other events of the component** are not model events. They stay
   events of actions, like arcade's `store.complete`, emitted by the store without a model.
