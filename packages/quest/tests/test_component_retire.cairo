//! `retire` (ARC-01 §3.5, amended by D-135): live dependents, lifecycle after retirement, held
//! entries made dead.

use quiver_quest::component::QuestComponent::{Event, QuestRetired};
use quiver_quest::constants::MAX_HELD;
use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::Mode;
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{held, one_off, task};
use super::setup::{
    PLAYER, abandon, accept, as_admin, as_owner, assert_error, claim, define, define_held,
    define_simple, deploy, report, retire, stop,
};

const T: u32 = 5;

/// Meaning changed by D-135: tasks have no pages; what retirement frees is the slot of the
/// players who hold the quest, at their next `accept`.
#[test]
#[available_gas(l2_gas: 15478271)]
fn quest_retire_frees_slot() {
    let q = deploy();
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() {
        define_held(q, id, one_off(), T, 1);
        id += 1;
    }
    define_simple(q, 9, one_off(), T, 1);
    let mut spy = spy_events();
    retire(q, 3);
    spy.assert_emitted(@array![(q.address, Event::QuestRetired(QuestRetired { quest_id: 3 }))]);
    assert!(spy.get_events().events.len() == 1);
    // The list is full of entries, one of them dead: 9 is accepted in the place of 3
    accept(q, PLAYER, 9);
    assert!(
        q.view.quest_held(PLAYER) == array![held(1, 0), held(2, 0), held(4, 0), held(9, 0)].span(),
    );
}

/// Meaning changed by D-135: the retired quest is held, and skipped when the walk reaches it.
#[test]
#[available_gas(l2_gas: 9045379)]
fn quest_retired_not_progressed() {
    let q = deploy();
    define_held(q, 1, one_off(), T, 5);
    define_held(q, 2, one_off(), T, 5);
    retire(q, 1);
    report(q, PLAYER, T, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 0);
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 13943587)]
fn quest_retired_completed_still_claimable() {
    let q = deploy();
    define_held(q, 1, one_off(), T, 1);
    report(q, PLAYER, T, 1, Mode::Storage);
    retire(q, 1);
    assert!(claim(q, PLAYER, 1, 0) == 0);
    assert!(q.view.quest_progress(PLAYER, 1, 0).claimed);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5062470)]
fn quest_retired_accept_reverts() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    retire(q, 1);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, 1), errors::RETIRED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5245821)]
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
#[available_gas(l2_gas: 5026403)]
fn quest_redefine_retired_reverts() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    retire(q, 1);
    as_admin(q);
    assert_error(
        q.safe.define(1, one_off(), array![task(T, 1)].span(), array![].span()),
        errors::ALREADY_DEFINED,
    );
    stop(q);
}

/// The held entry of a retired quest is inert, not removed: it is dead until the next accept.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 6243563)]
fn quest_retired_is_not_accepted() {
    let q = deploy();
    define_held(q, 1, one_off(), T, 5);
    retire(q, 1);
    assert!(!q.view.quest_is_accepted(PLAYER, 1));
    assert!(q.view.quest_held(PLAYER) == array![held(1, 0)].span());
    as_owner(q);
    assert_error(q.safe.abandon(PLAYER, 1), errors::RETIRED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 6813891)]
fn quest_retire_prerequisite_with_live_dependent_reverts() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    define(q, 2, one_off(), array![task(6, 1)].span(), array![1].span());
    as_admin(q);
    assert_error(q.safe.retire(1), errors::HAS_LIVE_DEPENDENTS);
    stop(q);
    let (definition, _, _) = q.view.quest_definition(1);
    assert!(definition.live_dependents == 1 && !definition.retired);
}

#[test]
#[available_gas(l2_gas: 7653440)]
fn quest_retire_dependent_then_prerequisite() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    define(q, 2, one_off(), array![task(6, 1)].span(), array![1].span());
    retire(q, 2);
    let (definition, _, _) = q.view.quest_definition(1);
    assert!(definition.live_dependents == 0);
    retire(q, 1);
    let (definition, _, _) = q.view.quest_definition(1);
    assert!(definition.retired);
}

/// A retired quest's definition stays readable, with `retired` set.
#[test]
#[available_gas(l2_gas: 4780209)]
fn quest_retired_definition_readable() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    retire(q, 1);
    let (definition, tasks, _) = q.view.quest_definition(1);
    assert!(definition.defined && definition.retired);
    assert!(tasks == array![task(T, 1)].span());
}

#[test]
#[available_gas(l2_gas: 5936291)]
fn quest_retire_abandon_before_is_kept() {
    let q = deploy();
    define_held(q, 1, one_off(), T, 5);
    abandon(q, PLAYER, 1);
    retire(q, 1);
    assert!(q.view.quest_held(PLAYER) == array![].span());
    assert!(!q.view.quest_is_accepted(PLAYER, 1));
}
