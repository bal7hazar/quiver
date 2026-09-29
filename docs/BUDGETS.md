# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-29 at `c29ece9` (ARC-03c, D-135), snforge 0.61, L2 gas. Each benchmark has a
baseline that runs the same setup without the call.

- **Call** is the benchmark minus its baseline: the entrypoint's own cost through a dispatcher,
  from a consumer whose hooks do nothing unless the row says otherwise.
- **Reads**, **writes** and **events** are the call's syscalls, the same difference taken from
  `snforge test --detailed-resources`. The reads of `progress` and `progress_many` include the
  reporter check (1 read).
- The **budget** is that of the benchmark test.
- **Changed slots** are the storage slots whose value the call changes.

### The cost of a changed slot

A storage slot changed by a transaction costs **about 402 000 L2 gas** beyond its write's
computation, once per slot per transaction (the state diff). A write that changes a slot costs
459 099; a second write to that slot, or a write that leaves it unchanged, costs 57 099. These
are ARC-03b's probes, re-measured unchanged (`test_component_probe`).

snforge counts a whole test as one transaction, so a benchmark pays only 57 099 for a slot its
setup already changed. The **transaction's figure** adds 402 000 for each such slot: that is what
the call costs in a transaction of its own. Details are in
[packages/quest/GAS.md](../packages/quest/GAS.md#cost-model-of-quiver_quest-010-arc-03c-d-135).

### The worst call against the cap

[A-G1 amendment](decisions/2026-09-28-A-G1-amendment-cost-cap.md): the worst call the package
allows must stay under 20 M L2 gas. Starknet's limit is 1.1 × 10⁹ L2 gas per transaction ("Max
L2 gas per transaction", docs.starknet.io, Learn > Cheatsheets > Chain info, read 2026-09-28).

The worst call is `progress_many` with 16 entries `[1..=15, 129]` (the slowest merge). Every
held quest completes, each on the batch's last three tasks, with a daily schedule. For H = 8,
entries 5 to 8 of the list are seeded, since `accept` stops at `MAX_HELD` = 4.

| Worst call | Benchmark | Test measured | Test budget | Call | Changed slots | Reads / writes / events | Against 20 M | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|---|---|
| **H = 4, hooks empty** | `bench_progress_many_worst_held4` | 15 786 233 | 16 575 545 | **6 131 373** | 8 | 23 / 8 / 4 | 31 % | 0.56 % |
| **H = 8, hooks empty** | `bench_progress_many_worst_held8` | 27 457 013 | 28 829 864 | **11 279 423** | 16 | 44 / 16 / 8 | 56 % | 1.03 % |
| **H = 4, a hook writing one slot** | `bench_progress_many_worst_held4_hook` | 17 601 153 | 18 481 211 | **7 946 293** | 12 | 23 / 12 / 4 | 40 % | 0.72 % |
| **H = 8, a hook writing one slot** | `bench_progress_many_worst_held8_hook` | 31 086 853 | 32 641 196 | **14 909 263** | 24 | 44 / 24 / 8 | 75 % | 1.36 % |
| Grim World's use: 16 entries, 3 quests and a daily contract held and completing, K ≤ 2, 3 quests per task | `game_case_three_per_task` | 81 349 348 | 85 416 816 | 4 471 716 (transaction: 5 275 716) | 8 | 23 / 8 / 4 | 26 % | 0.48 % |

All of them are under 20 M. The game's figure is the same with 2 quests per task
(`game_case_two_per_task`): quests that are not held are not read. Its transaction figure adds
2 × 402 000 for the records that `accept` changed in the same test.

### Per entrypoint

| Entrypoint | Case | Benchmark | Test measured | Test budget | Call | Changed slots (of them changed by the setup) | Transaction's figure | Reads / writes / events |
|---|---|---|---|---|---|---|---|---|
| `progress_many` | §5.1 witness, adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 557 578 846 | 585 457 789 | 5 549 156 | 8 (0) | 5 549 156 | 23 / 8 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` | 13 702 654 | 14 387 787 | 5 108 944 | 8 (0) | 5 108 944 | 23 / 8 / 4 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` | 10 628 516 | 11 159 942 | 2 034 806 | 2 (0) | 2 034 806 | 20 / 2 / 1 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` | 9 957 496 | 10 455 371 | 1 363 786 | 1 (0) | 1 363 786 | 16 / 1 / 0 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` | 9 496 786 | 9 971 626 | 903 076 | 0 | 903 076 | 16 / 0 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` | 4 189 366 | 4 398 835 | 1 369 256 | 2 (0) | 1 369 256 | 6 / 2 / 1 |
| `progress` | 1 held, counts | `bench_progress_plain` | 3 644 266 | 3 826 480 | 824 156 | 1 (0) | 824 156 | 5 / 1 / 0 |
| `progress` | nothing held | `bench_progress_nothing_held` | 2 287 716 | 2 402 102 | 213 576 | 0 | 213 576 | 2 / 0 / 0 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` | 1 077 296 | 1 131 161 | 212 366 | 0 | 212 366 | 1 / 0 / 1 |
| `progress_many`, event mode | 16 distinct entries | `bench_progress_many_event_mode_worst` | 2 125 426 | 2 231 698 | 1 260 496 | 0 | 1 260 496 | 1 / 0 / 16 |
| `progress_many`, event mode | `[1..=15, 129]`, late collision | `bench_progress_many_event_mode_late_collision` | 2 696 753 | 2 831 591 | 1 831 823 | 0 | 1 831 823 | 1 / 0 / 16 |
| `progress_many`, event mode | `[1..=15, 15]`, late duplicate | `bench_progress_many_event_mode_late_duplicate` | 2 639 133 | 2 771 090 | 1 774 203 | 0 | 1 774 203 | 1 / 0 / 15 |
| `accept` | **worst**: 7 prerequisites not cached, 4 dead entries (completed now) pruned | `bench_accept_worst_completed` | 39 269 736 | 41 233 223 | 1 287 300 | 3 (2) | **2 091 300** | 22 / 3 / 0 |
| `accept` | same, 4 entries expired at rollover | `bench_accept_worst_expired` | 34 141 102 | 35 848 158 | 1 125 540 | 3 (2) | 1 929 540 | 18 / 3 / 0 |
| `accept` | common: no prerequisite, empty list | `bench_accept_plain` | 2 820 110 | 2 961 116 | 745 970 | 1 (0) | 745 970 | 3 / 1 / 0 |
| `abandon` | **worst**: first of 4, the others move up | `bench_abandon_worst` | 9 098 170 | 9 553 079 | 504 460 | 2 (2) | **1 308 460** | 5 / 2 / 0 |
| `abandon` | second of 2 | `bench_abandon` | 4 855 220 | 5 097 981 | 386 420 | 1 (1) | 788 420 | 4 / 1 / 0 |
| `claim` | — | `bench_claim` | 4 553 386 | 4 781 056 | 364 020 | 2 (2) | 1 168 020 | 2 / 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 24 899 182 | 26 144 142 | 2 590 440 | 10 (7) | 5 404 440 | 8 / 10 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 25 902 802 | 27 197 943 | 1 003 240 | 8 (8) | 4 219 240 | 9 / 8 / 1 |
| `set_reporter` | — | `bench_set_reporter` | 1 473 140 | 1 546 797 | 608 210 | 1 (0) | 608 210 | 0 / 1 / 1 |
| `quest_is_unlocked` | K = 7, not cached | `bench_view_is_unlocked_worst` | 38 474 926 | 40 398 673 | 492 490 | 0 | — | 10 / 0 / 0 |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` | 38 286 836 | 40 201 178 | 304 400 | 0 | — | 3 / 0 / 0 |
| `quest_is_accepted` | full list, not held | `bench_view_is_accepted` | 38 275 526 | 40 189 303 | 293 090 | 0 | — | 4 / 0 / 0 |
| `quest_held` | full list | `bench_view_held_full` | 38 228 346 | 40 139 764 | 245 910 | 0 | — | 3 / 0 / 0 |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` | 38 270 726 | 40 184 263 | 288 290 | 0 | — | 2 / 0 / 0 |
| `quest_current_interval` | — | `bench_view_current_interval` | 38 143 066 | 40 050 220 | 160 630 | 0 | — | 1 / 0 / 0 |
| `quest_is_reporter` | — | `bench_view_is_reporter` | 38 107 126 | 40 012 483 | 124 690 | 0 | — | 1 / 0 / 0 |

### Slots each entrypoint changes

| Entrypoint | Best | Common | Worst |
|---|---|---|---|
| `progress`, `progress_many`, event mode | 0 | 0 | 0 |
| `progress`, `progress_many`, storage mode | 0 | 1 per quest that counts (P), 2 per quest that completes (P, R) | 2 × H (8 at H = 4, 16 at H = 8), plus what the hooks change. The held list: never |
| `accept` | 1 (the list slot of the new entry) | 1, or 2 when an unlock is cached (R) | 3 at H = 4: both list slots and R |
| `abandon` | 1 | 1 or 2 | 2 at H = 4: both list slots |
| `claim` | 2 | 2 | 2 |
| `define` | 2 (A, B) | 2 + C + K | 10: A, B, C, 7 prerequisites |
| `retire` | 1 (A) | 1 + K | 8: A, 7 prerequisites |
| `set_reporter` | 1 | 1 | 1 |

## `quiver_quest`: the library

Measured 2026-09-29 at `c29ece9`, as written in `packages/quest/GAS.md`
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
| `held_remove` | 8 entries, the first removed | `bench_held_remove_first` | 43 390 | 45 560 |
| `held_contains` | absent among 8 | `bench_held_contains_absent` | 38 210 | 40 121 |
| `held_position` | absent among 8 | `bench_held_position_absent` | 36 970 | 38 819 |
| `prerequisites_met` | 7 records | `bench_prerequisites_met_seven` | 29 700 | 31 185 |
| `QuestHeldSlot` pack and unpack | both entries at their maximum | `bench_pack_unpack_held_slot` | 26 090 | 27 395 |
| `held_slot` | the last slot of 8 entries | `bench_held_slot_last` | 25 350 | 26 618 |

The other functions (packing, records, schedules) are between 13 720 and 45 000 with their setup;
see `GAS.md`.
