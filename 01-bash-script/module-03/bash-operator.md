# Bash — Operators & Expressions 

---

## 1. Expression Contexts

| Context | Syntax | Used For |
|---|---|---|
| Arithmetic eval | `(( ))` | Integer math & conditions |
| Arithmetic value | `$(( ))` | Math that returns a value |
| POSIX test | `[ ]` | File, string, numeric checks |
| Extended test | `[[ ]]` | Bash: regex, glob, safe vars |
| Command sub | `$( )` | Capture command output |
| String ops | `${var...}` | Manipulate strings |

> Every expression returns exit status: `0` = true, non-zero = false

---

## 2. Arithmetic Operators

| Op | Meaning | Example | Result |
|---|---|---|---|
| `+` | Add | `$(( 10+3 ))` | `13` |
| `-` | Subtract | `$(( 10-3 ))` | `7` |
| `*` | Multiply | `$(( 10*3 ))` | `30` |
| `/` | Divide (integer) | `$(( 10/3 ))` | `3` |
| `%` | Modulo | `$(( 10%3 ))` | `1` |
| `**` | Power | `$(( 2**8 ))` | `256` |

```bash
a=15; b=4
echo $(( a + b ))   # 19
echo $(( a / b ))   # 3  ← integer division, no decimals
echo $(( a % b ))   # 3  ← remainder
echo $(( a ** 2 ))  # 225

# Float → use bc or awk
echo "scale=4; 22/7" | bc -l        # 3.1428
awk 'BEGIN { printf "%.4f\n", 22/7 }' # 3.1429
```

---

## 3. `$(( ))` vs `(( ))`

| | `$(( ))` | `(( ))` |
|---|---|---|
| Returns | Numeric value | Exit status (0/1) |
| Use for | Assignment, inline | `if`, `while` conditions |

```bash
sum=$(( 3 + 4 ))         # get value → 7
if (( sum > 5 )); then   # use as condition
    echo "big"
fi
```

---

## 4. `expr` (Legacy — Avoid)

```bash
expr 10 \* 3       # 30  — must escape *
expr length "hi"   # 2
expr substr "Hello" 1 3  # Hel
```
> Slow (forks a process). Use `$(( ))` instead.

---

## 5. `let` Command

```bash
let "x = 5 + 3"   # x=8
let "x++"         # increment
let "x += 10"     # x=19
# ⚠️ let "x=0" returns exit 1 — careful with set -e
```

---

## 6. Numeric Comparison Operators

**In `[ ]` / `[[ ]]`** — use flags:

| Op | Meaning |
|---|---|
| `-eq` | equal |
| `-ne` | not equal |
| `-gt` | greater than |
| `-lt` | less than |
| `-ge` | greater or equal |
| `-le` | less or equal |

**In `(( ))`** — use symbols: `==` `!=` `>` `<` `>=` `<=`

```bash
[ $a -gt $b ]      # POSIX style
(( a > b ))        # cleaner arithmetic style

# ⚠️ Pitfall: string vs numeric
[[ "9" > "10" ]]   # TRUE (lexicographic — wrong!)
(( 9 > 10 ))       # FALSE (correct numeric)
```

---

## 7. String Operators

| Op | Meaning | Context |
|---|---|---|
| `=` / `==` | equal | `[ ]` / `[[ ]]` |
| `!=` | not equal | both |
| `<` / `>` | lexicographic order | `[[ ]]` only |
| `-z` | empty string | both |
| `-n` | non-empty string | both |

```bash
[ "$a" = "$b" ]          # equality (POSIX)
[[ "$a" == "$b" ]]       # equality (Bash)
[ -z "$var" ]            # is empty?
[ -n "$var" ]            # is non-empty?
[[ $file == *.txt ]]     # glob pattern match
echo ${#var}             # string length
```

---

## 8. File Test Operators

| Op | Meaning |
|---|---|
| `-e` | exists (any type) |
| `-f` | regular file |
| `-d` | directory |
| `-L` | symbolic link |
| `-r` / `-w` / `-x` | readable / writable / executable |
| `-s` | non-empty file |
| `-O` / `-G` | owned by user / group |
| `-nt` / `-ot` | newer / older than |
| `-ef` | same inode |

