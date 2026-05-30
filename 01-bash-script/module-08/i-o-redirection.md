# Bash — Input, Output & Redirection (Quick Notes)

---

## 1. Standard Streams

| FD | Name | Default |
|---|---|---|
| `0` | stdin | Keyboard → Program |
| `1` | stdout | Program → Terminal |
| `2` | stderr | Program → Terminal (errors) |

```bash
echo "Hello"          # stdout (fd 1)
ls /nonexistent       # stderr (fd 2) — looks same on screen but different stream
echo $?               # check exit status
```
> stdout and stderr both appear on terminal by default — but they are **separate streams**.

---

## 2. Output Redirection `>`

```bash
echo "Hello" > file.txt       # create/overwrite file
ls -la > filelist.txt         # save command output
date > timestamp.txt

# ⚠️ Destructive — existing content is LOST
echo "line1" > data.txt
echo "line2" > data.txt       # line1 is gone!
```

---

## 3. Input Redirection `<`

```bash
sort < names.txt              # sort reads from file
wc -w < essay.txt             # count words from file
read name < name.txt          # read variable from file

while IFS= read -r line; do
    echo "Processing: $line"
done < data.txt               # loop over file lines
```
> `cmd < file` is more efficient than `cat file | cmd` — no extra process.

---

## 4. Append Redirection `>>`

```bash
echo "Log started: $(date)" > app.log    # create
echo "User logged in"  >> app.log        # append
echo "User logged out" >> app.log        # append
```

| Operator | File Exists | File Missing |
|---|---|---|
| `>` | Overwrites | Creates |
| `>>` | Appends | Creates |

> ✅ Always use `>>` for log files — never overwrite logs by accident.

---

## 5. stderr Redirection `2>`

```bash
ls /nonexistent 2> errors.txt           # stderr to file
ls /etc /fake > out.txt 2> err.txt      # stdout and stderr to separate files
./script.sh 2>> error.log              # append stderr
./script.sh 2> /dev/null               # discard errors silently
```

---

## 6. Redirect stdout + stderr Together

```bash
# POSIX — order matters! stdout first, then stderr follows
./script.sh > output.txt 2>&1          # ✅ correct
./script.sh 2>&1 > output.txt          # ❌ wrong — stderr still goes to terminal

# Bash shorthand
./script.sh &> output.txt              # both to file
./script.sh &>> output.txt             # both appended
./script.sh &> /dev/null               # suppress everything
```
> ⚠️ `&>` is Bash-only. Use `> file 2>&1` for POSIX portability.

---

## 7. `/dev/null` — The Black Hole

Discards everything written to it. Returns EOF when read.

```bash
./script.sh > /dev/null                # discard stdout
./script.sh 2> /dev/null               # discard stderr
./script.sh &> /dev/null               # discard all output

# Check if command exists silently
which python3 &> /dev/null && echo "found" || echo "not found"

# Silent cron job
0 * * * * /usr/bin/backup.sh &> /dev/null
```

---

## 8. Pipes `|`

Connects stdout of one command to stdin of the next. Runs simultaneously — no temp files.

```bash
ls /etc | grep "conf"                  # filter output
ls /etc | wc -l                        # count files
ps aux | grep "nginx" | grep -v grep   # find process

# Multi-step pipeline
cat /etc/passwd | cut -d: -f1 | sort | head -10

# Top 5 largest files
du -sh /var/log/* | sort -rh | head -5

# Most common words
cat file.txt | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | sort | uniq -c | sort -rn | head -10
```

### `$PIPESTATUS` — Exit Codes of All Stages
```bash
ls /fake | grep "conf"
echo "${PIPESTATUS[@]}"    # e.g. 2 1  (ls failed, grep failed)
echo "${PIPESTATUS[0]}"    # ls exit code
```

### `pipefail` — Fail if Any Stage Fails
```bash
set -o pipefail
ls /fake | grep "conf"
echo $?    # non-zero — because ls failed
```

---

## 9. `tee` — Split Output

Writes to **both terminal and file** simultaneously.

```bash
ls /etc | tee filelist.txt             # see it + save it
echo "entry" | tee -a logfile.txt     # append mode
echo "msg" | tee file1.txt file2.txt  # write to multiple files

# Middle of pipeline — inspect intermediate data
cat /etc/passwd | tee raw.txt | cut -d: -f1 | tee users.txt | wc -l

# Watch build output live + save it
make | tee build.log
```

---

## 10. Here Document (heredoc) `<<`

Pass a multi-line block of text as stdin — no separate file needed.

```bash
# Basic heredoc — variables ARE expanded
cat << EOF
Hello $USER
Today is $(date)
EOF

# Save to file
cat << EOF > config.txt
host=localhost
port=5432
EOF

# Quoted delimiter — NO variable expansion (literal)
cat << 'EOF'
Home is $HOME      # printed as-is
EOF

# Indented heredoc — strips leading TABS (not spaces)
generate_config() {
    cat <<- EOF
	port=8080
	debug=true
	EOF
}
```

---

## 11. Here String `<<<`

Pass a **single line** as stdin — cleaner than `echo "..." | cmd`.

```bash
grep "world" <<< "hello world"         # no extra process
tr '[:lower:]' '[:upper:]' <<< "hello" # HELLO

read first last <<< "John Smith"
echo "$first $last"                    # John Smith

data="192.168.1.1"
grep -oP '\d+\.\d+\.\d+\.\d+' <<< "$data"
```

---

## 12. Process Substitution `<( )`

Treats command output as a **file** — for commands that need a filename, not stdin.

