//! The Starknet component of `quiver_quest` (ARC-01 §3.3 to §3.7, amended by D-135): storage,
//! events, hooks, the trusted internal layer, and the optional external ABI with its access
//! control. Every stored entity is a model (`crate::models`), read and written only through the
//! store (`crate::store`).
//!
//! **The internal layer is trusted**: `InternalImpl` checks no caller. A consumer calls it from
//! its own entrypoints, after its own checks. Only the external impls `QuestImpl` and
//! `QuestViewImpl` check anything, and only when the consumer embeds them.
//!
//! **The consumer chooses the tracked models' events** (`crate::store::QuestTracking`): the
//! component's impls take its choice as an impl parameter, like the hooks. The action events
//! (`QuestProgressed`, `QuestCompleted`, `QuestClaimed`, `QuestRetired`) are emitted here,
//! whatever the choice.
//!
//! **Every quest is accepted before it progresses** (D-135). A player holds at most `MAX_HELD`
//! quests, in a list of at most `HELD_SLOTS` slots; progress walks that list, not the quests of
//! the reported tasks, so the cost of a call depends on the held quests only.
//!
//! Every loop is bounded: batches by `MAX_ENTRIES` (checked first by `BatchTrait::merge`), the
//! held list by `HELD_SLOTS` slots of 2 entries (`MAX_HELD_LIMIT`), tasks by `MAX_TASKS`,
//! conditions by `MAX_CONDITIONS`.

#[starknet::component]
pub mod QuestComponent {
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use crate::constants::{ACCEPTANCE_LIMIT, HELD_INTERVAL_LIMIT, MAX_HELD};
    use crate::errors;
    use crate::events::claimed::ClaimedTrait;
    use crate::events::completed::CompletedTrait;
    pub use crate::events::index::{
        QuestClaimed, QuestCompleted, QuestDefined, QuestProgressed, QuestReporterSet, QuestRetired,
    };
    use crate::events::progressed::ProgressedTrait;
    use crate::events::retired::RetiredTrait;
    use crate::interface::{IQuest, IQuestView};
    use crate::models::definition::{
        ConditionsSlot, ConditionsSlotTrait, DefinitionTrait, HeadSlot, TasksSlot, TasksSlotTrait,
    };
    use crate::models::held::HeldSlot;
    use crate::models::progress::{ProgressSlot, ProgressStorage, ProgressTrait};
    use crate::models::record::{QuestRecord, RecordSlot, RecordStorage, RecordTrait};
    use crate::models::reporter::{QuestReporter, ReporterAssert};
    use crate::models::status::{StatusAssert, StatusStorage, StatusTrait};
    use crate::store::{QuestTracking, StoreTrait};
    use crate::types::batch::{BatchTrait, TaskProgress};
    use crate::types::held::{HeldTrait, QuestHeld};
    use crate::types::mode::Mode;
    use crate::types::schedule::{QuestSchedule, ScheduleTrait};
    use crate::types::task::QuestTask;

    /// Members are prefixed with `Quest_` so that they do not collide in the consumer's storage.
    /// Every value is one felt (layouts next to each model, in `quiver_quest::models`). Read and
    /// written only by the store.
    #[storage]
    pub struct Storage {
        /// Slot A, key `quest_id`: the definition's head and the quest's status.
        pub Quest_definitions: Map<u32, HeadSlot>,
        /// Slot B, key `quest_id`.
        pub Quest_tasks: Map<u32, TasksSlot>,
        /// Slot C, key `quest_id`; written only for a quest with conditions.
        pub Quest_conditions: Map<u32, ConditionsSlot>,
        /// Slot P, key `(player_id, quest_id, interval_id)`.
        pub Quest_progress: Map<(felt252, u32, u64), ProgressSlot>,
        /// Slot R, key `(player_id, quest_id)`.
        pub Quest_records: Map<(felt252, u32), RecordSlot>,
        /// Slot H, the held list, key `(player_id, index)`, indices `0..HELD_SLOTS`; contiguous
        /// from index 0.
        pub Quest_held: Map<(felt252, u8), HeldSlot>,
        pub Quest_reporters: Map<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub enum Event {
        QuestDefined: QuestDefined,
        QuestProgressed: QuestProgressed,
        QuestCompleted: QuestCompleted,
        QuestClaimed: QuestClaimed,
        QuestRetired: QuestRetired,
        QuestReporterSet: QuestReporterSet,
    }

