# 🛡️ User Input Validator

A comprehensive Bash mini project that validates 7 types of user input — Name, Email, Phone, IP Address, Username, Date, and URL — with detailed rule-by-rule feedback, color-coded output, session logging, and bulk CSV validation.

---

## 📁 Project Structure

```
input-validator/
├── input_validator.sh    # Main script
├── README.md             # This file
└── logs/                 # Auto-created — session logs saved here
    └── validation_YYYYMMDD_HHMMSS.log
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 7 validator types | Name, Email, Phone, IPv4, Username, Date, URL |
| 📋 Rule-by-rule feedback | Every check shown with ✔ pass or ✗ fail |
| 🎨 Color-coded output | Green pass / Red fail / Yellow warning / Cyan info |
| 📂 Bulk CSV validation | Validate many inputs at once from a file |
| 📝 Session logging | Every result auto-saved to timestamped log file |
| 📋 Log viewer | View color-coded session log from inside the tool |
| 🔁 Interactive menu | Loop-based menu — validate multiple inputs per run |
| 📅 Smart date logic | Leap year check, past/future detection, month limits |
| 🌐 IP classification | Detects Private / Public / Loopback / Multicast |

---

## 🚀 Getting Started

### 1. Clone or Download

```bash
git clone https://github.com/your-username/input-validator.git
cd input-validator
```

### 2. Give Execute Permission

```bash
chmod +x input_validator.sh
```

### 3. Run the Script

```bash
./input_validator.sh
```

---

## 📸 Demo

```
  ╔══════════════════════════════════════════╗
  ║       🛡️  User Input Validator  v1.0      ║
  ║     Validate · Sanitize · Confirm        ║
  ╚══════════════════════════════════════════╝

  What would you like to validate?

  1)  Full Name          5)  Username
  2)  Email Address      6)  Date (YYYY-MM-DD)
  3)  Phone Number       7)  URL
  4)  IPv4 Address       8)  📂 Bulk validate from file
                         9)  📋 View session log
                         10) Exit

  Enter choice [1-10]: 2
  Enter email: user@example.com

  ── Email Address Validation ──

  ✔  Valid email format
  ✔  No consecutive dots
  ✔  Exactly one @ symbol
  ✔  Domain has valid dot notation
  ✔  Valid TLD: .com
  ℹ  Local part : user
  ℹ  Domain     : example.com

  ✅ Email is VALID
```

---

## 📋 Validators & Rules

### 1. 👤 Full Name
| Rule | Check |
|---|---|
| Not empty | Required |
| Letters and spaces only | No digits or symbols |
| Length 2–50 chars | Validated |
| At least two words | First + last name |
| No leading/trailing spaces | Trimming check |

### 2. 📧 Email Address
| Rule | Check |
|---|---|
| Basic format | `user@domain.tld` |
| No consecutive dots | `..` not allowed |
| Exactly one `@` | Single @ only |
| Domain has dot | `gmail.com` not `gmail` |
| TLD length 2–6 chars | `.com`, `.co.in` etc. |

### 3. 📱 Phone Number
| Rule | Check |
|---|---|
| Valid characters | Digits, spaces, `+`, `-`, `()` |
| All digits after stripping | No letters |
| Length 7–15 digits | ITU-T E.164 standard |
| Indian mobile format | Starts 6–9, 10 digits |
| International format | `+` prefix detected |

### 4. 🌐 IPv4 Address
| Rule | Check |
|---|---|
| Format `x.x.x.x` | 4 groups required |
| Each octet 0–255 | Range validation |
| No leading zeros | `01` or `007` rejected |
| IP classification | Private / Public / Loopback / Multicast |

### 5. 👤 Username
| Rule | Check |
|---|---|
| Valid chars | `a-z`, `A-Z`, `0-9`, `_`, `-` |
| Starts with letter | Not digit or symbol |
| Length 3–20 chars | Validated |
| No consecutive `--` or `__` | Pattern check |
| Cannot end with `_` or `-` | Edge check |

### 6. 📅 Date (YYYY-MM-DD)
| Rule | Check |
|---|---|
| Format YYYY-MM-DD | Regex match |
| Year range 1900–future | Reasonable bounds |
| Month 01–12 | Validated |
| Day within month limit | 28/29/30/31 based on month |
| Leap year check | Feb 29 correctly handled |
| Past / today / future | Comparison with today |

### 7. 🔗 URL
| Rule | Check |
|---|---|
| Starts with `http://` or `https://` | Scheme required |
| Full URL format | Domain + optional path |
| No spaces | URL encoding check |
| HTTPS preferred | Warning for HTTP |

