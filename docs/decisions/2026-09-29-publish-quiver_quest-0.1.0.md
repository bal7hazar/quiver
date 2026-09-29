# `quiver_quest` 0.1.0 — published 2026-09-29 (D-138)

| | |
|---|---|
| Asked by | `[Opus 5.5]` orchestrator of `quiver`, 2026-09-29 |
| Decides | The project manager (D-132): a go that names the package, the version and the commit |
| Package | **`quiver_quest`** (`packages/quest`) |
| Version | **0.1.0**, the first |
| Commit | **`364462f9c7dcc60f52dd45ab1e9d735c3aa7cbe2`** on `main` (`364462f`) |
| Registry | scarbs.xyz; the name is free (`api/v1/index/qu/iv/quiver_quest.json` answered 404 on 2026-09-29) |
| Published by | The orchestrator's session, by hand, after the go (`scarb --manifest-path packages/quest/Scarb.toml publish` from that commit); no agent, no CI |

## What it is

Quests for Starknet games, without Dojo: a pure Cairo library (`quiver_quest::logic`) and a
Starknet component (`QuestComponent`) with storage, events, hooks the consumer implements, an
optional external ABI with its access control, and views. The API is the one accepted at gate A-G1
(D-131, [ARC-01 §3](../research/ARC-01-quest-achievement.md)), amended by the cost cap and by
D-135 ([decision](2026-09-28-quest-cost-cap.md)):

- tasks with a target count, one-off and recurring schedules (daily aligned on 00:00 UTC when
  `start` is a multiple of 86 400), AND prerequisites checked at acceptance, completion once per
  interval, claim once, a claim hook receiving the claim index;
- **every quest is accepted before it progresses; a player holds at most `MAX_HELD` = 4 quests**
  (the layout works up to 8); an acceptance expires at rollover with its progress; progress walks
  the player's held quests only;
- one aggregated `progress_many` call per player per transaction, at most 16 distinct tasks;
- storage or event mode per call; definitions always stored; retirement guarded by live dependents;
- only registered reporters report progress; admin and player authorisation are hooks.

## What was checked, at that commit

| The project manager's check (D-132) | Result |
|---|---|
| On `main`, every CI check completed and green | `tooling` and `cairo` both **success** on `364462f` (the `package (packages/quest)` job runs build, 423 tests and the gas check) |
| Audits closed without `blocker` or `major` | ARC-03a `[GPT-6-Astra]`: [PASS WITH FINDINGS](../reports/ARC-03a-audit-gpt-6-astra-2.md). ARC-03c `[GPT-6-Astra]`: four passes, the last [PASS WITH FINDINGS](../reports/ARC-03c-audit-gpt-6-astra-4.md), no major; its last minor closed in #15. ARC-03b's findings were carried into ARC-03c and re-checked there |
| Changelog and version agree | `Scarb.toml` 0.1.0; `CHANGELOG.md` section `[0.1.0] - 2026-09-29`; `.github/ci/release_check.py quiver_quest-v0.1.0` passes |
| Gas tables of that commit | `packages/quest/GAS.md` (423 tests, each within `ceil(1.05 × measured)`, checked by `scripts/gas.py --check` in CI) and `docs/BUDGETS.md` |
| `scarb package` from a clean checkout | A fresh clone at `364462f`: packaged and verified, 52 files, 72.11 KiB; archive sha256 `494228f198376611f338d75a4c8511cd02eec1bc8ee666c4bd6c7973eeb4379c` |
| Name and version free on the registry | `quiver_quest`: 404 on the index |
| No test dependency declared as a regular one | Packaged manifest: `[dependencies] starknet ^2.19.0` only; `snforge_std ^0.61.0` under `[dev-dependencies]` |

## Cost, measured

| Call | L2 gas (snforge) | Network estimate | Share of the 20M cap |
|---|---|---|---|
| Worst `progress_many`, `MAX_HELD` = 4, new slots, hooks empty | 6 213 063 | 6 168 215 | 31 % |
| Same, with a hook writing one new slot per completion | 8 027 983 | 7 960 711 | 40 % |
| Worst at the layout's limit of 8 held, one-slot hook | 15 060 053 | 14 925 509 | 75 % |
| Grim World's use (16 tasks, 3 quests and one contract) | 4 553 406 | 4 469 558 | 23 % |
| `accept`, worst | 1 921 540 | 1 885 222 | 10 % |

Network estimates reprice each written slot at the figures read on Sepolia by the game's FND-04
(about 453 500 L2 gas for a created slot, 32 000 for an overwritten one). The network's
per-transaction limit is 1.1 × 10⁹ L2 gas.

## What the consumer must do

- Depend on `quiver_quest = "0.1.0"`; embed `QuestComponent`, implement `QuestHooksTrait`
  (`authorize_admin`, `authorize_player`, `on_quest_complete`, `on_quest_claim`); embed
  `QuestViewImpl`, and `QuestImpl` only if it wants the package's external ABI.
- Register its reporters (or call the internal layer from its own checked entrypoints: the
  internal layer checks nothing).
- Accept every quest before it progresses; aggregate its results by task id and call
  `progress_many` once per player per transaction, with at most 16 distinct tasks.
- Size its own hooks: the integration budget in the package's README.
- For Grim World (GLD-02): needs A-1 to A-12 of its `docs/needs/arcade.md` are answered by this
  version.

## Known and documented

- After 2³⁰ acceptances by one player, an entry accepted 2³⁰ acceptances earlier and still held
  cannot be told apart from a renewal of the same quest in the same interval made by a hook during
  a progress call (the residual accepted under the [decision of the last loop](2026-09-29-ARC-03c-last-loop.md)).
- `quest_held` returns stale entries until the player's next `accept` prunes them, by design.

## Answer and publication

Go given by the project manager `[Fable 5.1]` in the owner's name on 2026-09-29, **D-138**
([record in the game](https://github.com/bal7hazar/grimworld/blob/main/docs/decisions/2026-09-29-publish-quiver_quest-0.1.0.md),
`6e7393a`), for that package, that version, that commit and that archive only.

Published by the orchestrator's session, by hand, on 2026-09-29: a fresh clone at `364462f`,
`scarb --manifest-path packages/quest/Scarb.toml package` with Scarb 2.19.4 gave sha256
`494228f198376611f338d75a4c8511cd02eec1bc8ee666c4bd6c7973eeb4379c`, equal to the go's; then
`scarb … publish` from the same checkout.

| | |
|---|---|
| Registry | **https://scarbs.xyz/packages/quiver_quest**, version 0.1.0 |
| Registry checksum | `sha256:494228f198376611f338d75a4c8511cd02eec1bc8ee666c4bd6c7973eeb4379c` (the index's `cksum`, equal to the approved archive) |
| Recorded dependencies | `starknet ^2.19.0` (normal), `snforge_std ^0.61.0` (test) |
| Tag and release | [`quiver_quest-v0.1.0`](https://github.com/bal7hazar/quiver/releases/tag/quiver_quest-v0.1.0), on `364462f`, with the archive attached |
