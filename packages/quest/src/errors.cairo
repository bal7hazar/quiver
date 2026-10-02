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
pub const TOO_MANY_ENTRIES: felt252 = 'Quest: too many entries';
pub const TOO_MANY_HELD: felt252 = 'Quest: too many held';
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

#[cfg(test)]
mod tests {
    use crate::errors;

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn quest_error_strings_are_the_accepted_ones() {
        assert!(errors::INVALID_ID == 'Quest: invalid id');
        assert!(errors::INVALID_TASKS == 'Quest: invalid tasks');
        assert!(errors::INVALID_WINDOW == 'Quest: invalid window');
        assert!(errors::INVALID_INTERVAL == 'Quest: invalid interval');
        assert!(errors::INVALID_CONDITION == 'Quest: invalid condition');
        assert!(errors::TOO_MANY_CONDITIONS == 'Quest: too many conditions');
        assert!(errors::ALREADY_DEFINED == 'Quest: already defined');
        assert!(errors::DOES_NOT_EXIST == 'Quest: does not exist');
        assert!(errors::RETIRED == 'Quest: retired');
        assert!(errors::HAS_LIVE_DEPENDENTS == 'Quest: has live dependents');
        assert!(errors::TOO_MANY_DEPENDENTS == 'Quest: too many dependents');
        assert!(errors::INVALID_TASK == 'Quest: invalid task');
        assert!(errors::TOO_MANY_ENTRIES == 'Quest: too many entries');
        assert!(errors::TOO_MANY_HELD == 'Quest: too many held');
        assert!(errors::NOT_ACTIVE == 'Quest: not active');
        assert!(errors::LOCKED == 'Quest: locked');
        assert!(errors::ALREADY_ACCEPTED == 'Quest: already accepted');
        assert!(errors::ALREADY_COMPLETED == 'Quest: already completed');
        assert!(errors::NOT_ACCEPTED == 'Quest: not accepted');
        assert!(errors::NOT_COMPLETED == 'Quest: not completed');
        assert!(errors::ALREADY_CLAIMED == 'Quest: already claimed');
        assert!(errors::NOT_REPORTER == 'Quest: not reporter');
        assert!(errors::NOT_ADMIN == 'Quest: not admin');
        assert!(errors::NOT_AUTHORIZED == 'Quest: not authorized');
    }
}
