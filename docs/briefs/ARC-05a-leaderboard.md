# ARC-05a — `quiver_leaderboard` 0.1.0

## Held: the owner's licence answer
**This lot does not start until the owner answers on the licence.** Arcade's licence is "all rights
reserved", non-commercial use only. The design below is written **from Paved's specification**; it
shares some design ideas with Arcade's leaderboard, named in the
[mapping](../research/ARC-05a-arcade-leaderboard-mapping.md). The lot **may not copy or port Arcade
code**, nor read it as a model to transcribe, unless the owner's answer allows it. The package
declares the workspace's licence (MIT, compatible with Paved's Apache-2.0).

## Agent
Profile `impl-sonnet`: the design is complete, and the tests are Paved's own. Branch
`feat/ARC-05a-leaderboard`; pull request `[Sonnet 5.5] ARC-05a quiver_leaderboard 0.1.0`. Read
first: this brief, [COMMON.md](COMMON.md), [CAIRO.md](../CAIRO.md) in full,
[WORKSPACE.md](../WORKSPACE.md), [BUDGETS.md](../BUDGETS.md), `packages/achievement/` for the shape
of a package (models, store, errors, `GAS.md`, budgets).

## Paved's specification
Paved (an on-chain Carcassonne) replaces its own `Tournament::score` with this package once a
version is published and its measures beat today's. Its request (2026-10-07) is the specification;
every line is met by the design:

| Paved asks | The design |
|---|---|
| Internal code on the contract's own storage, from a storage node or path; no entry point in the consumer's ABI | A `#[starknet::storage_node]` the consumer places in its storage; the functions are trait methods on its storage path. The package has no `#[starknet::interface]`, no `#[abi]`, no contract, no component outside its tests |
| `submit(tournament_id: u64, Submission) -> u8`, `ranked(tournament_id, rank: u8) -> Ranked`, `top(tournament_id) -> Top3` | Exactly these, with Paved's types (below) |
| Key: any `u64`, 0 and 213 503 982 334 600 included | A map key, never packed nor checked |
| Higher score ranks higher; an equal score never displaces (earlier call stays above); a placed submission shifts lower ranks down; score 0 never ranks; games ranked, not players; `time` and `game_id` data only, never compared; no block timestamp read | The rule below |
| Never reverts on a valid game end: score 0, player 0, or not placed → returns 0, writes nothing | No refusal exists in the package |
| N = 3; nothing below rank 3 stored; a larger N must not cost more at N = 3 | N fixed at 3 in 0.1.0 (`Top3`); no loop over N |
| Only the game contract submits | By construction: no entry point; the consumer's own entrypoints call it |
| Ceilings: `submit` placing ≤ 1.3M (rank 1, two shifted), not placing ≤ 0.6M; `top` ≤ 0.6M; `ranked` ≤ 0.3M; none depending on the number of submissions | Constant reads and writes per call (below); measured at 10, 100 and 1,000 prior submissions |
| 4 slots per tournament (player and score), 6 at most; a submit writes only the slots that changed | **4 slots**: one word of three scores, one player slot per rank; a slot whose value is unchanged is not written |
| No event from the consumer's address, or behind a switch off by default | **The package emits nothing.** It may offer an event type the consumer emits itself |
| Scarb 2.20.1, snforge 0.64.0, `starknet` 2.20.x; `snforge_std` in dev-dependencies only | The workspace's toolchain |
| Published version on scarbs.xyz, pinned (O-1) | Published as 0.1.0 (below); a breaking release announced to the project manager first |

## Types and storage
`Submission { player_id: felt252, game_id: u32, score: u32, time: u64 }`;
`Ranked { player_id: felt252, score: u32 }` (zero player and zero score: an empty rank);
`Top3 { first: Ranked, second: Ranked, third: Ranked }`.

`LeaderboardStorage`, a storage node with two members: `scores: Map<u64, ScoresSlot>`, the three
scores of a tournament in one felt, rank 1 at [0, 32), rank 2 at [32, 64), rank 3 at [64, 96),
[96, 252) zero; and `players: Map<(u64, u8), felt252>`, the player of rank 1, 2 or 3. A model per
CAIRO §7 (`models/`: the ranking of a tournament; `types/`: the three structs; a store with the
reads and writes; packing by `StorePacking`), the store being implemented on the node's storage
path instead of a component state: say so in the README.

## The rule, exactly
`submit(t, s)`:
1. `s.score == 0` or `s.player_id == 0`: return 0; nothing read, nothing written.
2. Read the scores word `(s1, s2, s3)` (an empty rank reads 0). `s.score <= s3`: return 0.
3. The rank: 1 if `s.score > s1`, else 2 if `s.score > s2`, else 3 (an equal score goes below).
4. Shift the lower ranks down by one (rank 3's entry, if displaced, is dropped), write the new
   scores word once (arithmetic shifts, CAIRO §3), write each player slot **only if its value
   changes** (a player shifted onto a slot holding the same player is not written), return the rank.

`ranked(t, r)`: `r` outside 1..=3 → empty `Ranked`; else the score from the word and the player
(the player slot not read when the score is 0). `top(t)`: one read of the word, and the player of
each non-empty rank. Worst case: `submit` at rank 1 on a full board, 3 reads (word, players 1 and 2)
and 4 writes; not placed, 1 read; `top` 4 reads; `ranked` 2 reads. No loop depends on the number of
submissions; every loop is bounded by 3 and written in the doc comments and the README.

## Events
None emitted. The package offers `LeaderboardSubmitted { #[key] tournament_id: u64, #[key]
player_id: felt252, game_id: u32, score: u32, time: u64, rank: u8 }` for a consumer that wants to
emit one itself, from its own contract; its README says Paved's indexer does not read it.

## Tests (written first, each with a budget; unit tests in their module, D-167)
- **Paved's acceptance tests, reproduced** in the package: a **table test** of the rule (ties at
  every rank, shifts, score 0, player 0, a player on all three ranks, a score equal to rank 3,
  tournament ids 0 and 213 503 982 334 600); a **property test** (`#[fuzzer]`, runs stated) of
  sequences of submissions against a **reference model** in `src/testing/`, a plain list of three
  that applies the rule as written above, compared after each step on `top` and on every return.
