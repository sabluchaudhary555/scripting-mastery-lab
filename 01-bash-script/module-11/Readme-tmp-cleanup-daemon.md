# 🧹 Temp File Cleanup Daemon

A lightweight Bash daemon that **automatically deletes old temporary files** on a schedule — runs silently in the background, survives terminal logout, and responds to signals for control.

---

## 📌 Topics Covered

| Topic | Usage in This Project |
|-------|----------------------|
| Daemon Process | Runs as a background service with PID file |
| `trap` | Handles EXIT, SIGTERM, SIGINT, SIGHUP, SIGUSR1 |
| `nohup` / `disown` | Survives terminal logout |
| Signals | SIGHUP = reload, SIGUSR1 = stats, SIGTERM = stop |
| `kill` | Graceful stop via SIGTERM |
| Job Control | Background execution with `&` |
| `ulimit` | Can be combined to limit resource usage |
| Cron | Optional: schedule via `@reboot` or `*/5 * * * *` |
| Process Identifiers | `$$`, `$PIDFILE`, `kill -0` to check existence |
| `wait` | Waits for subprocesses in cleanup cycles |

---

## 📁 Project Structure

```
tmp_cleanup_daemon/
├── tmp_cleanup_daemon.sh   # main daemon script
├── README.md               # this file
└── tmp_cleanup_daemon.log  # auto-created on first run
```

---

## 🚀 Getting Started

### 1. Clone / Download
```bash
git clone https://github.com/yourname/tmp-cleanup-daemon.git
cd tmp-cleanup-daemon
```

### 2. Make executable
```bash
chmod +x tmp_cleanup_daemon.sh
```

### 3. Start the daemon
```bash
# Start with defaults
./tmp_cleanup_daemon.sh start

# Preview what would be deleted (dry run)
./tmp_cleanup_daemon.sh start --dry-run

# Custom age and interval
./tmp_cleanup_daemon.sh start --age 30 --interval 120
```

---

## 🛠️ Usage

```bash
./tmp_cleanup_daemon.sh [ACTION] [OPTIONS]
```

### Actions

| Action | Description |
|--------|-------------|
| `start` | Start the daemon in the background |
| `stop` | Gracefully stop the running daemon |
| `status` | Show if daemon is running + print stats |
| `run-once` | Run a single cleanup cycle and exit |

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--dry-run` | false | Preview deletions without removing |
| `--age N` | 60 | Delete files older than N minutes |
| `--interval N` | 300 | Check every N seconds |
| `--log FILE` | `/tmp/...log` | Custom log file path |

---

## 📡 Signal Control

Once the daemon is running, you can control it with signals:

```bash
# Get the PID
cat /tmp/tmp_cleanup_daemon.pid

# Stop gracefully
kill -TERM $(cat /tmp/tmp_cleanup_daemon.pid)

# Print live stats to log
kill -USR1 $(cat /tmp/tmp_cleanup_daemon.pid)

# Reload config (SIGHUP)
kill -HUP $(cat /tmp/tmp_cleanup_daemon.pid)
```

---

## 🔁 Auto-start with Cron

To start the daemon automatically at boot:

```bash
crontab -e
```

Add:
```
@reboot /full/path/to/tmp_cleanup_daemon.sh start --age 60 >> /tmp/cleanup_boot.log 2>&1
```

Or run every hour as a one-shot (no daemon needed):
```
0 * * * * /full/path/to/tmp_cleanup_daemon.sh run-once >> /tmp/cleanup_cron.log 2>&1
```

---

## 📊 Sample Log Output

```
2025-05-02 10:00:00 [INFO] Daemon started PID: 4321
2025-05-02 10:00:00 [INFO] --- Cleanup cycle started ---
2025-05-02 10:00:01 [DELETE] /tmp/tmpXk92a1
2025-05-02 10:00:01 [DELETE] /tmp/sess_abc123
2025-05-02 10:00:01 [INFO] [/tmp] scanned=45 deleted=12 failed=0
2025-05-02 10:00:01 [INFO] --- Cleanup cycle complete ---
2025-05-02 10:00:01 [INFO] Next cycle in 300s — sleeping...
```

---

## ⚙️ Configuration (edit inside script)

```bash
WATCH_DIRS=("/tmp" "/var/tmp" "${HOME}/.cache/tmp")
MAX_AGE_MINUTES=60
CHECK_INTERVAL=300
DRY_RUN=false
```

---

## 💡 How It Works

```
start
  │
  ├─ check PID file → already running? exit
  ├─ write PID to /tmp/tmp_cleanup_daemon.pid
  ├─ register traps (EXIT, INT, TERM, HUP, USR1)
  │
  └─ loop forever:
       ├─ for each WATCH_DIR:
       │    └─ find files older than MAX_AGE_MINUTES → delete
       └─ sleep CHECK_INTERVAL seconds
```

---

## 📋 Requirements

- Bash 4.0+
- Standard Unix tools: `find`, `rm`, `kill`, `date`
- No external dependencies

---

## 🧠 Learning Outcomes

After building this project you will understand:
- How real Linux daemons work (PID files, signal handling, logging)
- How to use `trap` for graceful shutdown and reload
- How cron and `nohup` keep processes alive
- How `kill` signals communicate between processes

---

