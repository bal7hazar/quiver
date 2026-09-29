//! The store (D-143, ARC-06, ARC-07a): the only access to the component's storage, `get_x` and
//! `set_x` per model, and focused reads where a path needs less than the model. Arcade's `Store`
//! wraps a Dojo world; here the component's own state is the store: `StoreTrait` is implemented
//! on `ComponentState`, so a call is `self.get_definition(id)` inside the component, with nothing
//! built and nothing looked up at run time.
//!
//! **Tracked models** implement `Tracked`, which fixes their one event at compile time:
//! `QuestDefinition` (`QuestDefined`) and `QuestReporter` (`QuestReporterSet`). The others,
//! `QuestStatus`, `QuestProgress`, `QuestRecord` and `QuestHeldSlot`, are untracked: their
//! `set_x` is the write alone.
//!
//! **Optional tracking** (ARC-07a, the owner's review D-147): whether a tracked model's `set_x`
//! emits its event is the consumer's choice, made at compile time by its impl of `QuestTracking`,
//! one constant per tracked model: `tracking::TrackAll` (every tracked model emits, as 0.1.0) or
//! `tracking::TrackNone`, or its own. `set_x` emits `if Tracking::X`: the compiler folds the
//! constant, so an untracked choice costs exactly the write with no event code, and a tracked one
//! the write plus the event (measured, `tests/test_tracking.cairo`, `GAS.md`).
//!
//! **What the compiler enforces**: `Tracked::event` does not compile for a model without the
//! impl, so an untracked model's `set_x` cannot emit a model event through it. **What it does not
//! enforce, and the convention and tests do**: that a tracked model's `set_x` ends with
//! `if Tracking::X { HasComponent::emit(ref self, Tracked::event(@x)) }`, once; that no other
//! `set_x` emits. Tests, per tracked model under `TrackAll` and `TrackNone`, and per untracked
//! model: `tests/test_store_models.cairo`.

use starknet::ContractAddress;
use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};
use crate::component::QuestComponent::{ComponentState, HasComponent};
use crate::models::definition::{
    ConditionsSlotTrait, DefinitionStorage, DefinitionTracked, HeadSlot, NO_CONDITIONS, NO_TASKS,
    QuestDefinition, TasksSlot,
};
use crate::models::held::{HeldSlotStorage, QuestHeldSlot};
use crate::models::progress::{ProgressStorage, QuestProgress};
use crate::models::record::{QuestRecord, RecordStorage};
use crate::models::reporter::{QuestReporter, ReporterTracked};
use crate::models::status::{QuestStatus, StatusStorage};

/// A model the indexer tracks: `Event` is what `Store::set_x` emits on every write of it, with the
/// model's keys and new values, when the consumer tracks it. The list of the impls of this trait
/// is the list of tracked models (D-130). It selects the event; it does not make `set_x` emit
/// (see the module's doc).
pub trait Tracked<M> {
    type Event;
    fn event(self: @M) -> Self::Event;
}

/// The consumer's choice of the tracked models whose writes emit their event: one constant per
/// tracked model, known at compile time. The component's impls take it as an impl parameter,
/// like the hooks: the consumer writes `impl QuestTracking = TrackAll<ContractState>;` (or
/// `TrackNone`, or its own impl) in its contract.
pub trait QuestTracking<TContractState> {
    /// `QuestDefined` on `define`.
    const DEFINITION: bool;
    /// `QuestReporterSet` on `set_reporter`.
    const REPORTER: bool;
}

/// The two ready choices. They sit in a module of their own, not next to `QuestTracking`: the
/// compiler looks for impls in the trait's module, and would find them there as well as the
/// consumer's own, and refuse the call as ambiguous.
pub mod tracking {
    use super::QuestTracking;

    /// Every tracked model emits its event on every write, as 0.1.0.
    pub impl TrackAll<TContractState> of QuestTracking<TContractState> {
        const DEFINITION: bool = true;
        const REPORTER: bool = true;
    }

    /// No model emits: the writes alone. The action events are emitted all the same.
    pub impl TrackNone<TContractState> of QuestTracking<TContractState> {
        const DEFINITION: bool = false;
        const REPORTER: bool = false;
    }
}

#[generate_trait]
pub impl StoreImpl<
    TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