```bash
[ -f "$file" ] && echo "exists"
[ ! -d "/tmp/dir" ] && mkdir /tmp/dir
[ "$f1" -nt "$f2" ] && echo "f1 is newer"
```

---

## 9. Logical Operators

| Context | AND | OR | NOT |
|---|---|---|---|
| `[ ]` | `-a` | `-o` | `!` |
| `[[ ]]` | `&&` | `\|\|` | `!` |
| `(( ))` | `&&` | `\|\|` | `!` |
| Shell (between cmds) | `&&` | `\|\|` | `!` |

```bash
[[ $age -ge 18 && $role == "admin" ]]  # AND
[[ $x -lt 0 || $x -gt 100 ]]          # OR
[ ! -f "/tmp/lock" ]                   # NOT

mkdir /tmp/work && echo "done"         # shell AND
ping -c1 google.com || echo "no net"   # shell OR
```

---

## 10. Bitwise Operators *(inside `(( ))`)*

| Op | Meaning | Example | Result |
|---|---|---|---|
| `&` | AND | `$(( 6 & 3 ))` | `2` |
| `\|` | OR | `$(( 6 \| 3 ))` | `7` |
| `^` | XOR | `$(( 6 ^ 3 ))` | `5` |
| `~` | NOT | `$(( ~5 ))` | `-6` |
| `<<` | Left shift | `$(( 1 << 3 ))` | `8` |
| `>>` | Right shift | `$(( 16 >> 2 ))` | `4` |

```bash
# Permission flags example
READ=4; WRITE=2; EXEC=1
perms=$(( READ | WRITE | EXEC ))  # 7
(( perms & READ ))  && echo "readable"
perms=$(( perms & ~WRITE ))       # remove write → 5
```

---

## 11. Assignment Operators

```bash
x=10             # basic assignment — NO spaces around =

# Compound (inside (( )) or let)
(( x += 5 ))    # x=15
(( x -= 3 ))    # x=12
(( x *= 2 ))    # x=24
(( x /= 4 ))    # x=6
(( x %= 4 ))    # x=2
(( x **= 3 ))   # x=8

# Increment / Decrement
(( x++ ))   # post-increment (use then add)
(( ++x ))   # pre-increment  (add then use)
(( x-- ))   # post-decrement
(( --x ))   # pre-decrement
```

### Conditional Assignment (Parameter Expansion)

| Syntax | Meaning |
|---|---|
| `${var:-default}` | Use default if unset/empty (var unchanged) |
| `${var:=default}` | Assign default if unset/empty |
| `${var:+value}` | Use value only if var IS set |
| `${var:?msg}` | Error + exit if unset/empty |

```bash
name=${NAME:-"guest"}           # fallback silently
echo ${PORT:=8080}              # sets PORT=8080 if empty
${DB_URL:?"DB_URL must be set"} # hard fail if missing
flag=${DEBUG:+"-v"}             # only set if DEBUG exists
```

---

## 12. String Operations (Parameter Expansion)

```bash
str="Hello, World!"

# Length
echo ${#str}              # 13

# Substring  ${var:offset:length}
echo ${str:0:5}           # Hello
echo ${str:7}             # World!
echo ${str: -6}           # orld!  (from end)

# Remove prefix/suffix
path="/home/user/file.txt"
echo ${path##*/}          # file.txt      (longest prefix removed)
echo ${path%/*}           # /home/user    (shortest suffix removed)

filename="archive.tar.gz"
echo ${filename%.*}       # archive.tar   (remove last extension)
echo ${filename%%.*}      # archive       (remove all extensions)

# Replace
msg="I love bash and bash is great"
echo ${msg/bash/Python}   # replace first
echo ${msg//bash/Python}  # replace all

# Case conversion (Bash 4+)
s="Hello World"
echo ${s,,}   # hello world  (lowercase)
echo ${s^^}   # HELLO WORLD  (uppercase)
echo ${s~~}   # hELLO wORLD  (toggle)
```

