# 🐚 Bash Scripting Learning Path
An industry-aligned roadmap designed to master Bash scripting, automation, and system administration.


## 🟢 Phase 1: Bash Fundamentals
**Goal:** Understand Bash and write your first scripts.

* Introduction to Bash: What is Bash? (Bourne Again SHell)
* Shell vs Terminal vs Bash: Understanding the differences.
* Shebang: Using `#!/bin/bash` to define script interpreter.
* Script Execution: Running scripts with `./script.sh`, `bash script.sh`.
* Making Scripts Executable: Using `chmod +x script.sh`.
* Comments: Documenting code with `#`.
* Output: Using `echo` and `printf`.
   <!-- * 📂 Mini Project: __Hello World Script with User Input__ -->


## 🟡 Phase 2: Variables and Data Handling
**Goal:** Store and manipulate data in scripts.

* Variable Declaration: Creating and using variables.
* Local vs Environment Variables: Understanding scope with `export`.
* Reading Input: Getting user input with `read`.
* Special Variables: `$0`, `$1-$9`, `$@`, `$#`, `$$`, `$?`.
* Command Substitution: Using `` `...` `` vs `$()`.
   <!-- * 📂 Mini Project: __System Information Reporter__ -->



## 🟠 Phase 3: Operators and Conditionals
**Goal:** Make decisions and perform calculations.

* Arithmetic Operators: `+`, `-`, `*`, `/`, `%` using `let`, `(( ))`, `bc`.
* Comparison Operators: `-eq`, `-ne`, `-gt`, `-lt`, `==`, `!=`.
* Logical Operators: `&&`, `||`, `!`.
* String Operators: `=`, `!=`, `-z`, `-n`.
* File Test Operators: `-f`, `-d`, `-e`, `-r`, `-w`, `-x`.
* Conditional Statements: `if`, `else`, `elif`, `case ... esac`.
* Test Commands: `[ ]` vs `[[ ]]` vs `test`.
   <!-- * 📂 Mini Project: __File Type Checker and Validator__ -->



## 🔵 Phase 4: Loops and Iteration
**Goal:** Automate repetitive tasks.

* `for` Loops: C-style and list-based iteration.
* `while` Loops: Condition-based looping.
* `until` Loops: Loop until condition is true.
* Loop Control: Using `break` and `continue`.
* Nested Loops: Loops within loops.
   <!-- * 📂 Mini Project: __Batch File Renamer__ -->



## 🟣 Phase 5: Functions and Modularity
**Goal:** Write reusable and organized code.

* Defining Functions: Creating custom functions.
* Function Arguments: Using `$1`, `$2`, `$@`, `$#`.
* Return Values: Returning data and exit status.
* Local vs Global Variables: Variable scope in functions.
* Recursive Functions: Functions calling themselves.
   <!-- * 📂 Mini Project: __Calculator Script with Functions__ -->



## 🟤 Phase 6: Command-Line Arguments
**Goal:** Make scripts interactive and flexible.

* Script Name: Accessing script name with `$0`.
* Positional Parameters: Using `$1`, `$2`, etc.
* All Arguments: Understanding `$@` vs `$*`.
* Argument Count: Using `$#`.
* Shifting Arguments: Using `shift` command.
* Parsing Options: Using `getopts` for flags.
   <!-- * 📂 Mini Project: __CLI-Based Todo Manager__ -->



## ⚫ Phase 7: Input/Output and Redirection
**Goal:** Control data flow in scripts.

* Standard Streams: stdin, stdout, stderr.
* Output Redirection: `>`, `>>`, `2>`, `&>`.
* Input Redirection: `<`, `<<<`.
* Pipes: Chaining commands with `|`.
* Here Documents: Multi-line input with `<<`.
* File Descriptors: Advanced I/O control.
* `tee` Command: Simultaneous output to file and screen.
   <!-- * 📂 Mini Project: __Log File Analyzer__ -->



## 🔴 Phase 8: File Operations and String Manipulation
**Goal:** Master file handling and text processing.

* File Testing: Checking file types with `-f`, `-d`, `-e`, `-r`, `-w`, `-x`.
* Reading Files: Line-by-line with `while read`.
* Writing to Files: Creating and modifying files.
* String Length: Using `${#str}`.
* Substrings: Extracting with `${str:start:length}`.
* Pattern Replacement: Using `${str/pattern/replacement}`.
* Regular Expressions: Pattern matching with `[[ =~ ]]`.
   <!-- * 📂 Mini Project: __CSV Data Parser and Reporter__ -->



