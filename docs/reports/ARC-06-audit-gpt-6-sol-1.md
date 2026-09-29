# [GPT-6-Sol] Audit — ARC-06 — organisation

## Verdict

**FAIL.** The reference model follows most of Arcade’s layout, and `set_definition` emits `QuestDefined` on every call. Production reads still bypass the store, and the written convention does not yet cover every ARC-07 model.

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | **major** | component.cairo (`packages/quest/src/component.cairo:387`) | Production reads of definition data bypass `Store::get_definition`. | `definition()` reads A, B and C directly; other paths also read definition fields directly. A source search found `get_definition` used only in tests. This misses the brief’s requirement that reads of the reference definition go through the store. | Route full definition reads through the store. Put necessary A-only reads behind focused store methods so hot paths retain their current cost. |
| 2 | **major** | research write-up (`docs/research/ARC-06-model-store.md:182`), achievement component (`packages/achievement/src/component.cairo:52`) | The convention as written does not fit achievement definitions without an exception. | `AchievementDefined` includes `points`, but `points` is deliberately absent from storage. A definition reconstructed by `get_x` therefore cannot produce its required event through `Tracked::event(@model)`. The write-up gives ARC-07 no rule for this case. | Decide explicitly whether event-only data is passed to `set_x`, held in a write-time model that cannot be reconstructed, or treated as an action event. Preserve the published layout and measure any change. |
| 3 | **minor** | store.cairo (`packages/quest/src/store.cairo:6`), research write-up (`docs/research/ARC-06-model-store.md:81`) | The compile-time guarantee is overstated. | `Tracked<QuestDefinition>` selects an event type at compile time. It does not force a hand-written `set_x` to call `Tracked::event`, prevent that method from emitting twice, or prevent direct storage writes or an untracked setter from emitting manually. The mock tests verify their implementations, not those general properties. | State that emission is enforced by convention and per-model tests; add a source check for tracked setters and direct writes if this is to govern ARC-07. |
| 4 | **minor** | models/definition.cairo (`packages/quest/src/models/definition.cairo:244`) | The two free functions have a written reason, but its ownership claim is weak. | `task_at` and `id_at` exist solely to build the definition’s storage slots. The comment says no type owns them, although `DefinitionStorage::into_slots` owns that conversion. | Scope them with the conversion or give a specific reason that doing so is unsuitable. |
| 5 | **note** | models/index.cairo (`packages/quest/src/models/index.cairo:9`), logic/types.cairo (`packages/quest/src/logic/types.cairo:42`) | Two public types are named `QuestDefinition`. | One is the new model; the other is 0.1.0’s packed slot A and remains in the public view. The write-up defers renaming it to ARC-07. | In 0.2.0, reserve `QuestDefinition` for the model and give the packed representation a slot-specific name. Model status separately; slot A also contains schedule and counts. |

## Coverage

Compared `models/definition.cairo`, `models/index.cairo`, `store.cairo`, and `events/` with Arcade at `c53fadc`. The struct and trait layout, assert impl, scoped errors, event folder, and `get_x`/`set_x` shape are substantially retained. Replacing Dojo’s world with `ComponentState`, using explicit storage conversion for three packed slots, and emitting the existing Starknet `QuestDefined` event are justified differences. The convention choice is reasonable: the component store cannot be shared, while the reusable `Tracked` trait is small.

For ARC-07, quest progress and record can be untracked models with separate action events; reporter entries can be tracked; held slots can be models while list operations remain store methods. Quest status needs careful handling because it shares physical slot A with definition data. Achievement definition is the case the written pattern does not yet fit.

Reviewed source, tests, the brief, §7–8, and the research write-up. `git diff --check origin/main...HEAD` passed. I did not run build or tests in the read-only workspace.