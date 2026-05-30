# 🔀 Module 4: Conditional Statements in Bash
> Bash Scripting Series | `scripting-mastery-lab`

---

## 1. `if / elif / else`

```bash
#!/bin/bash
marks=75

if [ $marks -ge 90 ]; then
    echo "Grade: A"
elif [ $marks -ge 60 ]; then
    echo "Grade: B"
else
    echo "Grade: C"
fi
```

> ⚠️ Always put **spaces** inside `[ ]` — `[$var]` will throw an error.

---

## 2. Nested Conditionals

```bash
age=20
employed=true

if [ $age -ge 18 ]; then
    if [ $employed = true ]; then
        echo "Eligible for loan"
    else
        echo "Need employment"
    fi
fi
```

> 💡 Prefer `&&` / `||` over deep nesting for cleaner code.

---

## 3. Test Commands: `[ ]` vs `[[ ]]` vs `test`

| Feature | `test` / `[ ]` | `[[ ]]` |
|---|---|---|
| POSIX standard | ✅ Yes | ❌ Bash only |
| Regex match (`=~`) | ❌ No | ✅ Yes |
| Pattern match (`*`) | ❌ No | ✅ Yes |
| No quoting needed | ❌ Needs quotes | ✅ Safer |
| `&&` / `\|\|` inside | ❌ No | ✅ Yes |

```bash
name="Hacker"

# [ ] style — POSIX
[ "$name" = "Hacker" ] && echo "Match"

# [[ ]] style — Bash preferred
[[ $name == H* ]] && echo "Starts with H"

# Regex with [[
[[ $name =~ ^H[a-z]+ ]] && echo "Regex matched"
```

> ✅ **Use `[[ ]]` in Bash scripts** — safer, more powerful.

---

## 4. `case ... esac` Pattern Matching

```bash
read -p "Enter day: " day

case $day in
    Monday|Tuesday|Wednesday|Thursday|Friday)
        echo "Weekday" ;;
    Saturday|Sunday)
        echo "Weekend" ;;
    *)
        echo "Invalid day" ;;
esac
```

**Syntax rules:**
- Each pattern ends with `)`
- Each block ends with `;;`
- `*` is the default/fallback case
- Multiple patterns use `|` as OR

> 💡 `case` is cleaner than a long `if-elif` chain for menu-driven scripts.

---

## 5. Short-Circuit Evaluation: `&&` and `||`

```bash
# && → run second command ONLY if first succeeds (exit 0)
mkdir mydir && echo "Directory created"

# || → run second command ONLY if first fails (non-zero exit)
cd mydir || echo "Failed to enter directory"

# Combined — very common pattern
[ -f config.txt ] && echo "File exists" || echo "File missing"
```

| Operator | Runs next command when... |
|---|---|
| `&&` | Previous command **succeeded** |
| `\|\|` | Previous command **failed** |

> ⚠️ `cmd1 && cmd2 || cmd3` is NOT a true ternary — if `cmd2` fails, `cmd3` also runs.

---

## 6. Ternary-Style Operations

Bash has no native ternary operator, but these patterns replicate it:

```bash
age=20

# Pattern 1: && || style
[ $age -ge 18 ] && echo "Adult" || echo "Minor"

# Pattern 2: Arithmetic ternary (numbers only)
result=$(( age >= 18 ? 1 : 0 ))
echo $result    # 1

# Pattern 3: Variable assignment
status=$( [ $age -ge 18 ] && echo "Adult" || echo "Minor" )
echo $status
```

---

## 🔢 Comparison Operators Quick Reference

### Numeric
| Operator | Meaning |
|---|---|
| `-eq` | Equal to |
| `-ne` | Not equal |
| `-gt` | Greater than |
| `-lt` | Less than |
| `-ge` | Greater or equal |
| `-le` | Less or equal |

### String
| Operator | Meaning |
|---|---|
| `=` or `==` | Equal |
| `!=` | Not equal |
| `-z` | Empty string |
| `-n` | Non-empty string |
| `<` / `>` | Lexicographic compare (use in `[[ ]]`) |

### File Tests
| Operator | Meaning |
|---|---|
| `-f` | Is a regular file |
| `-d` | Is a directory |
| `-e` | Exists |
| `-r` / `-w` / `-x` | Readable / Writable / Executable |

---

## ⚡ Cheat Sheet

```bash
# if-elif-else
if [ condition ]; then ... elif [ condition ]; then ... else ... fi

# case
case $var in pattern) commands ;; *) default ;; esac

# short-circuit
cmd1 && cmd2       # run cmd2 if cmd1 succeeds
cmd1 || cmd2       # run cmd2 if cmd1 fails

# ternary style
[ condition ] && echo "yes" || echo "no"
result=$(( x > 0 ? 1 : 0 ))
```

---

<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)

---
**Made with ❤️ for the Open Source Community**