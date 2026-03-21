# 🔐 Silent Password Vault — Bash Mini Project

## 📌 What It Does

Accepts a username and password securely via terminal (input is hidden), validates both entries, checks password strength using regex, hashes the password with `sha256sum`, and appends the record to a local vault file.

---

## 🧠 Bash Concepts Covered

| Concept | Usage in Script |
|---|---|
| `read -p` | Inline prompt for username |
| `read -sp` | Silent/hidden password input — `-s` suppresses echo |
| `echo ""` | Mandatory newline after every `-s` read |
| `${#passwd}` | String length operator — used for min-length check |
| `[[ -z ]]` | Empty string check |
| `=~ regex` | Pattern matching for uppercase, digit, special char |
| `readonly` | `MIN_LEN` and `VAULT_FILE` declared as constants |
| `$(sha256sum)` | Command substitution — hashes password |
| `${hash:0:16}` | Substring extraction for safe display |
| `>>` | Append operator — writes entry to vault file |

---

## 📁 Project Structure

```
silent-password-vault/
├── password_vault.sh     # Main script
├── README.md             # This file
└── .vault_store          # Auto-created at $HOME — stores hashed entries
```

> `.vault_store` is created automatically on first run at `$HOME/.vault_store`.

---

## ⚙️ Requirements

- Bash `v4.0+`
- `sha256sum` — pre-installed on Linux; on macOS use `shasum -a 256`
- No external dependencies

Check:
```bash
bash --version
sha256sum --version
```

---

## 🚀 Installation & Usage

**1. Clone or download**
```bash
git clone https://github.com/your-username/bash-mini-projects.git
cd bash-mini-projects/05-silent-password-vault
```

**2. Give execute permission**
```bash
chmod +x password_vault.sh
```

**3. Run the script**
```bash
./password_vault.sh
```

**4. Follow the prompts**
```
Username: h4cker
Password:              ← input is hidden (-s flag)
Confirm password:      ← hidden again
```

---

## 📤 Sample Output

```
╔══════════════════════════════════════╗
║         VAULT ENTRY SAVED            ║
╠══════════════════════════════════════╣
  User      : h4cker
  Length    : 12 characters
  Strength  : strong
  SHA256    : 3b4c9f8a1d72e601...
  Stored at : /home/hacker/.vault_store
  Timestamp : Fri Mar 20 15:42:10 IST 2026
╚══════════════════════════════════════╝
```

---

## 🔍 How It Works

```bash
# 1. Prompt username — visible input
read -p "Username: " username

# 2. Silent password — terminal echo suppressed
read -sp "Password: " passwd
echo ""    # CRITICAL: always add newline after -sp

# 3. Confirm — second hidden read
read -sp "Confirm password: " passwd2
echo ""

# 4. Length check using ${#var}
if (( ${#passwd} < MIN_LEN )); then
    echo "[ERROR] Too short. Min: ${MIN_LEN}"
    exit 1
fi

# 5. Match check
if [[ "${passwd}" != "${passwd2}" ]]; then
    echo "[ERROR] Passwords do not match."
    exit 1
fi

# 6. Strength via regex
[[ "${passwd}" =~ [A-Z] ]]        && has_upper=true
[[ "${passwd}" =~ [0-9] ]]        && has_digit=true
[[ "${passwd}" =~ [^a-zA-Z0-9] ]] && has_special=true

# 7. Hash and store
hash=$(echo -n "${passwd}" | sha256sum | cut -d' ' -f1)
echo "${username}:${hash}:$(date)" >> "${VAULT_FILE}"
```

---

## 🔒 Vault File Format

Each entry is saved as one line:
```
username:sha256hash:timestamp
```

Example:
```
h4cker:3b4c9f8a1d72e601f3c5...:Fri Mar 20 15:42:10 IST 2026
```

> The plaintext password is **never stored** — only its SHA-256 hash.

---

## 🛡️ Password Strength Rules

| Strength | Conditions |
|---|---|
| `weak` | Lowercase only, no digits or special chars |
| `medium` | Has uppercase OR digit |
| `strong` | Has uppercase AND digit AND special character |

---

## ⚠️ Common Mistakes (from notes)

```bash
# WRONG — no newline after -s, next echo prints on same line
read -sp "Password: " pass
echo "Saved."        # bug: prints on same line as hidden cursor

# CORRECT
read -sp "Password: " pass
echo ""              # force newline first
echo "Saved."

# WRONG — not using -r, backslashes get eaten
read -p "Input: " val

# CORRECT for raw input
read -r -p "Input: " val
```

---

## 💡 Key Notes

- **`-s` never adds a newline** — always follow with `echo ""`
- **`${#var}`** gives string length — works on any variable
- **`=~`** enables regex inside `[[ ]]` — no quotes around the pattern
- **`readonly`** constants prevent accidental modification mid-script
- **`sha256sum`** outputs `hash  filename` — use `cut -d' ' -f1` to extract just the hash

---


<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

--- 

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)

---
**Made with ❤️ for the Open Source Community**