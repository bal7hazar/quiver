# Budgets

Per entrypoint and per algorithm: the measured value, the budget, the date and the commit
([CAIRO.md](CAIRO.md) §2). The detail, test by test, is in each package's `GAS.md`. A budget is
`ceil(1.05 × measured)` of its test when it is set, and must stay between the measured value and
that figure (`scripts/gas.py --check`), so a later, lower measurement can leave it tighter; raising one needs a written reason and the orchestrator's
agreement, lowering one needs nothing.

## `quiver_quest`: the component

Measured 2026-09-29 for `quiver_quest` 0.2.0 (ARC-07a) and **re-measured 2026-10-02 on Scarb 2.20.1,
snforge 0.64.0** (ARC-10, D-180; the commit is in `packages/quest/GAS.md`), L2 gas; 0.1.0's figures (`21f3066`, ARC-03c fix loop 4, D-135) are set against them
in [packages/quest/GAS.md](../packages/quest/GAS.md#quiver_quest-020-arc-07a). Each benchmark has a
baseline that runs the same setup without the call. The consumer tracks every model
(`TrackAll`), as 0.1.0 emits.

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

| Written slot | snforge 0.64 (these figures; 0.61: 459 106 and 57 106) | The network (FND-04, 149 Sepolia transactions; [decision](decisions/2026-09-28-quest-cost-cap.md), correction of 2026-09-29) |
|---|---|---|
| Created (zero → non-zero) | 474 106 (write 72 106 + allocation 402 000) | about 453 500 |
| Overwritten or zeroed | 72 106 | about 32 000 |

**The figures below are snforge's.** The **network estimate** reprices each slot the call writes
at the network's price: −20 606 per created slot and −40 106 per overwritten one (on 0.61: −5 606
and −25 106; the network's price is the same, snforge 0.64 charges 15 000 more per write). Details and
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
| **H = 4, created, hooks empty** | `bench_progress_many_worst_held4` | 16 821 613 | 16 955 866 | **6 460 843** | 8 / 0 | 6 295 995 | 32 % / 31 % | 0.59 % |
| H = 4, existing, hooks empty | `bench_progress_many_worst_held4_existing` | 16 972 913 | 17 114 731 | 3 244 843 | 0 / 8 | 2 923 995 | 16 % / 15 % | 0.29 % |
| **H = 4, created, a hook writing one slot** | `bench_progress_many_worst_held4_hook` | 18 696 533 | 18 861 532 | **8 335 763** | 12 / 0 | 8 088 491 | 42 % / 40 % | 0.76 % |
| H = 4, existing, a hook writing one slot | `bench_progress_many_worst_held4_existing_hook` | 18 847 833 | 19 020 397 | 5 119 763 | 4 / 8 | 4 716 491 | 26 % / 24 % | 0.47 % |
| **H = 8, created, hooks empty** | `bench_progress_many_worst_held8` | 28 971 913 | 29 280 241 | **11 917 073** | 16 / 0 | 11 587 377 | 60 % / 58 % | 1.08 % |
| H = 8, existing, hooks empty | `bench_progress_many_worst_held8_existing` | 29 272 683 | 29 596 049 | 5 485 073 | 0 / 16 | 4 843 377 | 27 % / 24 % | 0.50 % |
| **H = 8, created, a hook writing one slot** | `bench_progress_many_worst_held8_hook` | 32 721 753 | 33 091 573 | **15 666 913** | 24 / 0 | 15 172 369 | 78 % / 76 % | 1.42 % |
| H = 8, existing, a hook writing one slot | `bench_progress_many_worst_held8_existing_hook` | 33 022 523 | 33 407 381 | 9 234 913 | 8 / 16 | 8 428 369 | 46 % / 42 % | 0.84 % |
| Grim World's use: 16 entries, 3 quests and a daily contract completing, K ≤ 2 | `game_case_three_per_task` | 84 355 448 | 85 344 712 | 4 801 186 | 6 / 2 | 4 597 338 | 24 % / 23 % | 0.44 % |

All of them are under 20 M, by snforge's prices and by the network's.

### Per entrypoint

| Entrypoint | Case | Benchmark | Test measured | Test budget | Call | Created / overwritten | Network estimate | Reads / events |
|---|---|---|---|---|---|---|---|---|
| `progress_many` | §5.1 witness adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 569 194 416 | 580 778 149 | 5 878 626 | 8 / 0 | 5 713 778 | 25 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` | 14 628 244 | 14 695 878 | 5 438 294 | 8 / 0 | 5 273 446 | 25 / 4 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` | 11 441 896 | 11 463 613 | 2 251 946 | 2 / 0 | 2 210 734 | 22 / 1 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` | 10 689 976 | 10 715 047 | 1 500 026 | 1 / 0 | 1 479 420 | 16 / 0 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` | 10 213 456 | 10 230 451 | 1 023 506 | 0 / 0 | 1 023 506 | 16 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` | 4 347 376 | 4 425 127 | 1 444 296 | 2 / 0 | 1 403 084 | 6 / 1 |
| `progress` | 1 held, counts | `bench_progress_plain` | 3 780 416 | 3 851 869 | 877 336 | 1 / 0 | 856 730 | 5 / 0 |
| `progress` | nothing held | `bench_progress_nothing_held` | 2 339 846 | 2 405 294 | 236 256 | 0 / 0 | 236 256 | 2 / 0 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` | 1 087 766 | 1 131 161 | 217 146 | 0 / 0 | 217 146 | 1 / 1 |
| `progress_many`, event mode | 16 distinct entries | `bench_progress_many_event_mode_worst` | 2 135 096 | 2 231 383 | 1 264 476 | 0 / 0 | 1 264 476 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 129]`, late collision | `bench_progress_many_event_mode_late_collision` | 2 706 423 | 2 831 276 | 1 835 803 | 0 / 0 | 1 835 803 | 1 / 16 |
| `progress_many`, event mode | `[1..=15, 15]`, late duplicate | `bench_progress_many_event_mode_late_duplicate` | 2 648 803 | 2 770 775 | 1 778 183 | 0 / 0 | 1 778 183 | 1 / 15 |
| `accept` | **worst**: grows into a slot never used; K = 7 not cached | `bench_accept_growth` | 31 779 282 | 31 832 422 | 2 061 170 | 2 / 1 | 1 979 852 | 17 / 0 |
| `accept` | grows back into a slot used before | `bench_accept_regrow` | 9 565 310 | 9 622 221 | 778 980 | 0 / 2 | 698 768 | 8 / 0 |
| `accept` | mixed list: 2 live weekly, 2 stale daily; K = 7 | `bench_accept_mixed` | 37 003 132 | 38 853 289 | 1 842 280 | 1 / 2 | 1 741 462 | 20 / 0 |
| `accept` | 4 dead entries completed now, pruned; K = 7 | `bench_accept_worst_completed` | 42 317 036 | 44 432 888 | 1 929 690 | 1 / 2 | 1 828 872 | 22 / 0 |
| `accept` | 4 entries expired, pruned; K = 7 | `bench_accept_worst_expired` | 36 821 492 | 36 835 893 | 1 743 930 | 1 / 2 | 1 643 112 | 18 / 0 |
| `accept` | a player's first accept, no prerequisite | `bench_accept_plain` | 2 903 080 | 2 974 640 | 799 490 | 1 / 0 | 778 884 | 3 / 0 |
| `abandon` | **worst**: first of 4, the others move up | `bench_abandon_worst` | 9 810 980 | 9 845 651 | 621 030 | 0 / 2 | 540 818 | 5 / 0 |
| `abandon` | the third of 3: slot 1 no longer used, kept | `bench_abandon_shrink` | 7 552 280 | 7 623 536 | 486 740 | 0 / 1 | 446 634 | 4 / 0 |
| `abandon` | second of 2 | `bench_abandon` | 5 100 200 | 5 163 596 | 458 370 | 0 / 1 | 418 264 | 4 / 0 |
| `claim` | — | `bench_claim` | 4 752 296 | 4 807 873 | 404 920 | 0 / 2 | 324 708 | 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 26 231 692 | 26 319 219 | 2 779 560 | 3 / 7 | 2 437 000 | 8 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 27 408 132 | 28 778 539 | 1 175 940 | 0 / 8 | 855 092 | 9 / 1 |
| `set_reporter` | a new reporter | `bench_set_reporter` | 1 492 230 | 1 546 797 | 621 610 | 1 / 0 | 601 004 | 0 / 1 |
| `set_reporter` | a registered reporter revoked: the slot is zeroed | `bench_set_reporter_revoke` | 1 311 040 | 1 342 604 | −181 190 in the test; 220 810 in a transaction of its own | 0 / 1 | 180 704 | 0 / 1 |
| `set_reporter` | a registered reporter set again, unchanged | `bench_set_reporter_unchanged` | 1 712 840 | 1 764 494 | 220 610 | 0 / 1 | 180 504 | 0 / 1 |
| `quest_is_unlocked` | K = 7, not cached | `bench_view_is_unlocked_worst` | 40 943 816 | 40 985 119 | 556 470 | — | — | 10 / 0 |
| `quest_definition` | 3 tasks, 7 conditions | `bench_view_definition_worst` | 40 709 526 | 40 783 214 | 322 180 | — | — | 3 / 0 |
| `quest_is_accepted` | full list, not held | `bench_view_is_accepted` | 40 742 976 | 40 813 507 | 355 630 | — | — | 4 / 0 |
| `quest_held` | full list | `bench_view_held_full` | 40 703 716 | 40 777 114 | 316 370 | — | — | 3 / 0 |
| `quest_progress` + `quest_record` | two calls | `bench_view_progress_and_record` | 40 687 916 | 40 767 034 | 300 570 | — | — | 2 / 0 |
| `quest_current_interval` | — | `bench_view_current_interval` | 40 552 256 | 40 632 151 | 164 910 | — | — | 1 / 0 |
| `quest_is_reporter` | — | `bench_view_is_reporter` | 40 517 716 | 40 594 414 | 130 370 | — | — | 1 / 0 |

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
back into it costs 778 980 on Scarb 2.20.1 (703 980 instead of 1 084 240 on 2.19.4, about 654 000
instead of 1 053 500 at the network's prices then). The worst calls are not worse; the reasons are in `GAS.md`.

**0.2.0 against 0.1.0** (ARC-07a, measured on Scarb 2.19.4): no worst call is raised. `progress_many` is 7 220 cheaper at
H = 4 and 14 140 at H = 8, `accept` 4 370, `abandon` 9 910, `define` 400; `set_reporter` is the
same to the unit, `retire` 300 more. The largest rise is the view `quest_is_unlocked`, +4 300
(0.9 %).

## Optional tracking (ARC-07a, `quiver_quest` 0.2.0)

Detail in [packages/quest/GAS.md](../packages/quest/GAS.md#optional-tracking) and
[research](research/ARC-06-model-store.md#7-optional-tracking-arc-07a). A tracked model's write
under `TrackNone` costs exactly the write with no event code, and under `TrackAll` the write plus
the event, to the unit: one slot created, 469 530 and 514 550 (by a constant and by an emitter
alike); the reporter, 469 630 and 513 230, as 0.1.0's code without and with its `emit`; the quest
definition (3 tasks, 7 conditions), 1 542 390 and 1 697 490, as the same model's slots written by
hand without and with its `emit` (fix loop 1).

## The store of a model (ARC-06, `quiver_quest` 0.2.0)

Measured 2026-09-29 at `852f546`, ARC-06 fix loop 1, **on Scarb 2.19.4 and snforge 0.61: a record of that
step, not re-measured** (the write of a slot costs 15 000 more and a read 6 000 more on snforge 0.64) ([research](research/ARC-06-model-store.md#4-cost), detail in
[packages/quest/GAS.md](../packages/quest/GAS.md#the-store-and-the-definition-model-arc-06)).
The store costs what the same code costs by hand, for untracked and tracked models, created and
overwritten slots, and reads: `set` 454 530 created and 52 530 overwritten, plus 45 020 for a
tracked model's event; `get` 29 420 (against a read-shaped baseline). The quest definition through the store: write 1 652 890
(1 657 450 by hand), read 130 400 (130 430). `define`'s worst case is 2 583 680 (2 590 440 in the
0.1.0's table); ARC-06 left the worst calls unchanged.

## `quiver_quest`: the library

Measured 2026-09-29 for 0.2.0 (ARC-07a), as written in `packages/quest/GAS.md`. The functions of
0.1.0's `logic` are now methods of the types and models (ARC-01 §3.2, amended); the tests of
`RecordTrait::all_completed` build models with their keys, and their budgets were raised, with a
note. The benchmarks are in `packages/quest/tests/test_bench.cairo`. A figure includes the test's
setup; the function's own cost is the benchmark minus its `bench_baseline_*`.

| Algorithm | Worst case | Benchmark | Measured | Budget |
|---|---|---|---|---|
| `BatchTrait::merge` | 16 entries, a modulo-128 collision at the 16th | `bench_batch_merge_late_modulo_collision` | 745 293 | 782 558 |
| `BatchTrait::merge` | 16 entries, a repeat at the 16th | `bench_batch_merge_late_duplicate` | 741 383 | 778 453 |
| `BatchTrait::merge` | 16 distinct entries (fast path) | `bench_batch_merge_sixteen_distinct` | 174 166 | 182 875 |
| `ProgressTrait::add` | 3 tasks, 16 entries | `bench_progress_add_three_tasks_sixteen_entries` | 148 160 | 155 568 |
| `DefinitionTrait::new`, `into_slots` | 3 tasks, 7 conditions | `bench_definition_new_three_tasks_seven_conditions` | 141 470 | 148 544 |
| `BatchTrait::first_position` | absent among 16 | `bench_batch_first_position_absent` | 102 660 | 107 793 |
| `BatchTrait::count_of` | absent among 16 | `bench_batch_count_of_absent` | 82 760 | 86 898 |
| `HeldTrait::remove` | 8 entries, the first removed | `bench_held_remove_first` | 38 570 | 40 499 |
| `HeldTrait::contains` | absent among 8 | `bench_held_contains_absent` | 33 440 | 35 112 |
| `HeldTrait::position` | absent among 8 | `bench_held_position_absent` | 30 740 | 32 277 |
| `HeldSlot` pack and unpack | every field at its maximum: ids, intervals 2^48 − 1, numbers and the counter 2^30 − 1 | `bench_pack_unpack_held_slot` | 37 900 | 39 795 |
| `RecordTrait::all_completed` | 7 records | `bench_prerequisites_met_seven` | 26 970 | 28 319 |
| `HeldSlotTrait::new` | the last slot of 8 entries | `bench_held_slot_last` | 22 870 | 24 014 |

The other functions (packing, records, schedules) are between 13 720 and 45 000 with their setup;
see `GAS.md`.

## `quiver_achievement`: the component (event mode only)

Measured 2026-10-01 (ARC-07b, `quiver_achievement` 0.2.0) and re-measured 2026-10-02 on Scarb 2.20.1,
snforge 0.64.0 (ARC-10; the commit is in `packages/achievement/GAS.md`), L2 gas, as for `quiver_quest` above: **call** is the
benchmark minus its baseline, through a dispatcher from `MockBench` (`authorize_admin` accepts
every caller; `TrackAll`, as 0.1.0); reads and events from `snforge test --detailed-resources`,
the reads of `progress` and `progress_many` including the reporter check. The package is event
mode only ([decision](decisions/2026-09-29-achievement-event-only.md)): progress writes nothing,
and reads no definition, so its cost does not depend on the achievements defined. The network
estimate reprices each written slot as above; details in
[packages/achievement/GAS.md](../packages/achievement/GAS.md#quiver_achievement-020-arc-07b).
Against 0.1.0 (ARC-04, on Scarb 2.19.4): progress, `set_reporter` and `achievement_is_reporter` were
the same to the unit; `define` of 1 task −4 370, of 3 tasks +1 610, `retire` +2 570,
`achievement_definition` +3 610, from `points` stored in slot A. On Scarb 2.20.1 every call that
writes or reads costs more (a write 15 000, a read 6 000); the figures below are the new ones.

| Entrypoint | Case | Benchmark | Test measured | Test budget | Call | Created / overwritten | Network estimate | Reads / events | Against 20 M |
|---|---|---|---|---|---|---|---|---|---|
| `progress_many` | **the worst**: 16 entries `[1..=15, 129]`, late collision | `bench_progress_many_late_collision` | 2 616 383 | 2 736 734 | **1 821 093** | 0 / 0 | 1 821 093 | 1 / 16 | 9.1 % |
| `progress_many` | 16 entries `[1..=15, 15]`, late duplicate | `bench_progress_many_late_duplicate` | 2 559 563 | 2 677 073 | 1 764 273 | 0 / 0 | 1 764 273 | 1 / 15 | 8.8 % |
| `progress_many` | 16 distinct entries | `bench_progress_many_sixteen_distinct` | 2 045 056 | 2 136 841 | 1 249 766 | 0 / 0 | 1 249 766 | 1 / 16 | 6.2 % |
| `progress_many` | the worst, 48 achievements of 3 tasks on its tasks | `bench_progress_many_late_collision_with_definitions` | 61 971 683 | 63 268 583 | 1 820 893 | 0 / 0 | 1 820 893 | 1 / 16 | 9.1 % |
| `progress` | 1 entry | `bench_progress` | 1 008 926 | 1 048 778 | 213 636 | 0 / 0 | 213 636 | 1 / 1 | 1.1 % |
| `define` | **the worst**: 3 tasks | `bench_define_worst` | 2 028 210 | 2 085 962 | 1 232 920 | 2 / 0 | 1 191 708 | 1 / 1 | 6.2 % |
| `define` | 1 task | `bench_define_one_task` | 1 517 840 | 1 567 514 | 722 550 | 1 / 0 | 701 944 | 1 / 1 | 3.6 % |
| `retire` | — | `bench_retire` | 2 290 770 | 2 338 949 | 262 730 | 0 / 1 | 222 624 | 1 / 1 | 1.3 % |
| `set_reporter` | a new reporter | `bench_set_reporter` | 1 416 100 | 1 466 861 | 620 810 | 1 / 0 | 600 204 | 0 / 1 | 3.1 % |
| `set_reporter` | a registered reporter revoked: the slot is zeroed | `bench_set_reporter_revoke` | 1 234 110 | 1 261 827 | −181 990 in the test; 220 010 in a transaction of its own | 0 / 1 | 179 904 | 0 / 1 | 1.1 % |
| `set_reporter` | a registered reporter set again, unchanged | `bench_set_reporter_unchanged` | 1 635 910 | 1 683 717 | 219 810 | 0 / 1 | 179 704 | 0 / 1 | 1.1 % |
| `achievement_definition` | 3 tasks | `bench_view_definition_worst` | 2 257 460 | 2 310 987 | 229 420 | — | — | 2 / 0 | 1.1 % |
| `achievement_is_reporter` | — | `bench_view_is_reporter` | 925 660 | 960 005 | 130 370 | — | — | 1 / 0 | 0.7 % |

**Optional tracking** (`test_tracking`, the store against its hand-written twin, each model
created): under `TrackNone` the write alone, under `TrackAll` the write plus the event, to the
unit.

| Model | `TrackNone` | `TrackAll` | Store − hand | The event |
|---|---|---|---|---|
| Definition, 1 task (`bench_track_*_definition_one_task_*`) | 482 910 | 553 090 | 0 | 70 180 |
| Definition, 3 tasks (`bench_track_*_definition_three_tasks_*`) | 956 590 | 1 051 350 | 0 | 94 760 |
| Reporter (`bench_track_*_reporter_*`) | 469 630 | 510 830 | 0 | 41 200 |

**Grim World's use** (design/13, the MVP's 8 titles as 26 tiers on 8 tasks):

| Case | Benchmark | Test measured | Test budget | Call | Created / overwritten | Network estimate | Reads / events | Against 20 M |
|---|---|---|---|---|---|---|---|---|
| A results transaction: 6 character tasks and 2 account tasks, one `progress_many` per player id | `bench_game_results_call` | 20 548 588 | 21 031 309 | **838 408** | 0 / 0 | 838 408 | 2 / 8 | 4.2 % |
| 16 distinct tasks in one call (A-10) | `bench_game_results_call_sixteen` | 20 959 746 | 21 467 645 | 1 249 566 | 0 / 0 | 1 249 566 | 1 / 16 | 6.2 % |
| The 26 tiers defined in one transaction (the admin's setup) | `bench_game_define_titles` | 19 711 680 | 20 161 796 | 18 916 390 | 26 / 0 | 18 380 634 | 26 / 26 | **94.6 %** |

Every call of the package is under 20 M, by snforge's prices and by the network's. Defining in
bulk is the consumer's batching of admin calls: 26 definitions in one transaction come near the
cap, so they are spread over several transactions (the README says so).

## `quiver_achievement`: the library

In their modules since 0.2.0 (D-167): `types::batch::tests` and `models::definition::tests`. A
figure includes the test's setup (`bench_baseline_sixteen_entries`: 49 990).

| Algorithm | Worst case | Benchmark | Measured | Budget |
|---|---|---|---|---|
| `BatchTrait::merge` | 16 entries, a modulo-128 collision at the 16th | `bench_batch_merge_late_modulo_collision` | 743 793 | 780 983 |
| `BatchTrait::merge` | 16 entries, a repeat at the 16th | `bench_batch_merge_late_duplicate` | 739 883 | 776 878 |
| `BatchTrait::merge` | 16 distinct entries (fast path) | `bench_batch_merge_sixteen_distinct` | 172 666 | 181 300 |
| `HeadSlot` (slot A, with `points`) pack and unpack | every field at its maximum | `bench_pack_unpack_definition` | 26 960 | 28 308 |
| `TasksSlot` (slot B) pack and unpack | every field at its maximum | `bench_pack_unpack_extra_tasks` | 17 100 | 17 955 |
| `DefinitionTrait::new`, then `into_slots` | 3 tasks | `bench_definition_new_three_tasks` | 12 410 | 13 031 |
