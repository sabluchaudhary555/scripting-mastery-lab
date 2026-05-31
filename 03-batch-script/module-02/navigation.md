# CMD — Basic Navigation Quick Reference

> One concept. One example. No fluff.

---

## Drives

```bat
:: list all drives
wmic logicaldisk get name

:: switch drives — just type the letter + colon
D:
C:
E:

:: cd alone does NOT switch drives — this stays on C:
cd D:\Projects     :: ✗ still on C:

:: correct way
D:                 :: ✓ now on D:
cd Projects        :: ✓ now in D:\Projects

:: or in one shot
cd /d D:\Projects  :: ✓ switches drive AND directory together
```

---

## Paths

**Absolute** — starts from drive root, works from anywhere:

```bat
cd C:\Users\Alice\Documents
type C:\Users\Alice\notes.txt
copy C:\file.txt D:\Backup\file.txt
```

**Relative** — starts from current directory:

```bat
:: assume you're at C:\Users\Alice
cd Documents            :: → C:\Users\Alice\Documents
cd ..\Desktop           :: → C:\Users\Desktop
type notes.txt          :: reads C:\Users\Alice\notes.txt
```

**Special symbols:**

| Symbol | Meaning |
|---|---|
| `\` | Root of current drive |
| `.` | Current directory |
| `..` | Parent directory (one level up) |
| `..\..` | Two levels up |
| `*` | Wildcard — any characters |
| `?` | Wildcard — single character |

```bat
cd .          :: no change
cd ..         :: one level up
cd ..\..      :: two levels up
dir .         :: list current folder
dir ..        :: list parent folder
```

---

## cd — Change Directory

```bat
cd                        :: print current directory
cd foldername             :: go into subfolder
cd ..                     :: go up one level
cd \                      :: go to root of current drive
cd /d D:\Projects         :: switch drive AND folder at once

:: paths with spaces — always quote them
cd "C:\Program Files"
cd "C:\Users\Alice\My Documents"

:: jump using environment variables
cd %USERPROFILE%          :: C:\Users\Alice
cd %USERPROFILE%\Desktop  :: C:\Users\Alice\Desktop
cd %APPDATA%              :: C:\Users\Alice\AppData\Roaming
cd %TEMP%                 :: temp folder
cd %WINDIR%               :: C:\Windows
cd %ProgramFiles%         :: C:\Program Files
```

---

## pushd / popd — Save and Return

```bat
pushd C:\Windows\System32   :: saves current dir, goes to System32
pushd C:\Program Files      :: saves System32, goes to Program Files

popd                        :: back to System32
popd                        :: back to original dir
```

> Use `pushd`/`popd` in batch scripts when you need to temporarily visit a folder and come back cleanly.

---

## Windows Directory Structure

```
C:\
├── Windows\
│   └── System32\           ← core commands and executables
├── Users\
│   └── Alice\
│       ├── Desktop\
│       ├── Documents\
│       ├── Downloads\
│       └── AppData\        ← hidden — app configs
├── Program Files\          ← 64-bit apps
├── Program Files (x86)\    ← 32-bit apps
├── ProgramData\            ← hidden — shared app data
└── Temp\                   ← system temp files
```

| Path | What's there |
|---|---|
| `C:\Windows\System32` | Core system executables and DLLs |
| `C:\Users\%USERNAME%` | Your personal profile |
| `C:\Users\%USERNAME%\AppData` | Hidden app settings |
| `C:\Program Files` | 64-bit software |
| `%TEMP%` | Temporary files |

---

## dir — List Files and Folders

```bat
dir                    :: list current directory
dir C:\Users           :: list specific path
dir *.txt              :: list only .txt files
dir /a                 :: show ALL files including hidden
dir /ah                :: hidden files only
dir /s                 :: recursive — search subfolders too
dir /b                 :: bare — filenames only (good for scripting)
dir /p                 :: pause page by page
dir /w                 :: wide format
dir /o:n               :: sort by name
dir /o:d               :: sort by date (oldest first)
dir /o:-d              :: sort by date (newest first)
dir /o:s               :: sort by size
dir /q                 :: show file owner
```

**Wildcards:**

```bat
dir *.txt              :: all .txt files
dir file?.txt          :: file1.txt, filea.txt (? = one char)
dir report*            :: report.txt, report_final.pdf
dir *2024*             :: any file with "2024" in the name
dir /b *.exe           :: just the exe names, no decoration
```

**Reading dir output:**

```
24-05-2026  10:30    <DIR>      Projects
24-05-2026  09:15        1,245  notes.txt
24-05-2026  08:00       45,678  report.pdf
             2 File(s)    46,923 bytes
             1 Dir(s)  50,000,000,000 bytes free
```

| Column | Meaning |
|---|---|
| Date / Time | Last modified |
| `<DIR>` | It's a folder, not a file |
| Number | File size in bytes |
| Bottom line | File count + total size + free space |

---

## tree — Visual Folder Structure

```bat
tree                   :: folder tree from current dir
tree C:\Users\Alice    :: folder tree of a specific path
tree /f                :: include files (not just folders)
tree /a                :: use plain ASCII instead of box-drawing chars
```

```
C:\Users\Alice
├───Documents
│   └───Projects
│           script.bat
├───Desktop
└───Downloads
        setup.exe
```

---

## cls — Clear Screen

```bat
cls     :: wipes the screen — does NOT undo commands
```

Use it: after lots of output, before a demo, inside batch scripts to keep things readable.

---

## exit — Close CMD or End a Script

```bat
exit          :: close the CMD window
exit /b       :: exit script only — keep CMD window open
exit /b 0     :: exit with code 0 (success)
exit /b 1     :: exit with code 1 (failure)
```

**Check exit code:**

```bat
ping 8.8.8.8
echo %ERRORLEVEL%     :: 0 = success, 1 = failure
```

**Common exit codes:**

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | General error |
| `2` | File not found |
| `5` | Access denied |
| `9009` | Command not found |

```bat
:: one-liner error check
ping 8.8.8.8 && echo Reachable || echo Not reachable
```