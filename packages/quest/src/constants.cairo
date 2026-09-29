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
