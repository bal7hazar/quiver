# [Sonnet 5.5] ARC-12 — gas.py safety

## Summary
Three safety fixes to `scripts/gas.py`, the notes of the review of ARC-11. No file under `packages/` is changed.

- `--write` refuses (exit 1, a message naming the `GAS.md`, nothing written) a non-empty `GAS.md` in which no generated table is found. A missing or blank file still gets a fresh table. The refusal comes before the snforge run, and again in the pure `rewrite()`.
- The table header and separator are the constants `TABLE_HEAD` and `TABLE_SEPARATOR`, which `render()` writes and the parser looks for, so they cannot drift apart.
- `generated_table()` ends the table at the first line that is not its header, separator or a row (`ROW_RE`); a hand-written `|` line glued to the table is kept.
- `parse_table()` (so `--check`) reads the generated table only, not tables of the hand-written sections.

## Files changed
- `scripts/gas.py`: `TABLE_HEAD`, `TABLE_SEPARATOR`, `generated_table()`, `parse_table()`, `hand_written()`, `rewrite()`, `main()`, docstring.
- `scripts/test_gas.py`: classes `GeneratedTableOnly` (5 tests) and `WriteWiring` (4 tests).
- `docs/WORKSPACE.md`: §5 describes the refusal and the generated-table-only reading.
- `PLAN.md`, `STATUS.md`: ARC-11 done, ARC-12 in progress, 0.2.0 requests and ARC-07d state.
- `docs/reports/ARC-12-report.md`: this report.

## Commands run
- `python3 -m unittest scripts/test_gas.py`: `Ran 47 tests ... OK`.
- `python3 scripts/gas.py packages/quest --check` (Linux): `quiver_quest: 512 tests within budget, GAS.md up to date`, exit 0.
- `python3 scripts/gas.py packages/achievement --check` (Linux): `quiver_achievement: 145 tests within budget, GAS.md up to date`, exit 0.
- `git status --short` afterwards: only the allowlisted files.

## Cost
—

## Acceptance criteria
- AC-1: `test_refuses_a_file_without_a_generated_table`, `test_main_refuses_and_writes_nothing` (exit 1, message names `GAS.md`, file unchanged), `test_missing_or_empty_file_gets_a_fresh_table`, `test_header_comes_from_render`.
- AC-2: `test_a_glued_hand_written_pipe_line_is_kept`, `test_a_glued_line_shaped_like_a_row_is_a_row`.
- AC-3: `test_check_reads_only_the_generated_table`; both real `--check` runs above pass as before.
- AC-4: nine new tests; the wiring is `rewrite()` (`test_render_plus_kept_tail`), no snforge. 47 tests pass.
- AC-5: PLAN.md and STATUS.md updated, structure kept.
- AC-6: see the pull request's checks; the head sha is in the report's `## Next`.

## Deviations from the brief
None. A line shaped like a generated row (`` | `name` | n | n | ``) glued to the table counts as a row, by the brief's own definition.

## Escalations
None.

## Open questions
None.
