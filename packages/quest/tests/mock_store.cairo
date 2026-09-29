//! The store's mechanism (ARC-06) on two models of one slot each, in a component of its own:
//! `Plain`, untracked, and `Logged`, tracked by `LoggedSet`. Each is written and read through the
//! store and by hand (the storage member itself, and `emit` for the tracked one), so that a
//! benchmark sets the one against the other. And `MockDefinitionStore`, which embeds
//! `QuestComponent` to set the store of every model of the package against the hand-written code
//! of 0.1.0, under `TrackAll`; `MockSilentStore`, its tracked models under `TrackNone` (ARC-07a).

use quiver_quest::models::definition::{HeadSlot as DefinitionSlot, QuestDefinition, TasksSlot};
use quiver_quest::models::held::QuestHeldSlot;
use quiver_quest::models::progress::QuestProgress;
use quiver_quest::models::record::QuestRecord;
use quiver_quest::models::status::QuestStatus;
use quiver_quest::store::Tracked;
use quiver_quest::types::schedule::QuestSchedule;
use quiver_quest::types::task::QuestTask;
use starknet::ContractAddress;
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

/// `Values` and a third field in its free bits: `c` [128, 144). For the cost of storing one more
/// field in a slot that is written anyway (ARC-06 fix loop 1, point 2).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct Wide {
    pub id: u32,
    pub a: u64,
    pub b: u64,
    pub c: u16,
}

#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct WideValues {
    pub a: u64,
    pub b: u64,
    pub c: u16,
}

pub impl WideValuesPacking of StorePacking<WideValues, felt252> {
    fn pack(value: WideValues) -> felt252 {
        value.a.into()
            + value.b.into() * 0x10000000000000000
            + value.c.into() * 0x100000000000000000000000000000000
    }

