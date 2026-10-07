# [Sonnet 5.5] ARC-05a — `quiver_leaderboard` 0.1.0

## Summary
New package `packages/leaderboard` (`quiver_leaderboard` 0.1.0), written from Paved's specification; no Arcade code. `LeaderboardStorage` is a `#[starknet::storage_node]` (`scores: Map<u64, Scores>` one packed word of three `u32`, `players: Map<(u64, u8), felt252>`): 4 slots per tournament. `submit`, `ranked` and `top` are trait methods on the node's storage path (they also work on `StorageBase`, so a consumer writes `self.leaderboard.submit(..)`). No interface, ABI item, contract or component outside tests; no event (`LeaderboardSubmitted` is offered for a consumer to emit). Nothing reverts. No loop. 78 tests, all budgeted. Pull request: see the PR.

Stop rules: neither tripped. The node is read and written from the consumer's store on Cairo 2.20, and a `2023_11` consumer (temporary package, `Scarb.toml` with `edition = "2023_11"`, a contract with `leaderboard: LeaderboardStorage`, path dependency) builds against this `2024_07` package; its ABI holds only the consumer's own two functions.

## Files changed
- `packages/leaderboard/`: `Scarb.toml`, `README.md`, `CHANGELOG.md`, `GAS.md`; `src/` (`lib`, `store` (the node and its slot accessors), `leaderboard` (the three calls), `models/{index,scores}` (the scores word, packing, rank and shift), `types/{submission,ranked,top3}`, `events/submitted`, `bench` and `testing/{mock,reference}` (test only)); `tests/{mocks,test_contract}.cairo`.
- `Scarb.lock`; `docs/BUDGETS.md` (section); `docs/WORKSPACE.md` (layout line); `AGENTS.md` (test-table row with the measured peak); `docs/reports/ARC-05a-report.md` (this report).

## Commands run
- `cd packages/leaderboard && snforge test`: 78 passed (capped `prlimit --as=8589934592 -- /usr/bin/time -v`: first full run **1,022,620 kB** maximum resident set size; the 1,000-submission benchmark alone 876,584 kB).
- `python3 scripts/gas.py packages/leaderboard --write` then `--check`.
- `.github/ci/affected.py matrix` on this change: `packages/leaderboard` is in the matrix (no `.github/` or `scripts/` edit was needed).
- Edition check: a temporary consumer package (outside the repository) with `edition = "2023_11"`, built with Scarb 2.20.1 and `RAYON_NUM_THREADS=1`.

## Cost
snforge L2 gas, benchmark minus baseline, after 10 / 100 / 1,000 prior submissions (identical): `submit` rank 1 427,420, rank 2 313,540, rank 3 198,050, not placed 47,920, score 0 or player 0 0, `top` 163,910, `ranked` 83,450 (full) / 44,530 (empty). First submissions (slots created): 1,005,030; 602,200; 599,750; rank 1 on two 829,680. Network estimates and every test's measure and budget: `packages/leaderboard/GAS.md`; summary in `docs/BUDGETS.md`. Before: — (new package).

| Operation | Before | After | Ceiling (Paved) | Note |
|---|---|---|---|---|
| `submit` placing, worst | — | 427,420 | 1.3 M | flat at 10/100/1,000 |
| `submit` not placed | — | 47,920 | 0.6 M | |
| `top` | — | 163,910 | 0.6 M | |
| `ranked` | — | 83,450 | 0.3 M | |
| first submission | — | 1,005,030 | 1.3 M | two slots created |

## Acceptance criteria
- AC-1 Every line of the specification: types and signatures as asked; key any `u64` (tests at 0, 213 503 982 334 600, `u64::MAX`); the rule and ties (table tests in `leaderboard::tests`); never reverts (score 0 / player 0 / not placed return 0); N = 3; 4 slots; no Dojo, no `u256`.
- AC-2 Paved's table test (separate tests: ties at every rank, shifts, score 0, player 0, one player on three ranks, a score equal to rank 3, ids 0 and 213 503 982 334 600) and the property test `property_sequences_match_the_reference` (100 runs of 16 steps against `src/testing/reference.cairo`, compared after each step on `top` and on every return) pass.
- AC-3 No interface, ABI item, contract or component outside tests: only `src/testing/mock.cairo` (cfg(test)) and `tests/mocks.cairo` declare contracts; `no_event_after_any_kind_of_submit` (`spy_events` empty).
- AC-4 `the_slots_hold_the_ranks`, `a_placing_submit_changes_only_the_slots_it_moves`, `an_unchanged_slot_is_not_written` (two writes fewer when the shifted players are equal), `a_submit_that_does_not_place_leaves_the_storage_unchanged` (`load` before and after), `tournaments_are_isolated`; `the_block_timestamp_changes_nothing`; the package reads no timestamp.
- AC-5 Every test has a budget; `python3 scripts/gas.py packages/leaderboard --check`; every ceiling is met and flat at 10, 100 and 1,000.
- AC-6 README, CHANGELOG, GAS.md, BUDGETS, WORKSPACE, AGENTS (peak 1,022,620 kB).
- AC-7 CI: see the pull request; the matrix includes `packages/leaderboard`.

## Deviations from the brief
- The property test is deterministic (a seeded 48-bit linear congruence, 100 runs stated), not `#[fuzzer]`: `scripts/gas.py` reads one `l2_gas` figure per test and a fuzzer prints a summary, so it would read as unmeasured. **Accepted by the orchestrator for this lot.**
- `assert_macros = "2.20.0"` in the package's `[dev-dependencies]` for `assert_eq!`.
- The benchmarks are unit tests in `src/bench.cairo`, measuring the internal call without a dispatcher (what a consumer pays); `tests/` holds the deployed-mock tests. The mock contract of the unit tests is `MockBoard` (cfg(test)); the one of `tests/` is `MockConsumer` (snforge refuses two contracts with one name).
- The reference model methods are `apply` and `board`, not `submit` and `top` (a method-name clash with the pathable impls).

## Escalations
- **Fuzzer:** `scripts/gas.py` does not parse `#[fuzzer]` results; teaching it would let the property test become a real `#[fuzzer]` (a later lot, `scripts/` being out of scope here).
- Paved's ceilings come from `cairo-profiler`, these figures are snforge's L2 gas; Paved measures its own delta at its interface PR.

## Open questions
None.
