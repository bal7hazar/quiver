# [Opus 5.5] ARC-01 — Analysis of quest and achievement, and the API of their native rewrites (fix loop 3)

## Summary

**Fix loop 2** (after the `[GPT-6-Sol]` re-audit, FAIL on points A to E):

- `progress_many` has **no second-call fallback**. The consumer aggregates by task id and
  calls once per player per transaction. `MAX_ENTRIES` is sized at 16 from the design
  documents, with a question for the game (Q-19).
- Retirement has a full lifecycle: a retired quest is never "accepted", `abandon` is not
  needed, and a prerequisite with live dependents **cannot be retired** (new Q-20).
- `batch_first_position` uses B only, relying on the zero sentinel of unused task slots.
- The worst-case witnesses in §5 are now reachable, and recomputed for 16 entries.
- The record's counters are `u64` with saturating increments.
- There are now 20 open questions.

Everything below the fix-loop-2 section is kept from fix loop 1.

**Fix loop 1** (after the first audit, FAIL). The report gained these changes:

- **Acceptance is tied to an interval.** A new field, `QuestRecord.accepted_interval: u64`,
  records the interval of the acceptance. An acceptance expires at rollover, and a completed
  interval cannot be accepted again.
- **`progress_many` is bounded and aggregated.** At most 8 entries. The algorithm merges
  duplicates and writes each progress and record slot at most once per call.
- **`retire` frees association slots**, so the cap is 28 live quests per task. The choice is
  now a gate question, Q-14, with options for both packages.
- **D-6 and D-7 are qualified** by prerequisite recurrence and definition order.
- **Interval ids are `u64`**, so they cannot overflow.
- **Presence bits and the uncached `quest_is_unlocked` are specified.**
- **The achievement events are complete Cairo structs.**
- **The page-count formula in §5 is corrected**, and event-mode batches are counted.
- **Two open questions are new**: Q-18 (how long an acceptance holds) and Q-19 (the batch
  bound). There are now 19.

Model: this session ran as **Opus 5.5** (`claude-opus-5-5`), as the brief names. No commit:
the `research` profile cannot commit; the orchestrator commits to pull request #2.

## Files changed

- `docs/research/ARC-01-quest-achievement.md`: revised in fix loop 2; now 1716 lines.
- `REPORT.md`: updated, not committed.

## Commands run

Reading only; nothing was built or run.

Fix loop 2:

- `Grep` over the report for `second call`, `MAX_ENTRIES`, `completions`, `claim_index`,
  `batch_first_position`, `is_accepted`, `abandon`, `retire`, the worst-case figures and
  Q-14 and Q-19, to find every place to change.
- `Read` of the affected ranges.
- A final `Grep` confirms that no `u32` counter, `u32` claim index, `MAX_ENTRIES = 8` or
  "≈ 2 720" remains. The three remaining "second call" matches all say there is none
  (lines 572, 1442, 1715).
- `grep -n` for the line numbers below. `wc -l` gives 1716.

Fix loop 1:

- `Read` of the whole report (lines 1-1360 before the fix).
- `Grep` for leftover `u32` interval ids and stale error names. The only remaining matches
  are the legitimate `'Quest: not active'` for the schedule and `Option<u32>` batch
  positions.
- `grep -n` over headings and key lines, to cite the line numbers below. `wc -l` gives
  1640 lines.
- From the first run, unchanged: the reading of `ref/arcade/` and `ref/grimworld/`, and the
  registry lookups.
- The citation added to D-7, `quest/src/component.cairo:225`, is the `is_unlocked` check
  that skips a locked quest. I read it in the first run's full reading of `component.cairo`.
- I did not run the link checker, as in the first run. The fix adds no relative link.

## Cost

| Entrypoint or algorithm | Before | After | Budget | Note |
|---|---|---|---|---|
| — | — | — | — | No Cairo was built. §5 gives estimates from the layouts |

## Fix loop 3

The third `[GPT-6-Sol]` audit returned PASS WITH FINDINGS. Two edits were made and nothing
else: `git diff --stat` shows 3 lines changed in the report, and it still has 1716 lines.

