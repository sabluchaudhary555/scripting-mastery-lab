# Module 6: Functions

## Defining and Calling Functions

```bash
# Two syntax styles
function greet() {
  echo "Hello, $1"
}

greet() {
  echo "Hello, $1"
}

greet "World"   # calling the function
```

---

## Parameters: `$1`, `$2`, `$@`, `$#`

| Variable | Meaning |
|----------|---------|
| `$1`, `$2`, ... | Positional arguments |
| `$@` | All arguments as separate words |
| `$*` | All arguments as a single word |
| `$#` | Number of arguments passed |

```bash
info() {
  echo "Count: $#"
  echo "All args: $@"
  echo "First: $1, Second: $2"
}

info apple banana cherry
# Count: 3
# All args: apple banana cherry
# First: apple, Second: banana
```

---

## `$argv` Array (Zsh-specific)

In Zsh, `$argv` is an array holding all positional arguments — equivalent to `$@`.

```zsh
show_args() {
  echo "First: $argv[1]"
  echo "All: $argv"
}

show_args one two three
```

> **Note:** `$argv` is Zsh-only. Use `$@` for portability across Bash/Zsh.

---

## Return Values and Exit Status

Functions return an **exit status** (integer 0–255) via `return`, not a value.
Use command substitution `$()` to capture output as a "return value".

```bash
is_even() {
  (( $1 % 2 == 0 )) && return 0 || return 1
}

is_even 4 && echo "Even" || echo "Odd"

# Capturing output as a return value
get_square() {
  echo $(( $1 * $1 ))
}

result=$(get_square 5)
echo "Square: $result"   # Square: 25
```

> `return 0` = success, non-zero = failure (mirrors exit codes).

---

## Local vs Global Variables: `local` | `typeset`

By default, variables inside functions are **global**. Use `local` (Bash/Zsh) or `typeset` (Zsh/ksh) to scope them.

```bash
x="global"

demo() {
  local x="local"       # Bash & Zsh
  # typeset x="local"   # Zsh/ksh equivalent
  echo "Inside: $x"
}

demo
echo "Outside: $x"
# Inside: local
# Outside: global
```

> Always use `local` inside functions to avoid polluting the global namespace.

---

## Recursive Functions

A function that calls itself. Must have a **base case** to avoid infinite recursion.

```bash
factorial() {
  (( $1 <= 1 )) && echo 1 && return
  echo $(( $1 * $(factorial $(( $1 - 1 ))) ))
}

factorial 5   # 120
```

```bash
countdown() {
  (( $1 < 0 )) && return
  echo $1
  countdown $(( $1 - 1 ))
}

countdown 3
# 3 2 1 0
```

---

## Autoloading Functions: `autoload -Uz`

Zsh can **lazily load** functions from files — the function is only read from disk when first called. Each function lives in its own file (filename = function name).

```zsh
# Add directory to fpath
fpath=(~/.zsh/functions $fpath)

# Mark function for autoloading
autoload -Uz my_function

my_function   # loaded from ~/.zsh/functions/my_function on first call
```

**Flags:**
- `-U` — suppress alias expansion inside the function (best practice)
- `-z` — use Zsh-style autoload (not ksh-style)

---

## Function Libraries and Sourcing

Group related functions into a library file and **source** it to make them available.

```bash
# File: ~/.bash_utils.sh
greet()   { echo "Hello, $1"; }
farewell(){ echo "Goodbye, $1"; }
```

```bash
# In your script or ~/.bashrc / ~/.zshrc
source ~/.bash_utils.sh
# or shorthand:
. ~/.bash_utils.sh

greet "Alice"
farewell "Bob"
```

> Source at shell startup or at the top of scripts that need the library.

---

## Anonymous Functions

A function defined and **immediately invoked** without a name. Useful for scoping variables or one-off logic.

```zsh
# Zsh anonymous function
(){
  local tmp="I'm scoped"
  echo $tmp
}

# With arguments
(){ echo "Args: $@" } one two three
```

```bash
# Bash equivalent using a subshell
(
  local_var="scoped"
  echo $local_var
)
```

> Anonymous functions in Zsh are a clean way to create a local scope without polluting the environment.

---

## Quick Reference

```
$1 $2 ...    Positional parameters
$@           All args (separate)
$#           Argument count
$argv        All args array (Zsh only)
return N     Set exit status (0=ok)
$()          Capture function output
local var    Scope variable to function
typeset var  Zsh/ksh scoping
autoload -Uz Lazy-load function from fpath
source file  Load function library
(){ ... }    Anonymous function (Zsh)
```