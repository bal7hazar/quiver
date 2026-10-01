//! `quiver_quest` 0.2.0, organised as docs/CAIRO.md §7 says (D-143, ARC-07a): `models/` the stored
//! entities, `events/` the events, `types/` the value types, `helpers/` what belongs to no entity,
//! `store` the only access to storage, `component` the entrypoints and their access control.

pub mod component;
pub mod constants;
pub mod errors;
pub mod interface;
pub mod store;

pub mod types {
    pub mod batch;
    pub mod held;
    pub mod mode;
    pub mod schedule;
    pub mod task;
}

pub mod helpers {
    pub mod bits;
}

pub mod models {
    pub mod definition;
    pub mod held;
    pub mod index;
    pub mod progress;
    pub mod record;
    pub mod reporter;
    pub mod status;
}

/// What the unit tests of the modules share (D-167): builders, the packing oracle and 0.1.0's
/// functions as oracles. Compiled for tests only; `tests/` keeps its own copies of what the
/// integration tests need, as it cannot reach this module.
#[cfg(test)]
mod testing {
    pub mod helpers;
    pub mod oracle;
    pub mod packing;
}

pub mod events {
    pub mod claimed;
    pub mod completed;
    pub mod defined;
    pub mod index;
    pub mod progressed;
    pub mod reporter_set;
    pub mod retired;
}
