//! The achievement definition (D-143, ARC-07b): the model's constructor and behaviour, its checks,
//! its errors, its storage (the slots A and B of 0.1.0, with `points` now stored in A) and its
//! tracking.

// Internal imports

use starknet::storage_access::StorePacking;
use crate::constants::MAX_TASKS;
use crate::events::defined::{AchievementDefined, DefinedTrait};
use crate::helpers::bits::errors::{PACKING_FIELD_OUT_OF_RANGE, PACKING_RESERVED_BITS_SET};
use crate::helpers::bits::{
    BitsTrait, NZ_2, NZ_2_32, NZ_2_64, NZ_4, TWO_POW_128, TWO_POW_130, TWO_POW_131, TWO_POW_132,
    TWO_POW_164, TWO_POW_196, TWO_POW_32, TWO_POW_64, TWO_POW_96,
};
pub use crate::models::index::AchievementDefinition;
use crate::store::Tracked;
use crate::types::task::{AchievementTask, TaskAssert};
use crate::types::window::{AchievementWindow, WindowAssert, WindowTrait};

// Slots

/// Slot A, key `achievement_id`: the definition's window, its first task and its points, and the
/// achievement's status (`crate::models::status`), which shares it. Layout (bits from 0): `start`
/// [0, 64) · `end` [64, 128) · `task_count` [128, 130) · `defined` [130] · `retired` [131] ·
/// `t0.task_id` [132, 164) · `t0.total` [164, 196) · `points` [196, 212). Bits [212, 252) are
/// reserved. 0.1.0's `quiver_achievement::logic::AchievementDefinition`, renamed, with `points`
/// (0.1.0 emitted it only).
///
/// The first task is inline, so a single-task achievement (every tier of a title) is one slot.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct HeadSlot {
    pub window: AchievementWindow,
    /// 1..=MAX_TASKS.
    pub task_count: u8,
    /// Presence bit: true once `define` wrote the slot. An empty slot reads false.
    pub defined: bool,
    /// Set by `retire`.
    pub retired: bool,
    pub t0: AchievementTask,
    pub points: u16,
}

/// Slot B, key `achievement_id`, written only when `task_count > 1`; unused entries are zero.
/// Layout: `t1.task_id` [0, 32) · `t1.total` [32, 64) · `t2.task_id` [64, 96) · `t2.total`
/// [96, 128). Bits [128, 252) are reserved. 0.1.0's `AchievementExtraTasks`, renamed.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct TasksSlot {
    pub t1: AchievementTask,
    pub t2: AchievementTask,
}

// Constants

const NO_TASK: AchievementTask = AchievementTask { task_id: 0, total: 0 };
/// Slot B of an achievement of one task, never written.
pub const NO_TASKS: TasksSlot = TasksSlot { t1: NO_TASK, t2: NO_TASK };

// Errors

/// The strings of 0.1.0 (`crate::errors`), which are API. The window's and a task's own are in
/// `crate::types::window` and `crate::types::task`.
pub mod errors {
    pub const DEFINITION_INVALID_ID: felt252 = crate::errors::INVALID_ID;
    pub const DEFINITION_INVALID_TASKS: felt252 = crate::errors::INVALID_TASKS;
}

// Implementations

#[generate_trait]
pub impl DefinitionImpl of DefinitionTrait {
    /// A valid definition, or panics, in this order: `'Achievement: invalid id'` (`id == 0`);
    /// `'Achievement: invalid window'`; `'Achievement: invalid tasks'` (none, more than
    /// `MAX_TASKS`, a task id 0, a total 0, a task id repeated). The same checks whatever the use
    /// of the achievement (D-11).
    #[inline]
    fn new(
        id: u32, window: AchievementWindow, tasks: Span<AchievementTask>, points: u16,
    ) -> AchievementDefinition {
        // [Check] Inputs
        DefinitionAssert::assert_valid_id(id);
        DefinitionAssert::assert_valid_window(window);
        DefinitionAssert::assert_valid_tasks(tasks);
        // [Return] AchievementDefinition
        AchievementDefinition { id, window, tasks, points }
    }

    /// Whether the achievement counts at `time`: its window's (`WindowTrait::is_active`), the rule
    /// an indexer applies.
    #[inline]
    fn is_active(self: @AchievementDefinition, time: u64) -> bool {
        self.window.is_active(time)
    }
}

