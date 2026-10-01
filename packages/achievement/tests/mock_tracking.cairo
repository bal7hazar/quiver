//! Optional tracking (ARC-07b), on the package's own models: `MockStoreAll` embeds
//! `AchievementComponent` under `TrackAll`, `MockStoreNone` under `TrackNone`. Each sets every
//! model through the store, and the tracked ones also by hand, in the same contract and on the
//! same slots: the same model built (`DefinitionTrait::new`), its slots written by hand, then, in
//! `MockStoreAll` only, the component's `emit` of its event. The only difference between
//! `store_set_x` and `hand_set_x` of one contract is the tracking path: the `if Tracking::X` of
//! the store against an `emit` written or not.

use quiver_achievement::models::definition::AchievementDefinition;
use quiver_achievement::models::status::AchievementStatus;
use quiver_achievement::types::task::AchievementTask;
use quiver_achievement::types::window::AchievementWindow;
use starknet::ContractAddress;

#[starknet::interface]
pub trait IMockStore<TState> {
    /// The baseline of the definition's writes: the same arguments, nothing done.
    fn noop(
        ref self: TState,
        id: u32,
        window: AchievementWindow,
        tasks: Span<AchievementTask>,
        points: u16,
    );
    /// `DefinitionTrait::new`, then `Store::set_definition`.
    fn store_set_definition(
        ref self: TState,
        id: u32,
        window: AchievementWindow,
        tasks: Span<AchievementTask>,
        points: u16,
    );
    /// `DefinitionTrait::new`, then by hand: A, B for 2 or 3 tasks, then `emit` of
    /// `AchievementDefined` under `TrackAll`, nothing under `TrackNone`.
    fn hand_set_definition(
        ref self: TState,
        id: u32,
        window: AchievementWindow,
        tasks: Span<AchievementTask>,
        points: u16,
    );
    fn store_get_definition(self: @TState, id: u32) -> AchievementDefinition;
    /// The untracked status: read from A, written back into the A read.
    fn store_get_status(self: @TState, id: u32) -> AchievementStatus;
    fn store_set_status(ref self: TState, id: u32, retired: bool);
    /// The baseline of the reporter's writes.
    fn noop_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    fn store_set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    /// The write by hand, then `emit` of `AchievementReporterSet` under `TrackAll`, nothing under
    /// `TrackNone`.
    fn hand_set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    fn store_get_reporter(self: @TState, reporter: ContractAddress) -> bool;
}

#[starknet::contract]
pub mod MockStoreAll {
    use quiver_achievement::component::AchievementComponent;
    use quiver_achievement::component::AchievementComponent::{
        AchievementDefined, AchievementReporterSet,
    };
    use quiver_achievement::models::definition::{
        AchievementDefinition, DefinitionStorage, DefinitionTrait,
    };
    use quiver_achievement::models::reporter::AchievementReporter;
    use quiver_achievement::models::status::AchievementStatus;
    use quiver_achievement::store::StoreTrait;
    use quiver_achievement::types::task::AchievementTask;
    use quiver_achievement::types::window::AchievementWindow;
    use starknet::ContractAddress;
    use starknet::storage::StorageMapWriteAccess;
    use super::IMockStore;

    component!(path: AchievementComponent, storage: achievement, event: AchievementEvent);

    /// Every tracked model emits, as 0.1.0.
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

