# [Opus 5.5] ARC-03b — `quiver_quest`: the Starknet component

## Summary

`quiver_quest` now has its component. This session ran on Opus 5.5 (`claude-opus-5-5`), the
model the brief names.

- `quiver_quest::component::QuestComponent`. It has the storage of ARC-01 §3.3 (the `Quest_*`
  members, one felt per value), the six events of §3.4 with their keys, and the hook trait
  `QuestHooksTrait`. The trusted internal layer is `InternalImpl`: `define`, `retire`,
  `set_reporter`, `progress`, `progress_many`, `accept`, `abandon`, `claim`, `assert_reporter`,
  and the reads `definition`, `progress_of`, `record_of`, `current_interval`, `is_unlocked`,
  `is_accepted`. The external impls are `QuestImpl` (access-checked as §3.6 says) and
  `QuestViewImpl`, and a consumer can embed either one on its own.
- `quiver_quest::interface::{IQuest, IQuestView}` and their dispatchers.
- The algorithms of §3.5 (`progress_many`, `accept`, `retire`, `define`) follow the spec step by
  step and use the ARC-03a library unchanged. For every entrypoint, **the measured storage reads
  and writes equal the §5.1 estimates exactly**, counted with syscall counters (see Cost).
- 126 new tests use three mock consumers in `tests/mocks.cairo`:
  - `MockQuest` embeds `QuestImpl` and `QuestViewImpl`, and its hooks log what they see.
  - `MockConsumer` embeds only the views and calls the internal layer from its own entrypoints,
    as §3.8 does.
  - `MockBench` has hooks that do nothing, so the benchmarks measure the component alone.
- There is one benchmark per entrypoint on the worst case of §5.1. Each has a baseline that runs
  the same setup without the call.
- `GAS.md` is regenerated (292 tests) and `docs/BUDGETS.md` is created. The README and CHANGELOG
  are ready for 0.1.0, which is not released.

Pull request: https://github.com/bal7hazar/quiver/pull/7. CI is green: `cairo`,
`package (packages/quest)`, `affected`, `links` and `scripts` all pass.

## Files changed

- `packages/quest/src/component.cairo`: new. `QuestComponent`: storage, events, hooks trait, `InternalImpl`, private helpers, `QuestImpl`, `QuestViewImpl`.
- `packages/quest/src/interface.cairo`: new. `IQuest` and `IQuestView`.
- `packages/quest/src/lib.cairo`: declares `component` and `interface`.
- `packages/quest/tests/mocks.cairo`: new. `MockQuest`, `MockConsumer`, `MockBench`, `HookCall`, `IMockQuest`, `IMockConsumer`.
- `packages/quest/tests/setup.cairo`: new. Deployment, actors, cheat helpers, `assert_error`.
- `packages/quest/tests/test_component_event_mode.cairo`: new, 6 tests (D-1).
- `packages/quest/tests/test_component_prerequisites.cairo`: new, 12 tests (D-2 to D-6).
- `packages/quest/tests/test_component_progress.cairo`: new, 19 tests (storage progress, batches, intervals).
- `packages/quest/tests/test_component_accept.cairo`: new, 12 tests (accept, abandon, rollover).
- `packages/quest/tests/test_component_claim.cairo`: new, 8 tests (claims, hooks).
- `packages/quest/tests/test_component_define.cairo`: new, 11 tests (D-7, D-8, pages, dependents).
- `packages/quest/tests/test_component_retire.cairo`: new, 13 tests (retirement, pages read from storage).
- `packages/quest/tests/test_component_access.cairo`: new, 14 tests (D-13, AC-3, the internal layer).
- `packages/quest/tests/test_component_events.cairo`: new, 3 tests (events felt by felt, views).
- `packages/quest/tests/test_component_bench.cairo`: new, 28 tests (benchmarks and baselines).
- `packages/quest/GAS.md`: regenerated. 292 tests; the 166 library rows are unchanged except the commit column.
- `packages/quest/README.md`: rewritten for 0.1.0.
- `packages/quest/CHANGELOG.md`: a `## [0.1.0] - not yet released` section listing the API; `## [Unreleased]` is empty.
- `docs/BUDGETS.md`: new. Per entrypoint: measured value, budget, the call's cost, reads and writes, the §5.1 estimate, date and commit. It also lists the library's main algorithms.

## Commands run

```
$ scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build
   Compiling quiver_quest v0.1.0 (…/packages/quest/Scarb.toml)
    Finished `dev` profile target(s) in 1 second

$ cd packages/quest && snforge test
Tests: 292 passed, 0 failed, 0 ignored, 0 filtered out
(snforge also prints `warn: external contracts not found for selectors: quiver_quest::*` while it
compiles. It is harmless: the mocks in tests/ are declared and deployed.)

$ scripts/gas.py packages/quest --write
quiver_quest: wrote packages/quest/GAS.md (292 tests)
$ scripts/gas.py packages/quest --check
quiver_quest: 292 tests within budget, GAS.md up to date

$ scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check   → exit 0
$ python3 .github/ci/check-links.py
check-links: 0 broken link(s)

$ cd packages/quest && snforge test test_component_bench --detailed-resources   (excerpt)
bench_progress_worst         syscalls: (StorageRead: 686, StorageWrite: 400, EmitEvent: 71, …)
baseline_progress_worst      syscalls: (StorageRead: 345, StorageWrite: 344, EmitEvent: 43, …)
quest_batch_bound_accepted   syscalls: (StorageRead: 10197, StorageWrite: 5860, EmitEvent: 911, …)
baseline_batch_bound_accepted syscalls: (StorageWrite: 4964, StorageRead: 4755, EmitEvent: 463, …)
bench_retire_worst           syscalls: (StorageRead: 371, StorageWrite: 306, …)
baseline_retire_worst        syscalls: (StorageRead: 349, StorageWrite: 292, …)
bench_define_worst           syscalls: (StorageRead: 349, StorageWrite: 292, …)
baseline_define_worst        syscalls: (StorageRead: 329, StorageWrite: 279, …)
bench_accept_worst           syscalls: (StorageRead: 72, StorageWrite: 50, …)
baseline_prerequisites       syscalls: (StorageRead: 61, StorageWrite: 49, …)

$ cd packages/quest && snforge test batch_two_tasks --detailed-resources   (excerpt)
quest_batch_two_tasks_one_quest_one_write_not_completing  (StorageRead: 13, StorageWrite: 9, …)
baseline_batch_two_tasks_one_quest_not_completing        (StorageWrite: 8, StorageRead: 6, …)
quest_batch_two_tasks_one_quest_one_write                (StorageRead: 19, StorageWrite: 18, …)
baseline_batch_two_tasks_one_quest                       (StorageWrite: 8, StorageRead: 7, …)

$ gh pr checks 7 --watch --interval 30
affected pass · cairo pass · links pass · package (packages/quest) pass (56s) · scripts pass
```

The 166 rows of the library in `GAS.md` compared with ARC-03a (`git diff --word-diff 40b21e2`):
the only change is the commit column, `df0a781` → `2982130`, in all 166 rows.

## Cost

### Per entrypoint, worst case of §5.1 beside the measure

**Call** is the benchmark minus its baseline, in L2 gas, through a dispatcher. **Reads/writes**
are the storage syscalls of the call, the same difference taken with `--detailed-resources`.
The reporter check of `progress` and `progress_many` is 1 more read and is not counted here.

