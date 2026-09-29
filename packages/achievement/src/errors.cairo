//! Error strings of `quiver_achievement` (ARC-01 §3.11, amended by the decision of 2026-09-29).
//! They are API, like events: a change to one is announced in the changelog (COMMON §4).

pub const INVALID_ID: felt252 = 'Achievement: invalid id';
pub const INVALID_TASKS: felt252 = 'Achievement: invalid tasks';
pub const INVALID_WINDOW: felt252 = 'Achievement: invalid window';
pub const ALREADY_DEFINED: felt252 = 'Achievement: already defined';
pub const DOES_NOT_EXIST: felt252 = 'Achievement: does not exist';
pub const RETIRED: felt252 = 'Achievement: retired';
pub const INVALID_TASK: felt252 = 'Achievement: invalid task';
pub const TOO_MANY_ENTRIES: felt252 = 'Achievement: too many entries';
pub const NOT_REPORTER: felt252 = 'Achievement: not reporter';
pub const NOT_ADMIN: felt252 = 'Achievement: not admin';
