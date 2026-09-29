# [Opus 5.5] ARC-03c — `quiver_quest`: progress walks the player's held quests (D-135)

## Summary

This session ran on Opus 5.5 (`claude-opus-5-5`), the model the brief names.

`quiver_quest` 0.1.0 is complete on D-135. What exists now that did not before:

- **Acceptance is required for every quest.** `needs_accept`, its bit and
  `'Quest: no accept step'` are gone.
- **A player holds at most `MAX_HELD` = 4 quests**, in a held list:
  `Quest_held: Map<(player_id, slot), QuestHeldSlot>`, 4 slots of 2 entries each.
- **`accept`** checks the schedule, retirement and prerequisites (it caches the unlock). It
  refuses an interval already completed and a full list (`'Quest: too many held'`), prunes the
  dead entries (completed, expired at rollover, retired), and appends the quest.
- **`abandon`** removes the entry from the list.
- **`progress` and `progress_many` walk the held list.** They read no task page and no
  prerequisite, and never write the list. Everything else of ARC-03b's algorithm is kept:
  saturation, one write per record, completion, the hook after the state is written, the
  retired-by-hook skip, and `Mode::Event` reading and writing nothing.
- **The task pages are removed**, with their caps and the library's page helpers. No entrypoint
  needed them.
- **The worst call is measured under 20 M L2 gas**: 6.13 M at H = 4 and 11.28 M at H = 8 with
  empty hooks; 7.95 M and 14.91 M with a hook writing one slot.

Pull request: https://github.com/bal7hazar/quiver/pull/10. It supersedes #7. CI is green.

### The held list: layout and changed slots

| Bits of a slot | Field |
|---|---|
| [0, 32) | `e0.quest_id` (0 = empty) |
| [32, 96) | `e0.interval_id`, the interval of the acceptance |
| [96, 128) | reserved |
| [128, 160) | `e1.quest_id` |
| [160, 224) | `e1.interval_id` |
| [224, 252) | reserved |

The entries are contiguous and in the order of acceptance. A slot whose `e1` is empty ends the
list. The walk reads slots in order while they are full, at most `HELD_SLOTS` = 4, whatever
`MAX_HELD` is. So the code works for any `MAX_HELD` up to 8, and the H = 8 case runs the same
code on a seeded list.

**Why this layout: acceptance lives in the list alone.** `QuestRecord` lost `active` and
`accepted_interval`, and each entry carries the interval of its acceptance. Then:

- progress needs no record to know an acceptance;
- progress never has to write the list: dead entries wait for the next `accept`;
- `accept` and `abandon` change one slot in the common case, instead of the list and the record.

Slots changed per call, counted with `--detailed-resources`:

| Case | `progress_many` (storage) | `accept` | `abandon` |
|---|---|---|---|
| Nothing completes (common) | 1 per quest that counts (P) | 1 (the list slot), 2 with a first unlock (R) | 1 |
| One completes | + 2 for it (P, R) | — | — |
| All complete (worst) | 2H: **8 at H = 4, 16 at H = 8**, plus the hooks' own | 3 (both list slots, R) | 2 (both list slots) |
| The list | **never written** | — | — |

**Pruning is lazy, at `accept`.** I measured both options:

- A dead entry costs a later progress call 0.07 M (expired) to 0.12 M (completed).
- Pruning it at progress would change a list slot, 0.46 M, in the call that meets it. That pays
  only after four or more later calls before the player's next `accept`.
- Pruning at progress would also put up to 2 (H = 4) or 4 (H = 8) changed slots, 0.9 M or 1.8 M,
  into the worst call.

The details are in `packages/quest/GAS.md`, in the section below the table.

### Measurements of Scope 5, against 20 M

Each benchmark has its baseline. The call is the benchmark minus the baseline, through a
dispatcher.

| Case | Benchmark | Call (L2 gas) | Reads / writes / events | vs 20 M | vs 1.1 × 10⁹ |
|---|---|---|---|---|---|
| Worst, H = 4, hooks empty | `bench_progress_many_worst_held4` | **6 131 373** | 23 / 8 / 4 | 31 % | 0.56 % |
| Worst, H = 8, hooks empty | `bench_progress_many_worst_held8` | **11 279 423** | 44 / 16 / 8 | 56 % | 1.03 % |
| Worst, H = 4, a hook writing one slot | `bench_progress_many_worst_held4_hook` | **7 946 293** | 23 / 12 / 4 | 40 % | 0.72 % |
| Worst, H = 8, a hook writing one slot | `bench_progress_many_worst_held8_hook` | **14 909 263** | 44 / 24 / 8 | 75 % | 1.36 % |
| The game's use (3 quests per task) | `game_case_three_per_task` | 4 471 716; **5 275 716** in a transaction of its own | 23 / 8 / 4 | 26 % | 0.48 % |
| The game's use (2 quests per task) | `game_case_two_per_task` | 4 471 716 (identical: quests not held are not read) | 23 / 8 / 4 | 26 % | 0.48 % |
| `accept`, worst: K = 7 not cached, full list of 4 entries completed now, all pruned | `bench_accept_worst_completed` | 1 287 300; **2 091 300** in a transaction of its own | 22 / 3 / 0 | 10 % | — |
| `accept`: same with 4 entries expired at rollover | `bench_accept_worst_expired` | 1 125 540; 1 929 540 | 18 / 3 / 0 | 10 % | — |
| `abandon`, worst: the first of 4 | `bench_abandon_worst` | 504 460; **1 308 460** | 5 / 2 / 0 | 7 % | — |

**The worst case.** It is 16 entries `[1..=15, 129]`, whose modulo-128 collision at the last
entry runs `batch_merge`'s plain merge in full. Every held quest has 3 tasks at the last three
positions of the batch (the longest lookups), a daily schedule (a division), and completes.

**How H = 8 is built.** Quests 1 to 8 are defined through `define`. Quests 1 to 4 are accepted
through `accept`. Entries 5 to 8 are seeded into slots 2 and 3 of the list with snforge's
`store`, since `accept` stops at `MAX_HELD` = 4. The walk reads up to 4 slots, so it is the same
code as at H = 4.

**The hook.** `MockBenchHook`'s `on_quest_complete` writes `completions[quest_id]`, a different
slot for each quest.

**"In a transaction of its own".** This adds 402 000 L2 gas for each slot that the call changes
and that its setup had already changed in the same test. snforge counts a test as one
transaction. I measured that seeding with `store` does not avoid it
(`probe_store_then_change_100`: 57 099 per write). Every figure of the progress rows is counted
in full.

**The measured cost of a changed slot**: 459 099 L2 gas for a write that changes a slot, against
57 099 for a rewrite, so **402 000**. These are ARC-03b's probes, re-run with the same figures.

## Files changed

- `packages/quest/src/component.cairo`: the held list (`Quest_held`), mandatory `accept` with pruning and `'Quest: too many held'`, `abandon` removing the entry, `progress_many` walking the list with the still-held check after a hook, `define`/`retire` without pages, `is_accepted` on the list, `held_of`, the view `quest_held`.
- `packages/quest/src/interface.cairo`: `define` without `needs_accept`; `quest_held`.
- `packages/quest/src/constants.cairo`: `MAX_HELD = 4`, `MAX_HELD_LIMIT = 8`, `HELD_SLOTS = 4`; `QUESTS_PER_PAGE` and `MAX_PAGES` removed.
- `packages/quest/src/errors.cairo`: `TOO_MANY_HELD` added; `TASK_FULL` and `NO_ACCEPT_STEP` removed.
- `packages/quest/src/logic.cairo`: exports updated.
- `packages/quest/src/logic/types.cairo`: `QuestDefinition` without `needs_accept` (new bit positions); `QuestRecord` without `active` and `accepted_interval`; `QuestHeld`, `QuestHeldSlot` and its packing; `QuestIdPage` removed.
- `packages/quest/src/logic/held.cairo`: new, `held_position`, `held_contains`, `held_remove`, `held_slot`, `HELD_EMPTY`.
- `packages/quest/src/logic/record.cairo`: `record_is_accepted`, `record_accept`, `record_abandon` removed; `record_complete` touches completions only.
- `packages/quest/src/logic/definition.cairo`: `definition_new` without `needs_accept`.
- `packages/quest/src/logic/bits.cairo`: four constants no longer used removed.
- `packages/quest/src/logic/pages.cairo`: deleted.
- `packages/quest/tests/helpers.cairo`, `setup.cairo`, `mocks.cairo`, `mock_reentrant.cairo`: `record` of 3 fields, `held`, `held_slot`, `define_held`, `held_slots` (raw slots from storage); `MockBenchHook`; an `abandon` re-entry.
- `packages/quest/tests/test_component_accept.cairo`: adapted; new held-list tests (list full, layout, expired pruned, completed leaves the list, retired pruned, abandon removes, abandon of a completed quest).
- `packages/quest/tests/test_component_progress.cairo`: adapted; new `quest_held_by_one_player_not_progressed_by_another`, `quest_not_held_not_progressed`.
- `packages/quest/tests/test_component_reentry.cairo`: adapted; new `quest_reentrant_abandon_later_quest_not_progressed`, `quest_reentrant_accept_not_progressed_by_the_call`, `quest_reentrant_abandon_other_quest_leaves_outer_unchanged`.
- `packages/quest/tests/test_component_{prerequisites,claim,define,retire,access,events,event_mode,dependents}.cairo`: adapted to mandatory acceptance and to the removal of pages.
- `packages/quest/tests/test_component_bench.cairo`: rewritten, the benchmarks of Scope 5 and one per entrypoint.
- `packages/quest/tests/grid.cairo`, `test_component_grid.cairo`: rewritten, the grid over the held list (H ∈ {0, 1, 2, 4, 8} × 5 states, seeded).
- `packages/quest/tests/test_component_game.cairo`: the game's case through `define` and `accept`.
- `packages/quest/tests/test_component_probe.cairo`: `unpack_held` and the `store` probes added.
- `packages/quest/tests/test_held.cairo`: new, the held list's functions.
- `packages/quest/tests/test_{record,packing,definition,bench,constants,errors}.cairo`: adapted.
- `packages/quest/tests/test_pages.cairo`, `test_component_options.cairo`: deleted.
- `packages/quest/GAS.md`: regenerated (372 tests); the hand-written section below the table rewritten for D-135.
- `packages/quest/README.md`, `packages/quest/CHANGELOG.md`: updated for 0.1.0 on D-135.
- `docs/BUDGETS.md`: rewritten for the component and library of D-135.
- `docs/research/ARC-01-quest-achievement.md`: §3.1 (the bounds row), §3.2, §3.3, §3.5, §5.1 amended, each marked "Amended by D-135".

## Commands run

```
$ git fetch origin && git merge origin/main   → merged (the brief, the decision, ARC-03b's report)

$ scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build
   Compiling quiver_quest v0.1.0 (…/packages/quest/Scarb.toml)
    Finished `dev` profile target(s) in 3 seconds

$ cd packages/quest && snforge test
Tests: 372 passed, 0 failed, 0 ignored, 0 filtered out

$ scripts/gas.py packages/quest --write
quiver_quest: wrote packages/quest/GAS.md (372 tests)
$ scripts/gas.py packages/quest --check
quiver_quest: 372 tests within budget, GAS.md up to date

$ scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check   → exit 0
$ python3 .github/ci/check-links.py
check-links: 0 broken link(s)

$ snforge test test_component_bench --detailed-resources   (call = benchmark − baseline)
bench_progress_many_worst_held4       6131373   R 23  W 8   E 4
bench_progress_many_worst_held8      11279423   R 44  W 16  E 8
bench_progress_many_worst_held4_hook  7946293   R 23  W 12  E 4
bench_progress_many_worst_held8_hook 14909263   R 44  W 24  E 8
quest_batch_bound_accepted            5549156   R 23  W 8   E 4
bench_accept_worst_completed          1287300   R 22  W 3   E 0
bench_accept_worst_expired            1125540   R 18  W 3   E 0
bench_accept_plain                     745970   R 3   W 1   E 0
bench_abandon_worst                    504460   R 5   W 2   E 0
bench_abandon                          386420   R 4   W 1   E 0
bench_progress_plain                   824156   R 5   W 1   E 0
bench_progress_plain_completing       1369256   R 6   W 2   E 1
bench_progress_nothing_held            213576   R 2   W 0   E 0
bench_claim                            364020   R 2   W 2   E 1
bench_define_worst                    2590440   R 8   W 10  E 1
bench_retire_worst                    1003240   R 9   W 8   E 1

probes (per operation, net of the baseline): read 30 205; write that changes a slot 459 099;
rewrite 57 099; a write to a slot seeded by `store` 57 099; event 48 542.

$ gh pr checks 10 --watch --interval 30
affected pass · cairo pass · links pass · package (packages/quest) pass (1m8s) · scripts pass
```

By mistake, `snforge test` was run once from the worktree root instead of `packages/quest`. It
ran the workspace, which added 1 test of `quiver_achievement` (passed). Every other run was
package-scoped.

## Cost

The benchmark tables are in the summary, and in full in `packages/quest/GAS.md` (below the
table) and `docs/BUDGETS.md`.

Every test, before (`2703bb6`, ARC-03b fix loop 2) and after, measured L2 gas with its budget:

- **94 are new**, 177 removed, 173 changed, 105 unchanged.
- The removed ones are the E × N × K grid and cap options of the page design, the page tests,
  and the page and acceptance functions of the library.
- 72 budgets of tests present on both sides went up and 101 went down. The reasons for the raises
  are in a comment on the pull request: 69 component tests now call `accept` in their setup, and
  3 packing tests of `QuestConditions` rose by 100 to 1 000.

