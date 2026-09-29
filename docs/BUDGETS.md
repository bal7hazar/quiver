# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-29 at `b2260a2` (ARC-03c fix loop 2, D-135), snforge 0.61, L2 gas. Each
benchmark has a baseline that runs the same setup without the call.

- **Call** is the benchmark minus its baseline: the entrypoint's own cost through a dispatcher,
  from a consumer whose hooks do nothing unless the row says otherwise.
- **Reads** and **events** are the call's syscalls, the same difference taken from
  `snforge test --detailed-resources`. The reads of `progress` and `progress_many` include the
  reporter check (1 read).
- **Created / overwritten** count the slots the call writes: created when zero before the
  transaction, overwritten otherwise. No entrypoint zeroes a slot.
- The **budget** is that of the benchmark test.

### The price of a slot: snforge and the network

| Written slot | snforge 0.61 (these figures) | The network (FND-04, 149 Sepolia transactions; [decision](decisions/2026-09-28-quest-cost-cap.md), correction of 2026-09-29) |
|---|---|---|
| Created (zero → non-zero) | 459 106 (write 57 106 + allocation 402 000) | about 453 500 |
| Overwritten or zeroed | 57 106 | about 32 000 |

**The figures below are snforge's.** The **network estimate** reprices each slot the call writes
at the network's price: −5 606 per created slot and −25 106 per overwritten one. Details and
probes are in
[packages/quest/GAS.md](../packages/quest/GAS.md#cost-model-of-quiver_quest-010-arc-03c-d-135).

### The worst call against the cap

[A-G1 amendment](decisions/2026-09-28-A-G1-amendment-cost-cap.md): the worst call the package
allows must stay under 20 M L2 gas. Starknet's limit is 1.1 × 10⁹ L2 gas per transaction ("Max
L2 gas per transaction", docs.starknet.io, Learn > Cheatsheets > Chain info, read 2026-09-28).

**The case.**

- `progress_many` with 16 entries `[1..=15, 129]`, the slowest merge.
- Every held quest completes, each on the batch's last three tasks, with a daily schedule.
- For H = 8, entries 5 to 8 of the list are seeded, since `accept` stops at `MAX_HELD` = 4.

**Created**: the player's P and R slots are new (a first count in the interval, a first
completion); this is the worst, and **the figure set against the cap**. **Existing**: P and R
already exist and are overwritten. The hook's slot is new in both cases.

| Worst call | Benchmark | Test measured | Test budget | Call, snforge | Created / overwritten | Network estimate | Against 20 M (snforge / network) | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|---|---|
| **H = 4, created, hooks empty** | `bench_progress_many_worst_held4` | 16 102 773 | 16 907 912 | **6 182 583** | 8 / 0 | 6 137 735 | 31 % / 31 % | 0.56 % |
| H = 4, existing, hooks empty | `bench_progress_many_worst_held4_existing` | 16 254 073 | 17 066 777 | 2 966 583 | 0 / 8 | 2 765 735 | 15 % / 14 % | 0.27 % |
| **H = 4, created, a hook writing one slot** | `bench_progress_many_worst_held4_hook` | 17 917 693 | 18 813 578 | **7 997 503** | 12 / 0 | 7 930 231 | 40 % / 40 % | 0.73 % |
| H = 4, existing, a hook writing one slot | `bench_progress_many_worst_held4_existing_hook` | 18 068 993 | 18 972 443 | 4 781 503 | 4 / 8 | 4 558 231 | 24 % / 23 % | 0.43 % |
| **H = 8, created, hooks empty** | `bench_progress_many_worst_held8` | 27 840 593 | 29 232 623 | **11 374 333** | 16 / 0 | 11 284 637 | 57 % / 56 % | 1.03 % |
| H = 8, existing, hooks empty | `bench_progress_many_worst_held8_existing` | 28 141 363 | 29 548 432 | 4 942 333 | 0 / 16 | 4 540 637 | 25 % / 23 % | 0.45 % |
| **H = 8, created, a hook writing one slot** | `bench_progress_many_worst_held8_hook` | 31 470 433 | 33 043 955 | **15 004 173** | 24 / 0 | 14 869 629 | 75 % / 74 % | 1.36 % |
| H = 8, existing, a hook writing one slot | `bench_progress_many_worst_held8_existing_hook` | 31 771 203 | 33 359 764 | 8 572 173 | 8 / 16 | 8 125 629 | 43 % / 41 % | 0.78 % |
| Grim World's use: 16 entries, 3 quests and a daily contract completing, K ≤ 2 | `game_case_three_per_task` | 81 703 648 | 85 788 831 | 4 522 926 | 6 / 2 | 4 439 078 | 23 % / 22 % | 0.41 % |

