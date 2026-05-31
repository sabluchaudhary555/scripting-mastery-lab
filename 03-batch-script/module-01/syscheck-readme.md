# syscheck 🖥️

> Instant Windows system snapshot — one command, one screen, everything useful.
> No install. No admin required for most checks.

---

## Why this exists

You RDP into a server. You sit down at an unfamiliar machine. You start
troubleshooting something. The first thing you always do is the same:
what OS, what IPs, how much disk, what's running, who's logged in.

`syscheck` does all of that in 2 seconds instead of 5 minutes.

---

## At a Glance

| Section | What it shows |
|---|---|
| OS & Hardware | Windows version, architecture, RAM, CPU, last boot time |
| Network | IP addresses, gateway, DNS, internet reachability |
| Disk Usage | Size, free space, used % — flags drives over 85% full |
| Top Processes | Top 10 processes by memory usage |
| Users | Logged-in sessions, current user details |
| Admin (elevated) | Open ports, scheduled tasks, startup registry keys |

---

## Install

No installer needed.

```bat
:: copy to System32 to use from anywhere
copy syscheck.bat C:\Windows\System32\syscheck.bat

:: or just run from its folder
syscheck.bat
```

---

## Usage

```
syscheck              run all sections
syscheck net          network info only
syscheck disk         disk usage only
syscheck users        logged-in user info
syscheck admin        full check (run as Administrator for extra sections)
```

---

## Output

### Full run

```
C:\> syscheck

 ┌────────────────────────────────────────────────────┐
 │            syscheck v1.0 — system snapshot         │
 └────────────────────────────────────────────────────┘
  machine  : DESKTOP-A3F7K2
  user     : Alice
  time     : Wed 05/28/2026  09:14:33
  admin    : 0 (1=yes 0=no)
  path     : C:\Users\Alice
```

### OS & Hardware

```
 ══ OS & HARDWARE ═══════════════════════════════════════
  OS       : Microsoft Windows 11 Pro
  Arch     : 64-bit
  Last boot: 2026-05-27 22:05
  RAM      : 16 GB
  CPU      : Intel(R) Core(TM) i7-10700 CPU @ 2.90GHz
```

### Network

```
 ══ NETWORK ═══════════════════════════════════════════════
  IP addresses:
     IPv4 Address. . . : 192.168.1.42
  Default gateway:
     Default Gateway . : 192.168.1.1
  DNS:
     DNS Servers . . . : 8.8.8.8
  Internet : reachable
  Hostname : DESKTOP-A3F7K2
```

### Disk Usage

```
 ══ DISK USAGE ════════════════════════════════════════════
  Drive  Size        Free        Used%
  ─────────────────────────────────────────
   C:     476 GB      120 GB free    74%
   D:     931 GB      450 GB free    51%
```

If a drive is over 85% full:

```
  [!] C:     476 GB      18 GB free    96%  <-- low
```

### Top Processes

```
 ══ TOP PROCESSES (by memory) ════════════════════════════
  PID      Mem(KB)    Name
  ─────────────────────────────────────────
  8432     512,044    chrome.exe
  4120     234,880    Code.exe
  1204     198,332    explorer.exe
  9872     145,660    node.exe
  3344     98,224     WindowsTerminal.exe
```

### Users

```
 ══ USERS ══════════════════════════════════════════════════
  Currently logged in:
     Alice            console          1  Active

  Current user  : Alice
  User profile  : C:\Users\Alice
  Computer      : DESKTOP-A3F7K2
```

### Admin mode (elevated)

```
 ══ ADMIN CHECKS (elevated) ═══════════════════════════════
  Listening ports (local):
     TCP    0.0.0.0:80       0.0.0.0:0    LISTENING
     TCP    0.0.0.0:443      0.0.0.0:0    LISTENING
     TCP    0.0.0.0:3306     0.0.0.0:0    LISTENING

  Active scheduled tasks (first 5):
     \Microsoft\Windows\UpdateOrchestrator\Schedule Scan
     \Adobe Acrobat Update Task
     \GoogleUpdateTaskMachineUA

  Startup items (HKCU run):
     OneDrive    REG_SZ    C:\...Microsoft OneDrive\OneDrive.exe
     Slack       REG_SZ    C:\...\slack.exe --process-start-args
```

---

## Examples

```bat
:: quick check on any machine you sit down at
syscheck

:: just check the network when troubleshooting
syscheck net

:: check if a disk is getting full
syscheck disk

:: see open ports on a server (needs admin)
syscheck admin

:: redirect full report to a file for later
syscheck > C:\report.txt
```

---

## CMD Intro Concepts Used

| Concept | Where it shows up |
|---|---|
| `cmd.exe` / `where cmd` | The script is a `.bat` file — runs inside `cmd.exe` |
| `title` command | Sets title bar to `System Check — COMPUTERNAME` on launch |
| `color 0A` | Sets green-on-black terminal theme when script starts |
| `%CD%` | Displayed in the header — shows working directory |
| `%COMPUTERNAME%` `%USERNAME%` `%USERPROFILE%` | Built-in variables used throughout output |
| `%DATE%` `%TIME%` | Printed in the header as the snapshot timestamp |
| Drive letters | Disk section loops through all lettered drives with `wmic` |
| Absolute vs relative paths | `%TEMP%\ips.tmp` uses absolute temp path to avoid ambiguity |
| Admin vs normal user | `net session` detects elevation — unlocks extra sections |
| `whoami /groups` pattern | Same principle used via `net session >nul 2>&1` |
| CMD vs PowerShell note | `wmic` + `for /f` used instead of PS — works even when PS is restricted |
| Command syntax `cmd /switch arg` | Every section uses switches: `ping -n 1`, `tasklist /fo`, `netstat -an` |
| `/?` help pattern | All commands in the script have `/?` equivalents: `ipconfig /?` etc. |
| `& \|\| &&` chaining | Used to handle missing output gracefully without crashing |
| Quoting paths with spaces | `%TEMP%\ips.tmp` and `%USERPROFILE%` always quoted in practice |
| `goto` + labels dispatch | `syscheck net` / `disk` / `users` jumps to the right label |
| `>nul 2>&1` | Error suppression used on every command that might fail silently |
| `findstr` | Filters `ipconfig` and `netstat` output to extract useful lines |

---

## File Structure

```
cmd-intro/
├── notes/
│   └── cmd-intro-notes.md    ← quick reference for all intro CMD concepts
└── project/
    ├── syscheck.bat           ← the script
    └── README.md              ← this file
```

---

## Requirements

- Windows 7 or newer
- No admin required for: OS info, network, disk, processes, users
- Admin required for: open ports, scheduled tasks, startup registry keys
- `wmic` must be available (present on all Windows versions before Win11 22H2)

---

> **Tip:** Run `syscheck > report.txt` to save a snapshot to a file.
> Useful before making changes to a system — you have a baseline to compare against.

---

## License

MIT