| Test (`quiver_quest_integrationtest::…`) | Before (measured) | After (measured) | Budget | Note |
|---|---|---|---|---|
| `test_batch::batch_count_of_present_and_absent` | 47260 | 47260 | 49623 | unchanged |
| `test_batch::batch_first_position_at_the_bound` | 152110 | 152110 | 159716 | unchanged |
| `test_batch::batch_first_position_is_the_smallest_position` | 36930 | 36930 | 38777 | unchanged |
| `test_batch::batch_merge_drops_zero_counts` | 83525 | 83525 | 87702 | unchanged |
| `test_batch::batch_merge_empty` | 20710 | 20710 | 21746 | unchanged |
| `test_batch::batch_merge_ids_equal_modulo_128_are_distinct` | 183358 | 183358 | 192526 | unchanged |
| `test_batch::batch_merge_keeps_distinct_entries_in_order` | 53738 | 53738 | 56425 | unchanged |
| `test_batch::batch_merge_keeps_the_position_of_first_occurrence` | 92375 | 92375 | 96994 | unchanged |
| `test_batch::batch_merge_matches_the_plain_merge` | 8504394 | 8504394 | 8929614 | unchanged |
| `test_batch::batch_merge_saturates_duplicates` | 271214 | 271214 | 284775 | unchanged |
| `test_batch::quest_batch_above_bound_reverts` | 74260 | 74260 | 77973 | unchanged |
| `test_batch::quest_batch_bound_accepted` | 225086 | 225086 | 236341 | unchanged |
| `test_batch::quest_batch_duplicate_entries_merged` | 55829 | 55829 | 58621 | unchanged |
| `test_batch::quest_batch_duplicates_count_toward_bound` | 65140 | 65140 | 68397 | unchanged |
| `test_batch::quest_batch_event_mode_one_event_per_task_merge` | 85409 | 85409 | 89680 | unchanged |
| `test_batch::quest_batch_first_position_uses_zero_sentinel` | 31320 | 31320 | 32886 | unchanged |
| `test_batch::quest_batch_rejects_task_zero` | 31036 | 31036 | 32588 | unchanged |
| `test_batch::quest_batch_rejects_task_zero_with_zero_count` | 38452 | 38452 | 40375 | unchanged |
| `test_batch::quest_batch_zero_counts_count_toward_bound` | 74260 | 74260 | 77973 | unchanged |
| `test_bench::bench_baseline_empty` | 14120 | 14120 | 14826 | unchanged |
| `test_bench::bench_baseline_fifteen_then_one` | 52410 | 52410 | 55031 | unchanged |
| `test_bench::bench_baseline_sixteen_distinct` | 62900 | 62900 | 66045 | unchanged |
| `test_bench::bench_baseline_sixteen_with_duplicates` | 75500 | 75500 | 79275 | unchanged |
| `test_bench::bench_batch_count_of_absent` | 90590 | 90590 | 95120 | unchanged |
| `test_bench::bench_batch_first_position_absent` | 110490 | 110490 | 116015 | unchanged |
| `test_bench::bench_batch_merge_late_duplicate` | 749113 | 749113 | 786569 | unchanged |
| `test_bench::bench_batch_merge_late_modulo_collision` | 753023 | 753023 | 790675 | unchanged |
| `test_bench::bench_batch_merge_sixteen_distinct` | 181896 | 181896 | 190991 | unchanged |
| `test_bench::bench_batch_merge_sixteen_with_duplicates` | 545921 | 545921 | 573218 | unchanged |
| `test_bench::bench_claim` | 18340 | 17940 | 18837 | changed |
| `test_bench::bench_conditions_span_seven` | 19540 | 19540 | 20517 | unchanged |
| `test_bench::bench_definition_new_three_tasks_seven_conditions` | 151360 | 150760 | 158298 | changed |
| `test_bench::bench_held_contains_absent` | — | 38210 | 40121 | new |
| `test_bench::bench_held_position_absent` | — | 36970 | 38819 | new |
| `test_bench::bench_held_remove_first` | — | 43390 | 45560 | new |
| `test_bench::bench_held_slot_last` | — | 25350 | 26618 | new |
| `test_bench::bench_pack_unpack_conditions` | 35520 | 35620 | 37401 | changed |
| `test_bench::bench_pack_unpack_definition` | 43450 | 40560 | 42588 | changed |
| `test_bench::bench_pack_unpack_held_slot` | — | 26090 | 27395 | new |
| `test_bench::bench_pack_unpack_page` | 37630 | — | — | removed |
| `test_bench::bench_pack_unpack_progress` | 29130 | 29130 | 30587 | unchanged |
| `test_bench::bench_pack_unpack_record` | 29020 | 23750 | 24938 | changed |
| `test_bench::bench_pack_unpack_tasks` | 31390 | 31390 | 32960 | unchanged |
| `test_bench::bench_page_pop_full` | 24910 | — | — | removed |
| `test_bench::bench_page_position_absent` | 25830 | — | — | removed |
| `test_bench::bench_page_push_seventh` | 21680 | — | — | removed |
| `test_bench::bench_page_set_last` | 21680 | — | — | removed |
| `test_bench::bench_page_span_full` | 19340 | — | — | removed |
| `test_bench::bench_prerequisites_met_seven` | 31400 | 29700 | 31185 | changed |
| `test_bench::bench_progress_add_three_tasks_sixteen_entries` | 156430 | 156430 | 164252 | unchanged |
| `test_bench::bench_progress_is_complete_three_tasks` | 21680 | 21680 | 22764 | unchanged |
| `test_bench::bench_record_abandon` | 17140 | — | — | removed |
| `test_bench::bench_record_accept` | 17040 | — | — | removed |
| `test_bench::bench_record_complete` | 16640 | 16140 | 16947 | changed |
| `test_bench::bench_record_is_accepted` | 17140 | — | — | removed |
| `test_bench::bench_schedule_interval_id` | 20130 | 20130 | 21137 | unchanged |
| `test_bench::bench_schedule_is_active` | 19230 | 19230 | 20192 | unchanged |
| `test_bench::bench_schedule_validate` | 17480 | 17480 | 18354 | unchanged |
| `test_bench::bench_tasks_index_of_absent` | 20850 | 20850 | 21893 | unchanged |
| `test_bench::bench_tasks_span_three` | 20050 | 20050 | 21053 | unchanged |
| `test_component_accept::quest_abandon_completed_reverts` | — | 15716396 | 16502216 | new |
| `test_component_accept::quest_abandon_expired_reverts` | 5877080 | 5377150 | 5646008 | changed |
| `test_component_accept::quest_abandon_keeps_counts` | 9208248 | 8507098 | 8932453 | changed |
| `test_component_accept::quest_abandon_refusals` | 6872920 | 6206530 | 6516857 | changed |
| `test_component_accept::quest_abandon_removes_from_list` | — | 16809520 | 17649996 | new |
| `test_component_accept::quest_accept_after_completion_reverts` | 10339396 | 10209366 | 10719835 | changed |
| `test_component_accept::quest_accept_after_daily_completion` | 11113946 | 11068316 | 11621732 | changed |
| `test_component_accept::quest_accept_caches_unlock` | 14121752 | 14316292 | 15032107 | changed |
| `test_component_accept::quest_accept_list_full_reverts` | — | 15774080 | 16562784 | new |
| `test_component_accept::quest_accept_refusals` | 9917810 | 11420800 | 11991840 | changed |
| `test_component_accept::quest_accept_required` | 7471532 | 6787382 | 7126752 | changed |
| `test_component_accept::quest_accept_twice_same_interval_reverts` | 5806530 | 5381060 | 5650113 | changed |
| `test_component_accept::quest_acceptance_expires_at_rollover` | 9393598 | 8827098 | 9268453 | changed |
| `test_component_accept::quest_completed_leaves_list` | — | 21023346 | 22074514 | new |
| `test_component_accept::quest_completion_releases_acceptance` | 10224886 | 10271956 | 10785554 | changed |
| `test_component_accept::quest_expired_acceptance_pruned` | — | 15324140 | 16090347 | new |
| `test_component_accept::quest_held_list_layout` | — | 12574200 | 13202910 | new |
| `test_component_accept::quest_is_accepted_false_outside_schedule` | 5991790 | 5539790 | 5816780 | changed |
| `test_component_accept::quest_retired_pruned_at_accept` | — | 14960290 | 15708305 | new |
| `test_component_access::quest_abandon_requires_player_authorization` | 5926210 | 5466250 | 5739563 | changed |
| `test_component_access::quest_accept_requires_player_authorization` | 5110260 | 4594630 | 4824362 | changed |
| `test_component_access::quest_claim_requires_player_authorization` | 14576286 | 14398976 | 15118925 | changed |
| `test_component_access::quest_consumer_calls_the_internal_layer` | 5962536 | 5820686 | 6111721 | changed |
| `test_component_access::quest_define_admin_only` | 2987810 | 2978730 | 3127667 | changed |
| `test_component_access::quest_internal_layer_not_reachable_from_abi` | 2021290 | 2020890 | 2121935 | changed |
| `test_component_access::quest_player_authorization_is_per_player` | 4910330 | 4392060 | 4611663 | changed |
| `test_component_access::quest_progress_accepts_registered_reporter` | 7011632 | 7335572 | 7702351 | changed |
| `test_component_access::quest_progress_many_rejects_unregistered_caller` | 2847530 | 2851310 | 2993876 | changed |
| `test_component_access::quest_progress_rejects_unregistered_caller` | 5316730 | 5719490 | 6005465 | changed |
| `test_component_access::quest_reporter_revoked` | 4854300 | 5248800 | 5511240 | changed |
| `test_component_access::quest_retire_admin_only` | 5611150 | 4961580 | 5209659 | changed |
| `test_component_access::quest_set_reporter_admin_only` | 2970450 | 2969550 | 3118028 | changed |
| `test_component_access::quest_set_reporter_event_keys` | 2940840 | 2940440 | 3087462 | changed |
| `test_component_bench::baseline_accept_worst_completed` | — | 37982436 | 39881558 | new |
| `test_component_bench::baseline_accept_worst_expired` | — | 33015562 | 34666341 | new |
| `test_component_bench::baseline_accepted` | 27109912 | 2820110 | 2961116 | changed |
| `test_component_bench::baseline_batch_bound_accepted` | 1291105702 | 552029690 | 579631175 | changed |
| `test_component_bench::baseline_completed` | 3936036 | 4189366 | 4398835 | changed |
| `test_component_bench::baseline_define_worst` | 140916452 | 22308742 | 23424180 | changed |
| `test_component_bench::baseline_deployed` | 790500 | 864930 | 908177 | changed |
| `test_component_bench::baseline_full_list` | — | 8593710 | 9023396 | new |
| `test_component_bench::baseline_plain` | 2532310 | 2074140 | 2177847 | changed |
| `test_component_bench::baseline_prerequisites` | 26055202 | 37982436 | 39881558 | changed |
| `test_component_bench::baseline_progress_many_late_collision` | 1291088562 | — | — | removed |
| `test_component_bench::baseline_progress_many_late_duplicate` | 1211789592 | — | — | removed |
| `test_component_bench::baseline_progress_many_worst_held4` | — | 9654860 | 10137603 | new |
| `test_component_bench::baseline_progress_many_worst_held4_hook` | — | 9654860 | 10137603 | new |
| `test_component_bench::baseline_progress_many_worst_held8` | — | 16177590 | 16986470 | new |
| `test_component_bench::baseline_progress_many_worst_held8_hook` | — | 16177590 | 16986470 | new |
| `test_component_bench::baseline_progress_worst` | 101321042 | — | — | removed |
| `test_component_bench::baseline_retire_worst` | 144323012 | 24899562 | 26144541 | changed |
| `test_component_bench::baseline_two_held` | — | 4468800 | 4692240 | new |
| `test_component_bench::bench_abandon` | 27378872 | 4855220 | 5097981 | changed |
| `test_component_bench::bench_abandon_worst` | — | 9098170 | 9553079 | new |
| `test_component_bench::bench_accept_plain` | — | 2820110 | 2961116 | new |
| `test_component_bench::bench_accept_worst` | 27109912 | — | — | removed |
| `test_component_bench::bench_accept_worst_completed` | — | 39269736 | 41233223 | new |
| `test_component_bench::bench_accept_worst_expired` | — | 34141102 | 35848158 | new |
| `test_component_bench::bench_claim` | 4305336 | 4553386 | 4781056 | changed |
| `test_component_bench::bench_define_worst` | 144324932 | 24899182 | 26144142 | changed |
| `test_component_bench::bench_progress_accepted` | 28026018 | — | — | removed |
| `test_component_bench::bench_progress_event_mode` | 1001736 | 1077296 | 1131161 | changed |
| `test_component_bench::bench_progress_full_list_all_complete` | — | 13702654 | 14387787 | new |
| `test_component_bench::bench_progress_full_list_none_counts` | — | 9496786 | 9971626 | new |
| `test_component_bench::bench_progress_full_list_one_completes` | — | 10628516 | 11159942 | new |
| `test_component_bench::bench_progress_full_list_one_counts` | — | 9957496 | 10455371 | new |
| `test_component_bench::bench_progress_many_event_mode_late_collision` | 2625213 | 2696753 | 2831591 | changed |
| `test_component_bench::bench_progress_many_event_mode_late_duplicate` | 2567393 | 2639133 | 2771090 | changed |
| `test_component_bench::bench_progress_many_event_mode_worst` | 2053886 | 2125426 | 2231698 | changed |
| `test_component_bench::bench_progress_many_worst_held4` | — | 15786233 | 16575545 | new |
| `test_component_bench::bench_progress_many_worst_held4_hook` | — | 17601153 | 18481211 | new |
| `test_component_bench::bench_progress_many_worst_held8` | — | 27457013 | 28829864 | new |
| `test_component_bench::bench_progress_many_worst_held8_hook` | — | 31086853 | 32641196 | new |
| `test_component_bench::bench_progress_many_worst_late_collision` | 1974255845 | — | — | removed |
| `test_component_bench::bench_progress_many_worst_late_duplicate` | 1852316665 | — | — | removed |
| `test_component_bench::bench_progress_nothing_held` | — | 2287716 | 2402102 | new |
| `test_component_bench::bench_progress_plain` | 3387696 | 3644266 | 3826480 | changed |
| `test_component_bench::bench_progress_plain_completing` | 3936036 | 4189366 | 4398835 | changed |
| `test_component_bench::bench_progress_worst` | 144130218 | — | — | removed |
| `test_component_bench::bench_retire_worst` | 146468792 | 25902802 | 27197943 | changed |
| `test_component_bench::bench_set_reporter` | 1398910 | 1473140 | 1546797 | changed |
| `test_component_bench::bench_view_current_interval` | 26217812 | 38143066 | 40050220 | changed |
| `test_component_bench::bench_view_definition_worst` | 26363282 | 38286836 | 40201178 | changed |
| `test_component_bench::bench_view_held_full` | — | 38228346 | 40139764 | new |
| `test_component_bench::bench_view_is_accepted` | 26256152 | 38275526 | 40189303 | changed |
| `test_component_bench::bench_view_is_reporter` | 26179892 | 38107126 | 40012483 | changed |
| `test_component_bench::bench_view_is_unlocked_worst` | 26578052 | 38474926 | 40398673 | changed |
| `test_component_bench::bench_view_progress_and_record` | 26350462 | 38270726 | 40184263 | changed |
| `test_component_bench::quest_batch_bound_accepted` | 1973846068 | 557578846 | 585457789 | changed |
| `test_component_claim::quest_claim_emits_and_writes` | 12742436 | 13079616 | 13733597 | changed |
| `test_component_claim::quest_claim_hook_after_state_written` | 12730276 | 13074826 | 13728568 | changed |
| `test_component_claim::quest_claim_hook_panic_reverts_claim` | 11030536 | 11368316 | 11936732 | changed |
| `test_component_claim::quest_claim_index_counts_claims` | 21605042 | 22429522 | 23550999 | changed |
| `test_component_claim::quest_claim_twice_reverts` | 13000326 | 13336856 | 14003699 | changed |
| `test_component_claim::quest_claim_uncompleted_reverts` | 6567176 | 6908416 | 7253837 | changed |
| `test_component_claim::quest_complete_hook_after_state_written` | 9672586 | 10024856 | 10526099 | changed |
| `test_component_claim::quest_complete_hook_panic_reverts_progress` | 8033396 | 8906166 | 9351475 | changed |
| `test_component_define::quest_define_counts_dependents` | 9640250 | 8031610 | 8433191 | changed |
| `test_component_define::quest_define_rejects_association_overflow` | 50352270 | 47416290 | 49787105 | changed |
| `test_component_define::quest_define_rejects_duplicate_condition` | 4927780 | 4385400 | 4604670 | changed |
| `test_component_define::quest_define_rejects_invalid_input` | 3921080 | 3894240 | 4088952 | changed |
| `test_component_define::quest_define_rejects_retired_condition` | 5168000 | 4842530 | 5084657 | changed |
| `test_component_define::quest_define_rejects_self_condition` | 2995740 | 2986660 | 3135993 | changed |
| `test_component_define::quest_define_rejects_too_many_conditions` | 15999160 | 14087740 | 14792127 | changed |
| `test_component_define::quest_define_rejects_undefined_condition` | 3049990 | 3038930 | 3190877 | changed |
| `test_component_define::quest_define_stores_and_emits` | 8062170 | 6346680 | 6664014 | changed |
| `test_component_define::quest_define_twice_reverts` | 4911680 | 4369300 | 4587765 | changed |
| `test_component_define::quest_empty_slot_reads_undefined` | 2745300 | 2742420 | 2879541 | changed |
| `test_component_dependents::quest_define_reaches_max_dependents` | 9544160 | 7929740 | 8326227 | changed |
| `test_component_dependents::quest_define_rejects_too_many_dependents` | 10700260 | 9028620 | 9480051 | changed |
| `test_component_dependents::quest_retire_dependent_frees_max_dependents` | 12997420 | 11286530 | 11850857 | changed |
| `test_component_event_mode::quest_batch_event_mode_one_event_per_task` | 5237059 | 5627089 | 5908444 | changed |
| `test_component_event_mode::quest_event_mode_calls_no_hook` | 4944936 | 5335766 | 5602555 | changed |
| `test_component_event_mode::quest_event_mode_cannot_be_claimed` | 5434686 | 5817296 | 6108161 | changed |
| `test_component_event_mode::quest_event_mode_emits_only_progressed` | 5179696 | 5562456 | 5840579 | changed |
| `test_component_event_mode::quest_event_mode_zero_count_emits_nothing` | 3165198 | 3165418 | 3323689 | changed |
| `test_component_event_mode::quest_modes_do_not_mix` | 5957262 | 6314952 | 6630700 | changed |
| `test_component_events::quest_accept_and_abandon_emit_nothing` | 5386190 | 4954880 | 5202624 | changed |
| `test_component_events::quest_current_interval_view` | 5525770 | 4982370 | 5231489 | changed |
| `test_component_events::quest_events_keys_and_data` | 16074402 | 15837352 | 16629220 | changed |
| `test_component_game::baseline_game_case_three_per_task` | 88639842 | 76877632 | 80721514 | changed |
| `test_component_game::baseline_game_case_two_per_task` | 63718162 | 54059232 | 56762194 | changed |
| `test_component_game::game_case_three_per_task` | 98784008 | 81349348 | 85416816 | changed |
| `test_component_game::game_case_two_per_task` | 71733208 | 58530948 | 61457496 | changed |
| `test_component_grid::baseline_grid_e16_n1_k0` | 21503220 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n1_k1` | 35154640 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n1_k3` | 48806720 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n1_k7` | 76118240 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n28_k0` | 408769060 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n28_k7` | 1938232080 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n2_k0` | 35067780 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n2_k1` | 62372160 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n2_k3` | 89678800 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n2_k7` | 144306800 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n4_k0` | 62204260 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n4_k1` | 116814560 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n4_k3` | 171430320 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n4_k7` | 280691280 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n7_k0` | 102908980 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n7_k1` | 198478160 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n7_k3` | 294057600 | — | — | removed |
| `test_component_grid::baseline_grid_e16_n7_k7` | 485268000 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n1_k0` | 2089400 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n1_k1` | 2941170 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n1_k3` | 3792100 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n1_k7` | 5494420 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n28_k0` | 26267190 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n28_k7` | 121850210 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n2_k0` | 2936210 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n2_k1` | 4641290 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n2_k3` | 6345630 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n2_k7` | 9755230 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n4_k0` | 4630290 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n4_k1` | 8041990 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n4_k3` | 11453150 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n4_k7` | 18277310 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n7_k0` | 7171410 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n7_k1` | 13143040 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n7_k3` | 19114430 | — | — | removed |
| `test_component_grid::baseline_grid_e1_n7_k7` | 31060430 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n1_k0` | 5971980 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n1_k1` | 9383680 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n1_k3` | 12794840 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n1_k7` | 19619000 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n2_k0` | 9362340 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n2_k1` | 16187280 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n2_k3` | 23012080 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n2_k7` | 36665360 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n4_k0` | 16144900 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n4_k1` | 29796320 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n4_k3` | 43448400 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n4_k7` | 70759920 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n7_k0` | 26318740 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n7_k1` | 50209880 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n7_k3` | 74102880 | — | — | removed |
| `test_component_grid::baseline_grid_e4_n7_k7` | 121901760 | — | — | removed |
| `test_component_grid::baseline_grid_event_e1` | 794330 | — | — | removed |
| `test_component_grid::baseline_grid_event_e16` | 837750 | — | — | removed |
| `test_component_grid::baseline_grid_event_e4` | 802830 | — | — | removed |
| `test_component_grid::baseline_grid_h0` | — | 905870 | 951164 | new |
| `test_component_grid::baseline_grid_h1_complete` | — | 2167700 | 2276085 | new |
| `test_component_grid::baseline_grid_h1_count` | — | 2167700 | 2276085 | new |
| `test_component_grid::baseline_grid_h1_done` | — | 2589770 | 2719259 | new |
| `test_component_grid::baseline_grid_h1_expired` | — | 2167700 | 2276085 | new |
| `test_component_grid::baseline_grid_h1_miss` | — | 2167700 | 2276085 | new |
| `test_component_grid::baseline_grid_h2_complete` | — | 3008040 | 3158442 | new |
| `test_component_grid::baseline_grid_h2_count` | — | 3008040 | 3158442 | new |
| `test_component_grid::baseline_grid_h2_done` | — | 3852080 | 4044684 | new |
| `test_component_grid::baseline_grid_h2_expired` | — | 3008040 | 3158442 | new |
| `test_component_grid::baseline_grid_h2_miss` | — | 3008040 | 3158442 | new |
| `test_component_grid::baseline_grid_h4_complete` | — | 5114570 | 5370299 | new |
| `test_component_grid::baseline_grid_h4_count` | — | 5114570 | 5370299 | new |
| `test_component_grid::baseline_grid_h4_done` | — | 6802550 | 7142678 | new |
| `test_component_grid::baseline_grid_h4_expired` | — | 5114570 | 5370299 | new |
| `test_component_grid::baseline_grid_h4_miss` | — | 5114570 | 5370299 | new |
| `test_component_grid::baseline_grid_h8_complete` | — | 9327630 | 9794012 | new |
| `test_component_grid::baseline_grid_h8_count` | — | 9327630 | 9794012 | new |
| `test_component_grid::baseline_grid_h8_done` | — | 12703490 | 13338665 | new |
| `test_component_grid::baseline_grid_h8_expired` | — | 9327630 | 9794012 | new |
| `test_component_grid::baseline_grid_h8_miss` | — | 9327630 | 9794012 | new |
| `test_component_grid::grid_e16_n1_k0` | 41566016 | — | — | removed |
| `test_component_grid::grid_e16_n1_k1` | 56695996 | — | — | removed |
| `test_component_grid::grid_e16_n1_k3` | 71684076 | — | — | removed |
| `test_component_grid::grid_e16_n1_k7` | 101658156 | — | — | removed |
| `test_component_grid::grid_e16_n28_k0` | 937958096 | — | — | removed |
| `test_component_grid::grid_e16_n28_k7` | 2620780476 | — | — | removed |
| `test_component_grid::grid_e16_n2_k0` | 73879696 | — | — | removed |
| `test_component_grid::grid_e16_n2_k1` | 104141196 | — | — | removed |
| `test_component_grid::grid_e16_n2_k3` | 134119836 | — | — | removed |
| `test_component_grid::grid_e16_n2_k7` | 194072956 | — | — | removed |
| `test_component_grid::grid_e16_n4_k0` | 138523536 | — | — | removed |
| `test_component_grid::grid_e16_n4_k1` | 199048076 | — | — | removed |
| `test_component_grid::grid_e16_n4_k3` | 259007836 | — | — | removed |
| `test_component_grid::grid_e16_n4_k7` | 378919036 | — | — | removed |
| `test_component_grid::grid_e16_n7_k0` | 236417056 | — | — | removed |
| `test_component_grid::grid_e16_n7_k1` | 342336156 | — | — | removed |
| `test_component_grid::grid_e16_n7_k3` | 447267596 | — | — | removed |
| `test_component_grid::grid_e16_n7_k7` | 657115916 | — | — | removed |
| `test_component_grid::grid_e1_n1_k0` | 3501406 | — | — | removed |
| `test_component_grid::grid_e1_n1_k1` | 4445586 | — | — | removed |
| `test_component_grid::grid_e1_n1_k3` | 5380016 | — | — | removed |
| `test_component_grid::grid_e1_n1_k7` | 7248746 | — | — | removed |
| `test_component_grid::grid_e1_n28_k0` | 59499586 | — | — | removed |
| `test_component_grid::grid_e1_n28_k7` | 164667566 | — | — | removed |
| `test_component_grid::grid_e1_n2_k0` | 5520036 | — | — | removed |
| `test_component_grid::grid_e1_n2_k1` | 7409936 | — | — | removed |
| `test_component_grid::grid_e1_n2_k3` | 9281276 | — | — | removed |
| `test_component_grid::grid_e1_n2_k7` | 13023696 | — | — | removed |
| `test_component_grid::grid_e1_n4_k0` | 9558326 | — | — | removed |
| `test_component_grid::grid_e1_n4_k1` | 13339666 | — | — | removed |
| `test_component_grid::grid_e1_n4_k3` | 17084826 | — | — | removed |
| `test_component_grid::grid_e1_n4_k7` | 24574626 | — | — | removed |
| `test_component_grid::grid_e1_n7_k0` | 15673746 | — | — | removed |
| `test_component_grid::grid_e1_n7_k1` | 22292246 | — | — | removed |
| `test_component_grid::grid_e1_n7_k3` | 28848136 | — | — | removed |
| `test_component_grid::grid_e1_n7_k7` | 41959006 | — | — | removed |
| `test_component_grid::grid_e4_n1_k0` | 11114144 | — | — | removed |
| `test_component_grid::grid_e4_n1_k1` | 14895484 | — | — | removed |
| `test_component_grid::grid_e4_n1_k3` | 18640644 | — | — | removed |
| `test_component_grid::grid_e4_n1_k7` | 26130444 | — | — | removed |
| `test_component_grid::grid_e4_n2_k0` | 19191784 | — | — | removed |
| `test_component_grid::grid_e4_n2_k1` | 26756004 | — | — | removed |
| `test_component_grid::grid_e4_n2_k3` | 34248804 | — | — | removed |
| `test_component_grid::grid_e4_n2_k7` | 49233364 | — | — | removed |
| `test_component_grid::grid_e4_n4_k0` | 35351184 | — | — | removed |
| `test_component_grid::grid_e4_n4_k1` | 50481164 | — | — | removed |
| `test_component_grid::grid_e4_n4_k3` | 65469244 | — | — | removed |
| `test_component_grid::grid_e4_n4_k7` | 95443324 | — | — | removed |
| `test_component_grid::grid_e4_n7_k0` | 59822224 | — | — | removed |
| `test_component_grid::grid_e4_n7_k1` | 86300844 | — | — | removed |
| `test_component_grid::grid_e4_n7_k3` | 112531844 | — | — | removed |
| `test_component_grid::grid_e4_n7_k7` | 164990204 | — | — | removed |
| `test_component_grid::grid_event_e1` | 1015276 | — | — | removed |
| `test_component_grid::grid_event_e16` | 2053886 | — | — | removed |
| `test_component_grid::grid_event_e16_on_n7_k7` | 486482706 | — | — | removed |
| `test_component_grid::grid_event_e4` | 1222814 | — | — | removed |
| `test_component_grid::grid_h0` | — | 1896383 | 1991203 | new |
| `test_component_grid::grid_h1_complete` | — | 4390683 | 4610218 | new |
| `test_component_grid::grid_h1_count` | — | 3846323 | 4038640 | new |
| `test_component_grid::grid_h1_done` | — | 3676853 | 3860696 | new |
| `test_component_grid::grid_h1_expired` | — | 3211093 | 3371648 | new |
| `test_component_grid::grid_h1_miss` | — | 3393063 | 3562717 | new |
| `test_component_grid::grid_h2_complete` | — | 6547683 | 6875068 | new |
| `test_component_grid::grid_h2_count` | — | 5417023 | 5687875 | new |
| `test_component_grid::grid_h2_done` | — | 5077983 | 5331883 | new |
| `test_component_grid::grid_h2_expired` | — | 4146563 | 4353892 | new |
| `test_component_grid::grid_h2_miss` | — | 4510503 | 4736029 | new |
| `test_component_grid::grid_h4_complete` | — | 11247163 | 11809522 | new |
| `test_component_grid::grid_h4_count` | — | 8943803 | 9390994 | new |
| `test_component_grid::grid_h4_done` | — | 8265623 | 8678905 | new |
| `test_component_grid::grid_h4_expired` | — | 6402883 | 6723028 | new |
| `test_component_grid::grid_h4_miss` | — | 7130763 | 7487302 | new |
| `test_component_grid::grid_h8_complete` | — | 20609393 | 21639863 | new |
| `test_component_grid::grid_h8_count` | — | 15960633 | 16758665 | new |
| `test_component_grid::grid_h8_done` | — | 14604173 | 15334382 | new |
| `test_component_grid::grid_h8_expired` | — | 10878793 | 11422733 | new |
| `test_component_grid::grid_h8_miss` | — | 12334553 | 12951281 | new |
| `test_component_options::baseline_option_e12_n1_k7` | 57273610 | — | — | removed |
| `test_component_options::baseline_option_e15_n1_k0` | 20194580 | — | — | removed |
| `test_component_options::baseline_option_e16_n1_k0` | 21487910 | — | — | removed |
| `test_component_options::baseline_option_e2_n7_k4` | 43415850 | — | — | removed |
| `test_component_options::baseline_option_e3_n5_k2` | 34042450 | — | — | removed |
| `test_component_options::baseline_option_e4_n3_k7` | 53708610 | — | — | removed |
| `test_component_options::baseline_option_e4_n4_k0` | 16140870 | — | — | removed |
| `test_component_options::baseline_option_e5_n3_k1` | 28536960 | — | — | removed |
| `test_component_options::baseline_option_e7_n2_k3` | 39671910 | — | — | removed |
| `test_component_options::baseline_option_e8_n2_k0` | 17923030 | — | — | removed |
| `test_component_options::option_e12_n1_k7` | 76815759 | — | — | removed |
| `test_component_options::option_e15_n1_k0` | 39530797 | — | — | removed |
| `test_component_options::option_e16_n1_k0` | 42132323 | — | — | removed |
| `test_component_options::option_e2_n7_k4` | 63316699 | — | — | removed |
| `test_component_options::option_e3_n5_k2` | 54053565 | — | — | removed |
| `test_component_options::option_e4_n3_k7` | 72387311 | — | — | removed |
| `test_component_options::option_e4_n4_k0` | 35400531 | — | — | removed |
| `test_component_options::option_e5_n3_k1` | 48104417 | — | — | removed |
| `test_component_options::option_e7_n2_k3` | 59344119 | — | — | removed |
| `test_component_options::option_e8_n2_k0` | 37582275 | — | — | removed |
| `test_component_prerequisites::quest_dependent_unlocks_when_window_opens` | 14310728 | 15039398 | 15791368 | changed |
| `test_component_prerequisites::quest_inactive_dependent_does_not_revert` | 12383136 | 12199226 | 12809188 | changed |
| `test_component_prerequisites::quest_is_unlocked_evaluates_uncached` | 12211336 | 12012156 | 12612764 | changed |
| `test_component_prerequisites::quest_prerequisite_completed_before_definition` | 13539862 | 13933282 | 14629947 | changed |
| `test_component_prerequisites::quest_prerequisites_all_required` | 15304322 | 14972422 | 15721044 | changed |
| `test_component_prerequisites::quest_prerequisites_unlock_after_last` | 20546088 | 21469138 | 22542595 | changed |
| `test_component_prerequisites::quest_recurring_dependent_stays_unlocked` | 21897248 | 22899888 | 24044883 | changed |
| `test_component_prerequisites::quest_recurring_prerequisite_after_dependent_completed` | 21414358 | 22457398 | 23580268 | changed |
| `test_component_prerequisites::quest_recurring_prerequisite_completed_before_definition` | 13614872 | 14011592 | 14712172 | changed |
| `test_component_prerequisites::quest_recurring_prerequisite_completes_every_interval` | 21524608 | 22316018 | 23431819 | changed |
| `test_component_prerequisites::quest_unlock_cached_by_accept` | — | 14755372 | 15493141 | new |
| `test_component_prerequisites::quest_unlock_cached_by_progress` | 14581358 | — | — | removed |
| `test_component_prerequisites::quest_without_conditions_is_unlocked` | 4582270 | 4046690 | 4249025 | changed |
| `test_component_probe::probe_baseline` | 453720 | 453720 | 476406 | unchanged |
| `test_component_probe::probe_emit_100` | 5307920 | 5307920 | 5573316 | unchanged |
| `test_component_probe::probe_read_100` | 3474220 | 3474220 | 3647931 | unchanged |
| `test_component_probe::probe_store_baseline` | — | 42618190 | 44749100 | new |
| `test_component_probe::probe_store_then_change_100` | — | 48328090 | 50744495 | new |
| `test_component_probe::probe_unpack_definition_100` | 2514990 | 2316990 | 2432840 | changed |
| `test_component_probe::probe_unpack_held_100` | — | 1365790 | 1434080 | new |
| `test_component_probe::probe_unpack_record_100` | 1517190 | 1161190 | 1219250 | changed |
| `test_component_probe::probe_unpack_tasks_100` | 1716190 | 1716190 | 1802000 | unchanged |
| `test_component_probe::probe_write_100` | 46363620 | 46363620 | 48681801 | unchanged |
| `test_component_probe::probe_write_then_change_100` | 52345030 | 52345030 | 54962282 | unchanged |
| `test_component_probe::probe_write_then_overwrite_100` | 52345030 | 52345030 | 54962282 | unchanged |
| `test_component_probe::probe_write_twice_in_one_call_baseline` | 46635130 | 46635130 | 48966887 | unchanged |
| `test_component_progress::baseline_batch_two_tasks_one_quest` | 5249830 | 5121650 | 5377733 | changed |
| `test_component_progress::baseline_batch_two_tasks_one_quest_not_completing` | 5124590 | 4996410 | 5246231 | changed |
| `test_component_progress::quest_batch_above_bound_reverts` | 3236520 | 3244280 | 3406494 | changed |
| `test_component_progress::quest_batch_duplicate_entries_merged` | 5629349 | 5987029 | 6286381 | changed |
| `test_component_progress::quest_batch_duplicates_count_toward_bound` | 2974800 | 2978580 | 3127509 | changed |
| `test_component_progress::quest_batch_quest_on_two_entries_handled_once` | 8562322 | 8803432 | 9243604 | changed |
| `test_component_progress::quest_batch_rejects_task_zero` | 3030582 | 3038342 | 3190260 | changed |
| `test_component_progress::quest_batch_two_tasks_one_quest_one_write` | 10336542 | 10056672 | 10559506 | changed |
| `test_component_progress::quest_batch_two_tasks_one_quest_one_write_not_completing` | 6274852 | 6000492 | 6300517 | changed |
| `test_component_progress::quest_count_max_value` | 10123252 | 10405442 | 10925715 | changed |
| `test_component_progress::quest_count_saturates_at_total` | 10213112 | 10532442 | 11059065 | changed |
| `test_component_progress::quest_daily_interval_aligned_on_utc_midnight` | 7227682 | 8082732 | 8486869 | changed |
| `test_component_progress::quest_daily_rollover_starts_from_zero` | 7050832 | 7909842 | 8305335 | changed |
| `test_component_progress::quest_held_by_one_player_not_progressed_by_another` | — | 9978582 | 10477512 | new |
| `test_component_progress::quest_inactive_quest_skipped_not_reverted` | 7420766 | 8345936 | 8763233 | changed |
| `test_component_progress::quest_interval_id_is_u64` | 5831946 | 6189296 | 6498761 | changed |
| `test_component_progress::quest_not_held_not_progressed` | — | 6475372 | 6799141 | new |
| `test_component_progress::quest_one_off_completes_once` | 10098952 | 10381442 | 10900515 | changed |
| `test_component_progress::quest_progress_is_per_player` | 5742726 | 6100406 | 6405427 | changed |
| `test_component_progress::quest_recurring_completes_each_interval` | 20179534 | 21449544 | 22522022 | changed |
| `test_component_progress::quest_task_shared_by_max_quests` | 168914536 | 66613976 | 69944675 | changed |
| `test_component_reentry::quest_reentrant_abandon_later_quest_not_progressed` | — | 19927736 | 20924123 | new |
| `test_component_reentry::quest_reentrant_abandon_other_quest_leaves_outer_unchanged` | — | 57955694 | 60853479 | new |
| `test_component_reentry::quest_reentrant_accept_after_completion_refused` | 7793526 | 7502496 | 7877621 | changed |
| `test_component_reentry::quest_reentrant_accept_not_progressed_by_the_call` | — | 16823202 | 17664363 | new |
| `test_component_reentry::quest_reentrant_accept_other_quest_leaves_outer_unchanged` | 55636314 | 58696954 | 61631802 | changed |
| `test_component_reentry::quest_reentrant_claim_other_quest_leaves_outer_unchanged` | 58265404 | 60637724 | 63669611 | changed |
| `test_component_reentry::quest_reentrant_claim_same_quest_refused` | 11442046 | 11596606 | 12176437 | changed |
| `test_component_reentry::quest_reentrant_progress_later_quest_completes_once` | 17343742 | 17820932 | 18711979 | changed |
| `test_component_reentry::quest_reentrant_progress_other_quest_leaves_outer_unchanged` | 59679100 | 62492180 | 65616789 | changed |
| `test_component_reentry::quest_reentrant_progress_same_quest_completes_once` | 10832082 | 10940322 | 11487339 | changed |
| `test_component_reentry::quest_reentrant_retire_other_quest_leaves_outer_unchanged` | 55001484 | 57497014 | 60371865 | changed |
| `test_component_reentry::quest_retired_by_hook_not_progressed` | 13229536 | 13561206 | 14239267 | changed |
| `test_component_retire::quest_redefine_retired_reverts` | 5110540 | 4787050 | 5026403 | changed |
| `test_component_retire::quest_retire_abandon_before_is_kept` | 5722820 | 5653610 | 5936291 | changed |
| `test_component_retire::quest_retire_dependent_then_prerequisite` | 7930330 | 7288990 | 7653440 | changed |
| `test_component_retire::quest_retire_frees_slot` | 51550730 | 14741210 | 15478271 | changed |
| `test_component_retire::quest_retire_keeps_pages_contiguous` | 58104140 | — | — | removed |
| `test_component_retire::quest_retire_last_quest_empties_page` | 4986780 | — | — | removed |
| `test_component_retire::quest_retire_prerequisite_with_live_dependent_reverts` | 7601270 | 6489420 | 6813891 | changed |
| `test_component_retire::quest_retire_twice_reverts` | 5388010 | 4996020 | 5245821 | changed |
| `test_component_retire::quest_retired_accept_reverts` | 5120780 | 4821400 | 5062470 | changed |
| `test_component_retire::quest_retired_completed_still_claimable` | 12715966 | 13279606 | 13943587 | changed |
| `test_component_retire::quest_retired_definition_readable` | 4871670 | 4552580 | 4780209 | changed |
| `test_component_retire::quest_retired_is_not_accepted` | 6228240 | 5946250 | 6243563 | changed |
| `test_component_retire::quest_retired_not_progressed` | 7864156 | 8614646 | 9045379 | changed |
| `test_constants::quest_bounds_are_the_accepted_ones` | 13720 | 13720 | 14406 | unchanged |
| `test_definition::conditions_span_has_count_entries` | 104530 | 104530 | 109757 | unchanged |
| `test_definition::definition_new_one_task` | 27110 | 26210 | 27521 | changed |
| `test_definition::definition_new_round_trips_through_the_spans` | 70830 | 70630 | 74162 | changed |
| `test_definition::definition_new_three_tasks_seven_conditions` | 160730 | 160010 | 168011 | changed |
| `test_definition::definition_new_unused_slots_are_zero` | 37590 | 37390 | 39260 | changed |
| `test_definition::quest_define_rejects_condition_zero` | 27060 | 26860 | 28203 | changed |
| `test_definition::quest_define_rejects_duplicate_condition` | 33030 | 32830 | 34472 | changed |
| `test_definition::quest_define_rejects_duplicate_condition_far_apart` | 125580 | 125380 | 131649 | changed |
| `test_definition::quest_define_rejects_duration_above_interval` | 15520 | 15520 | 16296 | unchanged |
| `test_definition::quest_define_rejects_half_recurring` | 15520 | 15520 | 16296 | unchanged |
| `test_definition::quest_define_rejects_invalid_id` | 15520 | 15520 | 16296 | unchanged |
| `test_definition::quest_define_rejects_invalid_window` | 15520 | 15520 | 16296 | unchanged |
| `test_definition::quest_define_rejects_more_than_three_tasks` | 15520 | 15520 | 16296 | unchanged |
| `test_definition::quest_define_rejects_no_task` | 15520 | 15520 | 16296 | unchanged |
| `test_definition::quest_define_rejects_repeated_task` | 20530 | 20420 | 21441 | changed |
| `test_definition::quest_define_rejects_repeated_task_first_and_last` | 21530 | 21420 | 22491 | changed |
| `test_definition::quest_define_rejects_repeated_task_second_and_last` | 20320 | 20220 | 21231 | changed |
| `test_definition::quest_define_rejects_self_condition` | 21590 | 21390 | 22460 | changed |
| `test_definition::quest_define_rejects_task_zero` | 19120 | 19020 | 19971 | changed |
| `test_definition::quest_define_rejects_too_many_conditions` | 18630 | 18530 | 19457 | changed |
| `test_definition::quest_define_rejects_total_zero` | 20120 | 20020 | 21021 | changed |
| `test_definition::tasks_index_of_finds_used_slots_only` | 13720 | 13720 | 14406 | unchanged |
| `test_definition::tasks_span_has_task_count_entries` | 43210 | 43210 | 45371 | unchanged |
| `test_errors::quest_error_strings_are_the_accepted_ones` | 13720 | 13720 | 14406 | unchanged |
| `test_held::held_contains_needs_the_same_interval` | — | 37620 | 39501 | new |
| `test_held::held_position_finds_the_quest` | — | 38240 | 40152 | new |
| `test_held::held_remove_keeps_the_order` | — | 118150 | 124058 | new |
| `test_held::held_slot_pairs_entries_and_pads_with_empty` | — | 19040 | 19992 | new |
| `test_packing::quest_empty_slot_reads_undefined` | 37980 | 35300 | 37065 | changed |
| `test_packing::quest_packing_accepts_the_bounds` | 4680920 | 3702550 | 3887678 | changed |
| `test_packing::quest_packing_presence_bits_at_their_positions` | 1138250 | 1110290 | 1165805 | changed |
| `test_packing::quest_packing_rejects_condition_count_16` | 15520 | 15520 | 16296 | unchanged |
| `test_packing::quest_packing_rejects_condition_count_8` | 15520 | 15520 | 16296 | unchanged |
| `test_packing::quest_packing_rejects_page_len_255` | 15520 | — | — | removed |
| `test_packing::quest_packing_rejects_page_len_8` | 15520 | — | — | removed |
| `test_packing::quest_packing_rejects_task_count_255` | 15520 | 15520 | 16296 | unchanged |
| `test_packing::quest_packing_rejects_task_count_4` | 15520 | 15520 | 16296 | unchanged |
| `test_packing::quest_packing_round_trip_conditions` | 19268540 | 19269540 | 20233017 | changed |
| `test_packing::quest_packing_round_trip_definition_max` | 27686180 | 23754800 | 24942540 | changed |
| `test_packing::quest_packing_round_trip_definition_mixed` | 7560970 | 7136390 | 7493210 | changed |
| `test_packing::quest_packing_round_trip_definition_zero` | 2530360 | 2388570 | 2507999 | changed |
| `test_packing::quest_packing_round_trip_held_slot` | — | 9215370 | 9676139 | new |
| `test_packing::quest_packing_round_trip_page` | 12922480 | — | — | removed |
| `test_packing::quest_packing_round_trip_progress` | 11909220 | 11909220 | 12504681 | unchanged |
| `test_packing::quest_packing_round_trip_record` | 12947340 | 7143570 | 7500749 | changed |
| `test_packing::quest_packing_round_trip_tasks` | 15134650 | 15134650 | 15891383 | unchanged |
| `test_packing::quest_unpacking_progress_reads_bit_97_alone` | 689570 | 689570 | 724049 | unchanged |
| `test_packing::quest_unpacking_rejects_conditions_bit_224` | 377150 | 377250 | 396113 | changed |
| `test_packing::quest_unpacking_rejects_definition_bit_215` | — | 425120 | 446376 | new |
| `test_packing::quest_unpacking_rejects_definition_bit_216` | 396190 | — | — | removed |
| `test_packing::quest_unpacking_rejects_definition_felt_minus_one` | 33560 | 31580 | 33159 | changed |
| `test_packing::quest_unpacking_rejects_held_bit_224` | — | 369620 | 388101 | new |
| `test_packing::quest_unpacking_rejects_held_bit_96` | — | 339180 | 356139 | new |
| `test_packing::quest_unpacking_rejects_page_bit_230` | 407250 | — | — | removed |
| `test_packing::quest_unpacking_rejects_page_len_8` | 409000 | — | — | removed |
| `test_packing::quest_unpacking_rejects_progress_bit_128` | 343080 | 343080 | 360234 | unchanged |
| `test_packing::quest_unpacking_rejects_progress_bit_98` | 356080 | 356080 | 373884 | unchanged |
| `test_packing::quest_unpacking_rejects_record_bit_129` | — | 356040 | 373842 | new |
| `test_packing::quest_unpacking_rejects_record_bit_194` | 372130 | — | — | removed |
| `test_packing::quest_unpacking_rejects_tasks_bit_192` | 359240 | 359240 | 377202 | unchanged |
| `test_pages::page_pop_empty_panics` | 15520 | — | — | removed |
| `test_pages::page_pop_removes_the_last_id` | 13720 | — | — | removed |
| `test_pages::page_position_among_len_ids` | 13720 | — | — | removed |
| `test_pages::page_push_appends_until_full` | 87110 | — | — | removed |
| `test_pages::page_push_full_panics` | 15520 | — | — | removed |
| `test_pages::page_set_beyond_len_panics` | 15520 | — | — | removed |
| `test_pages::page_set_replaces_one_id` | 13720 | — | — | removed |
| `test_pages::page_span_has_len_entries` | 31900 | — | — | removed |
| `test_pages::pages_removal_keeps_pages_contiguous` | 810930 | — | — | removed |
| `test_pages::pages_removal_of_the_only_id` | 172240 | — | — | removed |
| `test_pages::quest_retire_frees_slot_pages` | 566680 | — | — | removed |
| `test_progress::progress_add_ignores_other_tasks` | 46840 | 46840 | 49182 | unchanged |
| `test_progress::progress_add_keeps_claimed` | 16790 | 16790 | 17630 | unchanged |
| `test_progress::progress_add_matches_the_plain_formula` | 9379140 | 9379140 | 9848097 | unchanged |
| `test_progress::progress_add_three_tasks_partial_then_complete` | 63440 | 63440 | 66612 | unchanged |
| `test_progress::progress_add_touches_only_task_count_slots` | 24310 | 24310 | 25526 | unchanged |
| `test_progress::progress_is_complete_per_task_count` | 15940 | 15940 | 16737 | unchanged |
| `test_progress::quest_batch_duplicate_entries_merged_progress` | 58829 | 58829 | 61771 | unchanged |
| `test_progress::quest_batch_two_tasks_one_quest_one_write_logic` | 50012 | 50012 | 52513 | unchanged |
| `test_progress::quest_count_max_value` | 34610 | 34610 | 36341 | unchanged |
| `test_progress::quest_count_max_value_below_total` | 22160 | 22160 | 23268 | unchanged |
| `test_progress::quest_count_saturates_at_total` | 45750 | 45750 | 48038 | unchanged |
| `test_progress::quest_one_off_completes_once` | 31000 | 31000 | 32550 | unchanged |
| `test_record::claim_marks_claimed_and_counts` | 13720 | 13720 | 14406 | unchanged |
| `test_record::prerequisites_met_when_each_completed_once` | 40180 | 37080 | 38934 | changed |
| `test_record::quest_abandon_expired_reverts` | 15520 | — | — | removed |
| `test_record::quest_accept_twice_same_interval_reverts` | 15520 | — | — | removed |
| `test_record::quest_acceptance_expires_at_rollover_logic` | 13720 | — | — | removed |
| `test_record::quest_claim_index_counts_claims` | 13720 | 13720 | 14406 | unchanged |
| `test_record::quest_claim_twice_reverts` | 15520 | 15520 | 16296 | unchanged |
| `test_record::quest_claim_uncompleted_reverts` | 15520 | 15520 | 16296 | unchanged |
| `test_record::quest_claim_uncompleted_reverts_before_claimed` | 15520 | 15520 | 16296 | unchanged |
| `test_record::quest_completion_releases_acceptance` | 13720 | — | — | removed |
| `test_record::quest_prerequisites_all_required_logic` | 28420 | 27020 | 28371 | changed |
| `test_record::quest_record_counters_past_u32` | 27900 | 22940 | 24087 | changed |
| `test_record::quest_record_counters_saturate` | 13720 | 13720 | 14406 | unchanged |
| `test_record::quest_recurring_completes_each_interval_logic` | 13720 | 13720 | 14406 | unchanged |
| `test_record::record_abandon_clears_active` | 13720 | — | — | removed |
| `test_record::record_abandon_not_accepted_reverts` | 15520 | — | — | removed |
| `test_record::record_accept_sets_active_and_interval` | 13720 | — | — | removed |
| `test_record::record_complete_keeps_unlocked_and_claims` | 13720 | 13720 | 14406 | unchanged |
| `test_record::record_is_accepted_in_its_interval_only` | 15940 | — | — | removed |
| `test_schedule::quest_daily_interval_aligned_on_utc_midnight` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::quest_interval_id_is_u64` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::schedule_interval_id_never_panics_at_the_bounds` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::schedule_interval_id_none_when_inactive` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::schedule_interval_id_one_off_is_zero` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::schedule_interval_id_recurring` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::schedule_is_active_duration_equal_to_interval_is_always_active` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::schedule_is_active_never_ends_when_end_is_zero` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::schedule_is_active_one_off_window` | 15940 | 15940 | 16737 | unchanged |
| `test_schedule::schedule_is_active_recurring` | 16240 | 16240 | 17052 | unchanged |
| `test_schedule::schedule_validate_accepts_valid_schedules` | 13720 | 13720 | 14406 | unchanged |
| `test_schedule::schedule_validate_rejects_duration_above_interval` | 15520 | 15520 | 16296 | unchanged |
| `test_schedule::schedule_validate_rejects_duration_above_interval_at_max` | 15520 | 15520 | 16296 | unchanged |
| `test_schedule::schedule_validate_rejects_empty_window` | 15520 | 15520 | 16296 | unchanged |
| `test_schedule::schedule_validate_rejects_end_before_start` | 15520 | 15520 | 16296 | unchanged |
| `test_schedule::schedule_validate_rejects_half_recurring_duration_only` | 15520 | 15520 | 16296 | unchanged |
| `test_schedule::schedule_validate_rejects_half_recurring_interval_only` | 15520 | 15520 | 16296 | unchanged |

