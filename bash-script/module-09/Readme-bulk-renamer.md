# 📁 Bulk File Renamer

A powerful Bash mini project that renames files in bulk with 13 rename operations, dry run preview mode, session logging, and a one-command undo system — all from an interactive terminal menu.

---

## 📁 Project Structure

```
bulk-renamer/
├── bulk_renamer.sh       # Main script
├── README.md             # This file
└── rename_logs/          # Auto-created on first run
    ├── rename_YYYYMMDD_HHMMSS.log   # Full session log
    └── undo_YYYYMMDD_HHMMSS.sh      # Undo script
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 Dry Run Mode | Preview every rename before applying — safe by default |
| ⚡ Live Mode | Toggle to actually apply changes |
| ↩️ Undo System | Auto-generates undo script — reverse any operation instantly |
| 📝 Session Logging | Every action logged to timestamped file |
| 📋 File Preview | List all files with sizes before renaming |
| 🎨 Color Output | Green confirmed / Yellow preview / Red errors |
| 13 Operations | From simple case changes to regex-powered renaming |

---

## 🚀 Getting Started

### 1. Clone or Download

```bash
git clone https://github.com/your-username/bulk-renamer.git
cd bulk-renamer
```

### 2. Give Execute Permission

```bash
chmod +x bulk_renamer.sh
```

### 3. Run the Script

```bash
# Run in current directory
./bulk_renamer.sh

# Run on a specific directory
./bulk_renamer.sh /path/to/your/files
```

---

## 📸 Demo

```
  ╔═══════════════════════════════════════════╗
  ║        📁 Bulk File Renamer  v1.0          ║
  ║   Rename · Clean · Organize · Undo        ║
  ╚═══════════════════════════════════════════╝

  Working directory: ./photos
  🔍 DRY RUN MODE — No files will be changed

  Choose a rename operation:

  ── Basic ──────────────────────────────────
  1)  Spaces → Underscores
  2)  Convert to Lowercase
  3)  Convert to Uppercase

  ── Prefix / Suffix ────────────────────────
  4)  Add Prefix
  5)  Add Suffix  (before extension)
  6)  Remove Prefix
  7)  Remove Suffix

  ── Advanced ───────────────────────────────
  8)  Change Extension
  9)  Find & Replace in Filename
  10) Add Sequential Numbering
  11) Add Date Prefix (YYYYMMDD_)
  12) Remove Special Characters
  13) Regex-Based Rename (sed)

  ── Tools ──────────────────────────────────
  14) Preview Files in Directory
  15) Undo Last Operation
  16) Toggle Dry Run / Live Mode
  17) Exit
```

### Dry Run Preview (Option 1)
```
  ── Replace Spaces with Underscores ──

  →  My Photo 01.jpg        →  My_Photo_01.jpg
  →  holiday trip 2024.png  →  holiday_trip_2024.png
  →  screen shot.png        →  screen_shot.png
  –  already_clean.jpg      (no change)

  📊 Summary:
  ✔  Renamed : 3
  –  Skipped : 1
```

### Live Mode (after Toggle)
```
  ✔  My Photo 01.jpg        →  My_Photo_01.jpg
  ✔  holiday trip 2024.png  →  holiday_trip_2024.png

  📊 Summary:
  ✔  Renamed : 3
  –  Skipped : 1

  Undo script : ./rename_logs/undo_20250115_103045.sh
  To undo     : bash ./rename_logs/undo_20250115_103045.sh
```

---

## 🛠️ All 13 Rename Operations

| # | Operation | Example |
|---|---|---|
| 1 | **Spaces → Underscores** | `my file.txt` → `my_file.txt` |
| 2 | **To Lowercase** | `Report.TXT` → `report.txt` |
| 3 | **To Uppercase** | `report.txt` → `REPORT.TXT` |
| 4 | **Add Prefix** | `file.txt` → `2024_file.txt` |
| 5 | **Add Suffix** | `report.txt` → `report_final.txt` |
| 6 | **Remove Prefix** | `draft_file.txt` → `file.txt` |
| 7 | **Remove Suffix** | `file_old.txt` → `file.txt` |
| 8 | **Change Extension** | `data.txt` → `data.md` |
| 9 | **Find & Replace** | `img_001.jpg` → `photo_001.jpg` |
| 10 | **Sequential Numbering** | `*.jpg` → `photo_001.jpg`, `photo_002.jpg` ... |
| 11 | **Add Date Prefix** | `file.txt` → `20250115_file.txt` |
| 12 | **Remove Special Chars** | `hello@world!.txt` → `helloworld.txt` |
| 13 | **Regex Rename (sed)** | `s/_/-/g` or `s/^img/photo/` |

---

## ↩️ Undo System

Every rename operation in **Live Mode** generates an undo script automatically:

```bash
# Auto-generated undo_20250115_103045.sh
#!/bin/bash
mv -- "./My_Photo_01.jpg" "./My Photo 01.jpg"
mv -- "./holiday_trip_2024.png" "./holiday trip 2024.png"
mv -- "./screen_shot.png" "./screen shot.png"
```

Undo from inside the tool **(Option 15)** or run directly:

```bash
bash ./rename_logs/undo_20250115_103045.sh
```

---

## 📝 Session Log

Every action is logged with a timestamp:

```
[2025-01-15 10:30:45] === Session started | dir=./photos ===
[2025-01-15 10:30:52] OP: spaces_to_underscores dir=./photos
[2025-01-15 10:30:52] RENAMED: './My Photo 01.jpg' → './My_Photo_01.jpg'
[2025-01-15 10:30:52] RENAMED: './holiday trip.png' → './holiday_trip.png'
[2025-01-15 10:31:10] MODE: switched to LIVE
[2025-01-15 10:31:45] OP: change_extension .txt→.md dir=./photos
[2025-01-15 10:31:45] CONFLICT: './notes.md' already exists — skipping
[2025-01-15 10:32:00] === Session ended ===
```

---

## 🔧 Bash Concepts Used

### `find` with null-safe output
```bash
# -print0 + read -d '' handles filenames with spaces safely
while IFS= read -r -d '' filepath; do
    name=$(basename "$filepath")
    # process each file
