# Bash — Regular Expressions (Quick Notes)

---

## 1. Regex Flavors

| Flavor | Command | Features |
|---|---|---|
| BRE (Basic) | `grep` | `+`, `?`, `\|` need `\` to escape |
| ERE (Extended) | `grep -E` | `+`, `?`, `\|` work directly ✅ |
| PCRE | `grep -P` | `\d`, `\w`, lookahead/lookbehind ✅ |

```bash
echo "aaa" | grep 'a\+'       # BRE  — must escape +
echo "aaa" | grep -E 'a+'     # ERE  — clean ✅
echo "abc" | grep -P '\w+'    # PCRE — shorthand classes
```
> ✅ Use `grep -E` for everyday scripts. Use `grep -P` only for `\d`, `\w`, lookahead.

---

## 2. Anchors

| Symbol | Meaning |
|---|---|
| `^` | Start of line |
| `$` | End of line |
| `^...$` | Exact match (whole line) |
| `\b` | Word boundary |
| `\B` | Non-word boundary |

```bash
grep '^error' file.txt          # line starts with "error"
grep '\.sh$' file.txt           # line ends with ".sh"
grep '^error$' file.txt         # line is EXACTLY "error"
grep '^$' file.txt              # blank lines only
grep -P '\bword\b' file.txt     # whole word match
```

---

## 3. Character Classes

| Pattern | Matches |
|---|---|
| `[abc]` | a, b, or c |
| `[^abc]` | NOT a, b, or c |
| `[a-z]` | any lowercase letter |
| `[0-9]` | any digit |
| `[a-zA-Z0-9]` | alphanumeric |

```bash
echo "cat" | grep -E '[cbh]at'          # matches cat/bat/hat
grep '^[^0-9]' file.txt                 # line not starting with digit
echo "Hello123" | grep -oE '[a-z]+'    # ello
echo "#FF5733" | grep -E '^#[0-9A-Fa-f]{6}$'  # hex color
```

---

## 4. POSIX Classes

| Class | Equivalent | Matches |
|---|---|---|
| `[[:alpha:]]` | `[a-zA-Z]` | Letters |
| `[[:digit:]]` | `[0-9]` | Digits |
| `[[:alnum:]]` | `[a-zA-Z0-9]` | Letters + digits |
| `[[:space:]]` | `[ \t\n\r]` | Whitespace |
| `[[:upper:]]` | `[A-Z]` | Uppercase |
| `[[:lower:]]` | `[a-z]` | Lowercase |
| `[[:punct:]]` | `[.,!?...]` | Punctuation |
| `[[:blank:]]` | `[ \t]` | Space or tab |

```bash
grep '[[:digit:]]' file.txt                        # has a digit
grep '^[[:alpha:]]*$' file.txt                     # only letters
echo "Hi, World!" | sed 's/[[:punct:]]//g'        # remove punctuation
```

---

## 5. Quantifiers

| Symbol | Meaning |
|---|---|
| `*` | 0 or more |
| `+` | 1 or more |
| `?` | 0 or 1 (optional) |
| `{n}` | exactly n |
| `{n,}` | n or more |
| `{n,m}` | between n and m |
| `*?` / `+?` | lazy (non-greedy) |

```bash
echo "aaab"  | grep -E 'a*b'               # 0 or more a's before b
echo "250"   | grep -oE '[0-9]+'           # 1+ digits
echo "color" | grep -E 'colo(u)?r'         # u is optional
echo "123"   | grep -E '^[0-9]{3}$'        # exactly 3 digits
echo "hi"    | grep -E '^.{8,16}$'         # 8-16 chars (password check)

# Greedy vs Lazy
echo "<b>text</b>" | grep -oP '<.*>'       # greedy → whole string
echo "<b>text</b>" | grep -oP '<.*?>'      # lazy   → one tag at a time
```

---

## 6. Dot `.` — Wildcard

- Matches **any single character** except newline
- Escape with `\.` to match a **literal dot**

```bash
echo "cat" | grep -E 'c.t'        # any char between c and t
echo "192.168.1.1" | grep '192\.168'   # literal dot ✅
echo "192X168X1X1" | grep '192\.168'   # no match ✅
```
> ⚠️ Always escape `.` in IPs, file extensions, domains.

---

## 7. Alternation `|`

```bash
echo "cat" | grep -E 'cat|dog'                    # cat OR dog
grep -E 'ERROR|WARNING|CRITICAL' system.log       # multiple levels
ls | grep -E '\.jpg$|\.png$|\.gif$'               # file extensions

