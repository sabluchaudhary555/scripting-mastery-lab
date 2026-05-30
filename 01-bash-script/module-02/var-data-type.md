# 🟡 Module 2: Variables and Data Types
# 🐚 Bash Scripting — Variables & Data Types

> Bash is **loosely typed** — everything is a string by default unless declared otherwise.

---

## 📌 Table of Contents
1. [Variables Basics](#1-variables-basics)
2. [Data Types](#2-data-types)
3. [read Command](#3-read-command)
4. [Environment Variables](#4-environment-variables)
5. [Special Variables](#5-special-variables)
6. [Variable Scope](#6-variable-scope)
7. [String Operations](#7-string-operations)
8. [Parameter Expansion](#8-parameter-expansion)
9. [Arithmetic Operations](#9-arithmetic-operations)
10. [declare Command](#10-declare-command)
11. [Unsetting Variables](#11-unsetting-variables)

---

## 1. Variables Basics

```bash
name="Hacker"          # String
count=10               # Integer (as string)
path=$(pwd)            # Command output

echo $name             # Basic access
echo "$name"           # Preferred
echo "${name}"         # Best practice (explicit boundary)
echo "${name}sec"      # Boundary needed: 'Hackersec'
```

> ⚠️ **No spaces around `=`** — `var = value` causes an error.

---

## 2. Data Types

| Type | Declaration | Example |
|------|-------------|---------|
| String | `var="val"` | `name="Alice"` |
| Integer | `declare -i var` | `declare -i n=10` |
| Indexed Array | `arr=(...)` | `fruits=("a" "b")` |
| Associative Array | `declare -A arr` | `arr["key"]="val"` |
| Readonly | `readonly var` | `readonly PI=3.14` |
| Environment | `export var` | `export PATH=...` |
| Local | `local var` | Inside functions only |

---

## 3. `read` Command

Reads input from the user and stores it in a variable.

```bash
read name                         # Basic input → stored in $name
read                              # No variable → stored in $REPLY
```

### Common Options

| Option | Description | Example |
|--------|-------------|---------|
| `-p` | Inline prompt | `read -p "Name: " name` |
| `-s` | Silent (hidden) | `read -s -p "Pass: " pass` |
| `-n N` | Read N chars | `read -n 1 -p "Y/N: " ch` |
| `-t N` | Timeout (secs) | `read -t 5 -p "Quick: " ans` |
| `-r` | Raw input | `read -r filepath` |
| `-a` | Into array | `read -a arr` |

```bash
read -p "Username: " user
read -s -p "Password: " pass; echo ""
read -t 5 -p "Quick answer: " ans || echo "Timed out!"
read -a fruits <<< "apple banana cherry"
while IFS= read -r line; do echo "$line"; done < file.txt
```

> ⚠️ Always `echo ""` after `-s` | Always use `-r` for file paths

---

## 4. Environment Variables

Global variables available to the shell and all child processes.

```bash
env / printenv             # List all
export MY_VAR="value"      # Export to children
export PATH="$PATH:/mybin" # Add to PATH
```

### Common Built-ins

| Variable | Description |
|----------|-------------|
| `$HOME` | Home directory |
| `$USER` | Current username |
| `$PATH` | Executable search path |
| `$PWD` | Current directory |
| `$SHELL` | Current shell |
| `$RANDOM` | Random number 0–32767 |
| `$UID` | User ID |

```bash
# Persist in ~/.bashrc
echo 'export API_KEY="abc123"' >> ~/.bashrc
source ~/.bashrc
```

---

## 5. Special Variables

| Variable | Description |
|----------|-------------|
| `$0` | Script name |
| `$1`–`$9` | Positional arguments |
| `$#` | Argument count |
| `$@` | All args (separate words) |
| `$*` | All args (one string) |
| `$?` | Exit code of last command |
| `$$` | PID of current script |
| `$!` | PID of last background job |
| `$LINENO` | Current line number |
| `$SECONDS` | Seconds since script started |

```bash
echo "Script: $0, Args: $#, Last exit: $?"
```

---

## 6. Variable Scope

```bash
# Global (default)
msg="global"
func() { echo $msg; }     # Accessible

# Local (function-only)
func() {
  local x=10
  echo $x
}
echo $x                   # Empty — out of scope

# Subshell (isolated)
x=10
( x=999; echo $x )        # 999 inside
echo $x                   # 10 — unchanged

# Global inside function
func() { declare -g shared="visible outside"; }
func; echo $shared
```

---

## 7. String Operations

```bash
str="Hello Bash Scripting"

# Length
echo ${#str}                  # 20

# Slice: ${var:offset:length}
echo ${str:6:4}               # Bash

# Replace: first / all
echo ${str/Bash/Shell}        # Hello Shell Scripting
echo ${str//o/0}              # Hell0 Bash Scripting

# Case conversion
echo ${str^^}                 # HELLO BASH SCRIPTING
echo ${str,,}                 # hello bash scripting

# Trim prefix/suffix
file="report.tar.gz"
echo ${file%%.*}              # report       (longest suffix removed)
echo ${file##*.}              # gz            (longest prefix removed)
echo ${file%.*}               # report.tar   (shortest suffix removed)
```

---

## 8. Parameter Expansion & Defaults

| Syntax | Meaning |
|--------|---------|
| `${var:-default}` | Use default if unset/empty |
| `${var:=default}` | Assign default if unset/empty |
| `${var:+value}` | Use value only if var is set |
| `${var:?message}` | Error & exit if unset |

```bash
name=""
echo ${name:-"Anonymous"}         # Anonymous (not assigned)
echo ${name:="guest"}             # guest (assigned)
: ${REQUIRED:?"Must be set!"}     # Exit if unset

# Practical defaults
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-5432}
```

---

## 9. Arithmetic Operations

```bash
a=15; b=4

# Method 1: $(( )) — preferred
echo $((a + b))    # 19
echo $((a ** b))   # 50625
echo $((a % b))    # 3

# Method 2: let
let result=a*b
echo $result       # 60

# Method 3: expr (old style)
expr 10 + 5        # 15
expr 10 \* 5       # 50

# Increment / Decrement
((n++)); ((n--)); ((n += 5))

# Float (use bc or awk)
echo "scale=4; 22/7" | bc     # 3.1428
awk 'BEGIN { printf "%.2f\n", 10/3 }'
```

---

## 10. `declare` Command

| Flag | Purpose |
|------|---------|
| `-i` | Integer |
| `-r` | Readonly |
| `-a` | Indexed array |
| `-A` | Associative array |
| `-x` | Export (environment) |
| `-l` | Auto lowercase |
| `-u` | Auto uppercase |
| `-n` | Nameref (alias) |
| `-p` | Print attributes |
| `-g` | Global inside function |

```bash
declare -i count=10       # Integer
declare -r MAX=100        # Readonly
declare -l lower; lower="HELLO"   # → hello
declare -u upper; upper="hello"   # → HELLO
declare -ir LIMIT=50      # Integer + Readonly
declare -n ref=original   # ref is alias to original
declare -p upper          # Print: declare -u upper="HELLO"
```

---

## 11. Unsetting Variables

```bash
name="Hacker"
unset name                    # Remove variable

arr=("a" "b" "c")
unset arr[1]                  # Remove element → a c
unset arr                     # Remove entire array

declare -A cfg=(["host"]="localhost")
unset cfg["host"]             # Remove key

unset -f my_func              # Remove function

# Check if set
[ -z "${var+x}" ] && echo "not set" || echo "set"
```

---

## ⚡ Quick Reference

```
String       →  var="value"           default type
Integer      →  declare -i            use $(( ))
Float        →  bc / awk / python3    not native
Boolean      →  0/1 or "true"/"false" convention
Array        →  arr=(...)             zero-indexed
Assoc Array  →  declare -A            key-value, Bash 4+
Readonly     →  readonly / declare -r cannot modify
Environment  →  export                inherited by children
Local        →  local                 function-scoped only
```

<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)

---
**Made with ❤️ for the Open Source Community**


<br>