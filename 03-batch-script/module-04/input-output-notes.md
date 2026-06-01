# CMD — Input, Output & Text Handling Notes

## 1. Viewing File Contents
```cmd
type file.txt                  :: print entire file to screen
type file1.txt file2.txt       :: view multiple files
type source.txt > dest.txt     :: copy file content

more file.txt                  :: view page by page (Space = next, Q = quit)
more +50 file.txt              :: start from line 50
more /s file.txt               :: squeeze multiple blank lines
dir C:\Windows | more          :: paginate any command output
```

| Use Case | Command |
|----------|---------|
| Small file, quick look | `type` |
| Large log file | `more` |
| Search inside file | `find` / `findstr` |
| Copy file content | `type file > newfile` |

## 2. echo — Output & Input
```cmd
echo Hello World               :: print text
echo.                          :: print blank line (NOT just "echo")
echo ===========================

@echo off                      :: hide commands in batch scripts (use at top)
echo on                        :: show commands again
```

**Escaping special characters:**
```cmd
echo 5 ^> 3 is true            :: print > literally
echo Progress: 100%%           :: print % literally
echo Salt ^& Pepper            :: print & literally
```

**User Input:**
```cmd
set /p name=Enter your name: 
echo Hello, %name%!

set /a result=10+5             :: math
echo %result%                  :: output: 15
```

## 3. Searching Text
```cmd
find "error" app.log           :: search for text in file
find /i "Error" app.log        :: case-insensitive
find /n "failed" app.log       :: show line numbers
find /c "timeout" net.log      :: count matches
find /v "success" results.txt  :: show lines NOT matching

tasklist | find "chrome"       :: filter command output
netstat -a | find "LISTENING"
```

```cmd
findstr "password" config.txt          :: basic search
findstr /i /s "admin" *.txt            :: case-insensitive + recursive
findstr /c:"error" /c:"warn" app.log   :: OR logic (multiple terms)
findstr /r "^[0-9]" data.txt           :: regex — lines starting with number
findstr /r "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" log.txt  :: find IP addresses
findstr /m "secret" *.txt              :: show only filenames (not lines)
```

| Feature | `find` | `findstr` |
|---------|--------|-----------|
| Regex | ❌ | ✅ `/r` |
| Recursive | ❌ | ✅ `/s` |
| Multiple patterns | ❌ | ✅ `/c:` |
| Count | ✅ `/c` | ❌ |

## 4. Output Redirection
```cmd
dir > filelist.txt             :: save output to file (overwrites)
echo Hello > notes.txt

dir C:\Bad 2> errors.txt       :: save only errors
del file.txt 2> nul            :: suppress error messages

dir C:\Windows > all.txt 2>&1  :: save BOTH output + errors to one file
command > nul 2>&1             :: suppress everything
```

**Append (don't overwrite):**
```cmd
echo New line >> log.txt       :: append to file
date /t >> activity.txt        :: append date
dir D:\ >> inventory.txt
```

**Redirect input:**
```cmd
sort < unsorted.txt            :: feed file as input
```

| Operator | Action |
|----------|--------|
| `>` | Redirect stdout (overwrite) |
| `>>` | Redirect stdout (append) |
| `2>` | Redirect stderr |
| `2>&1` | Merge errors into stdout |
| `< ` | Redirect stdin from file |
| `> nul` | Discard output |

## 5. Pipes & Filters
```cmd
tasklist | find "chrome"                    :: filter output
dir /b | sort                               :: sort output
dir C:\Windows\System32 | more             :: paginate output
dir /b *.dll | find /c ".dll"              :: count files

:: chain multiple pipes
netstat -a | find "LISTENING" | sort
dir /b C:\Windows\System32 | sort | more
```

**sort:**
```cmd
sort names.txt                 :: alphabetical
sort /r names.txt              :: reverse (Z→A)
dir /b | sort                  :: sort command output
sort unsorted.txt > sorted.txt :: sort and save
```

## 6. Standard Streams
```
stdin  (0) ← Keyboard input
stdout (1) → Normal output to screen
stderr (2) → Error output to screen
```

**nul device** — discards everything (like `/dev/null` in Linux):
```cmd
ping 8.8.8.8 > nul             :: hide output
command 2> nul                 :: hide errors
command > nul 2>&1             :: hide everything
copy nul emptyfile.txt         :: create empty file
```

**con device** — keyboard/screen directly:
```cmd
copy con myfile.txt            :: type file content from keyboard (Ctrl+Z to save)
copy myfile.txt con            :: print file to screen
```

## 7. Log Analysis
```cmd
:: filter by severity
find /i "error" app.log
find /i "warning" app.log
findstr /c:"error" /c:"warn" /c:"critical" app.log

:: count entries
find /c "" app.log             :: total line count
find /c /i "error" app.log     :: count errors

:: save analysis to report
echo === Report: %date% === > report.txt
find /c /i "error" app.log >> report.txt
find /n /i "error" app.log >> report.txt
```

**Common Windows Log Paths:**

| Log | Path |
|-----|------|
| Windows Update | `C:\Windows\WindowsUpdate.log` |
| CBS | `C:\Windows\Logs\CBS\CBS.log` |
| IIS Access | `C:\inetpub\logs\LogFiles\` |
| Event Logs | via `wevtutil` |

```cmd
:: Windows Event Log
wevtutil qe System /c:20 /rd:true /f:text | more
wevtutil qe Security /q:"*[System[(EventID=4625)]]" /c:10 /f:text
```