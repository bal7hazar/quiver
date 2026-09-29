use quiver_achievement::errors;

#[test]
#[available_gas(l2_gas: 14406)]
fn achievement_error_strings_are_the_accepted_ones() {
    assert!(errors::INVALID_ID == 'Achievement: invalid id');
    assert!(errors::INVALID_TASKS == 'Achievement: invalid tasks');
    assert!(errors::INVALID_WINDOW == 'Achievement: invalid window');
    assert!(errors::ALREADY_DEFINED == 'Achievement: already defined');
    assert!(errors::DOES_NOT_EXIST == 'Achievement: does not exist');
    assert!(errors::RETIRED == 'Achievement: retired');
    assert!(errors::INVALID_TASK == 'Achievement: invalid task');
    assert!(errors::TOO_MANY_ENTRIES == 'Achievement: too many entries');
    assert!(errors::NOT_REPORTER == 'Achievement: not reporter');
    assert!(errors::NOT_ADMIN == 'Achievement: not admin');
}
