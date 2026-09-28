//! The Starknet component of `quiver_quest` (ARC-01 §3.3 to §3.7): storage, events, hooks, the
//! trusted internal layer, and the optional external ABI with its access control.
//!
//! **The internal layer is trusted**: `InternalImpl` checks no caller. A consumer calls it from
//! its own entrypoints, after its own checks. Only the external impls `QuestImpl` and
//! `QuestViewImpl` check anything, and only when the consumer embeds them.
//!
//! Every loop is bounded: batches by `MAX_ENTRIES` (checked first by `batch_merge`), pages by
//! `MAX_PAGES`, the quests of a page by `QUESTS_PER_PAGE`, tasks by `MAX_TASKS`, conditions by
//! `MAX_CONDITIONS`.

#[starknet::component]
pub mod QuestComponent {
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use crate::constants::{MAX_PAGES, QUESTS_PER_PAGE};
    use crate::errors;
    use crate::interface::{IQuest, IQuestView};
    use crate::logic::{
        Mode, QuestConditions, QuestDefinition, QuestIdPage, QuestProgress, QuestRecord,
        QuestSchedule, QuestTask, QuestTasks, TaskProgress, batch_first_position, batch_merge,
        claim as claim_logic, conditions_span, definition_new, page_pop, page_position, page_push,
        page_set, progress_add, record_abandon, record_accept, record_complete, record_is_accepted,
        schedule_interval_id, tasks_span,
    };

    /// Members are prefixed with `Quest_` so that they do not collide in the consumer's storage.
    /// Every value is one felt (layouts in `quiver_quest::logic::types`).
    #[storage]
    pub struct Storage {
        /// Slot A, key `quest_id`.
        pub Quest_definitions: Map<u32, QuestDefinition>,
        /// Slot B, key `quest_id`.
        pub Quest_tasks: Map<u32, QuestTasks>,
        /// Slot C, key `quest_id`; written only for a quest with conditions.
        pub Quest_conditions: Map<u32, QuestConditions>,
        /// Live quests using a task, key `(task_id, page)`; pages are contiguous.
        pub Quest_task_pages: Map<(u32, u8), QuestIdPage>,
        /// Key `(player_id, quest_id, interval_id)`.
        pub Quest_progress: Map<(felt252, u32, u64), QuestProgress>,
        /// Key `(player_id, quest_id)`.
        pub Quest_records: Map<(felt252, u32), QuestRecord>,
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

    /// Every `define`.
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct QuestDefined {
        #[key]
        pub quest_id: u32,
        pub schedule: QuestSchedule,
        pub tasks: Span<QuestTask>,
        pub conditions: Span<u32>,
        pub needs_accept: bool,
    }

    /// `Mode::Event` only; one per merged, non-zero entry.
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct QuestProgressed {
        #[key]
        pub player_id: felt252,
        #[key]
        pub task_id: u32,
        pub count: u32,
    }

