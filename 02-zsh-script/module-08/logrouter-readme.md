# logrouter 🪵

> Split a live log stream into separate files by severity level.
> Pipe anything into it — it routes, counts, and reports.

**Module 8 · Real-life Project** &nbsp;|&nbsp; `zsh` · `stdin/stdout` · `file descriptors` · `getopts` · `pipes`

---

## What it does

You pipe your app's log output into `logrouter.zsh` and it sorts every line into a separate file based on the log level it detects. All lines still go to `app.all.log`, and you get a clean summary at the end. Works with streaming input (`tail -f`) or a static file.

```
your app stdout  ──▶  logrouter  ──▶  6 routed files
```

---

## Output Files

| File | Color | What goes in it |
|---|---|---|
| `app.all.log` | ⚫ | Every single line, always |
| `app.info.log` | 🟢 | INFO level lines only |
| `app.warn.log` | 🟡 | WARN / WARNING lines |
| `app.error.log` | 🔴 | ERROR, FATAL, CRITICAL |
| `app.debug.log` | ⚪ | DEBUG and TRACE lines |
| `app.other.log` | ◻️ | Anything without a known level |

---

## Install

```zsh
# clone or copy the file
chmod +x logrouter.zsh

# optional: put it on your PATH
ln -s $PWD/logrouter.zsh ~/.local/bin/logrouter
```

---

## Usage

```
logrouter.zsh [options]
logrouter.zsh -i <logfile> [options]
```

### Options

| Flag | Default | Description |
|---|---|---|
| `-o <dir>` | `./log-output` | Where to write output files |
| `-i <file>` | stdin | Read from a file instead of piped input |
| `-p <prefix>` | `app` | Filename prefix — e.g. `-p api` → `api.error.log` |
| `-v` | off | Verbose: print each line to terminal as it's routed |
| `-s` | off | Print summary table when done |
| `-h` | — | Show help |

---

## Output

### Startup

```
logrouter started — writing to ./logs/app.*

  all    → ./logs/app.all.log
  info   → ./logs/app.info.log
  warn   → ./logs/app.warn.log
  error  → ./logs/app.error.log
  debug  → ./logs/app.debug.log
  other  → ./logs/app.other.log
```

### Verbose mode (`-v`)

```
[INFO ] 2024-07-15 08:00:01 INFO  app started on port 8080
[DEBUG] 2024-07-15 08:01:22 DEBUG loading config from /etc/app.conf
[INFO ] 2024-07-15 08:02:10 INFO  connected to db on port 5432
[WARN ] 2024-07-15 08:03:45 WARN  memory usage at 71%
[ERROR] 2024-07-15 08:04:01 ERROR failed to write cache: permission denied
[INFO ] 2024-07-15 08:04:33 INFO  retrying cache write
[ERROR] 2024-07-15 08:05:00 ERROR disk full on /var/cache
```

### Summary (`-s`)

```
── summary ──────────────────────────────
  total    10
  info      4
  warn      2
  error     2
  debug     1
  other     1

  output: ./logs/
```

---

## Examples

```zsh
# pipe a live stream
tail -f /var/log/myapp.log | ./logrouter.zsh -o ./logs -v

# route a static file with custom prefix and summary
./logrouter.zsh -i app.log -o ./out -p myapp -s

# only route errors from the last hour
grep "$(date -d '1 hour ago' +'%H:')" app.log | ./logrouter.zsh -o ./recent

# route your app's live output directly
./myserver 2>&1 | ./logrouter.zsh -o ./logs -p server -v
```

---

## Module 8 Concepts Used

| Concept | Where it shows up |
|---|---|
| `stdin / stdout / stderr` | Reads log lines from stdin (fd 0), status to stdout, errors to `>&2` |
| `exec N>> file` | Opens a persistent fd per log level — no open/close per line |
| `>> &>` redirection | Each level appends with `>>`, summary errors use `>&2` |
| `/dev/stdin` | Fallback input source so the same read loop handles pipe and file mode |
| `getopts` | Parses `-o -i -p -v -s -h` with `$OPTARG` and `shift $((OPTIND-1))` |
| Argument validation | Checks missing args, bad files, and terminal stdin before starting |
| `trap EXIT` | Closes all file descriptors cleanly even on Ctrl+C |
| Pipes `\|` | Designed to sit in a pipeline — `tail -f app.log \| logrouter \| grep ERROR` |
| `setopt pipe_fail` | Exits if any command in a pipeline fails, not just the last |

---

## File Structure

```
module-08/
├── notes/
│   └── module-08-notes.md     ← quick reference for all M8 concepts
└── project/
    ├── logrouter.zsh           ← the main script
    └── README.md               ← this file
```

---

## Requirements

- zsh 5.0+
- No external dependencies — just standard Unix tools

---

> **Note:** Works with any log format that has a level keyword anywhere in the line —
> `INFO`, `[WARN]`, `level=error`, `FATAL`, etc.
> Lines that don't match any known level go to `app.other.log` so nothing is ever lost.

---

## License

MIT