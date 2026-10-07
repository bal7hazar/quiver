//! What needs a deployed contract (ARC-05a): the calls through a storage path of a consumer's
//! contract, no event after any kind of submit, a submit that does not place leaving the storage as
//! it was, a placing submit writing slots 1 and 2 only when they change, tournaments isolated, and
//! no read of the block timestamp.

use quiver_leaderboard::types::ranked::Ranked;
use quiver_leaderboard::types::top3::Top3;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, load, spy_events,
    start_cheat_block_timestamp_global,
};
use starknet::ContractAddress;
use super::mocks::{IMockConsumerDispatcher, IMockConsumerDispatcherTrait};

const T: u64 = 5;

fn deploy() -> (ContractAddress, IMockConsumerDispatcher) {
    let class = declare("MockConsumer").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    (address, IMockConsumerDispatcher { contract_address: address })
}

/// A 10, B 8, C 5 on tournament `T`.
fn full(board: IMockConsumerDispatcher) {
    board.submit(T, 'C', 5);
    board.submit(T, 'B', 8);
    board.submit(T, 'A', 10);
}

/// The four slots of a tournament, as `load` reads them: scores word, players 1, 2 and 3.
fn slots(address: ContractAddress, board: IMockConsumerDispatcher, t: u64) -> Array<felt252> {
    let mut out = array![];
    out.append(*load(address, board.scores_address(t), 1).at(0));
    for rank in 1..4_u8 {
        out.append(*load(address, board.player_address(t, rank), 1).at(0));
    }
    out
}

fn at(player_id: felt252, score: u32) -> Ranked {
    Ranked { player_id, score }
}

#[test]
#[available_gas(l2_gas: 2512272)]
fn the_calls_go_through_a_consumers_storage_path() {
    let (_, board) = deploy();
    assert_eq!(board.submit(T, 'A', 10), 1);
    assert_eq!(board.submit(T, 'B', 8), 2);
    assert_eq!(board.ranked(T, 2), at('B', 8));
    assert_eq!(board.top(T), Top3 { first: at('A', 10), second: at('B', 8), third: at(0, 0) });
}

#[test]
#[available_gas(l2_gas: 4692146)]
fn no_event_after_any_kind_of_submit() {
    let (_, board) = deploy();
    let mut spy = spy_events();
    full(board);
    board.submit(T, 'D', 12); // rank 1
    board.submit(T, 'D', 11); // rank 2
    board.submit(T, 'D', 9); // rank 3
    board.submit(T, 'D', 1); // not placed
    board.submit(T, 'D', 0); // score 0
    board.submit(T, 0, 99); // player 0
    assert_eq!(spy.get_events().events.len(), 0);
}

#[test]
#[available_gas(l2_gas: 4744719)]
fn a_submit_that_does_not_place_leaves_the_storage_unchanged() {
    let (address, board) = deploy();
    full(board);
    let before = slots(address, board, T);
    assert_eq!(board.submit(T, 'D', 1), 0); // below rank 3
    assert_eq!(board.submit(T, 'D', 5), 0); // equal to rank 3
    assert_eq!(board.submit(T, 'D', 0), 0); // score 0
    assert_eq!(board.submit(T, 0, 99), 0); // player 0
    assert_eq!(slots(address, board, T), before);
}

#[test]
#[available_gas(l2_gas: 3701471)]
fn the_slots_hold_the_ranks() {
    let (address, board) = deploy();
    full(board);
    // The scores word: 10 at [0, 32), 8 at [32, 64), 5 at [64, 96).
    assert_eq!(
        slots(address, board, T),
        array![10 + 8 * 0x100000000 + 5 * 0x10000000000000000, 'A', 'B', 'C'],
    );
}

#[test]
#[available_gas(l2_gas: 4522749)]
fn a_placing_submit_changes_only_the_slots_it_moves() {
    let (address, board) = deploy();
    full(board);
    let before = slots(address, board, T);
    assert_eq!(board.submit(T, 'D', 6), 3); // rank 3: the word and player 3 only
    let after = slots(address, board, T);
    assert!(*before.at(0) != *after.at(0));
    assert_eq!(*after.at(1), *before.at(1));
    assert_eq!(*after.at(2), *before.at(2));
    assert_eq!(*after.at(3), 'D');
}

/// Gas of the call, of a rank-1 submit shifting two ranks: when the players of ranks 1 and 2 are
/// the player submitting, slots 1 and 2 keep their value and are not written (two writes fewer).
/// Slot 3 is written all the same, with the same value: it is not read.
#[test]
#[available_gas(l2_gas: 7054152)]
fn slots_one_and_two_are_written_only_when_they_change() {
    let (_, distinct) = deploy();
    distinct.submit(T, 'C', 5);
    distinct.submit(T, 'B', 8);
    distinct.submit(T, 'A', 10);
    let (rank, gas_distinct) = distinct.submit_gas(T, 'D', 12);
    assert_eq!(rank, 1);

    let (_, same) = deploy();
    same.submit(T, 'D', 5);
    same.submit(T, 'D', 8);
    same.submit(T, 'D', 10);
    let (rank, gas_same) = same.submit_gas(T, 'D', 12);
    assert_eq!(rank, 1);
    // Slots 1 and 2 keep 'D': only the word and slot 3 are written (slot 3 is not read, so it is
    // always written). A write is at least 70 000.
    assert!(gas_distinct > gas_same + 140000, "distinct {}, same {}", gas_distinct, gas_same);
}

#[test]
#[available_gas(l2_gas: 10807734)]
fn the_gas_of_a_placing_submit_falls_with_the_rank() {
    let (_, one) = deploy();
    full(one);
    let (rank, rank1) = one.submit_gas(T, 'D', 12);
    assert_eq!(rank, 1);
    let (_, two) = deploy();
    full(two);
    let (rank, rank2) = two.submit_gas(T, 'D', 9);
    assert_eq!(rank, 2);
    let (_, three) = deploy();
    full(three);
    let (rank, rank3) = three.submit_gas(T, 'D', 6);
    assert_eq!(rank, 3);
    assert!(rank1 > rank2 && rank2 > rank3, "{} {} {}", rank1, rank2, rank3);
}

#[test]
#[available_gas(l2_gas: 7397702)]
fn tournaments_are_isolated() {
    let (address, board) = deploy();
    full(board);
    let before = slots(address, board, T);
    assert_eq!(board.submit(T + 1, 'Z', 99), 1);
    assert_eq!(board.submit(0, 'Y', 1), 1);
    assert_eq!(slots(address, board, T), before);
    assert_eq!(board.top(T + 1).first, at('Z', 99));
    assert_eq!(board.top(0).first, at('Y', 1));
    assert!(board.scores_address(T) != board.scores_address(T + 1));
    assert!(board.player_address(T, 1) != board.player_address(T + 1, 1));
}

#[test]
#[available_gas(l2_gas: 4782383)]
fn the_block_timestamp_changes_nothing() {
    let (_, early) = deploy();
    start_cheat_block_timestamp_global(1);
    early.submit(T, 'A', 4);
    early.submit(T, 'B', 4);
    let (_, late) = deploy();
    start_cheat_block_timestamp_global(1000000);
    late.submit(T, 'A', 4);
    late.submit(T, 'B', 4);
    assert_eq!(early.top(T), late.top(T));
}