## Acceptance criteria

- [x] **AC-1**: acceptance is mandatory, at most `MAX_HELD` quests are held, and progress walks
  the held list and reads no task page and no prerequisite.
  - Code: `src/component.cairo` (`progress_many`, `progress_held`, `accept`).
  - Tests: `quest_accept_required`, `quest_not_held_not_progressed`,
    `quest_accept_list_full_reverts`, `quest_task_shared_by_max_quests` (28 quests on the task,
    only the 4 held count).
  - No task page exists any more. The reads of each progress benchmark are exactly the list, then
    A, P, B, R per held quest (`--detailed-resources`, above).
- [x] **AC-2**: the worst call is measured under 20 M for H = 4 and 8, with empty hooks and with
  a hook writing one slot: 6.13 M, 11.28 M, 7.95 M, 14.91 M. The game's use is measured
  (`game_case_three_per_task`, `game_case_two_per_task`): 4.47 M, or 5.28 M in a transaction of
  its own.
- [x] **AC-3**: `GAS.md`, in the section below the table, and `docs/BUDGETS.md` give the changed
  slot (402 000; 459 099 against 57 099), the slots changed per entrypoint (best, common, worst),
  and the worst call against 20 M and 1.1 × 10⁹.
- [x] **AC-4**: every named test case of ARC-01 §2 for `quest` exists and passes. The new cases of
  Scope 7 exist:
  - `quest_accept_list_full_reverts`;
  - `quest_expired_acceptance_pruned`;
  - `quest_completed_leaves_list`;
  - `quest_held_by_one_player_not_progressed_by_another`;
  - `quest_reentrant_accept_not_progressed_by_the_call`,
    `quest_reentrant_abandon_later_quest_not_progressed`,
    `quest_reentrant_abandon_other_quest_leaves_outer_unchanged` and
    `quest_reentrant_accept_other_quest_leaves_outer_unchanged`.

  Every test has a budget, and `scripts/gas.py packages/quest --check` passes, locally and in CI.