## 🟠 Phase 9: Arrays and Advanced Data Structures
**Goal:** Work with collections of data.

* Declaring Arrays: Indexed and associative arrays.
* Accessing Elements: Using `${arr[0]}`, `${arr[@]}`.
* Array Length: Getting size with `${#arr[@]}`.
* Iterating Arrays: Looping through array elements.
* Array Operations: Adding, removing, slicing elements.
   <!-- * 📂 Mini Project: __Student Grade Management System__ -->



## 🟡 Phase 10: Text Processing Tools
**Goal:** Master external utilities for text manipulation.

* `grep`: Searching patterns in files.
* `sed`: Stream editor for text transformation.
* `awk`: Advanced text processing and reporting.
* `cut`, `paste`, `sort`, `uniq`: Data manipulation tools.
* `tr`: Character translation and deletion.
* `find` and `xargs`: File searching and batch operations.
   <!-- * 📂 Mini Project: __Server Access Log Analyzer__ -->



## 🔵 Phase 11: Archiving and Compression
**Goal:** Manage backups and compressed files.

* Creating Archives: Using `tar` command.
* Compression: `gzip`, `bzip2`, `zip`, `unzip`.
* Combined Operations: `tar -czf`, `tar -xzf`.
* Backup Strategies: Full, incremental, and differential backups.
   <!-- * 📂 Mini Project: __Automated Backup Script__ -->



## 🟣 Phase 12: Process and Job Management
**Goal:** Control running processes and background jobs.

* Background Processes: Running with `&`.
* Job Control: `jobs`, `fg`, `bg` commands.
* Process Information: Using `ps`, `top`, `htop`, `pgrep`.
* Killing Processes: `kill`, `killall`, `pkill` with signals.
* Exit Status: Checking `$?` for success/failure.
* Signal Handling: Using `trap` for cleanup operations.
   <!-- * 📂 Mini Project: __Process Monitor and Auto-Restart Script__ -->



## 🟢 Phase 13: Debugging and Error Handling
**Goal:** Write robust and error-free scripts.

* Debug Mode: Using `bash -x` and `set -x`.
* Strict Mode: `set -e`, `set -u`, `set -o pipefail`.
* Error Messages: Creating meaningful error output.
* Logging: Implementing script logging.
* Cleanup with `trap`: Handling script interruptions.
* ShellCheck: Static code analysis for Bash.
   <!-- * 📂 Mini Project: __Robust Deployment Script with Error Handling__ -->



## 🔴 Phase 14: Advanced Bash Features
**Goal:** Unlock powerful scripting techniques.

* Subshells: Using `( )` for isolated execution.
* Command Grouping: Using `{ }` for grouped commands.
* Named Pipes (FIFOs): Inter-process communication.
* Process Substitution: Using `<()` and `>()`.
* Parallel Execution: Using `xargs -P` and GNU parallel.
   <!-- * 📂 Mini Project: __Parallel File Processor__ -->



## 🟠 Phase 15: Cron Jobs and Task Scheduling
**Goal:** Automate script execution on schedule.

* Introduction to Cron: Understanding cron daemon.
* Cron Syntax: Minute, hour, day, month, weekday fields.
* Creating Cron Jobs: Using `crontab -e`.
* Common Schedules: Daily, weekly, monthly tasks.
* Logging Cron Output: Redirecting cron job output.
* Troubleshooting: Debugging failed cron jobs.
   <!-- * 📂 Mini Project: __Scheduled System Health Reporter__ -->



## 🟡 Phase 16: Networking and System Administration
**Goal:** Automate network and system tasks.

* Network Tools: `curl`, `wget`, `ping`, `nc`, `netstat`.
* SSH Automation: Using `ssh`, `scp`, `rsync` in scripts.
* System Monitoring: CPU, RAM, disk usage scripts.
* Disk Management: `df`, `du` for space monitoring.
* User Management: Creating and managing users/groups.
* Service Management: Starting, stopping, monitoring services.
   <!-- * 📂 Mini Project: __Server Health Monitoring Dashboard__ -->



## 🔵 Phase 17: Security Best Practices
**Goal:** Write secure and safe scripts.

* Input Validation: Sanitizing user input.
* Command Injection: Preventing security vulnerabilities.
* Secure Credentials: Handling passwords and API keys.
* File Permissions: Proper permission management.
* Quoting: Preventing word splitting and globbing.
* Principle of Least Privilege: Running with minimum permissions.
   <!-- * 📂 Mini Project: __Secure File Transfer Script__ -->


<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555)

---
**Made with ❤️ for the Open Source Community**