//! Mock consumers of `QuestComponent`, deployed by the tests.
//!
//! - `MockQuest` embeds the external impls `QuestImpl` and `QuestViewImpl`. Its admin is set at
//!   deployment; each player id has an owner. Its hooks log every call with what they saw of the
//!   component's state, and can be told to panic.
//! - `MockConsumer` is the consumer of ARC-01 §3.8: it embeds only `QuestViewImpl` and calls the
//!   internal layer from its own entrypoints, after its own checks.

use starknet::ContractAddress;

/// One hook call, with the state the hook read from the component when it ran.
#[derive(Drop, Copy, Serde, PartialEq, Debug, starknet::Store)]
pub struct HookCall {
    /// `'complete'` or `'claim'`.
    pub kind: felt252,
    pub player_id: felt252,
    pub quest_id: u32,
    pub interval_id: u64,
    /// `completions` or `claim_index`.
    pub value: u64,
    /// The record's `completions` (complete) or `claims` (claim), read inside the hook.
    pub seen_counter: u64,
    /// The progress's `completed` (complete) or `claimed` (claim), read inside the hook.
    pub seen_flag: bool,
}

#[starknet::interface]
pub trait IMockQuest<TState> {
    fn set_owner(ref self: TState, player_id: felt252, owner: ContractAddress);
    fn set_panics(ref self: TState, on_complete: bool, on_claim: bool);
    fn hook_count(self: @TState) -> u32;
    fn hook_call(self: @TState, index: u32) -> HookCall;
}

#[starknet::interface]
pub trait IMockConsumer<TState> {
    fn define_quest(
        ref self: TState,
        quest_id: u32,
        schedule: quiver_quest::types::schedule::QuestSchedule,
        tasks: Span<quiver_quest::types::task::QuestTask>,
        conditions: Span<u32>,
    );
    fn submit_results(
        ref self: TState,
        adventurer_id: felt252,
        progress: Span<quiver_quest::types::batch::TaskProgress>,
    );
    fn accept_quest(ref self: TState, adventurer_id: felt252, quest_id: u32);
    fn claim_quest(
        ref self: TState, adventurer_id: felt252, quest_id: u32, interval_id: u64,
    ) -> u64;
}

#[starknet::contract]
pub mod MockQuest {
    use quiver_quest::component::QuestComponent;
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use super::{HookCall, IMockQuest};

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    /// Every tracked model emits, as 0.1.0.
    impl QuestTracking = quiver_quest::store::tracking::TrackAll<ContractState>;

    #[abi(embed_v0)]
    impl QuestImpl = QuestComponent::QuestImpl<ContractState>;
    #[abi(embed_v0)]
    impl QuestViewImpl = QuestComponent::QuestViewImpl<ContractState>;
    impl QuestInternalImpl = QuestComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        quest: QuestComponent::Storage,
        admin: ContractAddress,
        owners: Map<felt252, ContractAddress>,
        panic_on_complete: bool,
        panic_on_claim: bool,
        hook_count: u32,
        hook_calls: Map<u32, HookCall>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        QuestEvent: QuestComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        self.admin.write(admin);
    }

    fn log(ref self: ContractState, call: HookCall) {
        let count = self.hook_count.read();
        self.hook_calls.write(count, call);
        self.hook_count.write(count + 1);
    }

    impl QuestHooks of QuestComponent::QuestHooksTrait<ContractState> {
        fn authorize_admin(
            self: @QuestComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            caller == self.get_contract().admin.read()
        }

        fn authorize_player(
            self: @QuestComponent::ComponentState<ContractState>,
            caller: ContractAddress,
            player_id: felt252,
        ) -> bool {
            caller == self.get_contract().owners.read(player_id)
        }

        fn on_quest_complete(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            completions: u64,
        ) {
            let record = self.record_of(player_id, quest_id);
            let progress = self.progress_of(player_id, quest_id, interval_id);
            let mut contract = self.get_contract_mut();
            assert(!contract.panic_on_complete.read(), 'Mock: complete refused');
            log(
                ref contract,
                HookCall {
                    kind: 'complete',
                    player_id,
                    quest_id,
                    interval_id,
                    value: completions,
                    seen_counter: record.completions,
                    seen_flag: progress.completed,
                },
            );
        }

        fn on_quest_claim(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            claim_index: u64,
        ) {
            let record = self.record_of(player_id, quest_id);
            let progress = self.progress_of(player_id, quest_id, interval_id);
            let mut contract = self.get_contract_mut();
            assert(!contract.panic_on_claim.read(), 'Mock: claim refused');
            log(
                ref contract,
                HookCall {
                    kind: 'claim',
                    player_id,
                    quest_id,
                    interval_id,
                    value: claim_index,
                    seen_counter: record.claims,
                    seen_flag: progress.claimed,
                },
            );
        }
    }

    #[abi(embed_v0)]
    impl MockQuestImpl of IMockQuest<ContractState> {
        fn set_owner(ref self: ContractState, player_id: felt252, owner: ContractAddress) {
            self.owners.write(player_id, owner);
        }

        fn set_panics(ref self: ContractState, on_complete: bool, on_claim: bool) {
            self.panic_on_complete.write(on_complete);
            self.panic_on_claim.write(on_claim);
        }

        fn hook_count(self: @ContractState) -> u32 {
            self.hook_count.read()
        }

        fn hook_call(self: @ContractState, index: u32) -> HookCall {
            self.hook_calls.read(index)
        }
    }
}