- **13 (major): A-5 depends on Q-19.** **Fixed.**
  - §4 row A-5 (line 1442): the status is now **"Covered, subject to Q-19"**, and a sentence
    is added: an expedition that reports more than `MAX_ENTRIES` distinct tasks reverts,
    unless the game enforces a ceiling at or below the bound.
  - Q-19 (line 1715): the question to the game is explicit. The game must either confirm a
    ceiling of 16 distinct reported task ids per expedition, enforced by the game, or name
    its maximum, so that the bound is chosen to cover it.
- **14 (minor): the retirement cost in Q-14.** **Fixed.** Q-14 (line 1710) now gives
  ≤ 22 reads and ≤ 14 writes for a quest, matching §5.1, and ≤ 14 reads and ≤ 7 writes for an
  achievement, matching §5.2. Q-14 covers both packages, so both figures are stated.

## Fix loop 2

Line numbers are those of the file after fix loop 2 (1716 lines).

- **A. Second-call fallback** (blocker). **Fixed.** Every fallback is removed, and the
  contract is stated.
  - §3.1 (line 572), the principle "one write per record per transaction": the consumer
    aggregates its results by task id and calls `progress_many` once per player per
    transaction, the one dispatcher call of the results interface (ADR-0007). `MAX_ENTRIES`
    bounds the entries of that call, which are its distinct tasks. A longer list is a
    consumer error that reverts, with no second call. Duplicates still count towards the
    bound, which is checked before merging.
  - §4 A-5 (line 1442) is rewritten the same way. §3.8 `submit_results` (lines 1168-1169)
    states that the results arrive aggregated, in one call.
  - The value is 16 (lines 586, 1220), sized in Q-19 (line 1715) from design/06 and design/14.
    For one Region 1 expedition: kills by caste (about 7), places reached (1 to 3), a boss (1),
    items (up to about 5), activate, lure or talk (1 to 3). That is about 12 to 19 quest tasks.
    Q-19 gives options 8, 16 and 32 with their worst cases and recommends 16. It says that
    **the design documents do not bound this for later regions**, and asks the game to
    confirm a ceiling.
  - §5 is recomputed for 16 (line 1497): quest `progress_many` 5 440 reads, 896 writes,
    448 events and hooks; achievement (line 1529) 1 408 reads and 448 writes. The totals are
    given as linear in the bound (`340 × E`, `88 × E`).
  - Tests: `quest_batch_duplicates_count_toward_bound`; `quest_batch_bound_accepted` now uses
    the reachable witness.
- **B. Retirement lifecycle** (major). **Fixed.**
  - (1) `is_accepted` and `quest_is_accepted` read A first and return false for a retired
    quest (line 945), so the consumer's pruning frees the slot. `abandon` on a retired
    quest reverts `'Quest: retired'`. It is not needed: the leftover `active` bit is inert,
    because every reader of acceptance checks `retired` first, and clearing it would be a
    write that changes no outcome. That is stated in "Lifecycle after retirement"
    (line 1019).
  - (2) A `live_dependents: u16` field in A (type at line 607; layout [200, 216), 216 bits,
    line 775) counts the live quests that name this one. `define` increments it and refuses
    a retired condition. `retire` reverts `'Quest: has live dependents'` while it is above
    zero (line 1009), and decrements the counters of its own conditions.
  - The cost is in §5.1: retire ≤ 22 reads and ≤ 14 writes; define adds K writes; nothing is
    added to progress, accept or claim.
  - The choice is put to the owner in the new **Q-20** (line 1716): refuse (recommended),
    cascade (unbounded), or leave it to the admin. Q-14 now refers to it.
  - New errors: `'Quest: has live dependents'` and `'Quest: too many dependents'`.
  - Tests: `quest_retired_is_not_accepted`, `quest_retire_prerequisite_with_live_dependent_reverts`,
    `quest_retire_dependent_then_prerequisite`, `quest_define_rejects_retired_condition`,
    `quest_define_counts_dependents`.
