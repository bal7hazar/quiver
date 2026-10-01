//! An entry of a player's held list (ARC-01 §3.2, amended by D-135), and the list as the span of
//! its non-empty entries, in the order of acceptance. Stored two per slot of the held list
//! (`crate::models::held`), never on its own.
//!
//! The component reads the list, changes it in memory, and writes back only the slots that
//! changed. Every function visits at most the span's entries: `MAX_HELD_LIMIT`, the list's
//! capacity.

// Types

/// One quest a player holds: accepted in `interval_id`, as the player's acceptance number
/// `acceptance`. `quest_id == 0` is an empty entry.
///
/// An entry is **live** while its quest is not retired, the current interval of its quest is
/// `interval_id`, and that interval is not completed; otherwise it is dead, and the next `accept`
/// prunes it. The whole entry, quest, interval and acceptance number, identifies an acceptance: a
/// quest abandoned and accepted again is a new entry. `interval_id` is stored on 48 bits
/// (`HELD_INTERVAL_LIMIT`), `acceptance` on 30 (`ACCEPTANCE_LIMIT`).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestHeld {
    pub quest_id: u32,
    pub interval_id: u64,
    pub acceptance: u32,
}

/// The held list as a writing path reads it (`Store::get_held_list`): its entries, the player's
/// acceptance counter (slot 0), and the `kept` bit of each slot read. `Store::set_held_list`
/// compares a new list against it, to write only the slots that change.
#[derive(Drop, Copy)]
pub struct HeldList {
    pub entries: Span<QuestHeld>,
    pub counter: u32,
    pub kept: Span<bool>,
}

// Constants

/// The empty entry: quest id 0 is never valid.
pub const HELD_EMPTY: QuestHeld = QuestHeld { quest_id: 0, interval_id: 0, acceptance: 0 };

// Implementations

/// The list is a span of entries: `held.position(quest_id)`, `held.remove(position)`.
#[generate_trait]
pub impl HeldImpl of HeldTrait {
    /// The position of `quest_id` in the list, if any. `accept` keeps a quest at most once in a
    /// list.
    fn position(self: Span<QuestHeld>, quest_id: u32) -> Option<u32> {
        let mut held = self;
        let mut position = 0;
        while let Some(entry) = held.pop_front() {
            if *entry.quest_id == quest_id {
                return Some(position);
            }
            position += 1;
        }
        None
    }

    /// `entry` is in the list: the same quest, interval and acceptance.
    fn contains(self: Span<QuestHeld>, entry: QuestHeld) -> bool {
        let mut held = self;
        while let Some(other) = held.pop_front() {
            if *other == entry {
                return true;
            }
        }
        false
    }

    /// The list without the entry at `position`; the later entries move up one place, so the
    /// list stays contiguous and in the order of acceptance. A position outside the list removes
    /// nothing.
    fn remove(self: Span<QuestHeld>, position: u32) -> Span<QuestHeld> {
        let mut out = array![];
        let mut held = self;
        let mut index = 0;
        while let Some(entry) = held.pop_front() {
            if index != position {
                out.append(*entry);
            }
            index += 1;
        }
        out.span()
    }

    /// The entry at `index`, or the empty entry past the end.
    #[inline(always)]
    fn entry_at(self: Span<QuestHeld>, index: u32) -> QuestHeld {
        match self.get(index) {
            Option::Some(entry) => *entry.unbox(),
            Option::None => HELD_EMPTY,
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::testing::helpers::{eight_held, held, opaque, stamped};
    use crate::types::schedule::ScheduleAssert;
    use super::HeldTrait;

    #[test]
    #[available_gas(l2_gas: 40782)]
    fn held_position_finds_the_quest() {
        let list = array![held(5, 0), held(9, 3), held(2, 3)].span();
        assert!(HeldTrait::position(list, 5) == Some(0));
        assert!(HeldTrait::position(list, 2) == Some(2));
        assert!(HeldTrait::position(list, 7) == None);
        assert!(HeldTrait::position(array![].span(), 5) == None);
    }

    #[test]
    #[available_gas(l2_gas: 49739)]
    fn held_contains_needs_the_same_interval() {
        let list = array![held(5, 0), held(9, 3)].span();
        assert!(HeldTrait::contains(list, held(9, 3)));
        // the same quest accepted in another interval is not this entry
        assert!(!HeldTrait::contains(list, held(9, 4)));
        // nor the same quest and interval under another acceptance number
        assert!(!HeldTrait::contains(list, stamped(9, 3, 1)));
        assert!(!HeldTrait::contains(list, held(7, 0)));
        assert!(!HeldTrait::contains(array![].span(), held(5, 0)));
    }

    #[test]
    #[available_gas(l2_gas: 135629)]
    fn held_remove_keeps_the_order() {
        let list = array![held(1, 0), held(2, 0), held(3, 0), held(4, 0)].span();
        assert!(HeldTrait::remove(list, 0) == array![held(2, 0), held(3, 0), held(4, 0)].span());
        assert!(HeldTrait::remove(list, 1) == array![held(1, 0), held(3, 0), held(4, 0)].span());
        assert!(HeldTrait::remove(list, 3) == array![held(1, 0), held(2, 0), held(3, 0)].span());
        // outside the list: unchanged
        assert!(HeldTrait::remove(list, 4) == list);
        assert!(HeldTrait::remove(array![held(1, 0)].span(), 0) == array![].span());
    }

    // held list, at its capacity

    #[test]
    #[available_gas(l2_gas: 40499)]
    fn bench_held_position_absent() {
        assert!(HeldTrait::position(eight_held(), opaque(99)) == None);
    }

    #[test]
    #[available_gas(l2_gas: 43334)]
    fn bench_held_contains_absent() {
        assert!(!HeldTrait::contains(eight_held(), opaque(held(8, 31))));
    }

    #[test]
    #[available_gas(l2_gas: 48720)]
    fn bench_held_remove_first() {
        assert!(HeldTrait::remove(eight_held(), opaque(0)).len() == 7);
    }
}
