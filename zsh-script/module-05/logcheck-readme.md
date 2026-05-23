<div align="center">

# 📋 logcheck.zsh

**A terminal log analyzer — parse, search, and summarize any log file without leaving your shell.**

![Shell](https://img.shields.io/badge/Shell-Zsh-informational?style=flat&logo=gnu-bash&logoColor=white&color=2bbc8a)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue?style=flat)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat)
![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat)

<br/>

> No `grep | awk | sort | uniq -c` pipelines to remember.  
> Just run `logcheck.zsh` and get instant insights from any log file.

<br/>

![Demo](https://raw.githubusercontent.com/yourusername/logcheck.zsh/main/demo.gif)

> ☝️ Record your own with [asciinema](https://asciinema.org/) and drop it here as `demo.gif`

</div>

---

## 📌 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Demo](#-demo)
- [Installation](#-installation)
- [Usage](#-usage)
- [What It Does](#-what-it-does)
- [How It Works](#-how-it-works)
- [Zsh Concepts Used](#-zsh-concepts-used)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## 📖 About

`logcheck.zsh` is an interactive log file analyzer written in pure Zsh. Feed it any log file — server logs, system logs, application logs — and get a clean summary, error extraction, keyword search, and hourly activity breakdown from an interactive terminal menu.

Built as part of a **Zsh mini-projects series** to practice every type of loop in a real, practical script.

---

## ✨ Features

- 📊 **Summary stats** — total lines, error/warning/info/debug counts
- 🔴 **Error lines** — extract and list all ERROR entries (first 10 shown)
- 🔁 **Top repeated messages** — find the most common log entries
- ⏰ **Activity by hour** — bar chart of log activity per hour
- 🔍 **Keyword search** — search any word or phrase across all lines
- 🎭 **Demo mode** — auto-generates a fake log if no file is given
- 🎨 Color-coded output — ✔ green, ⚠ yellow, ✘ red
- 🔁 Interactive menu — stays open until you exit

---

## 🎬 Demo

```
  ┌──────────────────────────┐
  │     logcheck.zsh         │
  │  /var/log/syslog
  └──────────────────────────┘
  1) Summary stats
  2) Show error lines
  3) Top repeated messages
  4) Activity by hour
  5) Search keyword
  6) Exit

  Choose [1-6]: 1

  Summary
  -------
  File     : /var/log/syslog
  Lines    : 1452
  ✔  INFO     : 987
  ⚠  WARNING  : 213
  ✘  ERROR    : 87
     DEBUG    : 165

  Choose [1-6]: 4

  Activity by Hour
  ----------------
  08:00  ████████████          48
  09:00  ████████████████████  81
  10:00  ██████████████        60
  11:00  ██████████████████    72
```

---

## 🚀 Installation

```zsh
git clone https://github.com/yourusername/logcheck.zsh.git
cd logcheck.zsh
chmod +x logcheck.zsh
```

**Optional — use it from anywhere:**

```zsh
cp logcheck.zsh /usr/local/bin/logcheck
# then just run: logcheck /var/log/syslog
```

### Prerequisites

| Tool | Required | Notes |
|---|---|---|
| `zsh` | ✅ Yes | v5.0+ |
| `mktemp` | ✅ Yes | Standard on macOS & Linux |

No external dependencies. No package installs.

---

## 🧑‍💻 Usage

```zsh
# Analyze a specific log file
./logcheck.zsh /var/log/syslog
./logcheck.zsh /var/log/nginx/access.log
./logcheck.zsh ./myapp.log

# No file? Demo mode auto-generates a fake log
./logcheck.zsh
```

### Menu Options

| Option | What It Does |
|---|---|
| `1` | Summary — line count + level breakdown |
| `2` | All ERROR lines (first 10) |
| `3` | Top 5 most repeated messages |
| `4` | Activity bar chart grouped by hour |
| `5` | Search any keyword — shows every matching line |
| `6` | Exit |

---

## ⚙️ What It Does

### 📊 Summary Stats
Counts total lines and breaks them down by log level (ERROR, WARNING, INFO, DEBUG). Uses a `while` loop to read every line exactly once.

### 🔴 Error Lines
Scans the file line by line, skips non-ERROR lines with `continue`, prints up to 10 errors, then `break`s.

### 🔁 Top Repeated Messages
Strips timestamps and counts each unique message using an associative array. Sorts the top 5 using a nested `for` loop with bubble sort.

### ⏰ Activity by Hour
Extracts the hour from each timestamp using `=~` regex, counts hits per hour, and draws a `repeat`-based bar chart inline.

### 🔍 Keyword Search
Loops every line, skips non-matching lines with `continue`, and prints all matches with a running count.

---

## ⚙️ How It Works

```
┌───────────────────────────────────────────────┐
│  Startup                                       │
│    → file given? validate it                   │
│    → no file? generate demo log with for loop  │
│                    ↓                           │
│  Menu (while true loop)                        │
│    → user picks option                         │
│    → case routes to function                   │
│    → function reads file with while IFS= read  │
│    → results printed with color                │
│    → loop back to menu                         │
│                    ↓                           │
│  Exit on option 6 or Ctrl+C                    │
└───────────────────────────────────────────────┘
```

Every analyzer function uses the same safe pattern:
```zsh
while IFS= read -r line; do
    [[ $line != *PATTERN* ]] && continue
    # process matching line
done < "$file"
```
This avoids subshell scope issues — variable changes made inside the loop persist after it ends.

---

## 🧠 Zsh Concepts Used

This project was built specifically to practice every loop type from the notes:

| Concept | Where Used |
|---|---|
| `while IFS= read -r` | All file-reading functions — safe line-by-line |
| `for i in ${(kv)assoc}` | Iterating associative array in top-messages |
| `for (( i=1; i<n; i++ ))` | Bubble sort nested loop in top-messages |
| `for i in {1..50}` | Demo log generation |
| `repeat N` | Drawing bar chart blocks in hourly view |
| `while true` | Main interactive menu loop |
| `break` | Stop after 10 errors in error viewer |
| `continue` | Skip non-matching lines in all filters |
| `< <(cmd)` process substitution | Safe command output looping |
| `typeset -A` associative array | Message frequency counter |
| `(( count++ ))` | Running counters inside loops |
| `case` statement | Menu routing |
| `=~` regex with `$match[]` | Hour extraction from timestamps |

---

## 📁 Project Structure

```
logcheck.zsh/
├── logcheck.zsh      # main script
├── README.md         # this file
└── demo.gif          # terminal recording (add your own)
```

---

## 🤝 Contributing

Ideas welcome! Some things that would be great to add:

- Export report to `.txt` or `.csv`
- Filter by date range
- Watch mode — tail a live log file
- IP address frequency analysis for access logs

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-idea`
3. Commit: `git commit -m "add: your feature"`
4. Push: `git push origin feature/your-idea`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Made with 📋 and Zsh  
⭐ Star this repo if it saved you from drowning in logs!

</div>