/// Tracked (D-143): the indexer reads `AchievementDefined`, which `Store::set_definition` emits on
/// every write when the consumer tracks the definition (`AchievementTracking::DEFINITION`). Being
/// tracked is this impl: known at compile time.
pub impl DefinitionTracked of Tracked<AchievementDefinition> {
    type Event = AchievementDefined;

    #[inline]
    fn event(self: @AchievementDefinition) -> AchievementDefined {
        DefinedTrait::new(self)
    }
}

/// Storage: the slots A and B; each is one felt (`HeadPacking`, `TasksPacking`). A also holds the
/// achievement's status (`defined`, `retired`), which is not part of this model: a definition
/// written is a new one, with the status of a new achievement.
#[generate_trait]
pub impl DefinitionStorage of DefinitionStorageTrait {
    /// A (defined, not retired) and B; unused entries of B are zero. B is written only for 2 or 3
    /// tasks.
    #[inline]
    fn into_slots(self: @AchievementDefinition) -> (HeadSlot, TasksSlot) {
        let tasks = *self.tasks;
        let len = tasks.len();
        let slot_a = HeadSlot {
            window: *self.window,
            task_count: len.try_into().unwrap(),
            defined: true,
            retired: false,
            t0: *tasks[0],
            points: *self.points,
        };
        if len == 1 {
            return (slot_a, NO_TASKS);
        }
        let t1 = *tasks[1];
        if len == 2 {
            return (slot_a, TasksSlot { t1, t2: NO_TASK });
        }
        (slot_a, TasksSlot { t1, t2: *tasks[2] })
    }

    /// The definition of `id` from its slots: the first `task_count` tasks. An achievement not
    /// defined (A zero) has no task.
    #[inline]
    fn from_slots(id: u32, slot_a: HeadSlot, slot_b: TasksSlot) -> AchievementDefinition {
        AchievementDefinition {
            id, window: slot_a.window, tasks: slot_a.tasks(@slot_b), points: slot_a.points,
        }
    }
}

#[generate_trait]
pub impl DefinitionAssert of AssertTrait {
    #[inline(always)]
    fn assert_valid_id(id: u32) {
        assert(id != 0, errors::DEFINITION_INVALID_ID);
    }

    /// `WindowAssert::assert_valid`: `end == 0 || end > start`.
    #[inline(always)]
    fn assert_valid_window(window: AchievementWindow) {
        window.assert_valid();
    }

    /// 1 to `MAX_TASKS` (3), unrolled: ids distinct and non-zero, totals non-zero.
    #[inline(always)]
    fn assert_valid_tasks(tasks: Span<AchievementTask>) {
        let len = tasks.len();
        assert(len != 0 && len <= MAX_TASKS.into(), errors::DEFINITION_INVALID_TASKS);
        let t0 = *tasks[0];
        t0.assert_valid();
        if len == 1 {
            return;
        }
        let t1 = *tasks[1];
        t1.assert_valid();
        assert(t1.task_id != t0.task_id, errors::DEFINITION_INVALID_TASKS);
        if len == 2 {
            return;
        }
        let t2 = *tasks[2];
        t2.assert_valid();
        assert(
            t2.task_id != t0.task_id && t2.task_id != t1.task_id, errors::DEFINITION_INVALID_TASKS,
        );
    }
}

/// Slot A's tasks, for the paths that read the slots (`Store::get_definition`, the view).
#[generate_trait]
pub impl HeadSlotImpl of HeadSlotTrait {
    /// The first `task_count` tasks (at most 3): `t0` from A, then `t1` and `t2` from B.
    fn tasks(self: @HeadSlot, slot_b: @TasksSlot) -> Span<AchievementTask> {
        let task_count = *self.task_count;
        let mut out = array![];
        if task_count > 0 {
            out.append(*self.t0);
            if task_count > 1 {
                out.append(*slot_b.t1);
                if task_count > 2 {
                    out.append(*slot_b.t2);
                }
            }
        }
        out.span()
    }
}

// Packing. Every field is put at its offset by a multiplication on felts and read back by a
// division with remainder on a `u128` limb; no field straddles bit 128.
//
// A field narrower than its Cairo type (`task_count`) is checked against its bound before
// packing, so that it never spills into its neighbour. Unpacking rejects a felt with a bit set
// outside the encoding: a stored felt the package did not write is a corruption
// (`crate::helpers::bits::errors`). Neither panic is an error of the API: the component never
// packs or reads such a value.