- **C. `batch_first_position` read before A** (major). **Fixed with a B-only function.**
  - The new signature is `batch_first_position(batch, tasks: @QuestTasks)` (line 684). It
    scans the three slots and ignores task id 0, the unused-slot sentinel. Step 2.2.1
    (line 962) explains the choice: it keeps the skip before A's read, so a quest reached
    again costs one read (B), not two. The §5 costs are unchanged.
  - To make the sentinel safe, `batch_merge` now rejects task id 0 (`'Quest: invalid task'`,
    `'Achievement: invalid task'`).
  - Tests: `quest_batch_first_position_uses_zero_sentinel`, `quest_batch_rejects_task_zero`
    (line 529).
  - The achievement algorithm already read A, which holds `t0` and `task_count`, before the
    check; it is unchanged.
- **D. Unreachable worst-case witnesses** (minor). **Fixed.**
  - The quest witnesses (the `progress` worst-case row and line 1497) are now quests
    **without** an accept step whose 7 prerequisites were met earlier and are first observed
    in this call.
  - A paragraph (line 1505) explains why an accepted quest costs 4 reads, not 11, since
    `accept` caches `unlocked`.
  - The bounds are confirmed: per quest the counts are unchanged, 12 reads with B. Totals
    are recomputed for 16 entries (point A).
- **E. `u32` counters** (minor). **Fixed by `u64` counters with saturating increment.**
  - `QuestRecord.completions` and `claims` are `u64` (line 630). The reason is in a
    paragraph at line 718. The layout is [0, 64) and [64, 128), 194 bits (line 780).
  - The hooks' `completions` and `claim_index`, `claim`'s return value (internal and ABI),
    and the consumer sketch are `u64`.
  - Tests: `quest_record_counters_past_u32` and `quest_record_counters_saturate` (line 545).
- **Summary and §7.** The summary (lines 22-40) states 16 entries, the retirement guard and
  20 questions. Q-14 is updated, Q-19 is rewritten and Q-20 is added.

Nothing else was changed.

## Fix loop 1

Line numbers are those of the file after fix loop 1 (1640 lines); fix loop 2 shifted them.

1. **Acceptance has no interval identity** (blocker). **Fixed.** Acceptance expires at
   rollover (Q-18), with a recommendation and a question to the game's designer, since
   design/14 is silent on it.
   - §3.2: `QuestRecord.accepted_interval: u64` and the rule "accepted = active and same
     interval" (lines 614-626). `record_is_accepted`, `record_accept(record, interval_id)`
     and `record_abandon(record, interval_id)`. A semantics row "Acceptance".
   - §3.3: the record's layout, `accepted_interval` [66, 130), 130 bits.
   - §3.5, the algorithms:
     - progress skips a quest unless `record_is_accepted(R, iid)`;
     - **`accept` step by step** (line 954): reverts `'Quest: already accepted'` in the
       same interval and `'Quest: already completed'` when the current interval's progress
       is completed; it replaces an expired acceptance;
     - `abandon` reverts `'Quest: not accepted'`;
     - new view `is_accepted` / `quest_is_accepted`;
     - the error list is updated.
   - §3.8: the consumer sketch counts its 3 active quests by pruning with
     `quest_is_accepted`, because expiry has no transaction and so no hook.
   - §4: the rows for 3 active quests and the daily draw.
   - §5.1: accept costs 3 to 11 reads; abandon 2.
   - §2 "Also tested" (lines 516-520): `quest_acceptance_expires_at_rollover` (accept on
     day 0, progress on day 1 not counted), `quest_accept_after_completion_reverts`,
     `quest_accept_after_daily_completion`, `quest_accept_twice_same_interval_reverts`,
     `quest_abandon_expired_reverts`.
