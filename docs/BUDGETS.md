# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-28 at `88b09f7` (ARC-03b, fix loop 2), snforge 0.61, L2 gas. Each benchmark
has a baseline that runs the same setup without the call. **Call** is the benchmark minus its
baseline: the entrypoint's own cost through a dispatcher, from a consumer whose hooks do nothing.
**Reads** and **writes** are the storage syscalls of the call, the same difference taken from
`snforge test --detailed-resources`; the reporter check of `progress` and `progress_many` (1
read) is counted apart. The **budget** is that of the benchmark test.

### The cost cap (A-G1 amendment, 2026-09-28): not met yet, escalated

The [amendment](decisions/2026-09-28-A-G1-amendment-cost-cap.md) requires the worst call the
package allows to stay under 20 M L2 gas. Under the bounds of A-G1 (16 entries, 28 quests per
task, 7 prerequisites) it is 683 M. **No caps that keep 16 entries per call meet 20 M**: one
quest per task and no prerequisite already measure 20 644 413. The caps are therefore not set in
this version of the branch; the choice is escalated with the measured options (ARC-03b report,
fix loop 2). The cost model of `progress_many` (E tasks, N quests per task, K prerequisites), the
measured options and Grim World's case are in
[packages/quest/GAS.md](../packages/quest/GAS.md#cost-model-of-progress_many-arc-03b-fix-loop-2).

### The maxima of `progress_many`

They are different quantities and are kept on separate lines.

| Line | Worst case | Benchmark (baseline) | Test measured | Test budget | Call | Reads | Writes | Note |
|---|---|---|---|---|---|---|---|---|
| **§5.1 storage-operation maximum** (A-G1 bounds) | 16 distinct tasks 1..=16 (fast merge) × 28 live quests, 448, K = 7 first observed, all completing | `quest_batch_bound_accepted` (`baseline_batch_bound_accepted`) | 1 973 846 068 | 2 072 538 372 | 682 740 366 | 5 440 | 896 | 5 440 reads, 896 writes |
| **Measured gas maximum** (A-G1 bounds) | The same witness, entries `[1..=15, 129]` (late collision, plain merge) | `bench_progress_many_worst_late_collision` (`baseline_progress_many_late_collision`) | 1 974 255 845 | 2 072 968 638 | 683 167 283 | 5 440 | 896 | — |
| Smallest configuration with 16 entries | 16 entries `[1..=15, 129]` × 1 quest × K = 0, all completing | `option_e16_n1_k0` (`baseline_option_e16_n1_k0`) | 42 132 323 | 44 238 940 | 20 644 413 | 80 | 32 | **above 20 M** |
| Grim World's case | 16 entries, 3 quests per task, 4 held quests completing (3 with an accept step, 1 daily contract), K ≤ 2 cached | `game_case_three_per_task` (`baseline_game_case_three_per_task`) | 98 784 008 | 103 723 209 | 10 144 166 | 160 | 8 | under 20 M |

### Per entrypoint

| Entrypoint | Worst case | Benchmark (baseline) | Test measured | Test budget | Call | Reads | Writes | §5.1 estimate |
|---|---|---|---|---|---|---|---|---|
| `progress`, event mode | 1 entry | `bench_progress_event_mode` (`baseline_deployed`) | 1 001 736 | 1 051 823 | 211 236 | 0 | 0 | 0 reads, 0 writes, 1 event |
| `progress_many`, event mode | 16 distinct entries (fast merge) | `bench_progress_many_event_mode_worst` (`baseline_deployed`) | 2 053 886 | 2 156 581 | 1 263 386 | 0 | 0 | 0, 0, 16 events |
| `progress_many`, event mode | `[1..=15, 129]`, late collision | `bench_progress_many_event_mode_late_collision` (`baseline_deployed`) | 2 625 213 | 2 756 474 | 1 834 713 | 0 | 0 | 0, 0, 16 events |
| `progress_many`, event mode | `[1..=15, 15]`, late duplicate, 15 events | `bench_progress_many_event_mode_late_duplicate` (`baseline_deployed`) | 2 567 393 | 2 695 763 | 1 776 893 | 0 | 0 | 0, 0, 15 events |
| `progress` | 1 task, 28 live quests, K = 7 first observed, all completing | `bench_progress_worst` (`baseline_progress_worst`) | 144 130 218 | 151 336 729 | 42 809 176 | 340 | 56 | 340 reads, 56 writes |
| `progress_many` | `[1..=15, 15]`: 15 tasks × 28 quests (420), K = 7, all completing | `bench_progress_many_worst_late_duplicate` (`baseline_progress_many_late_duplicate`) | 1 852 316 665 | 1 944 932 499 | 640 527 073 | 5 100 | 840 | 15 × 340, 15 × 56 |
| `progress` | 1 one-off quest, 1 task, not completing | `bench_progress_plain` (`baseline_plain`) | 3 387 696 | 3 557 081 | 855 386 | 4 | 1 | 4, 1 |
| `progress` | Same, completing | `bench_progress_plain_completing` (`baseline_plain`) | 3 936 036 | 4 132 838 | 1 403 726 | 5 | 2 | 5, 2 |
| `progress` | 1 accepted quest (unlock cached), not completing | `bench_progress_accepted` (`baseline_accepted`) | 28 026 018 | 29 427 319 | 916 106 | 5 | 1 | 5, 1 |
| `accept` | K = 7 met, not cached | `bench_accept_worst` (`baseline_prerequisites`) | 27 109 912 | 28 465 408 | 1 054 710 | 11 | 1 | 3 to 11 reads, 1 write |
| `abandon` | — | `bench_abandon` (`baseline_accepted`) | 27 378 872 | 28 747 816 | 268 960 | 2 | 1 | 2, 1 |
| `claim` | — | `bench_claim` (`baseline_completed`) | 4 305 336 | 4 520 603 | 369 300 | 2 | 2 | 2, 2 |
| `retire` | 3 tasks × 28 live quests, 7 conditions | `bench_retire_worst` (`baseline_retire_worst`) | 146 468 792 | 153 792 232 | 2 145 780 | 22 | 14 | ≤ 22, ≤ 14 |
| `define` | 3 tasks × 27 live quests, 7 conditions | `bench_define_worst` (`baseline_define_worst`) | 144 324 932 | 151 541 179 | 3 408 480 | 20 | 13 | 20 reads, 13 writes |
| `set_reporter` | — | `bench_set_reporter` (`baseline_deployed`) | 1 398 910 | 1 468 856 | 608 410 | 0 | 1 | — |
| `quest_is_unlocked` | K = 7, not cached | `bench_view_is_unlocked_worst` (`baseline_prerequisites`) | 26 578 052 | 27 906 955 | 522 850 | 10 | 0 | — |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` (`baseline_prerequisites`) | 26 363 282 | 27 681 447 | 308 080 | 3 | 0 | — |
| `quest_is_accepted` | — | `bench_view_is_accepted` (`baseline_prerequisites`) | 26 256 152 | 27 568 960 | 200 950 | 2 | 0 | — |
| `quest_current_interval` | — | `bench_view_current_interval` (`baseline_prerequisites`) | 26 217 812 | 27 528 703 | 162 610 | 1 | 0 | — |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` (`baseline_prerequisites`) | 26 350 462 | 27 667 986 | 295 260 | 2 | 0 | — |
| `quest_is_reporter` | — | `bench_view_is_reporter` (`baseline_prerequisites`) | 26 179 892 | 27 488 887 | 124 690 | 1 | 0 | — |

The worst cases above are those of the bounds of A-G1, which the cost cap will replace. Fix
loop 2 removed some work per quest (`progress_many` from 704.8 M to 683.2 M on its worst case,
-3.1 %); the cost of a completed quest is mostly its two changed storage slots (GAS.md, unit
costs).

## `quiver_quest`: the library

Measured 2026-09-28 at `2982130` and again, unchanged, at `24578a7` and `88b09f7`, as written in `packages/quest/GAS.md` (ARC-03a's benchmarks,
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
