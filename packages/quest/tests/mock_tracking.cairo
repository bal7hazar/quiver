//! Optional tracking (ARC-07a), measured on one model of one slot: `Logged` of `mock_store`,
//! tracked by `LoggedSet`, whose event the consumer chooses at compile time. Two mechanisms:
//!
//! - **the constant**: the consumer's `TrackingTrait` impl has one `bool` constant per tracked
//!   model; `set_logged` emits `if Tracking::LOGGED`;
//! - **the emitter**: one impl parameter per tracked model, `Emit` (calls `emit`) or `Silent`
//!   (an empty body).
//!
//! Each contract also has the hand-written twins, in the same contract and on the same slot: the
//! write with no event code at all, and the write then `emit`. `MockTrackAll` chooses to emit,
//! `MockTrackNone` not to.

use super::mock_store::Logged;

#[starknet::component]
pub mod TrackingComponent {
    use starknet::storage::{Map, StorageMapWriteAccess};
    use super::Logged;
    use super::super::mock_store::{LoggedSet, LoggedTracked, Values};

    #[storage]
    pub struct Storage {
        pub Mock_logged: Map<u32, Values>,
    }

    #[event]
    #[derive(Drop, PartialEq, Debug, starknet::Event)]
    pub enum Event {
        LoggedSet: LoggedSet,
    }

    /// The consumer's choice, by constants.
    pub trait TrackingTrait<TContractState> {
        const LOGGED: bool;
    }

    /// The consumer's choice, by an emitter per tracked model.
    pub trait LoggedEmitter<TContractState> {
        fn emit_logged(ref self: ComponentState<TContractState>, logged: @Logged);
    }

    #[generate_trait]
    pub impl StoreImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl Tracking: TrackingTrait<TContractState>,
        impl Emitter: LoggedEmitter<TContractState>,
        +Drop<TContractState>,
    > of StoreTrait<TContractState> {
        /// The constant.
        #[inline]
        fn set_logged(ref self: ComponentState<TContractState>, logged: Logged) {
            self.Mock_logged.write(logged.id, Values { a: logged.a, b: logged.b });
            if Tracking::LOGGED {
                HasComponent::emit(ref self, LoggedTracked::event(@logged));
            }
        }

        /// The emitter.
        #[inline]
        fn set_logged_by_emitter(ref self: ComponentState<TContractState>, logged: Logged) {
            self.Mock_logged.write(logged.id, Values { a: logged.a, b: logged.b });
            Emitter::emit_logged(ref self, @logged);
        }

        /// By hand: the write, with no event code.
        #[inline]
        fn hand_set_silent(ref self: ComponentState<TContractState>, id: u32, a: u64, b: u64) {
            self.Mock_logged.write(id, Values { a, b });
        }

        /// By hand: the write, then its event.
        #[inline]
        fn hand_set_emitted(ref self: ComponentState<TContractState>, id: u32, a: u64, b: u64) {
            self.Mock_logged.write(id, Values { a, b });
            self.emit(LoggedSet { id, a, b });
        }
    }
}


/// The ready choices, outside the traits' module: there, the compiler would find them as well as
/// the consumer's own impl and refuse the call as ambiguous.
pub mod choices {
    use super::TrackingComponent::{ComponentState, HasComponent, LoggedEmitter, TrackingTrait};
    use super::super::mock_store::{Logged, LoggedTracked};

    pub impl TrackAll<TContractState> of TrackingTrait<TContractState> {
        const LOGGED: bool = true;
    }

    pub impl TrackNone<TContractState> of TrackingTrait<TContractState> {
        const LOGGED: bool = false;
    }

    pub impl Emit<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of LoggedEmitter<TContractState> {
        #[inline]
        fn emit_logged(ref self: ComponentState<TContractState>, logged: @Logged) {
            HasComponent::emit(ref self, LoggedTracked::event(logged));
        }
    }

    pub impl Silent<TContractState> of LoggedEmitter<TContractState> {
        #[inline]
        fn emit_logged(ref self: ComponentState<TContractState>, logged: @Logged) {}
    }
}

#[starknet::interface]
pub trait IMockTracking<TState> {
    fn noop(ref self: TState, id: u32, a: u64, b: u64);
    fn set_by_constant(ref self: TState, id: u32, a: u64, b: u64);
    fn set_by_emitter(ref self: TState, id: u32, a: u64, b: u64);
    fn hand_set_silent(ref self: TState, id: u32, a: u64, b: u64);
    fn hand_set_emitted(ref self: TState, id: u32, a: u64, b: u64);
}

#[starknet::contract]
pub mod MockTrackAll {
    use super::TrackingComponent::StoreTrait;
    use super::{IMockTracking, Logged, TrackingComponent};

    component!(path: TrackingComponent, storage: tracking, event: TrackingEvent);

    impl Tracking = super::choices::TrackAll<ContractState>;
    impl LoggedEmitter = super::choices::Emit<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        tracking: TrackingComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        TrackingEvent: TrackingComponent::Event,
    }

    #[abi(embed_v0)]
    impl MockTrackingImpl of IMockTracking<ContractState> {
        fn noop(ref self: ContractState, id: u32, a: u64, b: u64) {}

        fn set_by_constant(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.tracking.set_logged(Logged { id, a, b });
        }

        fn set_by_emitter(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.tracking.set_logged_by_emitter(Logged { id, a, b });
        }

        fn hand_set_silent(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.tracking.hand_set_silent(id, a, b);
        }

        fn hand_set_emitted(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.tracking.hand_set_emitted(id, a, b);
        }
    }
}

#[starknet::contract]
pub mod MockTrackNone {
    use super::TrackingComponent::StoreTrait;
    use super::{IMockTracking, Logged, TrackingComponent};

    component!(path: TrackingComponent, storage: tracking, event: TrackingEvent);

    impl Tracking = super::choices::TrackNone<ContractState>;
    impl LoggedEmitter = super::choices::Silent<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        tracking: TrackingComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        TrackingEvent: TrackingComponent::Event,
    }

    #[abi(embed_v0)]
    impl MockTrackingImpl of IMockTracking<ContractState> {
        fn noop(ref self: ContractState, id: u32, a: u64, b: u64) {}

        fn set_by_constant(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.tracking.set_logged(Logged { id, a, b });
        }

        fn set_by_emitter(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.tracking.set_logged_by_emitter(Logged { id, a, b });
        }

        fn hand_set_silent(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.tracking.hand_set_silent(id, a, b);
        }

        fn hand_set_emitted(ref self: ContractState, id: u32, a: u64, b: u64) {
            self.tracking.hand_set_emitted(id, a, b);
        }
    }
}