| Entrypoint | Worst case | Test measured | Budget | Call | Reads / writes measured | §5.1 estimate |
|---|---|---|---|---|---|---|
| `progress`, event mode | 1 entry | 1 001 736 | 1 051 823 | 211 236 | 0 / 0, 1 event | 0 / 0, 1 event |
| `progress_many`, event mode | 16 distinct entries | 2 053 886 | 2 156 581 | 1 263 386 | 0 / 0, 16 events | 0 / 0, E events |
| `progress` | 1 task, 28 live quests, each K = 7 first observed, all completing | 144 700 398 | 151 935 418 | 43 267 006 | **340 / 56**, 28 events | **340 / 56**, 28, 28 hooks |
| `progress_many` | 16 tasks × 28 quests (448 distinct), K = 7 first observed, all completing (`quest_batch_bound_accepted`) | 1 995 551 098 | 2 095 328 653 | 704 333 046 | **5 440 / 896**, 448 events | **5 440 / 896**, 448, 448 hooks |
| `progress` | one-off, 1 task, not completing | 3 389 826 | 3 559 318 | 857 516 | 4 / 1 | 4 / 1 |
| `progress` | same, completing | 3 938 166 | 4 135 075 | 1 405 856 | 5 / 2, 1 event | 5 / 2, 1 |
| `progress` | accepted quest, not completing | 28 153 088 | 29 560 743 | 914 366 | 5 / 1 | 5 / 1 |
| `progress_many` | 2 tasks of one quest, not completing | 6 274 042 | 6 587 745 | 1 149 452 | 6 / **1** | 6 / 1 |
| `progress_many` | same, completing | 10 335 732 | 10 852 519 | — (the logging hook is in it) | 7 / **2** for the component | 7 / 2 |
| `accept` | K = 7 met, not cached | 27 238 722 | 28 600 659 | 1 071 170 | **11 / 1** | 3 to 11 / 1 |
| `abandon` | — | 27 507 682 | 28 883 067 | 268 960 | 2 / 1 | 2 / 1 |
| `claim` | — | 4 307 466 | 4 522 840 | 369 300 | 2 / 2, 1 event | 2 / 2, 1, 1 hook |
| `retire` | 3 tasks × 28 live quests (hole on page 0, last on page 3), K = 7 | 146 581 142 | 153 910 200 | 2 145 780 | **22 / 14** | ≤ 22 / ≤ 14 |
| `define` | 3 tasks × 27 live quests (4 pages each), K = 7 | 144 437 282 | 151 659 147 | 3 408 480 | 20 / 13 | K A + pages; A, B, C, 3 pages, K A (no total given) |
| `set_reporter` | — | 1 398 910 | 1 468 856 | 608 410 | 0 / 1 | — |
| `quest_is_unlocked` | K = 7, not cached | 26 706 862 | 28 042 206 | 539 310 | 10 / 0 | (A + R + C + K) |
| `quest_definition` | 3 tasks, 7 conditions | 26 475 632 | 27 799 414 | 308 080 | 3 / 0 | — |
| `quest_is_accepted` | — | 26 368 502 | 27 686 928 | 200 950 | 2 / 0 | — |
| `quest_current_interval` | — | 26 330 162 | 27 646 671 | 162 610 | 1 / 0 | — |
| `quest_progress` + `quest_record` | two calls | 26 462 812 | 27 785 953 | 295 260 | 2 / 0 | — |
| `quest_is_reporter` | — | 26 292 242 | 27 606 855 | 124 690 | 1 / 0 | — |

The benchmark of the completing two-task batch uses `MockQuest`. Its logging hook adds 3 reads
and 8 writes (a 7-slot `HookCall` and the counter), and the test makes one more view call. That
leaves 7 reads and 2 writes (P and R) for the component.

### Every test the lot touched

All 126 tests are new, so "Before" is "—". The 166 library tests are unchanged, re-measured with
the same figures.

