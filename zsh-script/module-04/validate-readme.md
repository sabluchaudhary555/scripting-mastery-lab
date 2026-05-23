<div align="center">

# 🔍 validate.zsh

**A terminal-based input validator — check usernames, emails, IPs, ports, and file paths instantly.**

![Shell](https://img.shields.io/badge/Shell-Zsh-informational?style=flat&logo=gnu-bash&logoColor=white&color=2bbc8a)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue?style=flat)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat)
![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat)

<br/>

> Stop copy-pasting regex from Stack Overflow.  
> Just run `validate.zsh` and check anything in seconds.

<br/>


</div>

---

## 📌 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Demo](#-demo)
- [Installation](#-installation)
- [Usage](#-usage)
- [What It Validates](#-what-it-validates)
- [How It Works](#-how-it-works)
- [Zsh Concepts Used](#-zsh-concepts-used)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## 📖 About

`validate.zsh` is a command-line input validation tool written in pure Zsh. It provides an interactive menu to validate common data types — usernames, emails, IPv4 addresses, ports, and file paths — with clear, color-coded feedback.

Built as part of a **Zsh mini-projects series** to practice conditional statements in a real, useful tool.

---

## ✨ Features

- 👤 **Username** — length (3–20), allowed characters only
- 📧 **Email** — full format validation with regex
- 🌐 **IPv4** — format check + octet range (0–255) per segment
- 🔌 **Port** — range check (1–65535) + privileged port warning
- 📁 **File path** — existence, type, permissions, size & line count
- 🎨 Color-coded output — ✔ green for valid, ✘ red for errors, ⚠ yellow for warnings
- 🔁 Interactive menu — loops until you choose to exit

---

## 🎬 Demo

```
  ┌─────────────────────────────┐
  │     Zsh Input Validator     │
  └─────────────────────────────┘
  1) Username
  2) Email address
  3) IPv4 address
  4) Port number
  5) File path
  6) Exit

  Choose [1-6]: 3

  IPv4 address: 192.168.1.300
  ✘  Octet out of range (each must be 0–255)

  Choose [1-6]: 3

  IPv4 address: 192.168.1.1
  ✔  Valid IPv4: 192.168.1.1

  Choose [1-6]: 4

  Port number: 80
  ⚠  Port 80 is privileged (requires root)
```

---

## 🚀 Installation

```zsh
git clone https://github.com/yourusername/validate.zsh.git
cd validate.zsh
chmod +x validate.zsh
```

**Optional — use it anywhere:**

```zsh
cp validate.zsh /usr/local/bin/validate
# then just run: validate
```

### Prerequisites

| Tool | Required |
|---|---|
| `zsh` | ✅ Yes (v5.0+) |
| `du`, `wc` | ✅ Yes (standard on all Unix systems) |

No external dependencies. No package installs.

---

## 🧑‍💻 Usage

```zsh
./validate.zsh
```

An interactive menu opens. Pick a validator, enter your value, get instant feedback. Press Enter to go back to the menu.

---

## 🔎 What It Validates

### 👤 Username
| Rule | Detail |
|---|---|
| Not empty | Required |
| Length | 3–20 characters |
| Characters | Letters, digits, underscores only (`a-z A-Z 0-9 _`) |

### 📧 Email
| Rule | Detail |
|---|---|
| Format | `user@domain.tld` |
| TLD length | Minimum 2 characters |

### 🌐 IPv4 Address
| Rule | Detail |
|---|---|
| Format | `x.x.x.x` — exactly 4 segments |
| Each segment | Must be `0–255` |

### 🔌 Port Number
| Rule | Detail |
|---|---|
| Must be a number | No letters allowed |
| Range | `1–65535` |
| Privileged ports | `< 1024` — warning shown (still valid) |

### 📁 File Path
| Check | Detail |
|---|---|
| Exists | Must exist on disk |
| Type | Must be a regular file (not a directory) |
| Readable | Must have read permission |
| Info | Shows size and line count on success |

---

## ⚙️ How It Works

```
┌──────────────────────────────────────────────┐
│  User selects option from menu               │
│                ↓                             │
│  Input is passed to validator function       │
│                ↓                             │
│  Guard clauses run top-to-bottom:            │
│    → empty check                             │
│    → format/type check                       │
│    → range/permission check                  │
│                ↓                             │
│  First failing guard exits with error        │
│  All pass → success message + details        │
│                ↓                             │
│  Menu loops back for next input              │
└──────────────────────────────────────────────┘
```

Each validator uses the **guard clause pattern** — check for failure early, exit fast, keep the happy path flat and readable.

---

## 🧠 Zsh Concepts Used

This project was built specifically to practice Zsh conditional statements:

| Concept | Where Used |
|---|---|
| `[[ ]]` double brackets | String checks, file tests, regex matching |
| `(( ))` arithmetic | Port range, username length, octet range |
| `=~` regex match | Email, IPv4, username format validation |
| `$match[]` capture groups | Extracting IPv4 octets from regex |
| `case` statement | Interactive menu routing |
| `-z` / `-n` string tests | Empty input detection |
| `-e -f -d -r` file tests | File path validation |
| Guard clauses `&&` `{ }` | Early exit on validation failure |
| `${#var}` | String length check |
| Functions with `return` | Each validator is its own reusable function |
| Color codes | Terminal output formatting |

---

## 📁 Project Structure

```
validate.zsh/
├── validate.zsh      # main script
├── README.md         # this file
└── demo.gif          # terminal demo (add your own)
```

---

## 🤝 Contributing

Got a validator idea? PRs are welcome!

1. Fork the repo
2. Create a branch: `git checkout -b feature/add-url-validator`
3. Commit: `git commit -m "add: URL validator"`
4. Push: `git push origin feature/add-url-validator`
5. Open a Pull Request

**Ideas for new validators:** URL, date format, MAC address, credit card number, hex color code.

---
