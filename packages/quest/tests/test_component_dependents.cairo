//! The ceiling of `live_dependents`, 65 535 (fix loop 1, point 3). The prerequisite's A slot is
//! seeded at 65 534 with snforge's `store`, as no test could define that many quests.

use quiver_quest::errors;
use quiver_quest::interface::{
    IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait, IQuestViewSafeDispatcherTrait,
};
use quiver_quest::logic::QuestTask;
use snforge_std::{map_entry_address, store};
use starknet::storage_access::StorePacking;
use super::helpers::{one_off, task};
use super::setup::{Quest, as_admin, assert_error, define, define_simple, deploy, retire, stop};

const P: u32 = 1;
const X: u32 = 2;
const B: u32 = 3;
const C: u32 = 4;
const TASK_C: u32 = 8;

fn live_dependents(q: Quest, quest_id: u32) -> u16 {
    let (definition, _, _) = q.view.quest_definition(quest_id);
    definition.live_dependents
}

/// Writes `live_dependents` into the stored A slot of `quest_id`.
fn seed_live_dependents(q: Quest, quest_id: u32, value: u16) {
    let (mut definition, _, _) = q.view.quest_definition(quest_id);
    definition.live_dependents = value;
    let address = map_entry_address(selector!("Quest_definitions"), array![quest_id.into()].span());
    store(q.address, address, array![StorePacking::pack(definition)].span());
}

fn one(task_id: u32) -> Span<QuestTask> {
    array![task(task_id, 1)].span()
}

/// P at 65 534 live dependents, X at 0.
fn seeded() -> Quest {
    let q = deploy();
    define_simple(q, P, one_off(), 5, 1);
    define_simple(q, X, one_off(), 6, 1);
    seed_live_dependents(q, P, 0xfffe);
    assert!(live_dependents(q, P) == 0xfffe);
    q
}

#[test]
#[available_gas(l2_gas: 8326227)]
fn quest_define_reaches_max_dependents() {
    let q = seeded();
    define(q, B, one_off(), one(7), array![P].span());
    assert!(live_dependents(q, P) == 0xffff);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 9480051)]
fn quest_define_rejects_too_many_dependents() {
    let q = seeded();
    define(q, B, one_off(), one(7), array![P].span());
    // X comes first, so its counter would be written before P's refusal
    as_admin(q);
    assert_error(
        q.safe.define(C, one_off(), one(TASK_C), array![X, P].span()), errors::TOO_MANY_DEPENDENTS,
    );
    stop(q);
    // Nothing of C was kept
    assert!(live_dependents(q, P) == 0xffff);
    assert!(live_dependents(q, X) == 0);
    assert_error(q.safe_view.quest_definition(C), errors::DOES_NOT_EXIST);
}

#[test]
#[available_gas(l2_gas: 11850857)]
fn quest_retire_dependent_frees_max_dependents() {
    let q = seeded();
    define(q, B, one_off(), one(7), array![P].span());
    retire(q, B);
    assert!(live_dependents(q, P) == 0xfffe);
    define(q, C, one_off(), one(TASK_C), array![X, P].span());
    assert!(live_dependents(q, P) == 0xffff);
    assert!(live_dependents(q, X) == 1);
    let (definition, _, _) = q.view.quest_definition(C);
    assert!(definition.defined);
}