    /// Implemented by the consumer; the component's impls are generic over it.
    pub trait QuestHooksTrait<TContractState> {
        /// May `caller` define and retire quests and set reporters? Used by the external
        /// `QuestImpl` only.
        fn authorize_admin(self: @ComponentState<TContractState>, caller: ContractAddress) -> bool;
        /// May `caller` accept, abandon or claim for `player_id`? Used by the external `QuestImpl`
        /// only.
        fn authorize_player(
            self: @ComponentState<TContractState>, caller: ContractAddress, player_id: felt252,
        ) -> bool;
        /// After a completion is written. `completions` includes this one (1 for the first).
        fn on_quest_complete(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            completions: u64,
        );
        /// After a claim is written. `claim_index` is 0 for the first claim of this quest by this
        /// player.
        fn on_quest_claim(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
            claim_index: u64,
        );
    }

    /// The trusted layer: **no function here checks the caller**. The consumer calls them from
    /// its own entrypoints, after its own checks. A hook that panics reverts the whole call.
    #[generate_trait]
    pub impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: QuestHooksTrait<TContractState>,
        impl Tracking: QuestTracking<TContractState>,
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        /// Validates (`DefinitionTrait::new`), then refuses `'Quest: already defined'` (retired
        /// or not), a condition not defined or retired (`'Quest: invalid condition'`), a
        /// condition with `0xffff` live dependents (`'Quest: too many dependents'`). Writes each
        /// condition's status (`live_dependents + 1`), then the definition through the store (A,
        /// B, C only with conditions, and `QuestDefined` when tracked). Any number of quests may
        /// use a task.
        fn define(
            ref self: ComponentState<TContractState>,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
        ) {
            let definition = DefinitionTrait::new(quest_id, schedule, tasks, conditions);
            assert(!self.has_definition(quest_id), errors::ALREADY_DEFINED);
            // Conditions: at most MAX_CONDITIONS, checked by DefinitionTrait::new. Each one's
            // status, one read and one write of its A
            for condition in conditions {
                let condition = *condition;
                let head = self.get_definition_head(condition);
                let mut prerequisite = head.status(condition);
                prerequisite.assert_valid_condition();
                prerequisite.add_dependent();
                self.set_status(prerequisite, head);
            }
            self.set_definition(definition);
        }

        /// Refuses `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: has live
        /// dependents'`. Decrements its conditions' `live_dependents`, sets `retired`; emits
        /// `QuestRetired`. Player data is kept: completed intervals stay claimable. The held
        /// entries of the quest become dead: progress skips them, and each player's next `accept`
        /// prunes them.
        fn retire(ref self: ComponentState<TContractState>, quest_id: u32) {
            let head = self.get_definition_head(quest_id);
            let mut status = head.status(quest_id);
            status.assert_can_retire();
            if head.condition_count != 0 {
                let conditions = self.get_definition_conditions(quest_id, head.condition_count);
                for condition in conditions {
                    let condition = *condition;
                    let prerequisite_head = self.get_definition_head(condition);
                    let mut prerequisite = prerequisite_head.status(condition);
                    prerequisite.remove_dependent();
                    self.set_status(prerequisite, prerequisite_head);
                }
            }
            status.retire();
            self.set_status(status, head);
            self.emit(RetiredTrait::new(quest_id));
        }

        /// Registers or revokes a reporter; emits `QuestReporterSet` when tracked.
        fn set_reporter(
            ref self: ComponentState<TContractState>, reporter: ContractAddress, allowed: bool,
        ) {
            StoreTrait::set_reporter(ref self, QuestReporter { reporter, allowed });
        }

