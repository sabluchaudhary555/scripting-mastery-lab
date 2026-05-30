<div align="center">

# ⚙️ procwatch.zsh

**A terminal process manager — monitor, find, kill, and control processes without memorizing commands.**

![Shell](https://img.shields.io/badge/Shell-Zsh-informational?style=flat&logo=gnu-bash&logoColor=white&color=2bbc8a)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue?style=flat)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat)
![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat)

<br/>

> `ps aux | grep ...` — never again.  
> Just run `procwatch.zsh` and manage your processes interactively.

</div>

---

## 📌 Table of Contents
- [About](#-about) · [Features](#-features) · [Installation](#-installation) · [Usage](#-usage) · [How It Works](#-how-it-works) · [Zsh Concepts](#-zsh-concepts-used) · [Contributing](#-contributing) · [License](#-license)

---

## 📖 About

`procwatch.zsh` is an interactive terminal process manager. It wraps the most useful process management commands — `ps`, `pgrep`, `kill`, `pkill`, `nice`, `nohup`, `jobs`, `disown` — into a clean, menu-driven interface.

Built to practice **Module 11: Process Management**.

---

## ✨ Features

- 📊 **Snapshot** — top 10 processes by CPU and memory
- 🔍 **Find process** — search by name, see PID + CPU + MEM
- 💀 **Kill process** — choose SIGTERM / SIGKILL / SIGHUP by name or PID
- 🔄 **Background runner** — run any command with optional `nohup`
- 🐢 **Nice priority** — run commands at custom CPU priority
- 🎛️ **Job control demo** — `jobs`, `disown`, background `&`
- 📺 **Live monitor** — auto-refreshing process view (5 cycles)
- 🧪 **Subshell demo** — shows `( )` vs `{ }` scope difference live

---

## 🎬 Demo

```
  ┌─────────────────────────────┐
  │       procwatch.zsh         │
  └─────────────────────────────┘

  Choose [1-9]: 2

  Find Process
  ─────────────
  Process name: node

  ✔  Found:
  PID 3821    CPU:2.1%  MEM:1.4%  node server.js
  PID 4102    CPU:0.3%  MEM:0.8%  node watcher.js

  Choose [1-9]: 3

  Kill Process
  ─────────────
  Signals:
    1) SIGTERM (15) — graceful shutdown
    2) SIGKILL  (9) — force kill
    3) SIGHUP   (1) — reload config

  Signal [1-3]: 1
  PID or process name: 3821
  ✔  Sent signal 15 to PID 3821
```

---

## 🚀 Installation

```zsh
git clone https://github.com/yourusername/procwatch.zsh.git
cd procwatch.zsh
chmod +x procwatch.zsh
```

---

## 🧑‍💻 Usage

```zsh
./procwatch.zsh
```

No arguments needed — everything is interactive.

---

## ⚙️ How It Works

| Menu Option | Commands Used |
|---|---|
| Snapshot | `ps aux --sort=-%cpu/-%mem` |
| Find process | `pgrep -a`, `ps -p` |
| Kill process | `kill -sig PID`, `pkill` |
| Background runner | `&`, `nohup`, `$!` |
| Nice priority | `nice -n`, `renice` |
| Job control | `jobs`, `disown`, `&` |
| Live monitor | `ps` in loop + `$pipestatus` |
| Subshell demo | `( )` vs `{ }` live example |

---

## 🧠 Zsh Concepts Used

| Concept | Where |
|---|---|
| `&` background | Background runner, job demo |
| `jobs` / `disown` | Job control demo |
| `pgrep -a` / `pkill` | Find & kill process |
| `kill -SIGTERM/KILL/HUP` | Kill with signal choice |
| `$?` exit code | Kill result checking |
| `$pipestatus` | Live monitor pipeline check |
| `nice -n` / `renice` | Priority runner |
| `nohup` | Survive terminal close |
| `$!` last background PID | Capture PID after `&` |
| `( )` subshell | Subshell demo |
| `{ }` command group | Group demo |
| `trap INT` | Clean Ctrl+C in monitor |
| `ps aux` / `ps -p` | Process snapshot |

---

## 📁 Project Structure

```
procwatch.zsh/
├── procwatch.zsh     # main script
└── README.md         # this file
```

---

