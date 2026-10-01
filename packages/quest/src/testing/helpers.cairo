//! Builders shared by the tests: they keep each test to its given, when and then.

use crate::models::definition::{
    ConditionsSlot, DefinitionStorage, DefinitionTrait, HeadSlot, TasksSlot,
};
use crate::models::held::{HeldSlot, HeldSlotStorage, HeldSlotTrait};
use crate::models::progress::{ProgressSlot, ProgressStorage, ProgressTrait};
use crate::models::record::{QuestRecord, RecordSlot, RecordStorage, RecordTrait};
use crate::types::batch::TaskProgress;
use crate::types::held::QuestHeld;
use crate::types::schedule::QuestSchedule;
use crate::types::task::QuestTask;

// The models' behaviour on the slots of 0.1.0: the tests of 0.1.0's pure functions, kept, run the
// models' code through these (ARC-07a). Keys are fixed; they play no part in the behaviour.

const PLAYER: felt252 = 'player';
const QUEST: u32 = 1;

/// `DefinitionTrait::new`, then its storage: the slots A, B and C of 0.1.0's `definition_new`.
pub fn definition_slots(
    quest_id: u32, schedule: QuestSchedule, tasks: Span<QuestTask>, conditions: Span<u32>,
) -> (HeadSlot, TasksSlot, ConditionsSlot) {
    DefinitionTrait::new(quest_id, schedule, tasks, conditions).into_slots()
}

/// `ProgressTrait::add` on a progress slot: `(progress, changed, completed by this call)`.
pub fn add_counts(
    progress: ProgressSlot, tasks: @TasksSlot, task_count: u8, batch: Span<TaskProgress>,
) -> (ProgressSlot, bool, bool) {
    let mut model = ProgressStorage::from_slot(PLAYER, QUEST, 0, progress);
    let (changed, completed) = model.add(tasks, task_count, batch);
    (model.into_slot(), changed, completed)
}

/// `ProgressTrait::is_complete` on a progress slot.
pub fn is_complete(progress: @ProgressSlot, tasks: @TasksSlot, task_count: u8) -> bool {
    ProgressStorage::from_slot(PLAYER, QUEST, 0, *progress).is_complete(tasks, task_count)
}

/// `RecordTrait::complete` on a record slot.
pub fn complete(record: RecordSlot) -> RecordSlot {
    let mut model = RecordStorage::from_slot(PLAYER, QUEST, record);
    model.complete();
    model.into_slot()
}

/// `ProgressTrait::claim` then `RecordTrait::claim`, as the component's `claim`: `(progress,
/// record, claim_index)`.
pub fn claim_both(progress: ProgressSlot, record: RecordSlot) -> (ProgressSlot, RecordSlot, u64) {
    let mut progress = ProgressStorage::from_slot(PLAYER, QUEST, 0, progress);
    let mut record = RecordStorage::from_slot(PLAYER, QUEST, record);
    progress.claim();
    let claim_index = record.claim();
    (progress.into_slot(), record.into_slot(), claim_index)
}

/// A record model, keys fixed: for `RecordTrait::all_completed`, which takes models.
pub fn record_model(completions: u64, claims: u64, unlocked: bool) -> QuestRecord {
    QuestRecord { player_id: PLAYER, quest_id: QUEST, completions, claims, unlocked }
}

/// `HeldSlotTrait::new`, as a slot: 0.1.0's `held_slot`.
pub fn held_slot_of(held: Span<QuestHeld>, slot: u32, counter: u32, kept: bool) -> HeldSlot {
    HeldSlotTrait::new(PLAYER, slot.try_into().unwrap(), held, counter, kept).into_slot()
}

pub const DAY: u32 = 86400;
pub const U32_MAX: u32 = 0xffffffff;
pub const U64_MAX: u64 = 0xffffffffffffffff;

pub fn schedule(start: u64, end: u64, duration: u32, interval: u32) -> QuestSchedule {
    QuestSchedule { start, end, duration, interval }
}

pub fn one_off() -> QuestSchedule {
    schedule(0, 0, 0, 0)
}

pub fn daily() -> QuestSchedule {
    schedule(0, 0, DAY, DAY)
}

pub fn task(task_id: u32, total: u32) -> QuestTask {
    QuestTask { task_id, total }
}

