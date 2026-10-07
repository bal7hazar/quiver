//! `quiver_leaderboard` 0.1.0 (ARC-05a): a top-3 leaderboard as **internal code on the consumer's
//! own storage**. The consumer places a `LeaderboardStorage` node in its `#[storage]` and calls
//! `submit`, `ranked` and `top` on it from its own entrypoints. No entry point, no event, no
//! contract, no component: access control is the consumer's. Written from Paved's specification.
//!
//! Organised as docs/CAIRO.md §7 says: `models/` the stored entity (the scores word), `types/` the
//! value types, `events/` the event a consumer may emit itself, `store` the only access to
//! storage (the storage node itself), `leaderboard` the three calls.
//!
//! The unit tests of a module are in its file, under `#[cfg(test)] mod tests` (D-167); `tests/`
//! holds what needs a deployed contract.

#[cfg(test)]
pub mod bench;
pub mod leaderboard;
pub mod store;

pub mod types {
    pub mod ranked;
    pub mod submission;
    pub mod top3;
}

pub mod models {
    pub mod index;
    pub mod scores;
}

pub mod events {
    pub mod submitted;
}

#[cfg(test)]
pub mod testing {
    pub mod mock;
    pub mod reference;
}
