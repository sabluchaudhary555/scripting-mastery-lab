# Zsh — Error Handling & Debugging

Quick notes. Concept → what it does → when to use it.

---

## Exit Status `$?`

Every command returns `0` (success) or non-zero (failure). `$?` holds the last one — capture it immediately or it's gone.

```zsh
ls /tmp        # succeeds
echo $?        # 0

ls /fake       # fails
status=$?      # save it NOW before next command overwrites it
echo $status   # 2
```

**Common codes:**

| Code | Meaning |
|------|---------|
| 0 | success |
| 1 | general error |
| 2 | bad arguments |
| 126 | not executable |
| 127 | command not found |
| 130 | killed by Ctrl+C |

---

## Inline Error Handling

```zsh
# && — run only if previous succeeded
mkdir /tmp/x && cd /tmp/x

# || — run only if previous failed
cd /app || { echo "not found"; exit 1; }

# if — cleanest for real logic
if ! command -v git > /dev/null; then
    echo "git not installed"
    exit 1
fi
```

> `cmd && ok || fail` looks like a ternary but isn't — if `ok` fails, `fail` also runs. Use `if/else` for anything real.

---

## Safety Options (`setopt`)

Zsh's equivalent of bash's `set -euo pipefail`:

```zsh
setopt ERR_EXIT    # exit immediately on any error       (set -e)
setopt NO_UNSET    # error if you use an unset variable  (set -u)
setopt PIPE_FAIL   # pipeline fails if any step fails    (set -o pipefail)
```

**Script header — always start with this:**

```zsh
#!/bin/zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL
```

Handle expected failures without triggering `ERR_EXIT`:

```zsh
grep "x" file.txt || true          # swallow it with || true
if ! grep "x" file.txt; then ...   # or use if (ERR_EXIT ignores if-conditions)
```

---

## Traps

Run code automatically when something happens.

```zsh
trap 'rm -f /tmp/lock'   EXIT   # always runs on exit (cleanup)
trap 'echo "line $LINENO"' ERR  # runs on error
trap 'echo "Ctrl+C"; exit 130'  INT   # runs on Ctrl+C
trap 'cleanup; exit 0'   TERM   # runs on kill
trap 'echo "ZERR hit"'   ZERR   # Zsh-only: fires EVERYWHERE, even inside if/||
```

**Best pattern — use a named function:**

```zsh
cleanup() {
    rm -rf "$TMPDIR"
    rm -f /var/lock/myscript.lock
}

trap cleanup EXIT
trap 'echo "error line $LINENO"; cleanup; exit 1' ERR
trap 'cleanup; exit 130' INT TERM
```

`trap - EXIT` resets. `trap '' INT` ignores a signal.

---

## Signal Reference

| Signal | Fires when | Use for |
|--------|-----------|---------|
| EXIT | any exit | temp file cleanup |
| ERR | command fails (not in if/\|\|/&&) | error logging |
| INT | Ctrl+C | graceful interrupt |
| TERM | `kill` / shutdown | graceful shutdown |
| ZERR | any failure, everywhere (Zsh only) | aggressive debug |

---

## Logging

Errors go to **stderr** (`>&2`). Results go to **stdout**. Keep them separate.

```zsh
log_info()  { echo "[INFO]  $(date '+%H:%M:%S') $*"; }
log_warn()  { echo "[WARN]  $(date '+%H:%M:%S') $*" >&2; }
log_error() { echo "[ERROR] $(date '+%H:%M:%S') $*" >&2; }
log_debug() { [[ "${DEBUG:-0}" == 1 ]] && echo "[DEBUG] $*"; }
```

Log to file + terminal at once:

```zsh
exec > >(tee -a "$LOGFILE") 2>&1
```

---

## Debug Modes

```zsh
zsh -n script.sh    # syntax check — no execution, just parse
zsh -x script.sh    # trace — print every command as it runs (expanded)
```

Inside a script:

```zsh
setopt XTRACE       # start tracing here
# ... suspect code ...
unsetopt XTRACE     # stop

# trace only inside one function:
my_func() {
    setopt LOCAL_OPTIONS XTRACE
    # traced here, reverts on return
}
```

`VERBOSE` vs `XTRACE`:

| | XTRACE `-x` | VERBOSE `-v` |
|---|---|---|
| shows | expanded values | raw source lines |
| best for | "what value did that have?" | "which lines ran?" |

---

## PS4 — Better Trace Output

Default trace prefix is just `+`. Make it useful:

```zsh
export PS4='+%D{%T} %N:%I %_ '
# +14:32:05 script.sh:12 (nesting depth)
```

| Sequence | Meaning |
|----------|---------|
| `%N` | script/function name |
| `%I` | line number |
| `%D{fmt}` | timestamp |
| `%_` | nesting depth |

---

## SOURCE_TRACE (Zsh-only)

Prints every file that gets `source`d — useful for debugging startup speed or plugin load order.

```zsh
zsh -o SOURCE_TRACE myscript.sh
# <sourcetrace> ./lib/utils.zsh:1
# <sourcetrace> ./config.zsh:1

# combine with xtrace for maximum detail:
zsh -x -o SOURCE_TRACE myscript.sh
```

---

## Full Script Template

```zsh
#!/bin/zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

LOGFILE="/tmp/run_$(date +%Y%m%d).log"
exec > >(tee -a "$LOGFILE") 2>&1

log_info()  { echo "[INFO]  $(date '+%H:%M:%S') $*"; }
log_error() { echo "[ERROR] $(date '+%H:%M:%S') $*" >&2; }

TMPDIR_WORK=$(mktemp -d)

cleanup()      { rm -rf "$TMPDIR_WORK"; }
error_handler(){ log_error "failed at line $LINENO"; cleanup; exit 1; }

trap cleanup       EXIT
trap error_handler ERR
trap 'cleanup; exit 130' INT TERM

[[ "${DEBUG:-0}" == 1 ]] && { export PS4='+%D{%T} %N:%I %_ '; setopt XTRACE; }

log_info "started"
# your logic here
log_info "done"
```

---

## Quick Reference

```zsh
# check exit code
echo $?
cmd; status=$?          # save immediately

# safety header
setopt ERR_EXIT NO_UNSET PIPE_FAIL

# traps
trap 'cleanup' EXIT
trap 'handler' ERR
trap 'handler' INT TERM
trap 'handler' ZERR     # fires everywhere (zsh-only)
trap - EXIT             # reset
trap '' INT             # ignore

# debug
zsh -n script.sh        # syntax check
zsh -x script.sh        # trace execution
zsh -o SOURCE_TRACE s.sh  # trace sourced files
setopt XTRACE           # trace from here
setopt LOCAL_OPTIONS XTRACE  # trace only inside function
export PS4='+%N:%I> '  # better trace prefix

# logging
echo "msg" >&2          # stderr
exec > >(tee -a log) 2>&1  # everything to file + terminal
```