# 📁 Smart Backup — CMD Mini Project

A simple Windows batch script that **automatically sorts and backs up files by type** into a dated folder. No software needed — just plain CMD.

---

## 🚀 What It Does

You give it a folder. It creates a backup like this:

```
Backup_2026-06-01/
├── Documents/     → .pdf, .docx, .txt, .xlsx, .pptx
├── Images/        → .jpg, .png, .gif, .bmp
├── Videos/        → .mp4, .avi, .mkv, .mov
├── Code/          → .py, .js, .html, .css, .java, .bat
├── Others/        → everything else
└── backup_log.txt → list of all backed up files
```

---

## ▶️ How to Use

**Option 1 — Drag & Drop**
Drag any folder onto `smart-backup.bat`

**Option 2 — Run from CMD**
```cmd
smart-backup.bat C:\Users\YourName\Desktop\MyFiles
```

**Option 3 — Double click**
Double-click the .bat file and type/paste your folder path when asked

---

## 📋 Requirements

- Windows 7 / 10 / 11
- No installation needed
- Just the `.bat` file

---

## 📂 Example

```
Before:
MyFiles/
  resume.pdf
  photo.jpg
  notes.txt
  app.py
  movie.mp4
  random.zip

After running smart-backup.bat:
Backup_2026-06-01/
  Documents/  → resume.pdf, notes.txt
  Images/     → photo.jpg
  Videos/     → movie.mp4
  Code/       → app.py
  Others/     → random.zip
  backup_log.txt
```

---

## 🧠 CMD Concepts Used

| Concept | Where Used |
|---------|-----------|
| `mkdir` | Creating category folders |
| `copy` | Copying files to backup |
| `for` loop | Looping through files by extension |
| `if exist` | Checking if file/folder exists |
| `echo` + `>>` | Writing the backup log |
| `set /p` | Taking user input |
| `wmic` | Getting today's date |
| `%~nxf` | Extracting filename from path |

---

## ⚠️ Notes

- The script only copies files from the **top level** of the source folder (not subfolders)
- It does **not delete** your original files — safe to run anytime
- Backup folder is created **next to** your source folder

---

## 🛠️ Want to Extend It?

- Add `/s` flag to `copy` to include subfolders
- Add more file extensions in the `for` loops
- Change `copy` to `robocopy` for large folder support
- Schedule it with Windows Task Scheduler for auto backups

---

Made with ❤️ using nothing but Windows CMD