# quiver_leaderboard

A top-3 leaderboard for Starknet games, as **internal code on the consumer's own storage**. The
consumer places a storage node in its `#[storage]` and calls `submit`, `ranked` and `top` on it
from its own entrypoints. Pure Cairo and Starknet, no Dojo, no `u256`.

**No entry point, no event.** The package has no `#[starknet::interface]`, no ABI item, no contract
and no component outside its tests, so nothing of it appears in the consumer's ABI, and it emits
nothing. Access control is the consumer's: only code the consumer writes can call `submit`.
Written from Paved's specification; no Arcade code.

## Usage

```cairo
use quiver_leaderboard::leaderboard::{LeaderboardTrait, LeaderboardViewTrait};
use quiver_leaderboard::store::LeaderboardStorage;
use quiver_leaderboard::types::submission::Submission;

#[storage]
struct Storage {
    leaderboard: LeaderboardStorage,
}

// in an entrypoint, with `ref self: ContractState`:
let rank = self.leaderboard.submit(tournament_id, Submission { player_id, game_id, score, time });
// in a view, with `self: @ContractState`:
let top = self.leaderboard.top(tournament_id);        // Top3 { first, second, third }
let third = self.leaderboard.ranked(tournament_id, 3); // Ranked { player_id, score }
```

The calls are trait methods on the node's storage path; they also work on a path (a node nested in
another node). `Submission { player_id: felt252, game_id: u32, score: u32, time: u64 }`,
`Ranked { player_id: felt252, score: u32 }` (zero player and zero score: an empty rank),
`Top3 { first, second, third }`.

## The rule

`submit(t, s)`:

1. A score of 0 or a player of 0: returns 0; nothing read, nothing written.
2. A score not above the third's: returns 0; nothing written.
3. Otherwise the rank is 1 above the first, else 2 above the second, else 3. **An equal score goes
   below** (the earlier call stays above). The lower ranks shift down by one; the third falls out.
   The scores word is written once; player slots 1 and 2 are written **only if their value changes**.
   Slot 3 is not read, so it is written on every placement that reaches it, even with the same value
   (one overwrite, about 72 106 gas, no state diff on the network; reading it would cost about 38 920
   on every placing submit).

Games are ranked, not players: one player may hold two or three ranks. `game_id` and `time` are
data, never compared; the block timestamp is never read. `ranked` with a rank outside 1..=3 answers
an empty `Ranked`. A tournament id is a map key, never packed nor checked: any `u64` (0 included).
**Nothing reverts.**

## Storage: 4 slots per tournament

`LeaderboardStorage` is a `#[starknet::storage_node]` of two maps: `scores: Map<u64, Scores>`, the
three scores in one felt (rank 1 at bits [0, 32), rank 2 at [32, 64), rank 3 at [64, 96), the rest
zero), and `players: Map<(u64, u8), felt252>`, the player of rank 1, 2 and 3. The organisation is
docs/CAIRO.md §7: `models/` holds the scores word and its packing (`StorePacking`), `store.cairo`
the only access to storage. The store is implemented on the node's storage path instead of a
component state, since the package has no component.

## Bounds and costs

N is fixed at 3 (`Top3`). **No loop exists**; every operation is a constant number of storage
accesses, whatever the number of submissions: `submit` at most 3 reads (the word, players 1 and 2)
and 4 writes; not placed, 1 read; `top` at most 4 reads; `ranked` at most 2. Measured in snforge L2
gas, flat after 10, 100 and 1,000 submissions: `submit` placing 198 050 to 427 420 (rank 3 to rank
1 on a full board; 1 005 030 for the first submission of a tournament, which creates two slots),
not placed 47 920, `top` 163 910, `ranked` 44 530 to 83 450. Detail, ceilings and network
estimates: [GAS.md](GAS.md).

## Events

None emitted. `events::submitted::LeaderboardSubmitted` (keys `tournament_id`, `player_id`; data
`game_id`, `score`, `time`, `rank`) is offered for a consumer that wants to emit one itself, from its
own contract, with `SubmittedTrait::new(tournament_id, @submission, rank)`. Paved's indexer does not
read it.

## Toolchain

Scarb 2.20.1, snforge 0.64.0, `starknet` 2.20.x. The package uses edition `2024_07`; a consumer on
`2023_11` builds against it (a dependency keeps its own edition).
