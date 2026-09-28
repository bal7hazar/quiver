use quiver_quest::constants::{MAX_CONDITIONS, MAX_ENTRIES, MAX_PAGES, MAX_TASKS, QUESTS_PER_PAGE};

#[test]
#[available_gas(l2_gas: 14406)]
fn quest_bounds_are_the_accepted_ones() {
    assert!(MAX_TASKS == 3);
    assert!(MAX_CONDITIONS == 7);
    assert!(QUESTS_PER_PAGE == 7);
    assert!(MAX_PAGES == 4);
    assert!(MAX_ENTRIES == 16);
}