        /// Exactly `progress_many(player_id, [TaskProgress { task_id, count }], mode)`.
        fn progress(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            task_id: u32,
            count: u32,
            mode: Mode,
        ) {
            InternalTrait::progress_many(
                ref self, player_id, array![TaskProgress { task_id, count }].span(), mode,
            );
        }

        /// Panics `'Quest: too many entries'` above `MAX_ENTRIES` entries (duplicates and zero
        /// counts included) and `'Quest: invalid task'` on a task id 0. Never reverts for a
        /// quest-level reason: a held quest retired, outside the interval of its acceptance, or
        /// already completed is skipped; a quest not held is not read.
        ///
        /// `Mode::Event`: one `QuestProgressed` per merged, non-zero entry; no read, no write, no
        /// hook. `Mode::Storage`: walks the player's held list, in the order of acceptance; each
        /// held quest's progress and record are read and written at most once; `QuestCompleted`
        /// then `on_quest_complete` per completion, after its writes. The list itself is not
        /// written.
        ///
        /// The consumer aggregates its results by task and calls this once per player per
        /// transaction: the package cannot see across calls.
        fn progress_many(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            entries: Span<TaskProgress>,
            mode: Mode,
        ) {
            let batch = entries.merge();
            if batch.len() == 0 {
                return;
            }
            if mode == Mode::Event {
                for entry in batch {
                    let TaskProgress { task_id, count } = *entry;
                    self.emit(ProgressedTrait::new(player_id, task_id, count));
                }
                return;
            }
            let time = get_block_timestamp();
            // The held quests when the call starts. A hook may accept or abandon: once a hook
            // has run, each later entry is processed only if the list still holds it, the whole
            // entry: quest, interval and acceptance number. An entry accepted by a hook, a
            // renewed one included, has a new number and is not in this walk
            let held = self.get_held(player_id);
            let mut hooked = false;
            let mut position: u32 = 0;
            for entry in held {
                let entry = *entry;
                if hooked && !self.is_still_held(player_id, entry, position) {
                    position += 1;
                    continue;
                }
                if self.progress_held(player_id, entry, batch, time) {
                    hooked = true;
                }
                position += 1;
            }
        }

        /// Refuses, in this order: `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: not
        /// active'` (outside the schedule), `'Quest: locked'` (prerequisites not met; once met,
        /// cached in the record), `'Quest: already accepted'` (held and live in this interval),
        /// `'Quest: already completed'` (this interval), `'Quest: too many held'` (`MAX_HELD`
        /// live quests held).
        ///
        /// Prunes the held list of its dead entries (retired, expired at rollover, completed),
        /// appends the quest, and writes the slots of the list that changed. The acceptance holds
        /// until completion, abandon, retirement or rollover.
        fn accept(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32) {
            let head = self.get_definition_head(quest_id);
            let status = head.status(quest_id);
            status.assert_does_exist();
            status.assert_not_retired();
            let time = get_block_timestamp();
            // An interval id at or above 2^48 (8.9 million years of one-second intervals) does not
            // fit a held entry: the quest is not active there, and cannot be accepted
            let interval_id = match head.schedule.interval_id(time) {
                Option::Some(interval_id) => interval_id,
                Option::None => core::panic_with_felt252(errors::NOT_ACTIVE),
            };
            assert(interval_id < HELD_INTERVAL_LIMIT, errors::NOT_ACTIVE);
            let mut unlock: Option<QuestRecord> = Option::None;
            if head.condition_count != 0 {
                let mut record = self.get_record(player_id, quest_id);
                if !record.unlocked {
                    assert(
                        self.prerequisites_met(player_id, quest_id, head.condition_count),
                        errors::LOCKED,
                    );
                    record.unlock();
                    unlock = Option::Some(record);
                }
            }
            let list = self.get_held_list(player_id);
            let held = list.entries;
            let completed = self.get_progress(player_id, quest_id, interval_id).completed;
            if let Option::Some(position) = held.position(quest_id) {
                // Its own entry is live when it is of this interval and not completed: A is
                // already known not retired
                assert(
                    *held[position].interval_id != interval_id || completed,
                    errors::ALREADY_ACCEPTED,
                );
            }
            assert(!completed, errors::ALREADY_COMPLETED);
            // Keep the live entries of the other quests, in order
            let mut kept_after: Array<QuestHeld> = array![];
            for entry in held {
                let entry = *entry;
                if entry.quest_id != quest_id && self.is_held_live(player_id, entry, time) {
                    kept_after.append(entry);
                }
            }
            assert(kept_after.len() < MAX_HELD.into(), errors::TOO_MANY_HELD);
            // A new acceptance number, 30 bits: a quest abandoned and accepted again, even in the
            // same interval, is a different entry for a call that was running. The counter wraps to
            // 0 after 2^30 - 1, about 1.07 × 10^9 acceptances by one player
            let acceptance = if list.counter + 1 == ACCEPTANCE_LIMIT {
                0
            } else {
                list.counter + 1
            };
            kept_after.append(QuestHeld { quest_id, interval_id, acceptance });
            self.set_held_list(player_id, list, kept_after.span(), acceptance);
            if let Option::Some(record) = unlock {
                self.set_record(record);
            }
        }

