# Arcade's leaderboard → `quiver_leaderboard` 0.1.0

| | |
|---|---|
| Asked by | The owner, 2026-10-07 (relayed by the project manager): Arcade's leaderboard as a quiver package, without Dojo, as `quiver_quest` and `quiver_achievement` were |
| Written by | A thread of track ARC, `[Opus 5.5]`, 2026-10-07, for the brief [ARC-05a](../briefs/ARC-05a-leaderboard.md) |
| Reference | `cartridge-gg/arcade` at `c53fadcc`, `packages/leaderboard/` (read file by file; nothing run) |
| Format | As [the quest mapping](ARC-07a-arcade-mapping.md): what Arcade has, what 0.1.0 does with it, why |

The reasons, abbreviated in the tables:

- **Paved**: the consumer's needs 1 to 5, in [the brief](../briefs/ARC-05a-leaderboard.md#the-consumers-needs).
  Where Arcade differs from them, the needs win.
- **Native**: no Dojo world. Starknet storage is keyed slots of one packed felt; a created slot costs
  about 453 500 L2 gas on the network, an overwritten one about 32 000
  ([GAS.md of `quiver_achievement`](../../packages/achievement/GAS.md#the-price-of-a-storage-slot-snforge-and-the-network)).
- **§7**: the organisation of [CAIRO.md §7](../CAIRO.md#7-organisation-of-the-code-owners-rule-2026-09-29-d-143):
  models, one store, a tracked model's event optional for the consumer at compile time.
- **Defect**: a defect found by reading Arcade's code (below). Read, not run.
- **Indexer**: what the consumer's indexer rebuilds from events, so the contract does not store it.

## 1. What Arcade has

| Piece | File | What it does |
|---|---|---|
| `RankableComponent` | `src/components/rankable.cairo` | A Starknet component (no Dojo model) holding, per `leaderboard_id: felt252`: `cap: u8`, `len: u8`, `keys` (a map shared by positions and by `key + 252` → position), `data` (key → `Item`), `lowest_key`. A **max-heap in storage**, keyed by the game id. Internal functions only: `set` (the capacity), `cap`, `len`, `is_empty`, `span`, `get`, `at`, `submit`, `pop_front` |
| `Item` | `src/types/item.cairo` | `{ key: u64 (the game id), score: u64, time: u64 }`, packed in one felt. Ordered by score, then the earlier time; equal on the key alone |
| `Heap` | `src/helpers/heap.cairo` | The same heap in memory (`Felt252Dict`), used by `span` to sort the stored items for a read |
| `LeaderboardScore` | `src/events/index.cairo`, `score.cairo` | A Dojo event `{ #[key] leaderboard_id, #[key] game_id, player, score, timestamp }`, emitted through the world |
| `Store` | `src/store.cairo` | Wraps the Dojo `WorldStorage`; one method, `submit`, which emits `LeaderboardScore` |
| `Ranker` | `src/tests/mocks/ranker.cairo` | A `#[dojo::contract]` exposing `set`, `len`, `submit`, `at` to **any caller**. A test mock; the deployed manifest names `submit`, `set`, `hydrate`, `upgrade` (no `hydrate` in the sources at `c53fadcc`: not mapped) |
| Tests | `src/tests/test_ranker.cairo` | 8 tests through a Dojo test world: order, equal scores, capacity, a game submitted twice. No gas budget |
| Manifest | `Scarb.toml` | `dojo` 1.8.0, Cairo 2.13.1, and `graffiti` (a git dependency, unused by the sources). `README.md` is a copy of the quest package's |

`submit(world, leaderboard_id, game_id, player_id, score, time, to_store)` always emits
`LeaderboardScore`; with `to_store` it also inserts `Item { key: game_id, score, time }` in the heap.
A capacity of 0 means "up to 255" (`len` is a `u8`).

**What depends on Dojo**: the event (`#[dojo::event]`, `world.emit_event`), the `Store`, the mock
contract and its test world (`dojo_cairo_test`). The heap itself is plain Starknet storage.

## 2. Defects found by reading

| # | Where | Defect |
|---|---|---|
| L-1 | `Item`'s packing | Fields are `u64`, but `pack` places `score` at bit 32 and `time` at bit 64, and `unpack` masks 32 bits: a game id or a score of 2^32 or more overlaps the next field and reads back wrong |
| L-2 | `add` on a full board | It calls `swap(index, lowest_key)` with a **position** where `swap` takes two **keys**. The tests pass because their game ids 1 to 4 equal the positions involved |
| L-3 | `add` on a full board | `lowest_key` is not recomputed after an eviction: it still names the evicted item, whose data stays stored, and the next submission is compared with it |
| L-4 | `Item`'s order | Equal score and equal time compare neither lower nor greater: the order of such items is the heap's, not a rule |
| L-5 | `keys` | Positions and `key + 252` share one map: with more than 252 items, game ids 0 to 2 collide with positions 252 to 254 |
| L-6 | `at(rank)` | Each read rebuilds a heap in memory from every stored item and pops `rank + 1` of them: a view's cost grows with `len` (up to 255) |
| L-7 | The board | The player is not stored: a prize claim cannot read from storage who holds a rank |

## 3. Models

| Arcade | `quiver_leaderboard` 0.1.0 | Why |
|---|---|---|
| `cap`, set by `set(leaderboard_id, cap)` | `LeaderboardDefinition { leaderboard_id, size }`, in slot H | **Kept**, as a definition written once by `define`, tracked (§7). `size` from 1 to `MAX_SIZE` = 16; 0 ("up to 255") is refused (Paved, need 3: a bounded top) |
| `len`, `lowest_key`, the heap's positions in `keys` | `LeaderboardRanking { leaderboard_id, len, order }`, sharing slot H | **Merged and changed**. The order of the top is 16 indices of 4 bits in the slot that holds the size: a submission rewrites one felt for the order instead of swapping keys through the heap (Native; defects L-2, L-3, L-5). Untracked: the indexer rebuilds the ranking from `LeaderboardSubmitted` (Indexer) |
| `data: key → Item { key: game_id, score, time }` | `LeaderboardEntry { leaderboard_id, index, player, game_id, score, time }`, slots P (player) and S (score, time, game id) | **Changed**. The player is stored, so the prize claim reads the winners (L-7, Paved need 3). One place per player, not per game (the brief, the tie rule). The packing gives each `u64` its own 64 bits (L-1). Untracked: no event on a shift |
| The heap in memory (`Heap`, `Felt252Dict`) | **Dropped** | The top is kept in rank order; a read walks `len` entries, with no sort (L-6) |
| — | `LeaderboardSubmitter { leaderboard_id, submitter, allowed }` | **New**. Arcade has no access control; Paved needs `submit` limited to the contracts it registers, per leaderboard (need 2). Tracked |

## 4. Events

| Arcade | `quiver_leaderboard` 0.1.0 | Why |
|---|---|---|
| `LeaderboardScore { #[key] leaderboard_id, #[key] game_id, player, score, timestamp }`, on every submission | `LeaderboardSubmitted { #[key] leaderboard_id, #[key] player, game_id, score, time }`, on every submission | **Kept, keys changed**: keyed by the leaderboard and the **player**, the game id in the data (Paved need 4). An action event, emitted whatever the consumer tracks: with the bounded top, it is the only record of the full ranking (Indexer) |
| — | `LeaderboardDefined { #[key] leaderboard_id, size }` | **New**: the tracked definition's event (§7) |
| — | `LeaderboardSubmitterSet { #[key] leaderboard_id, #[key] submitter, allowed }` | **New**: the tracked submitter's event (§7), as `QuestReporterSet` |

## 5. Entrypoints, access and modes

| Arcade | `quiver_leaderboard` 0.1.0 | Why |
|---|---|---|
| `set(leaderboard_id, cap)`, internal, callable again at any time | `define(leaderboard_id, size)`, once per leaderboard; again refused | **Changed**: a size that shrinks under a full board has no defined meaning |
| `submit(…, to_store)` | `submit(leaderboard_id, player, game_id, score, time) -> Option<u8>` (the new rank, if the entry is in the top) | **Changed**: the top is always kept and always bounded, so `to_store` has no use (Paved need 3). The rank returned lets the consumer react in the same call |
| `at(rank)`, `span(count)`, `len`, `get(key)` | Views `leaderboard_definition`, `leaderboard_top`, `leaderboard_at`, `leaderboard_is_submitter` | **Kept** as reads of the stored top, in rank order (L-6). `get(key)` by game id is dropped: the top is keyed by rank |
| `pop_front`, `is_empty`, `cap` | **Dropped** | Never called by `submit`; `pop_front` is a heap operation the top no longer needs |
| No access control (the mock exposes `set` and `submit` to anyone) | `define` and `set_submitter` by the `authorize_admin` hook; `submit` by the submitters registered for that leaderboard; the internal layer trusted, as in `quiver_quest` | **New** (Paved need 2; [COMMON.md §4](../briefs/COMMON.md#4-rules-of-the-packages)) |
| Dojo world, `Store` over `WorldStorage`, `graffiti` | The component's state is the store (§7); no dependency but `starknet` | **Native**, Paved need 1 |

The tie rule, the bounds and their costs are the brief's.
