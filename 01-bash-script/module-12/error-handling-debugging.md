# 🐛 Bash Error Handling & Debugging — Short Notes

---

## ⚠️ Why It Matters
Without error handling, Bash runs even after failures — silently causing damage.
> **Golden Rule:** Never assume a command succeeded.

---

## 📤 Exit Status (`$?`)
- `0` = success | non-zero = failure
- Read `$?` **immediately** after command — any next command overwrites it

```bash
ls /etc; echo $?         # 0
ls /nope 2>/dev/null; echo $?  # 2

# Save it fast
cmd; status=$?
```

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Bad usage |
| 126 | Not executable |
| 127 | Command not found |
| 128+N | Killed by signal N |

```bash
# Pipe exit statuses
ls /nope | grep x
echo "${PIPESTATUS[@]}"   # all stages: "2 1"
```

---

## 🛡️ `set` Safety Options

```bash
set -euo pipefail    # ← golden combo (use in every script)
IFS=$'\n\t'          # safe word splitting
```

| Option | Meaning |
|--------|---------|
| `-e` | Exit on any error |
| `-u` | Error on undefined variable |
| `-o pipefail` | Fail if any pipe stage fails |
| `-x` | Debug: print each command |
| `-n` | Dry run: syntax check only |
| `-v` | Verbose: print lines as read |

```bash
set +x   # disable debug
set -x   # enable debug
```

---

## 🔀 Error Handling Patterns

```bash
cmd || exit 1                        # die on failure
cmd || { echo "error"; exit 1; }    # die with message
if ! cmd; then echo "failed"; fi    # explicit check
mkdir dir && echo "done"            # run only on success
```

---

## 🔧 Custom Error Functions

```bash
die() { echo "❌ ERROR: $1" >&2; exit "${2:-1}"; }

# Usage
[[ -f "file.txt" ]] || die "file not found"
cd /backup         || die "cannot cd" 2
```

---

## 🪤 `trap` — Cleanup & Error Catching

```bash
trap 'cleanup'       EXIT   # always runs on exit
trap 'handler $LINENO' ERR  # runs on any error
trap 'on_int'        INT    # Ctrl+C
trap 'reload'        HUP    # reload signal
trap -               INT    # reset to default
trap ''              INT    # ignore signal
```

**EXIT trap example:**
```bash
tmpfile=$(mktemp)
cleanup() { rm -f "$tmpfile"; }
trap cleanup EXIT   # runs even if script crashes
```

**ERR trap example:**
```bash
on_error() { echo "Failed at line $1 | cmd: $BASH_COMMAND"; }
trap 'on_error $LINENO' ERR
```

---

## ✅ Input Validation

```bash
[[ $# -lt 2 ]]       && { echo "Usage: $0 src dst"; exit 2; }
[[ -f "$1" ]]        || die "File not found: $1"
[[ -r "$1" ]]        || die "File not readable: $1"
[[ -w "$2" ]]        || die "Dest not writable: $2"
[[ $EUID -eq 0 ]]    || die "Need root"
[[ "$n" =~ ^[0-9]+$ ]] || die "Must be a number"
command -v curl      || die "curl not installed"
```

---

## 📝 Logging

```bash
log_info()  { echo "[INFO]  $(date '+%H:%M:%S') $1" | tee -a "$LOG"; }
log_warn()  { echo "[WARN]  $(date '+%H:%M:%S') $1" >&2; }
log_error() { echo "[ERROR] $(date '+%H:%M:%S') $1" >&2; }
log_debug() { [[ "${DEBUG:-false}" == "true" ]] && echo "[DEBUG] $1"; }

# Run with debug:   DEBUG=true ./script.sh
# Run silent:       LOG_LEVEL=0 ./script.sh
```

---

## 🔍 Debug Mode (`set -x`)

```bash
set -x      # print every command before running
set +x      # stop printing

# Output:
# + name=Hacker
# + echo 'Hello Hacker'
```

---

## 🖥️ `bash -x` and `bash -n`

```bash
bash -n script.sh          # syntax check (no execution)
bash -x script.sh          # trace execution
bash -xv script.sh         # trace + verbose
bash -x script.sh 2>debug.log   # save trace to file
```

---

## 🏷️ `PS4` — Custom Debug Prompt

```bash
# Default: +
# Custom: shows file, line, function
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x
```

---

## 🎯 Selective Debugging

```bash
# Debug only one section
set -x
process_data
set +x

# Debug via env variable
[[ "${DEBUG:-false}" == "true" ]] && set -x
```

---

## 🔬 ShellCheck

```bash
shellcheck script.sh         # check script
shellcheck *.sh              # check all
shellcheck -S error          # errors only
shellcheck -e SC2086         # ignore one warning
# shellcheck disable=SC2086  # inline ignore
```

**Common warnings:**
| Code | Issue |
|------|-------|
| SC2086 | Unquoted variable |
| SC2164 | `cd` without error check |
| SC2155 | `local var=$(cmd)` masks exit status |
| SC2006 | Backtick usage — use `$()` |

---

## 🐞 Top 5 Common Bugs

```bash
# 1. Unquoted variable
rm $file          # ❌  →  rm "$file"  ✅

# 2. cd without check
cd /wrong; rm -rf *     # ❌  →  cd /path || exit 1  ✅

# 3. Pipe subshell loses variable
cat f | while read l; do (( count++ )); done   # ❌ count stays 0
while read l; do (( count++ )); done < f       # ✅

# 4. local masks exit status
local x=$(false_cmd)   # ❌  →  local x; x=$(false_cmd)  ✅

# 5. Empty glob
for f in *.txt; do ...   # ❌ runs with "*.txt" if no files
shopt -s nullglob        # ✅ returns empty
```

---

## 🧠 Quick Reference

| Task | Command |
|------|---------|
| Safe script header | `set -euo pipefail` |
| Always clean up | `trap cleanup EXIT` |
| Catch errors | `trap 'handler $LINENO' ERR` |
| Syntax check | `bash -n script.sh` |
| Trace execution | `bash -x script.sh` |
| Custom debug prompt | `export PS4='...'` |
| Static analysis | `shellcheck script.sh` |
| Debug toggle | `DEBUG=true ./script.sh` |
| Die with message | `cmd \|\| die "msg"` |
| Validate file | `[[ -f "$f" ]] \|\| die "..."` |