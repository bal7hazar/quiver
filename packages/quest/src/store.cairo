//! The store (D-143, ARC-06): the access to the component's storage, `get_x` and `set_x` per
//! model. Arcade's `Store` wraps a Dojo world; here the component's own state is the store:
//! `StoreTrait` is implemented on `ComponentState`, so a call is `self.get_definition(id)` inside
//! the component, with nothing built and nothing looked up at run time.
//!
//! `set_x` writes the model and, **if and only if the model is tracked**, emits its event: a
//! model is tracked when it implements `Tracked`, and `set_x` then calls `Tracked::event`, which
//! does not compile for a model that does not implement it. An untracked model's `set_x` is the
//! write alone.

use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};
use crate::component::QuestComponent::{ComponentState, HasComponent};
use crate::logic::types::{QuestConditions, QuestTask, QuestTasks};
use crate::models::definition::{DefinitionStorage, DefinitionTracked, QuestDefinition};

/// A model the indexer tracks: `Event` is what `Store::set_x` emits on every write of it, with the
/// model's keys and new values. The list of the impls of this trait is the list of tracked
/// models (D-130).
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

    /// Writes A, B, and C when the definition has conditions; emits `QuestDefined` (tracked). A
    /// definition never changes once written: the caller writes one for a quest not defined
    /// (`DefinitionAssert::assert_does_not_exist`), since A is written with the status of a new
    /// quest.
    #[inline]
    fn set_definition(ref self: ComponentState<TContractState>, definition: @QuestDefinition) {
        let id = *definition.id;
        let (slot_a, slot_b, slot_c) = definition.into_slots();
        self.Quest_definitions.write(id, slot_a);
        self.Quest_tasks.write(id, slot_b);
        if slot_a.condition_count != 0 {
            self.Quest_conditions.write(id, slot_c);
        }
        HasComponent::emit(ref self, Tracked::event(definition));
    }
}
