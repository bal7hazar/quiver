use quiver_quest::errors;

#[test]
#[available_gas(l2_gas: 14406)]
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
    assert!(errors::TASK_FULL == 'Quest: task full');
    assert!(errors::TOO_MANY_ENTRIES == 'Quest: too many entries');
    assert!(errors::NO_ACCEPT_STEP == 'Quest: no accept step');
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
