<div align="center">

# 🍅 pomodoro.zsh

**A lightweight, distraction-free focus timer for your terminal.**

![Shell](https://img.shields.io/badge/Shell-Zsh-informational?style=flat&logo=gnu-bash&logoColor=white&color=2bbc8a)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue?style=flat)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat)
![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat)

<br/>

> No apps. No subscriptions. No browser tabs.  
> Just you, your terminal, and a timer.

<br/>

![Demo](https://raw.githubusercontent.com/yourusername/pomodoro.zsh/main/demo.gif)

> ☝️ Replace this with your own screen recording — try [ttyrec](https://github.com/ovh/ttyrec) + [ttygif](https://github.com/icholy/ttygif) or [asciinema](https://asciinema.org/)

</div>

---

## 📌 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Demo](#-demo)
- [Installation](#-installation)
- [Usage](#-usage)
- [How It Works](#-how-it-works)
- [Zsh Concepts Used](#-zsh-concepts-used)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## 📖 About

`pomodoro.zsh` is a terminal-based [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique) timer written in pure Zsh — no dependencies, no installs beyond Zsh itself.

Built as part of a **Zsh mini-projects series** to learn shell scripting by solving real, everyday problems.

---

## ✨ Features

- ⏱️ Live countdown that updates in-place (no scroll spam)
- 🔔 Desktop notifications on macOS & Linux
- 🔁 Loops automatically — asks after each session if you want to continue
- 📊 Tracks total sessions completed
- ⚙️ Fully customizable work & break durations via CLI args
- 🎨 Color-coded terminal output for work / break phases
- 🛑 Clean `Ctrl+C` exit with session summary

---

## 🎬 Demo

```
  Pomodoro Timer
  Work: 25m  |  Break: 5m
  ─────────────────────────────

  Session 1 starting — focus for 25 minutes
  Press Ctrl+C to stop anytime

  Work  →  24:37  ██████░░░░░░░░░░░░░░

  Break time — 5 minutes

  Break  →  04:12  ████████████████░░░░

  Session complete! Total sessions: 1

  Keep going? [y/n]: y
```

---

## 🚀 Installation

**Clone the repo**

```zsh
git clone https://github.com/yourusername/pomodoro.zsh.git
cd pomodoro.zsh
```

**Make it executable**

```zsh
chmod +x pomodoro.zsh
```

**Optional — use it from anywhere**

```zsh
cp pomodoro.zsh /usr/local/bin/pomodoro
# then just run: pomodoro
```

### Prerequisites

| Tool | Required | Notes |
|---|---|---|
| `zsh` | ✅ Yes | v5.0+ recommended |
| `notify-send` | ❌ Optional | Linux desktop notifications |
| `osascript` | ❌ Optional | macOS notifications (built-in) |

> If neither notification tool is found, the script falls back to a terminal bell `\a`.

---

## 🧑‍💻 Usage

```zsh
# Default: 25 min work, 5 min break
./pomodoro.zsh

# Custom work and break times
./pomodoro.zsh [work_minutes] [break_minutes]

# Examples
./pomodoro.zsh 45 10     # deep work session
./pomodoro.zsh 50 15     # extended focus
./pomodoro.zsh 15 3      # quick burst mode
```

### Controls

| Key | Action |
|---|---|
| `Ctrl+C` | Stop timer, show session summary |
| `y` | Continue to next session |
| `n` | Exit after current session |

---

## ⚙️ How It Works

```
┌─────────────────────────────────────────────┐
│                  START                       │
│                    ↓                         │
│         countdown(WORK minutes)              │
│                    ↓                         │
│         🔔 Notify: "Take a break!"           │
│                    ↓                         │
│         countdown(BREAK minutes)             │
│                    ↓                         │
│         🔔 Notify: "Back to work!"           │
│                    ↓                         │
│         SESSION++  →  Ask to continue?       │
│           yes ↙           ↘ no              │
│          loop              EXIT              │
└─────────────────────────────────────────────┘
```

The `countdown()` function uses `\r` to overwrite the same terminal line every second — no screen clutter.

Notifications are checked in priority order:
1. `notify-send` → Linux
2. `osascript` → macOS
3. Terminal bell `\a` → fallback

---

## 🧠 Zsh Concepts Used

This project was built specifically to practice core Zsh scripting concepts:

| Concept | Used For |
|---|---|
| `(( ))` arithmetic | Countdown math, session counter |
| `$(( ))` substitution | Converting seconds → mm:ss |
| `%02d` printf formatting | Zero-padded time display |
| `trap INT` | Clean Ctrl+C handling |
| `command -v` | Checking notification tool availability |
| `&>/dev/null` | Silencing command output |
| Functions | `countdown()`, `notify()`, `run_session()` |
| `while true` loop | Session looping |
| `[[ ]]` conditionals | Answer checking, tool detection |
| ANSI color codes | Color-coded terminal output |

---

## 📁 Project Structure

```
pomodoro.zsh/
├── pomodoro.zsh      # main script
├── README.md         # this file
└── demo.gif          # terminal demo recording
```

---