| Test (`quiver_quest_integrationtest::…`) | Before | After (measured) | Budget | Note |
|---|---|---|---|---|
| `test_component_accept::quest_abandon_expired_reverts` | — | 5877080 | 6170934 | new |
| `test_component_accept::quest_abandon_keeps_counts` | — | 9216108 | 9676914 | new |
| `test_component_accept::quest_abandon_refusals` | — | 6872920 | 7216566 | new |
| `test_component_accept::quest_accept_after_completion_reverts` | — | 10341526 | 10858603 | new |
| `test_component_accept::quest_accept_after_daily_completion` | — | 11116076 | 11671880 | new |
| `test_component_accept::quest_accept_caches_unlock` | — | 14130652 | 14837185 | new |
| `test_component_accept::quest_accept_refusals` | — | 9930890 | 10427435 | new |
| `test_component_accept::quest_accept_required` | — | 7477262 | 7851126 | new |
| `test_component_accept::quest_accept_twice_same_interval_reverts` | — | 5806530 | 6096857 | new |
| `test_component_accept::quest_acceptance_expires_at_rollover` | — | 9401458 | 9871531 | new |
| `test_component_accept::quest_completion_releases_acceptance` | — | 10227016 | 10738367 | new |
| `test_component_accept::quest_is_accepted_false_outside_schedule` | — | 5991790 | 6291380 | new |
| `test_component_access::quest_abandon_requires_player_authorization` | — | 5926210 | 6222521 | new |
| `test_component_access::quest_accept_requires_player_authorization` | — | 5113630 | 5369312 | new |
| `test_component_access::quest_claim_requires_player_authorization` | — | 14578416 | 15307337 | new |
| `test_component_access::quest_consumer_calls_the_internal_layer` | — | 5963866 | 6262060 | new |
| `test_component_access::quest_define_admin_only` | — | 2987810 | 3137201 | new |
| `test_component_access::quest_internal_layer_not_reachable_from_abi` | — | 2021290 | 2122355 | new |
| `test_component_access::quest_player_authorization_is_per_player` | — | 4913700 | 5159385 | new |
| `test_component_access::quest_progress_accepts_registered_reporter` | — | 7015892 | 7366687 | new |
| `test_component_access::quest_progress_many_rejects_unregistered_caller` | — | 2846730 | 2989067 | new |
| `test_component_access::quest_progress_rejects_unregistered_caller` | — | 5314330 | 5580047 | new |
| `test_component_access::quest_reporter_revoked` | — | 4853500 | 5096175 | new |
| `test_component_access::quest_retire_admin_only` | — | 5611150 | 5891708 | new |
| `test_component_access::quest_set_reporter_admin_only` | — | 2970450 | 3118973 | new |
| `test_component_access::quest_set_reporter_event_keys` | — | 2940840 | 3087882 | new |
| `test_component_bench::baseline_accepted` | — | 27238722 | 28600659 | new, baseline |
| `test_component_bench::baseline_batch_bound_accepted` | — | 1291218052 | 1355778955 | new, baseline |
| `test_component_bench::baseline_completed` | — | 3938166 | 4135075 | new, baseline |
| `test_component_bench::baseline_define_worst` | — | 141028802 | 148080243 | new, baseline |
| `test_component_bench::baseline_deployed` | — | 790500 | 830025 | new, baseline |
| `test_component_bench::baseline_plain` | — | 2532310 | 2658926 | new, baseline |
| `test_component_bench::baseline_prerequisites` | — | 26167552 | 27475930 | new, baseline |
| `test_component_bench::baseline_progress_worst` | — | 101433392 | 106505062 | new, baseline |
| `test_component_bench::baseline_retire_worst` | — | 144435362 | 151657131 | new, baseline |
| `test_component_bench::bench_abandon` | — | 27507682 | 28883067 | new, benchmark |
| `test_component_bench::bench_accept_worst` | — | 27238722 | 28600659 | new, benchmark |
| `test_component_bench::bench_claim` | — | 4307466 | 4522840 | new, benchmark |
| `test_component_bench::bench_define_worst` | — | 144437282 | 151659147 | new, benchmark |
| `test_component_bench::bench_progress_accepted` | — | 28153088 | 29560743 | new, benchmark |
| `test_component_bench::bench_progress_event_mode` | — | 1001736 | 1051823 | new, benchmark |
| `test_component_bench::bench_progress_many_event_mode_worst` | — | 2053886 | 2156581 | new, benchmark |
| `test_component_bench::bench_progress_plain` | — | 3389826 | 3559318 | new, benchmark |
| `test_component_bench::bench_progress_plain_completing` | — | 3938166 | 4135075 | new, benchmark |
| `test_component_bench::bench_progress_worst` | — | 144700398 | 151935418 | new, benchmark |
| `test_component_bench::bench_retire_worst` | — | 146581142 | 153910200 | new, benchmark |
| `test_component_bench::bench_set_reporter` | — | 1398910 | 1468856 | new, benchmark |
| `test_component_bench::bench_view_current_interval` | — | 26330162 | 27646671 | new, benchmark |
| `test_component_bench::bench_view_definition_worst` | — | 26475632 | 27799414 | new, benchmark |
| `test_component_bench::bench_view_is_accepted` | — | 26368502 | 27686928 | new, benchmark |
| `test_component_bench::bench_view_is_reporter` | — | 26292242 | 27606855 | new, benchmark |
| `test_component_bench::bench_view_is_unlocked_worst` | — | 26706862 | 28042206 | new, benchmark |
| `test_component_bench::bench_view_progress_and_record` | — | 26462812 | 27785953 | new, benchmark |
| `test_component_bench::quest_batch_bound_accepted` | — | 1995551098 | 2095328653 | new, benchmark |
| `test_component_claim::quest_claim_emits_and_writes` | — | 12744566 | 13381795 | new |
| `test_component_claim::quest_claim_hook_after_state_written` | — | 12732406 | 13369027 | new |
| `test_component_claim::quest_claim_hook_panic_reverts_claim` | — | 11032666 | 11584300 | new |
| `test_component_claim::quest_claim_index_counts_claims` | — | 21609302 | 22689768 | new |
| `test_component_claim::quest_claim_twice_reverts` | — | 13002456 | 13652579 | new |
| `test_component_claim::quest_claim_uncompleted_reverts` | — | 6569306 | 6897772 | new |
| `test_component_claim::quest_complete_hook_after_state_written` | — | 9674716 | 10158452 | new |
| `test_component_claim::quest_complete_hook_panic_reverts_progress` | — | 8036676 | 8438510 | new |
| `test_component_define::quest_define_counts_dependents` | — | 9640250 | 10122263 | new |
| `test_component_define::quest_define_rejects_association_overflow` | — | 50352270 | 52869884 | new |
| `test_component_define::quest_define_rejects_duplicate_condition` | — | 4927780 | 5174169 | new |
| `test_component_define::quest_define_rejects_invalid_input` | — | 3921080 | 4117134 | new |
| `test_component_define::quest_define_rejects_retired_condition` | — | 5168000 | 5426400 | new |
| `test_component_define::quest_define_rejects_self_condition` | — | 2995740 | 3145527 | new |
| `test_component_define::quest_define_rejects_too_many_conditions` | — | 15999160 | 16799118 | new |
| `test_component_define::quest_define_rejects_undefined_condition` | — | 3049990 | 3202490 | new |
| `test_component_define::quest_define_stores_and_emits` | — | 8062170 | 8465279 | new |
| `test_component_define::quest_define_twice_reverts` | — | 4911680 | 5157264 | new |
| `test_component_define::quest_empty_slot_reads_undefined` | — | 2745300 | 2882565 | new |
| `test_component_event_mode::quest_batch_event_mode_one_event_per_task` | — | 5237059 | 5498912 | new |
| `test_component_event_mode::quest_event_mode_calls_no_hook` | — | 4944936 | 5192183 | new |
| `test_component_event_mode::quest_event_mode_cannot_be_claimed` | — | 5434686 | 5706421 | new |
| `test_component_event_mode::quest_event_mode_emits_only_progressed` | — | 5179696 | 5438681 | new |
| `test_component_event_mode::quest_event_mode_zero_count_emits_nothing` | — | 3165198 | 3323458 | new |
| `test_component_event_mode::quest_modes_do_not_mix` | — | 5959392 | 6257362 | new |
| `test_component_events::quest_accept_and_abandon_emit_nothing` | — | 5386190 | 5655500 | new |
| `test_component_events::quest_current_interval_view` | — | 5525770 | 5802059 | new |
| `test_component_events::quest_events_keys_and_data` | — | 16076532 | 16880359 | new |
| `test_component_prerequisites::quest_dependent_unlocks_when_window_opens` | — | 14323228 | 15039390 | new |
| `test_component_prerequisites::quest_inactive_dependent_does_not_revert` | — | 12385266 | 13004530 | new |
| `test_component_prerequisites::quest_is_unlocked_evaluates_uncached` | — | 12218106 | 12829012 | new |
| `test_component_prerequisites::quest_prerequisite_completed_before_definition` | — | 13548762 | 14226201 | new |
| `test_component_prerequisites::quest_prerequisites_all_required` | — | 15326672 | 16093006 | new |
| `test_component_prerequisites::quest_prerequisites_unlock_after_last` | — | 20565698 | 21593983 | new |
| `test_component_prerequisites::quest_recurring_dependent_stays_unlocked` | — | 21908278 | 23003692 | new |
| `test_component_prerequisites::quest_recurring_prerequisite_after_dependent_completed` | — | 21425388 | 22496658 | new |
| `test_component_prerequisites::quest_recurring_prerequisite_completed_before_definition` | — | 13623772 | 14304961 | new |
| `test_component_prerequisites::quest_recurring_prerequisite_completes_every_interval` | — | 21535638 | 22612420 | new |
| `test_component_prerequisites::quest_unlock_cached_by_progress` | — | 14600198 | 15330208 | new |
| `test_component_prerequisites::quest_without_conditions_is_unlocked` | — | 4582270 | 4811384 | new |
| `test_component_progress::baseline_batch_two_tasks_one_quest` | — | 5249830 | 5512322 | new, baseline |
| `test_component_progress::baseline_batch_two_tasks_one_quest_not_completing` | — | 5124590 | 5380820 | new, baseline |
| `test_component_progress::quest_batch_above_bound_reverts` | — | 3234920 | 3396666 | new |
| `test_component_progress::quest_batch_duplicate_entries_merged` | — | 5631479 | 5913053 | new |
| `test_component_progress::quest_batch_duplicates_count_toward_bound` | — | 2974000 | 3122700 | new |
| `test_component_progress::quest_batch_quest_on_two_entries_handled_once` | — | 8561682 | 8989767 | new |
| `test_component_progress::quest_batch_rejects_task_zero` | — | 3028982 | 3180432 | new |
| `test_component_progress::quest_batch_two_tasks_one_quest_one_write` | — | 10335732 | 10852519 | new |
| `test_component_progress::quest_batch_two_tasks_one_quest_one_write_not_completing` | — | 6274042 | 6587745 | new |
| `test_component_progress::quest_count_max_value` | — | 10128982 | 10635432 | new |
| `test_component_progress::quest_count_saturates_at_total` | — | 10217372 | 10728241 | new |
| `test_component_progress::quest_daily_interval_aligned_on_utc_midnight` | — | 7231942 | 7593540 | new |
| `test_component_progress::quest_daily_rollover_starts_from_zero` | — | 7055092 | 7407847 | new |
| `test_component_progress::quest_inactive_quest_skipped_not_reverted` | — | 7424536 | 7795763 | new |
| `test_component_progress::quest_interval_id_is_u64` | — | 5834076 | 6125780 | new |
| `test_component_progress::quest_one_off_completes_once` | — | 10104682 | 10609917 | new |
| `test_component_progress::quest_progress_is_per_player` | — | 5744856 | 6032099 | new |
| `test_component_progress::quest_recurring_completes_each_interval` | — | 20189524 | 21199001 | new |
| `test_component_progress::quest_task_shared_by_max_quests` | — | 168911486 | 177357061 | new |
| `test_component_retire::quest_redefine_retired_reverts` | — | 5110540 | 5366067 | new |
| `test_component_retire::quest_retire_abandon_before_is_kept` | — | 5722820 | 6008961 | new |
| `test_component_retire::quest_retire_dependent_then_prerequisite` | — | 7930330 | 8326847 | new |
| `test_component_retire::quest_retire_frees_slot` | — | 51550730 | 54128267 | new |
| `test_component_retire::quest_retire_keeps_pages_contiguous` | — | 58104140 | 61009347 | new |
| `test_component_retire::quest_retire_last_quest_empties_page` | — | 4986780 | 5236119 | new |
| `test_component_retire::quest_retire_prerequisite_with_live_dependent_reverts` | — | 7601270 | 7981334 | new |
| `test_component_retire::quest_retire_twice_reverts` | — | 5388010 | 5657411 | new |
| `test_component_retire::quest_retired_accept_reverts` | — | 5124150 | 5380358 | new |
| `test_component_retire::quest_retired_completed_still_claimable` | — | 12718096 | 13354001 | new |
| `test_component_retire::quest_retired_definition_readable` | — | 4871670 | 5115254 | new |
| `test_component_retire::quest_retired_is_not_accepted` | — | 6228240 | 6539652 | new |
| `test_component_retire::quest_retired_not_progressed` | — | 7866286 | 8259601 | new |