- [x] **AC-5**: ARC-01 §3.1 (the bounds row), §3.2, §3.3, §3.5 and §5.1 are amended in this pull
  request, each marked "Amended by D-135". The README (usage with `accept_quest`, the held list,
  bounds, the integration budget with the measured worst calls) and the CHANGELOG (0.1.0, with a
  subsection listing what D-135 changed) are ready.
- [x] **AC-6**: the pull request's CI is green: `cairo`, `package (packages/quest)` (with
  `gas.py --check`), `affected`, `links` and `scripts`.

### The named tests whose meaning changed, and why

Every named test of §2 kept its name. Where the rule of D-135 changes what the test can observe,
the test states the new meaning in its doc comment:

| Test | What it tests now | Why |
|---|---|---|
| `quest_accept_required` | Every quest, not only one defined with an accept step, counts nothing before `accept` | Acceptance is mandatory |
| `quest_completion_releases_acceptance` | The entry is dead after completion (`quest_is_accepted` false), and stays in the list until the next accept | The record has no `active` bit |
| `quest_inactive_quest_skipped_not_reverted` | A **held** quest whose window closed within its interval is skipped | An inactive quest cannot be accepted, so it cannot be held otherwise |
| `quest_prerequisites_all_required` | C cannot be accepted while locked (`'Quest: locked'`), so progress on its task counts nothing | Prerequisites are checked at acceptance |
| `quest_prerequisites_unlock_after_last` | `accept` caches the unlock | Before, the first progress did |
| `quest_dependent_unlocks_when_window_opens` | Before the window, `accept` is refused `'Quest: not active'`; when it opens, the quest is accepted and counts | The same |
| `quest_task_shared_by_max_quests` | 28 quests on one task; one progress counts on the `MAX_HELD` the player holds, and on no other | The walk is of the held list |
| `quest_define_rejects_association_overflow` | A 29th quest on a task is defined; the refusal left is the held list's (`'Quest: too many held'` at accept) | Tasks have no pages and no cap |
| `quest_retire_frees_slot` | Retirement frees the player's held slot at the next accept | The same |
| `quest_retired_not_progressed` | A held, retired quest is skipped; its A **is** read (the §2 row said "no read of Q's A") | The walk reads A to know retirement |
| `quest_retired_is_not_accepted` | The held entry of a retired quest is inert, not the record's bit | The same as `quest_completion_releases_acceptance` |
| `quest_batch_bound_accepted` | 16 distinct tasks, 4 held quests completing, 28 quests on each task not held | The witness of §5.1 is now the held quests |
| `quest_packing_round_trip` | `…_held_slot` replaces `…_page`; A and R have their new layouts | Layouts of §3.3 amended |

