//! The store (D-143, ARC-06, ARC-07b): the only access to the component's storage, `get_x` and
//! `set_x` per model, and focused reads where a path needs less than the model. Arcade's `Store`
//! wraps a Dojo world; here the component's own state is the store: `StoreTrait` is implemented
//! on `ComponentState`, so a call is `self.get_definition(id)` inside the component, with nothing
//! built and nothing looked up at run time.
//!
//! **Tracked models** implement `Tracked`, which fixes their one event at compile time:
//! `AchievementDefinition` (`AchievementDefined`) and `AchievementReporter`
//! (`AchievementReporterSet`). `AchievementStatus` is untracked: its `set_status` is the write
//! alone. Progress is not stored (event mode only).
//!
//! **Optional tracking** (ARC-07b, as `quiver_quest` 0.2.0; the owner's review D-147): whether a
//! tracked model's `set_x` emits its event is the consumer's choice, made at compile time by its
//! impl of `AchievementTracking`, one constant per tracked model: `tracking::TrackAll` (every
//! tracked model emits, as 0.1.0) or `tracking::TrackNone`, or its own. `set_x` emits
//! `if Tracking::X`: the compiler folds the constant, so an untracked choice costs exactly the
//! write with no event code, and a tracked one the write plus the event (measured,
//! `tests/test_tracking.cairo`, `GAS.md`).
//!
//! **What the compiler enforces**: `Tracked::event` does not compile for a model without the
//! impl, so an untracked model's `set_x` cannot emit a model event through it. **What it does not
//! enforce, and the convention and tests do**: that a tracked model's `set_x` ends with
//! `if Tracking::X { HasComponent::emit(ref self, Tracked::event(@x)) }`, once; that no other
//! `set_x` emits. Tests, per tracked model under `TrackAll` and `TrackNone`, and for the
//! untracked status: `tests/test_store_models.cairo`.

use starknet::ContractAddress;
use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};
use crate::component::AchievementComponent::{ComponentState, HasComponent};
use crate::models::definition::{
    AchievementDefinition, DefinitionStorage, DefinitionTracked, HeadSlot, NO_TASKS, TasksSlot,
};
use crate::models::reporter::{AchievementReporter, ReporterTracked};
use crate::models::status::{AchievementStatus, StatusStorage};

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
/// like the hooks: the consumer writes `impl AchievementTracking = TrackAll<ContractState>;` (or
/// `TrackNone`, or its own impl) in its contract.
pub trait AchievementTracking<TContractState> {
    /// `AchievementDefined` on `define`.
    const DEFINITION: bool;
    /// `AchievementReporterSet` on `set_reporter`.
    const REPORTER: bool;
}

/// The two ready choices. They sit in a module of their own, not next to `AchievementTracking`:
/// the compiler looks for impls in the trait's module, and would find them there as well as the
/// consumer's own, and refuse the call as ambiguous (error E2313, ARC-06 §7).
pub mod tracking {
    use super::AchievementTracking;

    /// Every tracked model emits its event on every write, as 0.1.0.
    pub impl TrackAll<TContractState> of AchievementTracking<TContractState> {
        const DEFINITION: bool = true;
        const REPORTER: bool = true;
    }

    /// No model emits: the writes alone. The action events (`AchievementRetired`,
    /// `AchievementProgressed`) are emitted all the same.
    pub impl TrackNone<TContractState> of AchievementTracking<TContractState> {
        const DEFINITION: bool = false;
        const REPORTER: bool = false;
    }
}

#[generate_trait]
pub impl StoreImpl<
    TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
