# Bash Fundamentals - Module 1 Quick Reference

A concise reference guide for Bash scripting fundamentals covering shell basics, script execution, permissions, and help commands.

---

## 📑 Table of Contents

- [1. What is Bash?](#1-what-is-bash)
- [2. Shell, Terminal, and CLI](#2-shell-terminal-and-cli)
- [3. Environment Setup](#3-environment-setup)
- [4. Shebang](#4-shebang)
- [5. Making Scripts Executable](#5-making-scripts-executable)
- [6. Running Scripts](#6-running-scripts)
- [7. Getting Help](#7-getting-help)

---

## 1. What is Bash?

**Bash** (Bourne Again SHell) - Command-line interpreter and scripting language for Unix-based systems.

### Key Points
- **Created:** 1989 by Brian Fox (GNU Project)
- **Purpose:** Replacement for Bourne Shell (sh)
- **Type:** Interactive interpreter AND scripting language
- **Default:** Most Linux distributions, macOS (pre-Catalina)

### Features
- Command history & tab completion
- Variables, functions, control structures
- Pipes, redirections, job control

### Quick Commands
```bash
# Check current shell
echo $SHELL

# Check Bash version
bash --version

# Simple execution
echo "Hello from Bash!"
```

---

## 2. Shell, Terminal, and CLI

### Understanding the Components

| Component | Definition | Examples |
|-----------|------------|----------|
| **Shell** | Program that interprets commands | bash, zsh, fish, ksh |
| **Terminal** | Window to interact with shell | GNOME Terminal, iTerm2, Windows Terminal |
| **CLI** | Text-based interface | Opposite of GUI |
| **Console** | Low-level system access | Physical/virtual direct interface |

### Visual Flow
```
User → Terminal (Display) → Shell (Interpreter) → Kernel (OS Core) → Hardware
```

### Quick Commands
```bash
# Identify terminal
echo $TERM

# Check terminal type
tty

# See running shell
ps -p $$

# List available shells
cat /etc/shells
```

---

## 3. Environment Setup

### Linux Setup
```bash
# Check Bash installation
which bash
bash --version

# Install Bash (Ubuntu/Debian)
sudo apt update && sudo apt install bash

# Set as default shell
chsh -s /bin/bash
```

### macOS Setup
```bash
# Check version (default: 3.2)
bash --version

# Install latest via Homebrew
brew install bash
sudo echo /usr/local/bin/bash >> /etc/shells
chsh -s /usr/local/bin/bash
```

### Windows (WSL) Setup
```powershell
# PowerShell (Administrator)
wsl --install

# Access Bash
wsl
```

### Text Editors Quick Reference

| Editor | Exit | Save | Save & Exit |
|--------|------|------|-------------|
| **nano** | `Ctrl+X` | `Ctrl+O` | `Ctrl+O` → `Enter` → `Ctrl+X` |
| **vim** | `Esc` → `:q` | `Esc` → `:w` | `Esc` → `:wq` or `ZZ` |

---

## 4. Shebang

**Shebang** (`#!`) - Tells system which interpreter to use

### Syntax
```bash
#!/bin/bash
```

### Common Shebangs
```bash
#!/bin/bash              # Standard Bash
#!/bin/sh                # POSIX shell
#!/usr/bin/env bash      # Portable (recommended)
#!/bin/bash -x           # Debug mode
#!/bin/bash -e           # Exit on error
#!/bin/bash -u           # Error on undefined variables
#!/bin/bash -euo pipefail  # Strict mode (production)
```

### Example
```bash
# Without shebang - need interpreter
bash script.sh

# With shebang - direct execution
chmod +x script.sh
./script.sh
```

---

## 5. Making Scripts Executable

### File Permissions

**Format:** `-rwxrwxrwx`
- `r` = read (4)
- `w` = write (2)
- `x` = execute (1)

**Categories:** Owner | Group | Others

### chmod Examples
```bash
# Make executable
chmod +x script.sh         # Add execute for all
chmod 755 script.sh        # rwxr-xr-x
chmod u+x script.sh        # Owner only

# Remove execute
chmod -x script.sh
chmod 644 script.sh        # rw-r--r--

# Check permissions
ls -l script.sh
stat -c "%a %n" script.sh
```

### Practical Example
```bash
# Create script
cat > hello.sh << 'EOF'
#!/bin/bash
echo "Hello, World!"
EOF

# Make executable
chmod +x hello.sh

# Run it
./hello.sh
```

---

## 6. Running Scripts

### Three Main Methods

| Method | Execute Permission | Shebang | Shell Used | Variables Persist |
|--------|-------------------|---------|------------|-------------------|
| `./script.sh` | ✅ YES | ✅ YES | From shebang | ❌ NO (subshell) |
| `bash script.sh` | ❌ NO | ❌ NO | Explicitly bash | ❌ NO (subshell) |
| `source script.sh` | ❌ NO | ❌ NO | Current shell | ✅ YES (same shell) |

### Method 1: Direct Execution
```bash
# Requires: chmod +x & shebang
./script.sh

# With path
/full/path/to/script.sh
```

### Method 2: Explicit Interpreter
```bash
# No permissions needed
bash script.sh
sh script.sh

# With options
bash -x script.sh    # Debug mode
bash -n script.sh    # Syntax check only
```

### Method 3: Source/Dot Command
```bash
# Runs in current shell - variables persist
source script.sh
. script.sh

# Common use: configuration files
source ~/.bashrc
. /etc/profile
```

### Adding Scripts to PATH
```bash
# Create bin directory
mkdir -p ~/bin

# Move script
mv myscript.sh ~/bin/

# Add to PATH (in ~/.bashrc)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Now run from anywhere
myscript.sh
```

---

## 7. Getting Help

### Command Reference Table

| Command | Purpose | What It Shows |
|---------|---------|---------------|
| `man` | Full manual | Complete documentation |
| `--help` | Quick reference | Options and usage |
| `info` | Hypertext docs | Detailed GNU info |
| `type` | Command type | Alias/builtin/function/file |
| `which` | Executable location | Path to binary in PATH |
| `whereis` | All locations | Binary, source, man pages |

### man (Manual Pages)
```bash
# Basic usage
man ls
man bash

# Specific section
man 1 printf    # User command
man 3 printf    # C library function

# Search keyword
man -k copy

# Navigation
# Space: Next page
# b: Previous page
# /pattern: Search
# q: Quit
```

### --help Flag
```bash
# Quick reference
ls --help
grep --help
bash --help

# Short form
mkdir -h
```

### info Command
```bash
# Hypertext documentation
info bash
info grep

# Navigation
# n: Next node
# p: Previous node
# q: Quit
```

### type Command
```bash
# What is this command?
type ls        # alias
type cd        # builtin
type bash      # file

# Show all locations
type -a echo

# Show type only
type -t ls     # alias
type -t cd     # builtin
type -t grep   # file
```

### which Command
```bash
# Find executable location
which bash
which python3

# Show all matches
which -a python

# Check if exists
if which python3 > /dev/null 2>&1; then
    echo "Python3 found"
fi
```

### whereis Command
```bash
# Find binary, source, and manual
whereis bash
# Output: bash: /bin/bash /etc/bash.bashrc /usr/share/man/man1/bash.1.gz

# Binary only
whereis -b bash

# Manual only
whereis -m bash
```

---

## 🎯 Quick Tips

### When to Use What

**Direct Execution (`./script.sh`):**
- Production scripts
- Standalone programs
- When you need portability

**Bash Command (`bash script.sh`):**
- Testing scripts
- No execute permission available
- Debugging with `-x`

**Source Command (`source script.sh`):**
- Configuration files (`.bashrc`, `.profile`)
- Setting environment variables
- Loading functions/aliases

### Help Command Selection

- **Quick reminder?** → Use `--help`
- **Detailed learning?** → Use `man`
- **Is it installed?** → Use `which` or `type`
- **Where is everything?** → Use `whereis`
- **What type is it?** → Use `type`

---

## 📝 Cheat Sheet

### Essential Commands
```bash
# Check shell
echo $SHELL
bash --version

# Create script
nano script.sh           # or vim script.sh

# Make executable
chmod +x script.sh

# Run script
./script.sh              # Direct
bash script.sh           # Explicit interpreter
source script.sh         # Current shell

# Get help
man command
command --help
type command
which command
whereis command
```

### Script Template
```bash
#!/bin/bash
# Script description
# Author: Your Name
# Date: YYYY-MM-DD

# Your code here
echo "Hello, World!"
```

---

## 📚 Resources

- [Official Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Bash Guide for Beginners](https://tldp.org/LDP/Bash-Beginners-Guide/html/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)

---


<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)]

---
**Made with ❤️ for the Open Source Community**


<br>


**Note:** This is a learning project created as part of Bash scripting fundamentals. Feel free to use it for educational purposes!