The logic versions of `quest_accept_twice_same_interval_reverts`, `quest_abandon_expired_reverts`,
`quest_acceptance_expires_at_rollover` and `quest_completion_releases_acceptance` in
`test_record.cairo` were removed with `record_accept` and `record_abandon`. The component
versions, which were the named tests, remain. `quest_unlock_cached_by_progress`, which is not a
§2 name, became `quest_unlock_cached_by_accept`.

## Deviations from the brief

1. **`QuestRecord` lost `active` and `accepted_interval`** (and `record_is_accepted`,
   `record_accept`, `record_abandon` went with them). The brief asks for the held list's layout
   and not for this. But with acceptance also in the record, every `accept` and `abandon` would
   change two slots instead of one, and progress would read R for every held quest. Scope 1 asks
   to minimise changed slots, and ARC-01 §3.2 and §3.3 are amended accordingly.
2. **A new view, `quest_held(player_id)`** (internal `held_of`). The brief does not ask for it.
   Without the record's bits, a consumer or indexer had no way to list what a player holds
   (`accept` emits no event), and the tests needed it too.
3. **The walk's bound does not depend on `MAX_HELD`.** It reads slots while they are full, up to
   4. This lets the H = 8 case run the same code on a seeded list. I found no way to compile a
   test-only `MAX_HELD = 8`: `#[cfg(test)]` items of `src/` are not visible to the integration
   tests (tried), and a Scarb feature would need a second `snforge` run, which `gas.py` does not
   allow. The cost is one extra slot read when exactly 4 are held (the empty third slot), which
   is in every figure above.