        /// Refuses `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: not active'`,
        /// `'Quest: not accepted'` (not held in the current interval, or that interval is
        /// completed). Removes the quest from the held list; the later entries move up. The
        /// counts of the interval are kept.
        fn abandon(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32) {
            let head = self.get_definition_head(quest_id);
            let status = head.status(quest_id);
            status.assert_does_exist();
            status.assert_not_retired();
            let interval_id = match head.schedule.interval_id(get_block_timestamp()) {
                Option::Some(interval_id) => interval_id,
                Option::None => core::panic_with_felt252(errors::NOT_ACTIVE),
            };
            let list = self.get_held_list(player_id);
            let held = list.entries;
            let position = match held.position(quest_id) {
                Option::Some(position) => position,
                Option::None => core::panic_with_felt252(errors::NOT_ACCEPTED),
            };
            assert(*held[position].interval_id == interval_id, errors::NOT_ACCEPTED);
            assert(
                !self.get_progress(player_id, quest_id, interval_id).completed,
                errors::NOT_ACCEPTED,
            );
            self.set_held_list(player_id, list, held.remove(position), list.counter);
        }

        /// Refuses `'Quest: not completed'`, `'Quest: already claimed'`. Writes the progress and
        /// the record, emits `QuestClaimed`, then calls `on_quest_claim`. Any completed interval
        /// can be claimed, of a retired quest too. Returns the claim index (0 for the first).
        fn claim(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
        ) -> u64 {
            let mut progress = self.get_progress(player_id, quest_id, interval_id);
            let mut record = self.get_record(player_id, quest_id);
            progress.claim();
            let claim_index = record.claim();
            self.set_progress(progress);
            self.set_record(record);
            self.emit(ClaimedTrait::new(player_id, quest_id, interval_id));
            Hooks::on_quest_claim(ref self, player_id, quest_id, interval_id, claim_index);
            claim_index
        }

        /// Panics `'Quest: not reporter'` unless `caller` is a registered reporter.
        fn assert_reporter(self: @ComponentState<TContractState>, caller: ContractAddress) {
            self.get_reporter(caller).assert_is_allowed();
        }

        /// Slot A (the definition's head and the quest's status), the tasks and the conditions,
        /// as 0.1.0 returns them. Panics `'Quest: does not exist'`.
        fn definition(
            self: @ComponentState<TContractState>, quest_id: u32,
        ) -> (HeadSlot, Span<QuestTask>, Span<u32>) {
            let (head, quest_tasks, slot_c) = self.get_definition_slots(quest_id);
            head.status(quest_id).assert_does_exist();
            let conditions = slot_c.ids(head.condition_count);
            (head, quest_tasks.tasks(head.task_count), conditions)
        }

        /// The raw progress of a player on a quest in an interval: slot P.
        fn progress_of(
            self: @ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
        ) -> ProgressSlot {
            self.get_progress(player_id, quest_id, interval_id).into_slot()
        }

