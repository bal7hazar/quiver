//! The Starknet component of `quiver_quest` (ARC-01 §3.3 to §3.7, amended by D-135): storage,
//! events, hooks, the trusted internal layer, and the optional external ABI with its access
//! control.
//!
//! **The internal layer is trusted**: `InternalImpl` checks no caller. A consumer calls it from
//! its own entrypoints, after its own checks. Only the external impls `QuestImpl` and
//! `QuestViewImpl` check anything, and only when the consumer embeds them.
//!
//! **Every quest is accepted before it progresses** (D-135). A player holds at most `MAX_HELD`
//! quests, in a list of at most `HELD_SLOTS` slots; progress walks that list, not the quests of
//! the reported tasks, so the cost of a call depends on the held quests only.
//!
//! Every loop is bounded: batches by `MAX_ENTRIES` (checked first by `batch_merge`), the held
//! list by `HELD_SLOTS` slots of 2 entries (`MAX_HELD_LIMIT`), tasks by `MAX_TASKS`, conditions
//! by `MAX_CONDITIONS`.

#[starknet::component]
pub mod QuestComponent {
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use crate::constants::{HELD_SLOTS, MAX_HELD};
    use crate::errors;
    use crate::interface::{IQuest, IQuestView};
    use crate::logic::{
        Mode, QuestConditions, QuestDefinition, QuestHeld, QuestHeldSlot, QuestProgress,
        QuestRecord, QuestSchedule, QuestTask, QuestTasks, TaskProgress, batch_merge,
        claim as claim_logic, conditions_span, definition_new, held_contains, held_position,
        held_remove, held_slot, progress_add, record_complete, schedule_interval_id, tasks_span,
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
        /// Key `(player_id, quest_id, interval_id)`.
        pub Quest_progress: Map<(felt252, u32, u64), QuestProgress>,
        /// Key `(player_id, quest_id)`.
        pub Quest_records: Map<(felt252, u32), QuestRecord>,
        /// The held list, key `(player_id, slot)`, slots `0..HELD_SLOTS`; contiguous from slot 0.
        pub Quest_held: Map<(felt252, u8), QuestHeldSlot>,
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
        /// with `0xffff` live dependents (`'Quest: too many dependents'`). Writes each
        /// condition's A (`live_dependents + 1`), A, B, C (only with conditions); emits
        /// `QuestDefined`. Any number of quests may use a task.
        fn define(
            ref self: ComponentState<TContractState>,
            quest_id: u32,
            schedule: QuestSchedule,
            tasks: Span<QuestTask>,
            conditions: Span<u32>,
        ) {
            let (definition, quest_tasks, quest_conditions) = definition_new(
                quest_id, schedule, tasks, conditions,
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
            self.Quest_definitions.write(quest_id, definition);
            self.Quest_tasks.write(quest_id, quest_tasks);
            if definition.condition_count != 0 {
                self.Quest_conditions.write(quest_id, quest_conditions);
            }
            self.emit(QuestDefined { quest_id, schedule, tasks, conditions });
        }

        /// Refuses `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: has live
        /// dependents'`. Decrements its conditions' `live_dependents`, sets `retired`; emits
        /// `QuestRetired`. Player data is kept: completed intervals stay claimable. The held
        /// entries of the quest become dead: progress skips them, and each player's next `accept`
        /// prunes them.
        fn retire(ref self: ComponentState<TContractState>, quest_id: u32) {
            let mut definition = self.Quest_definitions.read(quest_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            assert(!definition.retired, errors::RETIRED);
            assert(definition.live_dependents == 0, errors::HAS_LIVE_DEPENDENTS);
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
            // The held quests when the call starts. A hook may accept or abandon: once a hook
            // has run, each later entry is processed only if the list still holds it. An entry
            // accepted by a hook is not in this walk
            let held = self.held_read(player_id);
            let mut hooked = false;
            let mut position: u32 = 0;
            for entry in held {
                let entry = *entry;
                if hooked && !self.still_held(player_id, entry, position) {
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
            let definition = self.Quest_definitions.read(quest_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            assert(!definition.retired, errors::RETIRED);
            let time = get_block_timestamp();
            let interval_id = match schedule_interval_id(@definition.schedule, time) {
                Option::Some(interval_id) => interval_id,
                Option::None => core::panic_with_felt252(errors::NOT_ACTIVE),
            };
            let record_key = (player_id, quest_id);
            let mut unlock: Option<QuestRecord> = Option::None;
            if definition.condition_count != 0 {
                let record = self.Quest_records.read(record_key);
                if !record.unlocked {
                    assert(
                        self.prerequisites_are_met(player_id, quest_id, definition.condition_count),
                        errors::LOCKED,
                    );
                    unlock = Option::Some(QuestRecord { unlocked: true, ..record });
                }
            }
            let held = self.held_read(player_id);
            let completed = self.Quest_progress.read((player_id, quest_id, interval_id)).completed;
            if let Option::Some(position) = held_position(held, quest_id) {
                // Its own entry is live when it is of this interval and not completed: A is
                // already known not retired
                assert(
                    *held[position].interval_id != interval_id || completed,
                    errors::ALREADY_ACCEPTED,
                );
            }
            assert(!completed, errors::ALREADY_COMPLETED);
            // Keep the live entries of the other quests, in order
            let mut kept: Array<QuestHeld> = array![];
            for entry in held {
                let entry = *entry;
                if entry.quest_id != quest_id && self.held_is_live(player_id, entry, time) {
                    kept.append(entry);
                }
            }
            assert(kept.len() < MAX_HELD.into(), errors::TOO_MANY_HELD);
            kept.append(QuestHeld { quest_id, interval_id });
            self.held_write(player_id, held, kept.span());
            if let Option::Some(record) = unlock {
                self.Quest_records.write(record_key, record);
            }
        }

        /// Refuses `'Quest: does not exist'`, `'Quest: retired'`, `'Quest: not active'`,
        /// `'Quest: not accepted'` (not held in the current interval, or that interval is
        /// completed). Removes the quest from the held list; the later entries move up. The
        /// counts of the interval are kept.
        fn abandon(ref self: ComponentState<TContractState>, player_id: felt252, quest_id: u32) {
            let definition = self.Quest_definitions.read(quest_id);
            assert(definition.defined, errors::DOES_NOT_EXIST);
            assert(!definition.retired, errors::RETIRED);
            let interval_id =
                match schedule_interval_id(@definition.schedule, get_block_timestamp()) {
                Option::Some(interval_id) => interval_id,
                Option::None => core::panic_with_felt252(errors::NOT_ACTIVE),
            };
            let held = self.held_read(player_id);
            let position = match held_position(held, quest_id) {
                Option::Some(position) => position,
                Option::None => core::panic_with_felt252(errors::NOT_ACCEPTED),
            };
            assert(*held[position].interval_id == interval_id, errors::NOT_ACCEPTED);
            assert(
                !self.Quest_progress.read((player_id, quest_id, interval_id)).completed,
                errors::NOT_ACCEPTED,
            );
            self.held_write(player_id, held, held_remove(held, position));
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

        /// The record: completions, claims, and the cached unlock.
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
        /// evaluates the prerequisites. Writes nothing: `accept` caches it.
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

        /// False for a quest not defined or retired, and outside the schedule; otherwise held in
        /// the current interval, and that interval not completed.
        fn is_accepted(
            self: @ComponentState<TContractState>, player_id: felt252, quest_id: u32,
        ) -> bool {
            let definition = self.Quest_definitions.read(quest_id);
            if !definition.defined || definition.retired {
                return false;
            }
            let interval_id =
                match schedule_interval_id(@definition.schedule, get_block_timestamp()) {
                Option::Some(interval_id) => interval_id,
                Option::None => { return false; },
            };
            let entry = QuestHeld { quest_id, interval_id };
            held_contains(self.held_read(player_id), entry)
                && !self.Quest_progress.read((player_id, quest_id, interval_id)).completed
        }

        /// The player's held entries, in the order of acceptance, live or dead (not yet pruned).
        fn held_of(self: @ComponentState<TContractState>, player_id: felt252) -> Span<QuestHeld> {
            self.held_read(player_id)
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
            let QuestHeld { quest_id, interval_id } = entry;
            // 1. A; skip a retired quest (a hook of an earlier quest of this call may retire it),
            // then an acceptance of another interval (expired at rollover) or outside the
            // schedule
            let definition = self.Quest_definitions.read(quest_id);
            if definition.retired {
                return false;
            }
            if schedule_interval_id(@definition.schedule, time) != Option::Some(interval_id) {
                return false;
            }
            // 2. P; skip once completed in this interval
            let progress_key = (player_id, quest_id, interval_id);
            let progress = self.Quest_progress.read(progress_key);
            if progress.completed {
                return false;
            }
            // 3. B, and every batched count of the quest's tasks at once
            let quest_tasks = self.Quest_tasks.read(quest_id);
            let (progress, changed, completed) = progress_add(
                progress, @quest_tasks, definition.task_count, batch,
            );
            if !changed {
                return false;
            }
            // 4. One write each: P, and R on completion
            self.Quest_progress.write(progress_key, progress);
            if !completed {
                return false;
            }
            let record_key = (player_id, quest_id);
            let record = record_complete(self.Quest_records.read(record_key));
            self.Quest_records.write(record_key, record);
            // 5. Event, then hook, after the writes
            self.emit(QuestCompleted { player_id, quest_id, interval_id });
            Hooks::on_quest_complete(
                ref self, player_id, quest_id, interval_id, record.completions,
            );
            true
        }

        /// Whether the list still holds `entry`, read at `position` of the list when the call
        /// started. One slot read when it is still there, as after a hook that did not touch the
        /// list; the whole list otherwise, since `abandon` moves the later entries up.
        fn still_held(
            self: @ComponentState<TContractState>,
            player_id: felt252,
            entry: QuestHeld,
            position: u32,
        ) -> bool {
            let slot: u8 = (position / 2).try_into().unwrap();
            let pair = self.Quest_held.read((player_id, slot));
            let found = if position % 2 == 0 {
                pair.e0
            } else {
                pair.e1
            };
            found == entry || held_contains(self.held_read(player_id), entry)
        }

        /// Whether a held entry is live at `time`: its quest is not retired, `time` is in the
        /// entry's interval, and that interval is not completed. Reads A, then P only when the
        /// interval matches.
        fn held_is_live(
            self: @ComponentState<TContractState>, player_id: felt252, entry: QuestHeld, time: u64,
        ) -> bool {
            let QuestHeld { quest_id, interval_id } = entry;
            let definition = self.Quest_definitions.read(quest_id);
            if definition.retired
                || schedule_interval_id(@definition.schedule, time) != Option::Some(interval_id) {
                return false;
            }
            !self.Quest_progress.read((player_id, quest_id, interval_id)).completed
        }

        /// The held list: slots read in order while full, at most `HELD_SLOTS`. A slot whose
        /// `e1` is empty ends the list.
        fn held_read(self: @ComponentState<TContractState>, player_id: felt252) -> Span<QuestHeld> {
            let mut held: Array<QuestHeld> = array![];
            let mut slot: u8 = 0;
            while slot < HELD_SLOTS {
                let QuestHeldSlot { e0, e1 } = self.Quest_held.read((player_id, slot));
                if e0.quest_id == 0 {
                    break;
                }
                held.append(e0);
                if e1.quest_id == 0 {
                    break;
                }
                held.append(e1);
                slot += 1;
            }
            held.span()
        }

        /// Writes the slots of `after` that differ from those of `before`, the list as read: an
        /// unchanged slot is not written.
        fn held_write(
            ref self: ComponentState<TContractState>,
            player_id: felt252,
            before: Span<QuestHeld>,
            after: Span<QuestHeld>,
        ) {
            let len = if before.len() > after.len() {
                before.len()
            } else {
                after.len()
            };
            let mut slot: u32 = 0;
            while 2 * slot < len {
                let value = held_slot(after, slot);
                if held_slot(before, slot) != value {
                    self.Quest_held.write((player_id, slot.try_into().unwrap()), value);
                }
                slot += 1;
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

        fn quest_held(
            self: @ComponentState<TContractState>, player_id: felt252,
        ) -> Span<QuestHeld> {
            self.held_of(player_id)
        }

        fn quest_is_reporter(
            self: @ComponentState<TContractState>, reporter: ContractAddress,
        ) -> bool {
            self.Quest_reporters.read(reporter)
        }
    }
}
