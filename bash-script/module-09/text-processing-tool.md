# Bash — Text Processing Tools (Quick Notes)

---

## 1. Overview — Unix Text Pipeline

```
Input File / Command Output
      ↓
  cat / head / tail   → View data
      ↓
  grep / awk          → Filter data
      ↓
  cut / tr / sed      → Transform data
      ↓
  sort / uniq         → Organize data
      ↓
  wc / awk            → Summarize data
      ↓
  Output / File / Report
```
> Each tool does **one thing well** — combine them with pipes for powerful pipelines.

---

## 2. `cat` — Display & Concatenate

```bash
cat file.txt                   # display file
cat -n file.txt                # with line numbers
cat -b file.txt                # line numbers (non-blank only)
cat -A file.txt                # show tabs (^I) and line endings ($)

# Combine files
cat f1.txt f2.txt > combined.txt
cat header.txt body.txt footer.txt > full.txt

# Create file with heredoc
cat > config.txt << EOF
host=localhost
port=3306
EOF
```
> ⚠️ Avoid `cat file | grep pattern` — just use `grep pattern file` directly.

---

## 3. `echo` & `printf` — Output Text

```bash
# echo
echo "Hello World"             # basic output
echo -n "No newline: "         # suppress newline
echo -e "Line1\nLine2\tTab"    # enable escape sequences
echo -e "\e[31mRed Text\e[0m"  # ANSI color
```

```bash
# printf — precise formatting (no newline by default)
printf "Hello, %s!\n" "Hacker"
printf "%-15s %3d\n" "Hacker" 20    # left-align str, right-align int
printf "Pi = %.4f\n" 3.14159        # Pi = 3.1416
printf "%05d\n" 42                  # 00042 (zero-padded)
```

| Specifier | Meaning |
|---|---|
| `%s` | String |
| `%d` | Integer |
| `%f` | Float |
| `%-10s` | Left-aligned, 10 wide |
| `%05d` | Zero-padded integer |

> ✅ Use `printf` for tables/reports. Use `echo` for simple messages.

---

## 4. `head` & `tail` — View Parts of File

```bash
# head — beginning of file
head file.txt                  # first 10 lines (default)
head -n 5 file.txt             # first 5 lines
head -n -3 file.txt            # all except last 3 lines
head -c 100 file.txt           # first 100 bytes

# tail — end of file
tail file.txt                  # last 10 lines
tail -n 20 file.txt            # last 20 lines
tail -n +2 data.csv            # skip first line (CSV header)
tail -f /var/log/syslog        # follow live — real-time log monitoring
tail -F /var/log/app.log       # follow + retry if file is recreated

# Extract middle lines
head -n 30 file.txt | tail -n 11    # lines 20–30
```
> 💡 `tail -f` is used every day in real server work to watch live logs.

---

## 5. `wc` — Count Lines, Words, Chars

```bash
wc file.txt                    # lines  words  bytes  filename
wc -l file.txt                 # lines only
wc -w file.txt                 # words only
wc -c file.txt                 # bytes
wc -m file.txt                 # characters (handles multibyte)
wc -L file.txt                 # length of longest line

wc -l /etc/passwd              # how many users
ls /etc | wc -l                # how many files in /etc
wc -l file1.txt file2.txt      # per-file + total
```
> 💡 `wc -l < file.txt` (with `<`) skips printing filename — just the number.

---

## 6. `sort` — Sort Lines

```bash
sort file.txt                  # alphabetical (default)
sort -r file.txt               # reverse
sort -n file.txt               # numeric (correct: 2 9 10 100)
sort -rn file.txt              # reverse numeric
sort -f file.txt               # case-insensitive
sort -u file.txt               # sort + remove duplicates
sort -h file.txt               # human-readable sizes (K M G)

# Sort by field — -k field, -t delimiter
sort -t: -k3 -n /etc/passwd    # by UID (field 3, : delimiter)
sort -t',' -k2 data.csv        # CSV by column 2
sort -t: -k1,1 -k3,3n file    # primary + secondary key

# In-place sort
sort -o file.txt file.txt
```

