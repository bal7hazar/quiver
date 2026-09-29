# Common rules of every task brief

Every brief in `docs/briefs/` inherits these rules. The orchestrator launches an agent with a
one-line prompt, `Read docs/briefs/<ID>-<slug>.md and docs/briefs/COMMON.md, then execute the
task.`, through `scripts/agent.sh`, in the task's own worktree. When a brief and this file
disagree, the brief wins for its task, and says so.

Adapted from `docs/briefs/COMMON.md` of `bal7hazar/grimworld`: the rules of this repository are
those of the game's [OPERATIONS.md](https://github.com/bal7hazar/grimworld/blob/main/OPERATIONS.md).
What belongs to the game only (assets, instances, multiplayer, the chain made invisible) is left
out.

## 1. Read first

1. The brief, then this file.
2. [README.md](../../README.md) and [PLAN.md](../../PLAN.md): what `quiver` is, one package per
   feature, pure Cairo and pure Starknet components, **no Dojo**.
3. The documents the brief names. Documents of the game are given to you as files in your
   worktree (under `ref/`, ignored by git) or as paths at a pinned commit; read them there.
4. **Every Cairo task: [docs/CAIRO.md](../CAIRO.md), in full.** Test-driven, a gas budget on
   every test, execution cost first, arithmetic then bitwise then loops, no `u256` without a
   written reason. Cairo 2.19 (Scarb 2.19.4), snforge 0.61, `snforge_std` as a
   **dev-dependency** only.

## 2. How you work

- **Foreground only.** Never run a command in the background (`&`, `run_in_background`,
  `nohup`) and never end your turn waiting for one: in headless mode that ends the session. A
  command may run for up to one hour in the foreground. Your turn ends when `REPORT.md` is
  written.
- **Work autonomously, do not ask questions, do not widen the scope.** Nobody answers
  during your run. What the brief does not ask for is out of scope, however tempting.
- **Ambiguity stops you.** If the documents do not say what the code must do, you do not
  invent a rule: you stop that part, and you write the question under *Escalations* in the
  report, with the documents you read.
- **Your allowlist is the brief's.** Write only the files and folders it lists. Anything
  else, including the shared files below, is an escalation in your report, not an edit.
- **Shared files belong to the orchestrator**: `README.md`, `PLAN.md`, `STATUS.md`,
  `docs/decisions/`, `docs/briefs/`, `docs/reports/`, `docs/CAIRO.md`, `.github/`,
  `scripts/agent.sh`, `scripts/lock.sh`, `scripts/profiles/`, the root `Scarb.toml` and
  workspace manifests, unless the brief lists one of them.
- **Your permissions** come from the profile of your launch (`scripts/profiles/`):
  `research`, `audit` or `implement`. A refused command is not an obstacle to work around:
  use an allowed command, or report what you needed. Run commands from the worktree root
  and call the project's scripts as `scripts/…` (`scripts/lock.sh`, not
  `../../scripts/lock.sh`), with `--manifest-path` for a package in a subfolder: rules match
  the start of a command. Delete files with relative paths inside your worktree.
- **Commit early** (profile `implement`). Coherent intermediate states in small commits, so
  that an interruption loses nothing; you may be resumed with `claude --continue`. A task on
  the `research` profile cannot commit: it writes its files in the worktree, and the
  orchestrator commits them and opens the pull request.
- **Never publish.** No sub-agent publishes, ever (D-132). A release on scarbs.xyz cannot be
  undone: the orchestrator's session publishes, and only after a go of the project manager
  that names the package, the version and the commit. The orchestrator asks by committing
  `docs/decisions/PENDING-publish-<package>-<version>.md` (package, version, commit, what
  changed, what the consumer must do); the project manager checks by itself that the commit
  is on `main` with every CI check completed and green, audits closed without `blocker` or
  `major`, changelog and version in agreement, the gas tables of that commit, `scarb package`
  from a clean checkout, the name and version free on the registry, and no test dependency
  declared as a regular one.

## 3. The machine

The VPS (8 vCPU, 31 GB) is shared with the owner's other programmes and with other agents.

- **Every heavy command goes through the build lock**:
  `scripts/lock.sh scarb --manifest-path <package>/Scarb.toml build` (Scarb 2.19: the option
  comes before the subcommand), `cd <package> && snforge test <filter>` (the machine's
  `snforge` shim takes the heavy lock). A workspace-wide run adds `--heavy`. `scarb` and
  `snforge` on your PATH are the machine's shims, which take the shared heavy lock by
  themselves.
