//! Deployment of the mock consumers and the actors of the component tests.

use quiver_achievement::interface::{
    IAchievementDispatcher, IAchievementDispatcherTrait, IAchievementSafeDispatcher,
    IAchievementViewDispatcher, IAchievementViewSafeDispatcher,
};
use quiver_achievement::types::batch::TaskProgress;
use quiver_achievement::types::task::AchievementTask;
use quiver_achievement::types::window::AchievementWindow;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use starknet::ContractAddress;
use super::helpers::{always, one};
use super::mocks::IMockConsumerDispatcher;

pub const PLAYER: felt252 = 'player';

pub fn admin() -> ContractAddress {
    'admin'.try_into().unwrap()
}

pub fn reporter() -> ContractAddress {
    'reporter'.try_into().unwrap()
}

pub fn stranger() -> ContractAddress {
    'stranger'.try_into().unwrap()
}

pub fn ephemeral() -> ContractAddress {
    'ephemeral'.try_into().unwrap()
}

/// `MockAchievement` with its actors: `admin()` is its admin, `reporter()` a registered reporter.
#[derive(Drop, Copy)]
pub struct Achievement {
    pub address: ContractAddress,
    pub achievement: IAchievementDispatcher,
    pub safe: IAchievementSafeDispatcher,
    pub view: IAchievementViewDispatcher,
    pub safe_view: IAchievementViewSafeDispatcher,
}

pub fn deploy() -> Achievement {
    let class = declare("MockAchievement").unwrap().contract_class();
    let (address, _) = class.deploy(@array![admin().into()]).unwrap();
    let a = Achievement {
        address,
        achievement: IAchievementDispatcher { contract_address: address },
        safe: IAchievementSafeDispatcher { contract_address: address },
        view: IAchievementViewDispatcher { contract_address: address },
        safe_view: IAchievementViewSafeDispatcher { contract_address: address },
    };
    as_admin(a);
    a.achievement.set_reporter(reporter(), true);
    stop(a);
    a
}

/// `MockConsumer`: `admin()` defines, `ephemeral()` submits results.
pub fn deploy_consumer() -> (ContractAddress, IMockConsumerDispatcher, IAchievementViewDispatcher) {
    let class = declare("MockConsumer").unwrap().contract_class();
    let (address, _) = class.deploy(@array![admin().into(), ephemeral().into()]).unwrap();
    (
        address,
        IMockConsumerDispatcher { contract_address: address },
        IAchievementViewDispatcher { contract_address: address },
    )
}

pub fn caller(a: Achievement, who: ContractAddress) {
    start_cheat_caller_address(a.address, who);
}

pub fn as_admin(a: Achievement) {
    caller(a, admin());
}

pub fn as_reporter(a: Achievement) {
    caller(a, reporter());
}

pub fn stop(a: Achievement) {
    stop_cheat_caller_address(a.address);
}

/// Defines an achievement as the admin.
pub fn define(
    a: Achievement,
    achievement_id: u32,
    window: AchievementWindow,
    tasks: Span<AchievementTask>,
    points: u16,
) {
    as_admin(a);
    a.achievement.define(achievement_id, window, tasks, points);
    stop(a);
}

/// An achievement of one task, always open, 10 points.
pub fn define_simple(a: Achievement, achievement_id: u32, task_id: u32, total: u32) {
    define(a, achievement_id, always(), one(task_id, total), 10);
}

pub fn retire(a: Achievement, achievement_id: u32) {
    as_admin(a);
    a.achievement.retire(achievement_id);
    stop(a);
}

/// `progress` as the reporter.
pub fn report(a: Achievement, player_id: felt252, task_id: u32, count: u32) {
    as_reporter(a);
    a.achievement.progress(player_id, task_id, count);
    stop(a);
}

/// `progress_many` as the reporter.
pub fn report_many(a: Achievement, player_id: felt252, entries: Span<TaskProgress>) {
    as_reporter(a);
    a.achievement.progress_many(player_id, entries);
    stop(a);
}

/// The panic data of a failed call starts with `error`.
pub fn assert_error<T, +Drop<T>>(result: Result<T, Array<felt252>>, error: felt252) {
    match result {
        Result::Ok(_) => panic!("expected {}, the call succeeded", error),
        Result::Err(data) => assert!(*data.at(0) == error, "expected {}, got {:?}", error, data),
    }
}
