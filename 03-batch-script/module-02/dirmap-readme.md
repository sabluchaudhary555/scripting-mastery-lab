# dirmap 🗺️

> Interactive directory explorer and file finder for CMD.
> Browse folders, jump to common locations, find files, see sizes — all from one tool.

---

## Why this exists

Learning CMD navigation is one thing. Actually using it efficiently is another.
`dirmap` is the tool I wanted while learning — a cleaner `dir`, one-word jumps
to common Windows folders, a recursive file finder, and a session history so
you can always retrace where you've been.

---

## At a Glance

| Command | What it does |
|---|---|
| `dirmap` | Launch interactive folder browser |
| `dirmap find *.log` | Find all `.log` files recursively from current folder |
| `dirmap find report 7` | Find files named "report" modified in last 7 days |
| `dirmap size C:\Users` | Show size of each subfolder |
| `dirmap go desktop` | Jump to Desktop instantly |
| `dirmap tree C:\Projects` | Visual folder tree with total file count |
| `dirmap hist` | Show everywhere you've been this session |

---

## Install

```bat
:: copy to System32 to use from anywhere in CMD
copy dirmap.bat C:\Windows\System32\dirmap.bat

:: or run directly from its folder
dirmap.bat
```

---

## Usage

```
dirmap [command] [args]
```

---

## Output

### Interactive mode

```
C:\> dirmap

 ╔══════════════════════════════════════════════════════╗
 ║           dirmap v1.0 — directory explorer           ║
 ╚══════════════════════════════════════════════════════╝

 Location: C:\Users\Alice\Documents
 ──────────────────────────────────────────────────────

   [DIR]  Projects
   [DIR]  Reports
   [DIR]  Archive
   12 KB  notes.txt
   46 KB  report.pdf
    3 KB  todo.txt

 3 folder(s)   3 file(s)

 Commands: cd <folder>  |  cd ..  |  d: (drive)  |  q (quit)
           find <*.ext>  |  size  |  tree  |  hist  |  go <name>

 Navigate: _
```

### find

```
C:\> dirmap find *.log

 Searching for "*.log" in C:\Users\Alice
 ──────────────────────────────────────────────────────

   14 KB   C:\Users\Alice\AppData\Local\app\error.log
    2 KB   C:\Users\Alice\Documents\Projects\debug.log
  128 KB   C:\Users\Alice\Documents\app-2026-05.log

 Found: 3 file(s)
```

With date filter — files modified in last 7 days:

```
C:\> dirmap find *.log 7

 Searching for "*.log" in C:\Users\Alice
 Modified in last 7 days
 ──────────────────────────────────────────────────────

   128 KB   C:\Users\Alice\Documents\app-2026-05.log

 Found: 1 file(s)
```

### size

```
C:\> dirmap size C:\Users\Alice

 Folder sizes in: C:\Users\Alice
 ──────────────────────────────────────────────────────
   214 MB   AppData
    88 MB   Documents
    42 MB   Downloads
     1 MB   Desktop
     0 MB   Favorites
```

### go — jump to common locations

```
C:\Windows\System32> dirmap go desktop

 Jumped to: C:\Users\Alice\Desktop

C:\Users\Alice\Desktop> dirmap go temp

 Jumped to: C:\Users\Alice\AppData\Local\Temp
```

**Available shortcuts:**

| Name | Goes to |
|---|---|
| `desktop` | `%USERPROFILE%\Desktop` |
| `documents` | `%USERPROFILE%\Documents` |
| `downloads` | `%USERPROFILE%\Downloads` |
| `appdata` | `%APPDATA%` |
| `temp` | `%TEMP%` |
| `windows` | `%WINDIR%` |
| `system32` | `%WINDIR%\System32` |
| `programs` | `%ProgramFiles%` |
| `root` | `C:\` |
| `home` | `%USERPROFILE%` |

### tree

```
C:\> dirmap tree C:\Users\Alice\Documents

 Folder tree: C:\Users\Alice\Documents
 ──────────────────────────────────────────────────────
 C:\Users\Alice\Documents
 +---Projects
 |   +---WebApp
 |   |       index.html
 |   |       style.css
 |   \---Scripts
 |           deploy.bat
 +---Reports
 |       q1-2026.pdf
 \---Archive

 Total: 5 file(s) in 5 folder(s)
```

### hist — navigation history

```
C:\> dirmap hist

 Navigation history this session:
 ──────────────────────────────────────────────────────
   1.  C:\
   2.  C:\Users\Alice
   3.  C:\Users\Alice\Documents
   4.  C:\Windows\System32
   5.  C:\Program Files
```

---

## Examples

```bat
:: open interactive explorer from current folder
dirmap

:: find all batch files anywhere under C:\Users
dirmap find *.bat

:: find any file with "budget" in the name changed recently
dirmap find budget 14

:: see which subfolder is eating disk space
dirmap size C:\Users\Alice

:: jump somewhere fast without typing the full path
dirmap go downloads
dirmap go system32
dirmap go temp

:: visual snapshot of a project
dirmap tree C:\Projects\MyApp

:: see where you've been this session
dirmap hist
```

---

## CMD Navigation Concepts Used

| Concept | Where it shows up |
|---|---|
| Drive switching `D:` | Interactive mode handles bare drive letters as navigation input |
| `cd /d` | `cmd_go` uses `cd /d` to switch drive and folder simultaneously |
| Absolute paths | All `go` shortcuts use absolute `%ENV_VAR%` paths — reliable regardless of current dir |
| Relative paths | Interactive `cd <folder>` and `cd ..` use relative navigation |
| `%USERPROFILE%` `%APPDATA%` `%TEMP%` `%WINDIR%` | All used in the `go` shortcut table |
| `dir /s /b` | Core of the `find` command — recursive bare listing |
| `dir /ad` `dir /a-d` | Used in `tree` to count folders vs files separately |
| `dir *.ext` wildcards | `find *.log`, `find report*` — passed straight to `dir` |
| `tree /f /a` | Used in `cmd_tree` to show full file tree in ASCII format |
| `pushd` / `popd` | `cmd_size` uses `pushd` to visit a folder and return cleanly |
| `cd \` | Root navigation available in interactive mode |
| `forfiles /d` | Date-filtered find — finds files modified within N days |
| `exit /b` | Each function returns with `goto :eof` — keeps CMD session alive |
| `cls` | Available as a command in interactive mode |
| `%ERRORLEVEL%` | Checked after every `cd` attempt to catch bad paths |
| `find /c /v ""` | Counts lines — used for history trimming and file totals |
| `move /y` | Atomic swap when trimming history file |

---

## File Structure

```
cmd-navigation/
├── notes/
│   └── cmd-navigation-notes.md   ← quick reference for all navigation concepts
└── project/
    ├── dirmap.bat                 ← the script
    └── README.md                 ← this file
```

---

## Requirements

- Windows 7 or newer
- No admin rights needed
- `forfiles` must be available — included in Windows Vista and later

---

> **Tip:** Inside interactive mode, you can type `go desktop` without the `dirmap` prefix.
> The session history in `%TEMP%\dirmap_history.txt` resets when you close CMD.

---

## License

MIT