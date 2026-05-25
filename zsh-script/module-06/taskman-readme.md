# taskman

A minimal task manager that lives in your terminal. No databases, no dependencies — just a plain text file and a Zsh script.

Built as a hands-on practice project for Zsh functions: parameters, local scope, return values, error handling, and the `$argv` array.

---

## What it does

```
  #1  [ ]  2025-05-24   finish the zsh functions chapter
  #2  [✓]  2025-05-24   write taskman project
  #3  [ ]  2025-05-25   push everything to github

  2 pending  •  1 done  •  3 total
```

That's basically it. Add tasks, mark them done, clean up.

---

## Setup

```zsh
# clone / download the file, then make it executable
chmod +x taskman.zsh

# optional: put it somewhere on your PATH
cp taskman.zsh ~/.local/bin/taskman
```

Tasks are stored in `~/.taskman_tasks` by default. Override with:

```zsh
export TASKMAN_FILE="$HOME/work/tasks.txt"
```

---

## Usage

```zsh
taskman add "read the zsh docs"
taskman add "write a function library"

taskman list           # show everything
taskman list todo      # pending only
taskman list done      # completed only

taskman done 1         # mark task #1 as done
taskman remove 2       # delete task #2
taskman clear          # wipe all completed tasks

taskman help
```

---

## Zsh concepts practiced

| Concept | Where it shows up |
|---|---|
| Function definitions | every command is its own function |
| Local variables | `local` / `typeset` used throughout |
| Positional params + `$@` | `add_task`, `done_task`, `remove_task` |
| Default + required params | `${1:-"all"}` and `${1:?"usage..."}` |
| `return` vs `print` | errors use `return`, values use `print` |
| `trap RETURN` cleanup | temp file cleanup in `done_task`, `remove_task` |
| Dispatcher pattern | `main()` routes commands via `case` |
| Exit status conventions | 0 success, 2 bad args, 4 not found |

---

## File format

Tasks are stored as pipe-delimited plain text — easy to read, grep, or edit by hand.

```
1|todo|2025-05-24|finish the zsh chapter
2|done|2025-05-24|write taskman project
```

---

## Notes

- IDs never get reused (always increments from the highest existing ID)
- The `clear` command doesn't re-number remaining tasks — IDs stay stable
- Works fine alongside scripts that grep the task file directly