A test's figure includes deploying the mock, and each dispatcher call costs the call's overhead
(roughly 0.2 M to 0.8 M L2 gas). To read an entrypoint's own cost, use the Call column of the
first table.

## Acceptance criteria

- [x] **AC-1**: storage (§3.3), events (§3.4), hooks, internal functions, external ABI and views
  (§3.5) are in `src/component.cairo` and `src/interface.cairo`. The member names, keys,
  signatures and error strings are those of the report. Deviations are listed below.
- [x] **AC-2**: every named test case of §2 for `quest` exists and passes. Where each one is:

  | §2 | Test(s) | File |
  |---|---|---|
  | D-1 | `quest_event_mode_emits_only_progressed`, `quest_event_mode_calls_no_hook`, `quest_event_mode_cannot_be_claimed`, `quest_modes_do_not_mix` | `tests/test_component_event_mode.cairo` |
  | D-2 | `quest_prerequisites_all_required`, `quest_prerequisites_unlock_after_last` | `tests/test_component_prerequisites.cairo` (logic: `test_record.cairo::quest_prerequisites_all_required_logic`) |
  | D-3 | `quest_inactive_dependent_does_not_revert`, `quest_dependent_unlocks_when_window_opens` | `tests/test_component_prerequisites.cairo` |
  | D-3 | `quest_inactive_quest_skipped_not_reverted` | `tests/test_component_progress.cairo` |
  | D-4 | `quest_recurring_prerequisite_completes_every_interval`, `quest_recurring_prerequisite_after_dependent_completed` | `tests/test_component_prerequisites.cairo` |
  | D-5 | `quest_recurring_dependent_stays_unlocked` | `tests/test_component_prerequisites.cairo` |
  | D-6 | `quest_prerequisite_completed_before_definition`, `quest_recurring_prerequisite_completed_before_definition` | `tests/test_component_prerequisites.cairo` |
  | D-7 | `quest_define_rejects_self_condition`, `_duplicate_condition`, `_undefined_condition`, `_too_many_conditions` | `tests/test_component_define.cairo` (the logic versions of self, duplicate and too many are in `test_definition.cairo`) |
  | D-8 | `quest_define_twice_reverts` | `tests/test_component_define.cairo` |
  | D-9 | `quest_count_saturates_at_total`, `quest_count_max_value` | `tests/test_component_progress.cairo` and `tests/test_progress.cairo` |
  | D-12 | `quest_define_rejects_duration_above_interval`, `quest_define_rejects_half_recurring` | `tests/test_definition.cairo` (ARC-03a) |
  | D-13 | `quest_progress_rejects_unregistered_caller`, `quest_progress_accepts_registered_reporter`, `quest_set_reporter_admin_only`, `quest_reporter_revoked`, `quest_claim_requires_player_authorization`, `quest_define_admin_only` | `tests/test_component_access.cairo` |
  | Also tested | `quest_daily_interval_aligned_on_utc_midnight`, `quest_one_off_completes_once`, `quest_recurring_completes_each_interval`, `quest_interval_id_is_u64`, `quest_batch_two_tasks_one_quest_one_write`, `quest_batch_duplicate_entries_merged`, `quest_batch_above_bound_reverts`, `quest_batch_rejects_task_zero`, `quest_batch_duplicates_count_toward_bound`, `quest_task_shared_by_max_quests` | `tests/test_component_progress.cairo` (the daily, interval and batch ones also exist as library tests of ARC-03a) |
  | Also tested | `quest_claim_index_counts_claims`, `quest_claim_twice_reverts`, `quest_claim_uncompleted_reverts` | `tests/test_component_claim.cairo` (and `test_record.cairo`) |
  | Also tested | `quest_accept_required`, `quest_completion_releases_acceptance`, `quest_acceptance_expires_at_rollover`, `quest_accept_twice_same_interval_reverts`, `quest_accept_after_completion_reverts`, `quest_accept_after_daily_completion`, `quest_abandon_expired_reverts` | `tests/test_component_accept.cairo` |
  | Also tested | `quest_batch_event_mode_one_event_per_task` | `tests/test_component_event_mode.cairo` |
  | Also tested | `quest_batch_bound_accepted` (the §5.1 witness, as a benchmark) | `tests/test_component_bench.cairo` |
  | Also tested | `quest_batch_first_position_uses_zero_sentinel` | `tests/test_batch.cairo` (ARC-03a) |
  | Also tested | `quest_define_rejects_association_overflow`, `quest_define_rejects_retired_condition`, `quest_define_counts_dependents`, `quest_empty_slot_reads_undefined` | `tests/test_component_define.cairo` (`quest_empty_slot_reads_undefined` also in `test_packing.cairo`) |
  | Also tested | `quest_retire_frees_slot`, `quest_retired_not_progressed`, `quest_retired_completed_still_claimable`, `quest_retired_accept_reverts`, `quest_retire_twice_reverts`, `quest_redefine_retired_reverts`, `quest_retired_is_not_accepted`, `quest_retire_prerequisite_with_live_dependent_reverts`, `quest_retire_dependent_then_prerequisite` | `tests/test_component_retire.cairo` |
  | Also tested | `quest_is_unlocked_evaluates_uncached` | `tests/test_component_prerequisites.cairo` |
  | Also tested | `quest_record_counters_past_u32`, `quest_record_counters_saturate` | `tests/test_record.cairo` (ARC-03a) |
  | Also tested | `quest_packing_round_trip` (as `quest_packing_round_trip_{definition_zero,definition_max,definition_mixed,tasks,conditions,page,progress,record}`) | `tests/test_packing.cairo` (ARC-03a) |

  Tests beyond §2:
  - Hooks: `quest_complete_hook_after_state_written` and `quest_claim_hook_after_state_written`.
    Inside the hook, the mock reads the record and the progress. It sees `completions`/`claims`
    already incremented and `completed`/`claimed` already set, and receives `completions` or
    `claim_index` as its argument.
  - A panicking hook reverts the call: `quest_complete_hook_panic_reverts_progress` (the other
    quest of the same call is reverted too) and `quest_claim_hook_panic_reverts_claim`.
  - Events: `quest_events_keys_and_data` checks keys and data felt by felt for five events;
    `quest_set_reporter_event_keys` checks the sixth.
  - Rollover (A-11): `quest_acceptance_expires_at_rollover` and
    `quest_daily_rollover_starts_from_zero`.
  - Pages: `quest_retire_keeps_pages_contiguous`. It reads the pages straight from storage with
    `load` and `map_entry_address` after each of 8 retirements: from the first page, the middle,
    the last id, and the ends of pages.
