//! Error strings of `quiver_achievement` (ARC-01 §3.11, amended by the decision of 2026-09-29).
//! They are API, like events: a change to one is announced in the changelog (COMMON §4). Each
//! model and type names the ones it raises in its own `errors` module, as these constants.

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

#[cfg(test)]
mod tests {
    #[test]
    #[available_gas(l2_gas: 14406)]
    fn achievement_error_strings_are_the_accepted_ones() {
        assert!(super::INVALID_ID == 'Achievement: invalid id');
        assert!(super::INVALID_TASKS == 'Achievement: invalid tasks');
        assert!(super::INVALID_WINDOW == 'Achievement: invalid window');
        assert!(super::ALREADY_DEFINED == 'Achievement: already defined');
        assert!(super::DOES_NOT_EXIST == 'Achievement: does not exist');
        assert!(super::RETIRED == 'Achievement: retired');
        assert!(super::INVALID_TASK == 'Achievement: invalid task');
        assert!(super::TOO_MANY_ENTRIES == 'Achievement: too many entries');
        assert!(super::NOT_REPORTER == 'Achievement: not reporter');
        assert!(super::NOT_ADMIN == 'Achievement: not admin');
    }
}
