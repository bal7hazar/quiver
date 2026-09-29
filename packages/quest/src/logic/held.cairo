//! A player's held list (ARC-01 §3.2, amended by D-135): the quests the player accepted, in the
//! order of acceptance, two per storage slot (`QuestHeldSlot`).
//!
//! The component reads the list as the span of its non-empty entries, changes it in memory, and
//! writes back only the slots that changed (`held_slot`). Every function visits at most the
//! span's entries: `MAX_HELD_LIMIT`, the list's capacity.

use super::types::{QuestHeld, QuestHeldSlot};

/// The empty entry: quest id 0 is never valid.
pub const HELD_EMPTY: QuestHeld = QuestHeld { quest_id: 0, interval_id: 0, acceptance: 0 };

/// The position of `quest_id` in `held`, if any. `accept` keeps a quest at most once in a list.
pub fn held_position(held: Span<QuestHeld>, quest_id: u32) -> Option<u32> {
    let mut held = held;
    let mut position = 0;
    while let Some(entry) = held.pop_front() {
        if *entry.quest_id == quest_id {
            return Some(position);
        }
        position += 1;
    }
    None
}

/// `entry` is in `held`: the same quest, interval and acceptance.
pub fn held_contains(held: Span<QuestHeld>, entry: QuestHeld) -> bool {
    let mut held = held;
    while let Some(other) = held.pop_front() {
        if *other == entry {
            return true;
        }
    }
    false
}

/// `held` without the entry at `position`; the later entries move up one place, so the list
/// stays contiguous and in the order of acceptance. A position outside `held` removes nothing.
pub fn held_remove(held: Span<QuestHeld>, position: u32) -> Span<QuestHeld> {
    let mut out = array![];
    let mut held = held;
    let mut index = 0;
    while let Some(entry) = held.pop_front() {
        if index != position {
            out.append(*entry);
        }
        index += 1;
    }
    out.span()
}

/// Slot `slot` of the list: entries `2 × slot` and `2 × slot + 1`, empty past the end,
/// `counter` in slot 0 (0 in the others), and `kept`.
pub fn held_slot(held: Span<QuestHeld>, slot: u32, counter: u32, kept: bool) -> QuestHeldSlot {
    let counter = if slot == 0 {
        counter
    } else {
        0
    };
    QuestHeldSlot { e0: entry_at(held, 2 * slot), e1: entry_at(held, 2 * slot + 1), counter, kept }
}

#[inline(always)]
fn entry_at(held: Span<QuestHeld>, index: u32) -> QuestHeld {
    match held.get(index) {
        Option::Some(entry) => *entry.unbox(),
        Option::None => HELD_EMPTY,
    }
}
