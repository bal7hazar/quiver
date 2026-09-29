# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-29 at `94b6d5d` (ARC-03c fix loop 1, D-135), snforge 0.61, L2 gas. Each
benchmark has a baseline that runs the same setup without the call.

- **Call** is the benchmark minus its baseline: the entrypoint's own cost through a dispatcher,
  from a consumer whose hooks do nothing unless the row says otherwise.
- **Reads**, **writes** and **events** are the call's syscalls, the same difference taken from
  `snforge test --detailed-resources`. The reads of `progress` and `progress_many` include the
  reporter check (1 read).
- **Allocations** are the storage cells the call takes from zero to non-zero.
- The **budget** is that of the benchmark test.

### The cost of a write

Every storage write costs 57 106 L2 gas. A write that **allocates** a cell costs **402 000
more**: the cell is zero at the start of the transaction and non-zero at its end (the allocation
cost of blockifier 0.14.2's versioned constants, counted from the final state diff). An update
of a non-zero cell, a clear, a write back to the initial value and an unchanged write pay no
allocation. Each transition is measured in its own test (`test_component_probe`,
`probe_transition_*`).

snforge counts a whole test as one transaction. A call that clears a cell its setup allocated
therefore reads 402 000 low. Such rows are marked "(clear)", with the transaction's figure
beside them. Every other figure is the transaction's.

Details are in
[packages/quest/GAS.md](../packages/quest/GAS.md#cost-model-of-quiver_quest-010-arc-03c-d-135).

### The worst call against the cap

[A-G1 amendment](decisions/2026-09-28-A-G1-amendment-cost-cap.md): the worst call the package
allows must stay under 20 M L2 gas. Starknet's limit is 1.1 × 10⁹ L2 gas per transaction ("Max
L2 gas per transaction", docs.starknet.io, Learn > Cheatsheets > Chain info, read 2026-09-28).

The worst call is `progress_many` with 16 entries `[1..=15, 129]` (the slowest merge). Every
held quest completes, each on the batch's last three tasks, with a daily schedule. For H = 8,
entries 5 to 8 of the list are seeded, since `accept` stops at `MAX_HELD` = 4.

It is allocation-heavy: every P and R it writes is allocated (the first count of the interval,
the first completion), so **the figures stand as measured**. With records that already exist,
each completion costs 402 000 less.

| Worst call | Benchmark | Test measured | Test budget | Call | Writes / allocations | Reads / events | Against 20 M | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|---|---|
| **H = 4, hooks empty** | `bench_progress_many_worst_held4` | 16 084 843 | 16 889 086 | **6 187 453** | 8 / 8 | 23 / 4 | 31 % | 0.56 % |
| **H = 8, hooks empty** | `bench_progress_many_worst_held8` | 27 815 963 | 29 206 762 | **11 376 913** | 16 / 16 | 44 / 8 | 57 % | 1.03 % |
| **H = 4, a hook writing one slot** | `bench_progress_many_worst_held4_hook` | 17 899 763 | 18 794 752 | **8 002 373** | 12 / 12 | 23 / 4 | 40 % | 0.73 % |
| **H = 8, a hook writing one slot** | `bench_progress_many_worst_held8_hook` | 31 445 803 | 33 018 094 | **15 006 753** | 24 / 24 | 44 / 8 | 75 % | 1.36 % |
| Grim World's use: 16 entries, 3 quests and a daily contract held and completing, K ≤ 2, 3 quests per task | `game_case_three_per_task` | 81 675 438 | 85 759 210 | 4 527 796 | 8 / 6 | 23 / 4 | 23 % | 0.41 % |

All of them are under 20 M. The game's figure is the same with 2 quests per task
(`game_case_two_per_task`): quests that are not held are not read. The records of the two quests
with prerequisites are updates, since `accept` cached their unlock, so its measure is the
transaction's figure. The +0.80 M correction of the first version was wrong.

### Per entrypoint

| Entrypoint | Case | Benchmark | Test measured | Test budget | Call | Writes / allocations | Transaction's figure | Reads / events |
|---|---|---|---|---|---|---|---|---|
| `progress_many` | §5.1 witness, adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 557 835 126 | 585 726 883 | 5 605 236 | 8 / 8 | 5 605 236 | 23 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` | 13 958 934 | 14 656 881 | 5 165 024 | 8 / 8 | 5 165 024 | 23 / 4 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` | 10 884 796 | 11 429 036 | 2 090 886 | 2 / 2 | 2 090 886 | 20 / 1 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` | 10 187 286 | 10 696 651 | 1 393 376 | 1 / 1 | 1 393 376 | 16 / 0 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` | 9 726 576 | 10 212 905 | 932 666 | 0 / 0 | 932 666 | 16 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` | 4 217 686 | 4 428 571 | 1 382 226 | 2 / 2 | 1 382 226 | 6 / 1 |
| `progress` | 1 held, counts | `bench_progress_plain` | 3 672 586 | 3 856 216 | 837 126 | 1 / 1 | 837 126 | 5 / 0 |
| `progress` | nothing held | `bench_progress_nothing_held` | 2 300 376 | 2 415 395 | 226 236 | 0 / 0 | 226 236 | 2 / 0 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` | 1 078 096 | 1 132 001 | 213 166 | 0 / 0 | 213 166 | 1 / 1 |
| `progress_many`, event mode | 16 distinct entries | `bench_progress_many_event_mode_worst` | 2 126 226 | 2 232 538 | 1 261 296 | 0 / 0 | 1 261 296 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 129]`, late collision | `bench_progress_many_event_mode_late_collision` | 2 697 553 | 2 832 431 | 1 832 623 | 0 / 0 | 1 832 623 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 15]`, late duplicate | `bench_progress_many_event_mode_late_duplicate` | 2 639 933 | 2 771 930 | 1 775 003 | 0 / 0 | 1 775 003 | 1 / 15 |
| `accept` | **worst**: the list grows into slot 1 (allocated); K = 7 not cached (R allocated) | `bench_accept_growth` | 30 328 862 | 31 845 306 | 1 889 960 | 3 / 2 | **1 889 960** | 17 / 0 |
| `accept` | mixed list: 2 live weekly and 2 stale daily entries; K = 7 not cached | `bench_accept_mixed` | 35 201 612 | 36 961 693 | 1 648 390 | 3 / 1 | 1 648 390 | 20 / 0 |
| `accept` | 4 dead entries completed now, pruned; K = 7 (clear) | `bench_accept_worst_completed` | 39 834 526 | 41 826 253 | 1 322 500 | 3 / 1 | 1 724 500 | 22 / 0 |
| `accept` | 4 entries expired at rollover, pruned; K = 7 (clear) | `bench_accept_worst_expired` | 34 642 372 | 36 374 491 | 1 160 740 | 3 / 1 | 1 562 740 | 18 / 0 |
| `accept` | common: no prerequisite, empty list, first accept | `bench_accept_plain` | 2 835 460 | 2 977 233 | 761 320 | 1 / 1 | 761 320 | 3 / 0 |
| `abandon` | **worst**: first of 4, the others move up | `bench_abandon_worst` | 9 332 780 | 9 799 419 | 538 870 | 2 / 0 | 538 870 | 5 / 0 |
| `abandon` | second of 2 | `bench_abandon` | 4 910 020 | 5 155 521 | 409 730 | 1 / 0 | 409 730 | 4 / 0 |
| `claim` | — | `bench_claim` | 4 581 706 | 4 810 792 | 364 020 | 2 / 0 | 364 020 | 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 25 099 822 | 26 354 814 | 2 590 440 | 10 / 3 | 2 590 440 | 8 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 26 103 442 | 27 408 615 | 1 003 240 | 8 / 0 | 1 003 240 | 9 / 1 |
| `set_reporter` | a new reporter | `bench_set_reporter` | 1 473 140 | 1 546 797 | 608 210 | 1 / 1 | 608 210 | 0 / 1 |
| `quest_is_unlocked` | K = 7, not cached | `bench_view_is_unlocked_worst` | 39 004 516 | 40 954 742 | 492 490 | 0 / 0 | — | 10 / 0 |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` | 38 816 426 | 40 757 248 | 304 400 | 0 / 0 | — | 3 / 0 |
| `quest_is_accepted` | full list, not held | `bench_view_is_accepted` | 38 833 816 | 40 775 507 | 321 790 | 0 / 0 | — | 4 / 0 |
| `quest_held` | full list | `bench_view_held_full` | 38 800 256 | 40 740 269 | 288 230 | 0 / 0 | — | 3 / 0 |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` | 38 800 316 | 40 740 332 | 288 290 | 0 / 0 | — | 2 / 0 |
| `quest_current_interval` | — | `bench_view_current_interval` | 38 672 656 | 40 606 289 | 160 630 | 0 / 0 | — | 1 / 0 |
| `quest_is_reporter` | — | `bench_view_is_reporter` | 38 636 716 | 40 568 552 | 124 690 | 0 / 0 | — | 1 / 0 |

### Writes, changed slots and allocations per entrypoint

| Entrypoint | Writes | Changed slots | Allocations |
|---|---|---|---|
| `progress`, `progress_many`, event mode | 0 | 0 | 0 |
| `progress`, `progress_many`, storage mode | 1 per quest that counts (P), + 1 per completion (R); the held list never | = writes | P on a quest's first count in an interval; R on a first completion when the record is zero. Worst: 2H (8 at H = 4), plus the hooks' own |
| `accept` | 1 or 2 list slots (slot 0 always, for the counter), + R when it caches an unlock | = writes | 0 to 2: slot 0 only at a player's first accept; slot 1 when the list grows into it from zero; R when the record is zero |
| `abandon` | 1 or 2 list slots | = writes | 0 |
| `claim` | 2 (P, R) | 2; 1 (P) when `claims` is saturated | 0 |
| `define` | 2 without conditions (A, B); 3 + K with K > 0 (A, B, C, K prerequisites) | = writes | 2 (A, B), or 3 with conditions |
| `retire` | 1 + K | = writes | 0 |
| `set_reporter` | 1 | 1; 0 when the value is already set | 1 for a new reporter; 0 otherwise |

## `quiver_quest`: the library

Measured 2026-09-29 at `94b6d5d`, as written in `packages/quest/GAS.md`
(`packages/quest/tests/test_bench.cairo`). A figure includes the test's setup; the function's own
cost is the benchmark minus its `bench_baseline_*`.

| Algorithm | Worst case | Benchmark | Measured | Budget |
|---|---|---|---|---|
| `batch_merge` | 16 entries, a modulo-128 collision at the 16th | `bench_batch_merge_late_modulo_collision` | 753 023 | 790 675 |
| `batch_merge` | 16 entries, a repeat at the 16th | `bench_batch_merge_late_duplicate` | 749 113 | 786 569 |
| `batch_merge` | 16 distinct entries (fast path) | `bench_batch_merge_sixteen_distinct` | 181 896 | 190 991 |
| `progress_add` | 3 tasks, 16 entries | `bench_progress_add_three_tasks_sixteen_entries` | 156 430 | 164 252 |
| `definition_new` | 3 tasks, 7 conditions | `bench_definition_new_three_tasks_seven_conditions` | 150 760 | 158 298 |
| `batch_first_position` | absent among 16 | `bench_batch_first_position_absent` | 110 490 | 116 015 |
| `batch_count_of` | absent among 16 | `bench_batch_count_of_absent` | 90 590 | 95 120 |
| `held_remove` | 8 entries, the first removed | `bench_held_remove_first` | 46 400 | 48 720 |
| `held_contains` | absent among 8 | `bench_held_contains_absent` | 41 270 | 43 334 |
| `held_position` | absent among 8 | `bench_held_position_absent` | 38 570 | 40 499 |
| `QuestHeldSlot` pack and unpack | both entries' ids and intervals at their maximum | `bench_pack_unpack_held_slot` | 35 920 | 37 716 |
| `prerequisites_met` | 7 records | `bench_prerequisites_met_seven` | 29 700 | 31 185 |
| `held_slot` | the last slot of 8 entries | `bench_held_slot_last` | 28 450 | 29 873 |

The other functions (packing, records, schedules) are between 13 720 and 45 000 with their setup;
see `GAS.md`.
