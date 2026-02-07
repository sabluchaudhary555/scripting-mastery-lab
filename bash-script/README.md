# 💻 Bash Scripting Learning Path
An industry-aligned roadmap designed to master Bash scripting, automation, and system administration.


## 🟢 Module 1: Introduction to Bash and Shell Fundamentals
**Goal:** Understand Bash and write your first scripts.

* Understanding Bash, shell, terminal, and command-line interface
* Environment setup (Linux, macOS, WSL) and shebang (`#!/bin/bash`)
* Script execution methods (`./script.sh`, `bash script.sh`, `source`) and making scripts executable (`chmod +x`)
* Essential commands: `echo`, `pwd`, `ls`, `cd`, `mkdir`, `touch`, `rm`, `cp`, `mv`
* Getting help: `man`, `--help`, `info`, `type`, `which`
  * 📂 Mini Project: [system-info-script](module-01/system-info-script.sh)


## 🟡 Module 2: Variables and Data Types
**Goal:** Store and manipulate data in scripts.

* Variable declaration, naming conventions, and output (`echo` vs `printf`, comments with `#`)
* Local vs environment variables (`export`) and reading input (`read` with options)
* Special variables: `$0`, `$1-$9`, `$@`, `$*`, `$#`, `$$`, `$!`, `$?`, `$_`
* Command substitution (backticks vs `$()`) and arithmetic expansion (`$((expression))`)
* Arrays: indexed and associative arrays, readonly variables


## 🟠 Module 3: Operators and Expressions
**Goal:** Make decisions and perform calculations.

* Arithmetic operations (`let`, `(( ))`, `expr`, `bc`) and operators: `+`, `-`, `*`, `/`, `%`, `++`, `--`, `**`
* Comparison operators - Numeric: `-eq`, `-ne`, `-gt`, `-ge`, `-lt`, `-le` | String: `==`, `!=`, `<`, `>`, `-z`, `-n`
* Logical operators: `&&`, `||`, `!` and bitwise operators
* File test operators: `-e`, `-f`, `-d`, `-L`, `-r`, `-w`, `-x`, `-s`, `-nt`, `-ot`


## 🔵 Module 4: Conditional Statements
**Goal:** Master decision-making in scripts.

* Basic conditionals: `if`, `elif`, `else` and nested conditionals
* Test commands: `[ ]` vs `[[ ]]` vs `test`
* Pattern matching with `case ... esac`
* Ternary operations and short-circuit evaluation with `&&` and `||`


## 🟣 Module 5: Loops
**Goal:** Automate repetitive tasks.

* `for` loops: list iteration, C-style, brace expansion, `seq`
* `while` and `until` loops for condition-based iteration
* Loop control: `break` and `continue`
* Nested loops and looping through files, directories, arrays, command output


## 🟤 Module 6: Functions
**Goal:** Write reusable and organized code.

* Defining and calling functions with parameters (`$1`, `$2`, `$@`, `$#`)
* Return values and exit status handling
* Variable scope: local vs global variables
* Recursive functions and function libraries with sourcing


## ⚫ Module 7: Command-Line Arguments
**Goal:** Make scripts interactive and flexible.

* Positional parameters: `$0`, `$1`, `$2`, etc. and understanding `$@` vs `$*`
* Argument count (`$#`) and shifting arguments (`shift`)
* Option parsing with `getopts` and long option parsing
* Argument validation and usage functions


## 🔴 Module 8: Input/Output and Redirection
**Goal:** Control data flow in scripts.

* Standard streams: stdin (0), stdout (1), stderr (2)
* Output redirection: `>`, `>>`, `2>`, `&>`, `2>&1` and input redirection: `<`, `<<<`, `<<EOF`
* Pipes (`|`), named pipes (FIFOs), and file descriptors
* Special files: `/dev/null`, `/dev/stdin`, `/dev/stdout`, `/dev/stderr` and `tee` command
* Process substitution: `<()`, `>()`


## 🟠 Module 9: String Manipulation
**Goal:** Master text processing within Bash.

* String length (`${#string}`) and substrings (`${string:position:length}`)
* Default values: `${var:-default}`, `${var:=default}`
* Pattern removal: `${string#pattern}`, `${string##pattern}`, `${string%pattern}`, `${string%%pattern}`
* Search/replace (`${string/pattern/replacement}`, `${string//pattern/replacement}`) and case conversion (`${string^^}`, `${string,,}`)
* Regex matching with `[[ =~ ]]`


