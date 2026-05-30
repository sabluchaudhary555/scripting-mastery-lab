# ✅ Mini Task Manager (To-Do CLI)
> A fully functional command-line To-Do app written in Bash — add, list, complete, delete, and search tasks, all stored in a `.txt` file.  

---

## 📸 Preview

```
╔══════════════════════════════════════╗
║       ✅ Mini Task Manager           ║
║     Bash Module 6 — Functions        ║
╚══════════════════════════════════════╝

📋 Menu:
  [1] Add Task
  [2] List Tasks
  [3] Complete Task
  [4] Delete Task
  [5] Clear All Tasks
  [6] Search Task
  [0] Exit

Enter choice [0-6]: 2

📋 Your Tasks:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ID   TASK                      STATUS     ADDED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  #1   Learn Bash Functions       ✅ DONE    2025-01-10 09:00
  #2   Build Task Manager         ⏳ PENDING 2025-01-10 10:30
  #3   Push to GitHub             ⏳ PENDING 2025-01-10 11:00
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Total: 3 task(s) | Done: 1 | Pending: 2
```

---

## ⚙️ Installation

**Step 1 — Clone the repo**
```bash
git clone https://github.com/sabluchaudhary555/scripting-mastery-lab.git
cd scripting-mastery-lab/module6
```

**Step 2 — Give execute permission**
```bash
chmod +x task_manager.sh
```

**Step 3 — Run**
```bash
./task_manager.sh
```

**Or create directly in Linux (WSL/Kali):**
```bash
cat > task_manager.sh << 'EOF'
# paste script content here
EOF
chmod +x task_manager.sh
./task_manager.sh
```

---

## 🚀 Usage

```bash
./task_manager.sh
```

Script launches an **interactive menu** — no arguments needed.

| Option | Action |
|--------|--------|
| `1` | Add a new task |
| `2` | List all tasks with status |
| `3` | Mark a task as DONE |
| `4` | Delete a task by ID |
| `5` | Clear all tasks (with confirmation) |
| `6` | Search tasks by keyword |
| `0` | Exit |

**Tasks are saved in `tasks.txt`** in the same directory — persists between runs.

**Data format inside `tasks.txt`:**
```
1|Learn Bash Functions|DONE|2025-01-10 09:00
2|Build Task Manager|PENDING|2025-01-10 10:30
```

---

## 🛠️ Requirements

| Requirement | Details |
|-------------|---------|
| OS | Linux / macOS / WSL |
| Shell | Bash `v4.0+` |
| Dependencies | `awk`, `sed`, `grep`, `date` (all built-in) |
| Storage | Creates `tasks.txt` in current directory |

---

## 🧠 Concepts Covered (Module 6)

| Concept | Used In |
|---------|---------|
| Defining functions | `add_task()`, `list_tasks()`, `delete_task()` etc. |
| Parameters `$1` | Task ID and input passed to each function |
| `return 0` / `return 1` | Success/failure signals in all functions |
| `local` variables | `local id`, `local task`, `local timestamp` |
| `echo` + `$()` | `get_next_id()` returns value via command substitution |
| `main()` function | Entry point — calls all other functions |
| `while` loop in function | `list_tasks()` loops file with `while IFS= read` |
| `case` inside `main()` | Menu navigation |

---

## 📁 File Structure

```
module6/
├── task_manager.sh    # Main script
├── tasks.txt          # Auto-created — stores your tasks
└── README.md          # This file
```

---

## ⚠️ Notes

- `tasks.txt` is created automatically on first run
- Deleting `tasks.txt` resets all tasks
- Task IDs are **sequential** — deleted IDs are not reused
- Search is **case-insensitive**
- Clear All asks for **confirmation** before wiping data

---
