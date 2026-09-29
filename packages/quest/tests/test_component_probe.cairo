//! Unit costs of the operations the component is made of, through a dispatcher, as the
//! benchmarks measure: a storage read and write of a `Map` keyed like the component's, an event
//! like `QuestCompleted`, and the unpack of each packed type read on the path of `progress_many`. A
//! probe's cost is its test minus `probe_baseline`, divided by its count (fix loop 2, point 2).

use quiver_quest::logic::{QuestDefinition, QuestHeldSlot, QuestRecord, QuestTasks};
use snforge_std::{ContractClassTrait, DeclareResultTrait, declare, map_entry_address, store};
use starknet::ContractAddress;

#[starknet::interface]
pub trait IProbe<TState> {
    fn noop(ref self: TState, n: u32);
    fn read_n(ref self: TState, n: u32) -> felt252;
    fn write_n(ref self: TState, n: u32);
    fn write_other_n(ref self: TState, n: u32);
    fn emit_n(ref self: TState, n: u32);
    fn unpack_definition_n(ref self: TState, n: u32) -> u64;
    fn unpack_tasks_n(ref self: TState, n: u32) -> u32;
    fn unpack_record_n(ref self: TState, n: u32) -> u64;
    fn unpack_held_n(ref self: TState, n: u32) -> u64;
    fn set_n(ref self: TState, n: u32, value: felt252);
    fn set_twice_n(ref self: TState, n: u32, first: felt252, second: felt252);
}

#[starknet::contract]
pub mod Probe {
    use quiver_quest::logic::{QuestDefinition, QuestHeldSlot, QuestRecord, QuestTasks};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::storage_access::StorePacking;
    use super::IProbe;

    #[storage]
    struct Storage {
        values: Map<(felt252, u32), felt252>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Done: Done,
    }

    #[derive(Drop, starknet::Event)]
    struct Done {
        #[key]
        player_id: felt252,
        #[key]
        quest_id: u32,
        interval_id: u64,
    }

    #[abi(embed_v0)]
    impl ProbeImpl of IProbe<ContractState> {
        fn noop(ref self: ContractState, n: u32) {
            let mut i = 0;
            while i < n {
                i += 1;
            }
        }

        fn read_n(ref self: ContractState, n: u32) -> felt252 {
            let mut acc = 0;
            let mut i = 0;
            while i < n {
                acc += self.values.read(('player', i));
                i += 1;
            }
            acc
        }

        fn write_n(ref self: ContractState, n: u32) {
            let mut i = 0;
            while i < n {
                self.values.write(('player', i), i.into() + 1);
                i += 1;
            }
        }

        fn write_other_n(ref self: ContractState, n: u32) {
            let mut i = 0;
            while i < n {
                self.values.write(('player', i), i.into() + 2);
                i += 1;
            }
        }

        fn set_n(ref self: ContractState, n: u32, value: felt252) {
            let mut i = 0;
            while i < n {
                self.values.write(('player', i), value);
                i += 1;
            }
        }

        fn set_twice_n(ref self: ContractState, n: u32, first: felt252, second: felt252) {
            let mut i = 0;
            while i < n {
                self.values.write(('player', i), first);
                self.values.write(('player', i), second);
                i += 1;
            }
        }

        fn emit_n(ref self: ContractState, n: u32) {
            let mut i = 0;
            while i < n {
                self.emit(Done { player_id: 'player', quest_id: i, interval_id: 0 });
                i += 1;
            }
        }

        fn unpack_definition_n(ref self: ContractState, n: u32) -> u64 {
            let mut acc = 0;
            let mut i: u32 = 0;
            while i < n {
                let packed: felt252 = 0x1234567890abcdef + i.into() * 0x10000000000000000;
                let d: QuestDefinition = StorePacking::unpack(packed);
                acc += d.schedule.end;
                i += 1;
            }
            acc
        }

        fn unpack_tasks_n(ref self: ContractState, n: u32) -> u32 {
            let mut acc = 0;
            let mut i: u32 = 0;
            while i < n {
                let t: QuestTasks = StorePacking::unpack(i.into() + 0x100000000);
                acc += t.t0.total;
                i += 1;
            }
            acc
        }

        fn unpack_record_n(ref self: ContractState, n: u32) -> u64 {
            let mut acc = 0;
            let mut i: u32 = 0;
            while i < n {
                let r: QuestRecord = StorePacking::unpack(i.into());
                acc += r.completions;
                i += 1;
            }
            acc
        }

        fn unpack_held_n(ref self: ContractState, n: u32) -> u64 {
            let mut acc = 0;
            let mut i: u32 = 0;
            while i < n {
                // two entries: (i, 20000) and (i + 1, 20000)
                let packed: felt252 = i.into()
                    + 20000 * 0x100000000
                    + (i.into() + 1) * 0x100000000000000000000000000000000
                    + 20000 * 0x10000000000000000000000000000000000000000;
                let h: QuestHeldSlot = StorePacking::unpack(packed);
                acc += h.e1.interval_id;
                i += 1;
            }
            acc
        }
    }
}

const N: u32 = 100;

fn deploy() -> IProbeDispatcher {
    let class = declare("Probe").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IProbeDispatcher { contract_address: address }
}

#[test]
#[available_gas(l2_gas: 476406)]
fn probe_baseline() {
    deploy().noop(N);
}

#[test]
#[available_gas(l2_gas: 3647931)]
fn probe_read_100() {
    deploy().read_n(N);
}

#[test]
#[available_gas(l2_gas: 48681801)]
fn probe_write_100() {
    deploy().write_n(N);
}

