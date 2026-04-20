# 💻 Bash Scripting Learning Path
An industry-aligned roadmap designed to master Bash scripting, automation, and system administration.

---

## 🟢 Module 1: Environment Setup
**Goal:** Understand Bash and set up your scripting environment.

* What is Bash? (Bourne Again SHell)
* Shell vs terminal vs CLI
* Setup: Linux / macOS / WSL
* Shebang: `#!/bin/bash`
* Making scripts executable: `chmod +x`
* Running scripts: `./script.sh` | `bash script.sh` | `source`
* Output: `echo` vs `printf`
* Comments: `#`
* Getting help: `man` | `--help` | `info` | `type` | `which`
* Writing and running your first script
  * 📂 Mini Project: [system-info-script](module-01/system-info-script.sh)


## 🟡 Module 2: Variables & Data Types
**Goal:** Store and manipulate data in scripts.

* Variable declaration, assignment, and naming conventions
* Local vs environment variables (`export`)
* Readonly variables
* Reading input: `read` (with options)
* Special variables: `$0` `$1-$9` `$@` `$*` `$#` `$$` `$!` `$?` `$_`
* Command substitution: backticks vs `$()`
* Arithmetic expansion: `$(( expression ))`
* Indexed arrays
* Associative arrays
  * 📂 Mini Project: [user-profile-card](module-02/user-profile-card.sh)
  * 📂 Mini Project: [filename-parsar](module-02/filename-parsar.sh)


## 🟠 Module 3: Operators & Expressions
**Goal:** Make decisions and perform calculations.

* Arithmetic: `let` | `(( ))` | `expr` | `bc`
* Operators: `+` `-` `*` `/` `%` `**` `++` `--`
* String operations
* Comparison operators
  * Numeric : `-eq` `-ne` `-gt` `-ge` `-lt` `-le`
  * String  : `==` `!=` `<` `>` `-z` `-n`
* Logical operators: `&&` `||` `!`
* File test operators: `-e` `-f` `-d` `-L` `-r` `-w` `-x` `-s` `-nt` `-ot`
* Bitwise operators
* 📂 Mini Project: [smart-calculator](module-03/smart-calculator.sh)

## 🔵 Module 4: Conditional Statements
**Goal:** Master decision-making in scripts.

* `if` / `elif` / `else` and nested conditionals
* Test commands: `[ ]` vs `[[ ]]` vs `test`
* Pattern matching with `case ... esac`
* Short-circuit evaluation: `&&` and `||`
* Ternary-style operations
* 📂 Mini Project: [day type detector](module-04/day-type-detector.sh)

## 🟣 Module 5: Loops
**Goal:** Automate repetitive tasks.

* `for` loop: list | C-style | brace expansion | `seq`
* `while` loop
* `until` loop
* Loop control: `break` | `continue`
* Nested loops
* Looping over: files | directories | arrays | command output


## 🟤 Module 6: Functions
**Goal:** Write reusable and organized code.

* Defining and calling functions
* Parameters: `$1` `$2` `$@` `$#`
* Return values and exit status
* Local vs global variables (scope)
* Recursive functions
* Function libraries and sourcing


## 🔴 Module 7: Regular Expressions
**Goal:** Master pattern matching and text searching.

* Basic syntax and special characters: `.` `*` `^` `$` `[]` `\`
* Character classes: `[a-z]` `[0-9]` `[^...]`
* Quantifiers: `*` `+` `?` `{n}` `{n,}` `{n,m}`
* Anchors: `^` `$` `\b`
* Groups and capturing: `()` `\1` `\2`
* Alternation: `|`
* POSIX classes: `[:alnum:]` `[:alpha:]` `[:digit:]`
* Regex with: `grep` | `sed` | `awk` | `[[ =~ ]]`


## 🟠 Module 8: Input, Output & Redirection
**Goal:** Control data flow in scripts.

* Standard streams: `stdin(0)` | `stdout(1)` | `stderr(2)`
* Output redirection: `>` `>>` `2>` `&>` `2>&1`
* Input redirection: `<` `<<<` `<<EOF`
* Pipes: `|`
* Named pipes (FIFOs)
* File descriptors
* `tee` command
* `/dev/null` `/dev/stdin` `/dev/stdout` `/dev/stderr`
* Process substitution: `<()` `>()`
* Positional parameters: `$0` `$1` `$2`
* `$@` vs `$*` | Argument count: `$#`
* `shift` | `getopts` | long option parsing
* Argument validation and usage functions


