// Types

/// Where a progress call goes: stored records, or events only.
#[derive(Drop, Copy, Serde, PartialEq, Debug, starknet::Store)]
pub enum Mode {
    #[default]
    Storage,
    Event,
}