- **In modules**: the scores word's packing and shifts; `ranked` outside 1..=3.
- **`tests/`** (a mock contract holding the node in its storage, with test-only wrappers): the
  calls through a storage path; no event emitted (`spy_events` empty) after every kind of submit;
  submits not placed leave storage unchanged (`load` before and after); a placing submit writes only
  the changed slots (`load`, and the gas difference between rank 1, 2 and 3); tournaments isolated.
- **Edition**: Paved builds with edition `2023_11`; quiver's packages use `2024_07`. A dependency
  keeps its own edition; if the lot finds otherwise, it stops and reports.

## Gas (Linux only, `RAYON_NUM_THREADS=1`, D-176; bench minus baseline, as `quiver_achievement`)
Each operation is measured **after 10, 100 and 1,000 prior submissions** to one tournament, to show
it is flat: `submit` at rank 1 with two shifted (worst), at ranks 2 and 3, not placed (below rank 3;
equal to rank 3), score 0, player 0, and the first submissions of a tournament (created slots,
measured apart and named); `top`; `ranked` (empty and full rank). `GAS.md` gives each figure against
Paved's ceiling, the 20M cap, and with its network estimate. A ceiling missed is reported under
Escalations, not hidden. **Memory first**: the first `snforge test` of the package and the
1,000-submission benchmark run under `prlimit --as=8589934592 -- /usr/bin/time -v …`; the peak goes in
`AGENTS.md`; above ~8 GB, stop and report. If 1,000 real submissions in one test is too slow, write the
same board with `snforge_std::store` and say so.

## Scope and allowlist
**In**: `packages/leaderboard/**` (`Scarb.toml` `quiver_leaderboard` 0.1.0, `README.md` with the
storage node usage, the rule, the bounds, the costs and "no entry point, no event"; `CHANGELOG.md`;
`GAS.md`; `src/`; `tests/`); `Scarb.lock`; a `quiver_leaderboard` section of `docs/BUDGETS.md`; the
layout line of `docs/WORKSPACE.md` §1; the row of `AGENTS.md`'s test table. **Out**: other packages,
`.github/`, `scripts/` (the CI and the pre-push find the package through `scarb metadata`,
WORKSPACE §2; the PR's CI shows a `packages/leaderboard` job); Arcade's code; publishing.

## Acceptance criteria
- [ ] AC-1 Every line of Paved's specification met as the table says; no Dojo, no `u256`.
- [ ] AC-2 Paved's table test and property test pass in the package.
- [ ] AC-3 No entry point and no event: no interface, ABI item, contract or component outside tests;
      `spy_events` empty.
- [ ] AC-4 4 slots per tournament; unchanged slots not written; no read of the block timestamp.
- [ ] AC-5 Every test budgeted; `python3 scripts/gas.py packages/leaderboard --check` passes; every
      ceiling met and flat at 10, 100, 1,000, or reported.
- [ ] AC-6 README, CHANGELOG, GAS.md, BUDGETS, WORKSPACE, AGENTS (measured peak) written.
- [ ] AC-7 CI green, with a `packages/leaderboard` job.

## Verification
`cd packages/leaderboard && snforge test` (through `scripts/lock.sh snforge test` on the VPS),
`python3 scripts/gas.py packages/leaderboard --check`,
`scarb --manifest-path packages/leaderboard/Scarb.toml fmt --check`, `python3 .github/ci/check-links.py`,
then `scripts/prepush.sh` (the hook). CI at most once per 5 minutes.

## After the lot
**Review on `review-opus`; no audit.** The package has no entry point: its access control is the
consumer's. A security-lens audit (D-177) comes back only if a later design adds a separate contract
(a `register_game` and a guarded `submit`). Then the orchestrator commits
`docs/decisions/PENDING-publish-quiver_leaderboard-0.1.0.md` (commit, archive sha256 from two clean
clones, Scarb 2.20) and sends it through the project manager: **the go is the owner's**, not delegated.

## To the project manager
1. **Licence (the owner's)**: the lot is held. Paved also asks that Arcade's licence and headers be
   named for ported code; Arcade's is non-commercial, so a port could not be published under MIT or
   Apache-2.0. Recommended: a clean implementation from Paved's specification, nothing ported.
2. **Storage node**: the design assumes Cairo 2.20 lets trait methods on a node's storage path read
   and write its maps from the consumer's `Store`. If the lot finds it cannot, it stops; the fallback
   is a component, which costs Paved a signature change at its three call sites.
3. **Ceilings**: Paved's figures come from `cairo-profiler`; the package measures snforge L2 gas.
   Paved measures its own delta at its interface PR; the package's `GAS.md` is the reference on its side.
4. **Dropped from the preliminary brief**: submitters registered per leaderboard, one place per
   player, a configurable N, ties by time, events by default. A separate contract, if ever wanted, is a
   new lot with its audit.
