# filewatch 🔍

> Audit a directory in one pass — broken symlinks, wrong permissions,
> duplicate filenames, old files, junk leftovers. All in one report.

**Module 10 · Real-life Project** &nbsp;|&nbsp; `find` · `stat` · `chmod` · `symlinks` · `mktemp` · `du` · `extended glob` · `zmv`

---

## At a Glance

| Check | What it catches |
|---|---|
| `--perms` | World-writable files, unreadable files, unexpected executables |
| `--size` | Files larger than N MB (default 50) |
| `--old` | Files not modified in N days (default 90) |
| `--dupes` | Same filename appearing in multiple locations |
| `--symlinks` | Symlinks pointing to missing targets |
| `--tmp` | Leftover `.tmp` `.bak` `.swp` `~` `.DS_Store` files |
| `--all` | All of the above in one run |

---

## Install

```zsh
chmod +x filewatch.zsh

# optional — add to PATH
ln -s $PWD/filewatch.zsh ~/.local/bin/filewatch
```

---

## Usage

```
filewatch.zsh [checks] [options] <directory>
```

### Options

| Flag | Default | Description |
|---|---|---|
| `--all` | — | Run every check |
| `--perms` | off | Permission audit |
| `--size <MB>` | `50` | Flag files larger than N MB |
| `--old <days>` | `90` | Flag files older than N days |
| `--dupes` | off | Find duplicate filenames |
| `--symlinks` | off | Check for broken symlinks |
| `--tmp` | off | Find temp and junk files |
| `-o <file>` | — | Also write report to a file |
| `-q` | off | Quiet — issues only, no summaries |
| `-h` | — | Show help |

---

## Output

```
$ ./filewatch.zsh --all /tmp/fw-test
```

```
filewatch report
directory : /tmp/fw-test
timestamp : 2026-05-28 01:10:33
────────────────────────────────────────────

── Overview
  files      : 12
  dirs       : 6
  symlinks   : 2
  total size : 72K

── Permission Check
  ✗ world-writable: /tmp/fw-test/uploads/exposed.txt
  ▲ unexpected +x:  /tmp/fw-test/uploads/image.jpg
  ▲ unexpected +x:  /tmp/fw-test/uploads/exposed.txt

── Large Files  (> 50MB)
  ✓ no files larger than 50MB

── Old Files  (not modified in 90+ days)
  ▲ 2026-01-28  old/stale.csv
  ▲ 2025-11-09  old/ancient.log

── Duplicate Filenames
  ▲ duplicate name: data.csv
      /tmp/fw-test/scripts/data.csv
      /tmp/fw-test/uploads/data.csv

── Symlink Check
  ✗ broken symlink: scripts/broken_link.sh
      → /tmp/fw-test/missing.txt  (target missing)
  ✓ ok: scripts/alias.sh  → /tmp/fw-test/scripts/real.sh

── Temp / Junk Files
  ▲ 4.0K  cache/session.tmp
  ▲ 4.0K  cache/old_data.bak
  ▲ 4.0K  cache/.DS_Store

────────────────────────────────────────────
▲ 8 issue(s) found
```

---

## Examples

```zsh
# full audit of a project folder
./filewatch.zsh --all ./project

# check uploads dir for permission issues and broken links
./filewatch.zsh --perms --symlinks /var/www/uploads

# find large and old files in Downloads
./filewatch.zsh --size 100 --old 30 ~/Downloads

# save report to file
./filewatch.zsh --all -o audit.txt ./src

# quiet mode — issues only, no noise
./filewatch.zsh --all -q ./backups

# custom thresholds
./filewatch.zsh --size 200 --old 365 /mnt/archive
```

---

## Module 10 Concepts Used

| Concept | Where it shows up |
|---|---|
| `find -type f/l/d` | Counting files, dirs, symlinks in Overview |
| `find -perm` | Detecting world-writable and unreadable files in `--perms` |
| `find -size +NM` | Large file detection in `--size` check |
| `find -mtime +N` | Old file detection in `--old` check |
| `find -name` | Junk file patterns in `--tmp` check |
| `stat -c%s` | Getting file size in bytes for large file display |
| `readlink` | Resolving symlink targets in `--symlinks` check |
| `basename` / `dirname` | Stripping paths when displaying results |
| `${path:A}` | Zsh equivalent of `realpath` — resolves absolute path |
| `du -sh` | Directory size in Overview, individual sizes in `--size` |
| `mktemp` | Temp file for collecting basenames in `--dupes` check |
| `trap EXIT` | Cleans up mktemp file automatically on exit or Ctrl+C |
| `ln -s` | Creating test symlinks (used in the demo setup) |
| `chmod` | Setting up test cases (world-writable, +x) |
| Extended glob `*.{tmp,bak}` | Junk file pattern matching |

---

## File Structure

```
module-10/
├── notes/
│   └── module-10-notes.md    ← quick reference for all M10 concepts
└── project/
    ├── filewatch.zsh          ← main script
    └── README.md              ← this file
```

---

## Requirements

- zsh 5.0+
- `find`, `stat`, `du`, `basename`, `readlink` — standard on Linux/macOS

---

> **Tip:** Use `-o report.txt` to save the output and commit it to git.
> Running it on CI before deploys catches permission and symlink issues early.

---

## License

MIT