4. **The benchmarks of calls that change slots their setup already changed** (`accept`,
   `abandon`, `claim`, `define`, `retire`, the game's case) under-count 402 000 per such slot in
   snforge. I give both figures. The progress figures, including every worst call, are not
   affected.
5. **ARC-03b's E × N × K grid (111 tests) and cap options (`test_component_options`) are
   removed.** They measured the fan-out through task pages, which no longer exists. The held-list
   grid replaces them.
6. **Hooks after a re-entrant change of the list** (Scope 7, the re-entry tests). A quest a hook
   accepts is not progressed by the running call; a quest a hook abandons is skipped. The brief
   names the tests but not the rule. I chose "the quests held when the call starts and still
   held when reached", like the retired-by-hook skip that ARC-03b's fix loop kept.
7. **`batch_first_position` is kept in the library although the component no longer calls it.**
   It is not a page helper, and Scope 4 does not name it.
8. **Test-driven order.** I wrote the source first, then adapted the tests and wrote the new
   cases, and set the budgets from the measures. All tests passed on the first full run.
9. **One accidental workspace-wide `snforge test`** (see Commands run).

## Escalations

1. **Parts of ARC-01 outside my allowlist are now stale.** They need the orchestrator's edit:
   - §3.4: `QuestDefined` lost `needs_accept`.
   - §3.7: the modes table says acceptance is enforced; in event mode the indexer would also
     need acceptances, and `accept` emits none.
   - §3.8: the consumer sketch keeps its own list of 3 active quests; the package now holds it.
   - §2: test rows that speak of `needs_accept` and `MAX_QUESTS_PER_TASK`, and "no read of Q's
     A" in `quest_retired_not_progressed`.
   - §5: the notation (N, Pg), which no longer applies to quests.
   - §4 and §7, where they mention `quest_is_accepted` and the consumer's list.
2. **`scripts/gas.py --write` still drops the hand-written section of `GAS.md`** (ARC-03b's
   escalation 2). I re-appended it after the final `--write`. Its `ROW_RE` also reads any table
   row that starts with a backticked name followed by two integer cells as a test row. One row of
   my section matched, and `--check` reported "GAS.md lists set_reporter, which is no longer
   measured" until I reworded it.
3. **The API gained `quest_held` and lost `QuestRecord.active` and `accepted_interval`**
   (deviations 1 and 2). This is for the orchestrator and the `[GPT-6-Astra]` audit to confirm
   before the publication request.

## Open questions

1. **Should `MAX_HELD` become a consumer's choice, up to 8?** D-135 makes it a constant of 0.1.0,
   and I kept it so. The layout and the walk already allow 8, measured at 11.3 M (14.9 M with a
   one-slot hook).
2. **Should a completed or expired entry be pruned by `abandon` too?** Today `abandon` removes
   only its own quest, and refuses a completed one (`'Quest: not accepted'`). The next `accept`
   prunes the dead ones.
3. From ARC-03b, still open: `quest_current_interval` for a quest not defined or retired, and
   `quest_is_unlocked` on a retired quest.

## Fix loop 1

The `[GPT-6-Astra]` audit returned FAIL on four points; the orchestrator accepted them. All four
are addressed on the same branch and allowlist.

Commits:

- `94b6d5d`: the fix of point 2, the regressions, the probes, the write assertions and the new
  benchmarks. The regressions were run failing before the fix.
- `9998fb1`: the documents.

**CI is green on `9998fb1`**: `cairo`, `package (packages/quest)` (with `gas.py --check`),
`affected`, `links` and `scripts`. Locally:

- `snforge test`: 394 passed, 0 failed.
- `scripts/gas.py packages/quest --check`: "394 tests within budget, GAS.md up to date".
- `fmt --check` exits 0; `check-links` finds 0 broken links.

**The figures of the sections above are superseded by this section**, `packages/quest/GAS.md`
and `docs/BUDGETS.md`. The "+402 000 per changed slot" corrections of the first version were
wrong.

### Point 1 (major): the 402 000 is an allocation cost. Measured and corrected

**Probes by transition** (`test_component_probe.cairo`, `probe_transition_*`). Each transition is
its own test on 100 cells. Tests that start from a value compare with a baseline that makes the
same first call, so the setup's allocations are the same on both sides.

| Transition in the measured call | L2 gas per write |
|---|---|
| 0 → 1 | 459 106 (write 57 106 + allocation 402 000) |
| 0 → 0 | 57 106 |
| 0 → 1 → 0 in one call | 113 293 for the two writes, no allocation |
| 1 → 2 | 57 106 |
| 1 → 1 | 57 106 |
| 1 → 2 → 1 in one call | 113 293, no allocation |
| 1 → 0 | −344 894 in the test: 57 106, minus the setup's allocation that the clear undoes |

The audit is right. snforge charges 402 000 once per cell that is zero at the start of the test
and non-zero at its end, from the final diff. Updates, clears, restorations and unchanged writes
cost 57 106. In a transaction of its own, a benchmark's figure is off only when the call
**clears** a cell its setup allocated: it reads 402 000 low. An update of a cell the setup
allocated is measured right.

**Corrections recomputed, and confirmed by measurement** (L2 gas; figures of the current code,
the pre-fix value in parentheses where the audit derived one):

| Call | First version said | Now | The audit derived |
|---|---|---|---|
| `claim` | 1 168 020 | **364 020** (P, R updated, no allocation) | ≈ 0.36 M, confirmed |
| `abandon`, worst | 1 308 460 | **538 870** (504 460 before the acceptance numbers) | ≈ 0.50 M, confirmed |
| Grim World's case | 5 275 716 | **4 527 796** (4 471 716 before); the records cached by `accept` are updates | ≈ 4.47 M, confirmed |
| `accept` pruning a full dead list (a clear of slot 1) | 2 091 300 | **1 724 500** (1 689 300 before) | ≈ 1.69 M, confirmed |
| `define`, `retire` | 5 404 440, 4 219 240 | **2 590 440, 1 003 240** (updates of the prerequisites) | — |

**Accept's worst case, remeasured.**

| Case | Benchmark | Call | Writes / allocations | Reads |
|---|---|---|---|---|
| **Worst**: the list grows into slot 1 (allocated) and R is allocated; K = 7 | `bench_accept_growth` | **1 889 960** | 3 / 2 | 17 |
| The mixed list asked for: weekly, daily, weekly, daily accepted yesterday; today 2 live, 2 stale; K = 7 | `bench_accept_mixed` | 1 648 390 | 3 / 1 | 20 |
| 4 dead entries completed now, pruned (a clear) | `bench_accept_worst_completed` | 1 322 500 measured; **1 724 500** in a transaction | 3 / 1 | 22 |
| 4 entries expired, pruned (a clear) | `bench_accept_worst_expired` | 1 160 740; 1 562 740 | 3 / 1 | 18 |

**The worst calls stay as measured.** Every P and R they write is allocated: each quest's first
count in the interval and its first completion. The hook's slot is new too. So their measures are
the transaction's figures:

| Worst call | Calls (L2 gas) | Allocations |
|---|---|---|
| H = 4, H = 8, hooks empty | 6 187 453, 11 376 913 | 8, 16 |
| H = 4, H = 8, with a one-slot hook | 8 002 373, 15 006 753 | 12, 24 |

With records that already exist, each completion costs 402 000 less.

**The lazy-pruning comparison, redone.**

- A dead entry costs each later progress call 0.05–0.08 M (expired) or 0.10–0.12 M (completed).
- Pruning at progress would be an update of a list slot, about 0.07–0.09 M. It is never an
  allocation (it was 0.46 M under the wrong model).
- So pruning at progress pays when a dead entry would be walked by two or more later progress
  calls before the player's next `accept`.
- I kept lazy pruning:
  - the difference is small and depends on the consumer's pattern (after a completion the
    player typically claims and accepts);
  - the worst call is not affected;
  - pruning at progress would have to write the list after hooks that may have changed it.

  This is a choice, and it is now listed as an open question.

**Documents.** `GAS.md` (the section below the table), `docs/BUDGETS.md`, the README's
integration budget and ARC-01 §3.3 and §5.1 now:

- separate writes, changed slots and allocations per entrypoint;
- carry the probe table;
- mark "(clear)" the only rows whose figure is corrected.

### Point 2 (major): renewed acceptances. Fixed with acceptance numbers

**Regressions first** (`test_component_reentry.cairo`, the hooks of `MockReentrant` gained
`'abandon_accept'` and `'accept_abandon_accept'`):

- `quest_reentrant_abandon_then_accept_not_progressed`: Q1 and Q2 held on T, target 1. Q1's
  completion hook abandons Q2 and accepts it again. Q2 must not be progressed by the call, and
  the next call progresses it.
- `quest_reentrant_accept_abandon_accept_not_progressed`: Q2 is not held at the start. The hook
  accepts it, abandons it, and accepts it again.
- `quest_reentrant_renewed_not_progressed_others_are`: Q1, Q2, Q3 held. The hook renews Q2. Q2 is
  not progressed; Q3, held throughout, completes.

Before the fix, the first and the third failed:

```
[FAIL] …test_component_reentry::quest_reentrant_abandon_then_accept_not_progressed
    "assertion failed: `r.view.quest_is_accepted(PLAYER, 2)`."   (Q2 had completed from the earlier batch)
[FAIL] …test_component_reentry::quest_reentrant_renewed_not_progressed_others_are
Tests: 13 passed, 2 failed
```

**The fix** (`src/logic/types.cairo`, `src/component.cairo`):

- Each entry carries `acceptance: u16`, the player's acceptance number, at [96, 112) and
  [224, 240).
- Slot 0 carries `counter: u16` at [112, 128), the number of the last acceptance. These are free
  bits of the existing layout.
- `accept` stamps the new entry with `counter.wrapping_add(1)` and stores that number as the
  counter.
- The walk compares whole entries after a hook (`still_held`, `held_contains`), so a renewed
  entry is excluded from the running call.
- `quest_is_accepted` and `accept`'s "already accepted" still match by quest and interval.
- A collision would need 2^16 acceptances by one player within one call, which no transaction can
  afford.

The stronger rule of the README holds, and the README now says it for renewals too.

**Cost of the common path.**

- +21 030 Sierra gas per progress call with two held quests: the wider unpack (from the
  references of point 3).
- The worst calls rose by +56 080 L2 gas (H = 4) and +97 490 (H = 8).
- `accept` writes slot 0 for the counter when the new entry lands in slot 1: one more update,
  57 106, never an allocation.
- The counter keeps slot 0 non-zero after a player's first accept, so later accepts into slot 0
  update rather than allocate it.

`quest_acceptance_numbers_are_new_on_renewal` pins the numbers. The layout tests
(`quest_held_list_layout`, `quest_expired_acceptance_pruned`, `quest_abandon_removes_from_list`)
now assert the stamps and the counter, slot by slot.

### Point 3 (major): the writes of progress, asserted

snforge 0.61 exposes no syscall or resource count to a test: `snforge_std` has call traces, the VM
step and cheatcodes only. So the assertion is on gas.

- `tests/test_component_writes.cairo` measures the **Sierra gas** of one `progress_many` call with
  `core::testing::get_available_gas()` around the dispatcher call. That figure is deterministic
  and free of the state-diff charges.
- It asserts that gas within **±20 000** of the call's reference. One write is 58 820, pinned by
  `write_costs_58_820_sierra_gas`.
- The consumer is `MockBench`, whose hooks write nothing.
- The cases are:
  - completing: P and R (`quest_progress_completing_writes_p_and_r`);
  - not completing: P only (`quest_progress_not_completing_writes_p_only`);
  - duplicate entries: P once (`quest_progress_duplicate_entries_write_p_once`);
  - two tasks of one quest: P and R once (`quest_progress_two_tasks_write_p_and_r_once`).

**Failing with an extra write injected** in a scratch build. I added a second
`self.Quest_progress.write(progress_key, progress);` in `progress_held`, ran the tests, then
removed it:

```
[FAIL] …quest_progress_completing_writes_p_and_r        "823256 is not within 20000 of 762226"
[FAIL] …quest_progress_two_tasks_write_p_and_r_once      "795152 is not within 20000 of 734122"
[FAIL] …quest_progress_not_completing_writes_p_only      "674056 is not within 20000 of 613026"
[FAIL] …quest_progress_duplicate_entries_write_p_once    "714239 is not within 20000 of 653209"
```

The references were taken before the fix of point 2 and re-set after it (+21 030 each; now
792 086, 634 056, 674 239, 755 152). A write of R without a completion would add the same 61 030
to the not-completing case and fail it too.

### Point 4 (minor): slot counts corrected

Both cost documents now have three columns, writes, changed slots and allocations:

- `define` writes 2 slots without conditions and **3 + K** with K > 0 (A, B, C and K
  prerequisites).
- `set_reporter` to its current value changes **no** slot (1 write); a new reporter is one
  allocation.
- `claim` at saturated `claims` changes **P only**: R is rewritten unchanged.
- `accept` always writes slot 0 now, for the counter.

### Budgets

197 budgets rose and none were lowered. All come from the acceptance numbers: the wider unpack,
and the counter's write in `accept`. The reasons are in a comment on the pull request.

- 11 library and packing tests. Two of them test more cases: `quest_packing_round_trip_held_slot`
  and `probe_unpack_held_100`.
