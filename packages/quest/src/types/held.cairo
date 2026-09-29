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
