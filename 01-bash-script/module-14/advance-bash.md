# 🔵 Module 14: Advanced Bash Features — Short Notes

---

## 🔘 Subshells `( )` vs Command Grouping `{ }`

```bash
# Subshell ( ) — runs in CHILD process, changes don't affect parent
x=10
( x=20; echo "inside: $x" )   # inside: 20
echo "outside: $x"             # outside: 10  ← unchanged

# Use case: temp cd without affecting parent
( cd /tmp && ls )
pwd   # still in original dir

# Command grouping { } — runs in CURRENT shell, changes DO affect parent
{ x=20; echo "inside: $x"; }   # inside: 20
echo "outside: $x"              # outside: 20  ← changed!

# Use case: redirect group output to one file
{ echo "line1"; echo "line2"; } > output.txt

# Use case: error handling
cd /backup || { echo "failed"; exit 1; }
```

| Feature | `( )` Subshell | `{ }` Grouping |
|---------|---------------|----------------|
| Process | child | current shell |
| Variable changes | isolated | affect parent |
| Performance | slower | faster |
| Use case | isolation | grouping + redirect |

---

## ⚙️ Co-processes `coproc`

```bash
# coproc — start background process with 2-way pipe communication
coproc myproc { cat; }     # start named coproc

echo "hello" >&"${myproc[1]}"   # write TO coproc
read line <&"${myproc[0]}"      # read FROM coproc
echo "$line"                     # hello

# Real use: talk to a long-running process
coproc bc                        # start calculator
echo "5 * 8" >&"${COPROC[1]}"
read result <&"${COPROC[0]}"
echo "Result: $result"           # Result: 40
```

---

## 🚇 Named Pipes — `mkfifo`

```bash
# Named pipe = file that connects two processes
mkfifo /tmp/mypipe

# Terminal 1 — write to pipe (blocks until reader connects)
echo "hello from pipe" > /tmp/mypipe

# Terminal 2 — read from pipe
cat /tmp/mypipe     # hello from pipe

# Use case: producer → consumer pipeline
mkfifo /tmp/data_pipe
producer_script > /tmp/data_pipe &   # background producer
consumer_script < /tmp/mypipe        # foreground consumer

# Cleanup
rm /tmp/mypipe
```

---

## 🔀 Process Substitution `<()` `>()`

```bash
# <(cmd) — treat command output AS a file (for reading)
diff <(ls dir1) <(ls dir2)           # compare directory listings
comm <(sort file1) <(sort file2)     # compare sorted files

# Loop over command output without subshell
while read line; do
    echo "got: $line"
done < <(find /etc -name "*.conf")   # runs in CURRENT shell

# vs pipe — pipe creates subshell (variable changes lost!)
find /etc -name "*.conf" | while read line; do
    (( count++ ))    # LOST after pipe
done

# >(cmd) — treat command AS a file (for writing)
tee >(gzip > out.gz) > out.txt       # write to file AND compress
echo "data" > >(grep pattern > filtered.txt)
```

---

## 🧩 Advanced Parameter Expansion

```bash
# Default values
${var:-default}      # use default if var unset or empty
${var:=default}      # assign default if var unset or empty
${var:?error msg}    # exit with error if var unset
${var:+other}        # use 'other' if var IS set

echo "${NAME:-anonymous}"      # anonymous if NAME unset
: "${CONFIG:=/etc/app.conf}"   # set default permanently

# String operations
str="Hello, World!"
echo ${#str}              # 13         (length)
echo ${str:7}             # World!     (slice from index 7)
echo ${str:7:5}           # World      (slice 5 chars from 7)
echo ${str/World/Bash}    # Hello, Bash!  (replace first)
echo ${str//l/L}          # HeLLo, WorLd! (replace all)
echo ${str^^}             # HELLO, WORLD! (uppercase)
echo ${str,,}             # hello, world! (lowercase)
echo ${str^}              # Hello, World! (capitalize first)

# Remove prefix / suffix
file="backup_2025_01.tar.gz"
echo ${file#*.}           # 2025_01.tar.gz  (remove shortest prefix)
echo ${file##*.}          # gz              (remove longest prefix)
echo ${file%.*}           # backup_2025_01.tar (remove shortest suffix)
echo ${file%%.*}          # backup_2025_01  (remove longest suffix)

# Practical
filename="/path/to/script.sh"
echo ${filename##*/}      # script.sh   (basename)
echo ${filename%/*}       # /path/to    (dirname)
echo ${filename##*.}      # sh          (extension)
```

---

## 🔁 Indirect References `${!var}`

```bash
# ${!var} — use VALUE of var as variable name
greeting="hello"
varname="greeting"
echo ${!varname}          # hello  ← value of $greeting

# Dynamic variable names
for env in HOME USER SHELL; do
    echo "$env = ${!env}"
done
# HOME = /home/hacker
# USER = hacker
# SHELL = /bin/bash

# Indirect array reference
fruits=("apple" "banana" "cherry")
arrname="fruits"
echo "${!arrname[@]}"     # 0 1 2  (indices of fruits array)

# nameref (bash 4.3+) — cleaner indirect reference
declare -n ref="fruits"
echo "${ref[0]}"          # apple
```

---

## 📦 Array Manipulation