- 186 component tests, from +0.02 % to a few %.
- 22 tests are new: 9 probes, 3 regressions, 1 acceptance-number test, 2 accept benchmarks with
  their 2 baselines, and the 5 write assertions. The count went from 372 to 394.

### Deviations (fix loop 1)

1. **Point 3 is a gas assertion, not a write count.** No count is exposed; the tolerance is set
   below one write.
2. **The pruning choice stays lazy** although, under the corrected model, pruning at progress
   would be cheaper for a player who makes two or more progress calls between a quest's death
   and their next accept. The figures are in GAS.md, and the question is open below.
3. **The probe table gives the clear's cost in a transaction of its own (57 106) by derivation.**
   snforge cannot start a test with a non-zero cell, so it cannot be measured directly. `store`
   seeding counts as a change of the test (`probe_store_then_change_100`).

### Escalations (fix loop 1)

1. The escalations of the first version stand: ARC-01 §3.4, §3.7, §3.8, §2 and §5 are outside
   the allowlist, and `gas.py --write` still drops GAS.md's hand-written section. I re-appended it
   after the final `--write`.
2. **`QuestHeld` and `QuestHeldSlot` gained fields** (`acceptance`, `counter`). This is an API
   change of the unreleased 0.1.0, recorded in the CHANGELOG, for the audit to confirm.

### Open questions (fix loop 1)

1. **Lazy pruning or pruning at progress?** They break even at about two later calls per dead
   entry, and the difference is at most about 0.1 M per dead entry per call. The choice depends
   on how often Grim World's players make progress calls between completing a quest and
   accepting the next.

## Fix loop 2

This loop answers the project manager's correction of the slot price
(`docs/decisions/2026-09-28-quest-cost-cap.md`, "Correction of 2026-09-29", merged from
`origin/main`). Same branch, same allowlist.

Commits:

- the merge of `origin/main`;
- `b2260a2`: the kept slots, with their tests first, and the benchmarks;
- `217cd43`: the documents.

**CI is green on `217cd43`**: `cairo`, `package (packages/quest)` (with `gas.py --check`),
`affected`, `links` and `scripts`. Locally:

- `snforge test`: 408 passed, 0 failed.
- `scripts/gas.py packages/quest --check`: "408 tests within budget, GAS.md up to date".
- `fmt --check` exits 0; `check-links` finds 0 broken links.

**The figures of the earlier sections are superseded by this one**, by `packages/quest/GAS.md`
and by `docs/BUDGETS.md`.

### The two prices of a slot, and which figures use which

| Written slot | snforge 0.61, measured in fix loop 1 | The network: the game's FND-04, 149 Sepolia transactions |
|---|---|---|
| Created (zero before the transaction, non-zero after) | **459 106** = write 57 106 + allocation 402 000 | about **453 500** |
| Overwritten, zeroed or unchanged | **57 106** | about **32 000** |

- The 402 000 I measured in fix loop 1 is snforge's allocation charge, on top of the write.
- snforge is within 1.3 % of the network for a created slot, and charges 25 000 more for an
  overwritten one.
- **Every figure in the documents is snforge's, measured.** Beside each figure set against the
  20 M cap, the documents give the **network estimate**: the measure with each written slot
  repriced (−5 606 per created slot, −25 106 per overwritten one). Both comparisons with the cap
  are stated.

### (a) The worst call, slots created and existing

The worst call is `progress_many` with `[1..=15, 129]`, every held quest completing, 3 tasks
each, a daily schedule.

- **Created**: each quest's P and R are new.
- **Existing**: P was seeded at 1 of 2 on each task in this interval and R with one completion,
  and the call overwrites them (`bench_progress_many_worst_held{4,8}_existing[_hook]`).
- The hook's slot is new in both cases.

| Case | snforge | Network estimate | Created / overwritten | vs 20 M (snforge / network) |
|---|---|---|---|---|
| H = 4, created, hooks empty | **6 182 583** | 6 137 735 | 8 / 0 | 31 % / 31 % |
| H = 4, existing, hooks empty | 2 966 583 | 2 765 735 | 0 / 8 | 15 % / 14 % |
| H = 4, created, one-slot hook | **7 997 503** | 7 930 231 | 12 / 0 | 40 % / 40 % |
| H = 4, existing, one-slot hook | 4 781 503 | 4 558 231 | 4 / 8 | 24 % / 23 % |
| H = 8, created, hooks empty | **11 374 333** | 11 284 637 | 16 / 0 | 57 % / 56 % |
| H = 8, existing, hooks empty | 4 942 333 | 4 540 637 | 0 / 16 | 25 % / 23 % |
| H = 8, created, one-slot hook | **15 004 173** | 14 869 629 | 24 / 0 | 75 % / 74 % |
| H = 8, existing, one-slot hook | 8 572 173 | 8 125 629 | 8 / 16 | 43 % / 41 % |
| Grim World's case | 4 522 926 | 4 439 078 | 6 / 2 | 23 % / 22 % |

**The figures stated against the cap are the created ones**, the worst the package allows: 6.18 M
at `MAX_HELD` = 4, and 15.00 M at the layout's limit of 8 with a one-slot hook. `MAX_HELD` stays
4. A completing quest whose slots already exist costs about 0.80 M less.

### (b) Slots created and overwritten, per entrypoint

Both cost documents now have, for each entrypoint and its best, common and worst cases, the
slots it creates and the slots it overwrites or zeroes (a table in `GAS.md` and in `BUDGETS.md`).
Every benchmark row gives its created and overwritten counts and its network estimate. In short:

- `progress_many` creates P on a quest's first count in an interval and R on its first
  completion (2H at worst), and overwrites them otherwise. It never writes the list.
- `accept` overwrites slot 0 always. It creates slot 0 only at a player's first accept, a list
  slot only the first time the list grows into it, and R at a first unlock: at most 2 created,
  1 overwritten.
- `abandon` only overwrites (1 or 2).
- `claim` overwrites 2, or P alone at saturated claims.
- `define` creates 2 or 3 and overwrites K.
- `retire` overwrites 1 + K.
- `set_reporter` creates 1 for a new reporter.
- **No entrypoint zeroes a slot any more** (below).

### (c) Keeping a player's slots instead of zeroing them: adopted

**Where slots were zeroed.** Only in the held list. Slot 1 (slots 1 to 3 at H = 8) was zeroed
when the list shrank out of it: `abandon`, or an `accept` that pruned expired, completed or
retired entries. It was created again the next time the list grew into it. Slot 0 already stayed
non-zero thanks to the acceptance counter (fix loop 1). P and R are never zeroed.

**The design.**

- A `kept` bit [240] in every slot, set once the slot has held an entry and never cleared. A slot
  the list stops using is overwritten with the bit alone, never zeroed.
- The list reads as before: a slot whose `e0` is empty ends it.
- `accept` and `abandon` read the bits (`held_read`) and write them back (`held_write`).
- Progress, the views and the still-held check read the entries alone (`held_entries`).

**Tests first.** `quest_held_slot_kept_after_shrink` and `quest_held_slot_kept_after_pruning`
check the raw felts of the list with `load`. They failed on the zeroing design:

```
[FAIL] …test_component_accept::quest_held_slot_kept_after_shrink
[FAIL] …test_component_accept::quest_held_slot_kept_after_pruning
Tests: 0 passed, 2 failed
```

Both pass now. `quest_expired_acceptance_pruned` now expects slot 1 kept rather than zero.

**Measured against the zeroing design** (the code of `94b6d5d`), L2 gas:

| Event | Benchmark | Zeroing | Kept | Network, zeroing → kept |
|---|---|---|---|---|
| The list grows back into slot 1 | `bench_accept_regrow` | 1 084 240 | **690 420** | ≈ 1 053 500 → ≈ 640 200 |
| The list shrinks out of slot 1 (`abandon`) | `bench_abandon_shrink` | 435 600 in a transaction (33 600 in the test: a zeroing) | 443 860 | ≈ 410 500 → ≈ 418 800 |
| The worst `accept`: growth into a slot never used | `bench_accept_growth` | 1 889 960 | 1 899 210 | ≈ 1 853 600 → ≈ 1 862 900 |
| **The worst progress call**, H = 4 / H = 8, created | `bench_progress_many_worst_held{4,8}` | 6 187 453 / 11 376 913 | **6 182 583 / 11 374 333** | — |

**Why it is adopted.**

