# 🔐 Password-Protected Zip Archiver

A Bash script that zips and encrypts any folder or file using **AES-256 encryption** — one command, zero hassle.

---

## 📋 Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Output Structure](#output-structure)
- [Security Notes](#security-notes)
- [Concepts Used](#concepts-used)

---

## ✨ Features

- 🔐 **AES-256 encryption** via `zip --encrypt`
- 📁 Works on **files and folders**
- ✅ **Archive verification** after creation — auto-deletes if corrupt
- 🕐 **Timestamped** archive names to avoid overwrites
- 📝 **Activity log** saved to `archiver.log`
- 🎨 **Colored terminal output** for clarity
- 💬 **Password confirmation prompt** with basic strength warning
- 🛡️ Safe scripting with `set -euo pipefail`

---

## 📦 Requirements

| Tool | Purpose |
|------|---------|
| `bash` | Shell interpreter (v4+) |
| `zip` | Archive + encryption |
| `unzip` | Verification + listing |

**Install zip (if missing):**
```bash
# Ubuntu / Debian
sudo apt install zip unzip

# macOS
brew install zip
```

---

## 🚀 Installation

```bash
# Clone or download the script
git clone https://github.com/yourusername/zip-archiver.git
cd zip-archiver

# Give execute permission
chmod +x zip_archiver.sh
```

---

## 📖 Usage

```bash
./zip_archiver.sh <folder_or_file> [output_name]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `folder_or_file` | ✅ Yes | Path to the folder or file to archive |
| `output_name` | ❌ No | Custom name for the zip (no extension needed) |

---

## 💡 Examples

```bash
# Archive a folder (auto-named with timestamp)
./zip_archiver.sh ./documents

# Archive a single file
./zip_archiver.sh ./passwords.txt

# Archive with a custom output name
./zip_archiver.sh ./projects my_projects_backup

# Show help
./zip_archiver.sh --help
```

**Sample run:**
```
==============================
  Password-Protected Archiver
==============================

Set archive password:
  Enter password     : ********
  Confirm password   : ********

[INFO]  Source      : ./documents
[INFO]  Output      : ./archives/documents_20250115_143022.zip
[INFO]  Encryption  : AES-256

[OK]    Archive created successfully!
  File : ./archives/documents_20250115_143022.zip
  Size : 4.2M

Done! Keep your password safe — there is no recovery.
```

---

## 📂 Output Structure

```
your-project/
├── zip_archiver.sh
├── archiver.log          ← auto-created activity log
└── archives/             ← auto-created output folder
    ├── documents_20250115_143022.zip
    └── secret_20250116_090011.zip
```

---

## 🔒 Security Notes

> ⚠️ **There is no password recovery.** If you forget the password, the archive cannot be opened.

- Passwords are never stored or logged anywhere
- Archive is verified after creation — corrupt archives are deleted immediately
- Use a **strong password** (12+ characters, mixed case, symbols)
- Store your password in a password manager like Bitwarden or KeePass
- The `-P` flag passes the password at runtime — avoid running in shared environments where `ps aux` could expose it; for higher security, consider prompting via `read` only (already done here)

---

## 🧠 Concepts Used

From **Module 10 — Bash File Operations:**

| Concept | Used For |
|---------|---------|
| `[[ -e ]]` file test | Validate source exists |
| `mkdir -p` | Create output dir safely |
| `mktemp` pattern (safe write) | Atomic operations |
| `set -euo pipefail` | Safe scripting |
| `du -sh` | Show archive size |
| `zip -T` | Archive verification |
| `>> logfile` | Append activity log |
| `read -rsp` | Silent password prompt |
| `trap` (pattern) | Error-safe flow |