## 🟡 Module 9: Text Processing Tools
**Goal:** Master external utilities for text manipulation.

* `grep`  : patterns | `-i` `-v` `-r` `-n` `-c` | extended regex
* `sed`   : substitution | deletion | in-place editing | address ranges
* `awk`   : field processing | built-in variables | patterns | control structures
* `cut` | `paste` | `sort` | `uniq` | `tr` | `wc` | `head` | `tail`
* `column` | `join`


## 🔵 Module 10: File Operations
**Goal:** Manage files and directories effectively.

* File and directory creation / deletion
* `find`: by name | type | size | time | `-exec`
* `locate` and `updatedb`
* Path ops: `basename` | `dirname` | `realpath`
* Permissions: `chmod` | `chown` | `chgrp`
* Links: `ln` (symbolic and hard)
* File info: `stat` | `file`
* Disk usage: `du` | `df`
* Temporary files: `mktemp`
* Globbing and wildcards: `*` `?` `[...]` (extended globbing)


## 🟣 Module 11: Process Management
**Goal:** Control running processes and background jobs.

* Foreground / background: `&`
* Job control: `jobs` | `fg` | `bg` | `disown`
* Process info: `ps` | `top` | `htop` | `pgrep` | `pidof`
* Killing processes: `kill` | `killall` | `pkill`
* Signals: `SIGTERM` | `SIGKILL` | `SIGINT` | `SIGHUP`
* Exit codes: `$?` | `exit`
* Process priority: `nice` | `renice`
* `nohup`
* Subshells: `( )` | command grouping: `{ }`


## 🟢 Module 12: Error Handling & Debugging
**Goal:** Write robust and error-free scripts.

* Exit status and error codes
* Error handling: `if cmd; then` | `||` | `&&`
* Set options: `-e` `-u` `-x` `-o pipefail`
* `set -euo pipefail` (best practice)
* Traps: `trap 'commands' SIGNAL`
* Signals: `EXIT` | `ERR` | `INT` | `TERM`
* Error messages and logging
* Debug mode: `bash -x` | `bash -n`
* `PS4` variable
* ShellCheck
* Verbose mode: `set -v`


## 🟠 Module 13: Networking & Remote Operations
**Goal:** Automate network and system tasks.

* `curl` | `wget` | `nc` (netcat)
* `ping` | `traceroute` | `nslookup` | `dig`
* `ip` | `ifconfig`
* SSH: `ssh` | `ssh-keygen` | `ssh-copy-id` | `scp` | `rsync`
* API calls with `curl`
* JSON parsing: `jq`
* XML parsing
* Email: `mail` | `sendmail`
* FTP automation


## 🔵 Module 14: Advanced Bash Features
**Goal:** Unlock powerful scripting techniques.

* Subshells `( )` | command grouping `{ }` | co-processes `coproc`
* Named pipes (`mkfifo`) and process substitution (`<()`, `>()`)
* Advanced parameter expansion and indirect references (`${!var}`)
* Array manipulation techniques
* Interactive features: `select` menus | `dialog` | `whiptail` | Bash completion
* Shell config: `shopt` | `.bashrc` | `.bash_profile` | `.profile`
* `mapfile` / `readarray`


## 🟣 Module 15: System Administration & Automation
**Goal:** Master system administration tasks.

* System monitoring: CPU | memory | disk | network usage tracking
* Automated backups: `tar` | `rsync` with incremental backups and rotation strategies
* Log management: rotation | analysis | alerts
* User management: creation | passwords | groups
* Package management: `apt` | `yum` | `dnf`
* Service management: `systemctl`
* Task scheduling: cron jobs (`crontab -e`, `@reboot`, `@daily`) | `anacron` | `at`


<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)

---
**Made with ❤️ for the Open Source Community**