# Use grouping to limit scope
echo "I like cats" | grep -E 'I like (cats|dogs)'
```
> ⚠️ `cat|dog food` means `cat` OR `dog food` — use `(cat|dog) food` to group.

---

## 8. Grouping & Capturing

```bash
# Grouping — apply quantifier to whole group
echo "colour" | grep -E 'col(ou)?r'       # 'ou' is optional
echo "ababab" | grep -E '^(ab){3}$'       # repeat group 3 times
echo "cat"    | grep -E '^(cat|dog)$'     # group with alternation

# Non-capturing group (?:) — group without storing
echo "foobar" | grep -P '(?:foo)(bar)'    # only 'bar' is captured
```

---

## 9. Backreferences

Refer to what a group already matched using `\1`, `\2`, etc.

```bash
# Find duplicate words
echo "the the quick fox" | grep -E '(\b\w+\b) \1'   # "the the"

# Find repeated characters
echo "aabbcc" | grep -oE '(.)\1'   # aa bb cc

# sed — swap words
echo "John Smith" | sed -E 's/(\w+) (\w+)/\2 \1/'   # Smith John

# sed — add quotes around each word
echo "hello world" | sed -E 's/(\w+)/"\1"/g'         # "hello" "world"
```

---

## 10. `grep` — Key Flags

| Flag | Meaning |
|---|---|
| `-E` | ERE mode |
| `-P` | PCRE mode |
| `-i` | Case insensitive |
| `-v` | Invert match |
| `-o` | Print matched part only |
| `-n` | Show line numbers |
| `-c` | Count matching lines |
| `-w` | Whole word match |
| `-r` | Recursive search |
| `-l` | List filenames only |

```bash
grep -i 'error' log.txt              # case insensitive
grep -v '^#' config.txt              # skip comments
grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' file  # extract IPs
grep -n 'fail' log.txt               # show line numbers
grep -c 'error' log.txt              # count error lines
grep -rn 'TODO' ./src/               # recursive with line numbers
grep -w 'cat' file.txt               # whole word only
```

---

## 11. `sed` — Key Commands

```bash
# Replace first / all / case-insensitive
echo "foo foo" | sed 's/foo/bar/'        # bar foo
echo "foo foo" | sed 's/foo/bar/g'       # bar bar
echo "FOO foo" | sed 's/foo/bar/gi'      # bar bar

# Delete lines
sed '/^#/d' file.txt                     # remove comments
sed '/^$/d' file.txt                     # remove blank lines
sed '/debug/d' logfile.txt               # remove debug lines

# Print specific lines
sed -n '5,10p' file.txt                  # lines 5 to 10
sed -n '/error/p' logfile.txt            # lines matching "error"

# Capture groups
echo "John Smith" | sed -E 's/(\w+) (\w+)/\2, \1/'   # Smith, John
echo "9876543210" | sed -E 's/([0-9]{10})/[\1]/'      # [9876543210]

# In-place edit
sed -i 's/http/https/g' config.txt       # edit file directly
sed -i.bak 's/http/https/g' config.txt   # with backup
```

---

## 12. `awk` — Regex Operations

```bash
# Match whole line
awk '/error/' file.txt
awk '!/debug/' file.txt                  # NOT matching

# Match specific field
awk '$1 ~ /^GET/' access.log            # field 1 starts with GET
awk '$2 ~ /^[0-9]+$/' file.txt          # field 2 is digits
awk '$3 !~ /fail/' results.txt          # field 3 has no "fail"

# gsub — replace all in line
awk '{gsub(/foo/, "bar"); print}' file.txt
awk '{gsub(/[0-9]+/, "X"); print}' file.txt

# sub — replace first only
awk '{sub(/foo/, "bar"); print}' file.txt

# match() — find position
awk '{if (match($0, /[0-9]+/)) print RSTART, RLENGTH}' file.txt
```

---

## 13. Bash `[[ =~ ]]`

```bash
[[ string =~ pattern ]]   # ⚠️ NEVER quote the pattern!
```

```bash
# Basic match
[[ "hello123" =~ ^[a-z]+[0-9]+$ ]] && echo "match"

