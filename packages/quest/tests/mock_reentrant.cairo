//! `MockReentrant`: hooks that re-enter the component once, on demand, through its internal
//! layer, as a consumer's hook can. Every caller is authorized; each hook logs its own call
//! (`HookCall`, with the state it read) before re-entering.

use super::mocks::HookCall;

/// What a hook does once, after logging its own call.
#[derive(Drop, Copy, Serde, PartialEq, Debug, starknet::Store)]
pub struct Reentry {
    /// The hook that triggers it: `'complete'` or `'claim'`; 0 for none.
    pub hook: felt252,
    /// Only when that hook is called for this quest.
    pub on_quest: u32,
    /// `'progress'`, `'claim'`, `'accept'` or `'retire'`.
    pub action: felt252,
    pub quest_id: u32,
    pub task_id: u32,
    pub count: u32,
    pub interval_id: u64,
}

#[starknet::interface]
pub trait IMockReentrant<TState> {
    fn set_reentry(ref self: TState, reentry: Reentry);
    fn hook_count(self: @TState) -> u32;
    fn hook_call(self: @TState, index: u32) -> HookCall;
}

#[starknet::contract]
pub mod MockReentrant {
    use quiver_quest::component::QuestComponent;
    use quiver_quest::logic::Mode;
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use super::super::mocks::HookCall;
    use super::{IMockReentrant, Reentry};

    component!(path: QuestComponent, storage: quest, event: QuestEvent);

    #[abi(embed_v0)]
    impl QuestImpl = QuestComponent::QuestImpl<ContractState>;
    #[abi(embed_v0)]
    impl QuestViewImpl = QuestComponent::QuestViewImpl<ContractState>;
    impl QuestInternalImpl = QuestComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        quest: QuestComponent::Storage,
        reentry: Reentry,
        hook_count: u32,
        hook_calls: Map<u32, HookCall>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        QuestEvent: QuestComponent::Event,
    }

    fn log(ref self: ContractState, call: HookCall) {
        let count = self.hook_count.read();
        self.hook_calls.write(count, call);
        self.hook_count.write(count + 1);
    }

    /// Runs the pending re-entry if it is for `hook` on `quest_id`, clearing it first so that it
    /// runs once.
    fn reenter(
        ref self: QuestComponent::ComponentState<ContractState>,
        hook: felt252,
        player_id: felt252,
        quest_id: u32,
    ) {
        let mut contract = self.get_contract_mut();
        let reentry = contract.reentry.read();
        if reentry.hook == 0 || reentry.hook != hook || reentry.on_quest != quest_id {
            return;
        }
        contract.reentry.write(Reentry { hook: 0, ..reentry });
        if reentry.action == 'progress' {
            QuestInternalImpl::progress(ref self, player_id, reentry.task_id, reentry.count, Mode::Storage);
        } else if reentry.action == 'claim' {
            QuestInternalImpl::claim(ref self, player_id, reentry.quest_id, reentry.interval_id);
        } else if reentry.action == 'accept' {
            QuestInternalImpl::accept(ref self, player_id, reentry.quest_id);
        } else if reentry.action == 'retire' {
            QuestInternalImpl::retire(ref self, reentry.quest_id);
        }
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
            let record = self.record_of(player_id, quest_id);
            let progress = self.progress_of(player_id, quest_id, interval_id);
            let mut contract = self.get_contract_mut();
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
            reenter(ref self, 'complete', player_id, quest_id);
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
            reenter(ref self, 'claim', player_id, quest_id);
        }
    }

    #[abi(embed_v0)]
    impl MockReentrantImpl of IMockReentrant<ContractState> {
        fn set_reentry(ref self: ContractState, reentry: Reentry) {
            self.reentry.write(reentry);
        }

        fn hook_count(self: @ContractState) -> u32 {
            self.hook_count.read()
        }

        fn hook_call(self: @ContractState, index: u32) -> HookCall {
            self.hook_calls.read(index)
        }
    }
}
