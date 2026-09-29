//! The store's mechanism (ARC-06) on two models of one slot each, in a component of its own:
//! `Plain`, untracked, and `Logged`, tracked by `LoggedSet`. Each is written and read through the
//! store and by hand (the storage member itself, and `emit` for the tracked one), so that a
//! benchmark sets the one against the other. And `MockDefinitionStore`, which embeds
//! `QuestComponent` to set the quest definition's store against the hand-written code of 0.1.0.

use quiver_quest::logic::{QuestDefinition as DefinitionSlot, QuestSchedule, QuestTask};
use quiver_quest::models::definition::QuestDefinition;
use quiver_quest::store::Tracked;
use starknet::storage_access::StorePacking;

/// Two fields and a key; the values fill one felt: `a` [0, 64) · `b` [64, 128).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct Plain {
    pub id: u32,
    pub a: u64,
    pub b: u64,
}

/// The same, tracked.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct Logged {
    pub id: u32,
    pub a: u64,
    pub b: u64,
}

/// The stored values of either model.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct Values {
    pub a: u64,
    pub b: u64,
}

pub impl ValuesPacking of StorePacking<Values, felt252> {
    fn pack(value: Values) -> felt252 {
        value.a.into() + value.b.into() * 0x10000000000000000
    }

    fn unpack(value: felt252) -> Values {
        let value: u128 = value.try_into().unwrap();
        let (b, a) = DivRem::div_rem(value, 0x10000000000000000);
        Values { a: a.try_into().unwrap(), b: b.try_into().unwrap() }
    }
}

#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct LoggedSet {
    #[key]
    pub id: u32,
    pub a: u64,
    pub b: u64,
}

pub impl LoggedTracked of Tracked<Logged> {
    type Event = LoggedSet;

    #[inline]
    fn event(self: @Logged) -> LoggedSet {
        LoggedSet { id: *self.id, a: *self.a, b: *self.b }
    }
}

#[starknet::component]
pub mod ModelsComponent {
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use super::{LoggedSet, Values};

    #[storage]
    pub struct Storage {
        pub Mock_plain: Map<u32, Values>,
        pub Mock_logged: Map<u32, Values>,
    }

    #[event]
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub enum Event {
        LoggedSet: LoggedSet,
    }

    /// The hand-written twins of the store's functions: what a component writes without a store.
    #[generate_trait]
    pub impl HandImpl<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of HandTrait<TContractState> {
        fn hand_set_plain(ref self: ComponentState<TContractState>, id: u32, a: u64, b: u64) {
            self.Mock_plain.write(id, Values { a, b });
        }

        fn hand_set_logged(ref self: ComponentState<TContractState>, id: u32, a: u64, b: u64) {
            self.Mock_logged.write(id, Values { a, b });
            self.emit(LoggedSet { id, a, b });
        }

        fn hand_get_plain(self: @ComponentState<TContractState>, id: u32) -> (u64, u64) {
            let Values { a, b } = self.Mock_plain.read(id);
            (a, b)
        }
    }
}

/// The store of `ModelsComponent`, written by the convention of `quiver_quest::store`.
pub mod models_store {
    use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};
    use super::ModelsComponent::{ComponentState, HasComponent};
    use super::{Logged, LoggedTracked, Plain, Tracked, Values};

    #[generate_trait]
    pub impl StoreImpl<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of StoreTrait<TContractState> {
        #[inline]
        fn get_plain(self: @ComponentState<TContractState>, id: u32) -> Plain {
            let Values { a, b } = self.Mock_plain.read(id);
            Plain { id, a, b }
        }

        /// Untracked: the write alone.
        #[inline]
        fn set_plain(ref self: ComponentState<TContractState>, plain: Plain) {
            self.Mock_plain.write(plain.id, Values { a: plain.a, b: plain.b });
        }

        #[inline]
        fn get_logged(self: @ComponentState<TContractState>, id: u32) -> Logged {
            let Values { a, b } = self.Mock_logged.read(id);
            Logged { id, a, b }
        }

        /// Tracked: the write, then its event.
        #[inline]
        fn set_logged(ref self: ComponentState<TContractState>, logged: Logged) {
            self.Mock_logged.write(logged.id, Values { a: logged.a, b: logged.b });
            HasComponent::emit(ref self, Tracked::event(@logged));
        }
    }
}

#[starknet::interface]
pub trait IMockModels<TState> {
    fn noop(ref self: TState, id: u32, a: u64, b: u64);
    fn hand_set_plain(ref self: TState, id: u32, a: u64, b: u64);
    fn store_set_plain(ref self: TState, id: u32, a: u64, b: u64);
    fn hand_set_logged(ref self: TState, id: u32, a: u64, b: u64);
    fn store_set_logged(ref self: TState, id: u32, a: u64, b: u64);
    fn hand_get_plain(self: @TState, id: u32) -> (u64, u64);
    fn store_get_plain(self: @TState, id: u32) -> (u64, u64);
    fn store_get_logged(self: @TState, id: u32) -> (u64, u64);
}

#[starknet::contract]
pub mod MockModels {
    use super::models_store::StoreTrait;
    use super::{IMockModels, Logged, ModelsComponent, Plain};

    component!(path: ModelsComponent, storage: models, event: ModelsEvent);

