# 📁 Bulk File Renamer
> A Bash script that renames all files of a given extension in a directory — with a custom prefix and auto-numbered pattern.  


## 📸 Preview

```
╔══════════════════════════════════════╗
║        📁 Bulk File Renamer          ║
║     Bash Module 5 — Loops            ║
╚══════════════════════════════════════╝

📂 Directory  : ./photos
🔍 Extension  : .jpg
🏷️  Prefix     : photo
📄 Files Found: 5

⚠️  Rename all 5 file(s)? [y/N]: y

🔄 Renaming files...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ Renamed: IMG_4521.jpg      →  photo_001.jpg
  ✅ Renamed: IMG_4522.jpg      →  photo_002.jpg
  ✅ Renamed: random_name.jpg   →  photo_003.jpg
  ✅ Renamed: pic2024.jpg       →  photo_004.jpg
  ✅ Renamed: DSC_0091.jpg      →  photo_005.jpg
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary:
  ✅ Successfully renamed : 5 file(s)
  ❌ Failed               : 0 file(s)
  📁 Saved in             : ./photos
```

---

## ⚙️ Installation

**Step 1 — Clone the repo**
```bash
git clone https://github.com/sabluchaudhary555/scripting-mastery-lab.git
cd scripting-mastery-lab/module5
```

**Step 2 — Give execute permission**
```bash
chmod +x bulk_file_renamer.sh
```

**Or create directly in Linux (WSL/Kali):**
```bash
cat > bulk_file_renamer.sh << 'EOF'
# paste script content here
EOF
chmod +x bulk_file_renamer.sh
```

---

## 🚀 Usage

```bash
./bulk_file_renamer.sh <directory> <extension> <prefix>
```

**Syntax:**

| Argument | Description | Example |
|----------|-------------|---------|
| `directory` | Path to target folder | `./photos` |
| `extension` | File type to rename | `jpg` |
| `prefix` | New name prefix | `photo` |

**Examples:**

```bash
# Rename all .jpg files in ./photos with prefix "photo"
./bulk_file_renamer.sh ./photos jpg photo

# Rename all .txt files in ./docs with prefix "report"
./bulk_file_renamer.sh ./docs txt report

# Rename all .sh files in current directory with prefix "script"
./bulk_file_renamer.sh . sh script
```

**Output pattern:**
```
prefix_001.ext
prefix_002.ext
prefix_003.ext
...
```

---

## 🛠️ Requirements

| Requirement | Details |
|-------------|---------|
| OS | Linux / macOS / WSL |
| Shell | Bash `v4.0+` |
| Dependencies | None (uses built-in `mv`, `ls`, `basename`) |
| Permissions | Read + Write access on target directory |

---

## 🧠 Concepts Covered (Module 5)

| Concept | Used In |
|---------|---------|
| `for` loop over files | Main renaming loop — `for file in dir/*.ext` |
| `[[ ]]` conditions | Argument validation, confirm prompt check |
| `continue` | Skip non-existent glob matches |
| `(( counter++ ))` | Auto-incrementing file number |
| `printf '%03d'` | Zero-padded numbering (001, 002...) |
| `basename` | Extract filename from full path |
| `wc -l` | Count matching files before rename |
| `mv` | Actual file renaming |

---

## ⚠️ Important Notes

- Script asks for **confirmation before renaming** — safe to run
- Files are renamed **in-place** — original directory is modified
- Zero-padded numbering ensures correct sort order (`001` not `1`)
- If a rename fails, it is **counted and reported** in summary
- Does **not** recurse into subdirectories (flat rename only)

---

## 📁 File Structure

```
module5/
├── bulk_file_renamer.sh   # Main script
└── README.md              # This file
```

---