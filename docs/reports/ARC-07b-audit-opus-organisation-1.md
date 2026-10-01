# [Opus 5.5] Audit — ARC-07b — organisation

## Verdict
PASS WITH FINDINGS

I found nothing that blocks the merge: no blocker, no major and no minor finding. There are 5 notes.

## Findings

| # | Severity | Location | Finding | Evidence or failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | note | `packages/achievement/src/component.cairo:157-161` | The component knows a storage rule: slot B is valid only when there are 2 or 3 tasks. That rule is also written in `Store::get_definition` (`src/store.cairo:87-91`), so it exists in two places. The component still reads only through the store. | `let slot_b = if head.task_count > 1 { self.get_definition_tasks(achievement_id) } else { NO_TASKS };` appears in the component and, almost word for word, in the store. If someone changes the rule in one place only, the view and `get_definition` disagree. `quiver_quest` 0.2.0, which the owner accepted, does the same for slot C (`packages/quest/src/component.cairo:376-380`), so this is a note. | A store read that returns `(HeadSlot, Span<AchievementTask>)`, or an equivalent, so the component keeps only the existence check. Possibly in ARC-07c, for both packages. |
| 2 | note | `packages/achievement/src/models/status.cairo:44,50,57,69,75` | `StatusAssert` and `StatusStorage` take `self` by value. `quiver_quest` 0.2.0 takes `@QuestStatus` and `@HeadSlot` (`packages/quest/src/models/status.cairo:67,73,80,99,110`). The reporter states why it takes a value (`models/reporter.cairo:22-23`, "by snapshot costs 5 steps more … measured"); the status states no reason. | The signatures differ from the reference shape and no reason is written. | Add the one-line measured reason, as the reporter has, or align with quest. |
| 3 | note | `packages/achievement/src/models/reporter.cairo` (whole file), `packages/achievement/src/helpers/bits.cairo` (whole file) | Neither file has a `#[cfg(test)] mod tests`. `ReporterAssert::assert_is_allowed` is tested only through a deployed contract (`tests/test_component_access.cairo`). The tables in `bits` (`POW2` with 128 entries, `TWO_POW_*`, `NZ_*`) are never checked against a computed value; the packing oracles cover them only indirectly. This is not a misplaced test: 0.1.0 had no such tests to move (`GAS.md:225-232`). | A wrong `POW2[i]` would cause a false collision on the fast path, so the merge would fall back to the plain path. The result stays correct and only the cost rises, so no behaviour test would catch it. | Add a small `mod tests` to each: `POW2[i] == 2^i` for every `i`, `TWO_POW_k` against `Pow`, and `assert_is_allowed` on true and false. |
| 4 | note | `packages/achievement/tests/helpers.cairo:45` | A doc comment still names the 0.1.0 free function. | "the fast pass of `batch_merge` runs 15 entries"; the 0.2.0 name is `BatchTrait::merge`, as `src/types/batch.cairo:142` already says. | Replace it with `BatchTrait::merge`. |
| 5 | note | `packages/achievement/src/models/definition.cairo:386`, `packages/achievement/src/types/batch.cairo:198` | Test names inside one module mix two prefixes. `achievement_define_rejects_id_zero` tests `DefinitionTrait::new`, not `define`, and sits among `definition_new_*` tests. `achievement_batch_merges_duplicates` sits among `batch_merge_*` tests. The brief requires 0.1.0 names to be kept unless their path changes, so this is consistent with the brief. | Inconsistent names within `models::definition::tests` and `types::batch::tests`. | Align the names in a later lot if the owner wants it. |

## What the checklist covered

- **Layers (CAIRO §7 and §8.1):**
  - There is no `logic/` folder.
  - `models/` has `index.cairo` with the 3 structs, plus `definition.cairo`, `status.cairo` and `reporter.cairo`, each in arcade's shape: `...Impl of ...Trait`, `...Assert`, `mod errors`, `HeadSlot` and `TasksSlot` with `HeadPacking` and `TasksPacking`, and `DefinitionTracked` / `ReporterTracked`.
  - `types/` holds window, task and batch (`TaskProgress` with `BatchTrait`). `helpers/bits` holds the tables and `BitsTrait::split`. `events/` has one file per event, with `index.cairo`.
  - There is one store. A search for `.read(`, `.write(` and `HasComponent::emit` matches only `src/store.cairo` (the tests' hand-written twins excepted).
  - Every storage member holds a model's slot: A is `HeadSlot`, B is `TasksSlot`, and the reporters are the model's `bool`.
  - The component holds storage, events, the hook, the internal layer, the external ABI and its access checks. Its two `self.emit` calls are the action events (`component.cairo:107,141`).
- **Free functions (§8.2):** There are none in library code outside `mod tests`. The constant tables are justified in writing (`helpers/bits.cairo:4-5`). `NO_TASK` and `NO_TASKS` are constants.
- **Tracking (§8.3):**
  - `set_definition` and `set_reporter` emit once, behind `if Tracking::DEFINITION` and `if Tracking::REPORTER` (`store.cairo:125,164`). `set_status` emits nothing (`store.cairo:142-146`).
  - The action events do not depend on the choice.
  - Tests cover every case:
    - `tests/test_store_models.cairo`: 3 writes give 3 events under `TrackAll` (created, changed, rewritten unchanged); there are none under `TrackNone`, with the same felts written; the status never emits.
    - `tests/test_component_track_own.cairo`: each constant works alone and cannot be swapped with the other.
    - `tests/test_component_track_none.cairo`: `AchievementProgressed` and `AchievementRetired` are still emitted under `TrackNone`.
  - `AchievementDefined` is built from the model (`events/defined.cairo:13-16`).
- **Where tests live (D-167):** Unit tests are in `types/batch`, `types/window`, `models/definition`, `models/status`, `store`, `constants` and `errors`. Every file in `tests/` deploys a contract, and `test_tracking.cairo:8` gives the written reason for staying there.
- **Names (§8.4):** They match `quiver_quest` 0.2.0: `AchievementTracking`, `tracking::{TrackAll, TrackNone}`, `DEFINITION`, `REPORTER`, `Tracked`, `HeadSlot`, `TasksSlot`, `DefinitionStorage`, `StatusStorage`, the `errors::<MODEL>_*` constants, `DefinedTrait::new`. The view returns `HeadSlot`, as quest's does.

## Coverage

**Read:**
- the brief `docs/briefs/ARC-07b-achievement-0.2.0.md`, and `docs/CAIRO.md` in full (§2, §7, §8);
- every file under `packages/achievement/src/` and `packages/achievement/tests/` except the bodies of `test_component_access`, `test_component_progress`, `test_component_retire` and `test_component_bench` (I read their names, imports and doc comments);
- `packages/achievement/README.md` lines 1-140, `CHANGELOG.md`, and the 0.2.0 sections of `GAS.md`;
- the reference `packages/quest/src/store.cairo`, `models/status.cairo`, `models/reporter.cairo`, and the impl and struct list of quest's `models/`, `types/` and `events/`.

**Could not check:** this session refuses every Bash command except the first, which only read the brief and listed the files. So I ran nothing:
- not `scarb build`, `snforge test`, `scripts/gas.py --check` or `scarb fmt --check`;
- not `git diff 50017e7..HEAD`, so I did not compare against 0.1.0's sources;
- not `ref/arcade`, which I did not read.

Everything above is from reading the code; none of it is reproduced by a run. Outside this lens, I did not check `docs/BUDGETS.md`, the ARC-01 and ARC-06 documents, CI status, or the figures in `GAS.md`.
