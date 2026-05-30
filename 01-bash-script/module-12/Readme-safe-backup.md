# 📦 Safe Backup Script

A production-grade Bash backup script built around **Module 12 — Error Handling & Debugging** concepts. Every step is validated, every failure is caught, and cleanup always runs — even when things go wrong.

---

## 📌 Module 12 Concepts Used

| Concept | Where Used |
|---------|-----------|
| `set -euo pipefail` | Script header — strict mode |
| `trap EXIT` | Always cleans up temp files on exit |
| `trap ERR` | Catches any failed command, shows line + command |
| Exit status `$?` | Checked after every critical operation |
| `die()` custom error function | Used throughout for clean error exits |
| Error codes (1, 2) | `die "msg" 2` for bad usage |
| `\|\|` operator | `mkdir -p ... \|\| die "..."` |
| `if ! cmd` | Input validation checks |
| `$BASH_COMMAND` | ERR trap shows exactly which command failed |
| `$LINENO` | ERR trap shows exact line number |
| `PS4` variable | Custom debug trace prefix |
| `bash -x` via `--debug` | Full trace mode flag |
| `set -x` toggled by `DEBUG=true` | Enabled at runtime |
| Structured logging | `log_info`, `log_warn`, `log_error` functions |
| Input validation | File, directory, integer, tool checks |
| Defensive coding | Atomic write, quoted vars, temp file safety |

---

## ✨ Features

- ✅ **Strict mode** — `set -euo pipefail` catches all silent failures
- ✅ **Atomic write** — writes to temp file first, moves only on success
- ✅ **Archive verification** — tests integrity before finalizing
- ✅ **Auto retry** — retries archive creation N times on failure
- ✅ **Log rotation** — keeps only the last N backups automatically
- ✅ **Disk space check** — validates free space before starting
- ✅ **Dry-run mode** — preview what would happen without writing
- ✅ **Debug mode** — full `bash -x` trace with custom `PS4`
- ✅ **Colored logging** — INFO / WARN / ERROR / DEBUG levels
- ✅ **Error box** — shows file, line, command, exit code on failure
- ✅ **Input validation** — validates source, destination, tools, types

---

## 📁 Project Structure

```
safe-backup/
├── safe_backup.sh       # main script
├── README.md            # this file
└── /tmp/safe_backup.log # auto-created log file
```

---

## 🚀 Getting Started

### 1. Make executable
```bash
chmod +x safe_backup.sh
```

### 2. Run with defaults (backs up $HOME)
```bash
./safe_backup.sh
```

### 3. Specify source and destination
```bash
./safe_backup.sh -s /etc -d /backup
```

---

## 🛠️ Usage

```bash
./safe_backup.sh [OPTIONS]
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `-s PATH` | `$HOME` | Source path to back up |
| `-d PATH` | `/tmp/safe_backups` | Destination directory |
| `-n N` | `5` | Max number of backups to keep |
| `-r N` | `3` | Retry count on failure |
| `-l FILE` | `/tmp/safe_backup.log` | Log file path |
| `--dry-run` | false | Preview without writing anything |
| `--debug` | false | Enable full `bash -x` trace |
| `-h` | — | Show help |

### Environment Variables

```bash
BACKUP_SRC=/var/www BACKUP_DST=/mnt/nas ./safe_backup.sh
DRY_RUN=true ./safe_backup.sh -s /etc
DEBUG=true ./safe_backup.sh -s /home 2>trace.log
```

---

## 📊 Example Output

```
[2025-05-02 10:00:00] [INFO ] ════════════════════════════════════════
[2025-05-02 10:00:00] [INFO ]  Safe Backup Script starting
[2025-05-02 10:00:00] [INFO ]  Source : /home/user
[2025-05-02 10:00:00] [INFO ]  Dest   : /tmp/safe_backups
[2025-05-02 10:00:01] [INFO ] Validation passed ✅
[2025-05-02 10:00:01] [INFO ] Disk space OK (available: 42GB)
[2025-05-02 10:00:01] [INFO ] Creating archive (attempt 1/3)...
[2025-05-02 10:00:04] [INFO ] Archive verified ✅ | 1423 files | size: 38M
[2025-05-02 10:00:05] [DONE ] Backup saved: backup_user_20250502_100005.tar.gz
[2025-05-02 10:00:05] [INFO ] Rotating old backups (keeping last 5)...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📦 BACKUP SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Source       : /home/user
  Destination  : /tmp/safe_backups
  Archive      : backup_user_20250502_100005.tar.gz
  Size         : 38M
  Total stored : 3 / 5
  Log          : /tmp/safe_backup.log
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### On Failure
```
╔══════════════════════════════════════╗
║         ❌  BACKUP FAILED            ║
╠══════════════════════════════════════╣
║  Script  : safe_backup.sh
║  Line    : 187
║  Command : tar --create --gzip ...
║  Code    : 1
╚══════════════════════════════════════╝
```

---

## 🔁 Automate with Cron

```bash
crontab -e
```

Add:
```
# Daily at 2 AM
0 2 * * * /path/to/safe_backup.sh -s /home -d /backup -n 7 >> /tmp/cron_backup.log 2>&1
```

---

## 🧪 Dry Run

```bash
./safe_backup.sh -s /etc -d /backup --dry-run
```

---

## 🐛 Debug Mode

```bash
./safe_backup.sh --debug 2>trace.log
cat trace.log
```

Custom `PS4` output:
```
+(safe_backup.sh:187): create_archive(): tar --create --gzip ...
```

---

## 💡 How It Works

```
start
  │
  ├── parse_args()        → flags and env vars
  ├── validate_inputs()   → source, dest, tools, types
  ├── check_disk_space()  → enough space for archive?
  ├── create_archive()    → tar to TEMP file (with retry)
  ├── verify_archive()    → tar -tzf integrity check
  ├── finalize_archive()  → atomic mv temp → final name
  ├── rotate_backups()    → delete oldest beyond MAX
  └── print_summary()     → show results
         │
         └── EXIT trap always runs:
               - delete temp file if still present
               - log total time and exit code
```

---

## 📋 Requirements

- Bash 4.0+
- `tar`, `gzip`, `du`, `df`, `stat`, `date`
- No external dependencies

---

## 🧠 Learning Outcomes

After building this project you will understand:
- Why `set -euo pipefail` is the first line of every production script
- How `trap EXIT` guarantees cleanup even when scripts crash
- How `trap ERR` with `$LINENO` and `$BASH_COMMAND` pinpoints failures
- Why atomic writes (temp → final) prevent file corruption
- How to build reusable `die()` and `log_*()` functions
- How `--dry-run` and `--debug` flags make scripts testable and safe

---
