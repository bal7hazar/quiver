//! Builders shared by the tests: they keep each test to its given, when and then.

use quiver_quest::logic::{
    QuestConditions, QuestHeld, QuestHeldSlot, QuestProgress, QuestRecord, QuestSchedule, QuestTask,
    QuestTasks, TaskProgress,
};

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

pub fn tasks(t0: QuestTask, t1: QuestTask, t2: QuestTask) -> QuestTasks {
    QuestTasks { t0, t1, t2 }
}

pub fn one_task(task_id: u32, total: u32) -> QuestTasks {
    tasks(task(task_id, total), task(0, 0), task(0, 0))
}

pub fn ids(q0: u32, q1: u32, q2: u32, q3: u32, q4: u32, q5: u32, q6: u32) -> QuestConditions {
    QuestConditions { q0, q1, q2, q3, q4, q5, q6 }
}

pub fn no_ids() -> QuestConditions {
    ids(0, 0, 0, 0, 0, 0, 0)
}

/// An entry with acceptance number 0.
pub fn held(quest_id: u32, interval_id: u64) -> QuestHeld {
    QuestHeld { quest_id, interval_id, acceptance: 0 }
}

/// An entry with its acceptance number.
pub fn stamped(quest_id: u32, interval_id: u64, acceptance: u16) -> QuestHeld {
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

/// A slot of the held list with counter 0.
pub fn held_slot(e0: QuestHeld, e1: QuestHeld) -> QuestHeldSlot {
    QuestHeldSlot { e0, e1, counter: 0 }
}

/// Slot 0 of a held list, with the player's acceptance counter.
pub fn held_slot0(e0: QuestHeld, e1: QuestHeld, counter: u16) -> QuestHeldSlot {
    QuestHeldSlot { e0, e1, counter }
}

pub fn progress(c0: u32, c1: u32, c2: u32, completed: bool, claimed: bool) -> QuestProgress {
    QuestProgress { c0, c1, c2, completed, claimed }
}

pub fn no_progress() -> QuestProgress {
    progress(0, 0, 0, false, false)
}

pub fn record(completions: u64, claims: u64, unlocked: bool) -> QuestRecord {
    QuestRecord { completions, claims, unlocked }
}

pub fn no_record() -> QuestRecord {
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
