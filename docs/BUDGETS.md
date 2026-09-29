# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-29 at `5a72315` (ARC-03c fix loop 3, D-135), snforge 0.61, L2 gas. Each
benchmark has a baseline that runs the same setup without the call.

- **Call** is the benchmark minus its baseline: the entrypoint's own cost through a dispatcher,
  from a consumer whose hooks do nothing unless the row says otherwise.
- **Reads** and **events** are the call's syscalls, the same difference taken from
  `snforge test --detailed-resources`. The reads of `progress` and `progress_many` include the
  reporter check (1 read).
- **Created / overwritten** count the slots the call writes: created when zero before the
  transaction, overwritten otherwise (a zeroing included). The held list is never zeroed; the
  one zeroing left is a reporter's revocation.
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
already exist and are overwritten. The hook's slot is new in both cases. Since fix loop 3 the walk also reads slot 0 after each
hook (the acceptance counter), which adds +109 700 at H = 4 and +302 660 at H = 8.

| Worst call | Benchmark | Test measured | Test budget | Call, snforge | Created / overwritten | Network estimate | Against 20 M (snforge / network) | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|---|---|
| **H = 4, created, hooks empty** | `bench_progress_many_worst_held4` | 16 212 473 | 17 023 097 | **6 292 283** | 8 / 0 | 6 247 435 | 31 % / 31 % | 0.57 % |
| H = 4, existing, hooks empty | `bench_progress_many_worst_held4_existing` | 16 363 773 | 17 181 962 | 3 076 283 | 0 / 8 | 2 875 435 | 15 % / 14 % | 0.28 % |
| **H = 4, created, a hook writing one slot** | `bench_progress_many_worst_held4_hook` | 18 027 393 | 18 928 763 | **8 107 203** | 12 / 0 | 8 039 931 | 41 % / 40 % | 0.74 % |
| H = 4, existing, a hook writing one slot | `bench_progress_many_worst_held4_existing_hook` | 18 178 693 | 19 087 628 | 4 891 203 | 4 / 8 | 4 667 931 | 24 % / 23 % | 0.44 % |
| **H = 8, created, hooks empty** | `bench_progress_many_worst_held8` | 28 143 253 | 29 550 416 | **11 676 993** | 16 / 0 | 11 587 297 | 58 % / 58 % | 1.06 % |
| H = 8, existing, hooks empty | `bench_progress_many_worst_held8_existing` | 28 444 023 | 29 866 225 | 5 244 993 | 0 / 16 | 4 843 297 | 26 % / 24 % | 0.48 % |
| **H = 8, created, a hook writing one slot** | `bench_progress_many_worst_held8_hook` | 31 773 093 | 33 361 748 | **15 306 833** | 24 / 0 | 15 172 289 | 77 % / 76 % | 1.39 % |
| H = 8, existing, a hook writing one slot | `bench_progress_many_worst_held8_existing_hook` | 32 073 863 | 33 677 557 | 8 874 833 | 8 / 16 | 8 428 289 | 44 % / 42 % | 0.81 % |
| Grim World's use: 16 entries, 3 quests and a daily contract completing, K ≤ 2 | `game_case_three_per_task` | 81 824 818 | 85 916 059 | 4 632 626 | 6 / 2 | 4 548 778 | 23 % / 23 % | 0.42 % |

All of them are under 20 M, by snforge's prices and by the network's.

### Per entrypoint