- **Local checks are package-scoped**: the tests of the package you touched and of the
  packages that depend on it. Never the whole workspace locally; the pull-request CI is the
  full gate. Push early and fix from CI.
- A build killed with signal 9, or exit code 137, is the OOM killer, not your code: wait a
  minute and run it again.
- Do not install or upgrade anything the brief does not ask for. Never change the machine's
  toolchain (`asdf set`, `asdf install`, `asdf plugin`): other programmes use it.
- **The machine is shared** (the game's OPERATIONS §3, 2026-09-29): delete and kill only what you
  created, named exactly. Temporary files and directories go under your own worktree (for example
  `target/` or a folder the brief names), never directly under `/tmp`. No wildcard outside your own
  directory, no kill by pattern (`pkill -f`, `killall`), no `git clean` or `git worktree prune`
  anywhere but your own worktree.

## 4. Rules of the packages

- **One package per feature.** A package depends on another only through its published
  interface (a path dependency inside the workspace, a version once released); never on its
  internals.
- **Logic and component.** The logic is a Cairo library without storage: state in, state out,
  testable without a deployment. The Starknet component wraps it with storage, events and
  hooks the consumer implements. No world, no model, no Dojo.
- **Two modes, chosen per call** (ADR-0004 of the game): storage when a rule of the consumer
  reads the data; events when it is only shown.
- **Access control is the package's.** Who may report progress, register, claim: written,
  tested, and audited on every lot that touches it.
- **Results are API.** A change to the outcome of a call for the same state and input, to a
  storage layout or to an event, is announced in the package's changelog; after a release it
  needs a new major or minor version as semver says.
- **Bounded execution.** Every loop has a bound stated in the package's documentation.
- **Names** (D-126 of the game): packages of our own take the prefix of the repository
  (`quiver_quest`, `quiver_achievement`); a mirror of a Rust crate keeps the crate's name.

## 5. Branch, commits, pull request

- Your worktree is on the branch the orchestrator created, `<type>/<task-id>-<slug>`, cut
  from `origin/main`. Stay on it; never touch `main`, another branch or another worktree.
- **Conventional commits** (`feat(quest): …`, `fix(achievement): …`, `chore(tooling): …`,
  `docs(research): …`), each ending with the trailer naming the model that did the work:
  `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` (or `Claude Opus 5.5`,
  `Claude Fable 5.1`).
- Never force-push, never rebase a pushed branch (merge `origin/main` into it instead),
  never skip hooks, never commit a secret.
- Push with exactly `git push -u origin HEAD` the first time and `git push` afterwards
  (the only two forms your profile allows). Open the pull request yourself with
  `gh pr create --base main`, title `[<Model>] <TASK-ID> <short description>`, body with the
  summary, the acceptance criteria ticked, the gas table for a Cairo task, and a last line
  `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
- Wait for the CI in the foreground (`gh pr checks <n> --watch --interval 30`) and fix until
  it is green. **Never merge**; the orchestrator does.

## 6. REPORT.md

Written at the root of your worktree, **not committed** (it is ignored by git). The
orchestrator reads it and the log, never your transcript.

The header's `[<Model>]` is **the model you read from your own session** (the model your
system prompt says you are running as), not the one the brief names; if they differ, say so
in the summary. The launcher also records the model the CLI actually ran (`model=` in the
log, `scripts/agent.sh status`), and the orchestrator checks the two agree.

```markdown
# [<Model>] <TASK-ID> — <title>

## Summary
What exists now that did not before. Pull request URL, if you opened one.

## Files changed
One line each.

## Commands run
Each with its real output, trimmed to what matters. No figure that was not measured.

## Cost
| Entrypoint or algorithm | Before | After | Budget | Note |
Every test and benchmark the lot touched (Cairo tasks). "—" for a task without Cairo.

## Acceptance criteria
Each criterion of the brief, with the test or command that shows it.

## Deviations from the brief
## Escalations
Shared files that need a change, design ambiguities, blockers.
## Open questions
```

An auditor writes the audit report of the game's
[OPERATIONS.md §6](https://github.com/bal7hazar/grimworld/blob/main/OPERATIONS.md#6-audits)
instead, in the same file.
