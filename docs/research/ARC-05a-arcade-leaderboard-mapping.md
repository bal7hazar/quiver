# Arcade's leaderboard, at the level of design → `quiver_leaderboard` 0.1.0

| | |
|---|---|
| Asked by | The owner, 2026-10-07 (relayed by the project manager): Arcade's leaderboard as a quiver package, without Dojo |
| Written by | A thread of track ARC, `[Opus 5.5]`, 2026-10-07, for the brief [ARC-05a](../briefs/ARC-05a-leaderboard.md) |
| Reference | `cartridge-gg/arcade` at `c53fadcc`, `packages/leaderboard/`, read; nothing run |
| Specification | **Paved's request** (2026-10-07, relayed by the project manager), which replaces the preliminary needs: the brief's [table](../briefs/ARC-05a-leaderboard.md#paveds-specification) |

## Licence hold

Arcade's licence is "all rights reserved", with a limited licence for non-commercial use only. A
licence is the owner's call, and the owner is being asked. Until the answer, this document
describes Arcade's **design** in its own words: it quotes no code, no signature and no layout of
Arcade's. The design of `quiver_leaderboard` is written from Paved's specification; the table in §2
says which design ideas it shares with Arcade's, and which it does not. The implementation lot
copies and ports no Arcade code unless the owner's answer allows it.

## 1. Arcade's leaderboard, as designed

- **What it is.** A component that a game embeds, with internal functions only. Each leaderboard,
  named by an identifier, keeps a capped set of game results in the game contract's storage, as a
  priority queue (a binary heap) whose order is rebuilt in memory to answer a read of a rank.
- **What a submission carries.** The leaderboard, the game, the player, the score and a time. A flag
  per call chooses between "event only" and "event and stored". The stored record keeps the game,
  the score and the time; the player is in the event only.
- **Order.** Higher score first; equal scores ordered by the earlier time. A game submitted again
  replaces its own record.
- **Capacity.** Set per leaderboard, small (at most 255), with "no capacity" meaning the maximum.
- **Events and Dojo.** Each submission emits one event, keyed by the leaderboard and the game,
  through a Dojo world; the event, its store and the test contract depend on Dojo. The heap itself
  is plain Starknet storage.
- **Access.** None in the package: the embedding contract decides who calls it.

**Weak points seen by reading** (not run; they inform the choices below, they are not ported):
the packing of a stored record gives its 64-bit fields 32-bit positions; an eviction on a full
board handles a position as if it were a key and does not refresh its record of the lowest entry
(the tests pass because their game numbers equal the positions involved); full ties have no rule;
one map serves both positions and keys; the cost of reading a rank grows with the size of the set;
and the winners cannot be read from storage, since the player is not stored.

## 2. What `quiver_leaderboard` takes, changes or leaves

| Design point | Arcade | `quiver_leaderboard` 0.1.0, from Paved's specification | Same design? |
|---|---|---|---|
| Where the code runs | A component the game embeds, internal functions | Internal code on the consumer's own storage, reached from a storage node or path; no component state needed, no external entry point | **Follows** the idea (code inside the game's contract); the mechanism differs |
| A per-leaderboard ranking keyed by an id | Yes, a free identifier | Yes: a tournament id, `u64`, any value including 0 | **Follows** |
| What a submission carries | Leaderboard, game, player, score, time | Tournament, player, game, score, time; game and time are data, never compared nor stored | **Follows** the content; not the use of time |
| Size of the top | Configurable, up to 255, a heap | Fixed at 3, kept in rank order: one word for the three scores, one slot per rank for the player (4 slots) | **Does not follow** |
| Order and ties | Score, then the earlier time | Score; an equal score never displaces (the earlier call stays above); a score of 0 never ranks | **Does not follow** |
| What a rank holds | A game | A game's result: one player may hold several ranks | **Follows** (games ranked, not players) |
| Player stored | No | Yes, so the prize claim reads the winners | **Does not follow** |
| Per-call choice event / stored | Yes | No: the top is always kept, nothing else is stored | **Does not follow** |
| Events | One per submission, through Dojo | **None** from the consumer's address; the package may offer an event type the consumer emits itself | **Does not follow** |
| Refusals | — | None on a valid game end: a score of 0, a player of 0 or a score not placed returns 0 and writes nothing | New |
| Access control | The embedding contract's | The embedding contract's: no entry point exists to guard | **Follows** |
| Dojo | World, event, store, tests | None | Native |

The bounds, the costs, the tests and Paved's acceptance tests are the brief's.
