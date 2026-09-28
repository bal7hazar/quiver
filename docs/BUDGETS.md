# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-28 at `24578a7` (ARC-03b, fix loop 1), snforge 0.61, L2 gas. Each benchmark in
`packages/quest/tests/test_component_bench.cairo` runs on the worst case of
[ARC-01 §5.1](research/ARC-01-quest-achievement.md) and has a baseline that runs the same setup
without the call. **Call** is the benchmark minus its baseline: the entrypoint's own cost through
a dispatcher, from a consumer whose hooks do nothing. **Reads** and **writes** are the storage
syscalls of the call, the same difference taken from `snforge test --detailed-resources`; the
reporter check of `progress` and `progress_many` (1 read) is counted apart. The **budget** is
that of the benchmark test.

### The two maxima of `progress_many`

They are different quantities and are kept on separate lines.

| Maximum | Input | Benchmark (baseline) | Test measured | Test budget | Call | Reads | Writes |
|---|---|---|---|---|---|---|---|
| **§5.1 storage-operation maximum** (5 440 reads, 896 writes, 448 events, 448 hooks) | 16 distinct tasks 1..=16 (merge fast path) × 28 live quests, 448 distinct, 7 prerequisites each first observed, all completing | `quest_batch_bound_accepted` (`baseline_batch_bound_accepted`) | 1 995 596 598 | 2 095 376 428 | 704 377 846 | 5 440 | 896 |
| **Measured gas maximum** | The same 448-quest witness, entries `[1..=15, 129]` (129 = 1 mod 128: `batch_merge` meets its collision at the 16th entry, then runs the plain merge in full) | `bench_progress_many_worst_late_collision` (`baseline_progress_many_late_collision`) | 1 996 006 375 | 2 095 806 694 | **704 804 763** | 5 440 | 896 |

The call of `quest_batch_bound_accepted` includes one more `quest_record` view call than its
baseline (about 0.1 M); the reads column excludes it. The late collision costs more gas for the
same storage operations: the slow merge (ARC-03a measured `batch_merge` at 753 023 on this input
against 181 896 on 16 distinct ids, setups included).

### Per entrypoint

