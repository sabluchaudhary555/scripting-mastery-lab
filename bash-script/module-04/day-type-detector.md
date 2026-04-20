# 📅 Day Type Detector
> A colorful Bash script that detects whether a day is a Weekday or Weekend — with motivational quotes and daily plans.  
> 📁 Part of [`scripting-mastery-lab`](https://github.com/sabluchaudhary555) | Module 4 — Conditional Statements

---

## 📸 Preview

```
╔══════════════════════════════════╗
║       📅 Day Type Detector       ║
║     Bash Module 4 — case/esac    ║
╚══════════════════════════════════╝

Enter a day name: Friday

📌 Day     : Friday
🔴 Type    : Weekday (but feels like weekend 😄)
💬 Quote   : 'TGIF — Thank God It's Friday!'

📊 Additional Info:
   🏢  Office  : Open
   ⚡  Status  : High Energy Day
   📅  Plan    : Meetings & Planning

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Script complete | Module 4 — case/esac
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## ⚙️ Installation

**Step 1 — Clone the repo**
```bash
git clone https://github.com/sabluchaudhary555/scripting-mastery-lab.git
cd scripting-mastery-lab/module4
```

**Step 2 — Give execute permission**
```bash
chmod +x day_type_detector.sh
```

**Step 3 — Run**
```bash
./day_type_detector.sh
```

> 💡 If you don't want to clone, create it directly in Linux:
> ```bash
> cat > day_type_detector.sh << 'EOF'
> # paste script content here
> EOF
> chmod +x day_type_detector.sh
> ./day_type_detector.sh
> ```

---

## 🚀 Usage

```bash
./day_type_detector.sh
# Enter a day name when prompted: Monday / tuesday / FRIDAY (any case works)
```

**Input is case-insensitive** — `MONDAY`, `Monday`, `monday` all work.

| Input | Output |
|-------|--------|
| `Monday` – `Friday` | 🔴 Weekday + motivational quote |
| `Saturday`, `Sunday` | 🟢 Weekend + rest day info |
| Any invalid input | ❌ Error message + exit |

---

## 🧠 Concepts Covered (Module 4)

| Concept | Used In |
|---------|---------|
| `case...esac` | Core day detection logic |
| `if / elif / else` | Extra info section |
| `[[ ]]` with `\|\|` | Weekend/weekday condition check |
| `*` default case | Invalid input handling |
| `tr` for normalization | Case-insensitive input |
| `exit 1` | Error exit on bad input |

---

## 📁 File Structure

```
module4/
├── day_type_detector.sh   # Main script
└── README.md              # This file
```

---

## 🛠️ Requirements

- Bash `v4.0+`
- Linux / macOS / WSL (Windows)
- No external dependencies

---

## 👨‍💻 Author

<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)

---
**Made with ❤️ for the Open Source Community**