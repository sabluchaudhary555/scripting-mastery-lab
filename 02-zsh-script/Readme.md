# Zsh Scripting Syllabus

## Module 1: Introduction & First Script
- What is Zsh? (Z Shell — extended Bourne shell)
- Zsh vs Bash: key differences
- Setup: Linux / macOS (default) / WSL
- Installing Zsh: `sudo apt install zsh` | `sudo dnf install zsh`
- `echo` vs `print` vs `printf`
- Zsh `print` options: `-n` `-r` `-l` `-z`
- Writing and running your first Zsh script

## Module 2: Variables & Data Types
- Declaration and assignment
- Naming conventions
- Local vs environment variables (`export`)
- Readonly variables: `readonly` | `typeset -r`
- `typeset` / `declare`: typed variables in Zsh
- Reading input: `read` (with options)
- Special variables: `$0` `$1-$9` `$@` `$*` `$#` `$$` `$!` `$?` `$_`
- Zsh-specific: `$ARGC` `$argv` `$funcstack` `$pipestatus`
- Command substitution: `$()` | backticks
- Arithmetic expansion: `$(( expression ))`
- Indexed arrays (1-based in Zsh)
- Associative arrays: `typeset -A`

## Module 3: Operators & Expressions
- Arithmetic: `(())` | `let` | `expr` | `bc`
- Operators: `+` `-` `*` `/` `%` `**` `++` `--`
- String operations
- Comparison operators
  - Numeric : `-eq` `-ne` `-gt` `-ge` `-lt` `-le`
  - String : `==` `!=` `<` `>` `-z` `-n`
- Logical operators: `&&` `||` `!`
- File test operators: `-e` `-f` `-d` `-L` `-r` `-w` `-x` `-s` `-nt` `-ot`
- Bitwise operators
- Zsh extended math: `zcalc`

## Module 4: Conditional Statements
- `if` / `elif` / `else`
- Nested conditionals
- Test commands: `[ ]` vs `[[ ]]` vs `test`
- `[[ ]]` enhancements in Zsh: `=~` `==` glob patterns
- `case ... esac` pattern matching
- Short-circuit evaluation: `&&` and `||`
- Ternary-style operations

## Module 5: Loops
- `for` loop: list | C-style | brace expansion | `seq`
- Zsh `for` shorthand: `for i (list) command`
- `while` loop
- `until` loop
- `repeat N` loop (Zsh-specific)
- Loop control: `break` | `continue`
- Nested loops
- Looping over: files | directories | arrays | command output

## Module 6: Functions
- Defining and calling functions
- Parameters: `$1` `$2` `$@` `$#`
- `$argv` array (Zsh-specific)
- Return values and exit status
- Local vs global variables: `local` | `typeset`
- Recursive functions
- Autoloading functions: `autoload -Uz`
- Function libraries and sourcing
- Anonymous functions: `(){ ... }`

## Module 7: Regular Expressions & Globbing
- Basic syntax and special characters: `.` `*` `^` `$` `[` `]` `\`
- Character classes: `[a-z]` `[0-9]` `[^...]`
- Quantifiers: `*` `+` `?` `{n}` `{n,}` `{n,m}`
- Anchors: `^` `$` `\b`
- Groups and capturing: `()` `\1` `\2`
- Alternation: `|`
- POSIX classes: `[:alnum:]` `[:alpha:]` `[:digit:]`
- Regex with: `grep` | `sed` | `awk` | `[[ =~ ]]`
- Zsh Extended Globbing (`setopt EXTENDED_GLOB`)
- `**/*` recursive glob
- `^pattern` negation
- `(#i)pattern` case-insensitive
- Glob qualifiers: `*(.)` files only | `*(/)` dirs only | `*(om)` by date
- Glob flags: `setopt NULL_GLOB` | `GLOB_DOTS`

## Module 8: Input, Output & Redirection
- Standard streams: stdin(0) | stdout(1) | stderr(2)
- Output redirection: `>` `>>` `2>` `&>` `2>&1`
- Input redirection: `<` `<<<` `<<EOF`
- Multios (Zsh-specific): write to multiple files: `cmd > f1 > f2`
- Pipes: `|`
- Named pipes (FIFOs)
- File descriptors
- `tee` command
- `/dev/null` `/dev/stdin` `/dev/stdout` `/dev/stderr`
- Process substitution: `<()` `>()`
- Positional parameters: `$0` `$1` `$2`
- `$@` vs `$*` | Argument count: `$#`
- `shift` | `zparseopts` (Zsh option parser)
- `getopts` | long option parsing
- Argument validation and usage functions

## Module 9: Text Processing Tools
- `grep` : patterns | `-i` `-v` `-r` `-n` `-c` | extended regex
- `sed` : substitution | deletion | in-place | address ranges
- `awk` : field processing | built-in variables | patterns | control structures
- `cut` | `paste` | `sort` | `uniq` | `tr` | `wc` | `head` | `tail`
- `column` | `join`
- Zsh string manipulation (no external tools needed)
  - `${var#pattern}` `${var##pattern}` — strip prefix
  - `${var%pattern}` `${var%%pattern}` — strip suffix
  - `${var/old/new}` `${var//old/new}` — substitution
  - `${#var}` — string length
  - `${var:offset:length}` — substring
  - `${(U)var}` `${(L)var}` — uppercase / lowercase
  - `${(j:sep:)array}` `${(s:sep:)var}` — join / split

## Module 10: File Operations
- File and directory creation / deletion
- `find`: by name | type | size | time | `-exec`
- `locate` and `updatedb`
- Path ops: `basename` | `dirname` | `realpath`
- Permissions: `chmod` | `chown` | `chgrp`
- Links: `ln` (symbolic and hard)
- File info: `stat` | `file`
- Disk usage: `du` | `df`
- Temporary files: `mktemp`
- Globbing and wildcards: `*` `?` `[...]` (extended globbing)
- Zsh `zmv` — smart batch rename: `autoload -Uz zmv`

## Module 11: Process Management
- Foreground / background: `&`
- Job control: `jobs` | `fg` | `bg` | `disown`
- Process info: `ps` | `top` | `htop` | `pgrep` | `pidof`
- Killing processes: `kill` | `killall` | `pkill`
- Signals: SIGTERM | SIGKILL | SIGINT | SIGHUP
- Exit codes: `$?` | `$pipestatus` (Zsh array) | `exit`
- Process priority: `nice` | `renice`
- `nohup`
- Subshells: `( )` | command grouping: `{ }`

## Module 12: Error Handling & Debugging
- Exit status and error codes
- Error handling: `if cmd; then` | `||` | `&&`
- Set options: `setopt ERR_EXIT` | `setopt NO_UNSET` | `setopt PIPE_FAIL`
- Equivalent of `set -euo pipefail`: `setopt ERR_EXIT NO_UNSET PIPE_FAIL`
- Traps: `trap 'commands' SIGNAL`
- Signals: EXIT | ERR | INT | TERM | ZERR (Zsh-specific)
- Error messages and logging
- Debug mode: `zsh -x` | `zsh -n`
- `PS4` variable
- `setopt XTRACE` | `setopt VERBOSE`
- Zsh-specific: `zsh -o SOURCE_TRACE`

## Module 13: Networking & Remote Operations
- `curl` | `wget` | `nc` (netcat)
- `ping` | `traceroute` | `nslookup` | `dig`
- `ip` | `ifconfig`
- SSH: `ssh` | `ssh-keygen` | `ssh-copy-id` | `scp` | `rsync`
- API calls with `curl`
- JSON parsing: `jq`
- XML parsing
- Email: `mail` | `sendmail`
- FTP automation