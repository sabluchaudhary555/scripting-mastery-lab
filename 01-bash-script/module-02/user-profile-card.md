# 👤 User Profile Card — Bash Mini Project

![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue?style=flat)
![Level](https://img.shields.io/badge/Level-Beginner-green?style=flat)
![Topics](https://img.shields.io/badge/Topics-Variables%20%7C%20read%20%7C%20%24()-informational?style=flat)

> Part of the **Bash Scripting Mini Projects Series** — Project #2  
> Covers: variable declaration, `read`, command substitution, `${}` expansion, silent input

---

## 📌 What It Does

Collects user details interactively via terminal prompts and prints a formatted **profile card** with both user-provided values and system-generated info (`hostname`, `date`, `id -u`).

---

## 🧠 Bash Concepts Covered

| Concept | Usage in Script |
|---|---|
| Variable assignment | `name="value"` — no spaces around `=` |
| `read -p` | Inline prompt for name, age, city, role |
| `read -sp` | Silent/hidden password input (`-s` flag) |
| `$()` command substitution | `$(date)`, `$(hostname)`, `$(id -u)` |
| `${var}` explicit expansion | All `echo` output lines — best practice |
| Naming convention | `snake_case` for local vars, `UPPER_CASE` for constants |

---

## 📁 Project Structure

```
user-profile-card/
├── profile_card.sh     # Main script
└── README.md           # This file
```

---

## ⚙️ Requirements

- Bash `v4.0+` (pre-installed on Linux/macOS)
- No external dependencies

Check your Bash version:
```bash
bash --version
```

---

## 🚀 Installation & Usage

**1. Clone or download the script**
```bash
git clone https://github.com/your-username/bash-mini-projects.git
cd bash-mini-projects/02-user-profile-card
```

**2. Give execute permission**
```bash
chmod +x profile_card.sh
```

**3. Run the script**
```bash
./profile_card.sh
```

**4. Follow the prompts**
```
Enter your name   : Hacker
Enter your age    : 21
Enter your city   : Noida
Enter your role   : Cybersec Lead
Enter password   : (hidden)
```

---

## 📤 Sample Output

```
╔══════════════════════════════════════╗
║        USER PROFILE CARD             ║
╠══════════════════════════════════════╣
  Name     : Hacker
  Age      : 10 yrs
  City     : Delhi
  Role     : Cybersec Lead
  UID      : 100000
  Host     : kali
  Login at : Fri Mar 20 14:32:01 IST 2026
  Password : (stored securely)
╚══════════════════════════════════════╝
```

---

## 🔍 How It Works

```bash
# 1. User input collected via read
read -p "Enter your name : " name

# 2. Silent input for password (no echo to terminal)
read -sp "Enter password  : " passwd

# 3. System values captured via command substitution
timestamp=$(date)
host=$(hostname)
uid_val=$(id -u)

# 4. Variables printed using ${} explicit expansion
echo "Name     : ${name}"
echo "Login at : ${timestamp}"
```

---

## 💡 Key Notes

- **No spaces around `=`** — `name="Hacker"` is valid, `name = "Hacker"` throws an error
- **`-s` flag** on `read` suppresses terminal echo (used for passwords)
- **`$()`** is preferred over backticks for command substitution — it's nestable and more readable
- **`${var}`** over `$var` avoids ambiguity when concatenating with other strings, e.g. `${prefix}sec`

---

## 🗺️ Series Roadmap

| # | Project | Topics |
|---|---|---|
| 01 | System Info Reporter | command substitution, env vars |
| **02** | **User Profile Card** ← you are here | `read`, variables, `${}` |
| 03 | Password Generator Logger | string ops, `date`, file redirect |
| 04 | File Rename Automator | loops, string concatenation |
| 05 | Environment Snapshot Tool | env vars, formatting |

---


<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)

---
**Made with ❤️ for the Open Source Community**