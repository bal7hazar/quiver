# ARC-05a — `quiver_leaderboard` 0.1.0

## Agent
Profile `impl-sonnet` (the design below is complete, and an oracle checks the one tricky part; the
review is on `review-opus`, another model than the author's). Branch `feat/ARC-05a-leaderboard`;
pull request `[Sonnet 5.5] ARC-05a quiver_leaderboard 0.1.0`.

## Goal
A new package `quiver_leaderboard` 0.1.0 in `packages/leaderboard/`: Arcade's leaderboard without
Dojo, organised as `quiver_quest` 0.2.0 ([CAIRO.md](../CAIRO.md) §7), meeting the consumer's needs
below. Read first: the [mapping to Arcade](../research/ARC-05a-arcade-leaderboard-mapping.md),
CAIRO.md in full, [WORKSPACE.md](../WORKSPACE.md), [BUDGETS.md](../BUDGETS.md), and
`packages/achievement/` as the shape to copy (store, tracking, hook, errors, `GAS.md`).

## The consumer's needs
Paved (an on-chain Carcassonne), preliminary; exact figures come later from its design.

| Need | The design |
|---|---|
| 1. No Dojo; on scarbs.xyz; Scarb 2.20.1, Cairo 2.20 | Depends on `starknet` only; `snforge_std` a dev-dependency; published by version (below) |
| 2. `submit` only by contracts the consumer registers, per leaderboard id, with player, score, game id, time | Submitters registered per `(leaderboard_id, submitter)` by the admin hook; the trusted internal layer for a consumer that embeds the component |
| 3. A bounded on-chain top-N (Paved: 3) with a defined tie rule; nothing unbounded | `size` per leaderboard, 1 to `MAX_SIZE` = 16; at most 1 + 2 × 16 slots per leaderboard; the tie rule below |
| 4. Events keyed by player and leaderboard id | `LeaderboardSubmitted`, keys `leaderboard_id` and `player`, on every submission |
| 5. Per-call gas small against Paved's move (5.59M L2 gas) | Measured in `GAS.md`, each figure also as a share of 5.59M; targets below |

## Models and storage (all one felt per slot, packed by `StorePacking`)
| Model | Slot, key | Layout | Tracked |
|---|---|---|---|
| `LeaderboardDefinition { leaderboard_id, size }` | H, `leaderboard_id` | `size` [0, 8) | Yes: `LeaderboardDefined` |
| `LeaderboardRanking { leaderboard_id, len, order }` | H, shared | `len` [8, 16); `order` [16, 80): nibble `r` = the slot index of rank `r`, for `r < len`; [80, 252) reserved, rejected on unpack | No |
| `LeaderboardEntry { leaderboard_id, index, player, game_id, score, time }` | P `(leaderboard_id, index)`: `player`; S, same key: `score` [0, 64), `time` [64, 128), `game_id` [128, 192), [192, 252) reserved | | No |
| `LeaderboardSubmitter { leaderboard_id, submitter, allowed }` | `Map<(felt252, ContractAddress), bool>` | | Yes: `LeaderboardSubmitterSet` |

Storage members are prefixed `Leaderboard_`. A leaderboard is defined when `size != 0`. Types:
`leaderboard_id: felt252` (only a key, never packed: the consumer's scheme, a day number or a short
string), `player: felt252` (as Arcade's `player_id`), `score`, `time`, `game_id`: `u64`. No `u256`.

**Why an order nibble**: entering the top writes the entry's own slots and H, three writes at most
whatever `size`, instead of shifting every lower entry (two slots each). The order is updated by
arithmetic with a table of powers of 16 (CAIRO §3, rank 1), never by a loop over nibbles.

## The tie rule, and a submission
Entry A ranks above entry B when, in this order: `A.score > B.score`; equal scores and
`A.time < B.time`; equal scores and times and `A.game_id < B.game_id`. On full equality, **the entry
already on the board stays above**: a new entry never displaces an equal one.

**One place per player**: a player holds at most one entry, their best. `submit` (after its checks):
1. Emits `LeaderboardSubmitted`, always.
2. Reads H. If the board is full and the new entry does not rank above the bottom entry: returns
   `None` (H and one S read; nothing written).
3. Looks for the player among the `len` entries (P reads). Present and the new entry not above
   their own: returns `None`, nothing written. Present and above: their slot is reused (S written,
   P unchanged). Absent: the bottom's slot when full (evicted), else slot `len` (P and S written).
4. Finds the rank from the bottom (at most `len` S reads), writes H once if `len` or `order`
   changed, and returns `Some(rank)`, 0 the top.

Every loop is bounded by `size` ≤ 16, written in the doc comments and the README.

## API
- **Hooks**: `LeaderboardHooksTrait { fn authorize_admin(self: @ComponentState<T>, caller) -> bool }`.
- **Tracking**: `LeaderboardTracking { const DEFINITION: bool; const SUBMITTER: bool; }` in `store`,
  ready impls `store::tracking::{TrackAll, TrackNone}`, emitted `if Tracking::X`, as the achievement.
- **Internal, trusted** (`InternalImpl`, no caller check): `define`, `set_submitter`, `submit`,
  `assert_submitter(leaderboard_id, caller)`, and the reads of the views.
- **`ILeaderboard`** (optional to embed): `define(leaderboard_id, size)` and
  `set_submitter(leaderboard_id, submitter, allowed)`, by `authorize_admin`;
  `submit(leaderboard_id, player, game_id, score, time) -> Option<u8>`, by a registered submitter.
- **`ILeaderboardView`** (optional): `leaderboard_definition(id) -> LeaderboardDefinition`,
  `leaderboard_top(id) -> Span<LeaderboardEntry>` (rank order, `len` entries),
  `leaderboard_at(id, rank: u8) -> Option<LeaderboardEntry>`, `leaderboard_is_submitter(id, submitter) -> bool`.

**Errors** (API, in `errors.cairo`, each model naming its own): `'Leaderboard: not admin'`,
`'Leaderboard: not submitter'` (not registered for **that** leaderboard, or revoked), `'Leaderboard: invalid id'`
(0), `'Leaderboard: invalid size'` (0 or above 16), `'Leaderboard: already defined'`,
`'Leaderboard: does not exist'` (`set_submitter`, `submit`, the views but `is_submitter`),
`'Leaderboard: invalid submitter'` (address 0), `'Leaderboard: invalid player'` (0). Checks in
this order: the caller, then the leaderboard, then the arguments.

**Events**: `LeaderboardSubmitted { #[key] leaderboard_id, #[key] player, game_id, score, time }`
(action, always emitted); `LeaderboardDefined { #[key] leaderboard_id, size }` and
`LeaderboardSubmitterSet { #[key] leaderboard_id, #[key] submitter, allowed }` (tracked models).

## Tests (written first, each with a budget, CAIRO §2; unit tests in their module, D-167)
- **In modules**: H, S packing (widths, reserved bits rejected, an empty slot reads undefined); the
  tie comparison at each level; the order update (insert, move up, evict); the bounds and errors.
- **Oracle**: a plain sorted array in `src/testing/` (as `quiver_quest`'s), compared with the
  ranking after each step of a fixed sequence of at least 200 submissions (sizes 1, 3, 16; repeats,
  ties at every level, players improving and not).
- **`tests/`** (deploy a contract): every `ILeaderboard` entrypoint refusing an unauthorised caller;
  a submitter of leaderboard A refused on B; a revoked submitter refused at once; the internal
  layer unreachable unless exposed; events field by field (`spy_events`); `TrackAll` and
  `TrackNone` (an untracked write costs the write alone, to the unit); untracked models never emit.

## Gas (Linux only, `RAYON_NUM_THREADS=1`, D-176; bench minus baseline, as `quiver_achievement`)
Benchmarks: `define` (sizes 3 and 16); `set_submitter` (new, revoked, unchanged); `submit` on boards
of sizes 3 and 16 after **10, 100 and 1,000** submissions to one leaderboard: rejected below the
bottom, entering at the bottom and at the top, a present player improving and not, and the
first entries (created slots); `leaderboard_top` and `leaderboard_at` at sizes 3 and 16. Each
figure in `GAS.md` with its network estimate, its share of the 20M cap and of Paved's 5.59M move.
**Targets**: a `submit` on a full board of 3 at most 10 % of the move (559 000); its cost the same,
to noise, after 10, 100 and 1,000 submissions (bounded storage). A target missed is reported, not
hidden. **Memory first**: the package's first `snforge test`, and the 1,000-submission benchmark,
under `prlimit --as=8589934592 -- /usr/bin/time -v …`; the peak goes in `AGENTS.md`; above ~8 GB,
stop and report (the Mac). If 1,000 real submissions in one test is too slow or too large, write
the equivalent full board with `snforge_std::store` and say so.

## Scope and allowlist
**In**: `packages/leaderboard/**` (`Scarb.toml` `quiver_leaderboard` 0.1.0, `README.md` with the
layout, the tie rule, the bounds, access control and the integration budget; `CHANGELOG.md`
`[Unreleased]`; `GAS.md`; `src/`; `tests/`); `Scarb.lock`; a `quiver_leaderboard` section of
`docs/BUDGETS.md`; the layout line of `docs/WORKSPACE.md` §1; the row of `AGENTS.md`'s test table.
**Out**: any other package; `.github/` and `scripts/`: the CI and the pre-push find the package
through `scarb metadata` (`members = ["packages/*"]`, WORKSPACE §2), so `affected.py` and the matrix
need no change; show it with the PR's CI (a `packages/leaderboard` job). Publishing (never by a thread).

## Acceptance criteria
- [ ] AC-1 Needs 1 to 5 met as the table says; no Dojo, no `u256`, no unbounded storage.
- [ ] AC-2 The tie rule and one place per player, checked against the oracle.
- [ ] AC-3 Every refusal of the error list tested, by entrypoint; submitters scoped per leaderboard.
- [ ] AC-4 §7 layers; tracking optional at compile time, measured to the unit.
- [ ] AC-5 Every test budgeted; `python3 scripts/gas.py packages/leaderboard --check` passes; the
      gas table with network estimates, cap and move shares; targets met or reported.
- [ ] AC-6 README, CHANGELOG, GAS.md, BUDGETS, WORKSPACE and AGENTS (measured peak) written.
- [ ] AC-7 CI green, with a `packages/leaderboard` job.

## Verification
`cd packages/leaderboard && snforge test` (through `scripts/lock.sh snforge test` on the VPS),
`python3 scripts/gas.py packages/leaderboard --check`,
`scarb --manifest-path packages/leaderboard/Scarb.toml fmt --check`, `python3 .github/ci/check-links.py`,
then `scripts/prepush.sh` (the hook). CI at most once per 5 minutes.

## After the lot
Review on `review-opus`, then a **security-lens audit of the access control** (`audit`, Opus;
D-177: access control on a published interface): `define`, `set_submitter`, `submit`, the internal
layer, the per-leaderboard scope. Then the orchestrator commits
`docs/decisions/PENDING-publish-quiver_leaderboard-0.1.0.md` (commit, archive sha256 from two clean
clones, what the consumer must do: Scarb 2.20) and sends it through the project manager: **the go
is the owner's**, not delegated. Tag `quiver_leaderboard-v0.1.0` after the publication.

## To the project manager (before the design is cut)
1. **One place per player** (decided, the brief's rule): Arcade ranks games, so one player could
   hold several prizes. Reversed if Paved wants games ranked: a flag in `define`, no new slot.
2. **Who submits**: if Paved embeds the component, no registration (trusted internal layer). If it
   uses a separate leaderboard contract, each daily leaderboard costs a `define` and a
   `set_submitter`, two created slots a day (estimate ~0.95M on snforge). Which one?
3. **No window or closing**: `submit` takes the consumer's `time` and the board stays open; the
   game refuses late submissions. If Paved wants the board frozen on-chain at the day's end, a
   `close` is one bit of H: ask now, it changes the API.
4. **Widths**: `score`, `time`, `game_id` as `u64`, `player` as `felt252`. Widening after 0.1.0 is
   breaking; Paved's exact figures should confirm them before the lot starts.