2. **`progress_many` unbounded, records written more than once** (blocker). **Fixed.**
   - §3.1: `MAX_ENTRIES = 8`, and a principle "one write per record per call", with the
     README note that the consumer calls it once per player per transaction.
   - §3.2: `batch_merge` (reverts `'Quest: too many entries'`, drops zeros, merges duplicates
     with saturation), `batch_count_of`, `batch_first_position`, and a `progress_add` that
     applies the whole batch.
   - §3.5 (line 916): the algorithm. A quest is processed only at the first batch entry of
     any of its tasks, before its A is read, so its P and R are read and written at most
     once. Event mode emits one event per merged, non-zero entry. `progress` is the
     one-entry case.
   - §3.10 and §3.11: the same for `quiver_achievement`, with
     `'Achievement: too many entries'`.
   - §5.1 and §5.2: event-mode rows for `progress_many` and a two-task batch row. Worst cases
     at lines 1432 and 1454: quest 2 720 reads, 448 writes, 224 events; achievement 704
     reads, 224 writes.
   - Tests (lines 521-525 and the achievement rows): `quest_batch_two_tasks_one_quest_one_write`,
     `quest_batch_duplicate_entries_merged`, `quest_batch_event_mode_one_event_per_task`,
     `quest_batch_above_bound_reverts`, `quest_batch_bound_accepted`,
     `achievement_batch_two_tasks_one_write`, `achievement_batch_above_bound_reverts`.
   - Q-19 on the bound (line 1640).
3. **28 per task is a lifetime cap** (major). **Fixed.**
   - Q-14 is rewritten (line 1635) with three options for both packages: retirement with its
     rules and cost; task ids chosen by the consumer; an accepted lifetime cap. The
     recommendation is retirement, with consumer task ids always open.
   - §3 now specifies:
     - `retire` step by step (line 968): the hole is filled with the last id, so pages stay
       contiguous;
     - a `retired` bit (quest A bit 199; achievement A bit 131, with `t0` shifted to
       [132, 196));
     - the events `QuestRetired` and `AchievementRetired`, and the error `'Quest: retired'`;
     - entries in both external ABIs;
     - the rules: player data kept, completed work claimable, accept refused, ids not
       reused, dependents left to the admin.
   - §5: N counts live quests; retire costs ≤ 14 reads and ≤ 7 writes.
   - Tests: `quest_retire_frees_slot` (line 528) and five more; `achievement_retire_frees_slot`
     and `achievement_retired_completed_kept`.
4. **D-6 and D-7 overstate "locked for ever"** (major). **Fixed.**
   - D-6 (line 352): the new title, the reverse index written at create
     (`component.cairo:178-183`), and a table by recurrence: one-off means locked for ever;
     recurring means unlocked by its next completion, after at least one interval. A
     recurring-prerequisite test is added (line 372).
   - D-7 (line 374): the self-condition is locked whatever the recurrence (`:225`). A
     duplicate condition is qualified by recurrence: one-off locks for ever; recurring
     unlocks at the second completion and then underflows (D-4) for a one-off dependent. A
     condition naming a quest defined later is satisfiable once that quest is defined and
     completed.
   - The test is renamed `quest_define_rejects_undefined_condition`, and "already defined"
     is stated as a native design choice.
5. **`edition.workspace = true`** (refuted by the orchestrator). **No design change.** I added
   the sentence to §6.1 (line 1512): verified with Scarb 2.19.4 `scarb metadata` by the
   orchestrator on 2026-09-28.
6. **Achievement events** (minor). **Fixed.** §3.11 (line 1243 onwards) gives the full enum
   and six structs with `#[derive(Drop, starknet::Event)]` and `#[key]` fields, and states
   the derives of `AchievementWindow` and `AchievementTask`.
7. **`quest_is_unlocked` and the presence bit** (minor). **Fixed.**
   - §3.5, `is_unlocked` (line 907): it is true without conditions or when cached; otherwise
     it reads C and each prerequisite's record and returns `prerequisites_met`, without
     writing the cache.
   - §3.3, "Presence bits" (line 758): `defined` is added as `2^198` and read back by
     division; an empty slot reads felt `0`, that is, `defined == false`, which gives
     `'Quest: does not exist'`, "no such condition", and permission to define. No other
     type needs a presence bit.
   - The same for achievements (line 1222, bit 130).
   - `defined` and `retired` are added to both definition structs.
   - Tests: `quest_is_unlocked_evaluates_uncached`, `quest_empty_slot_reads_undefined`,
     `quest_packing_round_trip`, `achievement_empty_slot_reads_undefined`.