#[starknet::contract]
pub mod MockConsumer {
    use quiver_quest::component::QuestComponent;
    use quiver_quest::types::batch::TaskProgress;
    use quiver_quest::types::mode::Mode;
    use quiver_quest::types::schedule::QuestSchedule;
    use quiver_quest::types::task::QuestTask;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    use super::IMockConsumer;

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    /// Every tracked model emits, as 0.1.0.
    impl QuestTracking = quiver_quest::store::tracking::TrackAll<ContractState>;

    #[abi(embed_v0)]
    impl QuestViewImpl = QuestComponent::QuestViewImpl<ContractState>;
    impl QuestInternalImpl = QuestComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        quest: QuestComponent::Storage,
        ephemeral: ContractAddress,
        admin: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        QuestEvent: QuestComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress, ephemeral: ContractAddress) {
        self.admin.write(admin);
        self.ephemeral.write(ephemeral);
    }

    impl QuestHooks of QuestComponent::QuestHooksTrait<ContractState> {
        fn authorize_admin(
            self: @QuestComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            false // QuestImpl is not embedded: the consumer's own entrypoints call the internals
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
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            completions: u64,
        ) {}

        fn on_quest_claim(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            claim_index: u64,
        ) {}
    }

    #[abi(embed_v0)]
    impl MockConsumerImpl of IMockConsumer<ContractState> {
        fn define_quest(
            ref self: ContractState,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
        ) {
            assert(get_caller_address() == self.admin.read(), 'not admin');
            self.quest.define(quest_id, schedule, tasks, conditions);
        }

        fn submit_results(
            ref self: ContractState, adventurer_id: felt252, progress: Span<TaskProgress>,
        ) {
            assert(get_caller_address() == self.ephemeral.read(), 'not ephemeral');
            self.quest.progress_many(adventurer_id, progress, Mode::Storage);
        }

        fn accept_quest(ref self: ContractState, adventurer_id: felt252, quest_id: u32) {
            self.quest.accept(adventurer_id, quest_id);
        }

        fn claim_quest(
            ref self: ContractState, adventurer_id: felt252, quest_id: u32, interval_id: u64,
        ) -> u64 {
            self.quest.claim(adventurer_id, quest_id, interval_id)
        }
    }
}

/// For the benchmarks of D-135: as `MockBench`, but `on_quest_complete` writes one storage slot
/// per completion, a different one for each quest (`completions[quest_id]`), as a consumer that
/// records completions for a title would.
#[starknet::contract]
pub mod MockBenchHook {
    use quiver_quest::component::QuestComponent;
    use starknet::ContractAddress;
    use starknet::storage::{Map, StorageMapWriteAccess};

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    /// Every tracked model emits, as 0.1.0.
    impl QuestTracking = quiver_quest::store::tracking::TrackAll<ContractState>;

    #[abi(embed_v0)]
    impl QuestImpl = QuestComponent::QuestImpl<ContractState>;
    #[abi(embed_v0)]
    impl QuestViewImpl = QuestComponent::QuestViewImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        quest: QuestComponent::Storage,
        completions: Map<u32, u64>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        QuestEvent: QuestComponent::Event,
    }

    impl QuestHooks of QuestComponent::QuestHooksTrait<ContractState> {
        fn authorize_admin(
            self: @QuestComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            true
        }

        fn authorize_player(
            self: @QuestComponent::ComponentState<ContractState>,
            caller: ContractAddress,
            player_id: felt252,
        ) -> bool {
            true
        }

        fn on_quest_complete(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            completions: u64,
        ) {
            let mut contract = self.get_contract_mut();
            contract.completions.write(quest_id, completions);
        }

        fn on_quest_claim(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            claim_index: u64,
        ) {}
    }
}

/// For the benchmarks: authorizes every caller and its hooks do nothing, so that a measure is
/// the component's own cost.
#[starknet::contract]
pub mod MockBench {
    use quiver_quest::component::QuestComponent;
    use starknet::ContractAddress;

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    /// Every tracked model emits, as 0.1.0.
    impl QuestTracking = quiver_quest::store::tracking::TrackAll<ContractState>;

    #[abi(embed_v0)]
    impl QuestImpl = QuestComponent::QuestImpl<ContractState>;
    #[abi(embed_v0)]
    impl QuestViewImpl = QuestComponent::QuestViewImpl<ContractState>;

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

    impl QuestHooks of QuestComponent::QuestHooksTrait<ContractState> {
        fn authorize_admin(
            self: @QuestComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            true
        }

        fn authorize_player(
            self: @QuestComponent::ComponentState<ContractState>,
            caller: ContractAddress,
            player_id: felt252,
        ) -> bool {
            true
        }

        fn on_quest_complete(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            completions: u64,
        ) {}

        fn on_quest_claim(
            ref self: QuestComponent::ComponentState<ContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            claim_index: u64,
        ) {}
    }
}