## 🟡 Module 10: Text Processing Tools
**Goal:** Master external utilities for text manipulation.

* `grep`: pattern searching with options (`-i`, `-v`, `-r`, `-n`, `-c`) and extended regex
* `sed`: stream editing for substitution, deletion, in-place editing, and address ranges
* `awk`: advanced field processing, built-in variables, patterns, and control structures
* Text manipulation tools: `cut`, `paste`, `sort`, `uniq`, `tr`, `wc`, `head`, `tail`, `column`, `join`


## 🔵 Module 11: File and Directory Operations
**Goal:** Manage files and directories effectively.

* File and directory creation, deletion, and manipulation
* `find` command: search by name, type, size, time, and `-exec` operations
* Path operations (`basename`, `dirname`, `realpath`) and permissions (`chmod`, `chown`, `chgrp`)
* Links (`ln` - symbolic and hard), file info (`stat`, `file`), and disk usage (`du`, `df`)
* Globbing and wildcards (`*`, `?`, `[...]`), extended globbing, and temporary files (`mktemp`)


## 🟣 Module 12: Process Management
**Goal:** Control running processes and background jobs.

* Job control: foreground/background (`&`), `jobs`, `fg`, `bg`, `disown`, and `nohup`
* Process information: `ps`, `top`, `htop`, `pgrep`, `pidof`
* Killing processes: `kill`, `killall`, `pkill` with signals (SIGTERM, SIGKILL, SIGINT, SIGHUP)
* Exit codes (`$?`, `exit`), process priority (`nice`, `renice`), and subshells (`( )`), command grouping (`{ }`)


## 🟢 Module 13: Error Handling and Debugging
**Goal:** Write robust and error-free scripts.

* Exit status, error codes, and error handling with `if command; then`, `||`, `&&`
* Set options for robust scripts: `set -e`, `set -u`, `set -o pipefail`, `set -x` (`set -euo pipefail`)
* Traps for signal handling: `trap 'commands' SIGNAL` (EXIT, ERR, INT, TERM)
* Debug mode (`bash -x`, `bash -n`), PS4 variable, verbose mode (`set -v`), and ShellCheck


## 🔴 Module 14: Regular Expressions
**Goal:** Master pattern matching and text searching.

* Basic syntax and special characters: `.`, `*`, `^`, `$`, `[]`, `\`
* Character classes (`[a-z]`, `[0-9]`, `[^...]`) and POSIX classes (`[:alnum:]`, `[:alpha:]`, `[:digit:]`)
* Quantifiers (`*`, `+`, `?`, `{n}`, `{n,}`, `{n,m}`) and anchors (`^`, `$`, `\b`)
* Groups and capturing (`()`, `\1`, `\2`), alternation (`|`)
* Regex usage with `grep`, `sed`, `awk`, and `[[ =~ ]]`


## 🟠 Module 15: Advanced Bash Features
**Goal:** Unlock powerful scripting techniques.

* Subshells (`( )`), command grouping (`{ }`), and co-processes (`coproc`)
* Named pipes (`mkfifo`) and process substitution (`<()`, `>()`)
* Advanced parameter expansion, indirect references (`${!var}`), and array manipulation
* Interactive features: `select` menus, `dialog`, `whiptail`, and Bash completion
* Shell configuration: `shopt`, `.bashrc`, `.bash_profile`, `.profile`, and `mapfile`/`readarray`


## 🟡 Module 16: Networking and Remote Operations
**Goal:** Automate network and system tasks.

* Network tools: `curl`, `wget`, `nc` (netcat), `ping`, `traceroute`, `nslookup`, `dig`
* Network interfaces: `ip`, `ifconfig`
* SSH automation: `ssh`, `ssh-keygen`, `ssh-copy-id`, `scp`, `rsync`
* API calls with `curl`, JSON parsing with `jq`, XML parsing
* Email and FTP automation: `mail`, `sendmail`, FTP


## 🔵 Module 17: System Administration and Automation
**Goal:** Master system administration tasks.

* System monitoring: CPU, memory, disk, and network usage tracking
* Automated backups: `tar`, `rsync` with incremental backups and rotation strategies
* Log management: rotation, analysis, and alerts
* User management (creation, passwords, groups) and package management (`apt`, `yum`, `dnf`)
* Service management (`systemctl`) and task scheduling: cron jobs (`crontab -e`, `@reboot`, `@daily`), `anacron`, `at`


<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)]

---
**Made with ❤️ for the Open Source Community**