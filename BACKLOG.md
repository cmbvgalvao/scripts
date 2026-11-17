# Backlog

## Now: macfleet (`bin/macfleet/`)

One command for the classroom Mac jobs, next to the original scripts in
`bin/runScriptOnRemote/` (kept unchanged on purpose).

- [x] Readability refactor of `bin/runScriptOnRemote/` (PR #2, merged 2026-11-17)
- [x] Fixes in `bin/runScriptOnRemote/`: CSV blank lines and missing final newline, missing script check, `deleteMacUser` empty-name guard, brew path on Apple Silicon (PR #2)
- [x] `macfleet` tool: all jobs, confirm before risky jobs, `--dry-run`, `--parallel`, summary and failed-Macs CSV (PR #3, merged 2026-11-17)
- [x] Demo: narrated MP4 (kept outside the repo) and a README GIF, recorded with simulated Macs
- [x] `--parallel N` to choose how many Macs at a time (plain `--parallel` stays 10)
- [x] `--log FILE`: each run appended with date, job, each Mac's result and output; the new account's password masked
- [ ] Try `macfleet` on one real Mac: `--dry-run`, then `install` on a one-Mac CSV (checks bash 3.2, SSH, brew path)
- [ ] Try `add-user` / `delete-user` on a test account on that Mac (real `sysadminctl`)

## Later / ideas

- Decide whether to retire `bin/runScriptOnRemote/` once `macfleet` has prepared a real classroom

## Known limits

- Tested only with a fake `ssh` and `sudo` on Windows (Git Bash, bash 5); never on macOS bash 3.2
- Remote `sudo` must work without a password prompt (same as the original scripts)
- `--parallel` needs SSH keys (`setup-ssh`), it turns on `BatchMode`

## Log

- 2026-11-17: refactor + fixes merged (PR #2); `macfleet` built and tested with fakes, PR #3 merged; demo GIF added; `--parallel N` and `--log` built and tested with fakes
