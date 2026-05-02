# ⚙️ Bash Process Management — Short Notes

---

## 🔍 What is a Process?
- A running instance of a program, each with a unique **PID**
- Every process (except `init`/`systemd` PID 1) has a **parent process**
- Created via `fork()` → `exec()` → `wait()`

---

## 🔄 Process States
| Symbol | State | Meaning |
|--------|-------|---------|
| R | Running | Executing on CPU |
| S | Sleeping | Waiting for event (can be killed) |
| D | Uninterruptible Sleep | Waiting for I/O (cannot be killed) |
| T | Stopped | Paused by signal (Ctrl+Z) |
| Z | Zombie | Finished, parent hasn't collected exit status |

---

## 👁️ Viewing Processes
```bash
ps aux                  # all processes snapshot
ps -ef --forest         # process tree
ps aux --sort=-%cpu     # sort by CPU
top / htop              # real-time monitor
pgrep -la nginx         # find PID by name
```

---

## 🪪 Process Identifiers
```bash
$$        # current shell PID
$PPID     # parent PID
$!        # last background process PID
$?        # last exit status (0 = success)
kill -0 PID  # check if process exists
```

---

## 🔀 Foreground & Background
```bash
cmd &       # run in background
Ctrl+C      # kill foreground (SIGINT)
Ctrl+Z      # pause foreground (SIGTSTP)
bg %1       # resume job 1 in background
fg %1       # bring job 1 to foreground
jobs -l     # list all jobs with PIDs
disown %1   # detach job from terminal
```

---

## 📶 Signals
| Signal | No. | Meaning |
|--------|-----|---------|
| SIGHUP | 1 | Hangup / reload config |
| SIGINT | 2 | Ctrl+C |
| SIGKILL | 9 | Force kill (can't be caught) |
| SIGTERM | 15 | Polite stop (can be caught) |
| SIGSTOP | 19 | Pause (can't be caught) |
| SIGCONT | 18 | Resume stopped process |

```bash
kill PID          # SIGTERM (polite)
kill -9 PID       # SIGKILL (force)
kill -HUP PID     # reload config
killall nginx     # kill by name
pkill -f "cmd"    # kill by full command
```
> ✅ Always try `SIGTERM` first, then `SIGKILL` if needed.

---

## 🪤 Trapping Signals
```bash
trap 'echo "Caught!"' INT TERM   # run command on signal
trap cleanup EXIT                # always runs on exit
trap - INT                       # reset to default
trap '' INT                      # ignore signal
```

---

## ⚖️ Process Priority (nice)
- Range: **-20** (highest) to **19** (lowest), default = 0
- Only root can set negative values

```bash
nice -n 10 ./script.sh      # start at low priority
sudo nice -n -5 ./script.sh # start at high priority (root)
renice -n 10 -p PID         # change running process
renice -n 5 -u username     # change all user's processes
```

---

## ⏳ wait — Sync Background Processes
```bash
wait              # wait for ALL background jobs
wait $PID         # wait for specific PID
wait %1           # wait for job number 1
wait -n           # wait for any one job (bash 4.3+)
```

---

## 🔒 nohup — Survive Logout
```bash
nohup ./script.sh > out.log 2>&1 &   # immune to SIGHUP
disown %1                             # remove from job table
```

---

## 🔢 ulimit — Resource Limits
```bash
ulimit -a          # show all limits
ulimit -n 65536    # max open files
ulimit -u 100      # max processes (prevents fork bombs)
ulimit -t 30       # max CPU seconds
```

---

## 📊 Monitoring
```bash
vmstat 2           # system stats every 2s
free -h            # memory usage
lsof -p PID        # files opened by process
lsof -i :80        # process on port 80
ss -tlnp           # listening ports + PIDs
```

---

## 🕐 Cron — Recurring Jobs
```
# min  hr  dom  mon  dow  command
  */5  *   *    *    *    /script.sh    # every 5 min
  0    2   *    *    *    /backup.sh    # daily at 2 AM
  @reboot   /start.sh                  # on startup
```
```bash
crontab -e    # edit
crontab -l    # list
crontab -r    # remove
```

---

## 📅 at — One-Time Jobs
```bash
echo "cmd" | at 10:30 AM
echo "cmd" | at now + 1 hour
atq              # list pending jobs
atrm 1           # remove job 1
```

---

## 🧠 Quick Reference
| Task | Command |
|------|---------|
| All processes | `ps aux` |
| Real-time view | `top` / `htop` |
| Kill politely | `kill PID` |
| Force kill | `kill -9 PID` |
| Run in background | `cmd &` |
| Pause process | `Ctrl+Z` |
| Resume background | `bg %1` |
| Run after logout | `nohup cmd &` |
| Schedule recurring | `crontab -e` |
| Schedule once | `echo "cmd" \| at TIME` |