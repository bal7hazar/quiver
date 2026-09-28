# [GPT-6-Sol] Audit — PR-8 — launcher lock

> Audited: `bal7hazar/quiver` pull request #8 at `800f71c`, whose shared counting code is the game's
> `scripts/agent.sh` at `44586e6` (the launcher reference). Every finding below lies in that
> shared code.

## Verdict

**FAIL.** The lock serializes launcher calls, but a newly detached audit can remain uncounted when the lock is released. The count can also merge distinct audits into one.

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | **blocker** | scripts/agent.sh:400 (`scripts/agent.sh:400`), scripts/agent.sh:204 (`scripts/agent.sh:204`) | The detached launch is not guaranteed to be countable before the lock is released. | With two agents running, the launcher forks a third and writes its PID. If that child has not yet executed the command carrying its log argument, the next launcher sees a live PID without that argument, treats it as reused, counts two, and can start a fourth. | Keep a verifiable pending-launch reservation under the lock until the child is identifiable; distinguish later PID reuse with process start time. |
| 2 | **blocker** | scripts/agent.sh:208 (`scripts/agent.sh:208`), tooling.yml:89 (`.github/workflows/tooling.yml:89`) | Distinct audits in one working directory count as one. | The count applies `sort -u` to working directories, and CI explicitly expects two processes in one directory to count once. One unit plus two independent audits in that directory is counted as two agents, leaving room to start a fourth. | Identify audit sessions, then deduplicate only the processes belonging to the same session. |
| 3 | **major** | scripts/agent.sh:173 (`scripts/agent.sh:173`), scripts/agent.sh:211 (`scripts/agent.sh:211`) | An incomplete `/proc` scan can produce a lower count. | An unreadable `cmdline` is silently skipped. An unrecorded codex audit with an unreadable `cmdline` is therefore missed; the pipeline also masks a `sort` failure with `|| true`. Checking `/proc/self/cmdline` does not establish that other entries are readable. | Refuse a launch when enumeration or classification is incomplete; propagate pipeline failures. |
| 4 | **major** | scripts/agent.sh:210 (`scripts/agent.sh:210`) | Unreadable working directories can overcount one audit’s processes. | Each failed `readlink` receives a different `unreadable-$pid` directory. If two processes belong to each of two audits and their directories cannot be read, two agents count as four, preventing another launch while the condition persists. | Report an uncertain count explicitly, or use a session identity that remains available without the working-directory link. |

## Coverage

Reviewed the PR diff, the launcher reference at `grimworld` commit `44586e6`, and the game’s audit rules. `bash -n` and `git diff --check` passed. I did not run CI’s fixture script because it writes files and starts background processes; `shellcheck` is unavailable here.

The shared lock covers the count through both launch calls, and both launched children close its file descriptor. Claude launches require a systemd user manager and use a unit; there is no detached Claude fallback. The unit query includes activating units; [systemd’s documentation](https://github.com/systemd/systemd/blob/main/man/systemd-run.xml) says `systemd-run` normally returns after the service has begun execution. A failed `systemctl` query and a garbage PID record refuse launch; the log-argument check handles ordinary reused PIDs. The launcher scans `codex exec` arguments, including `exec resume`, but CI tests only the former.

CI would fail if the lock or count were removed entirely. It does not test a second launch immediately after a permitted detached start, distinct audits sharing a directory, unreadable `/proc` entries, or whether the lock remains effective through a successful start.