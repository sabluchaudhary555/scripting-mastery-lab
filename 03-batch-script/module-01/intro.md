# CMD — Introduction Quick Reference

> One concept. One example. No fluff.

---

## What is CMD?

- Command-line interpreter built into Windows — `cmd.exe`
- Lives at `C:\Windows\System32\cmd.exe`
- Based on MS-DOS shell — runs since Windows NT (1993)
- Processes commands one at a time, line by line
- Talks directly to the Windows OS kernel

```bat
where cmd
:: → C:\Windows\System32\cmd.exe

ver
:: → Microsoft Windows [Version 10.0.19045.3803]
```

---

## CMD Interface

```
┌──────────────────────────────────────────────┐
│ Administrator: Command Prompt          [─][□][✕] │
├──────────────────────────────────────────────┤
│ Microsoft Windows [Version 10.0.19045.3803]  │
│ (c) Microsoft Corporation.                   │
│                                              │
│ C:\Users\Alice>_                             │
└──────────────────────────────────────────────┘
```

| Part | What it is |
|---|---|
| Title bar | Path of running shell — shows "Administrator:" if elevated |
| Prompt | Current drive + path + `>` symbol |
| Cursor `_` | Where you type |
| Output area | Where results appear |

**Customize the window:**

```bat
color 0A             :: green text on black (classic)
color F0             :: black text on white
title My Terminal    :: change title bar text
mode con cols=120 lines=40   :: resize window
```

---

## The Prompt

Default format: `C:\Users\Alice>`

| Part | Meaning |
|---|---|
| `C:` | Current drive letter |
| `\Users\Alice` | Current directory path |
| `>` | Input separator |

**Customize with `PROMPT`:**

```bat
PROMPT $P$G           :: default → C:\Users\Alice>
PROMPT [$T] $P$G      :: with time → [14:35:22] C:\Users\Alice>
PROMPT CMD$G          :: simple → CMD>
```

| Code | Inserts |
|---|---|
| `$P` | Current path |
| `$G` | `>` character |
| `$T` | Current time |
| `$D` | Current date |
| `$N` | Current drive letter |
| `$$` | Literal `$` |

---

## Drive Letters & Paths

```bat
:: switch drives
D:          :: → D:\>
C:          :: back to C

:: absolute path — from root
C:\Users\Alice\Documents\notes.txt

:: relative path — from current directory
Documents\notes.txt

:: special symbols
\           :: root of current drive
.           :: current directory
..          :: parent directory (one level up)
```

---

## Current Directory (Working Directory)

```bat
cd                   :: print current directory
echo %CD%            :: same thing

cd Documents         :: go into Documents
cd ..                :: go up one level
cd \                 :: jump to root
cd /d D:\Projects    :: change drive AND directory at once
```

> All relative paths resolve from here. If a file isn't in the
> current directory, either `cd` to it or use the full absolute path.

---

## Normal User vs Administrator CMD

| | Normal | Administrator |
|---|---|---|
| Prompt title | `Command Prompt` | `Administrator: Command Prompt` |
| System files | Read only | Full access |
| Install software | ✗ | ✓ |
| Modify registry | ✗ | ✓ |
| `net user /add` | ✗ Access denied | ✓ Works |

**Open Normal CMD:**
```
Win + R → cmd → Enter
Start → type cmd → Enter
```

**Open Admin CMD:**
```
Start → type cmd → Right-click → Run as administrator
Win + R → cmd → Ctrl + Shift + Enter
```

**Check if you're elevated:**
```bat
whoami /groups | find "S-1-16-12288"
:: if this line appears → you are admin
```

---

## CMD vs PowerShell

| Feature | CMD | PowerShell |
|---|---|---|
| Based on | MS-DOS shell | .NET Framework |
| Output | Plain text | Objects |
| Script file | `.bat` / `.cmd` | `.ps1` |
| Error handling | Basic (`errorlevel`) | `Try/Catch/Finally` |
| Piping | Text-based | Object-based |
| Commands | ~80 built-in | 200+ cmdlets |
| Remote mgmt | Limited | Full (WinRM) |

**Use CMD when:**
- Quick file/folder operations
- Legacy `.bat` scripts
- Network diagnostics (`ping`, `tracert`, `netstat`)
- PowerShell is restricted by Group Policy
- Pentesting / CTF on older systems

**Use PowerShell when:**
- Complex automation and admin tasks
- Working with Active Directory / Azure
- Parsing CSV, XML, JSON
- Need proper error handling

```bat
:: CMD
dir *.txt

:: PowerShell equivalent (more info)
Get-ChildItem -Filter *.txt
```

---

## Command Syntax

```
COMMAND [/switches] [arguments]
```

```bat
dir                          :: command only
dir /a                       :: command + switch
dir C:\Users /a /s           :: command + path + multiple switches
ping 8.8.8.8                 :: command + argument
copy file.txt D:\backup\     :: command + two arguments
```

**Switches use `/` (not `-` like Linux):**

```bat
dir /?          :: show help for any command
dir /a          :: show hidden files
dir /s          :: recursive
dir /o:n        :: sort by name
dir /o:d        :: sort by date modified
```

**Paths with spaces — use double quotes:**

```bat
cd "C:\Program Files"
copy "my file.txt" "D:\My Backup\"
```

**CMD is NOT case sensitive:**

```bat
DIR == dir == Dir == dIr    :: all identical
```

**Chain commands:**

```bat
cmd1 & cmd2        :: run both no matter what
cmd1 && cmd2       :: run cmd2 only if cmd1 succeeded
cmd1 || cmd2       :: run cmd2 only if cmd1 failed
```

```bat
mkdir TestFolder && cd TestFolder
:: creates folder, enters it — only if mkdir works
```

---

## Help System

```bat
dir /?          :: full help for any command — always check this first
help            :: list all built-in CMD commands
help dir        :: detailed help for a specific command
```

**Reading help output:**

```
COPY [/D] [/V] [/Y | /-Y] source [destination]
```

| Symbol | Meaning |
|---|---|
| `[ ]` | Optional — can be omitted |
| `\|` | Mutually exclusive — pick one |
| `source` | You provide this value |
| `COPY` | The command name itself |

```bat
:: useful commands worth reading the help for
xcopy /?        :: 20+ options for advanced copying
robocopy /?     :: 100+ options — the serious copy tool
icacls /?       :: file permissions
schtasks /?     :: task scheduler
netstat /?      :: network connections
```

> There are no man pages in CMD. `/?` is your only native reference.
> Get in the habit of running it before Googling.