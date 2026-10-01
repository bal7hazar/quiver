//! Mock consumers of `AchievementComponent`, deployed by the tests. Each names its tracking choice
//! (`quiver_achievement::store::AchievementTracking`), as a consumer of 0.2.0 does.
//!
//! - `MockAchievement` embeds the external impls `AchievementImpl` and `AchievementViewImpl`. Its
//!   admin is set at deployment. `TrackAll`.
//! - `MockConsumer` is the consumer of ARC-01 §3.8 for titles: it embeds only
//!   `AchievementViewImpl` and calls the internal layer from its own entrypoints, after its own
//!   checks. `TrackAll`.
//! - `MockBench` authorizes every caller, so that a benchmark measures the component's own cost.
//!   `TrackAll`, as 0.1.0. `MockBenchSilent` is the same under `TrackNone`.

use quiver_achievement::types::batch::TaskProgress;
use quiver_achievement::types::task::AchievementTask;
use quiver_achievement::types::window::AchievementWindow;

#[starknet::interface]
pub trait IMockConsumer<TState> {
    fn define_achievement(
        ref self: TState,
        achievement_id: u32,
        window: AchievementWindow,
        tasks: Span<AchievementTask>,
        points: u16,
    );
    fn submit_results(ref self: TState, adventurer_id: felt252, progress: Span<TaskProgress>);
}

#[starknet::contract]
pub mod MockAchievement {
    use quiver_achievement::component::AchievementComponent;
    use starknet::ContractAddress;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    component!(path: AchievementComponent, storage: achievement, event: AchievementEvent);

    #[abi(embed_v0)]
    impl AchievementImpl = AchievementComponent::AchievementImpl<ContractState>;
    #[abi(embed_v0)]
    impl AchievementViewImpl =
        AchievementComponent::AchievementViewImpl<ContractState>;

    impl AchievementTracking = quiver_achievement::store::tracking::TrackAll<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        achievement: AchievementComponent::Storage,
        admin: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AchievementEvent: AchievementComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        self.admin.write(admin);
    }

    impl AchievementHooks of AchievementComponent::AchievementHooksTrait<ContractState> {
        fn authorize_admin(
            self: @AchievementComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            caller == self.get_contract().admin.read()
        }
    }
}

#[starknet::contract]
pub mod MockConsumer {
    use quiver_achievement::component::AchievementComponent;
    use quiver_achievement::types::batch::TaskProgress;
    use quiver_achievement::types::task::AchievementTask;
    use quiver_achievement::types::window::AchievementWindow;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    use super::IMockConsumer;

    component!(path: AchievementComponent, storage: achievement, event: AchievementEvent);

    #[abi(embed_v0)]
    impl AchievementViewImpl =
        AchievementComponent::AchievementViewImpl<ContractState>;
    impl AchievementInternalImpl = AchievementComponent::InternalImpl<ContractState>;

    impl AchievementTracking = quiver_achievement::store::tracking::TrackAll<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        achievement: AchievementComponent::Storage,
        ephemeral: ContractAddress,
        admin: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AchievementEvent: AchievementComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress, ephemeral: ContractAddress) {
        self.admin.write(admin);
        self.ephemeral.write(ephemeral);
    }

    impl AchievementHooks of AchievementComponent::AchievementHooksTrait<ContractState> {
        fn authorize_admin(
            self: @AchievementComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            false // AchievementImpl is not embedded: the consumer's own entrypoints call the internals
        }
    }

    #[abi(embed_v0)]
    impl MockConsumerImpl of IMockConsumer<ContractState> {
        fn define_achievement(
            ref self: ContractState,
            achievement_id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {
            assert(get_caller_address() == self.admin.read(), 'not admin');
            self.achievement.define(achievement_id, window, tasks, points);
        }

        fn submit_results(
            ref self: ContractState, adventurer_id: felt252, progress: Span<TaskProgress>,
        ) {
            assert(get_caller_address() == self.ephemeral.read(), 'not ephemeral');
            self.achievement.progress_many(adventurer_id, progress);
        }
    }
}

/// For the benchmarks: authorizes every caller, so that a measure is the component's own cost.
#[starknet::contract]
pub mod MockBench {
    use quiver_achievement::component::AchievementComponent;
    use starknet::ContractAddress;

    component!(path: AchievementComponent, storage: achievement, event: AchievementEvent);

    #[abi(embed_v0)]
    impl AchievementImpl = AchievementComponent::AchievementImpl<ContractState>;
    #[abi(embed_v0)]
    impl AchievementViewImpl =
        AchievementComponent::AchievementViewImpl<ContractState>;

    /// Every tracked model emits, as 0.1.0: the benchmarks compare with 0.1.0's figures.
    impl AchievementTracking = quiver_achievement::store::tracking::TrackAll<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        achievement: AchievementComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AchievementEvent: AchievementComponent::Event,
    }

    impl AchievementHooks of AchievementComponent::AchievementHooksTrait<ContractState> {
        fn authorize_admin(
            self: @AchievementComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            true
        }
    }
}

/// `MockBench` under `TrackNone`: the tracked models' events are not emitted, the action events
/// are.
#[starknet::contract]
pub mod MockBenchSilent {
    use quiver_achievement::component::AchievementComponent;
    use starknet::ContractAddress;

    component!(path: AchievementComponent, storage: achievement, event: AchievementEvent);

    #[abi(embed_v0)]
    impl AchievementImpl = AchievementComponent::AchievementImpl<ContractState>;
    #[abi(embed_v0)]
    impl AchievementViewImpl =
        AchievementComponent::AchievementViewImpl<ContractState>;

    impl AchievementTracking = quiver_achievement::store::tracking::TrackNone<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        achievement: AchievementComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AchievementEvent: AchievementComponent::Event,
    }

    impl AchievementHooks of AchievementComponent::AchievementHooksTrait<ContractState> {
        fn authorize_admin(
            self: @AchievementComponent::ComponentState<ContractState>, caller: ContractAddress,
        ) -> bool {
            true
        }
    }
}
