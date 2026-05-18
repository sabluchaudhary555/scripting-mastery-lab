# 🐚 Shell Detector

> A Zsh mini project that detects and displays your current shell info, installed shells, system details, and Zsh status — all in a clean, colorful terminal output.

---

## 📌 Project Info

| Field       | Detail                          |
|-------------|----------------------------------|
| Project     | Shell Detector                   |
| Module      | Zsh — Module 01: Intro & Setup   |
| Author      | Hacker (sabluchaudhary555)       |
| GitHub      | github.com/sabluchaudhary555      |
| Site        | SSoft.in                         |
| Language    | Zsh Script                       |
| Level       | Beginner                         |

---

## 🎯 What It Does

Shell Detector is a Zsh script that:

- ✅ Detects your **current shell** (name, path, version)
- ✅ Lists all **installed shells** from `/etc/shells`
- ✅ Shows **system info** (user, hostname, OS, kernel, home dir)
- ✅ Prints the **Shell Family Tree** (sh → bash / ksh / zsh)
- ✅ Checks if **Zsh is installed and set as default**
- ✅ Gives fix commands if Zsh is not default

---

## 🧠 Concepts Used (from Module 01)

| Concept | Used In |
|---|---|
| `$SHELL`, `$ZSH_VERSION` | Shell detection |
| `basename` | Extract shell name from path |
| `command -v` | Check if Zsh is installed |
| `/etc/shells` | List all installed shells |
| `$USER`, `$HOME`, `$PWD` | System info variables |
| `uname -s`, `uname -r` | OS and kernel info |
| `hostname` | Machine name |
| `case` statement | Match shell types |
| ANSI color codes | Terminal coloring |
| `#!/usr/bin/env zsh` | Portable shebang |

---

## 📁 Project Structure

```
shell-detector/
├── shell_detector.zsh   # Main script
└── README.md            # This file
```

---

## ⚙️ Setup & Run

### Step 1 — Clone or Download

```sh
git clone https://github.com/sabluchaudhary555/shell-detector.git
cd shell-detector
```

### Step 2 — Give Execute Permission

```sh
chmod +x shell_detector.zsh
```

### Step 3 — Run

```sh
./shell_detector.zsh
```

---

## 🖥️ Sample Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🐚  SHELL DETECTOR v1.0  🐚
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Shell Info
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Shell Name         : zsh
  Shell Path         : /usr/bin/zsh
  Shell Version      : 5.9

  Installed Shells (from /etc/shells)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✔  /bin/sh
  ✔  /bin/bash
  ✔  /usr/bin/zsh

  System Info
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  User               : hacker
  Hostname           : kali-machine
  OS                 : Linux
  Kernel             : 6.1.0-kali9-amd64
  Home Dir           : /home/hacker
  PWD                : /home/hacker/projects

  Shell Family Tree
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  sh  (Bourne Shell — 1979)
   ├── bash  (Bourne Again SHell — 1989)
   ├── ksh   (Korn Shell — 1983)
   └── zsh   (Z Shell — 1990) ← You are here (if using Zsh)

  Zsh Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✔ Zsh is your DEFAULT shell!
  ✔ Zsh is INSTALLED at: /usr/bin/zsh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Done! Run this script anytime to check your shell.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔧 Requirements

| Requirement | Detail |
|---|---|
| OS | Linux / macOS / WSL |
| Shell | Zsh (5.x recommended) |
| Permissions | Standard user (no root needed) |

---

## 💡 How to Set Zsh as Default (if not already)

```sh
# Install Zsh
sudo apt install zsh -y

# Set as default
chsh -s $(which zsh)

# Log out and log back in, then verify
echo $SHELL
# Output: /usr/bin/zsh
```


---
