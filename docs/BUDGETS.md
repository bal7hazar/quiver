# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-29 at `21f3066` (ARC-03c fix loop 4, D-135), snforge 0.61, L2 gas. Each
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
already exist and are overwritten. The hook's slot is new in both cases. Since fix loop 4, acceptance numbers have 30 bits and the
walk compares whole entries after a hook, without the extra read of slot 0 that fix loop 3 added.

| Worst call | Benchmark | Test measured | Test budget | Call, snforge | Created / overwritten | Network estimate | Against 20 M (snforge / network) | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|---|---|
| **H = 4, created, hooks empty** | `bench_progress_many_worst_held4` | 16 216 753 | 17 027 591 | **6 213 063** | 8 / 0 | 6 168 215 | 31 % / 31 % | 0.56 % |
| H = 4, existing, hooks empty | `bench_progress_many_worst_held4_existing` | 16 368 053 | 17 186 456 | 2 997 063 | 0 / 8 | 2 796 215 | 15 % / 14 % | 0.27 % |
| **H = 4, created, a hook writing one slot** | `bench_progress_many_worst_held4_hook` | 18 031 673 | 18 933 257 | **8 027 983** | 12 / 0 | 7 960 711 | 40 % / 40 % | 0.73 % |
| H = 4, existing, a hook writing one slot | `bench_progress_many_worst_held4_existing_hook` | 18 182 973 | 19 092 122 | 4 811 983 | 4 / 8 | 4 588 711 | 24 % / 23 % | 0.44 % |
| **H = 8, created, hooks empty** | `bench_progress_many_worst_held8` | 27 987 733 | 29 387 120 | **11 430 213** | 16 / 0 | 11 340 517 | 57 % / 57 % | 1.04 % |
| H = 8, existing, hooks empty | `bench_progress_many_worst_held8_existing` | 28 288 503 | 29 702 929 | 4 998 213 | 0 / 16 | 4 596 517 | 25 % / 23 % | 0.45 % |
| **H = 8, created, a hook writing one slot** | `bench_progress_many_worst_held8_hook` | 31 617 573 | 33 198 452 | **15 060 053** | 24 / 0 | 14 925 509 | 75 % / 75 % | 1.37 % |
| H = 8, existing, a hook writing one slot | `bench_progress_many_worst_held8_existing_hook` | 31 918 343 | 33 514 261 | 8 628 053 | 8 / 16 | 8 181 509 | 43 % / 41 % | 0.78 % |
| Grim World's use: 16 entries, 3 quests and a daily contract completing, K ≤ 2 | `game_case_three_per_task` | 81 846 308 | 85 938 624 | 4 553 406 | 6 / 2 | 4 469 558 | 23 % / 22 % | 0.41 % |

All of them are under 20 M, by snforge's prices and by the network's.

### Per entrypoint

