# 📂 Filename Parser — Bash Mini Project


> Part of the **Bash Scripting Mini Projects Series** — String Variables
> Covers: `${##*/}`, `${%/*}`, `${##*.}`, `${%.*}` — prefix/suffix removal operators

---

## 📌 What It Does

Takes any filepath as input and extracts all useful parts — filename, directory, basename, and extension — using only pure Bash string operations. No external commands like `basename` or `dirname` are used.

---

## 🧠 Bash Concepts Covered

| Syntax | Operation | Description |
|---|---|---|
| `${var##*/}` | Remove longest prefix | Strips everything up to last `/` — gives filename |
| `${var%/*}` | Remove shortest suffix | Strips from last `/` onward — gives directory |
| `${var##*.}` | Remove longest prefix | Strips everything up to last `.` — gives extension |
| `${var%.*}` | Remove shortest suffix | Strips from last `.` onward — gives basename |

---

## 📁 Project Structure

```
bash-script/
└── module-02/
    ├── filename_parser.sh     # Main script
    └── README.md              # This file
```

---

## ⚙️ Requirements

- Bash `v3.0+`
- No external dependencies — pure Bash only

---

## 🚀 Installation & Usage

**Run this full block in your Kali / Linux terminal:**

```bash
cat > filename_parser.sh << 'EOF'
#!/bin/bash

read -p "Enter filepath: " filepath

filename="${filepath##*/}"
directory="${filepath%/*}"
extension="${filename##*.}"
basename="${filename%.*}"

echo ""
echo "======================================"
echo "        FILENAME PARSER"
echo "======================================"
echo "  Input     : $filepath"
echo "  Filename  : $filename"
echo "  Directory : $directory"
echo "  Basename  : $basename"
echo "  Extension : $extension"
echo "======================================"
EOF
chmod +x filename_parser.sh
bash filename_parser.sh
```

**Enter any filepath when prompted:**
```
Enter filepath: /home/hacker/scripts/deploy.sh
```

---

## 📤 Sample Output

```
Enter filepath: /home/hacker/scripts/deploy.sh

======================================
        FILENAME PARSER
======================================
  Input     : /home/hacker/scripts/deploy.sh
  Filename  : deploy.sh
  Directory : /home/hacker/scripts
  Basename  : deploy
  Extension : sh
======================================
```


## 💡 Key Notes

- `##` removes the **longest** matching prefix
- `#` removes the **shortest** matching prefix
- `%%` removes the **longest** matching suffix
- `%` removes the **shortest** matching suffix
- `*` is a wildcard — `##*/` means everything up to and including the last `/`
- No `basename` or `dirname` commands used — pure Bash parameter expansion only




---

## 🗺️ Series Roadmap

| # | Project | Topics |
|---|---|---|
| 01 | System Info Reporter | command substitution, env vars |
| 02 | User Profile Card | `read`, variables, `${}` |
| 03 | Silent Password Vault | `read -sp`, `${#}`, validation |
| **04** | **Filename Parser** ← you are here | `##` `%%` `%` string trimming |
| 05 | String Inspector | `${#}`, `^^`, `,,`, `rev` |
| 06 | Basic Calculator | `$(( ))`, `let`, arithmetic |

---

<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)

---
**Made with ❤️ for the Open Source Community**