> of StoreTrait<TContractState> {
    // Definition: slots A and B. Tracked

    /// Reads A; then B, when the achievement has 2 or 3 tasks. An achievement not defined reads
    /// with no task, from A alone.
    #[inline]
    fn get_definition(self: @ComponentState<TContractState>, id: u32) -> AchievementDefinition {
        let slot_a = self.Achievement_definitions.read(id);
        let slot_b = if slot_a.task_count > 1 {
            self.Achievement_extra_tasks.read(id)
        } else {
            NO_TASKS
        };
        DefinitionStorage::from_slots(id, slot_a, slot_b)
    }

    /// Slot A alone, one read: the definition's window, first task and points, and the
    /// achievement's status (`head.status(id)`). What `define`, `retire` and the view need. Zero
    /// for an achievement not defined.
    #[inline]
    fn get_definition_head(self: @ComponentState<TContractState>, id: u32) -> HeadSlot {
        self.Achievement_definitions.read(id)
    }

    /// Slot B alone: the second and third tasks, zero when unused; `head.task_count` says how many
    /// are used. Read only for 2 or 3 tasks: B of an achievement of one task is never written.
    #[inline]
    fn get_definition_tasks(self: @ComponentState<TContractState>, id: u32) -> TasksSlot {
        self.Achievement_extra_tasks.read(id)
    }

    /// Writes A, and B for 2 or 3 tasks; then emits `AchievementDefined`, once, when the consumer
    /// tracks the definition. A definition never changes once written: the caller writes one for
    /// an achievement not defined (`get_status`), since A is written with the status of a new
    /// achievement. The model is taken by value, as every `set_x`: by snapshot costs 3 steps more
    /// (ARC-06).
    #[inline]
    fn set_definition<impl Tracking: AchievementTracking<TContractState>>(
        ref self: ComponentState<TContractState>, definition: AchievementDefinition,
    ) {
        let id = definition.id;
        let (slot_a, slot_b) = definition.into_slots();
        self.Achievement_definitions.write(id, slot_a);
        if slot_a.task_count > 1 {
            self.Achievement_extra_tasks.write(id, slot_b);
        }
        if Tracking::DEFINITION {
            HasComponent::emit(ref self, Tracked::event(@definition));
        }
    }

    // Status: slot A, shared with the definition. Untracked

    /// The status alone, from A.
    #[inline]
    fn get_status(self: @ComponentState<TContractState>, id: u32) -> AchievementStatus {
        self.Achievement_definitions.read(id).status(id)
    }

    /// Writes slot A with `status`, and the definition's bits of `head` unchanged, in one write;
    /// untracked: emits nothing. `head` is the A that the path read (`get_definition_head`), so
    /// that A is not read twice (docs/research/ARC-06-model-store.md §1.3).
    #[inline]
    fn set_status(
        ref self: ComponentState<TContractState>, status: AchievementStatus, head: HeadSlot,
    ) {
        self.Achievement_definitions.write(status.id, status.into_slot(head));
    }

    // Reporter. Tracked

    #[inline]
    fn get_reporter(
        self: @ComponentState<TContractState>, reporter: ContractAddress,
    ) -> AchievementReporter {
        AchievementReporter { reporter, allowed: self.Achievement_reporters.read(reporter) }
    }

    /// Writes the reporter; then emits `AchievementReporterSet`, once, when the consumer tracks
    /// reporters.
    #[inline]
    fn set_reporter<impl Tracking: AchievementTracking<TContractState>>(
        ref self: ComponentState<TContractState>, reporter: AchievementReporter,
    ) {
        self.Achievement_reporters.write(reporter.reporter, reporter.allowed);
        if Tracking::REPORTER {
            HasComponent::emit(ref self, Tracked::event(@reporter));
        }
    }
}

/// The ready choices' constants. The store's reads and writes need a deployed contract: their
/// tests are in `tests/test_store_models.cairo` and `tests/test_tracking.cairo`.
#[cfg(test)]
mod tests {
    use super::tracking::{TrackAll, TrackNone};

    #[test]
    #[available_gas(l2_gas: 20000)]
    fn tracking_choices_are_all_or_none() {
        assert!(TrackAll::<()>::DEFINITION && TrackAll::<()>::REPORTER);
        assert!(!TrackNone::<()>::DEFINITION && !TrackNone::<()>::REPORTER);
    }
}
