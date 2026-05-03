# ⌨️ Bash Tab Completion for Your CLI Tool

A fully working **developer CLI tool** (`devtool`) paired with a production-grade **Bash tab completion script** — covering every completion technique: sub-commands, flags, dynamic file lists, context-aware suggestions, and nested option completions.

---

## 📌 Module 14 Concepts Used

| Concept | Where Used |
|---------|-----------|
| `COMP_WORDS` | Array of all words typed so far |
| `COMP_CWORD` | Index of current word being completed |
| `COMPREPLY` | Array filled with completion suggestions |
| `compgen -W` | Generate completions from a word list |
| `compgen -f` | Generate completions from filenames |
| `complete -F` | Register function as completer for a command |
| Associative arrays | Per-command option lists stored as variables |
| `${COMP_WORDS[COMP_CWORD-1]}` | Read previous word (for `--flag value`) |
| `case` + `COMP_CWORD` | Context-aware depth-based completions |
| Subshells `$( )` | Dynamic file/service list generation |
| `.bashrc` / `source` | How to install completions persistently |

---

## 📁 Project Structure

```
devtool-completion/
├── devtool.sh                # the CLI tool itself
├── devtool_completion.sh     # tab completion script
└── README.md                 # this file
```

---

## 🚀 Getting Started

### 1. Make executable
```bash
chmod +x devtool.sh devtool_completion.sh
```

### 2. Load completion (current session)
```bash
source ./devtool_completion.sh
```

### 3. Try it!
```bash
./devtool.sh <TAB><TAB>
# deploy  logs  db  config  status  version  --help

./devtool.sh deploy <TAB><TAB>
# dev  staging  prod

./devtool.sh deploy dev <TAB><TAB>
# api  worker  scheduler  nginx  postgres  --force  --dry-run  --tag

./devtool.sh logs <TAB><TAB>
# api  worker  scheduler  (dynamic — reads real log files!)

./devtool.sh config show <TAB><TAB>
# app.conf  nginx.conf  postgres.conf  (real config files!)

./devtool.sh deploy staging api --tag <TAB><TAB>
# latest  stable  v1.0.0  v1.1.0  v2.0.0

./devtool.sh logs api --since <TAB><TAB>
# 5m  15m  30m  1h  2h  6h  12h  24h  7d
```

---

## 🛠️ CLI Tool Commands

```bash
./devtool.sh deploy dev                          # deploy all to dev
./devtool.sh deploy staging api --tag v1.2.3    # deploy api to staging
./devtool.sh deploy prod --dry-run              # preview prod deploy
./devtool.sh logs api --follow                  # tail api logs
./devtool.sh logs worker --lines 100 --grep ERROR
./devtool.sh db backup --env prod
./devtool.sh db restore --file backup.sql
./devtool.sh db migrate --env staging
./devtool.sh config list
./devtool.sh config show app.conf
./devtool.sh status
```

---

## ⌨️ How Completion Works

```
User presses TAB after: devtool deploy dev --
         │
         ▼
bash calls _devtool_complete()
         │
         ├── COMP_WORDS = ["devtool", "deploy", "dev", "--"]
         ├── COMP_CWORD = 3  (cursor on 4th word)
         ├── cur  = "--"
         ├── prev = "dev"
         │
         └── cmd="deploy", CWORD=3
               → show services + flags
         │
         ▼
COMPREPLY = ["--force", "--rollback", "--dry-run", "--tag", "--help"]
```

---

## 📊 Completion Coverage

| Command | Depth 2 | Depth 3 | Flag Values |
|---------|---------|---------|-------------|
| `deploy` | envs | services + flags | `--tag` → versions |
| `logs` | services (dynamic) | flags | `--lines`, `--since`, `--grep` |
| `db` | operations | flags per op | `--env`, `--file` |
| `config` | operations | files (dynamic) | `--env` |

---

## 🔬 Key Techniques

```bash
# 1. Word list completion
COMPREPLY=( $(compgen -W "dev staging prod" -- "$cur") )

# 2. Dynamic from real files
files=$(ls /tmp/devtool_configs/*.conf | xargs -I{} basename {})
COMPREPLY=( $(compgen -W "$files" -- "$cur") )

# 3. Flag-value completion using $prev
case "$prev" in
    --env)   COMPREPLY=( $(compgen -W "dev staging prod" -- "$cur") ) ;;
    --since) COMPREPLY=( $(compgen -W "1h 6h 24h 7d" -- "$cur") ) ;;
esac

# 4. Depth-aware by COMP_CWORD
if [[ $COMP_CWORD -eq 2 ]]; then
    # show environments
elif [[ $COMP_CWORD -eq 3 ]]; then
    # show services
else
    # show flags
fi

# 5. Register the function
complete -F _devtool_complete devtool
```

---

## 💾 Install Permanently

```bash
# Option 1 — source in .bashrc
echo "source /path/to/devtool_completion.sh" >> ~/.bashrc
source ~/.bashrc

# Option 2 — system-wide
sudo cp devtool_completion.sh /etc/bash_completion.d/devtool

# Option 3 — user-local
mkdir -p ~/.local/share/bash-completion/completions
cp devtool_completion.sh ~/.local/share/bash-completion/completions/devtool
```

---

## 📋 Requirements

- Bash 4.0+
- `bash-completion` (optional): `sudo apt install bash-completion`

---

## 🧠 Learning Outcomes

- How `COMP_WORDS`, `COMP_CWORD`, and `COMPREPLY` work together
- How `compgen -W` filters suggestions against what the user typed
- How to make completions **context-aware** using `$prev` and depth
- How to make completions **dynamic** (reading real files/services)
- How to register with `complete -F` and install permanently

---