> ⚠️ Without `-n`, numbers sort as strings: `10, 100, 2, 9` — always use `-n` for numbers.

---

## 7. `uniq` — Remove Duplicates

```bash
sort file.txt | uniq           # remove ALL duplicates (sort first!)
sort file.txt | uniq -c        # count occurrences
sort file.txt | uniq -d        # show only duplicates
sort file.txt | uniq -u        # show only unique (appear once)
sort file.txt | uniq -i        # case-insensitive

# Most frequent IPs
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

> ⚠️ `uniq` only removes **adjacent** duplicates — always `sort` first.

| Flag | Meaning |
|---|---|
| (none) | Remove duplicates |
| `-c` | Count occurrences |
| `-d` | Only duplicates |
| `-u` | Only unique lines |

---

## 8. `cut` — Extract Fields/Columns

```bash
# By character position
cut -c1-5 file.txt             # chars 1 to 5
cut -c1,5,10 file.txt          # chars 1, 5, and 10
cut -c3- file.txt              # from char 3 to end

# By field + delimiter (-d and -f)
cut -d: -f1 /etc/passwd        # field 1 (username)
cut -d: -f1,3,6 /etc/passwd    # fields 1, 3, 6
cut -d: -f1-4 /etc/passwd      # fields 1 through 4
cut -d: -f3- /etc/passwd       # field 3 to end
cut -d',' -f2 data.csv         # CSV column 2

# All shells used on system
cut -d: -f7 /etc/passwd | sort | uniq -c | sort -rn
```
> ⚠️ `cut` can't handle variable whitespace — use `awk` for complex splitting.

---

## 9. `paste` — Merge Lines/Files

```bash
paste names.txt ages.txt           # merge side by side (tab-separated)
paste -d',' names.txt ages.txt     # comma delimiter
paste -d'|' f1.txt f2.txt f3.txt   # multiple files

paste - - < file.txt               # group into 2 columns
paste - - - < file.txt             # group into 3 columns
paste -s names.txt                 # all lines in one row (serial)
paste -s -d',' names.txt           # Alice,Bob,Carol
```

---

## 10. `tr` — Translate Characters

```bash
# Replace / convert
echo "hello" | tr 'a-z' 'A-Z'          # HELLO
echo "HELLO" | tr '[:upper:]' '[:lower:]'  # hello
echo "my file" | tr ' ' '_'            # my_file
echo "hello" | tr 'aeiou' '*'          # h*ll*

# Delete (-d)
echo "abc123" | tr -d '0-9'            # abc
echo "abc123" | tr -d '[:digit:]'      # abc
tr -d '\r' < windows.txt > unix.txt    # fix Windows line endings
echo "a b" | tr -d ' '                # ab

# Squeeze repeated chars (-s)
echo "heeello   world" | tr -s 'e '    # hello world
cat file.txt | tr -s '\n'              # remove extra blank lines

# Complement (-c) — match everything EXCEPT
echo "Hello 123!" | tr -dc '[:alpha:]' # Hellokeepletters only
echo "Hello 123!" | tr -dc '[:alnum:]' # Hello123
```

---

## 11. `grep` — Search Patterns

```bash
# Basic
grep 'error' file.txt              # search
grep -i 'error' file.txt           # case insensitive
grep -v 'debug' file.txt           # invert (exclude)
grep -n 'error' file.txt           # with line numbers
grep -c 'error' file.txt           # count matches
grep -w 'cat' file.txt             # whole word only
grep -o 'ERROR[^:]*' file.txt      # print match only

# Output context
grep -A 3 'error' log.txt          # 3 lines after match
grep -B 2 'error' log.txt          # 2 lines before match
grep -C 2 'error' log.txt          # 2 lines both sides

# Files
grep -l 'error' *.log              # filenames with match
grep -L 'error' *.log              # filenames WITHOUT match
grep -r 'TODO' ./src/              # recursive search
grep -rn 'password' /etc/          # recursive + line numbers

# Multiple patterns
grep -e 'error' -e 'warning' file  # multiple -e flags
grep -E 'error|warning|critical'   # ERE alternation
grep -f patterns.txt file          # patterns from file