| Entrypoint | Case | Benchmark | Test measured | Test budget | Call | Created / overwritten | Network estimate | Reads / events |
|---|---|---|---|---|---|---|---|---|
| `progress_many` | §5.1 witness adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 557 956 576 | 585 854 405 | 5 630 846 | 8 / 0 | 5 585 998 | 25 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` | 14 080 384 | 14 784 404 | 5 190 634 | 8 / 0 | 5 145 786 | 25 / 4 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` | 11 006 246 | 11 556 559 | 2 116 496 | 2 / 0 | 2 105 284 | 22 / 1 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` | 10 294 186 | 10 808 896 | 1 404 436 | 1 / 0 | 1 398 830 | 16 / 0 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` | 9 833 476 | 10 325 150 | 943 726 | 0 / 0 | 943 726 | 16 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` | 4 235 616 | 4 447 397 | 1 382 646 | 2 / 0 | 1 371 434 | 6 / 1 |
| `progress` | 1 held, counts | `bench_progress_plain` | 3 690 516 | 3 875 042 | 837 546 | 1 / 0 | 831 940 | 5 / 0 |
| `progress` | nothing held | `bench_progress_nothing_held` | 2 300 896 | 2 415 941 | 226 756 | 0 / 0 | 226 756 | 2 / 0 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` | 1 077 296 | 1 131 161 | 212 366 | 0 / 0 | 212 366 | 1 / 1 |
| `progress_many`, event mode | 16 distinct entries | `bench_progress_many_event_mode_worst` | 2 125 426 | 2 231 698 | 1 260 496 | 0 / 0 | 1 260 496 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 129]`, late collision | `bench_progress_many_event_mode_late_collision` | 2 696 753 | 2 831 591 | 1 831 823 | 0 / 0 | 1 831 823 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 15]`, late duplicate | `bench_progress_many_event_mode_late_duplicate` | 2 639 133 | 2 771 090 | 1 774 203 | 0 / 0 | 1 774 203 | 1 / 15 |
| `accept` | **worst**: grows into a slot never used; K = 7 not cached | `bench_accept_growth` | 30 512 312 | 32 037 928 | 1 921 540 | 2 / 1 | 1 885 222 | 17 / 0 |
| `accept` | grows back into a slot used before | `bench_accept_regrow` | 9 250 250 | 9 712 763 | 712 750 | 0 / 2 | 662 538 | 8 / 0 |
| `accept` | mixed list: 2 live weekly, 2 stale daily; K = 7 | `bench_accept_mixed` | 35 474 152 | 37 247 860 | 1 684 750 | 1 / 2 | 1 628 932 | 20 / 0 |
| `accept` | 4 dead entries completed now, pruned; K = 7 | `bench_accept_worst_completed` | 40 534 076 | 42 560 780 | 1 760 960 | 1 / 2 | 1 705 142 | 22 / 0 |
| `accept` | 4 entries expired, pruned; K = 7 | `bench_accept_worst_expired` | 35 316 312 | 37 082 128 | 1 599 200 | 1 / 2 | 1 543 382 | 18 / 0 |
| `accept` | a player's first accept, no prerequisite | `bench_accept_plain` | 2 852 970 | 2 995 619 | 778 830 | 1 / 0 | 773 224 | 3 / 0 |
| `abandon` | **worst**: first of 4, the others move up | `bench_abandon_worst` | 9 463 810 | 9 937 001 | 574 060 | 0 / 2 | 523 848 | 5 / 0 |
| `abandon` | the third of 3: slot 1 no longer used, kept | `bench_abandon_shrink` | 7 327 330 | 7 693 697 | 459 470 | 0 / 1 | 434 364 | 4 / 0 |
| `abandon` | second of 2 | `bench_abandon` | 4 964 890 | 5 213 135 | 430 750 | 0 / 1 | 405 644 | 4 / 0 |
| `claim` | — | `bench_claim` | 4 599 636 | 4 829 618 | 364 020 | 0 / 2 | 313 808 | 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 25 218 912 | 26 479 858 | 2 590 440 | 3 / 7 | 2 397 880 | 8 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 26 222 532 | 27 533 659 | 1 003 240 | 0 / 8 | 802 392 | 9 / 1 |
| `set_reporter` | a new reporter | `bench_set_reporter` | 1 473 140 | 1 546 797 | 608 210 | 1 / 0 | 602 604 | 0 / 1 |
| `set_reporter` | a registered reporter revoked: the slot is zeroed | `bench_set_reporter_revoke` | 1 278 670 | 1 342 604 | −194 470 in the test; 207 530 in a transaction of its own | 0 / 1 | 182 424 | 0 / 1 |
| `set_reporter` | a registered reporter set again, unchanged | `bench_set_reporter_unchanged` | 1 680 470 | 1 764 494 | 207 330 | 0 / 1 | 182 224 | 0 / 1 |
| `quest_is_unlocked` | K = 7, not cached | `bench_view_is_unlocked_worst` | 39 265 606 | 41 228 887 | 492 490 | — | — | 10 / 0 |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` | 39 077 516 | 41 031 392 | 304 400 | — | — | 3 / 0 |
| `quest_is_accepted` | full list, not held | `bench_view_is_accepted` | 39 106 066 | 41 061 370 | 332 950 | — | — | 4 / 0 |
| `quest_held` | full list | `bench_view_held_full` | 39 071 806 | 41 025 397 | 298 690 | — | — | 3 / 0 |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` | 39 061 406 | 41 014 477 | 288 290 | — | — | 2 / 0 |
| `quest_current_interval` | — | `bench_view_current_interval` | 38 933 746 | 40 880 434 | 160 630 | — | — | 1 / 0 |
| `quest_is_reporter` | — | `bench_view_is_reporter` | 38 897 806 | 40 842 697 | 124 690 | — | — | 1 / 0 |

### Slots created and overwritten, per entrypoint