pub impl HeadPacking of StorePacking<HeadSlot, felt252> {
    fn pack(value: HeadSlot) -> felt252 {
        assert(value.task_count <= MAX_TASKS, PACKING_FIELD_OUT_OF_RANGE);
        value.window.start.into()
            + value.window.end.into() * TWO_POW_64
            + value.task_count.into() * TWO_POW_128
            + value.defined.into() * TWO_POW_130
            + value.retired.into() * TWO_POW_131
            + value.t0.task_id.into() * TWO_POW_132
            + value.t0.total.into() * TWO_POW_164
            + value.points.into() * TWO_POW_196
    }

    fn unpack(value: felt252) -> HeadSlot {
        let (low, high) = BitsTrait::split(value);
        let (end, start) = DivRem::div_rem(low, NZ_2_64);
        let (high, task_count) = DivRem::div_rem(high, NZ_4);
        let (high, defined) = DivRem::div_rem(high, NZ_2);
        let (high, retired) = DivRem::div_rem(high, NZ_2);
        let (high, task_id) = DivRem::div_rem(high, NZ_2_32);
        let (points, total) = DivRem::div_rem(high, NZ_2_32);
        HeadSlot {
            window: AchievementWindow {
                start: start.try_into().unwrap(), end: end.try_into().unwrap(),
            },
            task_count: task_count.try_into().unwrap(),
            defined: defined != 0,
            retired: retired != 0,
            t0: AchievementTask {
                task_id: task_id.try_into().unwrap(), total: total.try_into().unwrap(),
            },
            // bits [196, 212); anything above is reserved
            points: points.try_into().expect(PACKING_RESERVED_BITS_SET),
        }
    }
}

pub impl TasksPacking of StorePacking<TasksSlot, felt252> {
    fn pack(value: TasksSlot) -> felt252 {
        value.t1.task_id.into()
            + value.t1.total.into() * TWO_POW_32
            + value.t2.task_id.into() * TWO_POW_64
            + value.t2.total.into() * TWO_POW_96
    }

    fn unpack(value: felt252) -> TasksSlot {
        // 128 bits: one limb, no split; a felt of 128 bits or more is rejected here
        let low: u128 = value.try_into().expect(PACKING_RESERVED_BITS_SET);
        let (low, id1) = DivRem::div_rem(low, NZ_2_32);
        let (low, total1) = DivRem::div_rem(low, NZ_2_32);
        let (total2, id2) = DivRem::div_rem(low, NZ_2_32);
        TasksSlot {
            t1: AchievementTask {
                task_id: id1.try_into().unwrap(), total: total1.try_into().unwrap(),
            },
            t2: AchievementTask {
                task_id: id2.try_into().unwrap(), total: total2.try_into().unwrap(),
            },
        }
    }
}

/// The constructor and its checks (D-11: the same validation for every use), the slots and their
/// packing against a plain oracle, and the benchmarks of the constructor and of the packing.
///
/// The oracle uses `u256` on purpose: it is the plain, obviously correct version the arithmetic
/// packing is tested against (docs/CAIRO.md §2). It never runs in the library.
#[cfg(test)]
mod tests {
    use core::num::traits::Pow;
    use starknet::storage_access::StorePacking;
    use crate::types::task::AchievementTask;
    use crate::types::window::AchievementWindow;
    use super::{DefinitionStorage, DefinitionTrait, HeadSlot, HeadSlotTrait, NO_TASKS, TasksSlot};

    const U32_MAX: u32 = 0xffffffff;
    const U64_MAX: u64 = 0xffffffffffffffff;
    const U16_MAX: u16 = 0xffff;

    fn window(start: u64, end: u64) -> AchievementWindow {
        AchievementWindow { start, end }
    }

    fn always() -> AchievementWindow {
        window(0, 0)
    }

    fn task(task_id: u32, total: u32) -> AchievementTask {
        AchievementTask { task_id, total }
    }

    fn one(task_id: u32, total: u32) -> Span<AchievementTask> {
        array![task(task_id, total)].span()
    }

    /// 0.1.0's `definition_new`: the constructor, then the slots it writes.
    fn definition_new(
        id: u32, window: AchievementWindow, tasks: Span<AchievementTask>,
    ) -> (HeadSlot, TasksSlot) {
        DefinitionTrait::new(id, window, tasks, 0).into_slots()
    }

    // The constructor and the slots