# Include/exclude files
grep -r 'error' --include='*.log' /var/
grep -r 'debug' --exclude='*.bak' ./
```

---

## 12. `sed` — Stream Editor

```bash
# Substitution
sed 's/old/new/' file.txt          # replace first per line
sed 's/old/new/g' file.txt         # replace all
sed 's/error/FIXED/gi' file.txt    # case-insensitive, all
sed '3s/old/new/' file.txt         # replace on line 3 only
sed '5,10s/old/new/g' file.txt     # lines 5 to 10

# Delete
sed '/^#/d' file.txt               # delete comment lines
sed '/^$/d' file.txt               # delete blank lines
sed '5d' file.txt                  # delete line 5
sed '5,10d' file.txt               # delete lines 5–10
sed '$d' file.txt                  # delete last line
sed '/error/!d' file.txt           # keep ONLY error lines

# Print (with -n)
sed -n '/error/p' file.txt         # print matching lines
sed -n '5p' file.txt               # print line 5
sed -n '5,10p' file.txt            # print lines 5–10
sed -n '$p' file.txt               # print last line

# Insert / Append
sed '/pattern/i\New line before' file.txt
sed '/pattern/a\New line after' file.txt
sed '1i\First line' file.txt
sed '$a\Last line' file.txt

# In-place edit
sed -i 's/old/new/g' file.txt       # edit file directly
sed -i.bak 's/old/new/g' file.txt   # with .bak backup

# Multiple commands
sed -e 's/foo/bar/g' -e '/debug/d' file.txt
sed 's/foo/bar/g; /debug/d' file.txt
```

---

## 13. `awk` — Pattern Scanning & Processing

```bash
# awk structure
awk 'BEGIN{setup} /pattern/{action} END{summary}' file

# $0=whole line  $1=field1  $NF=last field
# NR=line number  NF=field count  FS=field separator
```

```bash
# Basic field printing
awk '{print $1}' file.txt          # field 1
awk '{print $1, $3}' file.txt      # fields 1 and 3
awk '{print $NF}' file.txt         # last field
awk '{print NR, $0}' file.txt      # with line numbers

# Field separator
awk -F: '{print $1, $3}' /etc/passwd     # username + UID
awk -F',' '{print $2}' data.csv          # CSV column 2
awk -F: 'OFS="," {print $1,$6}' file     # custom output separator

# Pattern matching
awk '/error/' file.txt                   # line contains "error"
awk '!/debug/' file.txt                  # NOT debug
awk '$1 == "GET"' access.log             # exact field match
awk '$3 > 100' data.txt                  # numeric comparison
awk '$2 ~ /^[0-9]+$/' file.txt           # field matches regex
awk 'NR >= 5 && NR <= 10' file.txt       # lines 5 to 10

# Arithmetic
awk '{sum += $1} END {print "Total:", sum}' nums.txt
awk '{sum+=$1; count++} END {print sum/count}' nums.txt
awk 'BEGIN{min=9999} {if($1<min)min=$1} END{print min}' f

# Count occurrences
awk '{count[$1]++} END {for(k in count) print k, count[k]}' f

# String functions
awk '{print length($0)}' file.txt        # line length
awk '{print substr($1,1,3)}' file.txt    # first 3 chars
awk '{print tolower($0)}' file.txt       # lowercase
awk '{gsub(/foo/,"bar"); print}' file    # replace all
awk '{sub(/foo/,"bar"); print}' file     # replace first

# Control flow
awk '{if($3>90) print $1,"PASS"; else print $1,"FAIL"}' marks.txt
awk '/^#/ {next} {print}' file.txt       # skip comments

# BEGIN / END
awk 'BEGIN{print "=== Report ==="} {print $1} END{print NR,"lines"}' f
```

---

## 14. `find` — Search Files

```bash
# By name
find . -name "*.log"               # wildcard name
find . -iname "*.LOG"              # case-insensitive
find . -type f -name "*.sh"        # files only
find . -type d -name "logs"        # directories only
find . -type l                     # symlinks

# By size
find /var -type f -size +100M      # larger than 100MB
find . -type f -size -1k           # smaller than 1KB