| Entrypoint | Best case | Common case | Worst case |
|---|---|---|---|
| `progress`, `progress_many`, event mode | none | none | none |
| `progress_many`, storage mode | none (nothing held counts) | per quest that counts, P created on its first count in the interval, overwritten later; per completion, R created at the first completion, overwritten later | 2H created (8 at H = 4); plus the hooks' own. The held list: never written |
| `accept` | 1 overwritten (slot 0) | 1 or 2 overwritten; R created when it caches a first unlock | 2 created (a never-used list slot, R) and 1 overwritten (slot 0). A player's first accept creates slot 0 |
| `abandon` | 1 overwritten | 1 or 2 overwritten | 2 overwritten; a slot the list stops using keeps its `kept` bit, never zeroed |
| `claim` | 2 writes, 2 overwritten, 1 changed slot when `claims` is saturated: only P changes, R is rewritten unchanged | 2 overwritten (P, R) | 2 overwritten |
| `define` | 2 created (A, B) | 3 created (A, B, C), K overwritten | 3 created, 7 overwritten |
| `retire` | 1 overwritten | 1 + K overwritten | 8 overwritten |
| `set_reporter` | 1 write, nothing changed (the value is already set) | 1 created (a new reporter); 1 zeroed (a registered reporter revoked) | 1 created |

