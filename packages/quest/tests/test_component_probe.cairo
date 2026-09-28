//! Unit costs of the operations the component is made of, through a dispatcher, as the
//! benchmarks measure: a storage read and write of a `Map` keyed like the component's, an event
//! like `QuestCompleted`, and the unpack of each packed type. A probe's cost is its test minus
//! `probe_baseline`, divided by its count (fix loop 2, point 2).

use quiver_quest::logic::{QuestDefinition, QuestRecord, QuestTasks};
use snforge_std::{ContractClassTrait, DeclareResultTrait, declare};
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
}

#[starknet::contract]
pub mod Probe {
    use quiver_quest::logic::{QuestDefinition, QuestRecord, QuestTasks};
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
#[available_gas(l2_gas: 2640740)]
fn probe_unpack_definition_100() {
    deploy().unpack_definition_n(N);
}

#[test]
#[available_gas(l2_gas: 1802000)]
fn probe_unpack_tasks_100() {
    deploy().unpack_tasks_n(N);
}

#[test]
#[available_gas(l2_gas: 1593050)]
fn probe_unpack_record_100() {
    deploy().unpack_record_n(N);
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
fn _types(_d: QuestDefinition, _t: QuestTasks, _r: QuestRecord, _a: ContractAddress) {}