8. **§5 corrections** (minor). **Fixed.**
   - `Pg = min(⌊N / 7⌋ + 1, 4)`, with the examples N = 0, 6, 7 and 28 (line 1410).
   - Event-mode `progress_many` emits E events (lines 1422 and 1450).
   - "A call whose counts are all zero reads, writes and emits nothing" is stated.
   - The single-quest rows keep Pg = 1. The §5.3 sentence on pages uses Pg.
   - §3.7's event row is corrected.
9. **`u32` interval id overflows** (minor). **Fixed by widening to `u64`.** The reason is in
   §3.1 (line 557): `(time - start) / interval <= time < 2^64`, so the id cannot overflow,
   and widening costs nothing measurable. Constraining the schedule would reject valid
   ones. The change reaches the storage key, events, hooks, `claim`, `current_interval`
   and the views. Test `quest_interval_id_is_u64` (line 534).
- **Registry note.** §6.5 (line 1611) records the orchestrator's confirmation on 2026-09-28 at
  19:47 UTC.
- **Summary and §7.** The summary (lines 22-38) lists the new changes and 19 questions. Q-9
  refers to `retire`. Q-14, Q-18 and Q-19 are as above. §4 A-5 and A-7 are updated for the
  bound and live quests.

## Acceptance criteria

- [x] **AC-1**: sections 1 to 7 are present for both packages (§1 line 42 to §7 line 1618).
- [x] **AC-2**: statements about the Dojo packages cite `file:line` at `c53fadc`. The new
  D-6 and D-7 text cites `component.cairo:178-183`, `:225` and `:262-272`.
- [x] **AC-3**: D-1 to D-4 are confirmed with scenarios and tests; D-6 and D-7 are qualified.
- [x] **AC-4**: signatures for every library function, entrypoint, hook and event, including
  the complete achievement event structs; layouts with bit ranges, including the new
  `accepted_interval`, `retired` and presence-bit rules.
- [x] **AC-5**: A-1 to A-9 rows (§4).
- [x] **AC-6**: access control (§3.6), now covering `retire`.
- [x] **AC-7**: costs per progress call, `progress_many`, accept, abandon, retire and claim,
  worst cases included, labelled as estimates (§5).
- [x] **AC-8**: workspace, CI, publication and registry (§6), with the orchestrator's two
  confirmations.
- [x] **AC-9**: 20 open questions with options and recommendations (§7).

## Deviations from the brief

- As in the first run: the brief lists `ORCH-quiver.md` §1 and §4; I read the whole file.
  The effect of `scarb publish` on a `path` dependency is left to ARC-02 to verify (§6.2).

## Escalations

These are unchanged from the first run:

- Design/13 may mean titles use the game's own counters rather than `achievement`. That is a
  question for the game's project manager.
- ADR-0004's "aligned on UTC midnight" holds only when `start` is a multiple of 86 400 (Q-17).

New:

- **Q-18 needs the game's designer.** Design/14 does not say whether a held guild contract
  survives the day. The report recommends that acceptance expire at rollover.
- **Q-19 needs the game** (fix loop 2). The design documents do not bound the distinct tasks
  one expedition can report. The report sizes `MAX_ENTRIES = 16` from Region 1 (design/06,
  design/14) and asks the game to confirm a ceiling.

No shared file needs a change.

## Open questions

Q-1 to Q-20 are in the report, §7. The ones that most shape ARC-03:

- **Q-1**: `u32` ids.
- **Q-2**: 3 tasks.
- **Q-3**: a prerequisite is met once completed.
- **Q-4**: an optional accept step.
- **Q-14**: retirement.
- **Q-18**: acceptance until rollover.
- **Q-19**: `MAX_ENTRIES = 16`.
- **Q-20**: refuse retiring a prerequisite with live dependents.

Three are also questions for the game:

- **Q-12** and **Q-18**: for the game's designer.
- **Q-19**: a ceiling on the distinct tasks one expedition reports, which the design
  documents do not bound.
