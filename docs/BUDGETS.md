# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-28 at `23fd317` (ARC-03b), snforge 0.61, L2 gas. Each benchmark in
`packages/quest/tests/test_component_bench.cairo` runs on the worst case of
[ARC-01 §5.1](research/ARC-01-quest-achievement.md) and has a baseline that runs the same setup
without the call. **Call** is the benchmark minus its baseline: the entrypoint's own cost through
a dispatcher, from a consumer whose hooks do nothing. **Reads** and **writes** are the storage
syscalls of the call, the same difference taken from `snforge test --detailed-resources`; the
reporter check of `progress` and `progress_many` (1 read) is counted apart. The **budget** is
that of the benchmark test.

| Entrypoint | Worst case | Benchmark (baseline) | Test measured | Test budget | Call | Reads | Writes | §5.1 estimate |
|---|---|---|---|---|---|---|---|---|
| `progress`, event mode | 1 entry | `bench_progress_event_mode` (`baseline_deployed`) | 1 001 736 | 1 051 823 | 211 236 | 0 | 0 | 0 reads, 0 writes, 1 event |
| `progress_many`, event mode | 16 distinct entries | `bench_progress_many_event_mode_worst` (`baseline_deployed`) | 2 053 886 | 2 156 581 | 1 263 386 | 0 | 0 | 0, 0, 16 events |
| `progress` | 1 task shared by 28 live quests, each with 7 prerequisites first observed, all completing | `bench_progress_worst` (`baseline_progress_worst`) | 144 700 398 | 151 935 418 | 43 267 006 | 340 | 56 | 340 reads, 56 writes, 28 events, 28 hooks |
| `progress_many` | 16 tasks × 28 live quests (448 distinct), 7 prerequisites each first observed, all completing | `quest_batch_bound_accepted` (`baseline_batch_bound_accepted`) | 1 995 551 098 | 2 095 328 653 | 704 333 046 | 5 440 | 896 | 5 440 reads, 896 writes, 448 events, 448 hooks |
| `progress` | 1 one-off quest, 1 task, not completing | `bench_progress_plain` (`baseline_plain`) | 3 389 826 | 3 559 318 | 857 516 | 4 | 1 | 4, 1 |
| `progress` | Same, completing | `bench_progress_plain_completing` (`baseline_plain`) | 3 938 166 | 4 135 075 | 1 405 856 | 5 | 2 | 5, 2, 1 event, 1 hook |
| `progress` | 1 accepted quest (unlock cached by `accept`), not completing | `bench_progress_accepted` (`baseline_accepted`) | 28 153 088 | 29 560 743 | 914 366 | 5 | 1 | 5, 1 |
| `accept` | 7 prerequisites met, not cached | `bench_accept_worst` (`baseline_prerequisites`) | 27 238 722 | 28 600 659 | 1 071 170 | 11 | 1 | 3 to 11 reads, 1 write |
| `abandon` | — | `bench_abandon` (`baseline_accepted`) | 27 507 682 | 28 883 067 | 268 960 | 2 | 1 | 2, 1 |
| `claim` | — | `bench_claim` (`baseline_completed`) | 4 307 466 | 4 522 840 | 369 300 | 2 | 2 | 2, 2, 1 event, 1 hook |
| `retire` | 3 tasks, each with 28 live quests (hole on page 0, last id on page 3), 7 conditions | `bench_retire_worst` (`baseline_retire_worst`) | 146 581 142 | 153 910 200 | 2 145 780 | 22 | 14 | ≤ 22 reads, ≤ 14 writes |
| `define` | 3 tasks, each with 27 live quests (4 pages), 7 conditions | `bench_define_worst` (`baseline_define_worst`) | 144 437 282 | 151 659 147 | 3 408 480 | 20 | 13 | K + 1 + 3 × 4 = 20 reads; K + 3 + 3 = 13 writes (§5.1 lists them without a total) |
| `set_reporter` | — | `bench_set_reporter` (`baseline_deployed`) | 1 398 910 | 1 468 856 | 608 410 | 0 | 1 | — |
| `quest_is_unlocked` | 7 prerequisites, not cached | `bench_view_is_unlocked_worst` (`baseline_prerequisites`) | 26 706 862 | 28 042 206 | 539 310 | 10 | 0 | — |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` (`baseline_prerequisites`) | 26 475 632 | 27 799 414 | 308 080 | 3 | 0 | — |
| `quest_is_accepted` | — | `bench_view_is_accepted` (`baseline_prerequisites`) | 26 368 502 | 27 686 928 | 200 950 | 2 | 0 | — |
| `quest_current_interval` | — | `bench_view_current_interval` (`baseline_prerequisites`) | 26 330 162 | 27 646 671 | 162 610 | 1 | 0 | — |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` (`baseline_prerequisites`) | 26 462 812 | 27 785 953 | 295 260 | 2 | 0 | — |
| `quest_is_reporter` | — | `bench_view_is_reporter` (`baseline_prerequisites`) | 26 292 242 | 27 606 855 | 124 690 | 1 | 0 | — |

The `progress_many` benchmark's call also includes one more view call than its baseline (a
`quest_record` read, about 0.1 M), which the reads column excludes.

## `quiver_quest`: the library

Measured 2026-09-28 at `2982130`, as written in `packages/quest/GAS.md` (ARC-03a's benchmarks,
`packages/quest/tests/test_bench.cairo`, re-measured unchanged). A figure includes the test's
setup; the function's own cost is the benchmark minus its `bench_baseline_*`.

| Algorithm | Worst case | Benchmark | Measured | Budget |
|---|---|---|---|---|
| `batch_merge` | 16 entries, a modulo-128 collision at the 16th | `bench_batch_merge_late_modulo_collision` | 753 023 | 790 675 |
| `batch_merge` | 16 entries, a repeat at the 16th | `bench_batch_merge_late_duplicate` | 749 113 | 786 569 |
| `batch_merge` | 16 distinct entries (fast path) | `bench_batch_merge_sixteen_distinct` | 181 896 | 190 991 |
| `progress_add` | 3 tasks, 16 entries | `bench_progress_add_three_tasks_sixteen_entries` | 156 430 | 164 252 |
| `definition_new` | 3 tasks, 7 conditions | `bench_definition_new_three_tasks_seven_conditions` | 151 360 | 158 928 |
| `batch_first_position` | absent among 16 | `bench_batch_first_position_absent` | 110 490 | 116 015 |
| `batch_count_of` | absent among 16 | `bench_batch_count_of_absent` | 90 590 | 95 120 |
| `prerequisites_met` | 7 records | `bench_prerequisites_met_seven` | 31 400 | 32 970 |

The other functions (packing, pages, records, schedules) are between 16 640 and 43 450 with their
setup; see `GAS.md`.
