//! The external ABI of `quiver_achievement` (ARC-01 §3.11, amended by the decision of
//! 2026-09-29). Both interfaces are optional: a consumer embeds
//! `AchievementComponent::AchievementImpl`, `AchievementComponent::AchievementViewImpl`, both, or
//! neither.
//!
//! **Event mode only**: progress takes no mode, and no entrypoint stores, completes or claims
//! anything for a player. A storage mode is not refused at run time: it does not exist.

use starknet::ContractAddress;
use crate::models::definition::HeadSlot;
use crate::types::batch::TaskProgress;
use crate::types::task::AchievementTask;
use crate::types::window::AchievementWindow;

/// The access-checked entrypoints: `define`, `retire` and `set_reporter` need
/// `authorize_admin(caller)`; `progress` and `progress_many` a registered reporter.
#[starknet::interface]
pub trait IAchievement<TState> {
    fn define(
        ref self: TState,
        achievement_id: u32,
        window: AchievementWindow,
        tasks: Span<AchievementTask>,
        points: u16,
    );
    fn retire(ref self: TState, achievement_id: u32);
    fn set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    fn progress(ref self: TState, player_id: felt252, task_id: u32, count: u32);
    fn progress_many(ref self: TState, player_id: felt252, entries: Span<TaskProgress>);
}

/// The views. None writes.
#[starknet::interface]
pub trait IAchievementView<TState> {
    /// Slot A (with `retired` and, since 0.2.0, `points`) and the tasks. Panics `'Achievement:
    /// does not exist'`.
    fn achievement_definition(
        self: @TState, achievement_id: u32,
    ) -> (HeadSlot, Span<AchievementTask>);
    fn achievement_is_reporter(self: @TState, reporter: ContractAddress) -> bool;
}
