# [opus] Review — ARC-09 single-threaded builds

## Verdict
PASS WITH FINDINGS

## Revision
226f228bf368b01a0c84d68a7cbf56b3faf099f3, compared with origin/main

## Findings
| # | Severity | Location | Finding | Evidence or failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | note | `scripts/gas.py:188` | `setdefault` treats a variable that is set but empty as the caller's choice. An empty value gives rayon its default thread count, so the run is multi-threaded. | Running `RAYON_NUM_THREADS= python3 scripts/gas.py packages/quest --write` passes `""` to snforge, and the build uses the default threads. This matches the brief's literal wording ("unless the caller set it"), so it is not a defect. | Optional: also pin to `"1"` when the value is empty. |
| 2 | note | `docs/WORKSPACE.md:125` | The project manager's check "`scarb package` from a clean checkout" in §7 has no pin. The pinned commands in §6 and §7 are the ones the brief names. | The quoted line has no `RAYON_NUM_THREADS=1`. If the check builds multi-threaded, it could produce a program other than the one CI measured. | Point to the pinned command in §6. |
| 3 | note | `docs/WORKSPACE.md:128` | "the published program is the single-threaded one" claims too much. `scarb publish` uploads sources, and each consumer compiles them with its own thread setting. | Scarb's package and publish archive the sources (`target/package/*.tar.zst`). No compiled program is published. | Say instead that the verification build of the publish is single-threaded. |

## Coverage
- **Diff read in full**, plus the whole of `cairo.yml`, `release.yml`, `scripts/gas.py` (from line 100), the brief, and §5–7 of `WORKSPACE.md`.
- **AC-1:** in the `package` job, `RAYON_NUM_THREADS: "1"` is on `build`, `test` and `gas`, each with a one-line D-176 comment. The other steps are checkout, setup, the snforge install, the version check and `scarb fmt --check`, and none of them compiles. `release.yml`'s `scarb package` is pinned with its comment. `release.yml` reuses `cairo.yml` for its workspace jobs, so those are pinned too.
- **AC-2:** `snforge_env` copies the environment and only sets the variable when it is missing. The two tests cover both cases: missing, so it becomes `"1"`, and set to `"4"`, which is kept. The manual `package` and `publish` commands in `WORKSPACE.md` are pinned.
- **GAS.md claim:** the brief allows this section when nothing differs (its scope item 4 says "say so in each GAS.md"). The test counts in the sections match the rows `gas.py` generated, which I measured with grep: quest 512, achievement 145. On PR #32, CI's `gas --check` passed under the pin for both packages. That shows the single-threaded figures equal `GAS.md` on CI's machine.
- **Could not check:**
  - Running `python3 -m unittest scripts/test_gas.py` locally was refused by permissions. CI's `affected` job runs these tests and passed.
  - `REPORT.md` is not in the branch or anywhere on this machine. I therefore could not compare the six-run comparison (whether the default runs vary among themselves) or the slowdown figures against the GAS.md text. The PR body says all six runs per package were identical and equal to `GAS.md`.
  - I did not re-run the clean-build measurements.
- **CI on PR #32:** every check is green (affected, scripts, links, both package jobs, cairo). The PR body still has AC-6 unticked.
