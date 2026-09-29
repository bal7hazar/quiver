//! The Starknet component of `quiver_achievement` (ARC-01 §3.11, amended by the decision of
//! 2026-09-29): storage of the definitions and of the reporter registry, events, the one hook
//! `authorize_admin`, the trusted internal layer, and the optional external ABI with its access
//! control.
//!
//! **Event mode only.** Progress is emitted as `AchievementProgressed` events and nothing else:
//! there is no per-player storage, no task page, no completion and no claim, and no `Mode`
//! parameter. A consumer cannot ask for a storage mode: the code that would do it does not exist.
//! An indexer derives the tiers from `AchievementDefined`, `AchievementRetired` and
//! `AchievementProgressed`. A storage design with per-task counters is planned for a later
//! version; 0.1.0 reserves none of its layout.
//!
//! **The internal layer is trusted**: `InternalImpl` checks no caller. A consumer calls it from
//! its own entrypoints, after its own checks. Only the external impls `AchievementImpl` and
//! `AchievementViewImpl` check anything, and only when the consumer embeds them.
//!
//! Every loop is bounded: batches by `MAX_ENTRIES` (checked first by `batch_merge`), tasks by
//! `MAX_TASKS` (unrolled).

#[starknet::component]
pub mod AchievementComponent {
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    use crate::errors;
    use crate::interface::{IAchievement, IAchievementView};
    use crate::logic::{
        AchievementDefinition, AchievementExtraTasks, AchievementTask, AchievementWindow,
        TaskProgress, batch_merge, definition_new, tasks_span,
    };

    /// Members are prefixed with `Achievement_` so that they do not collide in the consumer's
    /// storage. Every value is one felt (layouts in `quiver_achievement::logic::types`). No
    /// member is keyed by a player.
    #[storage]
    pub struct Storage {
        /// Slot A, key `achievement_id`.
        pub Achievement_definitions: Map<u32, AchievementDefinition>,
        /// Slot B, key `achievement_id`; written only for an achievement of 2 or 3 tasks.
        pub Achievement_extra_tasks: Map<u32, AchievementExtraTasks>,
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

    /// Every `define`. `points` is here only: it is shown, never read by a rule.
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct AchievementDefined {
        #[key]
        pub achievement_id: u32,
        pub window: AchievementWindow,
        pub tasks: Span<AchievementTask>,
        pub points: u16,
    }

    /// One per merged, non-zero entry of a progress call.
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct AchievementProgressed {
        #[key]
        pub player_id: felt252,
        #[key]
        pub task_id: u32,
        pub count: u32,
    }

    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct AchievementRetired {
        #[key]
        pub achievement_id: u32,
    }

    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct AchievementReporterSet {
        #[key]
        pub reporter: ContractAddress,
        pub allowed: bool,
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
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        /// Validates (`definition_new`), then refuses `'Achievement: already defined'` (retired
        /// or not). Writes A, and B for 2 or 3 tasks; emits `AchievementDefined` with `points`.
        /// Any number of achievements may use a task: tiers are separate achievements on one
        /// task.
        fn define(
            ref self: ComponentState<TContractState>,
            achievement_id: u32,
            window: AchievementWindow,
            tasks: Span<AchievementTask>,
            points: u16,
        ) {
            let (definition, extra) = definition_new(achievement_id, window, tasks);
            assert(
                !self.Achievement_definitions.read(achievement_id).defined,
                errors::ALREADY_DEFINED,
            );
            self.Achievement_definitions.write(achievement_id, definition);
            if definition.task_count > 1 {
                self.Achievement_extra_tasks.write(achievement_id, extra);
            }
            self.emit(AchievementDefined { achievement_id, window, tasks, points });
        }

        /// Refuses `'Achievement: does not exist'`, `'Achievement: retired'`. Sets `retired`;
        /// emits `AchievementRetired`. Progress does not read it: the indexer stops counting the
        /// achievement from this event, and keeps what it reached before.
        fn retire(ref self: ComponentState<TContractState>, achievement_id: u32) {
            let mut definition = self.Achievement_definitions.read(achievement_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            assert(!definition.retired, errors::RETIRED);
            definition.retired = true;
            self.Achievement_definitions.write(achievement_id, definition);
            self.emit(AchievementRetired { achievement_id });
        }

        /// Registers or revokes a reporter; emits `AchievementReporterSet`.
        fn set_reporter(
            ref self: ComponentState<TContractState>, reporter: ContractAddress, allowed: bool,
        ) {
            self.Achievement_reporters.write(reporter, allowed);
            self.emit(AchievementReporterSet { reporter, allowed });
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
            for entry in batch_merge(entries) {
                let TaskProgress { task_id, count } = *entry;
                self.emit(AchievementProgressed { player_id, task_id, count });
            }
        }

        /// Panics `'Achievement: not reporter'` unless `caller` is a registered reporter.
        fn assert_reporter(self: @ComponentState<TContractState>, caller: ContractAddress) {
            assert(self.Achievement_reporters.read(caller), errors::NOT_REPORTER);
        }

        /// A and the tasks (B read only for 2 or 3 tasks). Panics `'Achievement: does not
        /// exist'`; a retired achievement is returned, with `retired` set.
        fn definition(
            self: @ComponentState<TContractState>, achievement_id: u32,
        ) -> (AchievementDefinition, Span<AchievementTask>) {
            let definition = self.Achievement_definitions.read(achievement_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            let extra = if definition.task_count > 1 {
                self.Achievement_extra_tasks.read(achievement_id)
            } else {
                AchievementExtraTasks {
                    t1: AchievementTask { task_id: 0, total: 0 },
                    t2: AchievementTask { task_id: 0, total: 0 },
                }
            };
            (definition, tasks_span(@definition, @extra))
        }
    }

    /// The access-checked ABI, optional to embed.
    #[embeddable_as(AchievementImpl)]
    impl Achievement<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: AchievementHooksTrait<TContractState>,
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
        +Drop<TContractState>,
    > of IAchievementView<ComponentState<TContractState>> {
        fn achievement_definition(
            self: @ComponentState<TContractState>, achievement_id: u32,
        ) -> (AchievementDefinition, Span<AchievementTask>) {
            self.definition(achievement_id)
        }

        fn achievement_is_reporter(
            self: @ComponentState<TContractState>, reporter: ContractAddress,
        ) -> bool {
            self.Achievement_reporters.read(reporter)
        }
    }
}