pub fn entry(task_id: u32, count: u32) -> TaskProgress {
    TaskProgress { task_id, count }
}

pub fn tasks(t0: QuestTask, t1: QuestTask, t2: QuestTask) -> TasksSlot {
    TasksSlot { t0, t1, t2 }
}

pub fn one_task(task_id: u32, total: u32) -> TasksSlot {
    tasks(task(task_id, total), task(0, 0), task(0, 0))
}

pub fn ids(q0: u32, q1: u32, q2: u32, q3: u32, q4: u32, q5: u32, q6: u32) -> ConditionsSlot {
    ConditionsSlot { q0, q1, q2, q3, q4, q5, q6 }
}

pub fn no_ids() -> ConditionsSlot {
    ids(0, 0, 0, 0, 0, 0, 0)
}

/// An entry with acceptance number 0.
pub fn held(quest_id: u32, interval_id: u64) -> QuestHeld {
    QuestHeld { quest_id, interval_id, acceptance: 0 }
}

/// An entry with its acceptance number.
pub fn stamped(quest_id: u32, interval_id: u64, acceptance: u32) -> QuestHeld {
    QuestHeld { quest_id, interval_id, acceptance }
}

/// The entries without their acceptance numbers, to compare quests and intervals only.
pub fn unstamped(entries: Span<QuestHeld>) -> Span<QuestHeld> {
    let mut out = array![];
    for entry in entries {
        out.append(QuestHeld { acceptance: 0, ..*entry });
    }
    out.span()
}

/// A slot of the held list with counter 0, `kept` when it holds an entry.
pub fn held_slot(e0: QuestHeld, e1: QuestHeld) -> HeldSlot {
    HeldSlot { e0, e1, counter: 0, kept: e0.quest_id != 0 }
}

/// Slot 0 of a held list, with the player's acceptance counter; `kept`, as slot 0 always is
/// once the player has accepted.
pub fn held_slot0(e0: QuestHeld, e1: QuestHeld, counter: u32) -> HeldSlot {
    HeldSlot { e0, e1, counter, kept: true }
}

/// A slot with every field given.
pub fn held_slot_k(e0: QuestHeld, e1: QuestHeld, counter: u32, kept: bool) -> HeldSlot {
    HeldSlot { e0, e1, counter, kept }
}

pub fn progress(c0: u32, c1: u32, c2: u32, completed: bool, claimed: bool) -> ProgressSlot {
    ProgressSlot { c0, c1, c2, completed, claimed }
}

pub fn no_progress() -> ProgressSlot {
    progress(0, 0, 0, false, false)
}

pub fn record(completions: u64, claims: u64, unlocked: bool) -> RecordSlot {
    RecordSlot { completions, claims, unlocked }
}

pub fn no_record() -> RecordSlot {
    record(0, 0, false)
}

/// `value`, hidden from the compiler: a benchmark's input is not folded into a constant.
#[inline(never)]
pub fn opaque<T, +Drop<T>>(value: T) -> T {
    value
}

/// `n` entries naming tasks `first`, `first + 1`, ..., each with count `count`.
pub fn distinct_entries(first: u32, n: u32, count: u32) -> Span<TaskProgress> {
    let mut out = array![];
    let mut i = 0;
    while i < n {
        out.append(entry(first + i, count));
        i += 1;
    }
    out.span()
}

/// `n` entries all naming `task_id`, each with count `count`.
pub fn same_entries(task_id: u32, n: u32, count: u32) -> Span<TaskProgress> {
    let mut out = array![];
    let mut i = 0;
    while i < n {
        out.append(entry(task_id, count));
        i += 1;
    }
    out.span()
}

/// A schedule that recurs hourly in a day, from second 1000: a benchmark's input.
pub fn recurring() -> QuestSchedule {
    opaque(schedule(1000, 0xffffffffffff, 3600, 86400))
}

/// A held list at its capacity, `MAX_HELD_LIMIT` = 8 entries.
pub fn eight_held() -> Span<QuestHeld> {
    opaque(
        array![
            held(1, 30), held(2, 30), held(3, 30), held(4, 30), held(5, 30), held(6, 30),
            held(7, 30), held(8, 30),
        ]
            .span(),
    )
}

pub fn three_tasks() -> TasksSlot {
    opaque(tasks(task(14, 100), task(15, 100), task(16, 100)))
}
