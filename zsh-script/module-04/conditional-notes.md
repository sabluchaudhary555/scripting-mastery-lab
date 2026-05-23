# Zsh Conditional Statements — Quick Notes

## How Conditions Work
Every command returns an **exit status** — `0` = true, non-zero = false.
```zsh
ls /etc/passwd; print $?   # → 0 (success)
ls /nope;       print $?   # → 1 (failure)
true;  print $?            # → 0
false; print $?            # → 1
```

---

## if Statement
```zsh
if [ condition ]; then
    commands
fi
```
- Spaces inside `[ ]` are **mandatory**
- `fi` always required to close

```zsh
temperature=35
if [ $temperature -gt 30 ]; then
    print "It's hot!"
fi
```

---

## if-else
```zsh
if (( n % 2 == 0 )); then
    print "Even"
else
    print "Odd"
fi
```

---

## if-elif-else
```zsh
if (( marks >= 90 ));   then print "A+"
elif (( marks >= 80 )); then print "A"
elif (( marks >= 70 )); then print "B"
else                         print "F"
fi
```
Only **first matching** block runs. Rest are skipped.

---

## [ ] vs [[ ]] vs (( ))

| Need | Use |
|---|---|
| POSIX portability | `[ ]` |
| Strings, regex, glob | `[[ ]]` |
| Math comparisons | `(( ))` |
| Real command check | `if command` directly |

---

## [[ ]] — Preferred in Zsh
```zsh
# Glob match
[[ $file == *.csv ]]         # DON'T quote the pattern

# Regex match
[[ $email =~ ^[a-z]+@[a-z]+\.[a-z]{2,}$ ]]
# DON'T quote the regex either

# Capture groups → $match array
[[ "2026-05-18" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]
print $match[1]   # 2026 (year)
print $match[2]   # 05   (month)

# Safe even when var is empty
[[ $var == "hello" ]]   # no error if $var is empty
```

---

## (( )) — Arithmetic
```zsh
if (( x > 5 && x < 100 )); then print "in range"; fi
if (( n % 2 == 0 ));        then print "even"; fi
if (( 2**8 == 256 ));       then print "correct"; fi
```
⚠️ `(( 0 ))` = **false**, any non-zero = **true** (opposite of what you'd expect)

---

## case Statement
```zsh
case $variable in
    pattern1)     commands ;;
    pat2 | pat3)  commands ;;
    *.txt)        print "text file" ;;
    *)            print "default" ;;   # catch-all
esac
```

Fall-through (Zsh-specific):
```zsh
;&    # run next block unconditionally
;;&   # test AND run next matching blocks
;;    # normal stop (always use this by default)
```

---

## File Tests
```zsh
[[ -e file ]]    # exists           [[ -f file ]]   # regular file
[[ -d file ]]    # directory        [[ -r file ]]   # readable
[[ -w file ]]    # writable         [[ -x file ]]   # executable
[[ -s file ]]    # non-empty        [[ -L file ]]   # symlink
[[ f1 -nt f2 ]]  # f1 newer         [[ -O file ]]   # owned by you
```

---

## Ternary-style
```zsh
# && / || one-liner
[[ $x -gt 5 ]] && print "big" || print "small"

# Arithmetic ternary
result=$(( x > 5 ? 100 : 0 ))

# Default value
display=${name:-"Guest"}   # use "Guest" if $name is empty
```
⚠️ `&&/||` ternary is unsafe if the "true" command can fail — use `if-else` for important logic.

---

## Command as Condition
```zsh
if command -v docker &>/dev/null; then print "docker installed"; fi
if grep -q "ERROR" /var/log/syslog; then print "errors found"; fi
if ping -c1 -q 8.8.8.8 &>/dev/null; then print "online"; fi
```
No brackets needed — just use the command directly.

---

## Guard Clauses (best practice)
```zsh
(( $# == 0 ))  && { print "Usage: $0 <file>"; exit 1; }
[[ ! -f $1 ]]  && { print "Not found: $1";    exit 2; }
[[ ! -r $1 ]]  && { print "No permission";    exit 3; }

# main logic only runs if all guards pass
print "Processing: $1"
```

---

## Safer Scripts
```zsh
setopt ERR_EXIT    # exit if any command fails
setopt NO_UNSET    # error on unset variables
setopt PIPE_FAIL   # catch pipeline failures
```

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| `[$var -gt 5]` no spaces | `[ $var -gt 5 ]` |
| `[ $str = "x" ]` unquoted | `[ "$str" = "x" ]` |
| `[ $a > $b ]` numeric | `(( a > b ))` |
| `[[ $s =~ "pattern" ]]` quoted | `[[ $s =~ pattern ]]` |
| Forgetting `fi` or `;;` | Every `if` needs `fi`, every branch needs `;;` |
| `(( 0 ))` thinking it's true | `0` = false inside `(( ))` |