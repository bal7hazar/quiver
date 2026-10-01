//! The Starknet component of `quiver_achievement` (ARC-01 §3.11, amended by the decision of
//! 2026-09-29): storage, events, the one hook `authorize_admin`, the trusted internal layer, and
//! the optional external ABI with its access control. Every stored entity is a model
//! (`crate::models`), read and written only through the store (`crate::store`).
//!
//! **Event mode only.** Progress is emitted as `AchievementProgressed` events and nothing else:
//! there is no per-player storage, no task page, no completion and no claim, and no `Mode`
//! parameter. A consumer cannot ask for a storage mode: the code that would do it does not exist.
//! An indexer derives the tiers from `AchievementDefined`, `AchievementRetired` and
//! `AchievementProgressed`. A storage design with per-task counters is planned for a later
//! version; none of its layout is reserved.
//!
//! **The internal layer is trusted**: `InternalImpl` checks no caller. A consumer calls it from
//! its own entrypoints, after its own checks. Only the external impls `AchievementImpl` and
//! `AchievementViewImpl` check anything, and only when the consumer embeds them.
//!
//! **The consumer chooses the tracked models' events** (`crate::store::AchievementTracking`): the
//! component's impls take its choice as an impl parameter, like the hook. The action events
//! (`AchievementProgressed`, `AchievementRetired`) are emitted here, whatever the choice.
//!
//! Every loop is bounded: batches by `MAX_ENTRIES` (checked first by `BatchTrait::merge`), tasks
//! by `MAX_TASKS` (unrolled).

