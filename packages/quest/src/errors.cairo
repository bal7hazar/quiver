//! Error strings of `quiver_quest` (ARC-01 §3.5). They are API, like events: a change to one
//! is announced in the changelog (COMMON §4).

pub const INVALID_ID: felt252 = 'Quest: invalid id';
pub const INVALID_TASKS: felt252 = 'Quest: invalid tasks';
pub const INVALID_WINDOW: felt252 = 'Quest: invalid window';
pub const INVALID_INTERVAL: felt252 = 'Quest: invalid interval';
pub const INVALID_CONDITION: felt252 = 'Quest: invalid condition';
pub const TOO_MANY_CONDITIONS: felt252 = 'Quest: too many conditions';
pub const ALREADY_DEFINED: felt252 = 'Quest: already defined';
pub const DOES_NOT_EXIST: felt252 = 'Quest: does not exist';
pub const RETIRED: felt252 = 'Quest: retired';
pub const HAS_LIVE_DEPENDENTS: felt252 = 'Quest: has live dependents';
pub const TOO_MANY_DEPENDENTS: felt252 = 'Quest: too many dependents';
pub const INVALID_TASK: felt252 = 'Quest: invalid task';
pub const TASK_FULL: felt252 = 'Quest: task full';
pub const TOO_MANY_ENTRIES: felt252 = 'Quest: too many entries';
pub const NO_ACCEPT_STEP: felt252 = 'Quest: no accept step';
pub const NOT_ACTIVE: felt252 = 'Quest: not active';
pub const LOCKED: felt252 = 'Quest: locked';
pub const ALREADY_ACCEPTED: felt252 = 'Quest: already accepted';
pub const ALREADY_COMPLETED: felt252 = 'Quest: already completed';
pub const NOT_ACCEPTED: felt252 = 'Quest: not accepted';
pub const NOT_COMPLETED: felt252 = 'Quest: not completed';
pub const ALREADY_CLAIMED: felt252 = 'Quest: already claimed';
pub const NOT_REPORTER: felt252 = 'Quest: not reporter';
pub const NOT_ADMIN: felt252 = 'Quest: not admin';
pub const NOT_AUTHORIZED: felt252 = 'Quest: not authorized';
