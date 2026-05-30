# Module 7: Regular Expressions & Globbing

## Basic Syntax & Special Characters

| Character | Meaning |
|-----------|---------|
| `.` | Any single character |
| `*` | Zero or more of previous |
| `^` | Start of line |
| `$` | End of line |
| `[]` | Character class |
| `\` | Escape special character |

```bash
grep "c.t" file.txt      # matches cat, cut, cot
grep "^hello" file.txt   # lines starting with hello
grep "end$" file.txt     # lines ending with end
```

---

## Character Classes

```bash
[a-z]    # lowercase letter
[A-Z]    # uppercase letter
[0-9]    # any digit
[a-zA-Z] # any letter
[^abc]   # NOT a, b, or c
[^0-9]   # NOT a digit
```

---

## Quantifiers

| Quantifier | Meaning |
|------------|---------|
| `*` | 0 or more |
| `+` | 1 or more |
| `?` | 0 or 1 (optional) |
| `{n}` | Exactly n times |
| `{n,}` | n or more times |
| `{n,m}` | Between n and m times |

```bash
grep -E "go+gle"     # google, gooogle...
grep -E "colou?r"    # color or colour
grep -E "[0-9]{3}"   # exactly 3 digits
```

> Use `grep -E` or `egrep` for `+`, `?`, `{}`.

---

## Anchors

```bash
^        # start of line
$        # end of line
\b       # word boundary

grep "^root" /etc/passwd       # lines starting with root
grep "\.sh$" file.txt          # lines ending with .sh
grep -E "\bword\b" file.txt    # exact word match
```

---

## Groups & Capturing

```bash
()       # group & capture
\1 \2    # backreference to group 1, 2

# Swap two words
echo "hello world" | sed -E 's/(\w+) (\w+)/\2 \1/'
# Output: world hello
```

---

## Alternation

```bash
|   # OR operator (use with -E or in [[ =~ ]])

grep -E "cat|dog" file.txt       # lines with cat or dog
grep -E "^(yes|no)$" file.txt    # lines that are exactly yes or no
```

---

## POSIX Classes

| Class | Equivalent |
|-------|-----------|
| `[:alnum:]` | `[a-zA-Z0-9]` |
| `[:alpha:]` | `[a-zA-Z]` |
| `[:digit:]` | `[0-9]` |
| `[:space:]` | whitespace |
| `[:upper:]` | `[A-Z]` |
| `[:lower:]` | `[a-z]` |

```bash
grep "[[:digit:]]" file.txt    # lines containing a digit
grep "[[:alpha:]]" file.txt    # lines containing a letter
```

> POSIX classes go **inside** `[]` — always double bracket: `[[:digit:]]`

---

## Regex with Tools

### `grep`
```bash
grep "pattern" file           # basic regex
grep -E "pattern" file        # extended regex (+, ?, |, {})
grep -i "pattern" file        # case-insensitive
grep -v "pattern" file        # invert (lines NOT matching)
```

### `sed`
```bash
sed 's/old/new/' file         # replace first match per line
sed 's/old/new/g' file        # replace all matches
sed -E 's/[0-9]+/NUM/g' file  # extended regex
```

### `awk`
```bash
awk '/pattern/ {print}' file          # print matching lines
awk '$1 ~ /^[0-9]/ {print}' file     # match on field 1
```

### `[[ =~ ]]` (Bash/Zsh)
```bash
str="hello123"
if [[ $str =~ [0-9]+ ]]; then
  echo "Contains numbers"
  echo "Match: ${BASH_REMATCH[0]}"   # Bash
fi
```

---

## Zsh Extended Globbing

Enable with:
```zsh
setopt EXTENDED_GLOB
```

### Recursive Glob
```zsh
**/*        # all files recursively
**/*.log    # all .log files in any subdirectory
```

### Negation
```zsh
^pattern    # everything NOT matching pattern

ls ^*.txt       # all files except .txt
ls ^(foo|bar)   # exclude foo and bar
```

### Case-Insensitive
```zsh
(#i)pattern     # match regardless of case

ls (#i)*.jpg    # matches .jpg .JPG .Jpg
```

### Glob Qualifiers
Appended in `()` at end of glob:

| Qualifier | Meaning |
|-----------|---------|
| `*(.)` | Regular files only |
| `*(/)` | Directories only |
| `*(@)` | Symlinks only |
| `*(om)` | Sort by modification date |
| `*(Lk+100)` | Files larger than 100KB |
| `*(m-1)` | Modified in last 1 day |

```zsh
ls *(.)          # files only, no dirs
ls *(/)          # dirs only
ls *(om)         # sorted by date, newest first
ls *(m-7.)       # files modified in last 7 days
```

---

## Glob Flags

```zsh
setopt NULL_GLOB    # no error if glob matches nothing (silently removes it)
setopt GLOB_DOTS    # include dotfiles (hidden files) in globs
```

```zsh
# Without NULL_GLOB → error if no match
ls *.xyz            # zsh: no matches found

# With NULL_GLOB → no error, just nothing
setopt NULL_GLOB
ls *.xyz            # silently does nothing

# GLOB_DOTS — normally * won't match .hidden files
setopt GLOB_DOTS
ls *                # now includes .bashrc, .zshrc etc.
```

---

## Quick Reference

```
.          any char          ^      line start
*          0 or more         $      line end
+          1 or more         \b     word boundary
?          optional          |      OR
{n,m}      range             ()     group/capture
[a-z]      char class        \1     backreference
[^x]       NOT x             [:digit:] POSIX class

grep -E    extended regex    sed 's/a/b/g'  replace
[[ =~ ]]   regex in shell    **/*   recursive glob
*(.)       files only        *(/)   dirs only
*(om)      sort by date      ^pat   negate (Zsh)
(#i)pat    case-insensitive  NULL_GLOB  no error on empty
```