done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)
```

### `tr` — Character translation
```bash
# Spaces to underscores
echo "$name" | tr ' ' '_'

# To lowercase / uppercase
echo "$name" | tr '[:upper:]' '[:lower:]'
echo "$name" | tr '[:lower:]' '[:upper:]'

# Remove special characters
echo "$name" | tr -dc 'a-zA-Z0-9_.-'
```

### `sed` — Regex-based rename
```bash
# User-provided sed expression applied to filename
newname=$(echo "$name" | sed -E "$sed_expr")
# Examples: 's/_/-/g'   's/^img/photo/'   's/[0-9]//g'
```

### String Operations (Parameter Expansion)
```bash
ext="${name##*.}"          # get extension
base="${name%.*}"          # get base without extension
newname="${base}${suffix}.${ext}"    # rebuild filename
"${name//"$find"/"$replace"}"       # find & replace all
[[ "$name" == "$prefix"* ]]         # check prefix
"${name#"$prefix"}"                 # remove prefix
```

### `printf` — Zero-padded numbering
```bash
# Generates: photo_001.jpg, photo_002.jpg ...
newname="${base}_$(printf '%03d' $counter).${ext}"
```

### I/O Redirection — Logging
```bash
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOG_FILE"

# Generate undo script on the fly
echo "mv -- \"$new_path\" \"$old_path\"" >> "$UNDO_FILE"
```

### Process Substitution `< <()`
```bash
# Keeps loop in current shell so variables (counters) persist
done < <(find "$WORK_DIR" -type f -print0 | sort -z)
# vs pipe (subshell — counter would be lost):
# find ... | while read ... — counter resets after loop!
```

### Pipes for Transformation
```bash
# Multi-step filename cleanup pipeline
newname=$(echo "$name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')

# Sequential sort for consistent ordering
find . -type f -print0 | sort -z
```

### `case` statement — Menu routing
```bash
case $choice in
    1)  op_spaces_to_underscores ;;
    2)  op_to_lowercase ;;
    13) op_regex_rename ;;
    16) toggle_dry_run ;;
esac
```

### Functions — Modular design
```bash
do_rename()              # core rename + dry run logic
op_spaces_to_underscores()
op_change_extension()
op_regex_rename()
op_undo()                # undo last operation
print_summary()          # show rename/skip/error counts
log()                    # timestamped logging
```

---

## 🧪 Test Cases

### Spaces → Underscores
| Input | Output |
|---|---|
| `My Photo 01.jpg` | `My_Photo_01.jpg` |
| `holiday trip 2024.png` | `holiday_trip_2024.png` |
| `already_clean.txt` | *(skipped — no change)* |

### Sequential Numbering
| Input | Output |
|---|---|
| `DSC_4821.jpg` | `photo_001.jpg` |
| `IMG_3020.jpg` | `photo_002.jpg` |
| `scan0045.jpg` | `photo_003.jpg` |

### Regex Rename
| Expression | Input | Output |
|---|---|---|
| `s/_/-/g` | `my_file_name.txt` | `my-file-name.txt` |
| `s/^img/photo/` | `img_001.jpg` | `photo_001.jpg` |
| `s/[0-9]//g` | `report2024.txt` | `report.txt` |

### Remove Special Characters
| Input | Output |
|---|---|
| `hello@world!.txt` | `helloworld.txt` |
| `file (copy).txt` | `file copy.txt` |
| `report#2024.pdf` | `report2024.pdf` |

---

## ⚠️ Safety Notes

- Script starts in **Dry Run Mode** by default — no files are changed until you toggle to Live Mode
- Always **preview first** using Dry Run before switching to Live
- **Undo script** is generated automatically in Live Mode for every session
- Conflict detection prevents overwriting existing files
- Use `./bulk_renamer.sh /path/to/dir` to target a specific directory safely

---

## 📌 Requirements

- Bash **4.0+** (for `${var,,}` and `${var^^}` case conversion)
- Standard GNU tools: `find`, `tr`, `sed`, `awk`, `sort`
- Works on **Linux** — macOS users may need `gnu-sed` (`brew install gnu-sed`)

---