- [x] **AC-3**: every entrypoint of `IQuest` refuses an unauthorised caller, with a test each:
  `quest_define_admin_only`, `quest_retire_admin_only`, `quest_set_reporter_admin_only`,
  `quest_progress_rejects_unregistered_caller` (both modes; the admin is refused too),
  `quest_progress_many_rejects_unregistered_caller`, `quest_accept_requires_player_authorization`,
  `quest_abandon_requires_player_authorization`, `quest_claim_requires_player_authorization`.
  `quest_internal_layer_not_reachable_from_abi` calls every `IQuest` selector on `MockConsumer`
  (which embeds views only) and gets `ENTRYPOINT_NOT_FOUND` for each.
  `quest_consumer_calls_the_internal_layer` shows the consumer's own checks guarding the internal
  layer. The internal layer is documented as trusted in the doc comments of `InternalImpl` and of
  the module, and in the README's "Access control, and the trusted internal layer" section.
- [x] **AC-4**: one write per record per call.
  - `quest_batch_two_tasks_one_quest_one_write_not_completing` against its baseline: **1
    storage write** (P), 6 reads plus the reporter check (2 pages, B twice, A, P).
  - `quest_batch_two_tasks_one_quest_one_write`: **2 writes** for the component (P and R).
  - At scale, the worst `progress_many` writes 896 slots for 448 quests: exactly one P and one R
    each.
  - `Mode::Event` writes nothing: 0 storage writes in `bench_progress_event_mode` and
    `bench_progress_many_event_mode_worst` against `baseline_deployed`. The views stay zero in
    `quest_event_mode_emits_only_progressed` and `quest_batch_event_mode_one_event_per_task`.
- [x] **AC-5**: every test has a budget `ceil(1.05 × measured)`, and `scripts/gas.py
  packages/quest --check` passes locally and in CI. There are benchmarks on every worst case of
  §5.1, with reads and writes equal to the estimates. `docs/BUDGETS.md` is written.
- [x] **AC-6**: README (usage with a consumer sketch, bounds, access control and the trusted
  internal layer, modes, the daily alignment on 00:00 UTC, the one-call-per-player-per-transaction
  rule) and CHANGELOG (`## [0.1.0] - not yet released`, listing the API) are done. CI on PR #7 is
  green.

## Deviations from the brief

1. **Tests were not all written before the code.** I wrote `component.cairo` first, with a
   one-test smoke check (since deleted). The point was to confirm that snforge 0.61 can declare
   and deploy contracts defined under `tests/` **without** `[[target.starknet-contract]]` in
   `packages/quest/Scarb.toml`, which is outside my allowlist. It can. The tests came next, and
   each was run before its budget was set.
2. **Event structs also derive `PartialEq` and `Debug`**, on top of `Drop, starknet::Event`, so
   that tests can compare them with `spy.assert_emitted`. This is additive; the serialized events
   are those of §3.4.
3. **Step 7 of `progress_many`, "write P once"**, is read as "at most once". P is written only if
   `progress_add` changed it. When a call only caches a newly met unlock (R marked, counts
   unchanged because the batched tasks are already at their totals), only R is written. Writing
   an unchanged P would cost a write and change no outcome.
4. **Order of `define`'s checks** (§3.5 lists them without an order): `definition_new`'s
   validation, then `'Quest: already defined'`, then each condition (`'Quest: invalid
   condition'`, `'Quest: too many dependents'`, then its A is written), then each task's pages
   (`'Quest: task full'`). A refusal reverts every write before it.
5. **`current_interval` / `quest_current_interval` returns `None` for a quest that is not
   defined.** §3.5 gives no rule. Without this, an empty slot would read as a one-off quest that
   started at the epoch and return `Some(0)`. For a retired quest it returns the schedule's
   interval, as for a live one. See Open questions.
6. **The CHANGELOG's ARC-03a entries moved** from `## [Unreleased]` into
   `## [0.1.0] - not yet released`, together with the component. `## [Unreleased]` now reads
   "Nothing yet.". `release_check.py` matches `## [0.1.0]`; the orchestrator sets the date when
   it releases (WORKSPACE §6).
7. **The README's "Not implemented yet" paragraph is gone.** ARC-03a flagged it as an
   escalation; the brief now lists the README.
8. **No change to the library** (`src/logic/`, `src/errors.cairo`, `src/constants.cairo`). No
   defect was found in it.

Everything else follows the brief. There is no `u256` in the component. Loops are bounded:
entries by `MAX_ENTRIES` (checked first by `batch_merge`), pages by `MAX_PAGES`, the quests of a
page by `QUESTS_PER_PAGE`, tasks by `MAX_TASKS`, conditions by `MAX_CONDITIONS`.

## Escalations

None blocking. I wrote no file outside the allowlist. The scratch files of this session are
under `target/`, which git ignores.

## Open questions

1. **`quest_current_interval` for a quest not defined or retired** (deviation 5): `None`, then
   the schedule's interval. Should a retired quest also return `None`? Or should an undefined
   one revert `'Quest: does not exist'`, as `quest_definition` does?
2. **`quest_is_unlocked` on a retired quest** evaluates its prerequisites like a live one's.
   §3.5 is silent; `quest_is_accepted` returns false for a retired quest.
3. **Early exit on prerequisites.** `progress` and `accept` read all K records, then call the
   library's `prerequisites_met`, as §3.5 and the §5.1 row "a locked quest: 4 + K reads" say.
   Stopping at the first prerequisite with no completion would read fewer on a locked quest.
   That changes a cost, not a result. Should it be done in a later version?
4. **The worst `progress_many` call measures 704 M L2 gas** for the component alone (16 × 28
   quests, all completing, K = 7 first observed). A consumer's hooks add to it. This is the
   product of the bounds, not a case of the game's design (§5.1). It may still be worth checking
   against the network's per-transaction L2 gas limit before Q-19's bound is relied on at its
   maximum.