- **Over a player's life, it is cheaper.** Each time the held list grows back into a slot it
  used before, the kept design saves 393 820 (about 421 500 at the network's prices). That
  happens whenever the player's held count rises above 2 again.
- **What it costs.** About 8 000 to 9 000 per `accept` or `abandon` that writes the list. One
  regrowth pays for about 45 such operations.
- **The worst call is not worse.** The walk reads entries without the bits, so the worst
  progress calls went down by 2 600 to 4 900.
- **One cost rose.** The worst `accept` rose by 9 250 (0.5 %): it grows into a slot never used,
  which both designs must create.
- **Side effect.** No benchmark needs the "clear" correction of fix loop 1 any more.

**Not adopted: reusing the progress slot P across intervals.** P is keyed by (player, quest,
interval), so a recurring quest creates a new P in each interval where it counts: about 453 500
per quest per interval on the network. One P per (player, quest), overwritten at each interval,
would save about 421 500 each time. But it would overwrite a completed interval that
`claim(player, quest, interval)` may still claim, and the API of A-G1 allows claiming any
completed interval. That is a change of the API's rules, not of layout, so I did not make it.
It is an open question.

### Budgets (fix loop 2)

Against `9998fb1`, 156 budgets went up and 48 went down. The reasons are in a comment on the pull
request:

- **Raised**: the `kept` bit, packed and carried by every list write: +8 000 to +9 000 L2 gas per
  `accept` or `abandon` in a setup, and 6 packing and held-list library tests.
- **Lowered**: the regrowths that now overwrite instead of create, and the worst progress calls.

14 tests are new, from 394 to 408:

- 8 worst-call benchmarks and baselines with existing slots;
- 4 regrowth and shrink benchmarks and baselines;
- 2 tests of the kept slots.

### Deviations (fix loop 2)

1. **The network estimates are computed, not measured.** Each measure is repriced slot by slot
   with the FND-04 figures, which the decision gives as approximate ("about"). snforge is the
   only instrument available here.
2. **In the "existing" variants, P and R are seeded with `store`.** The call then overwrites
   them, which prices them as a real transaction where they already existed would. The hook's
   slot is left new, its worst.
3. **The "zeroing" column of (c) comes from the benchmarks run on the code of `94b6d5d`.** For the
   shrink, which zeroes a slot its setup created, it gives the transaction's figure (+402 000), as
   in fix loop 1.

### Escalations (fix loop 2)

1. The escalations of the first version and fix loop 1 stand: ARC-01 §3.4, §3.7, §3.8, §2 and
   §5 are outside the allowlist, and `gas.py --write` drops GAS.md's hand-written section, which
   I re-appended.
2. **`QuestHeldSlot` gained a field, `kept`.** This is an API change of the unreleased 0.1.0,
   recorded in the CHANGELOG.

### Open questions (fix loop 2)

1. **Reuse of P across intervals.** It would save about 421 500 per recurring quest per
   interval, at the price of changing when a completed interval can be claimed (only until the
   next interval of that quest progresses). That is a decision on the API.
2. From fix loop 1: lazy pruning or pruning at progress. Both still stand at the corrected
   prices: 0.05–0.12 M per dead entry per later call, against about 0.07–0.09 M once.

## Fix loop 3

This loop answers three points of the `[GPT-6-Astra]` re-audit, as verified and decided by the
orchestrator. Same branch, same allowlist. Commits: `5a72315` (the fix, the regression written
first, the fixtures, the benchmarks) and `10f46d9` (the documents). **CI is green on `10f46d9`**:
`cairo`, `package (packages/quest)` (with `gas.py --check`), `affected`, `links`, `scripts`.
Locally:

- `snforge test`: 417 passed, 0 failed.
- `scripts/gas.py packages/quest --check`: "417 tests within budget, GAS.md up to date".
- `fmt --check` exits 0; `check-links` finds 0 broken links.

**The figures of the earlier sections are superseded** by this section, `packages/quest/GAS.md`
and `docs/BUDGETS.md`.

### Point 2 (major): the acceptance number wraps. Fixed with the counter read when the call starts

**The earlier argument was wrong.** Fix loop 1 said a collision "would need 65 536 acceptances by
one player inside one progress call". That was wrong. The counter wraps over the player's whole
lifetime, across transactions, so the numbers of outstanding entries come back.

In the audit's prehistory, Q1 (number 1) and Q2 (number 2) are held. Q3 was accepted and
abandoned 65 535 times in earlier transactions, so the counter is back at 1. Q1's completion hook
abandons Q2 and accepts it again: Q2 gets number 2, a tuple identical to the entry the call
started with, and it completes from the earlier batch.

**Regression first.** `quest_reentrant_renewal_after_counter_wrap_not_progressed`
(`tests/test_component_reentry.cairo`) builds that prehistory. Q1 and Q2 are accepted, then slot
0 is overwritten with `store` as `(Q1, 1), (Q2, 2)` with the counter at 1. Before the fix:

```
[FAIL] …test_component_reentry::quest_reentrant_renewal_after_counter_wrap_not_progressed
    "assertion failed: `r.view.quest_progress(PLAYER, 2, 0) == no_progress()`."
Tests: 1 passed, 1 failed
```

After the fix, it passes. `quest_counter_wrap_without_renewal_progresses_both` shows that the
wrapped counter alone changes nothing.

**The fix: the scheme the orchestrator proposed, without widening the number.**

- `progress_many` reads the counter when it starts (`held_entries_from`, from slot 0, which it
  reads anyway).
- After a hook, `still_held` reads slot 0 again. If numbers were issued during the call, an
  entry with `(number − start) mod 2^16` in `[1, (counter − start) mod 2^16]` is treated as
  renewed and excluded, before the entry is looked for in the list.
- A collision now needs 65 536 acceptances **within one call**, which no transaction affords:
  each `accept` costs at least 0.7 M L2 gas.

**Why this scheme.**

- **Numbers that are never reused, across outstanding entries.** `accept` could skip the numbers
  of the entries it currently holds. That does not cover the audit's case: the hook abandons Q2
  before re-accepting it, so Q2's number is no longer outstanding when it is reissued.
- **A wider number.** No bit is free in slot 0 for a wider counter; the entries' layout would
  have to change.

**Residual.** An outstanding entry whose number, issued 65 536 acceptances earlier, falls among
the numbers a hook issues during the same call is also excluded from that call. It is never
progressed from a batch that was not its own; it is only delayed to the next call. This is in
GAS.md.

**Cost.** One more read of slot 0 per entry processed after a hook in slots 1 to 3. The common
path (no hook, or no later entry) is unchanged.

| Worst call | Before | After |
|---|---|---|
| H = 4 | 6 182 583 | **6 292 283** (+109 700) |
| H = 8 | 11 374 333 | **11 676 993** (+302 660) |
| H = 4, with a one-slot hook | 7 997 503 | **8 107 203** |
| H = 8, with a one-slot hook | 15 004 173 | **15 306 833** (77 % of 20 M; network estimate 15 172 289, 76 %) |
| Grim World's case | 4 522 926 | 4 632 626 |

### Point 3 (major, decided): the gas guards kept and qualified; exact writes recorded

- **The claim is qualified** (`tests/test_component_writes.cairo` header, and GAS.md). The guards
  bound the cost of the writes, not their count. An extra write with nothing else changed fails
  them, as the injected write of fix loop 1 showed. An extra write compensated by an equal saving
  elsewhere would pass.
- **Two missing fixtures added:**
  - `quest_progress_two_tasks_not_completing_write_p_once`: two tasks of one quest, not
    completing;
  - `quest_progress_duplicates_several_counts_write_each_p_once`: entries
    `[(7, 1), (8, 1), (7, 2), (8, 1)]`, several positive counts on two quests' tasks.

  Two setup baselines were added for the counts. All six references were re-set after the fix of
  point 2.
- **The exact writes, counted with** `snforge test test_component_writes --detailed-resources`
  (`StorageWrite` of the test, minus the 7 of its setup baseline; `MockBench`, hooks empty). They
  are recorded in GAS.md beside the guards:

| Test | Guard reference | `StorageWrite` | Of the call |
|---|---|---|---|
| `quest_progress_completing_writes_p_and_r` | 799 006 | 9 | 2 (P, R) |
| `quest_progress_not_completing_writes_p_only` | 635 696 | 8 | 1 (P) |
| `quest_progress_duplicate_entries_write_p_once` | 675 879 | 8 | 1 (P) |
| `quest_progress_two_tasks_write_p_and_r_once` | 756 792 | 9 | 2 (P, R) |
| `quest_progress_two_tasks_not_completing_write_p_once` | 649 902 | 8 | 1 (P) |
| `quest_progress_duplicates_several_counts_write_each_p_once` | 768 045 | 9 | 2 (each quest's P) |

### Point 4 (minor): saturated claim, reporter revocation, "never zeroed"

- **Saturated claim.** It is now stated as 2 writes, 1 changed slot, 1 overwritten (P); R is
  rewritten unchanged. This is in the tables of GAS.md, BUDGETS.md and ARC-01 §5.1.
- **Reporter revocation.** `set_reporter(registered, false)` zeroes the reporter's slot. It is in
  the created/overwritten tables, with two benchmarks:

  | Benchmark | Measured | In a transaction of its own |
  |---|---|---|
  | `bench_set_reporter_revoke` | −194 470 (the zeroing undoes the setup's creation) | 207 530; network ≈ 182 400 |
  | `bench_set_reporter_unchanged` | 207 330 | — |

- **"No entrypoint zeroes a slot"** is now "the held list is never zeroed", with revocation named
  as the one zeroing. This is in GAS.md, BUDGETS.md, the README and ARC-01 §3.3 and §5.1.

### Budgets (fix loop 3)

149 budgets went up and none down against `217cd43`, all from the read of slot 0 after a hook;
no library budget moved. The reason is in a comment on the pull request. 9 tests are new, from
408 to 417:

- 2 of the wrapped counter;
- 2 guard fixtures and 2 setup baselines;
- 3 `set_reporter` benchmarks and their baseline.

### Deviations (fix loop 3)

1. **The write counts are recorded by hand.** snforge exposes no syscall count to a test, so the
   counts in GAS.md come from a run of `--detailed-resources`. A later change of the writes would
   not fail on them; it would fail on the gas guards, as qualified.
2. **The residual of point 2 is conservative, not zero.** A rare false exclusion delays an entry
   to the next call; it never progresses one wrongly.

### Escalations (fix loop 3)

The escalations of the first version and fix loops 1 and 2 stand, and none is new:

- ARC-01 §3.4, §3.7, §3.8, §2 and §5 are outside the allowlist;
- `gas.py --write` drops GAS.md's hand-written section, which I re-appended;
- the API fields added to `QuestHeld` and `QuestHeldSlot` are for the audit to confirm.

## Fix loop 4 (exception)

**The exception.** This is a fourth fix loop on ARC-03c, beyond the rule of three fix loops per
lot. The project manager `[Fable 5.1]` decided it on 2026-09-29
(`docs/decisions/2026-09-29-ARC-03c-last-loop.md`, option (a), merged from `origin/main` before
the work).

**Its reason**, as the decision gives it:

- Finding 6 of the third `[GPT-6-Astra]` pass is a defect of the storage layout. A 16-bit
  acceptance number wraps over a player's lifetime. After a wrap, a hook that accepts another
  quest made an unchanged held quest lose a batch's counts.
- The package will be published, its layout frozen at 0.1.0, and a publication cannot be undone.
  Widening the number after the release would be a migration for every consumer.

The loop is limited to the acceptance number and the minor points left by the third pass; nothing
else was changed. If the narrow audit pass that follows leaves a major, no other loop opens and
#10 is not merged.

**Commits:**

- the merge of `origin/main`;
- `21f3066`: the layout, the fix and the tests, the regression first;
- `6fc8832`: the documents.

**CI is green on `6fc8832`**: `cairo`, `package (packages/quest)` (with `gas.py --check`),
`affected`, `links` and `scripts`. Locally:

- `snforge test`: 423 passed, 0 failed.
- `scripts/gas.py packages/quest --check`: "423 tests within budget, GAS.md up to date".
- `fmt --check` exits 0; `check-links` finds 0 broken links.

**The figures of the earlier sections are superseded** by this section, `packages/quest/GAS.md`
and `docs/BUDGETS.md`.

### The layout: it fits

A slot holds two entries of `quest_id` (32 bits) + `interval_id` + `acceptance`, plus the
counter (slot 0) and the kept bit. With the interval id at 48 bits and a number of A bits, it
takes 2 × (80 + A) + A + 1 ≤ 251 bits, so **A ≤ 30**. I took A = 30 for the number and the
counter: wider than the 29 the decision named, at no cost, and the widest that fits. A wrap then
needs 2^30 ≈ 1.07 × 10⁹ acceptances by one player, at least 7.5 × 10¹⁴ L2 gas of their own.

| Bits | Field |
|---|---|
| [0, 32) | `e0.quest_id` |
| [32, 80) | `e0.interval_id` (48 bits) |
| [80, 110) | `e0.acceptance` (30 bits) |
| [110, 140) | `counter` (30 bits, slot 0 only): 18 bits in the low limb, 12 in the high, the one field that straddles bit 128 |
| [140, 172) | `e1.quest_id` |
| [172, 220) | `e1.interval_id` |
| [220, 250) | `e1.acceptance` |
| [250] | `kept` |
| [251] | reserved: rejected at unpack (`'Packing: reserved bits set'`) |

Every value is below 2^251. Packing refuses an interval id ≥ 2^48, and a number or counter
≥ 2^30, with `'Packing: field out of range'`.

The layout keeps the slots the measurements are based on: two entries per slot, the counter and
the kept bit in slot 0 and every slot, 4 slots. Types: `QuestHeld::acceptance` and
`QuestHeldSlot::counter` are `u32`; new constants `HELD_INTERVAL_LIMIT = 2^48` and
`ACCEPTANCE_LIMIT = 2^30`.

### The rule: whole entries, no window

The window check of fix loop 3 and its read of slot 0 after each hook are removed. After a hook,
the running call processes an entry only if the list still holds the **whole entry**: quest,
interval and number (`still_held`, as in fix loops 1 and 2). A renewed acceptance has a new
number, and so does an acceptance of another quest. Neither can be confused with an unchanged
entry until the counter wraps at 2^30.

### The boundaries

- **The counter**, `quest_acceptance_counter_wraps_at_2_30` (seeded). After 2^30 − 1 the next
  number is 0, then 1. Progress is unaffected: three held quests and a fourth accepted by a hook
  across the wrap all behave as usual.

  From then on, an acceptance can get the number of an entry accepted 2^30 acceptances earlier.
  If that entry is still held and a hook renews that same quest within a progress call, the
  renewal is not told apart. That is the only way left, after about 10⁹ acceptances by one player.
- **The interval id**, `quest_held_interval_id_boundary_2_48`. With one-second intervals from the
  epoch, the interval id is the time:
  - at 2^48 − 1, `accept` holds the quest with that interval id, and progress counts;
  - at 2^48, `accept` refuses `'Quest: not active'`, and the entry of 2^48 − 1 has expired as at
    any rollover.

  2^48 one-second intervals are about 8.9 million years. I used the existing refusal rather than
  adding an error string, since the decision limits this loop to the number.

### Tests

**The regression at the old width, written first.**
`quest_hook_accepting_another_quest_keeps_counts_after_16_bit_wrap` builds the third pass's
prehistory:

- Q1 (number 1) and Q2 (number 2, target 10) are held, and the counter is seeded as a 16-bit
  counter after 65 535 more acceptances: 1.
- Q1's hook accepts another quest, Q3, which gets number 2.
- The call reports 3.

On the code of fix loop 3:

```
[FAIL] …test_component_reentry::quest_hook_accepting_another_quest_keeps_counts_after_16_bit_wrap
    "assertion failed: `r.view.quest_progress(PLAYER, 2, 0).c0 == 3`."
```

After the fix, the same history seeds the counter the 30-bit layout gives it, 65 537. Q3 gets
65 538, which is 2 modulo 2^16, the collision of the old width, and the test asserts both facts.
Q2 keeps the 3, then reaches 4 at the next call.

**The renewal regressions of fix loops 1 and 3 pass.** The fix-loop-3 prehistory is re-seeded
with the counter at 65 537: a renewal of Q2 inside the hook gets 65 538 and is excluded.

**Packing.**

- The round trips cover every field alone and at its maximum, with the counter's low 18 and high
  12 bits alone.
- Every field at its maximum packs to exactly 2^251 − 1.
- Bit 250 is read as `kept`, and bit 251 is rejected.
- Three refusals of field range: interval 2^48, number 2^30, counter 2^30.

The write guards were re-set to the new exact values (802 776, 639 896, 680 079, 760 992,
654 102, 772 245). Their `StorageWrite` counts are unchanged, 2, 1, 1, 2, 1, 2.

### Remeasured

| Case (L2 gas, snforge; network estimate) | Fix loop 3 | **Fix loop 4** | vs 20 M |
|---|---|---|---|
| Worst, H = 4, created, hooks empty | 6 292 283 | **6 213 063** (6 168 215) | 31 % |
| Worst, H = 4, existing | 3 076 283 | 2 997 063 (2 796 215) | 15 % |
| Worst, H = 4, created, one-slot hook | 8 107 203 | **8 027 983** (7 960 711) | 40 % |
| Worst, H = 4, existing, one-slot hook | 4 891 203 | 4 811 983 (4 588 711) | 24 % |
| Worst, H = 8, created | 11 676 993 | **11 430 213** (11 340 517) | 57 % |
| Worst, H = 8, existing | 5 244 993 | 4 998 213 (4 596 517) | 25 % |
| Worst, H = 8, created, one-slot hook | 15 306 833 | **15 060 053** (14 925 509) | 75 % |
| Worst, H = 8, existing, one-slot hook | 8 874 833 | 8 628 053 (8 181 509) | 43 % |
| Grim World's case | 4 632 626 | 4 553 406 (4 469 558) | 23 % |
| `accept`, worst (grows into a never-used slot, K = 7) | 1 899 210 | 1 921 540 (1 885 222) | 10 % |
| `abandon`, worst (first of 4) | 547 920 | 574 060 (523 848) | 3 % |

All are under 20 M. Reads are back to 23 at H = 4 and 44 at H = 8. The worst progress calls are
below fix loop 3's, since the window's read is gone. `accept` and `abandon` rose by about 22 000
to 26 000 from the wider unpack (22 301 per slot against 17 221).

### The minor points of the third pass

- **Saturated `claim`** is now "2 writes, 2 overwritten, 1 changed slot: only P changes" in
  GAS.md, BUDGETS.md and ARC-01 §5.1.
- **ARC-01 §5.1's per-quest summary** now says "after a hook, + the entry's slot (and the whole
  list if the entry moved)", with the bounds ≤ 1 304 000 / 717 000 / 264 000 / 126 000 / 82 000
  per quest, and `1.00 M + 1.31 M × MAX_HELD` for the worst call.

### Budgets (fix loop 4)

195 budgets rose and 27 fell against `10f46d9`; the reasons are in a comment on the pull
request.

- **The rise**: the wider unpack, in every test that reads the held list.
- **The fall**: the calls that ran hooks, which no longer read slot 0 again.
- **Tests**: 6 are new, from 417 to 423: the regression, the counter's wrap, the interval's
  boundary, and 3 range refusals.

### Deviations (fix loop 4)

1. **The number is 30 bits, not 29.** The layout fits 30 exactly, and it doubles the margin to a
   wrap.
2. **The interval-id boundary reuses `'Quest: not active'`** rather than a new error string, to
   keep the API's errors unchanged in a loop limited to the number.
3. **The fix-loop-3 regressions were re-seeded**, their prehistory unchanged: the counter they
   seed is the value the same history gives at 30 bits (65 537). A counter of 1 with outstanding
   numbers 1 and 2 is now reachable only after 2^30 acceptances.

### Escalations (fix loop 4)

None new. The standing ones remain:

- ARC-01 §3.4, §3.7, §3.8, §2 and §5 are outside the allowlist;
- `gas.py --write` drops GAS.md's hand-written section, which I re-appended;
- the API changes of the unreleased 0.1.0 (the widened `QuestHeld::acceptance` and
  `QuestHeldSlot::counter`, the new constants) are for the narrow audit pass to confirm.