All of them are under 20 M, by snforge's prices and by the network's.

### Per entrypoint

| Entrypoint | Case | Benchmark | Test measured | Test budget | Call | Created / overwritten | Network estimate | Reads / events |
|---|---|---|---|---|---|---|---|---|
| `progress_many` | §5.1 witness adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 557 857 836 | 585 750 728 | 5 600 366 | 8 / 0 | 5 555 518 | 23 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` | 13 981 644 | 14 680 727 | 5 160 154 | 8 / 0 | 5 115 306 | 23 / 4 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` | 10 907 506 | 11 452 882 | 2 086 016 | 2 / 0 | 2 074 804 | 20 / 1 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` | 10 210 686 | 10 721 221 | 1 389 196 | 1 / 0 | 1 383 590 | 16 / 0 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` | 9 749 976 | 10 237 475 | 928 486 | 0 / 0 | 928 486 | 16 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` | 4 218 736 | 4 429 673 | 1 377 566 | 2 / 0 | 1 366 354 | 6 / 1 |
| `progress` | 1 held, counts | `bench_progress_plain` | 3 673 636 | 3 857 318 | 832 466 | 1 / 0 | 826 860 | 5 / 0 |
| `progress` | nothing held | `bench_progress_nothing_held` | 2 295 816 | 2 410 607 | 221 676 | 0 / 0 | 221 676 | 2 / 0 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` | 1 077 296 | 1 131 161 | 213 166 | 0 / 0 | 213 166 | 1 / 1 |
| `progress_many`, event mode | 16 distinct entries | `bench_progress_many_event_mode_worst` | 2 125 426 | 2 231 698 | 1 261 296 | 0 / 0 | 1 261 296 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 129]`, late collision | `bench_progress_many_event_mode_late_collision` | 2 696 753 | 2 831 591 | 1 832 623 | 0 / 0 | 1 832 623 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 15]`, late duplicate | `bench_progress_many_event_mode_late_duplicate` | 2 639 133 | 2 771 090 | 1 775 003 | 0 / 0 | 1 775 003 | 1 / 15 |
| `accept` | **worst**: grows into a slot never used; K = 7 not cached | `bench_accept_growth` | 30 348 222 | 31 865 634 | 1 899 210 | 2 / 1 | 1 862 892 | 17 / 0 |
| `accept` | grows back into a slot used before | `bench_accept_regrow` | 9 166 380 | 9 624 699 | 690 420 | 0 / 2 | 640 208 | 8 / 0 |
| `accept` | mixed list: 2 live weekly, 2 stale daily; K = 7 | `bench_accept_mixed` | 35 229 842 | 36 991 335 | 1 657 340 | 1 / 2 | 1 601 522 | 20 / 0 |
| `accept` | 4 dead entries completed now, pruned; K = 7 | `bench_accept_worst_completed` | 40 259 286 | 42 272 251 | 1 733 550 | 1 / 2 | 1 677 732 | 22 / 0 |
| `accept` | 4 entries expired, pruned; K = 7 | `bench_accept_worst_expired` | 35 072 002 | 36 825 603 | 1 571 790 | 1 / 2 | 1 515 972 | 18 / 0 |
| `accept` | a player's first accept, no prerequisite | `bench_accept_plain` | 2 841 170 | 2 983 229 | 767 030 | 1 / 0 | 761 424 | 3 / 0 |
| `abandon` | **worst**: first of 4, the others move up | `bench_abandon_worst` | 9 369 410 | 9 837 881 | 547 920 | 0 / 2 | 497 708 | 5 / 0 |
| `abandon` | the third of 3: slot 1 no longer used, kept | `bench_abandon_shrink` | 7 265 790 | 7 629 080 | 443 860 | 0 / 1 | 418 754 | 4 / 0 |
| `abandon` | second of 2 | `bench_abandon` | 4 925 680 | 5 171 964 | 415 140 | 0 / 1 | 390 034 | 4 / 0 |
| `claim` | — | `bench_claim` | 4 582 756 | 4 811 894 | 364 020 | 0 / 2 | 313 808 | 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 25 100 752 | 26 355 790 | 2 590 440 | 3 / 7 | 2 397 880 | 8 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 26 104 372 | 27 409 591 | 1 003 240 | 0 / 8 | 802 392 | 9 / 1 |
| `set_reporter` | a new reporter | `bench_set_reporter` | 1 473 140 | 1 546 797 | 608 210 | 1 / 0 | 602 604 | 0 / 1 |
| `quest_is_unlocked` | K = 7, not cached | `bench_view_is_unlocked_worst` | 39 018 226 | 40 969 138 | 492 490 | — | — | 10 / 0 |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` | 38 830 136 | 40 771 643 | 304 400 | — | — | 3 / 0 |
| `quest_is_accepted` | full list, not held | `bench_view_is_accepted` | 38 843 446 | 40 785 619 | 325 100 | — | — | 4 / 0 |
| `quest_held` | full list | `bench_view_held_full` | 38 809 186 | 40 749 646 | 291 540 | — | — | 3 / 0 |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` | 38 814 026 | 40 754 728 | 288 290 | — | — | 2 / 0 |
| `quest_current_interval` | — | `bench_view_current_interval` | 38 686 366 | 40 620 685 | 160 630 | — | — | 1 / 0 |
| `quest_is_reporter` | — | `bench_view_is_reporter` | 38 650 426 | 40 582 948 | 124 690 | — | — | 1 / 0 |

