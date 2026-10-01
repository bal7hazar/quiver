# [Opus 5.5] Audit — ARC-07b — organisation (formal)

**Revision read:** `970cff18687d8b197309839d29e780648ceb4a23`, which is the head of #25 (confirmed with `gh pr view 25`, `headRefOid`).

## Verdict
PASS WITH FINDINGS

Nothing blocks publication. The only open findings are my earlier notes 1 and 5, both deferred to ARC-07d.

## Findings

| # | Severity | Location | Finding | Evidence or failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | note (open, deferred to ARC-07d) | `packages/achievement/src/component.cairo:157-161` | The rule for when slot B holds data is written twice: in the component's view and in `Store::get_definition` (`src/store.cairo:87-91`). | Neither file changed since `66ae1c8`. `PLAN.md` records the deferral under ARC-07d, item (1). | As in ARC-07d: one store read for the view. |
| 5 | note (open, deferred to ARC-07d) | `packages/achievement/src/models/definition.cairo:386`, `packages/achievement/src/types/batch.cairo:198` | Test names inside a module mix 0.1.0 prefixes, as the brief requires (renamed only where paths change). | Unchanged. `PLAN.md` records it under ARC-07d, item (5). | As in ARC-07d, if the owner wants it. |

### My earlier notes, at this revision

| Earlier note | State | Evidence |
|---|---|---|
| 1. Slot B rule written twice | Open, deferred (ARC-07d) | Unchanged; `PLAN.md` ARC-07d row |
| 2. Status `self` by value with no reason | **Closed** | `StatusStorage::status` and `into_slot` now take `@HeadSlot` / `@AchievementStatus`, as quest does (`models/status.cairo:66-81`). `StatusAssert` stays by value and says why above the impl: "by snapshot costs 1 step more per check, +100 on `define` and the view, +200 on `retire` (measured, ARC-07b fix loop 2)". |
| 3. No unit tests in `bits` or `reporter` | **Closed** | `helpers/bits.cairo` has a `mod tests`: all 128 entries of `POW2` checked against doubling; every `TWO_POW_*` and `NZ_*` at its power; `split` with both limbs set and with the high limb zero. The high-limb literal has 31 hex digits (counted), so 2^123 − 1, below the high limb of the field prime as its comment says. `models/reporter.cairo` has a `mod tests`: `assert_is_allowed` passes when allowed and reverts `'Achievement: not reporter'` when not. All 7 tests have budgets listed in `GAS.md` (lines 12-16 and 46-47 at `970cff1`). |
| 4. Stale `batch_merge` in a comment | **Closed** | `tests/helpers.cairo:45-46` now says `BatchTrait::merge`. |
| 5. Mixed test-name prefixes | Open, deferred (ARC-07d) | Unchanged |

### Checklist on the whole package at `970cff1`

The only changes to `packages/achievement/src` and `tests` since my audit of `66ae1c8` are the diffs above (`git diff --stat 66ae1c8 970cff1`). The merges from `main` touched only `PLAN.md`, `STATUS.md` and the ARC-07c brief. The rest of my earlier reading therefore still holds:

- **Layers (§7, §8.1):** there is no `logic/`.
  - `models/` follows arcade's shape: `index` plus `definition`, `status` and `reporter`, each with its trait, `...Assert`, `errors`, slots and packing, and `Tracked` impl where it has one.
  - `types/` holds window, task and batch; `helpers/` holds bits; `events/` has one file per event.
  - There is one store, and only `store.cairo` reads or writes storage. The component holds only entrypoints, the hook, access control and the two action-event emits.
- **Free functions (§8.2):** none in library code. The constant tables have their written reason. The new `felt_pow2` and `u128_pow2` are test helpers inside `#[cfg(test)]`.
- **Tracking (§8.3):**
  - Each tracked model emits once per write under `TrackAll` and nothing under `TrackNone`.
  - Each constant works alone under a consumer's own impl (`test_component_track_own`).
  - The status never emits.
  - `AchievementProgressed` and `AchievementRetired` are emitted whatever the choice.
- **D-167:** unit tests now live in every library module that has behaviour (`bits` and `reporter` added). Everything in `tests/` deploys a contract.
- **Names (§8.4):** they match `quiver_quest` 0.2.0, and `StatusStorage` now has quest's signatures.

## Coverage

**Read:**
- `git log` and `git diff 66ae1c8 970cff1` for `packages/achievement/src` and `packages/achievement/tests` in full, and for `PLAN.md` and `STATUS.md`;
- the `GAS.md` budget lines for the new and moved tests;
- my earlier full reading of the package at `66ae1c8` (brief, `docs/CAIRO.md`, every `src` file, `tests/`, and the reference `packages/quest`), which still applies because nothing else in the package changed.

**Ran:**
- `gh pr checks 25` on head `970cff1`: all 6 checks pass, including `package (packages/achievement)` (32s), `cairo`, `links` and `scripts`.

**Could not run:** this session refused `git fetch`, `scarb`, `snforge` and `scripts/gas.py`. The revision was already present locally, and I read it with `git show` and `git diff`. Building, test results and budget checks rest on the green CI, not on my own run.

**Outside the organisation lens:** the cost figures in `GAS.md` and `docs/BUDGETS.md`, and the ARC-01 and ARC-06 documents.