#[test]
#[available_gas(l2_gas: 5573316)]
fn probe_emit_100() {
    deploy().emit_n(N);
}

#[test]
#[available_gas(l2_gas: 2432840)]
fn probe_unpack_definition_100() {
    deploy().unpack_definition_n(N);
}

#[test]
#[available_gas(l2_gas: 1802000)]
fn probe_unpack_tasks_100() {
    deploy().unpack_tasks_n(N);
}

#[test]
#[available_gas(l2_gas: 1219250)]
fn probe_unpack_record_100() {
    deploy().unpack_record_n(N);
}

#[test]
#[available_gas(l2_gas: 2284580)]
fn probe_unpack_held_100() {
    deploy().unpack_held_n(N);
}

/// The slots of `write_n`, seeded with snforge's `store` instead of a call: the setup of a
/// benchmark that seeds its fixture.
fn store_n(address: ContractAddress, n: u32) {
    let mut i: u32 = 0;
    while i < n {
        let key = map_entry_address(selector!("values"), array!['player', i.into()].span());
        store(address, key, array![i.into() + 1].span());
        i += 1;
    }
}

fn deploy_at() -> (ContractAddress, IProbeDispatcher) {
    let class = declare("Probe").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    (address, IProbeDispatcher { contract_address: address })
}

#[test]
#[available_gas(l2_gas: 44749100)]
fn probe_store_baseline() {
    let (address, probe) = deploy_at();
    store_n(address, N);
    probe.noop(N);
}

/// Slots seeded with `store`, then changed by a call: whether the seeding counts as a change of
/// the transaction (then each write costs as an overwrite) or not (as a first write).
#[test]
#[available_gas(l2_gas: 50744495)]
fn probe_store_then_change_100() {
    let (address, probe) = deploy_at();
    store_n(address, N);
    probe.write_other_n(N);
}

#[test]
#[available_gas(l2_gas: 54962282)]
fn probe_write_then_overwrite_100() {
    let probe = deploy();
    probe.write_n(N);
    probe.write_n(N);
}

#[test]
#[available_gas(l2_gas: 48966887)]
fn probe_write_twice_in_one_call_baseline() {
    let probe = deploy();
    probe.write_n(N);
    probe.noop(N);
}

#[test]
#[available_gas(l2_gas: 54962282)]
fn probe_write_then_change_100() {
    let probe = deploy();
    probe.write_n(N);
    probe.write_other_n(N);
}

#[allow(unused_imports)]
fn _types(
    _d: QuestDefinition, _t: QuestTasks, _r: QuestRecord, _h: QuestHeldSlot, _a: ContractAddress,
) {}

// Fix loop 1, point 1: the cost of a write by the transition of its cell. Starknet charges the
// allocation of a cell (zero at the start of the transaction, non-zero at its end) once, from the
// final state diff; snforge does the same over a whole test. Each transition is its own test; the
// tests with a first call that sets the cells to 1 are compared with
// `probe_transition_baseline_set`, which makes that first call and then a call that writes
// nothing, so that the allocations of the setup are the same on both sides.

#[test]
#[available_gas(l2_gas: 48967622)]
fn probe_transition_baseline_set() {
    let probe = deploy();
    probe.set_n(N, 1);
    probe.noop(N);
}

/// 0 → 1, one call: an allocation per cell.
#[test]
#[available_gas(l2_gas: 48967622)]
fn probe_transition_zero_to_value() {
    let probe = deploy();
    probe.noop(N);
    probe.set_n(N, 1);
}

/// 0 → 0: a write that changes nothing.
#[test]
#[available_gas(l2_gas: 6757622)]
fn probe_transition_zero_unchanged() {
    let probe = deploy();
    probe.noop(N);
    probe.set_n(N, 0);
}

/// 0 → 1 → 0 in one call: the cell is back to its initial value; no allocation.
#[test]
#[available_gas(l2_gas: 12657257)]
fn probe_transition_zero_set_then_restored() {
    let probe = deploy();
    probe.noop(N);
    probe.set_twice_n(N, 1, 0);
}

/// 1 → 2 (after the setup's 0 → 1): an update of a non-zero cell.
#[test]
#[available_gas(l2_gas: 54963752)]
fn probe_transition_value_to_other() {
    let probe = deploy();
    probe.set_n(N, 1);
    probe.set_n(N, 2);
}

/// 1 → 1: an unchanged non-zero cell.
#[test]
#[available_gas(l2_gas: 54963752)]
fn probe_transition_value_unchanged() {
    let probe = deploy();
    probe.set_n(N, 1);
    probe.set_n(N, 1);
}

/// 1 → 2 → 1 in one call: changed, then restored to its value at the start of the call.
#[test]
#[available_gas(l2_gas: 60863387)]
fn probe_transition_value_changed_then_restored() {
    let probe = deploy();
    probe.set_n(N, 1);
    probe.set_twice_n(N, 2, 1);
}

/// 1 → 0: a clear. Within one test it also undoes the setup's allocation, since the final diff
/// no longer has the cell; the difference with the baseline is the clear minus the allocation.
#[test]
#[available_gas(l2_gas: 12753752)]
fn probe_transition_value_to_zero() {
    let probe = deploy();
    probe.set_n(N, 1);
    probe.set_n(N, 0);
}

/// The baseline of the one-call-then-write tests above: deploy, then two calls that write
/// nothing.
#[test]
#[available_gas(l2_gas: 761492)]
fn probe_transition_baseline_empty() {
    let probe = deploy();
    probe.noop(N);
    probe.noop(N);
}