```bash
# Declare
arr=("one" "two" "three")
declare -a arr            # indexed array
declare -A map            # associative array (dictionary)

# Access
echo ${arr[0]}            # one
echo ${arr[-1]}           # three (last element)
echo ${arr[@]}            # all elements
echo ${#arr[@]}           # 3 (length)
echo ${!arr[@]}           # 0 1 2 (indices)

# Modify
arr+=("four")             # append
arr[1]="TWO"              # update index 1
unset arr[1]              # delete index 1

# Slice
echo ${arr[@]:1:2}        # elements from index 1, count 2

# Loop
for item in "${arr[@]}"; do echo "$item"; done
for i in "${!arr[@]}"; do echo "$i: ${arr[$i]}"; done

# Associative array
declare -A person
person[name]="hacker"
person[age]=25
echo ${person[name]}      # hacker
echo ${!person[@]}        # name age (keys)
echo ${person[@]}         # hacker 25 (values)

# mapfile / readarray — read file lines into array
mapfile -t lines < file.txt          # read file into array
readarray -t lines < file.txt        # same thing

mapfile -t words < <(cat /etc/shells)
echo "${words[0]}"        # /bin/sh
echo "${#words[@]}"       # number of lines
```

---

## 🎛️ Interactive Features

### `select` — Menu
```bash
# select builds a numbered menu automatically
PS3="Choose your shell: "    # select prompt
select shell in bash zsh fish quit; do
    case $shell in
        quit) break ;;
        "")   echo "Invalid choice" ;;
        *)    echo "You chose: $shell"; break ;;
    esac
done
```

### `dialog` — TUI Dialogs
```bash
sudo apt install dialog

# Yes/No box
dialog --yesno "Continue?" 7 40
[[ $? -eq 0 ]] && echo "Yes" || echo "No"

# Input box
name=$(dialog --inputbox "Enter your name:" 8 40 3>&1 1>&2 2>&3)
echo "Hello $name"

# Menu
choice=$(dialog --menu "Pick one:" 15 40 4 \
    1 "Install" 2 "Remove" 3 "Update" 3>&1 1>&2 2>&3)

# Progress bar
(for i in {1..100}; do echo $i; sleep 0.05; done) \
    | dialog --gauge "Installing..." 7 40 0
```

### `whiptail` — Lightweight TUI (pre-installed)
```bash
# Available on most systems without install
whiptail --title "Confirm" --yesno "Proceed?" 8 40
whiptail --inputbox "Enter name:" 8 40 3>&1 1>&2 2>&3
whiptail --msgbox "Done!" 8 40
```

### Bash Completion
```bash
# Tab completion for your own script
_myapp_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts="start stop restart status --help --version"
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
}
complete -F _myapp_complete myapp

# Save to: /etc/bash_completion.d/myapp
# or source it in .bashrc
```

---

## ⚙️ Shell Config Files

| File | When it runs |
|------|-------------|
| `~/.bash_profile` | Login shell (ssh, terminal login) |
| `~/.bashrc` | Interactive non-login shell (new terminal tab) |
| `~/.profile` | Login shell — POSIX (used if no `.bash_profile`) |
| `/etc/profile` | System-wide login shell |
| `/etc/bash.bashrc` | System-wide interactive shell |

```bash
# .bash_profile — typically sources .bashrc
[[ -f ~/.bashrc ]] && source ~/.bashrc

# .bashrc — your customizations go here
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=vim
alias ll='ls -la'
alias gs='git status'

# Apply changes without restarting
source ~/.bashrc
# or
. ~/.bashrc
```

---

## 🔧 `shopt` — Shell Options

```bash
shopt           # list all options + state
shopt -s opt    # set (enable) option
shopt -u opt    # unset (disable) option
shopt -q opt    # query silently (for if checks)

# Useful options
shopt -s nullglob      # *.txt returns empty if no match (not literal *.txt)
shopt -s globstar      # ** matches directories recursively
shopt -s dotglob       # globs match hidden files (.)
shopt -s nocaseglob    # case-insensitive glob
shopt -s cdspell       # auto-correct minor cd typos
shopt -s autocd        # type dirname to cd into it (no cd needed)
shopt -s histappend    # append to history, don't overwrite
shopt -s checkwinsize  # update LINES/COLUMNS after each command

# Example: recursive glob with globstar
shopt -s globstar
for f in **/*.sh; do echo "$f"; done   # find all .sh files recursively
```

---

## 📥 `mapfile` / `readarray`

```bash
# Read file into array (preserves lines)
mapfile -t arr < /etc/shells
echo "${arr[0]}"           # /bin/sh
echo "${#arr[@]}"          # number of shells

# From command output
mapfile -t procs < <(ps aux | awk '{print $11}' | tail -n +2)

# -t strips trailing newlines (almost always use this)
# -n N read only first N lines
mapfile -t -n 5 first5 < bigfile.txt

# readarray = mapfile (same thing)
readarray -t lines < config.txt

# Loop over mapfile result
mapfile -t users < <(cut -d: -f1 /etc/passwd)
for user in "${users[@]}"; do
    echo "User: $user"
done
```

---

## 🧠 Quick Reference

| Feature | Syntax | Use case |
|---------|--------|----------|
| Subshell | `( cmds )` | Isolated env, temp cd |
| Grouping | `{ cmds; }` | Redirect group output |
| Co-process | `coproc name { cmd; }` | 2-way IPC with process |
| Named pipe | `mkfifo /tmp/p` | Connect two processes |
| Process sub | `<(cmd)` | Use output as file |
| Default value | `${var:-default}` | Safe unset variable |
| String length | `${#var}` | Length of string |
| Substring | `${var:2:5}` | Slice string |
| Replace | `${var/old/new}` | String substitution |
| Uppercase | `${var^^}` | Convert case |
| Strip prefix | `${var##*/}` | Basename trick |
| Indirect ref | `${!varname}` | Dynamic variable |
| Array all | `${arr[@]}` | All elements |
| Array length | `${#arr[@]}` | Count elements |
| Assoc array | `declare -A map` | Key-value store |
| Read to array | `mapfile -t arr < file` | File → array |
| TUI menu | `select opt in a b c` | Interactive menu |
| Shell options | `shopt -s globstar` | Enable features |