5. **snforge prints `warn: external contracts not found for selectors: quiver_quest::*`** when it
   compiles the tests. It does not affect the results.

## Fix loop 1

The `[GPT-6-Astra]` audit returned FAIL (no access-control bypass found); the orchestrator
accepted all five points. All are addressed on the same branch and allowlist. The tests came
first and were committed before the fix (`1bed161`), and the point-1 regression failed before
the fix. Commits:

- `1bed161`: tests (points 1 to 3);
- `8f0125f`: the fix (point 1);
- `24578a7`: benchmarks and budgets (point 4);
- `16ad0e4`: docs (points 4 and 5).

CI is green on `16ad0e4`: `cairo`, `package (packages/quest)` (with `gas.py --check`),
`affected`, `links` and `scripts` all pass. Locally: `snforge test` gives 310 passed, 0 failed;
`scripts/gas.py packages/quest --check` gives "310 tests within budget, GAS.md up to date";
`fmt --check` exits 0; `check-links` finds 0 broken links.

### Point 1 (major): a quest retired during a hook could still be progressed. Fixed

**Cause.** `progress_many` reads a task's pages once, then processes each quest on them. ARC-01
§3.5 assumed that taking a quest off its pages is enough to stop it receiving progress ("progress
never reaches it, because it is on no page"). Re-entry breaks that assumption. A completion hook
of an earlier quest in the same call can retire a later quest of the same page snapshot, and the
loop then read that quest's A without checking `retired`.

**Fix.** `packages/quest/src/component.cairo:453-459`, in `progress_quest`. Right after A is
read, a retired quest is skipped, before its schedule, record or progress are looked at. This is
the only path that reads A from a snapshot. `define`, `retire` and `accept` read pages or A fresh,
and `accept` and `abandon` already refuse `'Quest: retired'`. The CHANGELOG
(`packages/quest/CHANGELOG.md:57`) and README (`packages/quest/README.md:124`) state the
behaviour.

**Regression test.** `quest_retired_by_hook_not_progressed`
(`packages/quest/tests/test_component_reentry.cairo:104`). It uses two permanent quests on one
task with target 1, and the first one's completion hook retires the second. After the call, the
second has no progress and a zero record, emits no `QuestCompleted`, gets no hook call, is
retired, and `claim` reverts `'Quest: not completed'`. Before the fix:

```
[FAIL] quiver_quest_integrationtest::test_component_reentry::quest_retired_by_hook_not_progressed
Failure data:
    "assertion failed: `r.view.quest_progress(PLAYER, 2, 0) == no_progress()`."
```

After the fix: `Tests: 9 passed, 0 failed` for `test_component_reentry`.

**Cost.** The check adds about 100 L2 gas per quest reached, which raised 70 budgets (all in
`test_component_*`):
- +3 500 on `bench_progress_worst`;
- +45 500 on `quest_batch_bound_accepted`;
- +100 to +800 on the others (setups included).

None was lowered, and no library budget changed. The reason is also written in the pull request
(comment on #7).

### Point 2 (major): hook re-entry untested. Tests added; no code change needed

**New mock.** `MockReentrant` (`packages/quest/tests/mock_reentrant.cairo`). Its hooks log their
call (`HookCall`, with the record and progress they read). Then, once and on demand
(`set_reentry`), they re-enter the component through the internal layer with `progress`,
`claim`, `accept` or `retire`, on the same quest or another one.

**Tests** (`packages/quest/tests/test_component_reentry.cairo`). They assert counters, flags,
events and hook-call counts:

| Test | Line | Asserts |
|---|---|---|
| `quest_reentrant_progress_same_quest_completes_once` | 128 | `progress` from `on_quest_complete`, same quest and interval: progress `(1, completed)`, `completions == 1`, one `QuestCompleted`, one hook call |
| `quest_reentrant_progress_later_quest_completes_once` | 150 | The re-entrant progress completes the second quest of the snapshot inside the hook; the outer loop then skips it: each quest completed once, one `QuestCompleted` each, two hook calls in order |
| `quest_reentrant_claim_same_quest_refused` | 171 | `claim` from `on_quest_claim` of the same interval is refused `'Quest: already claimed'`, which reverts the outer claim: `claimed == false`, `claims == 0`, only the setup's hook call is kept |
| `quest_reentrant_accept_after_completion_refused` | 202 | `accept` from `on_quest_complete` after the completion is refused `'Quest: already completed'` (§3.5 accept step 5), which reverts the outer progress: progress zero, record still accepted with `completions == 0`, no hook call kept |
| `quest_reentrant_{progress,claim,accept,retire}_other_quest_leaves_outer_unchanged` | 293, 300, 307, 314 | The same outer call runs on two deployments, without and with the re-entry. The outer quests' progress, records, `QuestCompleted` events and hook calls are equal; the inner operation took effect (another quest completed, claimed, accepted, retired) |

For the two refused cases, events are not asserted. snforge's spy keeps the events emitted inside
a call that then reverts, which a real receipt would not contain. Those tests check the reverted
state instead, with a comment saying why.

### Point 3 (major): the `live_dependents` ceiling. Tests added; no code change needed

**Fixture.** Prerequisite P's A slot is seeded at `live_dependents = 65 534` with snforge's
`store` at `map_entry_address(selector!("Quest_definitions"), [P])`
(`packages/quest/tests/test_component_dependents.cairo`).

| Test | Line | Asserts |
|---|---|---|
| `quest_define_reaches_max_dependents` | 56 | The next `define` naming P takes it to 65 535 |
| `quest_define_rejects_too_many_dependents` | 65 | The one after (`[X, P]`, so X's counter is incremented before P's refusal) reverts `'Quest: too many dependents'`. Nothing of it is kept: P stays at 65 535, X at 0, the new quest's task page is empty (read from storage), and the quest does not exist |
| `quest_retire_dependent_frees_max_dependents` | 84 | Retiring one dependent takes P back to 65 534; a new `define` naming X and P then succeeds (P 65 535, X 1, the page holds it) |

### Point 4 (minor): benchmarks through the slow merge. Added

In `packages/quest/tests/test_component_bench.cairo`:
- `fifteen_then` (line 183) builds `[1..=15, last]`, and `late_setup` (line 195) builds the
  storage fixture.
- Late collision `[1..=15, 129]` (129 = 1 mod 128), with the same 448-quest storage witness (task
  129 in place of 16): `bench_progress_many_worst_late_collision` (232) and its baseline (225),
  plus `bench_progress_many_event_mode_late_collision` (211).
- Late duplicate `[1..=15, 15]`, 15 distinct tasks, so 420 quests:
  `bench_progress_many_worst_late_duplicate` (247) and its baseline (240), plus
  `bench_progress_many_event_mode_late_duplicate` (218).

| Benchmark | Test measured | Budget | Call | Reads / writes |
|---|---|---|---|---|
| `quest_batch_bound_accepted` (fast path, §5.1 witness) | 1 995 596 598 | 2 095 376 428 | 704 377 846 | 5 440 / 896 |
| `bench_progress_many_worst_late_collision` (**new gas maximum**) | 1 996 006 375 | 2 095 806 694 | **704 804 763** | 5 440 / 896 |
| `bench_progress_many_worst_late_duplicate` (420 quests) | 1 871 824 365 | 1 965 415 584 | 659 921 723 | 5 100 / 840 |
| `bench_progress_many_event_mode_worst` (fast path) | 2 053 886 | 2 156 581 | 1 263 386 | 0 / 0, 16 events |
| `bench_progress_many_event_mode_late_collision` | 2 625 213 | 2 756 474 | 1 834 713 | 0 / 0, 16 events |
| `bench_progress_many_event_mode_late_duplicate` | 2 567 393 | 2 695 763 | 1 776 893 | 0 / 0, 15 events |

Reads exclude the reporter check (1 read). `GAS.md` is regenerated: 310 tests, and the library's
166 rows are unchanged but for the commit column.

`docs/BUDGETS.md:19` ("The two maxima of `progress_many`") keeps two distinct lines:
- the §5.1 storage-operation maximum, `quest_batch_bound_accepted`, 5 440 reads and 896 writes;
- the measured gas maximum, `bench_progress_many_worst_late_collision`, 704 804 763.

In `GAS.md` they are the two distinct rows of those tests. `GAS.md` is generated by
`scripts/gas.py`, one row per test, so it cannot carry a label without changing the tool, which
is outside the allowlist. The per-entrypoint table of `docs/BUDGETS.md` is refreshed with the
post-fix figures, at `24578a7`.

### Point 5: integration budget. Added

`packages/quest/README.md:199`, section "Integration budget":
- **The ceiling.** Starknet's "Max L2 gas per transaction" is 1.1 × 10⁹, from the
  chain-information table of docs.starknet.io
  (https://docs.starknet.io/learn/cheatsheets/chain-info), read on 2026-09-28. The page gives the
  current versions (Mainnet 0.14.2, Sepolia 0.14.3) but no date for the limit; it also gives 6 ×
  10⁹ per block.
- **The worst call against it.** 704 804 763 L2 gas is 64 % of the ceiling. That leaves about
  395 × 10⁶, 36 %, for the consumer's own logic, its 448 `on_quest_complete` hooks (about 0.88 ×
  10⁶ each if they had all of it) and the account.
- **The rule.** A consumer whose whole transaction could exceed the ceiling at the package's
  bounds must enforce a smaller practical bound on entries or fan-out (live quests per task,
  prerequisites), sized from its own measured worst case.
- **The reporter check** (line 223). The external `progress` and `progress_many` read the
  reporter registry once, in `Mode::Event` too; the internal event-mode call reads nothing.

`docs/BUDGETS.md` links to that section. The "0.88 × 10⁶ per hook" figure is arithmetic (395 ×
10⁶ / 448), not a measure.

## Fix loop 2

The project manager's cost cap
([A-G1 amendment](../decisions/2026-09-28-A-G1-amendment-cost-cap.md), on `main`) requires the
worst call the package allows to stay under 20 M L2 gas. I merged `origin/main` first (`49fbdb9`;
it touched no file of the package).

**Status.** Points 1, 2, 4 and 5 are done. **Point 3 is stopped and escalated, as the brief
says**: 16 entries per call cannot stay under 20 M with any caps, measured, so I did not choose
the caps. Point 6 records the caps as pending.

Commits: `49fbdb9` (merge), `88b09f7` (grid, options, game case, probes, optimizations, budgets),
`2703bb6` (GAS.md model, BUDGETS, README, CHANGELOG). CI is green on `2703bb6`: `cairo`,
`package (packages/quest)` with `gas.py --check`, `affected`, `links` and `scripts` all pass.
Locally: `snforge test` gives 455 passed, 0 failed; `scripts/gas.py packages/quest --check` gives
"455 tests within budget, GAS.md up to date"; `fmt --check` exits 0; `check-links` finds 0 broken
links.

### Point 1: `progress_many` measured as a function of E, N, K. Done

**Grid** (`packages/quest/tests/test_component_grid.cairo`, 111 budgeted tests, generated). It
covers:
- storage mode at every point of E ∈ {1, 4, 16} × N ∈ {1, 2, 4, 7} × K ∈ {0, 1, 3, 7};
- the corners of the old bounds (N = 28 with E ∈ {1, 16}, K ∈ {0, 7});
- event mode for E ∈ {1, 4, 16}, and E = 16 on the (16, 7, 7) fixture.

Each point has a baseline (the same fixture and entries, without the call). Every quest completes
and the hooks are empty. Fixtures are seeded straight into the component's storage with snforge's
`store` (`tests/grid.cairo`), so the grid reaches past any cap `define` would refuse.

**Model**, fitted on the 52 storage points, largest error 0.02%
(`packages/quest/GAS.md:550`):

| Term | Marginal L2 gas |
|---|---|
| per call | 169 946 |
| per task entry (its first page read included) | 71 229 |
| per extra page read | 58 206 |
| **per quest completed** | **1 172 066** |
| per quest with prerequisites (slot C read) | 50 828 |
| per prerequisite first observed | 41 642 |
| per event, event mode (E 1 → 16) | 66 346; independent of N and K (1 214 706 vs 1 216 136) |

The table of all 52 points (call, Sierra gas, reads, writes, events, per quest) and the model are
in `packages/quest/GAS.md:465-610`, in a section written below the generated table.
`scripts/gas.py --write` would drop that section; `--check` ignores it (escalation 2 below).

### Point 2: where the per-quest cost goes, and the waste removed

**Profile** (`packages/quest/tests/test_component_probe.cairo`, 100 operations per test, net of
`probe_baseline`):

| Operation | L2 gas | Sierra gas |
|---|---|---|
| storage read | 30 205 | 30 205 |
| **storage write to a slot changed in the transaction** | **459 099** | 57 099 |
| write of a slot already changed, or unchanged | 57 099 | 57 099 |
| event of `QuestCompleted`'s shape | 48 542 | 12 742 |
| unpack A / B / R | 20 613 / 12 625 / 10 635 | same |

A slot changed by the transaction costs about 402 000 L2 gas beyond its write's computation,
once per slot per transaction (`probe_write_then_change_100` equals
`probe_write_then_overwrite_100`). A completed quest changes two slots, its progress P and its
record R: **about 918 000 of its 1.17 M**. The rest is 4 to 5 reads (~150 000), the event
(~48 500) and ~140 000 of computation. So the 1.5 M per quest of the old worst case was mostly
not waste: 2 changed slots plus 12 reads with their unpacks. Neither slot can go without changing
the API: P holds the counts of the interval, R the completions the hook and the prerequisites
need.

**Waste removed** (`packages/quest/src/component.cairo`; no change of results):
- `:469` and `:514`: a one-task quest is only on its task's page. The batch is not scanned for
  its first position, and `progress_add` gets only its own entry (a slice of the batch).
- `:269`: the first page is read on its own; further pages (and the array that holds them) only
  when it is full.
- The page's ids are read slot by slot instead of through `page_span`'s array.
- `:549-557`: the prerequisites are read in order and the reading stops at the first one never
  completed. There is no array of records and no `prerequisites_met` call; the result is the same.

**Before and after** (the call alone, benchmark minus baseline, L2 gas):

| Benchmark | Before | After | Change |
|---|---|---|---|
| `bench_progress_worst` (1 × 28 × 7) | 43 269 806 | 42 809 176 | −1.1% |
| `quest_batch_bound_accepted` (16 × 28 × 7, fast merge) | 704 377 846 | 682 740 366 | −3.1% |
| `bench_progress_many_worst_late_collision` (the gas maximum) | 704 804 763 | 683 167 283 | −3.1% |
| `bench_progress_many_worst_late_duplicate` | 659 921 723 | 640 527 073 | −2.9% |
| grid (16, 1, 0) | 20 629 606 | 20 062 796 | −2.7% |
| grid (16, 1, 7) | 26 370 086 | 25 539 916 | −3.1% |
| `bench_progress_plain` / `_completing` | 857 616 / 1 405 956 | 855 386 / 1 403 726 | −0.3% / −0.2% |
| `bench_accept_worst` | 1 071 170 | 1 054 710 | −1.5% |
| `bench_view_is_unlocked_worst` | 539 310 | 522 850 | −3.1% |
| `bench_claim`, `bench_retire_worst`, `bench_define_worst` | unchanged | unchanged | 0 |

The grid before the changes fits the same model less well (largest error 17.9%). The old batch
scans made a quest's cost depend on its entry's position.

**Other options, not taken:**
- A per-call cache of prerequisite records helps only quests that share prerequisites, not the
  worst case (no sharing).
- A cheaper unpack or merge is library code outside this loop's allowlist, and worth at most
  ~0.1 M per quest.

**Budgets:** 145 new, 83 lowered, 10 raised by 250 to 2 400 L2 gas. The raised ones are calls
that revert and quests of two tasks (the one-task check), all in `test_component_access` and
`test_component_progress`.

### Point 3: the caps. Stopped and escalated

The rule: cut quests per task first, keep 16 entries per call unless the measurements prove it
impossible, and then escalate rather than choose.

**The measurement proves it impossible.** At 16 entries, the smallest caps (**1 quest per task, no
prerequisite**) measure **20 644 413 L2 gas** with the worst entries (`option_e16_n1_k0`,
`packages/quest/tests/test_component_options.cairo`), and 20 062 796 with distinct ids (grid).
Nothing smaller than one quest per task is a cap. The cost is 16 completed quests at ~1.17 M each,
most of it their changed slots. The model at E = 16 is 1.31 M + 18.75 M × N (+ ~0.6 M for the
worst merge):

| N at E = 16 | K = 0 |
|---|---|
| 1 | 20.6 M (measured) |
| 2 | ~39.4 M |
| 3 | ~58.2 M |
| 4 | ~76.9 M |

Each prerequisite first observed adds ~41 600 per quest, plus ~50 800 for the first.

**Measured options under 20 M** (worst entries for each E; `packages/quest/GAS.md:575`):

| E (entries) | N (quests per task) | K (prerequisites) | Quests | Call |
|---|---|---|---|---|
| 15 | 1 | 0 | 15 | 19 336 217 |
| 12 | 1 | 7 | 12 | 19 542 149 |
| 8 | 2 | 0 | 16 | 19 659 245 |
| 7 | 2 | 3 | 14 | 19 672 209 |
| 5 | 3 | 1 | 15 | 19 567 457 |
| 4 | 4 | 0 | 16 | 19 259 661 |
| 4 | 3 | 7 | 12 | 18 678 701 |
| 2 | 7 | 4 | 14 | 19 900 849 |
| 3 | 5 | 2 | 15 | 20 011 115 (just above) |
| 16 | 1 | 0 | 16 | **20 644 413 (above)** |

With these caps, a call completes at most 14 to 16 quests. Prerequisites below 7 are needed at
every E ≥ 13 (none fit at 16, K = 0 only at 15) and whenever N ≥ 2 with E ≥ 8.

**The game's own use is far below** (point 4): 10 144 166 with 16 entries and 3 quests per task.
Only its 4 held quests complete; the others are reached and skipped at a cost of reads. The
package's worst case assumes every quest reached completes, which the package cannot rule out
while accepting is the consumer's rule.

**For the decision** (these are the figures, not a choice):
- (a) Fewer entries per call than A-10's 16, with N and K from the table above.
- (b) One quest per task at 15 entries (or 16 with a cap a little above 20 M).
- (c) A higher cap: 16 entries with 1, 2 or 3 quests per task need about 20.6 M, 39.4 M or
  58.2 M.
- (d) An API change, outside this brief: bound what can complete in one call rather than what can
  be reached. For example, the package itself limits the quests a player holds (with an accept
  step required). The game's case (4 held) then bounds the worst call near its measured 10 M.

Nothing is changed in `constants.cairo` or the library's bounds, and no refusal is added. The
existing named refusals, `'Quest: task full'` (quests per task) and `'Quest: too many
conditions'` (prerequisites), already do what the caps need once their constants are lowered.

### Point 4: the game's case. Done

`packages/quest/tests/test_component_game.cairo`, through the real `define`/`accept` path:
- 16 entries;
- quest 1 on tasks 1 and 2, quest 2 on task 3 (1 prerequisite), quest 3 on tasks 4 and 5 (2
  prerequisites), a daily contract on task 6;
- all four held (accepted) and all completing;
- every task shared by 3 (or 2) quests in all, the others with an accept step but not accepted.

The benchmark and its baseline make the same view calls:

| Case | Call | Reads | Writes | Events |
|---|---|---|---|---|
| `game_case_three_per_task` (48 quests on the 16 tasks) | 10 144 166 | 160 | 8 | 4 |
| `game_case_two_per_task` (32) | 8 015 046 | 112 | 8 | 4 |
| worst call the package allows at 16 entries, smallest caps | 20 644 413 | 80 | 32 | 16 |

### Point 5: README integration budget. Rewritten

`packages/quest/README.md:201`:
- **The network's limit**: 1.1 × 10⁹ L2 gas ("Max L2 gas per transaction", docs.starknet.io,
  Learn > Cheatsheets > Chain info, read 2026-09-28), and the project's 20 M cap.
- **The package's worst call** (`:211`): 683 M under this version's bounds, 20.6 M at the
  smallest 16-entry caps, and the game's case at 10.1 M. It says the caps are not set yet and
  why.
- **The rule** (`:225`): the consumer's whole transaction (its own logic, the package's calls,
  hooks that multiply with completions, the account) must fit, with a smaller practical bound
  where needed.
