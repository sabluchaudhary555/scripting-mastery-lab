# 📊 Log Analyzer — CMD Mini Project

A simple Windows batch script that **reads any `.log` file and generates a clean summary report** — error counts, warning lines, and critical events, all saved to a `.txt` report file.

No Python. No tools. Just CMD.

---

## 🚀 What It Does

You give it a log file. It creates a report like this:

```
============================================
 LOG ANALYSIS REPORT
 File    : C:\Logs\app.log
 Date    : 2026-06-01 14:32
============================================

--- FILE STATS ---
Total lines : 1240

--- SEVERITY COUNTS ---
CRITICAL : 2
ERROR    : 47
WARNING  : 113
INFO     : 1078

--- ERROR LINES ---
[Line 42]   ERROR - Connection refused at 14:32:01
[Line 87]   ERROR - Timeout after 30 seconds
...

--- WARNING LINES ---
...

--- CRITICAL LINES ---
...
```

---

## ▶️ How to Use

**Option 1 — Pass log file directly:**
```cmd
log-analyzer.bat C:\Logs\app.log
```

**Option 2 — Double-click:**
Double-click `log-analyzer.bat` and paste your log file path when asked

**Option 3 — Drag & Drop:**
Drag a `.log` file onto `log-analyzer.bat`

---

## 📋 Requirements

- Windows 7 / 10 / 11
- Any `.log` or `.txt` file to analyze
- No installations needed

---

## 📂 Output

Report is saved **in the same folder as your log file**, named:
```
yourlogname_report.txt
```

Example: `app.log` → `app_report.txt`

---

## 🧠 CMD Concepts Used

| Concept | Where Used |
|---------|-----------|
| `find /c` | Count occurrences (errors, warnings) |
| `find /n /i` | Extract matching lines with numbers |
| `>` redirect | Create the report file |
| `>>` append | Add each section to report |
| `2> nul` | Suppress error output |
| `set /p` | Accept user input |
| `for /f` | Parse command output into variables |
| `echo` | Write section headers to report |
| `wmic` | Get current date/time |

---

## 📝 Sample Test Log

Create a quick test log to try it out:

```cmd
echo [INFO] App started > test.log
echo [INFO] Loading config >> test.log
echo [WARNING] Config missing, using defaults >> test.log
echo [INFO] Connected to database >> test.log
echo [ERROR] Failed to load module xyz >> test.log
echo [INFO] Retrying... >> test.log
echo [CRITICAL] Database connection lost >> test.log
echo [ERROR] Could not recover >> test.log
```

Then run:
```cmd
log-analyzer.bat test.log
```

---

## 🛠️ Want to Extend It?

- Add search for custom keywords (`set /p keyword=Search for: `)
- Extract IP addresses using `findstr /r`
- Add a count of unique error messages
- Auto-email the report using `blat` or PowerShell
- Schedule daily analysis with Windows Task Scheduler

---

Made with ❤️ using nothing but Windows CMD