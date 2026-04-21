# 🔧 Module 6: Functions in Bash
> Bash Scripting Series | `scripting-mastery-lab`

---

## 1. Defining and Calling Functions

```bash
# Style 1 — function keyword
function greet {
    echo "Hello, Hacker!"
}

# Style 2 — shorthand (preferred)
greet() {
    echo "Hello, Hacker!"
}

# Calling a function
greet
```

> ⚠️ Always **define before calling** — Bash reads top to bottom.

---

## 2. Parameters: `$1` `$2` `$@` `$#`

```bash
user_info() {
    echo "Name  : $1"
    echo "Age   : $2"
    echo "All   : $@"
    echo "Count : $#"
}

user_info "Hacker" 20 "GDSC" "Cybersecurity"
```

**Output:**
```
Name  : Hacker
Age   : 20
All   : Hacker 20 GDSC Cybersecurity
Count : 4
```

| Variable | Meaning |
|----------|---------|
| `$1`, `$2`... | Individual positional arguments |
| `$@` | All arguments as separate words |
| `$*` | All arguments as a single string |
| `$#` | Total number of arguments |
| `$0` | Script name itself |

> 💡 Always use `"$@"` over `"$*"` — preserves argument spacing correctly.

---

## 3. Return Values & Exit Status

> Bash functions **cannot return strings** — only integers (0–255) via `return`.  
> To return a string, use **command substitution** `$()`.

```bash
# return — exit status only (0 = success, non-zero = failure)
is_even() {
    (( $1 % 2 == 0 )) && return 0 || return 1
}

is_even 4 && echo "Even" || echo "Odd"
echo "Exit status: $?"     # $? holds last return value

# Returning a string — use echo + $()
get_greeting() {
    echo "Hello, $1!"
}

message=$(get_greeting "Hacker")
echo "$message"            # Hello, Hacker!
```

| Method | Use For |
|--------|---------|
| `return 0` | Success signal |
| `return 1` | Failure / error signal |
| `echo` + `$()` | Returning actual string/data |
| `$?` | Capture last exit status |

---

## 4. Local vs Global Variables (Scope)

```bash
name="Global Hacker"      # global variable

show_scope() {
    local name="Local Hacker"   # local — only inside function
    echo "Inside : $name"
}

show_scope
echo "Outside: $name"
```

**Output:**
```
Inside : Local Hacker
Outside: Global Hacker
```

> ✅ Always use `local` inside functions — prevents accidentally overwriting global variables.

| Variable | Scope |
|----------|-------|
| Declared normally | Global — accessible everywhere |
| Declared with `local` | Local — only inside that function |

---

## 5. Recursive Functions

```bash
# Factorial using recursion
factorial() {
    local n=$1
    if (( n <= 1 )); then
        echo 1
    else
        local prev=$(factorial $(( n - 1 )))
        echo $(( n * prev ))
    fi
}

result=$(factorial 5)
echo "5! = $result"        # 5! = 120
```

```bash
# Fibonacci using recursion
fibonacci() {
    local n=$1
    (( n <= 1 )) && echo $n && return
    local a=$(fibonacci $(( n - 1 )))
    local b=$(fibonacci $(( n - 2 )))
    echo $(( a + b ))
}

echo "Fib(6) = $(fibonacci 6)"   # Fib(6) = 8
```

> ⚠️ Bash recursion is **slow** for large inputs — use loops for performance-critical tasks.

---

## 6. Function Libraries & Sourcing

> Break reusable functions into a separate file and **source** it into any script.

**Step 1 — Create a library file `lib_utils.sh`:**
```bash
# lib_utils.sh — reusable function library

log_info() {
    echo "[INFO]  $(date '+%H:%M:%S') — $1"
}

log_error() {
    echo "[ERROR] $(date '+%H:%M:%S') — $1" >&2
}

is_root() {
    [[ $EUID -eq 0 ]] && return 0 || return 1
}
```

**Step 2 — Source it in your main script:**
```bash
#!/bin/bash

source ./lib_utils.sh
# OR shorthand:
. ./lib_utils.sh

log_info "Script started"
is_root && log_info "Running as root" || log_error "Not root"
```

> ✅ `source` runs the file **in the current shell** — all functions/variables become available.  
> ❌ `./lib_utils.sh` runs it in a **subshell** — functions won't be available in parent.

---

## ⚡ Cheat Sheet

```bash
# Define
funcname() { commands; }

# Call
funcname arg1 arg2

# Parameters
$1 $2        → positional args
$@           → all args (separate)
$#           → arg count
$?           → last exit status

# Return
return 0     → success
return 1     → failure
echo + $()   → return a string

# Scope
local var="value"    → local variable

# Recursion
funcname() {
    base_case && return
    funcname $(( n - 1 ))
}

# Source a library
source ./lib_utils.sh
```

---