# By time
find . -mtime -7                   # modified in last 7 days
find . -mtime +30                  # modified more than 30 days ago
find . -newer reference.txt        # newer than a file

# By permissions
find / -perm -4000 -type f 2>/dev/null   # SUID files
find / -perm -o+w -type f 2>/dev/null   # world-writable

# Execute on results
find . -name "*.tmp" -exec rm {} \;      # delete found files
find . -name "*.sh" -exec chmod 755 {} \; # fix permissions
find . -name "*.log" -exec ls -lh {} \;  # list details

# Combine conditions
find . -type f -name "*.log" -size +1M   # AND (default)
find . -name "*.jpg" -o -name "*.png"    # OR
find . -not -name "*.tmp"                # NOT
```

---

## 15. `xargs` — Build Commands from Input

```bash
# Basic — pass stdin as arguments to command
find . -name "*.tmp" | xargs rm         # delete found files
ls *.txt | xargs wc -l                  # wc on all .txt files

# One at a time (-n 1)
cat servers.txt | xargs -n 1 ping -c1  # ping each server

# N at a time
cat items.txt | xargs -n 2 echo        # 2 items per command call

# Handle spaces in filenames (-print0 + -0)
find . -name "*.txt" -print0 | xargs -0 rm    # null-safe ✅

# Placeholder with -I {}
cat servers.txt | xargs -I{} ssh {} "uptime"

# Parallel execution (-P)
cat urls.txt | xargs -P 4 -n 1 wget    # 4 downloads at a time
find . -name "*.log" | xargs -P 8 -n 1 gzip  # parallel compress
```
> ⚠️ Always use `-print0 | xargs -0` when filenames may contain spaces.

---

## 16. `diff` & `patch` — Compare Files

```bash
# diff — show differences
diff file1.txt file2.txt           # basic diff
diff -u file1.txt file2.txt        # unified format (like git diff)
diff -y file1.txt file2.txt        # side-by-side
diff -w file1.txt file2.txt        # ignore whitespace
diff -i file1.txt file2.txt        # ignore case
diff -r dir1/ dir2/                # compare directories
diff -rq dir1/ dir2/               # only report which files differ

# patch — apply differences
diff -u original.txt modified.txt > changes.patch   # create patch
patch original.txt < changes.patch                  # apply patch
patch -R original.txt < changes.patch               # undo patch
```

---

## 17. String Manipulation (Parameter Expansion)

```bash
str="Hello World"