#[starknet::component]
pub mod AchievementComponent {
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_caller_address};
    use crate::errors;
    pub use crate::events::index::{
        AchievementDefined, AchievementProgressed, AchievementReporterSet, AchievementRetired,
    };
    use crate::events::progressed::ProgressedTrait;
    use crate::events::retired::RetiredTrait;
    use crate::interface::{IAchievement, IAchievementView};
    use crate::models::definition::{DefinitionTrait, HeadSlot, HeadSlotTrait, NO_TASKS, TasksSlot};
    use crate::models::reporter::{AchievementReporter, ReporterAssert};
    use crate::models::status::{StatusAssert, StatusStorage, StatusTrait};
    use crate::store::{AchievementTracking, StoreTrait};
    use crate::types::batch::{BatchTrait, TaskProgress};
    use crate::types::task::AchievementTask;
    use crate::types::window::AchievementWindow;

    /// Members are prefixed with `Achievement_` so that they do not collide in the consumer's
    /// storage. Every value is one felt (layouts next to each model, in
    /// `quiver_achievement::models`). Read and written only by the store. No member is keyed by a
    /// player.
    #[storage]
    pub struct Storage {
        /// Slot A, key `achievement_id`: the definition's head and the achievement's status.
        pub Achievement_definitions: Map<u32, HeadSlot>,
        /// Slot B, key `achievement_id`; written only for an achievement of 2 or 3 tasks.
        pub Achievement_extra_tasks: Map<u32, TasksSlot>,
        pub Achievement_reporters: Map<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub enum Event {
        AchievementDefined: AchievementDefined,
        AchievementProgressed: AchievementProgressed,
        AchievementRetired: AchievementRetired,
        AchievementReporterSet: AchievementReporterSet,
    }

    /// Implemented by the consumer; the component's impls are generic over it.
    pub trait AchievementHooksTrait<TContractState> {
        /// May `caller` define and retire achievements and set reporters? Used by the external
        /// `AchievementImpl` only.
        fn authorize_admin(self: @ComponentState<TContractState>, caller: ContractAddress) -> bool;
    }

    /// The trusted layer: **no function here checks the caller**. The consumer calls them from
    /// its own entrypoints, after its own checks.
    #[generate_trait]
    pub impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: AchievementHooksTrait<TContractState>,
        impl Tracking: AchievementTracking<TContractState>,
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        /// Validates (`DefinitionTrait::new`), then refuses `'Achievement: already defined'`
        /// (retired or not). Writes the definition through the store: A with `points`, B for 2 or
        /// 3 tasks, and `AchievementDefined` when tracked. Any number of achievements may use a
        /// task: tiers are separate achievements on one task.
        fn define(
            ref self: ComponentState<TContractState>,
            achievement_id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {
            let definition = DefinitionTrait::new(achievement_id, window, tasks, points);
            self.get_status(achievement_id).assert_does_not_exist();
            self.set_definition(definition);
        }

        /// Refuses `'Achievement: does not exist'`, `'Achievement: retired'`. Sets `retired`;
        /// emits `AchievementRetired`. Progress does not read it: the indexer stops counting the
        /// achievement from this event, and keeps what it reached before.
        fn retire(ref self: ComponentState<TContractState>, achievement_id: u32) {
            let head = self.get_definition_head(achievement_id);
            let mut status = head.status(achievement_id);
            status.assert_can_retire();
            status.retire();
            self.set_status(status, head);
            self.emit(RetiredTrait::new(achievement_id));
        }

        /// Registers or revokes a reporter; emits `AchievementReporterSet` when tracked.
        fn set_reporter(
            ref self: ComponentState<TContractState>, reporter: ContractAddress, allowed: bool,
        ) {
            StoreTrait::set_reporter(ref self, AchievementReporter { reporter, allowed });
        }

        /// Exactly `progress_many(player_id, [TaskProgress { task_id, count }])`.
        fn progress(
            ref self: ComponentState<TContractState>, player_id: felt252, task_id: u32, count: u32,
        ) {
            InternalTrait::progress_many(
                ref self, player_id, array![TaskProgress { task_id, count }].span(),
            );
        }

        /// Panics `'Achievement: too many entries'` above `MAX_ENTRIES` entries (duplicates and
        /// zero counts included) and `'Achievement: invalid task'` on a task id 0. Emits one
        /// `AchievementProgressed` per merged, non-zero entry, in the order of first occurrence;
        /// **reads and writes nothing**, calls no hook. Windows and retirement are not checked
        /// here: the indexer applies them.
        ///
        /// The consumer aggregates its results by task and calls this once per player per
        /// transaction.
        fn progress_many(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            entries: Span<TaskProgress>,
        ) {
            for entry in entries.merge() {
                let TaskProgress { task_id, count } = *entry;
                self.emit(ProgressedTrait::new(player_id, task_id, count));
            }
        }

        /// Panics `'Achievement: not reporter'` unless `caller` is a registered reporter.
        fn assert_reporter(self: @ComponentState<TContractState>, caller: ContractAddress) {
            self.get_reporter(caller).assert_is_allowed();
        }

        /// A, with `points`, and the tasks (B read only for 2 or 3 tasks). Panics `'Achievement:
        /// does not exist'`; a retired achievement is returned, with `retired` set.
        fn definition(
            self: @ComponentState<TContractState>, achievement_id: u32,
        ) -> (HeadSlot, Span<AchievementTask>) {
            let head = self.get_definition_head(achievement_id);
            head.status(achievement_id).assert_does_exist();
            let slot_b = if head.task_count > 1 {
                self.get_definition_tasks(achievement_id)
            } else {
                NO_TASKS
            };
            (head, head.tasks(@slot_b))
        }
    }

    /// The access-checked ABI, optional to embed.
    #[embeddable_as(AchievementImpl)]
    impl Achievement<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: AchievementHooksTrait<TContractState>,
        impl Tracking: AchievementTracking<TContractState>,
        +Drop<TContractState>,
    > of IAchievement<ComponentState<TContractState>> {
        /// `authorize_admin(caller)` or `'Achievement: not admin'`.
        fn define(
            ref self: ComponentState<TContractState>,
            achievement_id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {
            assert(Hooks::authorize_admin(@self, get_caller_address()), errors::NOT_ADMIN);
            InternalTrait::define(ref self, achievement_id, window, tasks, points);
        }

        /// `authorize_admin(caller)` or `'Achievement: not admin'`.
        fn retire(ref self: ComponentState<TContractState>, achievement_id: u32) {
            assert(Hooks::authorize_admin(@self, get_caller_address()), errors::NOT_ADMIN);
            InternalTrait::retire(ref self, achievement_id);
        }

        /// `authorize_admin(caller)` or `'Achievement: not admin'`.
        fn set_reporter(
            ref self: ComponentState<TContractState>, reporter: ContractAddress, allowed: bool,
        ) {
            assert(Hooks::authorize_admin(@self, get_caller_address()), errors::NOT_ADMIN);
            InternalTrait::set_reporter(ref self, reporter, allowed);
        }

        /// A registered reporter or `'Achievement: not reporter'`.
        fn progress(
            ref self: ComponentState<TContractState>, player_id: felt252, task_id: u32, count: u32,
        ) {
            InternalTrait::assert_reporter(@self, get_caller_address());
            InternalTrait::progress(ref self, player_id, task_id, count);
        }

        /// A registered reporter or `'Achievement: not reporter'`.
        fn progress_many(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            entries: Span<TaskProgress>,
        ) {
            InternalTrait::assert_reporter(@self, get_caller_address());
            InternalTrait::progress_many(ref self, player_id, entries);
        }
    }

    /// The views, optional to embed. None writes.
    #[embeddable_as(AchievementViewImpl)]
    impl AchievementView<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: AchievementHooksTrait<TContractState>,
        impl Tracking: AchievementTracking<TContractState>,
        +Drop<TContractState>,
    > of IAchievementView<ComponentState<TContractState>> {
        fn achievement_definition(
            self: @ComponentState<TContractState>, achievement_id: u32,
        ) -> (HeadSlot, Span<AchievementTask>) {
            self.definition(achievement_id)
        }

        fn achievement_is_reporter(
            self: @ComponentState<TContractState>, reporter: ContractAddress,
        ) -> bool {
            self.get_reporter(reporter).allowed
        }
    }
}