**Kept slots** (fix loop 2): a held-list slot is never zeroed once it has held an entry. Growing
back into it costs 712 750 instead of 1 084 240 (about 640 000 instead of 1 053 500 at the
network's prices). The worst calls are not worse; the reasons are in `GAS.md`.

## The store of a model (ARC-06, `quiver_quest` Unreleased)

Measured 2026-09-29 at `0227486` ([research](research/ARC-06-model-store.md#4-cost), detail in
[packages/quest/GAS.md](../packages/quest/GAS.md#the-store-and-the-definition-model-arc-06-unreleased)).
The store costs what the same code costs by hand, for untracked and tracked models, created and
overwritten slots, and reads: `set` 454 530 created and 52 530 overwritten, plus 45 020 for a
tracked model's event; `get` 32 590. The quest definition through the store: write 1 652 890
(1 657 450 by hand), read 69 210 (69 240). `define`'s worst case is 2 583 680 (2 590 440 in the
table above); the worst calls are unchanged.

## `quiver_quest`: the library

Measured 2026-09-29 at `21f3066`, as written in `packages/quest/GAS.md`
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
| `QuestHeldSlot` pack and unpack | every field at its maximum: ids, intervals 2^48 − 1, numbers and the counter 2^30 − 1 | `bench_pack_unpack_held_slot` | 45 730 | 48 017 |
| `prerequisites_met` | 7 records | `bench_prerequisites_met_seven` | 29 700 | 31 185 |
| `held_slot` | the last slot of 8 entries | `bench_held_slot_last` | 29 960 | 31 458 |

The other functions (packing, records, schedules) are between 13 720 and 45 000 with their setup;
see `GAS.md`.

## `quiver_achievement`: the component (event mode only)

Measured 2026-09-29 (ARC-04; the commit is in `packages/achievement/GAS.md`), snforge 0.61, L2
gas, as for `quiver_quest` above: **call** is the benchmark minus its baseline, through a
dispatcher from `MockBench` (`authorize_admin` accepts every caller); reads and events from
`snforge test --detailed-resources`, the reads of `progress` and `progress_many` including the
reporter check. 0.1.0 is event mode only
([decision](decisions/2026-09-29-achievement-event-only.md)): progress writes nothing, and reads
no definition, so its cost does not depend on the achievements defined. The network estimate
reprices each written slot as above; details in
[packages/achievement/GAS.md](../packages/achievement/GAS.md#cost-model-of-quiver_achievement-010-arc-04-event-mode-only).

| Entrypoint | Case | Benchmark | Test measured | Test budget | Call | Created / overwritten | Network estimate | Reads / events | Against 20 M |
|---|---|---|---|---|---|---|---|---|---|
| `progress_many` | **the worst**: 16 entries `[1..=15, 129]`, late collision | `bench_progress_many_late_collision` | 2 606 413 | 2 736 734 | **1 816 813** | 0 / 0 | 1 816 813 | 1 / 16 | 9.1 % |
| `progress_many` | 16 entries `[1..=15, 15]`, late duplicate | `bench_progress_many_late_duplicate` | 2 549 593 | 2 677 073 | 1 759 993 | 0 / 0 | 1 759 993 | 1 / 15 | 8.8 % |
| `progress_many` | 16 distinct entries | `bench_progress_many_sixteen_distinct` | 2 035 086 | 2 136 841 | 1 245 486 | 0 / 0 | 1 245 486 | 1 / 16 | 6.2 % |
| `progress_many` | the worst, 48 achievements of 3 tasks on its tasks | `bench_progress_many_late_collision_with_definitions` | 60 255 793 | 63 268 583 | 1 816 613 | 0 / 0 | 1 816 613 | 1 / 16 | 9.1 % |
| `progress` | 1 entry | `bench_progress` | 998 836 | 1 048 778 | 209 236 | 0 / 0 | 209 236 | 1 / 1 | 1.0 % |
| `define` | **the worst**: 3 tasks | `bench_define_worst` | 1 986 630 | 2 085 962 | 1 197 030 | 2 / 0 | 1 185 818 | 1 / 1 | 6.0 % |
| `define` | 1 task | `bench_define_one_task` | 1 497 240 | 1 572 102 | 707 640 | 1 / 0 | 702 034 | 1 / 1 | 3.5 % |
| `retire` | — | `bench_retire` | 2 227 570 | 2 338 949 | 240 760 | 0 / 1 | 215 654 | 1 / 1 | 1.2 % |
| `set_reporter` | a new reporter | `bench_set_reporter` | 1 397 010 | 1 466 861 | 607 410 | 1 / 0 | 601 804 | 0 / 1 | 3.0 % |
| `set_reporter` | a registered reporter revoked: the slot is zeroed | `bench_set_reporter_revoke` | 1 201 740 | 1 261 827 | −195 270 in the test; 206 730 in a transaction of its own | 0 / 1 | 181 624 | 0 / 1 | 1.0 % |
| `set_reporter` | a registered reporter set again, unchanged | `bench_set_reporter_unchanged` | 1 603 540 | 1 683 717 | 206 530 | 0 / 1 | 181 424 | 0 / 1 | 1.0 % |
| `achievement_definition` | 3 tasks | `bench_view_definition_worst` | 2 200 940 | 2 310 987 | 214 130 | — | — | 2 / 0 | — |
| `achievement_is_reporter` | — | `bench_view_is_reporter` | 914 290 | 960 005 | 124 690 | — | — | 1 / 0 | — |

**Grim World's use** (design/13, the MVP's 8 titles as 26 tiers on 8 tasks):

| Case | Benchmark | Test measured | Test budget | Call | Created / overwritten | Network estimate | Reads / events | Against 20 M |
|---|---|---|---|---|---|---|---|---|
| A results transaction: 6 character tasks and 2 account tasks, one `progress_many` per player id | `bench_game_results_call` | 20 143 438 | 21 150 610 | **829 728** | 0 / 0 | 829 728 | 2 / 8 | 4.1 % |
| 16 distinct tasks in one call (A-10) | `bench_game_results_call_sixteen` | 20 558 996 | 21 586 946 | 1 245 286 | 0 / 0 | 1 245 286 | 1 / 16 | 6.2 % |
| The 26 tiers defined in one transaction (the admin's setup) | `bench_game_define_titles` | 19 315 330 | 20 281 097 | 18 525 730 | 26 / 0 | 18 379 974 | 26 / 26 | **92.6 %** |

Every call of the package is under 20 M, by snforge's prices and by the network's. Defining in
bulk is the consumer's batching of admin calls: 26 definitions in one transaction come near the
cap, so they are spread over several transactions (the README says so).

## `quiver_achievement`: the library

`packages/achievement/tests/test_bench.cairo`. A figure includes the test's setup
(`bench_baseline_sixteen_entries`: 49 990).

| Algorithm | Worst case | Benchmark | Measured | Budget |
|---|---|---|---|---|
| `batch_merge` | 16 entries, a modulo-128 collision at the 16th | `bench_batch_merge_late_modulo_collision` | 751 523 | 789 100 |
| `batch_merge` | 16 entries, a repeat at the 16th | `bench_batch_merge_late_duplicate` | 747 613 | 784 994 |
| `batch_merge` | 16 distinct entries (fast path) | `bench_batch_merge_sixteen_distinct` | 180 396 | 189 416 |
| `AchievementDefinition` pack and unpack | every field at its maximum | `bench_pack_unpack_definition` | 34 120 | 35 826 |
| `AchievementExtraTasks` pack and unpack | every field at its maximum | `bench_pack_unpack_extra_tasks` | 24 930 | 26 177 |
| `definition_new` | 3 tasks | `bench_definition_new_three_tasks` | 20 920 | 21 966 |