# Length
echo ${#str}              # 11

# Substring  ${var:start:length}
echo ${str:0:5}           # Hello
echo ${str:6}             # World
echo ${str:6:3}           # Wor
echo ${str: -5}           # World (last 5)

# Replace
echo ${str/World/Bash}    # Hello Bash       (first match)
echo ${str//l/L}          # HeLLo WorLd      (all matches)
echo ${str/#Hello/Hi}     # Hi World         (at start)
echo ${str/%World/Bash}   # Hello Bash       (at end)

# Case (Bash 4+)
echo ${str,,}             # hello world      (all lower)
echo ${str^^}             # HELLO WORLD      (all upper)
echo ${str,}              # hello World      (first char lower)
echo ${str^}              # Hello World      (first char upper)

# Remove prefix/suffix
file="report_2025.tar.gz"
echo ${file#*.}           # 2025.tar.gz      (remove shortest prefix)
echo ${file##*.}          # gz               (remove longest prefix)
echo ${file%.*}           # report_2025.tar  (remove shortest suffix)
echo ${file%%.*}          # report_2025      (remove longest suffix)

# Practical
echo ${file%.sh}          # remove .sh extension
echo ${file##*.}          # get extension only

# Default values
echo ${name:-"Anonymous"}     # use default if unset/empty
echo ${name:="Anonymous"}     # set default if unset/empty
echo ${name:?"Required!"}     # error + exit if unset
```

---

## 18. Practical Pipelines

```bash
# Top 10 most active IPs from Apache log
awk '{print $1}' /var/log/apache2/access.log \
    | sort | uniq -c | sort -rn | head -10

# Find + replace across multiple files
find . -name "*.txt" -exec sed -i 's/old/new/g' {} \;

# Count log levels (ERROR, WARNING, INFO)
grep -oP '(ERROR|WARNING|INFO|DEBUG)' app.log \
    | sort | uniq -c | sort -rn

# Extract all email addresses from files
grep -roh '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' . \
    | sort | uniq

# Generate CSV report from /etc/passwd
awk -F: 'BEGIN{print "Username,UID,Home,Shell"}
         {print $1","$3","$6","$7}' /etc/passwd > users.csv

# Find large files and log them
find /var -type f -size +50M \
    | xargs ls -lh 2>/dev/null \
    | awk '{print $5, $9}' | sort -rh | tee large_files.log

# Word frequency counter
cat essay.txt \
    | tr '[:upper:]' '[:lower:]' \
    | tr -s '[:space:][:punct:]' '\n' \
    | grep -v '^$' \
    | sort | uniq -c | sort -rn | head -20

# Disk usage summary
du -sh /var/log/* 2>/dev/null \
    | sort -rh | head -10 \
    | awk '{printf "%-10s %s\n", $1, $2}'
```

---

## Cheat Sheet

```
# cat
cat -n file          line numbers
cat f1 f2 > out      concatenate
cat -A file          show special chars

# head / tail
head -n 5 file       first 5 lines
head -n -3 file      all except last 3
tail -n +2 file      skip header line
tail -f file         follow live log

# wc
wc -l file           count lines
wc -w file           count words
wc -c file           count bytes

# sort
sort -n file         numeric sort
sort -rn file        reverse numeric
sort -u file         sort + unique
sort -t: -k3 -n f   by field 3

# uniq
sort f | uniq        remove duplicates
uniq -c              count each
uniq -d              only duplicates
uniq -u              only unique

# cut
cut -c1-5 file       chars 1–5
cut -d: -f1 file     field 1 (: delim)
cut -d, -f2,4 file   CSV fields 2,4

# tr
tr 'a-z' 'A-Z'       uppercase
tr -d '0-9'          delete digits
tr -s ' '            squeeze spaces
tr -d '\r'           fix Windows endings
tr -dc '[:alnum:]'   keep alphanumeric

# grep
grep -i 'p' f        case insensitive
grep -v 'p' f        invert
grep -n 'p' f        line numbers
grep -r 'p' dir/     recursive
grep -A 3 'p' f      3 lines after

# sed
sed 's/a/b/' f       replace first
sed 's/a/b/g' f      replace all
sed '/p/d' f         delete matching
sed -n '/p/p' f      print matching
sed -i 's/a/b/g' f   edit in-place

# awk
awk '{print $1}' f         field 1
awk -F: '{print $1}' f     : separator
awk '{sum+=$1}END{print sum}' f   sum
awk '$2 ~ /pat/' f         field match
awk '{gsub(/a/,"b");print}' f     replace

# find
find . -name "*.txt"       by name
find . -type f -size +1M   large files
find . -mtime -7            recent files
find . -exec cmd {} \;      run command

# xargs
cmd | xargs cmd2           pass as args
cmd | xargs -n 1 cmd2      one at a time
cmd | xargs -P 4 cmd2      parallel
find . -print0|xargs -0    null-safe

# String ops
${#var}           length
${var:0:5}        substring
${var/a/b}        replace first
${var//a/b}       replace all
${var,,}          lowercase
${var^^}          uppercase
${var##*.}        remove longest prefix
${var%%.*}        remove longest suffix
${var:-default}   use default if unset
```

---

> **Golden Rules**
> - Avoid useless `cat` — `grep p file` beats `cat file | grep p`
> - Always `sort` before `uniq` — it only removes adjacent duplicates
> - Use `-n` with `sort` for numbers — string sort gives wrong order
> - Use `printf` over `echo` for formatted/portable output
> - Use `-print0 | xargs -0` when filenames may have spaces
> - `wc -l < file` is cleaner than `wc -l file` (no filename in output)
> - `tail -f` for live logs, `tail -F` if the file may be recreated
> - Use `awk` instead of `cut` when fields have variable whitespace