### Slots created and overwritten, per entrypoint

| Entrypoint | Best case | Common case | Worst case |
|---|---|---|---|
| `progress`, `progress_many`, event mode | none | none | none |
| `progress_many`, storage mode | none (nothing held counts) | per quest that counts, P created on its first count in the interval, overwritten later; per completion, R created at the first completion, overwritten later | 2H created (8 at H = 4); plus the hooks' own. The held list: never written |
| `accept` | 1 overwritten (slot 0) | 1 or 2 overwritten; R created when it caches a first unlock | 2 created (a never-used list slot, R) and 1 overwritten (slot 0). A player's first accept creates slot 0 |
| `abandon` | 1 overwritten | 1 or 2 overwritten | 2 overwritten; a slot the list stops using keeps its `kept` bit, never zeroed |
| `claim` | 1 overwritten (P) when `claims` is saturated | 2 overwritten (P, R) | 2 overwritten |
| `define` | 2 created (A, B) | 3 created (A, B, C), K overwritten | 3 created, 7 overwritten |
| `retire` | 1 overwritten | 1 + K overwritten | 8 overwritten |
| `set_reporter` | nothing changed (the value is already set) | 1 created (a new reporter) | 1 created |

**Kept slots** (fix loop 2): a held-list slot is never zeroed once it has held an entry. Growing
back into it costs 690 420 instead of 1 084 240 (about 640 000 instead of 1 053 500 at the
network's prices). The worst calls are not worse; the reasons are in `GAS.md`.

## `quiver_quest`: the library

Measured 2026-09-29 at `b2260a2`, as written in `packages/quest/GAS.md`
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
| `QuestHeldSlot` pack and unpack | both entries' ids and intervals at their maximum | `bench_pack_unpack_held_slot` | 37 500 | 39 375 |
| `prerequisites_met` | 7 records | `bench_prerequisites_met_seven` | 29 700 | 31 185 |
| `held_slot` | the last slot of 8 entries | `bench_held_slot_last` | 29 960 | 31 458 |

The other functions (packing, records, schedules) are between 13 720 and 45 000 with their setup;
see `GAS.md`.