# Input validation
[[ $num =~ ^[0-9]+$ ]]                      # is integer?
[[ $email =~ ^[a-zA-Z0-9._%+-]+@.+\..+$ ]] # is email?
[[ $name =~ ^[A-Z] ]]                       # starts with capital?
[[ $uname =~ ^[a-zA-Z][a-zA-Z0-9_]{2,14}$ ]] # valid username?

# BASH_REMATCH — capture groups
text="Today is 2025-01-15"
if [[ $text =~ ([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
    echo "Year:  ${BASH_REMATCH[1]}"   # 2025
    echo "Month: ${BASH_REMATCH[2]}"   # 01
    echo "Day:   ${BASH_REMATCH[3]}"   # 15
fi
```

---

## 14. Lookahead & Lookbehind *(PCRE only — `grep -P`)*

| Syntax | Name | Meaning |
|---|---|---|
| `(?=p)` | Positive lookahead | followed by p |
| `(?!p)` | Negative lookahead | NOT followed by p |
| `(?<=p)` | Positive lookbehind | preceded by p |
| `(?<!p)` | Negative lookbehind | NOT preceded by p |

```bash
# Numbers followed by "px" only
echo "12px 34em 56px" | grep -oP '[0-9]+(?=px)'     # 12 56

# Numbers NOT followed by "px"
echo "12px 34em 56px" | grep -oP '[0-9]+(?!px)'     # 34

# Numbers after "$"
echo "$99 and 200g" | grep -oP '(?<=\$)[0-9]+'      # 99

# Numbers NOT after "$"
echo "$99 and 200g" | grep -oP '(?<!\$)[0-9]+'      # 200
```

---

## 15. Practical Patterns

```bash
# IPv4
[[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]

# Email
[[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]

# Indian mobile (starts 6-9, 10 digits)
[[ $phone =~ ^[6-9][0-9]{9}$ ]]

# Hex color
[[ $color =~ ^#[0-9A-Fa-f]{6}$ ]]

# Extract date from text
echo "Log: 2025-01-15" | grep -oP '\d{4}-\d{2}-\d{2}'

# Extract URLs
echo "Visit https://site.com" | grep -oP 'https?://[^\s]+'

# Extract all emails from file
grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt

# Remove blank lines
sed '/^[[:space:]]*$/d' file.txt

# Find duplicate words
echo "the the quick fox" | grep -oP '\b(\w+)\b(?=.*\b\1\b)'

# Password strength check
[[ ${#pass} -ge 8 ]]            || echo "Too short"
[[ $pass =~ [A-Z] ]]            || echo "Need uppercase"
[[ $pass =~ [0-9] ]]            || echo "Need digit"
[[ $pass =~ [^a-zA-Z0-9] ]]     || echo "Need special char"
```

---

## Cheat Sheet

```
# Anchors
^        start of line        $        end of line
\b       word boundary        \B       non-word boundary

# Quantifiers
*        0 or more            +        1 or more
?        0 or 1               {n}      exactly n
{n,}     n or more            {n,m}    n to m
*?       lazy 0 or more       +?       lazy 1 or more

# Character Classes
.        any char             [abc]    a, b, or c
[^abc]   not a,b,c            [a-z]    range

# PCRE Shorthand
\d  digit     \D  non-digit
\w  word      \W  non-word
\s  space     \S  non-space

# Groups
(abc)     capture group       (?:abc)  non-capturing
\1 \2     backreference

# Lookaround (PCRE)
(?=p)    lookahead            (?!p)    negative lookahead
(?<=p)   lookbehind           (?<!p)   negative lookbehind
```

---

> **Golden Rules**
> - Use `grep -E` (ERE) by default — cleaner syntax
> - Use `grep -P` only when you need `\d`, `\w`, or lookaround
> - Never quote regex in `[[ =~ ]]` — it breaks pattern matching
> - Always escape `.` when matching literal dots (IPs, domains)
> - `^` inside `[ ]` means NOT — `[^abc]` means not a, b, or c
> - Test `sed` without `-i` first before editing files in-place