| Entrypoint | Case | Benchmark | Test measured | Test budget | Call | Created / overwritten | Network estimate | Reads / events |
|---|---|---|---|---|---|---|---|---|
| `progress_many` | §5.1 witness adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 557 967 536 | 585 865 913 | 5 710 066 | 8 / 0 | 5 665 218 | 25 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` | 14 091 344 | 14 795 912 | 5 269 854 | 8 / 0 | 5 225 006 | 25 / 4 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` | 11 017 206 | 11 568 067 | 2 195 716 | 2 / 0 | 2 184 504 | 22 / 1 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` | 10 217 276 | 10 728 140 | 1 395 786 | 1 / 0 | 1 390 180 | 16 / 0 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` | 9 756 566 | 10 244 395 | 935 076 | 0 / 0 | 935 076 | 16 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` | 4 224 366 | 4 435 585 | 1 383 196 | 2 / 0 | 1 371 984 | 6 / 1 |
| `progress` | 1 held, counts | `bench_progress_plain` | 3 679 266 | 3 863 230 | 838 096 | 1 / 0 | 832 490 | 5 / 0 |
| `progress` | nothing held | `bench_progress_nothing_held` | 2 301 246 | 2 416 309 | 227 106 | 0 / 0 | 227 106 | 2 / 0 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` | 1 078 096 | 1 132 001 | 213 166 | 0 / 0 | 213 166 | 1 / 1 |
| `progress_many`, event mode | 16 distinct entries | `bench_progress_many_event_mode_worst` | 2 126 226 | 2 232 538 | 1 261 296 | 0 / 0 | 1 261 296 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 129]`, late collision | `bench_progress_many_event_mode_late_collision` | 2 697 553 | 2 832 431 | 1 832 623 | 0 / 0 | 1 832 623 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 15]`, late duplicate | `bench_progress_many_event_mode_late_duplicate` | 2 639 933 | 2 771 930 | 1 775 003 | 0 / 0 | 1 775 003 | 1 / 15 |
| `accept` | **worst**: grows into a slot never used; K = 7 not cached | `bench_accept_growth` | 30 387 632 | 31 907 014 | 1 899 210 | 2 / 1 | 1 862 892 | 17 / 0 |
| `accept` | grows back into a slot used before | `bench_accept_regrow` | 9 166 380 | 9 624 699 | 690 420 | 0 / 2 | 640 208 | 8 / 0 |
| `accept` | mixed list: 2 live weekly, 2 stale daily; K = 7 | `bench_accept_mixed` | 35 269 252 | 37 032 715 | 1 657 340 | 1 / 2 | 1 601 522 | 20 / 0 |
| `accept` | 4 dead entries completed now, pruned; K = 7 | `bench_accept_worst_completed` | 40 408 396 | 42 428 816 | 1 733 550 | 1 / 2 | 1 677 732 | 22 / 0 |
| `accept` | 4 entries expired, pruned; K = 7 | `bench_accept_worst_expired` | 35 111 412 | 36 866 983 | 1 571 790 | 1 / 2 | 1 515 972 | 18 / 0 |
| `accept` | a player's first accept, no prerequisite | `bench_accept_plain` | 2 841 170 | 2 983 229 | 767 030 | 1 / 0 | 761 424 | 3 / 0 |
| `abandon` | **worst**: first of 4, the others move up | `bench_abandon_worst` | 9 369 410 | 9 837 881 | 547 920 | 0 / 2 | 497 708 | 5 / 0 |
| `abandon` | the third of 3: slot 1 no longer used, kept | `bench_abandon_shrink` | 7 265 790 | 7 629 080 | 443 860 | 0 / 1 | 418 754 | 4 / 0 |
| `abandon` | second of 2 | `bench_abandon` | 4 925 680 | 5 171 964 | 415 140 | 0 / 1 | 390 034 | 4 / 0 |
| `claim` | — | `bench_claim` | 4 588 386 | 4 817 806 | 364 020 | 0 / 2 | 313 808 | 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 25 140 162 | 26 397 171 | 2 590 440 | 3 / 7 | 2 397 880 | 8 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 26 143 782 | 27 450 972 | 1 003 240 | 0 / 8 | 802 392 | 9 / 1 |
| `set_reporter` | a new reporter | `bench_set_reporter` | 1 473 140 | 1 546 797 | 608 210 | 1 / 0 | 602 604 | 0 / 1 |
| `set_reporter` | a registered reporter revoked: the slot is zeroed | `bench_set_reporter_revoke` | 1 278 670 | 1 342 604 | −194 470 in the test; 207 530 in a transaction of its own | 0 / 1 | 182 424 | 0 / 1 |
| `set_reporter` | a registered reporter set again, unchanged | `bench_set_reporter_unchanged` | 1 680 470 | 1 764 494 | 207 330 | 0 / 1 | 182 224 | 0 / 1 |
| `quest_is_unlocked` | K = 7, not cached | `bench_view_is_unlocked_worst` | 39 167 336 | 41 125 703 | 492 490 | — | — | 10 / 0 |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` | 38 979 246 | 40 928 209 | 304 400 | — | — | 3 / 0 |
| `quest_is_accepted` | full list, not held | `bench_view_is_accepted` | 38 992 556 | 40 942 184 | 325 100 | — | — | 4 / 0 |
| `quest_held` | full list | `bench_view_held_full` | 38 958 296 | 40 906 211 | 291 540 | — | — | 3 / 0 |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` | 38 963 136 | 40 911 293 | 288 290 | — | — | 2 / 0 |
| `quest_current_interval` | — | `bench_view_current_interval` | 38 835 476 | 40 777 250 | 160 630 | — | — | 1 / 0 |
| `quest_is_reporter` | — | `bench_view_is_reporter` | 38 799 536 | 40 739 513 | 124 690 | — | — | 1 / 0 |

### Slots created and overwritten, per entrypoint

| Entrypoint | Best case | Common case | Worst case |
|---|---|---|---|
| `progress`, `progress_many`, event mode | none | none | none |
| `progress_many`, storage mode | none (nothing held counts) | per quest that counts, P created on its first count in the interval, overwritten later; per completion, R created at the first completion, overwritten later | 2H created (8 at H = 4); plus the hooks' own. The held list: never written |
| `accept` | 1 overwritten (slot 0) | 1 or 2 overwritten; R created when it caches a first unlock | 2 created (a never-used list slot, R) and 1 overwritten (slot 0). A player's first accept creates slot 0 |
| `abandon` | 1 overwritten | 1 or 2 overwritten | 2 overwritten; a slot the list stops using keeps its `kept` bit, never zeroed |
| `claim` | 2 writes, 1 changed slot, 1 overwritten (P) when `claims` is saturated: R is rewritten unchanged | 2 overwritten (P, R) | 2 overwritten |
| `define` | 2 created (A, B) | 3 created (A, B, C), K overwritten | 3 created, 7 overwritten |
| `retire` | 1 overwritten | 1 + K overwritten | 8 overwritten |
| `set_reporter` | 1 write, nothing changed (the value is already set) | 1 created (a new reporter); 1 zeroed (a registered reporter revoked) | 1 created |

**Kept slots** (fix loop 2): a held-list slot is never zeroed once it has held an entry. Growing
back into it costs 690 420 instead of 1 084 240 (about 640 000 instead of 1 053 500 at the
network's prices). The worst calls are not worse; the reasons are in `GAS.md`.

## `quiver_quest`: the library

Measured 2026-09-29 at `5a72315`, as written in `packages/quest/GAS.md`
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