    #[abi(embed_v0)]
    impl MockStoreImpl of IMockStore<ContractState> {
        fn noop(
            ref self: ContractState,
            id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {}

        fn store_set_definition(
            ref self: ContractState,
            id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {
            let definition = DefinitionTrait::new(id, window, tasks, points);
            self.achievement.set_definition(definition);
        }

        fn hand_set_definition(
            ref self: ContractState,
            id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {
            let definition = DefinitionTrait::new(id, window, tasks, points);
            let (slot_a, slot_b) = definition.into_slots();
            self.achievement.Achievement_definitions.write(definition.id, slot_a);
            if slot_a.task_count > 1 {
                self.achievement.Achievement_extra_tasks.write(definition.id, slot_b);
            }
            // The component's own emit, as 0.1.0's `define` did (`self.emit(..)` in the
            // component)
            AchievementComponent::HasComponent::emit(
                ref self.achievement,
                AchievementDefined {
                    achievement_id: definition.id,
                    window: definition.window,
                    tasks: definition.tasks,
                    points: definition.points,
                },
            );
        }

        fn store_get_definition(self: @ContractState, id: u32) -> AchievementDefinition {
            self.achievement.get_definition(id)
        }

        fn store_get_status(self: @ContractState, id: u32) -> AchievementStatus {
            self.achievement.get_status(id)
        }

        fn store_set_status(ref self: ContractState, id: u32, retired: bool) {
            let head = self.achievement.get_definition_head(id);
            let status = AchievementStatus { id, defined: head.defined, retired };
            self.achievement.set_status(status, head);
        }

        fn noop_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {}

        fn store_set_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {
            StoreTrait::set_reporter(
                ref self.achievement, AchievementReporter { reporter, allowed },
            );
        }

        fn hand_set_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {
            self.achievement.Achievement_reporters.write(reporter, allowed);
            AchievementComponent::HasComponent::emit(
                ref self.achievement, AchievementReporterSet { reporter, allowed },
            );
        }

        fn store_get_reporter(self: @ContractState, reporter: ContractAddress) -> bool {
            self.achievement.get_reporter(reporter).allowed
        }
    }
}

#[starknet::contract]
pub mod MockStoreNone {
    use quiver_achievement::component::AchievementComponent;
    use quiver_achievement::models::definition::{
        AchievementDefinition, DefinitionStorage, DefinitionTrait,
    };
    use quiver_achievement::models::reporter::AchievementReporter;
    use quiver_achievement::models::status::AchievementStatus;
    use quiver_achievement::store::StoreTrait;
    use quiver_achievement::types::task::AchievementTask;
    use quiver_achievement::types::window::AchievementWindow;
    use starknet::ContractAddress;
    use starknet::storage::StorageMapWriteAccess;
    use super::IMockStore;

    component!(path: AchievementComponent, storage: achievement, event: AchievementEvent);

    /// No model emits.
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

    #[abi(embed_v0)]
    impl MockStoreImpl of IMockStore<ContractState> {
        fn noop(
            ref self: ContractState,
            id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {}

        fn store_set_definition(
            ref self: ContractState,
            id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {
            let definition = DefinitionTrait::new(id, window, tasks, points);
            self.achievement.set_definition(definition);
        }

        fn hand_set_definition(
            ref self: ContractState,
            id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {
            let definition = DefinitionTrait::new(id, window, tasks, points);
            let (slot_a, slot_b) = definition.into_slots();
            self.achievement.Achievement_definitions.write(definition.id, slot_a);
            if slot_a.task_count > 1 {
                self.achievement.Achievement_extra_tasks.write(definition.id, slot_b);
            }
        }

        fn store_get_definition(self: @ContractState, id: u32) -> AchievementDefinition {
            self.achievement.get_definition(id)
        }

        fn store_get_status(self: @ContractState, id: u32) -> AchievementStatus {
            self.achievement.get_status(id)
        }

        fn store_set_status(ref self: ContractState, id: u32, retired: bool) {
            let head = self.achievement.get_definition_head(id);
            let status = AchievementStatus { id, defined: head.defined, retired };
            self.achievement.set_status(status, head);
        }

        fn noop_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {}

        fn store_set_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {
            StoreTrait::set_reporter(
                ref self.achievement, AchievementReporter { reporter, allowed },
            );
        }

        fn hand_set_reporter(ref self: ContractState, reporter: ContractAddress, allowed: bool) {
            self.achievement.Achievement_reporters.write(reporter, allowed);
        }

        fn store_get_reporter(self: @ContractState, reporter: ContractAddress) -> bool {
            self.achievement.get_reporter(reporter).allowed
        }
    }
}
