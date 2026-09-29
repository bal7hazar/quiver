//! The store (D-143, ARC-06): the only access to the component's storage of a definition,
//! `get_x` and `set_x` per model, and focused reads where a path needs less than the model.
//! Arcade's `Store` wraps a Dojo world; here the component's own state is the store: `StoreTrait`
//! is implemented on `ComponentState`, so a call is `self.get_definition(id)` inside the
//! component, with nothing built and nothing looked up at run time.
//!
//! `set_x` writes the model and, if the model is tracked, emits its event.
//!
//! **What the compiler enforces**: a model is tracked when it implements `Tracked`, which fixes
//! its one event type at compile time; `Tracked::event` does not compile for a model without the
//! impl, so an untracked model's `set_x` cannot emit a model event through it.
//!
//! **What it does not enforce, and the convention and tests do**: that a tracked model's `set_x`
//! calls `HasComponent::emit(ref self, Tracked::event(@x))` once, after its writes; that it does
//! not emit twice; that an untracked `set_x` does not emit some event by hand. Each package has,
//! per tracked model, a test that its `set_x` emits exactly its event once per write, and per
//! untracked model a test that its `set_x` emits nothing (`tests/test_store_definition.cairo`:
//! `store_set_definition_emits_quest_defined_once`,
//! `store_status_write_emits_nothing_and_keeps_the_definition`).
//!
//! **The quest's status** (`defined`, `retired`, `live_dependents`) shares slot A with the
//! definition and is not part of the definition model. It is read with the definition's head in
//! one read (`get_definition_head`) and written by `set_definition_status`, untracked: its
//! changes have their own action events (`QuestRetired`) or none (the prerequisites' counter).
//! ARC-07 makes it a model of its own over slot A (docs/research/ARC-06-model-store.md §1.3).

use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};
use crate::component::QuestComponent::{ComponentState, HasComponent};
use crate::logic::conditions_span;
use crate::logic::types::{
    QuestConditions, QuestDefinition as DefinitionHead, QuestTask, QuestTasks,
};
use crate::models::definition::{DefinitionStorage, DefinitionTracked, QuestDefinition};

/// A model the indexer tracks: `Event` is what `Store::set_x` emits on every write of it, with the
/// model's keys and new values. The list of the impls of this trait is the list of tracked
/// models (D-130). It selects the event; it does not make `set_x` emit (see the module's doc).
pub trait Tracked<M> {
    type Event;
    fn event(self: @M) -> Self::Event;
}

const NO_TASK: QuestTask = QuestTask { task_id: 0, total: 0 };
const NO_TASKS: QuestTasks = QuestTasks { t0: NO_TASK, t1: NO_TASK, t2: NO_TASK };
const NO_CONDITIONS: QuestConditions = QuestConditions {
    q0: 0, q1: 0, q2: 0, q3: 0, q4: 0, q5: 0, q6: 0,
};

#[generate_trait]
pub impl StoreImpl<
    TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
> of StoreTrait<TContractState> {
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

    /// Slot A alone, one read: the definition's schedule and counts, and the quest's status. What
    /// the hot paths (`accept`, `progress_many`) and the checks of `retire` need. Zero for a quest
    /// not defined.
    #[inline]
    fn get_definition_head(self: @ComponentState<TContractState>, id: u32) -> DefinitionHead {
        self.Quest_definitions.read(id)
    }

    /// Slot B alone: the definition's tasks, packed, with unused entries zero; `head.task_count`
    /// says how many are used.
    #[inline]
    fn get_definition_tasks(self: @ComponentState<TContractState>, id: u32) -> QuestTasks {
        self.Quest_tasks.read(id)
    }

    /// The first `condition_count` ids of slot C, for a quest with conditions (`condition_count`
    /// non-zero; the callers skip C otherwise, as `get_definition` does, so that it is not read).
    #[inline]
    fn get_definition_conditions(
        self: @ComponentState<TContractState>, id: u32, condition_count: u8,
    ) -> Span<u32> {
        conditions_span(@self.Quest_conditions.read(id), condition_count)
    }

    /// Writes A, B, and C when the definition has conditions; emits `QuestDefined` (tracked), once.
    /// A definition never changes once written: the caller writes one for a quest not defined
    /// (`has_definition`), since A is written with the status of a new quest. The model is taken
    /// by value, as every `set_x`: by snapshot costs 3 steps more (ARC-06).
    #[inline]
    fn set_definition(ref self: ComponentState<TContractState>, definition: QuestDefinition) {
        let id = definition.id;
        let (slot_a, slot_b, slot_c) = definition.into_slots();
        self.Quest_definitions.write(id, slot_a);
        self.Quest_tasks.write(id, slot_b);
        if slot_a.condition_count != 0 {
            self.Quest_conditions.write(id, slot_c);
        }
        HasComponent::emit(ref self, Tracked::event(@definition));
    }

    /// Writes slot A with the status of `head` (`retired`, `live_dependents`), untracked: emits
    /// nothing. `head` is the one `get_definition_head` read, changed in its status only: the
    /// definition's fields are written back as they were, in the same single write.
    #[inline]
    fn set_definition_status(
        ref self: ComponentState<TContractState>, id: u32, head: DefinitionHead,
    ) {
        self.Quest_definitions.write(id, head);
    }
}
