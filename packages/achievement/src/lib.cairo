//! `quiver_achievement` 0.2.0, organised as docs/CAIRO.md §7 says (D-143, ARC-07b): `models/` the
//! stored entities, `events/` the events, `types/` the value types, `helpers/` what belongs to no
//! entity, `store` the only access to storage, `component` the entrypoints and their access
//! control.
//!
//! **Event mode only** (the decision of 2026-09-29): progress is emitted as
//! `AchievementProgressed`, never stored; an indexer derives the tiers from the definitions and
//! the events.
//!
//! The unit tests of a module are in its file, under `#[cfg(test)] mod tests` (D-167); `tests/`
//! holds what needs a deployed contract.

pub mod component;
pub mod constants;
pub mod errors;
pub mod interface;
pub mod store;

pub mod types {
    pub mod batch;
    pub mod task;
    pub mod window;
}

pub mod helpers {
    pub mod bits;
}

pub mod models {
    pub mod definition;
    pub mod index;
    pub mod reporter;
    pub mod status;
}

pub mod events {
    pub mod defined;
    pub mod index;
    pub mod progressed;
    pub mod reporter_set;
    pub mod retired;
}