- The paragraph on the reporter check in event mode is kept, and the Bounds section says its
  values are those of A-G1, not final.

### Point 6: CHANGELOG. Partly

`packages/quest/CHANGELOG.md:20` says the bounds are not final: they don't meet the amendment
(683 M measured), and the caps and their refusals will be recorded before the release.
`:63` records the prerequisite reading that stops early. The caps themselves can't be listed until
they are decided.

### Escalations (fix loop 2)

1. **The caps of 0.1.0.** 16 entries per call and the 20 M cap cannot both hold, with any quests
   per task or prerequisites. The figures and options are above and in `packages/quest/GAS.md`.
   The decision is between (a) fewer entries, (b) one quest per task at 15 entries, (c) a higher
   cap, or (d) an API change that bounds completions per call. Once it is made, the change is
   small: `MAX_ENTRIES`, `QUESTS_PER_PAGE`/`MAX_PAGES` (or a new `MAX_QUESTS_PER_TASK`) and
   `MAX_CONDITIONS`, the existing refusals, the tests that assume 28 and 7, and the docs.
2. **`scripts/gas.py --write` rewrites `GAS.md` whole.** The model section asked for there is
   written by hand below the generated table. `--check` passes, but a later `--write` drops the
   section. The tool (outside the allowlist) could keep what follows its table.
3. **The L2 gas of a changed storage slot** (~402 000, measured with snforge 0.61) dominates every
   figure. I have taken snforge's figures as the project's measure, as the amendment does; I did
   not compare them with the network's fee schedule.