    #[test]
    #[available_gas(l2_gas: 24003)]
    fn definition_new_one_task_inline() {
        let (definition, extra) = definition_new(5, window(100, 200), one(7, 10));
        assert!(
            definition == HeadSlot {
                window: window(100, 200),
                task_count: 1,
                defined: true,
                retired: false,
                t0: task(7, 10),
                points: 0,
            },
        );
        assert!(extra == TasksSlot { t1: task(0, 0), t2: task(0, 0) });
    }

    #[test]
    #[available_gas(l2_gas: 40562)]
    fn definition_new_three_tasks() {
        let tasks = array![task(1, 5), task(2, 6), task(3, 7)].span();
        let (definition, extra) = definition_new(5, always(), tasks);
        assert!(definition.task_count == 3);
        assert!(definition.t0 == task(1, 5));
        assert!(extra == TasksSlot { t1: task(2, 6), t2: task(3, 7) });
        assert!(definition.tasks(@extra) == tasks);
    }

    #[test]
    #[available_gas(l2_gas: 45623)]
    fn tasks_span_has_task_count_entries() {
        let (d1, e1) = definition_new(1, always(), one(4, 1));
        assert!(d1.tasks(@e1) == one(4, 1));
        let two = array![task(4, 1), task(9, 2)].span();
        let (d2, e2) = definition_new(1, always(), two);
        assert!(d2.tasks(@e2) == two);
    }

    /// The model's window decides: `start <= time` and (`end == 0` or `time < end`) (fix loop 1).
    #[test]
    #[available_gas(l2_gas: 26922)]
    fn definition_is_active_inside_and_outside_its_window() {
        let definition = DefinitionTrait::new(5, window(100, 200), one(7, 10), 25);
        assert!(!definition.is_active(99));
        assert!(definition.is_active(100));
        assert!(definition.is_active(199));
        assert!(!definition.is_active(200));
        let open = DefinitionTrait::new(6, window(100, 0), one(7, 10), 0);
        assert!(!open.is_active(99));
        assert!(open.is_active(0xffffffffffffffff));
    }

