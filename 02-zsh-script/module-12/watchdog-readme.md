# watchdog

A script runner that wraps any Zsh script with automatic error handling, traps, logging, syntax checking, and optional debug tracing.

Built to practice: exit codes, `setopt ERR_EXIT/NO_UNSET/PIPE_FAIL`, traps, `PS4`, `zsh -n/-x`, and structured logging.

---

## Usage

```zsh
chmod +x watchdog.zsh

./watchdog.zsh myscript.zsh              # run with full error handling
./watchdog.zsh --debug myscript.zsh      # run with xtrace debug output
./watchdog.zsh myscript.zsh arg1 arg2   # pass args through
```

---

## What it does

1. **Syntax check** — runs `zsh -n` before executing anything
2. **Executable check** — auto-fixes permissions with `chmod +x` if needed
3. **Logs everything** — to terminal + `/tmp/watchdog_TIMESTAMP.log`
4. **Trap on EXIT** — cleans up temp dir no matter what
5. **Trap on ERR** — decodes the exit code and prints a reason
6. **Trap on INT/TERM** — graceful Ctrl+C handling
7. **Debug mode** — sets a rich `PS4` and enables `XTRACE` for the target script
8. **Summary box** — ✓ / ✗ with exit code + log path

---

## Sample output

```
[INFO]  14:32:01 watchdog started (pid 9821)
[INFO]  14:32:01 running pre-flight checks...
[INFO]  14:32:01 checking syntax: zsh -n deploy.zsh
[INFO]  14:32:01 syntax OK
[INFO]  14:32:01 launching: deploy.zsh
─────────────────────────────────────────────────────
[INFO]  14:32:01 pulling latest code...
[ERROR] 14:32:03 git pull failed — network timeout
─────────────────────────────────────────────────────
[ERROR] 14:32:03 failed at line 42 — exit code: 1
[ERROR] 14:32:03 reason: general error
[INFO]  14:32:03 cleaning up work dir: /tmp/watchdog_abc123

╔══════════════════════════════════════╗
║   ✗  watchdog: FAILED  (code   1)   ║
╚══════════════════════════════════════╝
  log saved to: /tmp/watchdog_20250525_143201.log
```

---

## Zsh concepts practiced

| Concept | Where |
|---|---|
| `setopt ERR_EXIT NO_UNSET PIPE_FAIL` | top of script — safety header |
| Exit code capture + `$?` | `error_handler()`, `run_script()` |
| Exit code meaning (126, 127, 130…) | `error_handler` case block |
| `trap ... EXIT ERR INT TERM` | four traps, each with a job |
| Named function in trap | `cleanup`, `error_handler` instead of inline strings |
| `zsh -n` syntax check | `preflight()` |
| `zsh -x` + custom `PS4` | `run_script()` debug mode |
| `exec > >(tee -a log) 2>&1` | log to file + terminal simultaneously |
| `log_info/warn/error/debug` | structured logging with `>&2` for errors |
| `|| { ...; return N; }` | inline error handling with specific exit codes |