> of StoreTrait<TContractState> {
    // Definition: slots A, B, C. Tracked

    /// Reads A; then B, and C when the quest has conditions. A quest not defined reads with no
    /// task, from A alone.
    #[inline]
    fn get_definition(self: @ComponentState<TContractState>, id: u32) -> QuestDefinition {
        let slot_a = self.Quest_definitions.read(id);
        if !slot_a.defined {
            return DefinitionStorage::from_slots(id, slot_a, NO_TASKS, NO_CONDITIONS);
        }
        let slot_b = self.Quest_tasks.read(id);
        let slot_c = if slot_a.condition_count == 0 {
            NO_CONDITIONS
        } else {
            self.Quest_conditions.read(id)
        };
        DefinitionStorage::from_slots(id, slot_a, slot_b, slot_c)
    }

    /// Whether `id` is defined, from A alone: the check of `define`, which needs no more.
    #[inline]
    fn has_definition(self: @ComponentState<TContractState>, id: u32) -> bool {
        self.Quest_definitions.read(id).defined
    }

    /// Slot A alone, one read: the definition's schedule and counts, and the quest's status
    /// (`head.status(id)`). What the hot paths (`accept`, `progress_many`) and `retire` need.
    /// Zero for a quest not defined.
    #[inline]
    fn get_definition_head(self: @ComponentState<TContractState>, id: u32) -> HeadSlot {
        self.Quest_definitions.read(id)
    }

    /// Slot B alone: the definition's tasks, packed, with unused entries zero; `head.task_count`
    /// says how many are used.
    #[inline]
    fn get_definition_tasks(self: @ComponentState<TContractState>, id: u32) -> TasksSlot {
        self.Quest_tasks.read(id)
    }

    /// The first `condition_count` ids of slot C, for a quest with conditions (`condition_count`
    /// non-zero; the callers skip C otherwise, as `get_definition` does, so that it is not read).
    #[inline]
    fn get_definition_conditions(
        self: @ComponentState<TContractState>, id: u32, condition_count: u8,
    ) -> Span<u32> {
        self.Quest_conditions.read(id).ids(condition_count)
    }

    /// Writes A, B, and C when the definition has conditions; then emits `QuestDefined`, once,
    /// when the consumer tracks the definition. A definition never changes once written: the
    /// caller writes one for a quest not defined (`has_definition`), since A is written with the
    /// status of a new quest. The model is taken by value, as every `set_x`: by snapshot costs 3
    /// steps more (ARC-06).
    #[inline]
    fn set_definition<impl Tracking: QuestTracking<TContractState>>(
        ref self: ComponentState<TContractState>, definition: QuestDefinition,
    ) {
        let id = definition.id;
        let (slot_a, slot_b, slot_c) = definition.into_slots();
        self.Quest_definitions.write(id, slot_a);
        self.Quest_tasks.write(id, slot_b);
        if slot_a.condition_count != 0 {
            self.Quest_conditions.write(id, slot_c);
        }
        if Tracking::DEFINITION {
            HasComponent::emit(ref self, Tracked::event(@definition));
        }
    }

    // Status: slot A, shared with the definition. Untracked

    /// The status alone, from A. The component's paths read A once with `get_definition_head`,
    /// which gives the schedule as well.
    #[inline]
    fn get_status(self: @ComponentState<TContractState>, id: u32) -> QuestStatus {
        self.Quest_definitions.read(id).status(id)
    }

    /// Writes slot A with `status`, and the definition's bits of `head` unchanged, in one write;
    /// untracked: emits nothing. `head` is the A that the path read (`get_definition_head`), so
    /// that A is not read twice (docs/research/ARC-06-model-store.md §1.3).
    #[inline]
    fn set_status(ref self: ComponentState<TContractState>, status: QuestStatus, head: HeadSlot) {
        self.Quest_definitions.write(status.id, status.into_slot(head));
    }

    // Progress: slot P. Untracked

    #[inline]
    fn get_progress(
        self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32, interval_id: u64,
    ) -> QuestProgress {
        let slot = self.Quest_progress.read((player_id, quest_id, interval_id));
        ProgressStorage::from_slot(player_id, quest_id, interval_id, slot)
    }

    #[inline]
    fn set_progress(ref self: ComponentState<TContractState>, progress: QuestProgress) {
        let key = (progress.player_id, progress.quest_id, progress.interval_id);
        self.Quest_progress.write(key, progress.into_slot());
    }

    // Record: slot R. Untracked

    #[inline]
    fn get_record(
        self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
    ) -> QuestRecord {
        RecordStorage::from_slot(player_id, quest_id, self.Quest_records.read((player_id, quest_id)))
    }

    #[inline]
    fn set_record(ref self: ComponentState<TContractState>, record: QuestRecord) {
        self.Quest_records.write((record.player_id, record.quest_id), record.into_slot());
    }

    // Held list: slot H, per player and index. Untracked

    #[inline]
    fn get_held_slot(
        self: @ComponentState<TContractState>, player_id: felt252, index: u8,
    ) -> QuestHeldSlot {
        HeldSlotStorage::from_slot(player_id, index, self.Quest_held.read((player_id, index)))
    }

    #[inline]
    fn set_held_slot(ref self: ComponentState<TContractState>, slot: QuestHeldSlot) {
        self.Quest_held.write((slot.player_id, slot.index), slot.into_slot());
    }

    // Reporter. Tracked

    #[inline]
    fn get_reporter(
        self: @ComponentState<TContractState>, reporter: ContractAddress,
    ) -> QuestReporter {
        QuestReporter { reporter, allowed: self.Quest_reporters.read(reporter) }
    }

    /// Writes the reporter; then emits `QuestReporterSet`, once, when the consumer tracks
    /// reporters.
    #[inline]
    fn set_reporter<impl Tracking: QuestTracking<TContractState>>(
        ref self: ComponentState<TContractState>, reporter: QuestReporter,
    ) {
        self.Quest_reporters.write(reporter.reporter, reporter.allowed);
        if Tracking::REPORTER {
            HasComponent::emit(ref self, Tracked::event(@reporter));
        }
    }
}
