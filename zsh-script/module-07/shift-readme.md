# zsh-sift

A small zsh script for searching file contents with regex filters. Built as a
learning project for Module 7 (Regular Expressions & Globbing). Nothing you
couldn't do with raw grep, but it wraps everything into one convenient command
and shows off a few zsh-specific features along the way.

---

## What it does

- Recursively searches files using `**/*` extended globbing
- Filters by file extension, excludes glob patterns
- Supports plain text search or raw regex (`-r`)
- Case-insensitive mode, inverted match, line numbers
- Highlights matches in the output
- Shows a summary at the end

---

## Requirements

- zsh 5.0 or newer
- `grep` with `-E` support (standard on Linux/macOS)
- `file` command (for binary detection)

---

## Setup

```zsh
git clone https://github.com/yourname/zsh-sift
cd zsh-sift
chmod +x sift.zsh
```

Optionally symlink it somewhere on your PATH:

```zsh
ln -s $PWD/sift.zsh ~/.local/bin/sift
```

---

## Usage

```
sift.zsh [options] <pattern> [directory]
```

| Option      | What it does                                      |
|-------------|---------------------------------------------------|
| `-e <ext>`  | Only search files with this extension             |
| `-i`        | Case-insensitive matching                         |
| `-l`        | List filenames only, skip showing content         |
| `-n`        | Show line numbers                                 |
| `-v`        | Invert match (show lines that *don't* match)      |
| `-r <regex>`| Use a raw ERE regex instead of a literal pattern  |
| `-x <glob>` | Exclude files matching this glob                  |
| `-h`        | Show help                                         |

---

## Examples

**Find all TODOs in a project:**
```zsh
./sift.zsh 'TODO' ./src
```

**Search only `.zsh` files, show line numbers:**
```zsh
./sift.zsh -e zsh -n 'setopt' .
```

**Find IP addresses using a raw regex:**
```zsh
./sift.zsh -r '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /etc
```

**Case-insensitive search, list files only:**
```zsh
./sift.zsh -i -l 'error' ./logs
```

**Search everything except `.log` files:**
```zsh
./sift.zsh -x '*.log' 'warning' .
```

**Lines that do NOT contain a pattern:**
```zsh
./sift.zsh -v 'DEBUG' ./logs
```

---

## What's being practiced (Module 7)

| Concept | Where it shows up |
|---|---|
| `**/*` recursive glob | `collect_files()` — finds all files under a directory |
| `*(.)` glob qualifier | Same — filters to regular files only |
| `$~EXCLUDE_GLOB` | Expands a variable as a glob pattern for exclusion |
| `setopt extended_glob null_glob` | Top of script — enables `**` and prevents errors on empty globs |
| `grep -E` (ERE) | Core search engine for all patterns |
| Capturing groups + `sed` | Highlights matched text in output via back-reference `\1` |
| `[[ =~ ]]` | Not used directly here, but `-r` flag feeds patterns into the same ERE engine |
| POSIX `[:alpha:]` etc. | Can be used freely with `-r` flag |
| `^` `$` anchors | Work normally when passed via `-r` |

---

## Project structure

```
zsh-sift/
├── sift.zsh       # the main script
└── README.md      # this file
```

Kept deliberately simple — one file, no dependencies, easy to read through
in one sitting.

---