    fn unpack(value: felt252) -> WideValues {
        let value: u256 = value.into();
        let (b, a) = DivRem::div_rem(value.low, 0x10000000000000000);
        WideValues {
            a: a.try_into().unwrap(), b: b.try_into().unwrap(), c: value.high.try_into().unwrap(),
        }
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
    use super::{LoggedSet, Values, WideValues};

    #[storage]
    pub struct Storage {
        pub Mock_plain: Map<u32, Values>,
        pub Mock_logged: Map<u32, Values>,
        pub Mock_wide: Map<u32, WideValues>,
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
    use super::{Logged, LoggedTracked, Plain, Tracked, Values, Wide, WideValues};

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

        /// Untracked, three fields in one felt.
        #[inline]
        fn set_wide(ref self: ComponentState<TContractState>, wide: Wide) {
            self.Mock_wide.write(wide.id, WideValues { a: wide.a, b: wide.b, c: wide.c });
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
    /// The baseline of the reads: an id in, a value out.
    fn noop_get(self: @TState, id: u32) -> (u64, u64);
    fn noop_wide(ref self: TState, id: u32, a: u64, b: u64, c: u16);
    fn store_set_wide(ref self: TState, id: u32, a: u64, b: u64, c: u16);
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
    use super::{IMockModels, Logged, ModelsComponent, Plain, Wide};

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

        fn noop_get(self: @ContractState, id: u32) -> (u64, u64) {
            (1, 1)
        }

        fn noop_wide(ref self: ContractState, id: u32, a: u64, b: u64, c: u16) {}

        fn store_set_wide(ref self: ContractState, id: u32, a: u64, b: u64, c: u16) {
            self.models.set_wide(Wide { id, a, b, c });
        }

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
    /// The baseline of the reads: an id in, a value out.
    fn noop_read_definition(self: @TState, quest_id: u32) -> u32;
    /// The store's focused reads.
    fn store_get_definition_head(self: @TState, quest_id: u32) -> DefinitionSlot;
    fn store_get_definition_tasks(self: @TState, quest_id: u32) -> TasksSlot;
    fn store_get_definition_conditions(
        self: @TState, quest_id: u32, condition_count: u8,
    ) -> Span<u32>;
    /// The status: read from A, written back into the A read.
    fn store_get_status(self: @TState, quest_id: u32) -> QuestStatus;
    fn store_set_status(ref self: TState, quest_id: u32, retired: bool, live_dependents: u16);
    /// The other models, each through the store.
    fn store_set_progress(ref self: TState, progress: QuestProgress);
    fn store_get_progress(
        self: @TState, player_id: felt252, quest_id: u32, interval_id: u64,
    ) -> QuestProgress;
    fn store_set_record(ref self: TState, record: QuestRecord);
    fn store_get_record(self: @TState, player_id: felt252, quest_id: u32) -> QuestRecord;
    fn store_set_held_slot(ref self: TState, slot: QuestHeldSlot);
    fn store_get_held_slot(self: @TState, player_id: felt252, index: u8) -> QuestHeldSlot;
    fn noop_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    /// 0.1.0's `set_reporter`: the write, then `emit`.
    fn hand_set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    fn store_set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    fn store_get_reporter(self: @TState, reporter: ContractAddress) -> bool;
}

#[starknet::contract]
pub mod MockDefinitionStore {
    use quiver_quest::component::QuestComponent;
    use quiver_quest::component::QuestComponent::{QuestDefined, QuestReporterSet};
    use quiver_quest::models::definition::{DefinitionTrait, QuestDefinition};
    use quiver_quest::models::held::QuestHeldSlot;
    use quiver_quest::models::progress::QuestProgress;
    use quiver_quest::models::record::QuestRecord;
    use quiver_quest::models::reporter::QuestReporter;
    use quiver_quest::models::status::QuestStatus;
    use quiver_quest::store::StoreTrait;
    use quiver_quest::types::schedule::QuestSchedule;
    use quiver_quest::types::task::QuestTask;
    use starknet::ContractAddress;
    use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};
    use super::super::oracle::{conditions_span, definition_new, tasks_span};
    use super::{DefinitionSlot, IMockDefinitionStore, TasksSlot};

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    /// Every tracked model emits, as 0.1.0.
    impl QuestTracking = quiver_quest::store::tracking::TrackAll<ContractState>;

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

        fn noop_read_definition(self: @ContractState, quest_id: u32) -> u32 {
            70
        }

        fn store_get_definition_head(self: @ContractState, quest_id: u32) -> DefinitionSlot {
            self.quest.get_definition_head(quest_id)
        }

        fn store_get_definition_tasks(self: @ContractState, quest_id: u32) -> TasksSlot {
            self.quest.get_definition_tasks(quest_id)
        }

        fn store_get_definition_conditions(
            self: @ContractState, quest_id: u32, condition_count: u8,
        ) -> Span<u32> {
            self.quest.get_definition_conditions(quest_id, condition_count)
        }

        fn store_get_status(self: @ContractState, quest_id: u32) -> QuestStatus {
            self.quest.get_status(quest_id)
        }

        fn store_set_status(
            ref self: ContractState, quest_id: u32, retired: bool, live_dependents: u16,
        ) {
            let head = self.quest.get_definition_head(quest_id);
            let status = QuestStatus {
                id: quest_id, defined: head.defined, retired, live_dependents,
            };
            self.quest.set_status(status, head);
        }

        fn store_set_progress(ref self: ContractState, progress: QuestProgress) {
            self.quest.set_progress(progress);
        }

        fn store_get_progress(
            self: @ContractState, player_id: felt252, quest_id: u32, interval_id: u64,
        ) -> QuestProgress {
            self.quest.get_progress(player_id, quest_id, interval_id)
        }

        fn store_set_record(ref self: ContractState, record: QuestRecord) {
            self.quest.set_record(record);
        }

        fn store_get_record(
            self: @ContractState, player_id: felt252, quest_id: u32,
        ) -> QuestRecord {
            self.quest.get_record(player_id, quest_id)
        }

        fn store_set_held_slot(ref self: ContractState, slot: QuestHeldSlot) {
            self.quest.set_held_slot(slot);
        }

        fn store_get_held_slot(
            self: @ContractState, player_id: felt252, index: u8,
        ) -> QuestHeldSlot {
            self.quest.get_held_slot(player_id, index)
        }

        fn noop_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {}

        fn hand_set_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {
            self.quest.Quest_reporters.write(reporter, allowed);
            self
                .emit(
                    QuestComponent::Event::QuestReporterSet(QuestReporterSet { reporter, allowed }),
                );
        }

        fn store_set_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {
            StoreTrait::set_reporter(ref self.quest, QuestReporter { reporter, allowed });
        }

        fn store_get_reporter(self: @ContractState, reporter: ContractAddress) -> bool {
            self.quest.get_reporter(reporter).allowed
        }
    }
}

/// The tracked models under `TrackNone`, against the hand-written writes of 0.1.0 without their
/// `emit`: an untracked choice costs exactly the write with no event code (ARC-07a).
#[starknet::interface]
pub trait IMockSilentStore<TState> {
    fn noop(
        ref self: TState,
        quest_id: u32,
        schedule: QuestSchedule,
        tasks: Span<QuestTask>,
        conditions: Span<u32>,
    );
    /// 0.1.0's `define` without the prerequisites and without `emit`: `definition_new`, the three
    /// writes.
    fn hand_set_definition_silent(
        ref self: TState,
        quest_id: u32,
        schedule: QuestSchedule,
        tasks: Span<QuestTask>,
        conditions: Span<u32>,
    );
    /// `DefinitionTrait::new`, then `Store::set_definition` under `TrackNone`.
    fn store_set_definition(
        ref self: TState,
        quest_id: u32,
        schedule: QuestSchedule,
        tasks: Span<QuestTask>,
        conditions: Span<u32>,
    );
    fn noop_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    /// 0.1.0's `set_reporter` without `emit`: the write.
    fn hand_set_reporter_silent(ref self: TState, reporter: ContractAddress, allowed: bool);
    fn store_set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    fn store_get_reporter(self: @TState, reporter: ContractAddress) -> bool;
}

#[starknet::contract]
pub mod MockSilentStore {
    use quiver_quest::component::QuestComponent;
    use quiver_quest::models::definition::DefinitionTrait;
    use quiver_quest::models::reporter::QuestReporter;
    use quiver_quest::store::StoreTrait;
    use quiver_quest::types::schedule::QuestSchedule;
    use quiver_quest::types::task::QuestTask;
    use starknet::ContractAddress;
    use starknet::storage::StorageMapWriteAccess;
    use super::IMockSilentStore;
    use super::super::oracle::definition_new;

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    /// No model emits.
    impl QuestTracking = quiver_quest::store::tracking::TrackNone<ContractState>;

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
    impl MockSilentStoreImpl of IMockSilentStore<ContractState> {
        fn noop(
            ref self: ContractState,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
        ) {}

        fn hand_set_definition_silent(
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

        fn noop_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {}

        fn hand_set_reporter_silent(
            ref self: ContractState, reporter: ContractAddress, allowed: bool,
        ) {
            self.quest.Quest_reporters.write(reporter, allowed);
        }

        fn store_set_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {
            StoreTrait::set_reporter(ref self.quest, QuestReporter { reporter, allowed });
        }

        fn store_get_reporter(self: @ContractState, reporter: ContractAddress) -> bool {
            self.quest.get_reporter(reporter).allowed
        }
    }
}