| Entrypoint | Worst case | Benchmark (baseline) | Test measured | Test budget | Call | Reads | Writes | §5.1 estimate |
|---|---|---|---|---|---|---|---|---|
| `progress`, event mode | 1 entry | `bench_progress_event_mode` (`baseline_deployed`) | 1 001 736 | 1 051 823 | 211 236 | 0 | 0 | 0 reads, 0 writes, 1 event |
| `progress_many`, event mode | 16 distinct entries 1..=16 (fast merge) | `bench_progress_many_event_mode_worst` (`baseline_deployed`) | 2 053 886 | 2 156 581 | 1 263 386 | 0 | 0 | 0, 0, 16 events |
| `progress_many`, event mode | `[1..=15, 129]`, late collision (slow merge), 16 events | `bench_progress_many_event_mode_late_collision` (`baseline_deployed`) | 2 625 213 | 2 756 474 | **1 834 713** | 0 | 0 | 0, 0, 16 events |
| `progress_many`, event mode | `[1..=15, 15]`, late duplicate (slow merge), 15 events | `bench_progress_many_event_mode_late_duplicate` (`baseline_deployed`) | 2 567 393 | 2 695 763 | 1 776 893 | 0 | 0 | 0, 0, 15 events |
| `progress` | 1 task shared by 28 live quests, each with 7 prerequisites first observed, all completing | `bench_progress_worst` (`baseline_progress_worst`) | 144 703 898 | 151 939 093 | 43 269 806 | 340 | 56 | 340 reads, 56 writes, 28 events, 28 hooks |
| `progress_many` | See the two maxima above | | | | | | | 5 440 reads, 896 writes, 448 events, 448 hooks |
| `progress_many` | `[1..=15, 15]`, late duplicate: 15 distinct tasks × 28 quests (420), K = 7, all completing | `bench_progress_many_worst_late_duplicate` (`baseline_progress_many_late_duplicate`) | 1 871 824 365 | 1 965 415 584 | 659 921 723 | 5 100 | 840 | 15 × 340 reads, 15 × 56 writes |
| `progress` | 1 one-off quest, 1 task, not completing | `bench_progress_plain` (`baseline_plain`) | 3 389 926 | 3 559 423 | 857 616 | 4 | 1 | 4, 1 |
| `progress` | Same, completing | `bench_progress_plain_completing` (`baseline_plain`) | 3 938 266 | 4 135 180 | 1 405 956 | 5 | 2 | 5, 2, 1 event, 1 hook |
| `progress` | 1 accepted quest (unlock cached by `accept`), not completing | `bench_progress_accepted` (`baseline_accepted`) | 28 153 888 | 29 561 583 | 914 466 | 5 | 1 | 5, 1 |
| `accept` | 7 prerequisites met, not cached | `bench_accept_worst` (`baseline_prerequisites`) | 27 239 422 | 28 601 394 | 1 071 170 | 11 | 1 | 3 to 11 reads, 1 write |
| `abandon` | — | `bench_abandon` (`baseline_accepted`) | 27 508 382 | 28 883 802 | 268 960 | 2 | 1 | 2, 1 |
| `claim` | — | `bench_claim` (`baseline_completed`) | 4 307 566 | 4 522 945 | 369 300 | 2 | 2 | 2, 2, 1 event, 1 hook |
| `retire` | 3 tasks, each with 28 live quests (hole on page 0, last id on page 3), 7 conditions | `bench_retire_worst` (`baseline_retire_worst`) | 146 581 842 | 153 910 935 | 2 145 780 | 22 | 14 | ≤ 22 reads, ≤ 14 writes |
| `define` | 3 tasks, each with 27 live quests (4 pages), 7 conditions | `bench_define_worst` (`baseline_define_worst`) | 144 437 982 | 151 659 882 | 3 408 480 | 20 | 13 | K + 1 + 3 × 4 = 20 reads; K + 3 + 3 = 13 writes (§5.1 lists them without a total) |
| `set_reporter` | — | `bench_set_reporter` (`baseline_deployed`) | 1 398 910 | 1 468 856 | 608 410 | 0 | 1 | — |
| `quest_is_unlocked` | 7 prerequisites, not cached | `bench_view_is_unlocked_worst` (`baseline_prerequisites`) | 26 707 562 | 28 042 941 | 539 310 | 10 | 0 | — |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` (`baseline_prerequisites`) | 26 476 332 | 27 800 149 | 308 080 | 3 | 0 | — |
| `quest_is_accepted` | — | `bench_view_is_accepted` (`baseline_prerequisites`) | 26 369 202 | 27 687 663 | 200 950 | 2 | 0 | — |
| `quest_current_interval` | — | `bench_view_current_interval` (`baseline_prerequisites`) | 26 330 862 | 27 647 406 | 162 610 | 1 | 0 | — |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` (`baseline_prerequisites`) | 26 463 512 | 27 786 688 | 295 260 | 2 | 0 | — |
| `quest_is_reporter` | — | `bench_view_is_reporter` (`baseline_prerequisites`) | 26 292 942 | 27 607 590 | 124 690 | 1 | 0 | — |

Fix loop 1 raised 70 budgets of `quiver_quest` by the cost of one check: `progress_many` now
skips a quest retired since its task's pages were read, about 100 L2 gas per quest reached
(+3 500 on the 28-quest `progress`, +45 500 on the 448-quest `progress_many`, setups included).
The orchestrator accepted the fix that needs it.

The integration budget (the worst call against Starknet's per-transaction ceiling) is in
[packages/quest/README.md](../packages/quest/README.md#integration-budget).

## `quiver_quest`: the library

Measured 2026-09-28 at `2982130` and again, unchanged, at `24578a7`, as written in `packages/quest/GAS.md` (ARC-03a's benchmarks,
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