---

## 📂 Bulk Validation from CSV

Create a file with format `type,value` — one per line:

```
# sample_data.csv
name,Alice Johnson
email,alice@example.com
email,bad@@email
phone,9876543210
ip,192.168.1.1
ip,999.100.1.1
username,alice_dev
username,1invalid
date,2024-02-29
url,https://github.com
url,not-a-url
```

Run bulk validation:
```
  Enter choice: 8
  Enter path to CSV file: ./sample_data.csv

  📂 Bulk Validation from: ./sample_data.csv

  ✔ Passed: 7
  ✗ Failed: 4
  Full log saved to: ./logs/validation_20250115_103045.log
```

---

## 📝 Session Logging

Every validation is automatically logged with timestamp:

```
[2025-01-15 10:30:45] === Session started ===
[2025-01-15 10:30:52] EMAIL PASS: 'user@example.com'
[2025-01-15 10:31:05] EMAIL FAIL: 'bad@@email' — 2 error(s)
[2025-01-15 10:31:18] IP PASS: '192.168.1.1'
[2025-01-15 10:31:30] IP FAIL: '999.100.1.1' — 1 error(s)
[2025-01-15 10:32:00] === Session ended ===
```

View the log from within the tool using **Option 9**.

---

## 🔧 Bash Concepts Used

### Regex with `[[ =~ ]]` and `BASH_REMATCH`
```bash
# Email format check
[[ "$email" =~ ^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$ ]]

# Extract date parts into BASH_REMATCH
[[ "$date" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]
year="${BASH_REMATCH[1]}"
month="${BASH_REMATCH[2]}"
day="${BASH_REMATCH[3]}"
```

### String Operations
```bash
${#name}           # string length
${uname,,}         # convert to lowercase
${phone//[- ]/}    # strip dashes and spaces
${email%@*}        # extract local part (before @)
${email#*@}        # extract domain (after @)
```

### I/O Redirection & Pipes
```bash
# Count @ symbols using pipe + heredoc
at_count=$(grep -o "@" <<< "$email" | wc -l)

# Log to file with redirection
echo "[$(date)] $msg" >> "$LOG_FILE"

# Bulk validation reads from file
while IFS=',' read -r type value; do
    ...
done < "$file"
```

### Arithmetic & Conditionals
```bash
(( len < 2 || len > 50 ))          # range check
(( year % 4 == 0 && ... ))         # leap year
(( 10#$month < 1 || 10#$month > 12 ))  # force base-10
```

### Functions
```bash
validate_email()    # email rules
validate_ip()       # IP + classification
validate_date()     # date + leap year
validate_from_file()# bulk CSV processing
view_log()          # colored log viewer
```

### Arrays
```bash
IFS='.' read -ra octets <<< "$ip"     # split IP into array
for i in "${!octets[@]}"; do          # iterate with index
    (( octets[i] > 255 )) && ...
done
```

### Case Statement
```bash
case $((10#$month)) in
    4|6|9|11) max_day=30 ;;
    2)        max_day=28 ;;   # + leap year logic
    *)        max_day=31 ;;
esac
```

### Colors (ANSI Escape Codes)
```bash
GREEN='\033[0;32m'; RED='\033[0;31m'; RESET='\033[0m'
echo -e "${GREEN}✔${RESET} Passed"
echo -e "${RED}✗${RESET} Failed"
```

---

## 🧪 Test Cases

### Email
| Input | Result |
|---|---|
| `user@example.com` | ✅ Valid |
| `bad@@email.com` | ❌ Multiple @ |
| `nodomain@` | ❌ No domain |
| `user@domain` | ❌ No TLD |
| `user..name@domain.com` | ❌ Consecutive dots |

### IPv4
| Input | Result |
|---|---|
| `192.168.1.1` | ✅ Valid (Private) |
| `8.8.8.8` | ✅ Valid (Public) |
| `127.0.0.1` | ✅ Valid (Loopback) |
| `256.100.1.1` | ❌ Octet > 255 |
| `192.168.01.1` | ❌ Leading zero |

### Date
| Input | Result |
|---|---|
| `2024-02-29` | ✅ Valid (leap year) |
| `2023-02-29` | ❌ Not a leap year |
| `2024-13-01` | ❌ Invalid month |
| `2024-04-31` | ❌ April has 30 days |
| `2025-01-15` | ✅ Valid |

---

## 📌 Requirements

- Bash **3.2+** (for `[[ =~ ]]` and `BASH_REMATCH`)
- Works on **Linux** and **macOS**
- No external dependencies

---
