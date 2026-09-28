//! Deployment of the mock consumers and the actors of the component tests.

use quiver_quest::interface::{
    IQuestDispatcher, IQuestDispatcherTrait, IQuestSafeDispatcher, IQuestViewDispatcher,
    IQuestViewSafeDispatcher,
};
use quiver_quest::logic::{Mode, QuestSchedule, QuestTask, TaskProgress};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, start_cheat_block_timestamp,
    start_cheat_caller_address, stop_cheat_caller_address,
};
use starknet::ContractAddress;
use super::helpers::{entry, task};
use super::mocks::{IMockConsumerDispatcher, IMockQuestDispatcher, IMockQuestDispatcherTrait};

pub const PLAYER: felt252 = 'player';
pub const OTHER_PLAYER: felt252 = 'other player';
pub const WEEK: u64 = 604800;
pub const DAY64: u64 = 86400;

pub fn admin() -> ContractAddress {
    'admin'.try_into().unwrap()
}

pub fn reporter() -> ContractAddress {
    'reporter'.try_into().unwrap()
}

pub fn owner() -> ContractAddress {
    'owner'.try_into().unwrap()
}

pub fn stranger() -> ContractAddress {
    'stranger'.try_into().unwrap()
}

pub fn ephemeral() -> ContractAddress {
    'ephemeral'.try_into().unwrap()
}

/// `MockQuest` with its actors: `admin()` is its admin, `reporter()` a registered reporter,
/// `owner()` the owner of `PLAYER` and `OTHER_PLAYER`.
#[derive(Drop, Copy)]
pub struct Quest {
    pub address: ContractAddress,
    pub quest: IQuestDispatcher,
    pub safe: IQuestSafeDispatcher,
    pub view: IQuestViewDispatcher,
    pub safe_view: IQuestViewSafeDispatcher,
    pub mock: IMockQuestDispatcher,
}

pub fn deploy() -> Quest {
    let class = declare("MockQuest").unwrap().contract_class();
    let (address, _) = class.deploy(@array![admin().into()]).unwrap();
    let quest = Quest {
        address,
        quest: IQuestDispatcher { contract_address: address },
        safe: IQuestSafeDispatcher { contract_address: address },
        view: IQuestViewDispatcher { contract_address: address },
        safe_view: IQuestViewSafeDispatcher { contract_address: address },
        mock: IMockQuestDispatcher { contract_address: address },
    };
    as_admin(quest);
    quest.quest.set_reporter(reporter(), true);
    quest.mock.set_owner(PLAYER, owner());
    quest.mock.set_owner(OTHER_PLAYER, owner());
    stop(quest);
    quest
}

/// `MockConsumer`: `admin()` defines, `ephemeral()` submits results.
pub fn deploy_consumer() -> (ContractAddress, IMockConsumerDispatcher, IQuestViewDispatcher) {
    let class = declare("MockConsumer").unwrap().contract_class();
    let (address, _) = class.deploy(@array![admin().into(), ephemeral().into()]).unwrap();
    (
        address,
        IMockConsumerDispatcher { contract_address: address },
        IQuestViewDispatcher { contract_address: address },
    )
}

pub fn caller(quest: Quest, who: ContractAddress) {
    start_cheat_caller_address(quest.address, who);
}

pub fn as_admin(quest: Quest) {
    caller(quest, admin());
}

pub fn as_reporter(quest: Quest) {
    caller(quest, reporter());
}

pub fn as_owner(quest: Quest) {
    caller(quest, owner());
}

pub fn stop(quest: Quest) {
    stop_cheat_caller_address(quest.address);
}

pub fn at(quest: Quest, time: u64) {
    start_cheat_block_timestamp(quest.address, time);
}

/// Defines a quest as the admin.
pub fn define(
    quest: Quest,
    quest_id: u32,
    schedule: QuestSchedule,
    tasks: Span<QuestTask>,
    conditions: Span<u32>,
    needs_accept: bool,
) {
    as_admin(quest);
    quest.quest.define(quest_id, schedule, tasks, conditions, needs_accept);
    stop(quest);
}

/// A quest of one task, no condition, no accept step.
pub fn define_simple(
    quest: Quest, quest_id: u32, schedule: QuestSchedule, task_id: u32, total: u32,
) {
    define(quest, quest_id, schedule, array![task(task_id, total)].span(), array![].span(), false);
}

pub fn retire(quest: Quest, quest_id: u32) {
    as_admin(quest);
    quest.quest.retire(quest_id);
    stop(quest);
}

/// `progress` as the reporter.
pub fn report(quest: Quest, player_id: felt252, task_id: u32, count: u32, mode: Mode) {
    as_reporter(quest);
    quest.quest.progress(player_id, task_id, count, mode);
    stop(quest);
}

/// `progress_many` as the reporter.
pub fn report_many(quest: Quest, player_id: felt252, entries: Span<TaskProgress>, mode: Mode) {
    as_reporter(quest);
    quest.quest.progress_many(player_id, entries, mode);
    stop(quest);
}

pub fn accept(quest: Quest, player_id: felt252, quest_id: u32) {
    as_owner(quest);
    quest.quest.accept(player_id, quest_id);
    stop(quest);
}

pub fn abandon(quest: Quest, player_id: felt252, quest_id: u32) {
    as_owner(quest);
    quest.quest.abandon(player_id, quest_id);
    stop(quest);
}

pub fn claim(quest: Quest, player_id: felt252, quest_id: u32, interval_id: u64) -> u64 {
    as_owner(quest);
    let index = quest.quest.claim(player_id, quest_id, interval_id);
    stop(quest);
    index
}

/// `[(task_id, count)]`.
pub fn one_entry(task_id: u32, count: u32) -> Span<TaskProgress> {
    array![entry(task_id, count)].span()
}

/// The panic data of a failed call starts with `error`.
pub fn assert_error<T, +Drop<T>>(result: Result<T, Array<felt252>>, error: felt252) {
    match result {
        Result::Ok(_) => panic!("expected {}, the call succeeded", error),
        Result::Err(data) => assert!(*data.at(0) == error, "expected {}, got {:?}", error, data),
    }
}