    /// `points` is the model's and A's (ARC-07b); the model comes back from its slots.
    #[test]
    #[available_gas(l2_gas: 55115)]
    fn definition_points_stored_and_read_back() {
        let tasks = array![task(1, 5), task(2, 6)].span();
        let definition = DefinitionTrait::new(9, window(3, 4), tasks, U16_MAX);
        let (slot_a, slot_b) = definition.into_slots();
        assert!(slot_a.points == U16_MAX);
        assert!(DefinitionStorage::from_slots(9, slot_a, slot_b) == definition);
        // Not defined: no task
        let empty: HeadSlot = StorePacking::unpack(0);
        let none = DefinitionStorage::from_slots(9, empty, NO_TASKS);
        assert!(none.tasks.len() == 0 && none.points == 0);
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid id')]
    #[available_gas(l2_gas: 16296)]
    fn achievement_define_rejects_id_zero() {
        definition_new(0, always(), one(7, 1));
    }

    /// D-11: `end == start` is empty, refused.
    #[test]
    #[should_panic(expected: 'Achievement: invalid window')]
    #[available_gas(l2_gas: 16296)]
    fn definition_new_rejects_empty_window() {
        definition_new(5, window(100, 100), one(7, 1));
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid window')]
    #[available_gas(l2_gas: 16296)]
    fn definition_new_rejects_end_before_start() {
        definition_new(5, window(100, 99), one(7, 1));
    }

    /// The id is checked before the window, the window before the tasks.
    #[test]
    #[should_panic(expected: 'Achievement: invalid id')]
    #[available_gas(l2_gas: 16296)]
    fn definition_new_checks_id_first() {
        definition_new(0, window(100, 100), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid window')]
    #[available_gas(l2_gas: 16296)]
    fn definition_new_checks_window_before_tasks() {
        definition_new(5, window(100, 100), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid tasks')]
    #[available_gas(l2_gas: 16296)]
    fn definition_new_rejects_no_task() {
        definition_new(5, always(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid tasks')]
    #[available_gas(l2_gas: 16296)]
    fn definition_new_rejects_four_tasks() {
        definition_new(5, always(), array![task(1, 1), task(2, 1), task(3, 1), task(4, 1)].span());
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid tasks')]
    #[available_gas(l2_gas: 17241)]
    fn definition_new_rejects_task_id_zero() {
        definition_new(5, always(), array![task(1, 1), task(0, 1)].span());
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid tasks')]
    #[available_gas(l2_gas: 18396)]
    fn definition_new_rejects_total_zero() {
        definition_new(5, always(), array![task(1, 1), task(2, 1), task(3, 0)].span());
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid tasks')]
    #[available_gas(l2_gas: 21126)]
    fn definition_new_rejects_repeated_task() {
        definition_new(5, always(), array![task(1, 1), task(2, 1), task(1, 2)].span());
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid tasks')]
    #[available_gas(l2_gas: 19971)]
    fn definition_new_rejects_repeated_second_task() {
        definition_new(5, always(), array![task(2, 1), task(2, 3)].span());
    }

    // Packing: every slot of §3.11, round trip at zero, at every field's maximum and on mixed
    // values; the same felt as the oracle; the presence bits and `points` at their positions;
    // field widths checked and reserved bits rejected; an empty slot reads as undefined.

    fn pow2(n: u32) -> u256 {
        Pow::pow(2_u256, n.into())
    }

    /// Puts `value` in bits [offset, offset + width) of `acc`; the value must fit its width.
    fn put(ref acc: u256, value: u256, offset: u32, width: u32) {
        assert!(value < pow2(width), "field wider than its range");
        acc = acc + value * pow2(offset);
    }

    fn bit(flag: bool) -> u256 {
        if flag {
            1
        } else {
            0
        }
    }

    fn to_felt(value: u256) -> felt252 {
        assert!(value < pow2(251), "packed value not below 2^251");
        value.try_into().unwrap()
    }

    fn oracle_head(d: HeadSlot) -> felt252 {
        let mut acc: u256 = 0;
        put(ref acc, d.window.start.into(), 0, 64);
        put(ref acc, d.window.end.into(), 64, 64);
        put(ref acc, d.task_count.into(), 128, 2);
        put(ref acc, bit(d.defined), 130, 1);
        put(ref acc, bit(d.retired), 131, 1);
        put(ref acc, d.t0.task_id.into(), 132, 32);
        put(ref acc, d.t0.total.into(), 164, 32);
        put(ref acc, d.points.into(), 196, 16);
        to_felt(acc)
    }

    fn oracle_tasks(e: TasksSlot) -> felt252 {
        let mut acc: u256 = 0;
        put(ref acc, e.t1.task_id.into(), 0, 32);
        put(ref acc, e.t1.total.into(), 32, 32);
        put(ref acc, e.t2.task_id.into(), 64, 32);
        put(ref acc, e.t2.total.into(), 96, 32);
        to_felt(acc)
    }

    fn head(
        start: u64,
        end: u64,
        task_count: u8,
        defined: bool,
        retired: bool,
        id: u32,
        total: u32,
        points: u16,
    ) -> HeadSlot {
        HeadSlot {
            window: window(start, end), task_count, defined, retired, t0: task(id, total), points,
        }
    }

    fn round_trip_head(d: HeadSlot) {
        let packed = StorePacking::pack(d);
        assert!(packed == oracle_head(d));
        let back: HeadSlot = StorePacking::unpack(packed);
        assert!(back == d);
    }

    fn round_trip_tasks(e: TasksSlot) {
        let packed = StorePacking::pack(e);
        assert!(packed == oracle_tasks(e));
        let back: TasksSlot = StorePacking::unpack(packed);
        assert!(back == e);
    }

    // gas: raised, the `u256` oracle packs `points` too (ARC-07b); the packing itself is
    // `bench_pack_unpack_definition`
    #[test]
    #[available_gas(l2_gas: 9068105)]
    fn achievement_packing_round_trip_definition() {
        round_trip_head(head(0, 0, 0, false, false, 0, 0, 0));
        round_trip_head(head(U64_MAX, U64_MAX, 3, true, true, U32_MAX, U32_MAX, U16_MAX));
        round_trip_head(head(100, 200, 1, true, false, 7, 10, 25));
        round_trip_head(head(0, 0, 2, false, true, 1, U32_MAX, 0));
        round_trip_head(head(U64_MAX, 0, 3, true, false, U32_MAX, 1, 1));
    }

    #[test]
    #[available_gas(l2_gas: 3796905)]
    fn achievement_packing_round_trip_extra_tasks() {
        round_trip_tasks(TasksSlot { t1: task(0, 0), t2: task(0, 0) });
        round_trip_tasks(TasksSlot { t1: task(U32_MAX, U32_MAX), t2: task(U32_MAX, U32_MAX) });
        round_trip_tasks(TasksSlot { t1: task(8, 5), t2: task(0, 0) });
        round_trip_tasks(TasksSlot { t1: task(1, 2), t2: task(3, 4) });
    }

    /// `defined` is bit 130 and `retired` bit 131, alone.
    #[test]
    #[available_gas(l2_gas: 735956)]
    fn achievement_packing_presence_bits_at_their_positions() {
        let defined: felt252 = StorePacking::pack(head(0, 0, 0, true, false, 0, 0, 0));
        assert!(defined == to_felt(pow2(130)));
        let retired: felt252 = StorePacking::pack(head(0, 0, 0, false, true, 0, 0, 0));
        assert!(retired == to_felt(pow2(131)));
    }

    /// `points` is bits [196, 212), alone (ARC-07b).
    #[test]
    #[available_gas(l2_gas: 916808)]
    fn achievement_packing_points_at_their_position() {
        let one_point: felt252 = StorePacking::pack(head(0, 0, 0, false, false, 0, 0, 1));
        assert!(one_point == to_felt(pow2(196)));
        let all: felt252 = StorePacking::pack(head(0, 0, 0, false, false, 0, 0, U16_MAX));
        assert!(all == to_felt(pow2(212) - pow2(196)));
    }

    /// The widest value of each slot stays below 2^212 (A) and 2^128 (B).
    #[test]
    #[available_gas(l2_gas: 719019)]
    fn achievement_packing_widths() {
        let a: felt252 = StorePacking::pack(
            head(U64_MAX, U64_MAX, 3, true, true, U32_MAX, U32_MAX, U16_MAX),
        );
        assert!(a == to_felt(pow2(212) - 1));
        let b: felt252 = StorePacking::pack(
            TasksSlot { t1: task(U32_MAX, U32_MAX), t2: task(U32_MAX, U32_MAX) },
        );
        assert!(b == to_felt(pow2(128) - 1));
    }

    #[test]
    #[available_gas(l2_gas: 32634)]
    fn achievement_empty_slot_unpacks_undefined() {
        let d: HeadSlot = StorePacking::unpack(0);
        assert!(!d.defined);
        assert!(!d.retired);
        assert!(d.task_count == 0);
        assert!(d.points == 0);
    }

    #[test]
    #[should_panic(expected: 'Packing: field out of range')]
    #[available_gas(l2_gas: 16296)]
    fn achievement_packing_rejects_task_count_above_max() {
        let _: felt252 = StorePacking::pack(head(0, 0, 4, true, false, 1, 1, 0));
    }

    /// Bit 212, the first reserved bit since `points` took [196, 212) (0.1.0: bit 196).
    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 396701)]
    fn achievement_unpacking_rejects_bit_212() {
        let _: HeadSlot = StorePacking::unpack(to_felt(pow2(212)));
    }

    /// Exactly 2^251: bit 251 alone, every lower reserved bit clear. A felt literal, since
    /// `to_felt` requires values below 2^251 (2^251 is below the field prime, so it is a valid
    /// felt).
    const TWO_POW_251: felt252 = 0x800000000000000000000000000000000000000000000000000000000000000;

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 30933)]
    fn achievement_unpacking_rejects_bit_251() {
        let _: HeadSlot = StorePacking::unpack(TWO_POW_251);
    }

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 358470)]
    fn achievement_unpacking_extra_rejects_bit_128() {
        let _: TasksSlot = StorePacking::unpack(to_felt(pow2(128)));
    }

    // Benchmarks, on the worst case of each (docs/CAIRO.md §2)

    #[test]
    #[available_gas(l2_gas: 21126)]
    fn bench_definition_new_three_tasks() {
        definition_new(1, always(), array![task(1, 1), task(2, 1), task(3, 1)].span());
    }

    #[test]
    #[available_gas(l2_gas: 35826)]
    fn bench_pack_unpack_definition() {
        let d = head(U64_MAX, U64_MAX, 3, true, true, U32_MAX, U32_MAX, U16_MAX);
        let back: HeadSlot = StorePacking::unpack(StorePacking::pack(d));
        assert!(back == d);
    }

    #[test]
    #[available_gas(l2_gas: 26177)]
    fn bench_pack_unpack_extra_tasks() {
        let e = TasksSlot { t1: task(U32_MAX, U32_MAX), t2: task(U32_MAX, U32_MAX) };
        let back: TasksSlot = StorePacking::unpack(StorePacking::pack(e));
        assert!(back == e);
    }
}
