//! `retire` (ARC-01 §3.5): pages kept contiguous, live dependents, lifecycle after retirement.

use quiver_quest::component::QuestComponent::{Event, QuestRetired};
use quiver_quest::constants::{MAX_PAGES, QUESTS_PER_PAGE};
use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::{Mode, QuestIdPage, page_span};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, load, map_entry_address, spy_events};
use starknet::storage_access::StorePacking;
use super::helpers::{one_off, task};
use super::setup::{
    PLAYER, Quest, abandon, accept, as_admin, as_owner, assert_error, claim, define, define_simple,
    deploy, report, retire, stop,
};

const T: u32 = 5;

/// Page `index` of `task_id`, read from the component's storage.
fn page_of(q: Quest, task_id: u32, index: u8) -> QuestIdPage {
    let address = map_entry_address(
        selector!("Quest_task_pages"), array![task_id.into(), index.into()].span(),
    );
    StorePacking::unpack(*load(q.address, address, 1)[0])
}

/// Every id on the pages of `task_id`, in order, checking that they are contiguous.
fn live_ids(q: Quest, task_id: u32) -> Array<u32> {
    let mut ids = array![];
    let mut index: u8 = 0;
    let mut open = false;
    while index < MAX_PAGES {
        let page = page_of(q, task_id, index);
        assert!(!open || page.len == 0, "pages are not contiguous");
        for id in page_span(@page) {
            ids.append(*id);
        }
        if page.len < QUESTS_PER_PAGE {
            open = true;
        }
        index += 1;
    }
    ids
}

fn contains(ids: @Array<u32>, id: u32) -> bool {
    for x in ids.span() {
        if *x == id {
            return true;
        }
    }
    false
}

/// `MAX_QUESTS_PER_TASK` one-off quests 1..=28 on `T`.
fn full_task() -> Quest {
    let q = deploy();
    let max: u32 = (QUESTS_PER_PAGE * MAX_PAGES).into();
    let mut id: u32 = 1;
    while id <= max {
        define_simple(q, id, one_off(), T, 1);
        id += 1;
    }
    q
}

#[test]
#[available_gas(l2_gas: 54128267)]
fn quest_retire_frees_slot() {
    let q = full_task();
    let mut spy = spy_events();
    retire(q, 3);
    spy.assert_emitted(@array![(q.address, Event::QuestRetired(QuestRetired { quest_id: 3 }))]);
    assert!(spy.get_events().events.len() == 1);
    define_simple(q, 29, one_off(), T, 1);
    let ids = live_ids(q, T);
    assert!(ids.len() == 28);
    assert!(!contains(@ids, 3));
    assert!(contains(@ids, 29));
    // The last id (28) filled the hole on page 0; 29 went to the last page
    assert!(page_of(q, T, 0).ids.q2 == 28);
    assert!(page_of(q, T, 3).ids.q6 == 29);
}

/// Every position of a full task: retiring any quest keeps the others, contiguous.
#[test]
#[available_gas(l2_gas: 61009347)]
fn quest_retire_keeps_pages_contiguous() {
    let q = full_task();
    // From the first page, the middle, the last id, then down to empty
    let order = array![1, 14, 28, 27, 7, 8, 21, 2];
    let mut retired = array![];
    for id in order.span() {
        retire(q, *id);
        retired.append(*id);
        let ids = live_ids(q, T);
        assert!(ids.len() == 28 - retired.len());
        for gone in retired.span() {
            assert!(!contains(@ids, *gone));
        }
    }
}

#[test]
#[available_gas(l2_gas: 5236119)]
fn quest_retire_last_quest_empties_page() {
    let q = deploy();
    define(q, 1, one_off(), array![task(T, 1), task(6, 1)].span(), array![].span(), false);
    retire(q, 1);
    assert!(page_of(q, T, 0).len == 0);
    assert!(page_of(q, 6, 0).len == 0);
}

#[test]
#[available_gas(l2_gas: 8257364)]
fn quest_retired_not_progressed() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 5);
    define_simple(q, 2, one_off(), T, 5);
    retire(q, 1);
    report(q, PLAYER, T, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 0);
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 13351765)]
fn quest_retired_completed_still_claimable() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    report(q, PLAYER, T, 1, Mode::Storage);
    retire(q, 1);
    assert!(claim(q, PLAYER, 1, 0) == 0);
    assert!(q.view.quest_progress(PLAYER, 1, 0).claimed);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5376819)]
fn quest_retired_accept_reverts() {
    let q = deploy();
    define(q, 1, one_off(), array![task(T, 1)].span(), array![].span(), true);
    retire(q, 1);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, 1), errors::RETIRED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5657411)]
fn quest_retire_twice_reverts() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    retire(q, 1);
    as_admin(q);
    assert_error(q.safe.retire(1), errors::RETIRED);
    assert_error(q.safe.retire(99), errors::DOES_NOT_EXIST);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5366067)]
fn quest_redefine_retired_reverts() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    retire(q, 1);
    as_admin(q);
    assert_error(
        q.safe.define(1, one_off(), array![task(T, 1)].span(), array![].span(), false),
        errors::ALREADY_DEFINED,
    );
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 6539652)]
fn quest_retired_is_not_accepted() {
    let q = deploy();
    define(q, 1, one_off(), array![task(T, 5)].span(), array![].span(), true);
    accept(q, PLAYER, 1);
    retire(q, 1);
    assert!(!q.view.quest_is_accepted(PLAYER, 1));
    // The record's bit is inert, not cleared
    assert!(q.view.quest_record(PLAYER, 1).active);
    as_owner(q);
    assert_error(q.safe.abandon(PLAYER, 1), errors::RETIRED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 7981334)]
fn quest_retire_prerequisite_with_live_dependent_reverts() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    define(q, 2, one_off(), array![task(6, 1)].span(), array![1].span(), false);
    as_admin(q);
    assert_error(q.safe.retire(1), errors::HAS_LIVE_DEPENDENTS);
    stop(q);
    let (definition, _, _) = q.view.quest_definition(1);
    assert!(definition.live_dependents == 1 && !definition.retired);
}

#[test]
#[available_gas(l2_gas: 8326847)]
fn quest_retire_dependent_then_prerequisite() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    define(q, 2, one_off(), array![task(6, 1)].span(), array![1].span(), false);
    retire(q, 2);
    let (definition, _, _) = q.view.quest_definition(1);
    assert!(definition.live_dependents == 0);
    retire(q, 1);
    let (definition, _, _) = q.view.quest_definition(1);
    assert!(definition.retired);
}

/// A retired quest's definition stays readable, with `retired` set.
#[test]
#[available_gas(l2_gas: 5115254)]
fn quest_retired_definition_readable() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    retire(q, 1);
    let (definition, tasks, _) = q.view.quest_definition(1);
    assert!(definition.defined && definition.retired);
    assert!(tasks == array![task(T, 1)].span());
}

#[test]
#[available_gas(l2_gas: 6008961)]
fn quest_retire_abandon_before_is_kept() {
    let q = deploy();
    define(q, 1, one_off(), array![task(T, 5)].span(), array![].span(), true);
    accept(q, PLAYER, 1);
    abandon(q, PLAYER, 1);
    retire(q, 1);
    assert!(!q.view.quest_record(PLAYER, 1).active);
}
