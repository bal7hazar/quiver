//! Bounds of the API (ARC-01 §3.1, §3.2, amended by D-135). Every loop of the package is bounded
//! by one of them.

/// Tasks per quest.
pub const MAX_TASKS: u8 = 3;
/// Conditions (prerequisites) per quest.
pub const MAX_CONDITIONS: u8 = 7;
/// Entries (distinct tasks) per `progress_many` call.
pub const MAX_ENTRIES: u32 = 16;
/// Quests a player holds (accepted, not yet pruned) at once: `accept` refuses a new one when this
/// many are live. At most `MAX_HELD_LIMIT`.
pub const MAX_HELD: u8 = 4;
/// What the held list's layout can hold: `HELD_SLOTS` slots of 2 entries. The walk of the list
/// reads at most `HELD_SLOTS` slots whatever `MAX_HELD` is.
pub const MAX_HELD_LIMIT: u8 = 8;
/// Slots of a player's held list: `MAX_HELD_LIMIT / 2`.
pub const HELD_SLOTS: u8 = 4;
/// Interval ids a held entry can store: 48 bits (2^48 one-second intervals are about 8.9 million
/// years). `accept` refuses an interval at or above it as not active.
pub const HELD_INTERVAL_LIMIT: u64 = 0x1000000000000;
/// Acceptance numbers and the player's counter: 30 bits. The counter wraps to 0 after
/// `ACCEPTANCE_LIMIT - 1`, that is after about 1.07 × 10^9 acceptances by one player.
pub const ACCEPTANCE_LIMIT: u32 = 0x40000000;

#[cfg(test)]
mod tests {
    use super::{HELD_SLOTS, MAX_CONDITIONS, MAX_ENTRIES, MAX_HELD, MAX_HELD_LIMIT, MAX_TASKS};

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn quest_bounds_are_the_accepted_ones() {
        assert!(MAX_TASKS == 3);
        assert!(MAX_CONDITIONS == 7);
        assert!(MAX_ENTRIES == 16);
        // D-135: 4 held quests, at most 8, in slots of 2 entries
        assert!(MAX_HELD == 4);
        assert!(MAX_HELD <= MAX_HELD_LIMIT);
        assert!(MAX_HELD_LIMIT == 8);
        assert!(HELD_SLOTS * 2 == MAX_HELD_LIMIT);
    }
}
