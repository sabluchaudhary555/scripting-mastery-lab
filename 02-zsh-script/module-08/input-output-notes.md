# Module 8 — Input, Output & Redirection

## Standard Streams

Every process gets three streams automatically:

| Stream | FD | Default |
|---|---|---|
| `stdin`  | `0` | keyboard |
| `stdout` | `1` | terminal |
| `stderr` | `2` | terminal |

---

## Output Redirection

```zsh
cmd > file       # stdout → file (overwrite)
cmd >> file      # stdout → file (append)
cmd 2> file      # stderr → file
cmd &> file      # stdout + stderr → file
cmd 2>&1         # stderr → wherever stdout goes
```

---

## Input Redirection

```zsh
cmd < file            # file → stdin
cmd <<< "string"      # herestring (one line)
cmd <<EOF             # heredoc (multiline)
line one
line two
EOF
```

---

## Multios (zsh only)

```zsh
setopt multios
echo "hi" > a.txt > b.txt        # writes to both
cat < a.txt < b.txt               # reads from both
```

---

## Pipes

```zsh
cmd1 | cmd2          # stdout of cmd1 → stdin of cmd2
cmd1 | cmd2 | cmd3   # chain as long as you want
```

---

## Named Pipes (FIFOs)

```zsh
mkfifo /tmp/pipe
echo "data" > /tmp/pipe &    # writer (background)
read line < /tmp/pipe         # reader blocks until data arrives
```

---

## File Descriptors

```zsh
exec 3> out.txt     # open fd 3 for writing
echo "hi" >&3       # write to it
exec 3>&-           # close it

exec 4< in.txt      # open fd 4 for reading
read line <&4       # read from it
exec 4<&-
```

---

## tee

Writes to **stdout and a file at the same time**:

```zsh
cmd | tee file.txt          # stdout + file
cmd | tee -a file.txt       # stdout + append to file
cmd | tee a.txt | tee b.txt # stdout + two files
```

---

## /dev/null and friends

```zsh
cmd > /dev/null        # discard stdout
cmd 2> /dev/null       # discard stderr
cmd &> /dev/null       # discard everything
cat /dev/stdin         # explicit stdin
echo "hi" > /dev/stdout
```

---

## Process Substitution

Treats a command's output/input as if it were a file:

```zsh
diff <(sort a.txt) <(sort b.txt)     # <() = output as file
echo "hello" | tee >(tr a-z A-Z)    # >() = input as file
```

---

## Positional Parameters

```zsh
$0      # script name
$1 $2   # first, second argument
$#      # number of arguments
"$@"    # all args, individually quoted  ← almost always want this
"$*"    # all args joined as one string
```

`$@` vs `$*` matters when args have spaces:

```zsh
f() { for a in "$@"; do echo "$a"; done }
f "hello world" "foo"    # 2 lines ✓

f() { for a in "$*"; do echo "$a"; done }
f "hello world" "foo"    # 1 line  ✗
```

---

## shift

Drops `$1`, moves everything left:

```zsh
while [[ $# -gt 0 ]]; do
  echo "arg: $1"
  shift
done
```

---

## getopts — short options

```zsh
while getopts "vo:" opt; do
  case $opt in
    v) verbose=1 ;;
    o) output=$OPTARG ;;
    *) echo "usage: script [-v] [-o file]" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))   # remaining non-option args in $@
```

---

## zparseopts — long options (zsh only)

```zsh
local -A opts
zparseopts -D -E -A opts -- \
  -name:    \
  -verbose  \
  -output:

name=${opts[--name]:-default}
verbose=${opts[--verbose]:+1}
```

---

## Argument Validation Pattern

```zsh
usage() {
  echo "usage: $(basename $0) [-v] [-o file] <input>" >&2
  exit 1
}

[[ $# -lt 1 ]] && usage
[[ ! -f $1  ]] && { echo "error: file not found: $1" >&2; exit 1; }
```