---

## 13. Regex Matching `=~`

```bash
[[ string =~ regex ]]   # ⚠️ never quote the regex!
```

```bash
# BASH_REMATCH[0] = full match, [1],[2]... = capture groups

[[ "abc123" =~ ^[a-z]+([0-9]+)$ ]] && echo "${BASH_REMATCH[1]}"  # 123

# Common patterns
[[ $var =~ ^[0-9]+$ ]]             # integer
[[ $var =~ ^[a-zA-Z0-9._%+-]+@.+\.[a-zA-Z]{2,}$ ]]  # email

# Log parser
line="2024-08-15 ERROR Connection refused"
if [[ $line =~ ^([0-9-]+)[[:space:]]([A-Z]+)[[:space:]](.+)$ ]]; then
    echo "Date:  ${BASH_REMATCH[1]}"
    echo "Level: ${BASH_REMATCH[2]}"
    echo "Msg:   ${BASH_REMATCH[3]}"
fi
```

---

## 14. Ternary-Style Expressions

```bash
# Arithmetic ternary (returns number)
result=$(( x > 5 ? 1 : 0 ))

# && || one-liner (simple cases only)
[[ $x -gt 5 ]] && echo "big" || echo "small"

# Safe version — if inside $()
label=$(if [[ $x -gt 5 ]]; then echo "big"; else echo "small"; fi)

# Default value as ternary
user=${USERNAME:-"anonymous"}
```

> ⚠️ `cond && A || B` is unsafe if `A` can fail — `B` runs even when condition is true.

---

## 15. Command Substitution `$( )`

```bash
today=$(date +%Y-%m-%d)
echo "Running as $(whoami) on $(hostname)"
lines=$(wc -l < /etc/passwd)
owner=$(stat -c "%U" $(which bash))   # nested — clean with $()
```
> Avoid backticks `` `cmd` `` — hard to nest and read.

---

## 16. Process Substitution `<( )`

```bash
# Treat command output as a file — no temp files needed
diff <(sort file1.txt) <(sort file2.txt)
diff <(grep "ERROR" log1.txt) <(grep "ERROR" log2.txt)

# while loop without subshell issues
while IFS= read -r line; do
    echo "$line"
done < <(find /tmp -name "*.log")
```

---

## 17. Operator Precedence *(High → Low inside `(( ))`)*

```
++ --  ~  !  (unary)
**
*  /  %
+  -
<<  >>
<  <=  >  >=
==  !=
&  →  ^  →  |
&&  →  ||
=  +=  -=  (assignments)
```

```bash
echo $(( 2 + 3 * 4 ))      # 14  (not 20)
echo $(( (2 + 3) * 4 ))    # 20  (parens override)
echo $(( 2 * 3 ** 2 ))     # 18  (** before *)
```

---

## Quick Reference

### Which tool for arithmetic?
| Need | Use |
|---|---|
| Get value / assign | `$(( ))` |
| Condition in if/while | `(( ))` |
| Modify var in place | `(( x+=1 ))` or `let` |
| Float math | `bc -l` or `awk` |

### Common Pitfalls
| Mistake | Fix |
|---|---|
| `x = 5` | `x=5` (no spaces) |
| `echo $a + $b` | `echo $(( a + b ))` |
| `[ $a > $b ]` (numeric) | `(( a > b ))` or `[ $a -gt $b ]` |
| `[[ $s =~ "pattern" ]]` | `[[ $s =~ pattern ]]` (no quotes) |
| `expr $a * $b` | `expr $a \* $b` or `$(( a * b ))` |
| Integer division truncates | Use `bc` for decimals |

---

> **Golden Rules**
> - `$(( ))` → value &nbsp;&nbsp; `(( ))` → condition
> - Use `[[ ]]` over `[ ]` in Bash scripts
> - Never quote regex in `=~`
> - Always quote `"$var"` inside `[ ]`
> - Float math → `bc -l` or `awk`