    /// `Mode::Storage`, once per completion.
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct QuestCompleted {
        #[key]
        pub player_id: felt252,
        #[key]
        pub quest_id: u32,
        pub interval_id: u64,
    }

    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct QuestClaimed {
        #[key]
        pub player_id: felt252,
        #[key]
        pub quest_id: u32,
        pub interval_id: u64,
    }

    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct QuestRetired {
        #[key]
        pub quest_id: u32,
    }

    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub struct QuestReporterSet {
        #[key]
        pub reporter: ContractAddress,
        pub allowed: bool,
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
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        /// Validates (`definition_new`), then refuses `'Quest: already defined'` (retired or
        /// not), a condition not defined or retired (`'Quest: invalid condition'`), a condition
        /// with `0xffff` live dependents (`'Quest: too many dependents'`), and a task whose 4
        /// pages are full (`'Quest: task full'`). Writes each condition's A (`live_dependents +
        /// 1`), one page per task, A, B, C (only with conditions); emits `QuestDefined`.
        fn define(
            ref self: ComponentState<TContractState>,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
            needs_accept: bool,
        ) {
            let (definition, quest_tasks, quest_conditions) = definition_new(
                quest_id, schedule, tasks, conditions, needs_accept,
            );
            assert(!self.Quest_definitions.read(quest_id).defined, errors::ALREADY_DEFINED);
            // Conditions: at most MAX_CONDITIONS, checked by definition_new
            for condition in conditions {
                let condition = *condition;
                let mut prerequisite = self.Quest_definitions.read(condition);
                assert(prerequisite.defined && !prerequisite.retired, errors::INVALID_CONDITION);
                assert(prerequisite.live_dependents != 0xffff, errors::TOO_MANY_DEPENDENTS);
                prerequisite.live_dependents += 1;
                self.Quest_definitions.write(condition, prerequisite);
            }
            // Tasks: at most MAX_TASKS, checked by definition_new
            for task in tasks {
                let task_id = *task.task_id;
                let (index, page) = self.first_open_page(task_id);
                self.Quest_task_pages.write((task_id, index), page_push(page, quest_id));
            }
            self.Quest_definitions.write(quest_id, definition);
            self.Quest_tasks.write(quest_id, quest_tasks);
            if definition.condition_count != 0 {
                self.Quest_conditions.write(quest_id, quest_conditions);
            }
            self.emit(QuestDefined { quest_id, schedule, tasks, conditions, needs_accept });
        }

        /// Refuses `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: has live
        /// dependents'`. Removes the quest from each of its tasks' pages (the last id of the
        /// last non-empty page fills the hole, so pages stay contiguous), decrements its
        /// conditions' `live_dependents`, sets `retired`; emits `QuestRetired`. Player data is
        /// kept: completed intervals stay claimable.
        fn retire(ref self: ComponentState<TContractState>, quest_id: u32) {
            let mut definition = self.Quest_definitions.read(quest_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            assert(!definition.retired, errors::RETIRED);
            assert(definition.live_dependents == 0, errors::HAS_LIVE_DEPENDENTS);
            let quest_tasks = self.Quest_tasks.read(quest_id);
            for task in tasks_span(@quest_tasks, definition.task_count) {
                self.remove_from_pages(*task.task_id, quest_id);
            }
            if definition.condition_count != 0 {
                let conditions = self.Quest_conditions.read(quest_id);
                for condition in conditions_span(@conditions, definition.condition_count) {
                    let condition = *condition;
                    let mut prerequisite = self.Quest_definitions.read(condition);
                    prerequisite.live_dependents -= 1;
                    self.Quest_definitions.write(condition, prerequisite);
                }
            }
            definition.retired = true;
            self.Quest_definitions.write(quest_id, definition);
            self.emit(QuestRetired { quest_id });
        }

        /// Registers or revokes a reporter; emits `QuestReporterSet`.
        fn set_reporter(
            ref self: ComponentState<TContractState>, reporter: ContractAddress, allowed: bool,
        ) {
            self.Quest_reporters.write(reporter, allowed);
            self.emit(QuestReporterSet { reporter, allowed });
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
        /// quest-level reason: a quest inactive, locked, not accepted or already completed is
        /// skipped.
        ///
        /// `Mode::Event`: one `QuestProgressed` per merged, non-zero entry; no read, no write, no
        /// hook. `Mode::Storage`: each affected progress and record is read and written at most
        /// once; `QuestCompleted` then `on_quest_complete` per completion, after its writes.
        ///
        /// The consumer aggregates its results by task and calls this once per player per
        /// transaction: the package cannot see across calls.
        fn progress_many(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            entries: Span<TaskProgress>,
            mode: Mode,
        ) {
            let batch = batch_merge(entries);
            if batch.len() == 0 {
                return;
            }
            if mode == Mode::Event {
                for entry in batch {
                    let TaskProgress { task_id, count } = *entry;
                    self.emit(QuestProgressed { player_id, task_id, count });
                }
                return;
            }
            let time = get_block_timestamp();
            let mut position: u32 = 0;
            for entry in batch {
                let task_id = *entry.task_id;
                // The live quests on the task, read before any of them is processed. The first
                // page alone when it is not full, as with a few quests per task
                let first = self.Quest_task_pages.read((task_id, 0));
                let mut pages: Array<QuestIdPage> = array![first];
                if first.len == QUESTS_PER_PAGE {
                    let mut index: u8 = 1;
                    while index < MAX_PAGES {
                        let page = self.Quest_task_pages.read((task_id, index));
                        pages.append(page);
                        if page.len < QUESTS_PER_PAGE {
                            break;
                        }
                        index += 1;
                    }
                }
                for page in pages {
                    let QuestIdPage { len, ids } = page;
                    let mut slot: u8 = 0;
                    while slot < len {
                        let quest_id = match slot {
                            0 => ids.q0,
                            1 => ids.q1,
                            2 => ids.q2,
                            3 => ids.q3,
                            4 => ids.q4,
                            5 => ids.q5,
                            _ => ids.q6,
                        };
                        self.progress_quest(player_id, quest_id, batch, position, time);
                        slot += 1;
                    }
                }
                position += 1;
            }
        }

        /// Refuses `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: no accept step'`,
        /// `'Quest: not active'` (outside the schedule), `'Quest: locked'` (prerequisites not
        /// met), `'Quest: already accepted'` (in this interval), `'Quest: already completed'`
        /// (this interval). The acceptance holds until completion, abandon or rollover.
        fn accept(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32) {
            let definition = self.Quest_definitions.read(quest_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            assert(!definition.retired, errors::RETIRED);
            assert(definition.needs_accept, errors::NO_ACCEPT_STEP);
            let interval_id =
                match schedule_interval_id(@definition.schedule, get_block_timestamp()) {
                Option::Some(interval_id) => interval_id,
                Option::None => core::panic_with_felt252(errors::NOT_ACTIVE),
            };
            let mut record = self.Quest_records.read((player_id, quest_id));
            if definition.condition_count != 0 && !record.unlocked {
                assert(
                    self.prerequisites_are_met(player_id, quest_id, definition.condition_count),
                    errors::LOCKED,
                );
                record.unlocked = true;
            }
            assert(!record_is_accepted(@record, interval_id), errors::ALREADY_ACCEPTED);
            let progress = self.Quest_progress.read((player_id, quest_id, interval_id));
            assert(!progress.completed, errors::ALREADY_COMPLETED);
            self.Quest_records.write((player_id, quest_id), record_accept(record, interval_id));
        }

        /// Refuses `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: not active'`,
        /// `'Quest: not accepted'` (no acceptance in the current interval). The counts of the
        /// interval are kept.
        fn abandon(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32) {
            let definition = self.Quest_definitions.read(quest_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            assert(!definition.retired, errors::RETIRED);
            let interval_id =
                match schedule_interval_id(@definition.schedule, get_block_timestamp()) {
                Option::Some(interval_id) => interval_id,
                Option::None => core::panic_with_felt252(errors::NOT_ACTIVE),
            };
            let record = self.Quest_records.read((player_id, quest_id));
            self.Quest_records.write((player_id, quest_id), record_abandon(record, interval_id));
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
            let progress_key = (player_id, quest_id, interval_id);
            let record_key = (player_id, quest_id);
            let (progress, record, claim_index) = claim_logic(
                self.Quest_progress.read(progress_key), self.Quest_records.read(record_key),
            );
            self.Quest_progress.write(progress_key, progress);
            self.Quest_records.write(record_key, record);
            self.emit(QuestClaimed { player_id, quest_id, interval_id });
            Hooks::on_quest_claim(ref self, player_id, quest_id, interval_id, claim_index);
            claim_index
        }

        /// Panics `'Quest: not reporter'` unless `caller` is a registered reporter.
        fn assert_reporter(self: @ComponentState<TContractState>, caller: ContractAddress) {
            assert(self.Quest_reporters.read(caller), errors::NOT_REPORTER);
        }

        /// A, the tasks and the conditions. Panics `'Quest: does not exist'`.
        fn definition(
            self: @ComponentState<TContractState>, quest_id: u32,
        ) -> (QuestDefinition, Span<QuestTask>, Span<u32>) {
            let definition = self.Quest_definitions.read(quest_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            let quest_tasks = self.Quest_tasks.read(quest_id);
            let conditions = if definition.condition_count == 0 {
                array![].span()
            } else {
                conditions_span(@self.Quest_conditions.read(quest_id), definition.condition_count)
            };
            (definition, tasks_span(@quest_tasks, definition.task_count), conditions)
        }

        /// The raw progress of a player on a quest in an interval.
        fn progress_of(
            self: @ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
        ) -> QuestProgress {
            self.Quest_progress.read((player_id, quest_id, interval_id))
        }

        /// The raw record; use `is_accepted` to know whether a quest is accepted.
        fn record_of(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> QuestRecord {
            self.Quest_records.read((player_id, quest_id))
        }

        /// The interval id now; `None` outside the schedule or for a quest not defined.
        fn current_interval(self: @ComponentState<TContractState>, quest_id: u32) -> Option<u64> {
            let definition = self.Quest_definitions.read(quest_id);
            if !definition.defined {
                return Option::None;
            }
            schedule_interval_id(@definition.schedule, get_block_timestamp())
        }

        /// Panics `'Quest: does not exist'`. True without conditions or once cached; otherwise
        /// evaluates the prerequisites. Writes nothing: the next progress or accept caches it.
        fn is_unlocked(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> bool {
            let definition = self.Quest_definitions.read(quest_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            if definition.condition_count == 0
                || self.Quest_records.read((player_id, quest_id)).unlocked {
                return true;
            }
            self.prerequisites_are_met(player_id, quest_id, definition.condition_count)
        }

        /// False for a quest not defined or retired, and outside the schedule; otherwise
        /// accepted in the current interval.
        fn is_accepted(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> bool {
            let definition = self.Quest_definitions.read(quest_id);
            if !definition.defined || definition.retired {
                return false;
            }
            match schedule_interval_id(@definition.schedule, get_block_timestamp()) {
                Option::Some(interval_id) => record_is_accepted(
                    @self.Quest_records.read((player_id, quest_id)), interval_id,
                ),
                Option::None => false,
            }
        }
    }

    #[generate_trait]
    impl PrivateImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: QuestHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of PrivateTrait<TContractState> {
        /// Step 2.2 of `progress_many` (ARC-01 §3.5) for one quest reached at `position` of the
        /// merged `batch`.
        fn progress_quest(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            batch: Span<TaskProgress>,
            position: u32,
            time: u64,
        ) {
            // 1. B; a quest reached at a later entry was handled at its first one. A quest of one
            // task (t1 unused) is on this task's page only, so this entry is its first position
            // and its only count: neither needs a scan of the batch
            let quest_tasks = self.Quest_tasks.read(quest_id);
            let single = quest_tasks.t1.task_id == 0;
            if !single && batch_first_position(batch, @quest_tasks) != Option::Some(position) {
                return;
            }
            // 2. A; skip a quest retired since the pages were read (a hook of an earlier quest
            // of this call may retire it: page removal alone does not stop this call), then
            // outside the schedule
            let definition = self.Quest_definitions.read(quest_id);
            if definition.retired {
                return;
            }
            let interval_id = match schedule_interval_id(@definition.schedule, time) {
                Option::Some(interval_id) => interval_id,
                Option::None => { return; },
            };
            // 3. R, only for acceptance or prerequisites
            let record_key = (player_id, quest_id);
            let mut record = QuestRecord {
                completions: 0, claims: 0, unlocked: false, active: false, accepted_interval: 0,
            };
            let mut record_read = false;
            let mut record_marked = false;
            if definition.needs_accept || definition.condition_count != 0 {
                record = self.Quest_records.read(record_key);
                record_read = true;
                if definition.needs_accept && !record_is_accepted(@record, interval_id) {
                    return;
                }
                if definition.condition_count != 0 && !record.unlocked {
                    if !self
                        .prerequisites_are_met(player_id, quest_id, definition.condition_count) {
                        return;
                    }
                    record.unlocked = true;
                    record_marked = true;
                }
            }
            // 4. P; skip once completed in this interval
            let progress_key = (player_id, quest_id, interval_id);
            let progress = self.Quest_progress.read(progress_key);
            if progress.completed {
                return;
            }
            // 5. Every batched count of the quest's tasks at once
            let counts = if single {
                batch.slice(position, 1)
            } else {
                batch
            };
            let (progress, changed, completed) = progress_add(
                progress, @quest_tasks, definition.task_count, counts,
            );
            if !changed && !record_marked {
                return;
            }
            // 6. The record on completion
            if completed {
                if !record_read {
                    record = self.Quest_records.read(record_key);
                }
                record = record_complete(record);
                record_marked = true;
            }
            // 7. One write each
            if changed {
                self.Quest_progress.write(progress_key, progress);
            }
            if record_marked {
                self.Quest_records.write(record_key, record);
            }
            // 8. Event, then hook, after the writes
            if completed {
                self.emit(QuestCompleted { player_id, quest_id, interval_id });
                Hooks::on_quest_complete(
                    ref self, player_id, quest_id, interval_id, record.completions,
                );
            }
        }

        /// Reads C, then the record of each prerequisite in order (at most `MAX_CONDITIONS`),
        /// stopping at the first one never completed: the result of `prerequisites_met` over all
        /// of them, without reading the rest.
        fn prerequisites_are_met(
            self: @ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            condition_count: u8,
        ) -> bool {
            let conditions = self.Quest_conditions.read(quest_id);
            for condition in conditions_span(@conditions, condition_count) {
                if self.Quest_records.read((player_id, *condition)).completions == 0 {
                    return false;
                }
            }
            true
        }

        /// The first page of `task_id` with room, and its index. Panics `'Quest: task full'`
        /// when the `MAX_PAGES` pages are full.
        fn first_open_page(
            self: @ComponentState<TContractState>, task_id: u32,
        ) -> (u8, QuestIdPage) {
            let mut index: u8 = 0;
            loop {
                let page = self.Quest_task_pages.read((task_id, index));
                if page.len < QUESTS_PER_PAGE {
                    break (index, page);
                }
                index += 1;
                assert(index < MAX_PAGES, errors::TASK_FULL);
            }
        }

        /// Removes `quest_id` from the pages of `task_id`, keeping them contiguous: the last id
        /// of the last non-empty page fills the hole. One write if both are the same page, two
        /// otherwise.
        fn remove_from_pages(
            ref self: ComponentState<TContractState>, task_id: u32, quest_id: u32,
        ) {
            // Read the pages in order until one is not full (at most MAX_PAGES)
            let mut pages: Array<QuestIdPage> = array![];
            let mut hole: Option<(u8, u8)> = Option::None;
            let mut index: u8 = 0;
            while index < MAX_PAGES {
                let page = self.Quest_task_pages.read((task_id, index));
                pages.append(page);
                if hole.is_none() {
                    if let Option::Some(position) = page_position(@page, quest_id) {
                        hole = Option::Some((index, position));
                    }
                }
                if page.len < QUESTS_PER_PAGE {
                    break;
                }
                index += 1;
            }
            // A live quest is on each of its tasks' pages
            let (hole_index, hole_position) = hole.unwrap();
            // The last non-empty page: the last read, or the one before it when that is empty
            let mut last_index: u8 = pages.len().try_into().unwrap() - 1;
            if *pages[last_index.into()].len == 0 {
                last_index -= 1;
            }
            let (last_page, moved) = page_pop(*pages[last_index.into()]);
            if last_index == hole_index {
                let page = if moved == quest_id {
                    last_page
                } else {
                    page_set(last_page, hole_position, moved)
                };
                self.Quest_task_pages.write((task_id, hole_index), page);
            } else {
                let page = page_set(*pages[hole_index.into()], hole_position, moved);
                self.Quest_task_pages.write((task_id, hole_index), page);
                self.Quest_task_pages.write((task_id, last_index), last_page);
            }
        }
    }

    /// The access-checked ABI (ARC-01 §3.6), optional to embed.
    #[embeddable_as(QuestImpl)]
    impl Quest<
        TContractState,
        +HasComponent<TContractState>,
        impl Hooks: QuestHooksTrait<TContractState>,
        +Drop<TContractState>,
    > of IQuest<ComponentState<TContractState>> {
        /// `authorize_admin(caller)` or `'Quest: not admin'`.
        fn define(
            ref self: ComponentState<TContractState>,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
            needs_accept: bool,
        ) {
            assert(Hooks::authorize_admin(@self, get_caller_address()), errors::NOT_ADMIN);
            InternalTrait::define(ref self, quest_id, schedule, tasks, conditions, needs_accept);
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
        +Drop<TContractState>,
    > of IQuestView<ComponentState<TContractState>> {
        fn quest_definition(
            self: @ComponentState<TContractState>, quest_id: u32,
        ) -> (QuestDefinition, Span<QuestTask>, Span<u32>) {
            self.definition(quest_id)
        }

        fn quest_progress(
            self: @ComponentState<TContractState>,
            player_id: felt252,
            quest_id: u32,
            interval_id: u64,
        ) -> QuestProgress {
            self.progress_of(player_id, quest_id, interval_id)
        }

        fn quest_record(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> QuestRecord {
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

        fn quest_is_reporter(
            self: @ComponentState<TContractState>, reporter: ContractAddress,
        ) -> bool {
            self.Quest_reporters.read(reporter)
        }
    }
}