        /// The record: completions, claims, and the cached unlock; slot R.
        fn record_of(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> RecordSlot {
            self.get_record(player_id, quest_id).into_slot()
        }

        /// The interval id now; `None` outside the schedule or for a quest not defined.
        fn current_interval(self: @ComponentState<TContractState>, quest_id: u32) -> Option<u64> {
            let head = self.get_definition_head(quest_id);
            if !head.status(quest_id).defined {
                return Option::None;
            }
            head.schedule.interval_id(get_block_timestamp())
        }

        /// Panics `'Quest: does not exist'`. True without conditions or once cached; otherwise
        /// evaluates the prerequisites. Writes nothing: `accept` caches it.
        fn is_unlocked(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> bool {
            let head = self.get_definition_head(quest_id);
            head.status(quest_id).assert_does_exist();
            if head.condition_count == 0 || self.get_record(player_id, quest_id).unlocked {
                return true;
            }
            self.prerequisites_met(player_id, quest_id, head.condition_count)
        }

        /// False for a quest not defined or retired, and outside the schedule; otherwise held in
        /// the current interval, and that interval not completed.
        fn is_accepted(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> bool {
            let head = self.get_definition_head(quest_id);
            if !head.status(quest_id).is_live() {
                return false;
            }
            let interval_id = match head.schedule.interval_id(get_block_timestamp()) {
                Option::Some(interval_id) => interval_id,
                Option::None => { return false; },
            };
            let held = self.get_held(player_id);
            match held.position(quest_id) {
                Option::Some(position) => *held[position].interval_id == interval_id
                    && !self.get_progress(player_id, quest_id, interval_id).completed,
                Option::None => false,
            }
        }

        /// The player's held entries, in the order of acceptance, live or dead (not yet pruned).
        fn held_of(self: @ComponentState<TContractState>, player_id: felt252) -> Span<QuestHeld> {
            self.get_held(player_id)
        }
    }

    #[generate_trait]
    impl PrivateImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: QuestHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of PrivateTrait<TContractState> {
        /// One held entry of `progress_many` (ARC-01 §3.5). Returns whether a hook ran.
        fn progress_held(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            entry: QuestHeld,
            batch: Span<TaskProgress>,
            time: u64,
        ) -> bool {
            let QuestHeld { quest_id, interval_id, acceptance: _ } = entry;
            // 1. A; skip a retired quest (a hook of an earlier quest of this call may retire it),
            // then an acceptance of another interval (expired at rollover) or outside the
            // schedule
            let head = self.get_definition_head(quest_id);
            if head.status(quest_id).retired {
                return false;
            }
            if head.schedule.interval_id(time) != Option::Some(interval_id) {
                return false;
            }
            // 2. P; skip once completed in this interval
            let mut progress = self.get_progress(player_id, quest_id, interval_id);
            if progress.completed {
                return false;
            }
            // 3. B, and every batched count of the quest's tasks at once
            let quest_tasks = self.get_definition_tasks(quest_id);
            let (changed, completed) = progress.add(@quest_tasks, head.task_count, batch);
            if !changed {
                return false;
            }
            // 4. One write each: P, and R on completion
            self.set_progress(progress);
            if !completed {
                return false;
            }
            let mut record = self.get_record(player_id, quest_id);
            record.complete();
            self.set_record(record);
            // 5. Event, then hook, after the writes
            self.emit(CompletedTrait::new(player_id, quest_id, interval_id));
            Hooks::on_quest_complete(
                ref self, player_id, quest_id, interval_id, record.completions,
            );
            true
        }
    }

    /// The access-checked ABI (ARC-01 §3.6), optional to embed.
    #[embeddable_as(QuestImpl)]
    impl Quest<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: QuestHooksTrait<TContractState>,
        impl Tracking: QuestTracking<TContractState>,
        +Drop<TContractState>,
    > of IQuest<ComponentState<TContractState>> {
        /// `authorize_admin(caller)` or `'Quest: not admin'`.
        fn define(
            ref self: ComponentState<TContractState>,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
        ) {
            assert(Hooks::authorize_admin(@self, get_caller_address()), errors::NOT_ADMIN);
            InternalTrait::define(ref self, quest_id, schedule, tasks, conditions);
        }

        /// `authorize_admin(caller)` or `'Quest: not admin'`.
        fn retire(ref self: ComponentState<TContractState>, quest_id: u32) {
            assert(Hooks::authorize_admin(@self, get_caller_address()), errors::NOT_ADMIN);
            InternalTrait::retire(ref self, quest_id);
        }

        /// `authorize_admin(caller)` or `'Quest: not admin'`.
        fn set_reporter(
            ref self: ComponentState<TContractState>, reporter: ContractAddress, allowed: bool,
        ) {
            assert(Hooks::authorize_admin(@self, get_caller_address()), errors::NOT_ADMIN);
            InternalTrait::set_reporter(ref self, reporter, allowed);
        }

        /// A registered reporter or `'Quest: not reporter'`.
        fn progress(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            task_id: u32,
            count: u32,
            mode: Mode,
        ) {
            InternalTrait::assert_reporter(@self, get_caller_address());
            InternalTrait::progress(ref self, player_id, task_id, count, mode);
        }

        /// A registered reporter or `'Quest: not reporter'`.
        fn progress_many(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            entries: Span<TaskProgress>,
            mode: Mode,
        ) {
            InternalTrait::assert_reporter(@self, get_caller_address());
            InternalTrait::progress_many(ref self, player_id, entries, mode);
        }

        /// `authorize_player(caller, player_id)` or `'Quest: not authorized'`.
        fn accept(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32) {
            assert_player(@self, player_id);
            InternalTrait::accept(ref self, player_id, quest_id);
        }

        /// `authorize_player(caller, player_id)` or `'Quest: not authorized'`.
        fn abandon(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32) {
            assert_player(@self, player_id);
            InternalTrait::abandon(ref self, player_id, quest_id);
        }

        /// `authorize_player(caller, player_id)` or `'Quest: not authorized'`.
        fn claim(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
        ) -> u64 {
            assert_player(@self, player_id);
            InternalTrait::claim(ref self, player_id, quest_id, interval_id)
        }
    }

    /// Access control of the player's entrypoints, shared by three of them. A free function of
    /// 0.1.0, kept: a trait would add nothing, and it is private to the component.
    fn assert_player<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: QuestHooksTrait<TContractState>,
        +Drop<TContractState>,
    >(
        self: @ComponentState<TContractState>, player_id: felt252,
    ) {
        assert(
            Hooks::authorize_player(self, get_caller_address(), player_id), errors::NOT_AUTHORIZED,
        );
    }

    /// The views, optional to embed. None writes.
    #[embeddable_as(QuestViewImpl)]
    impl QuestView<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: QuestHooksTrait<TContractState>,
        impl Tracking: QuestTracking<TContractState>,
        +Drop<TContractState>,
    > of IQuestView<ComponentState<TContractState>> {
        fn quest_definition(
            self: @ComponentState<TContractState>, quest_id: u32,
        ) -> (HeadSlot, Span<QuestTask>, Span<u32>) {
            self.definition(quest_id)
        }

        fn quest_progress(
            self: @ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
        ) -> ProgressSlot {
            self.progress_of(player_id, quest_id, interval_id)
        }

        fn quest_record(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> RecordSlot {
            self.record_of(player_id, quest_id)
        }

        fn quest_current_interval(
            self: @ComponentState<TContractState>, quest_id: u32,
        ) -> Option<u64> {
            self.current_interval(quest_id)
        }

        fn quest_is_unlocked(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> bool {
            self.is_unlocked(player_id, quest_id)
        }

        fn quest_is_accepted(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> bool {
            self.is_accepted(player_id, quest_id)
        }

        fn quest_held(
            self: @ComponentState<TContractState>, player_id: felt252,
        ) -> Span<QuestHeld> {
            self.held_of(player_id)
        }

        fn quest_is_reporter(
            self: @ComponentState<TContractState>, reporter: ContractAddress,
        ) -> bool {
            self.get_reporter(reporter).allowed
        }
    }
}
