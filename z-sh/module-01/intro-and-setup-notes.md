# Zsh — Module 01: Introduction & Setup (Short Notes)

---

## 1. What is Zsh?
- **Z Shell** — extended Unix shell + scripting language
- Built on `sh` family; **backward-compatible with Bash**
- Zsh = Bash + better autocompletion + globbing + theming
- Config file: `~/.zshrc` | Prompt uses `%` (Bash uses `$`)

```sh
echo $SHELL        # check current shell
zsh --version      # check version
```

---

## 2. Quick History
| Key Fact | Detail |
|---|---|
| Created by | Paul Falstad, 1990 |
| Named after | Prof. Zhong Shao (login: zsh) |
| macOS default | Since Catalina (2019) |
| Kali Linux | Default in recent versions |

---

## 3. Zsh vs Bash — Key Differences

| Feature | Zsh | Bash |
|---|---|---|
| Tab completion | Advanced (menu) | Basic |
| Spell correction | `setopt CORRECT` | ❌ |
| Array indexing | **1-indexed** | 0-indexed |
| Float arithmetic | Native | Needs `bc` |
| Extended globbing | Rich patterns | Basic |
| Right-side prompt | `RPROMPT` | ❌ |
| Plugin ecosystem | Oh-My-Zsh, Prezto | Limited |

---

## 4. Important Differences (Code)

```zsh
# Shebang
#!/usr/bin/env zsh

# Arrays — 1-indexed
arr=("a" "b" "c")
echo $arr[1]        # a

# Float math
zmodload zsh/mathfunc
echo $(( 10.0 / 3 ))  # 3.333...

# Extended globbing
setopt EXTENDED_GLOB
ls **/*(.)   # all regular files (recursive)
ls **/*(/)   # all directories (recursive)

# Parameter flags
echo ${(U)name}   # UPPERCASE
echo ${(L)name}   # lowercase
echo ${(C)name}   # Capitalize

# Zsh-only options
setopt AUTO_CD CORRECT EXTENDED_GLOB HIST_IGNORE_DUPS
```

---

## 5. Setup & Install

```sh
# Ubuntu/Debian
sudo apt update && sudo apt install zsh -y

# Arch
sudo pacman -S zsh

# Fedora
sudo dnf install zsh -y

# Verify
zsh --version
which zsh
cat /etc/shells
```

---

## 6. Set as Default Shell

```sh
chsh -s $(which zsh)   # then log out & log back in
echo $SHELL            # verify → /usr/bin/zsh
```

---

## 7. First Script

```zsh
#!/usr/bin/env zsh
echo "Hello from Zsh!"
echo "Version: $ZSH_VERSION"
```

```sh
chmod +x hello.zsh && ./hello.zsh
```

---

## Cheat Sheet

| Command | Purpose |
|---|---|
| `echo $SHELL` | Current shell |
| `zsh --version` | Zsh version |
| `which zsh` | Zsh path |
| `cat /etc/shells` | All installed shells |
| `chsh -s $(which zsh)` | Set Zsh as default |
| `zsh` | Launch Zsh temporarily |
| `setopt CORRECT` | Enable spell correction |
| `setopt AUTO_CD` | cd by typing dirname |
| `zmodload zsh/mathfunc` | Enable float math |