```bash
# Compare two command outputs — diff needs files
diff <(ls /dir1) <(ls /dir2)
diff <(sort file1.txt) <(sort file2.txt)

# while loop — runs in CURRENT shell (variables persist)
while IFS= read -r line; do
    echo "$line"
done < <(find /etc -name "*.conf" 2>/dev/null)

# Split output into separate files simultaneously
tee >(grep "ERROR" > errors.txt) >(grep "INFO" > info.txt) < app.log
```
> `< <(cmd)` keeps the loop in the **current shell** — unlike pipes which use a subshell.

---

## 13. Command Substitution `$( )`

Captures command output as a **value**.

```bash
today=$(date +%Y-%m-%d)
echo "You are: $(whoami) on $(hostname)"
files=$(ls /etc | wc -l)

# Nested
echo "Kernel: $(uname -r | cut -d'-' -f1)"

# In conditions
if [[ $(id -u) -ne 0 ]]; then echo "Need root!"; exit 1; fi

# In arithmetic
total=$(( $(wc -l < file.txt) * 2 ))
```
> ✅ Always use `$( )` — never backticks `` `cmd` `` (hard to nest and read).

---

## 14. `exec` — Redirect Entire Script

Permanently redirects streams for the rest of the script — no new process.

```bash
# All stdout to file from this point on
exec > script.log

# Both stdout + stderr to file
exec > script.log 2>&1

# Self-logging script — terminal AND log file
exec > >(tee -a /var/log/myscript.log) 2>&1
echo "Script started: $(date)"      # goes to terminal + log

# Redirect stdin for entire script
exec < input_data.txt
read line1    # reads from file
read line2    # reads next line
```

### Save & Restore File Descriptors
```bash
exec 3>&1          # save stdout to fd 3
exec > output.txt  # redirect stdout to file
echo "to file"
exec 1>&3 3>&-     # restore stdout, close fd 3
echo "to terminal"
```

---

## 15. File Descriptors

| FD | Default | Use |
|---|---|---|
| `0` | stdin | Read input |
| `1` | stdout | Write output |
| `2` | stderr | Write errors |
| `3–9` | custom | Available for scripts |

```bash
# Open fd 3 for reading
exec 3< input.txt
read -u 3 line1         # read from fd 3
exec 3<&-               # close fd 3

# Open fd 4 for writing
exec 4> output.txt
echo "Hello" >&4        # write to fd 4
exec 4>&-               # close fd 4

# Read two files simultaneously
exec 3< file1.txt
exec 4< file2.txt
while true; do
    read -u 3 a || break
    read -u 4 b || break
    echo "$a | $b"
done
exec 3<&- 4<&-
```
> Always close FDs when done: `exec N<&-` (read) or `exec N>&-` (write).

---

## 16. Named Pipes (FIFO)

A pipe **with a name in the filesystem** — lets unrelated processes communicate.

```bash
mkfifo mypipe                   # create named pipe (shows as 'p' in ls)

# Terminal 1 — write (blocks until someone reads)
echo "Hello from process 1" > mypipe

# Terminal 2 — read (unblocks Terminal 1)
cat < mypipe

# Producer-consumer pattern
mkfifo /tmp/data_pipe
( for i in {1..5}; do echo "Item $i"; sleep 1; done ) > /tmp/data_pipe &
while IFS= read -r line; do echo "Got: $line"; done < /tmp/data_pipe
rm /tmp/data_pipe               # cleanup
```

---

## 17. Practical One-Liners

```bash
# Self-logging script
exec > >(tee -a "/var/log/backup_$(date +%Y%m%d).log") 2>&1

# Process CSV file
while IFS=',' read -r name age city; do
    echo "$name | $age | $city"
done < data.csv

# Separate stdout and stderr
./script.sh > output.txt 2> errors.txt

# Failed SSH login attempts (top 10)
grep "Failed password" /var/log/auth.log \
    | awk '{print $11}' | sort | uniq -c | sort -rn | head -10 | tee failed_logins.txt

# Feed choices to interactive script
./setup.sh << EOF
yes
/usr/local
admin
EOF
```

---

## Cheat Sheet

```
# Output
cmd > file          overwrite stdout
cmd >> file         append stdout
cmd 2> file         overwrite stderr
cmd 2>> file        append stderr
cmd > file 2>&1     stdout + stderr → file (POSIX)
cmd &> file         stdout + stderr → file (Bash)
cmd &>> file        stdout + stderr → append (Bash)

# Input
cmd < file          stdin from file
cmd <<< "string"    here string — single line stdin

# /dev/null
cmd > /dev/null     discard stdout
cmd 2> /dev/null    discard stderr
cmd &> /dev/null    discard everything

# Pipes
cmd1 | cmd2         stdout → stdin
cmd1 | tee f | cmd2 split to file + next command
${PIPESTATUS[@]}    exit codes of all stages
set -o pipefail     fail if any stage fails

# Heredoc
cmd << EOF          variables expanded
cmd << 'EOF'        no expansion (literal)
cmd <<- EOF         strip leading tabs

# Process Substitution
cmd <(cmd2)         cmd2 output as file
diff <(c1) <(c2)    compare command outputs

# exec
exec > file         script stdout → file
exec > file 2>&1    script stdout+stderr → file
exec 3< file        open fd 3 for reading
exec 3<&-           close fd 3

# Named Pipe
mkfifo name         create FIFO
cmd > name          write to pipe
cmd < name          read from pipe
rm name             delete pipe
```

---

> **Golden Rules**
> - `>` overwrites — use `>>` for logs
> - Order matters: `> file 2>&1` ✅ — `2>&1 > file` ❌
> - `&>` is Bash-only — use `> file 2>&1` for portability
> - Use `$( )` not backticks for command substitution
> - `< <(cmd)` keeps loop in current shell — pipes create subshells
> - Always close custom FDs: `exec N<&-` when done
> - Test `sed -i` and `exec >` without live files first