    impl HandImpl = ModelsComponent::HandImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        models: ModelsComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ModelsEvent: ModelsComponent::Event,
    }

    #[abi(embed_v0)]
    impl MockModelsImpl of IMockModels<ContractState> {
        fn noop(ref self: ContractState, id: u32, a: u64, b: u64) {}

        fn hand_set_plain(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.models.hand_set_plain(id, a, b);
        }

        fn store_set_plain(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.models.set_plain(Plain { id, a, b });
        }

        fn hand_set_logged(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.models.hand_set_logged(id, a, b);
        }

        fn store_set_logged(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.models.set_logged(Logged { id, a, b });
        }

        fn hand_get_plain(self: @ContractState, id: u32) -> (u64, u64) {
            self.models.hand_get_plain(id)
        }

        fn store_get_plain(self: @ContractState, id: u32) -> (u64, u64) {
            let Plain { id: _, a, b } = self.models.get_plain(id);
            (a, b)
        }

        fn store_get_logged(self: @ContractState, id: u32) -> (u64, u64) {
            let Logged { id: _, a, b } = self.models.get_logged(id);
            (a, b)
        }
    }
}

#[starknet::interface]
pub trait IMockDefinitionStore<TState> {
    fn noop(
        ref self: TState,
        quest_id: u32,
        schedule: QuestSchedule,
        tasks: Span<QuestTask>,
        conditions: Span<u32>,
    );
    /// 0.1.0's `define` without the prerequisites: `definition_new`, the three writes, `emit`.
    fn hand_set_definition(
        ref self: TState,
        quest_id: u32,
        schedule: QuestSchedule,
        tasks: Span<QuestTask>,
        conditions: Span<u32>,
    );
    /// `DefinitionTrait::new`, then `Store::set_definition`.
    fn store_set_definition(
        ref self: TState,
        quest_id: u32,
        schedule: QuestSchedule,
        tasks: Span<QuestTask>,
        conditions: Span<u32>,
    );
    /// 0.1.0's reads of the view `definition`: A, B, C (with conditions), the spans.
    fn hand_get_definition(
        self: @TState, quest_id: u32,
    ) -> (DefinitionSlot, Span<QuestTask>, Span<u32>);
    fn store_get_definition(self: @TState, quest_id: u32) -> QuestDefinition;
    fn store_has_definition(self: @TState, quest_id: u32) -> bool;
    /// The benchmarks' reads: the same as the two above, returning one number.
    fn hand_read_definition(self: @TState, quest_id: u32) -> u32;
    fn store_read_definition(self: @TState, quest_id: u32) -> u32;
}

#[starknet::contract]
pub mod MockDefinitionStore {
    use quiver_quest::component::QuestComponent;
    use quiver_quest::component::QuestComponent::QuestDefined;
    use quiver_quest::logic::{
        QuestDefinition as DefinitionSlot, QuestSchedule, QuestTask, conditions_span,
        definition_new, tasks_span,
    };
    use quiver_quest::models::definition::{DefinitionTrait, QuestDefinition};
    use quiver_quest::store::StoreTrait;
    use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};
    use super::IMockDefinitionStore;

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        quest: QuestComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        QuestEvent: QuestComponent::Event,
    }

    #[abi(embed_v0)]
    impl MockDefinitionStoreImpl of IMockDefinitionStore<ContractState> {
        fn noop(
            ref self: ContractState,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
        ) {}

        fn hand_set_definition(
            ref self: ContractState,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
        ) {
            let (definition, quest_tasks, quest_conditions) = definition_new(
                quest_id, schedule, tasks, conditions,
            );
            self.quest.Quest_definitions.write(quest_id, definition);
            self.quest.Quest_tasks.write(quest_id, quest_tasks);
            if definition.condition_count != 0 {
                self.quest.Quest_conditions.write(quest_id, quest_conditions);
            }
            self
                .emit(
                    QuestComponent::Event::QuestDefined(
                        QuestDefined { quest_id, schedule, tasks, conditions },
                    ),
                );
        }

        fn store_set_definition(
            ref self: ContractState,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
        ) {
            let definition = DefinitionTrait::new(quest_id, schedule, tasks, conditions);
            self.quest.set_definition(definition);
        }

        fn hand_get_definition(
            self: @ContractState, quest_id: u32,
        ) -> (DefinitionSlot, Span<QuestTask>, Span<u32>) {
            let definition = self.quest.Quest_definitions.read(quest_id);
            let quest_tasks = self.quest.Quest_tasks.read(quest_id);
            let conditions = if definition.condition_count == 0 {
                array![].span()
            } else {
                conditions_span(
                    @self.quest.Quest_conditions.read(quest_id), definition.condition_count,
                )
            };
            (definition, tasks_span(@quest_tasks, definition.task_count), conditions)
        }

        fn store_get_definition(self: @ContractState, quest_id: u32) -> QuestDefinition {
            self.quest.get_definition(quest_id)
        }

        fn store_has_definition(self: @ContractState, quest_id: u32) -> bool {
            self.quest.has_definition(quest_id)
        }

        fn hand_read_definition(self: @ContractState, quest_id: u32) -> u32 {
            let (definition, tasks, conditions) = self.hand_get_definition(quest_id);
            definition.schedule.duration + tasks.len() + conditions.len()
        }

        fn store_read_definition(self: @ContractState, quest_id: u32) -> u32 {
            let definition = self.quest.get_definition(quest_id);
            definition.schedule.duration + definition.tasks.len() + definition.conditions.len()
        }
    }
}
