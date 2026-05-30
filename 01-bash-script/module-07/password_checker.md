# 🔐 Password Strength Checker

A feature-rich Bash mini project that checks password strength in real time using regex, conditional logic, string operations, and colorized terminal output.

---

## 📁 Project Structure

```
password-checker/
├── password_checker.sh   # Main script
└── README.md             # This file
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 10-rule strength check | Validates length, character types, patterns, entropy |
| 🎨 Color-coded output | Red / Yellow / Green based on strength |
| 📊 Score bar | Visual progress bar from 0 to 10 |
| 🙈 Hidden input | Masked password entry (shows `*`) |
| 🎲 Password generator | Generates a random strong password |
| 💡 Suggestions | Tells you exactly how to improve your password |
| 🔁 Interactive menu | Loop-based menu — check multiple passwords in one run |

---

## 🚀 Getting Started

### 1. Clone or Download

```bash
git clone https://github.com/your-username/password-checker.git
cd password-checker
```

### 2. Give Execute Permission

```bash
chmod +x password_checker.sh
```

### 3. Run the Script

```bash
./password_checker.sh
```

---

## 📸 Demo

```
  ╔══════════════════════════════════════╗
  ║     🔐 Password Strength Checker     ║
  ╚══════════════════════════════════════╝

  Choose an option:
  1) Check password strength
  2) Check your own password (hidden input)
  3) Generate a strong password
  4) Exit

  Enter choice [1-4]: 1

  Enter password to check: Hello@1234

  📋 Checking Rules:

  ✔  Length ≥ 8 characters   (10 chars)
  ✗  Length ≥ 12 characters  (recommended)
  ✔  Contains uppercase letter (A–Z)
  ✔  Contains lowercase letter (a–z)
  ✔  Contains digit (0–9)
  ✔  Contains special character (!@#$%^&*...)
  ✔  Not a commonly used password
  ✔  No 3+ repeating characters
  ✔  No sequential patterns (abc, 123)
  ✔  Uses 3+ character types (good entropy)

  📊 Score: 9/10
  ██████████████████░░

  ✅ Strength: STRONG
     Good password — hard to crack.

  💡 Suggestions to improve:
  →  Use 12+ characters for stronger security
```

---

## 📋 The 10 Strength Rules

| # | Rule | Points |
|---|---|---|
| 1 | Length ≥ 8 characters | +1 |
| 2 | Length ≥ 12 characters | +1 |
| 3 | Contains uppercase letter (A–Z) | +1 |
| 4 | Contains lowercase letter (a–z) | +1 |
| 5 | Contains digit (0–9) | +1 |
| 6 | Contains special character (`!@#$%^&*`) | +1 |
| 7 | Not a commonly used password | +1 |
| 8 | No 3+ consecutive repeating characters | +1 |
| 9 | No sequential patterns (`abc`, `123`) | +1 |
| 10 | Uses 3+ different character types | +1 |

---

## 🏆 Strength Levels

| Score | Level | Color |
|---|---|---|
| 0 – 3 | 💀 Very Weak | 🔴 Red |
| 4 – 5 | ⚠️ Weak | 🟡 Yellow |
| 6 – 7 | 🔶 Moderate | 🟡 Yellow |
| 8 – 9 | ✅ Strong | 🟢 Green |
| 10 | 🔒 Very Strong | 🟢 Green |

---

## 🔧 Bash Concepts Used

This project is a practical application of core Bash scripting topics:

### Conditional Statements
```bash
if [[ "$pass" =~ [A-Z] ]]; then
    pass_rule "Contains uppercase letter"
    (( score++ ))
else
    fail_rule "Contains uppercase letter"
fi
```

### Regex with `[[ =~ ]]`
```bash
[[ "$pass" =~ [^a-zA-Z0-9] ]]    # special character check
[[ "$pass" =~ (.)\1\1 ]]          # 3+ repeating chars
[[ "$pass" =~ (abc|123|...) ]]    # sequential patterns
```

### String Operations
```bash
${#pass}          # string length
${pass,,}         # convert to lowercase
```

### Arithmetic Operators
```bash
(( score++ ))          # increment score
(( score * 2 ))        # scale for bar
(( ${#pass} >= 8 ))    # length comparison
```

### Arrays
```bash
local common=("password" "123456" "admin" ...)
local -a suggestions=()
suggestions+=("Add at least one digit")
```

### Functions
```bash
check_password()   # runs all 10 rules
generate_password()# creates random password
read_password()    # hidden input with masking
print_banner()     # display header
strength_bar()     # visual score bar
```

### Loops
```bash
# For loop — build strength bar
for (( i=0; i<filled; i++ )); do bar+="█"; done

# While loop — menu keeps running until exit
while true; do
    read choice
    case $choice in ...
done
```

### Colors (ANSI Escape Codes)
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${GREEN}✔${RESET} Passed"
```

### Hidden Input (`read -s`)
```bash
while IFS= read -r -s -n1 char; do
    [[ -z "$char" ]] && break          # Enter = done
    [[ "$char" == $'\x7f' ]] && ...    # Backspace handling
    pass+="$char"
    echo -n "*"
done
```

### Password Generator (`/dev/urandom`)
```bash
tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 16
```

---

## 🧪 Test Cases

| Password | Score | Level |
|---|---|---|
| `abc` | 1/10 | 💀 Very Weak |
| `password123` | 2/10 | 💀 Very Weak |
| `Hello1234` | 6/10 | 🔶 Moderate |
| `Hello@1234` | 9/10 | ✅ Strong |
| `Tr0ub4dor&3_Secure!` | 10/10 | 🔒 Very Strong |

---

## 🛡️ Common Passwords Blocked

The script automatically detects and flags these commonly used passwords:

```
password, 123456, password123, admin, letmein,
qwerty, abc123, 111111, iloveyou, welcome
```

---

## 💡 Example — Generate a Strong Password

```
  Enter choice [1-4]: 3
  Enter desired length (default 16): 20

  🎲 Generated Password (20 chars):
    K#9vQ$mL2@pX!nR7cW&j
```

---

## 📌 Requirements

- Bash version **3.2+** (for `[[ =~ ]]` regex support)
- Works on **Linux** and **macOS**
- No external dependencies needed

---

