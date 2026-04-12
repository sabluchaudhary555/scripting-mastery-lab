# 🧮 smart-calculator.sh

> **Module 3 Mini Project** — Operators & Expressions  
> **Bash Scripting Learning Path** | `scripting-mastery-lab`

A menu-driven command-line calculator built entirely in Bash.  
Covers every operator type from Module 3 — arithmetic, modulo, power, float division, square root, and a persistent running total with `++` / `--`.

---


### 1. Make executable
```bash
chmod +x smart-calculator.sh
```

### 2. Run
```bash
./smart-calculator.sh
```

---

## 📋 Menu Options

```
── Basic ───────────────────────────
 1) Addition          ( + )
 2) Subtraction       ( - )
 3) Multiplication    ( * )
 4) Division          ( / )  [integer]
 5) Modulo            ( % )

── Advanced ────────────────────────
 6) Power / Exponent  ( ** )
 7) Float Division    ( bc  )
 8) Square Root       ( bc  )

── Running Total ───────────────────
 9) Increment total   ( ++ )
10) Decrement total   ( -- )
11) Add result to total
12) Reset total to 0

── Other ───────────────────────────
 0) Exit
```

---

## 🖥️ Sample Output

### Banner on Launch
```
  ╔══════════════════════════════════════╗
  ║        🧮  Smart Calculator           ║
  ║   Bash Module 3 — Mini Project        ║
  ╚══════════════════════════════════════╝

  Running Total : 0
  Operations    : 0
```

### Option 1 — Addition
```
  Choose an option [0-12] : 1

  Enter first number  : 25
  Enter second number : 17

  ✔ 25 + 17 = 42

  Running Total : 0
  Operations    : 1
```

### Option 6 — Power
```
  Choose an option [0-12] : 6

  Enter first number  : 2
  Enter second number : 10

  ✔ 2 ** 10 = 1024

  Running Total : 0
  Operations    : 2
```

### Option 7 — Float Division (bc)
```
  Choose an option [0-12] : 7

  Enter first number  : 22
  Enter second number : 7

  ✔ 22 / 7 = 3.1428

  Running Total : 0
  Operations    : 3
```

### Option 8 — Square Root (bc -l)
```
  Choose an option [0-12] : 8

  Enter a number : 144

  ✔ sqrt(144) = 12.0000

  Running Total : 0
  Operations    : 4
```

### Option 5 — Modulo (via let)
```
  Choose an option [0-12] : 5

  Enter first number  : 17
  Enter second number : 5

  ✔ 17 % 5 = 2

  Running Total : 0
  Operations    : 5
```

### Option 9 — Increment ( ++ )
```
  Choose an option [0-12] : 9

  ✔ Total incremented → 1

  Running Total : 1
  Operations    : 6
```

### Option 10 — Decrement ( -- )
```
  Choose an option [0-12] : 10

  ✔ Total decremented → 0

  Running Total : 0
  Operations    : 7
```

### Option 11 — Add Last Result to Total
```
  Choose an option [0-12] : 11

  ✔ Added 1024 to total → 1024

  Running Total : 1024
  Operations    : 8
```

### Option 4 — Integer Division with Remainder
```
  Choose an option [0-12] : 4

  Enter first number  : 29
  Enter second number : 4

  ✔ 29 / 4 = 7
  (remainder: 1)

  Running Total : 1024
  Operations    : 9
```

### Input Validation Error
```
  Choose an option [0-12] : 1

  Enter first number  : abc
  Enter second number : 5

  ✗ Please enter valid integers.
```

### Division by Zero Guard
```
  Choose an option [0-12] : 4

  Enter first number  : 10
  Enter second number : 0

  ✗ Division by zero is not allowed.
```

### Option 0 — Exit
```
  Choose an option [0-12] : 0

  Goodbye! Total operations performed: 9
```

---

## ⚙️ How It Works

```
User launches script
        │
        ▼
show_banner()  →  display title
        │
        ▼
while true loop
        │
        ├── show_total()   →  print running total + op count
        ├── show_menu()    →  print all 13 options
        ├── read choice    →  get user input
        │
        └── case "$choice"
              ├── 1-5   →  (( )) and let  for integer ops
              ├── 6     →  (( num1 ** num2 ))  exponent
              ├── 7     →  echo "scale=4; n/d" | bc
              ├── 8     →  echo "sqrt(n)" | bc -l
              ├── 9     →  (( total++ ))
              ├── 10    →  (( total-- ))
              ├── 11    →  expr to add last_result to total
              ├── 12    →  total=0  reset
              └── 0     →  exit
```

---

## 🛡️ Error Handling

| Scenario | Handled By |
|---|---|
| Non-integer input | `[[ =~ ^-?[0-9]+$ ]]` regex check |
| Division by zero | `if (( num2 == 0 ))` guard |
| Modulo by zero | `if (( num2 == 0 ))` guard |
| Negative exponent | `if (( num2 < 0 ))` guard |
| No last result for total | `if [[ -z "$last_result" ]]` check |
| Invalid menu choice | `*` case fallback with error message |

---

## 📦 Requirements

| Tool | Purpose |
|---|---|
| `bash` 4.0+ | Script interpreter |
| `bc` | Float division and square root |
| `expr` | Running total addition |

Check if `bc` is installed:
```bash
which bc || sudo apt install bc
```

---


**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)

---
**Made with ❤️ for the Open Source Community**