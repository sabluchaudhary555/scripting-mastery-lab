# 🛒 Shopping Bill Maker — Zsh Mini Project

> **Module 2 Mini Project** | `scripting-mastery-lab`  
> A terminal-based shopping bill generator written in pure Zsh — no external tools, no frameworks.

---

## 📸 Demo

```
🛍️  Welcome to Shopping Bill Maker

📦 Available Items & Price (per unit in ₹)
-------------------------------------------
  apple      ₹40
  bread      ₹35
  butter     ₹110
  eggs       ₹90
  milk       ₹60
  rice       ₹80
-------------------------------------------

[1] Add item  [2] Generate Bill  [3] Exit
Choice: 1
  Item name  : milk
  Quantity   : 2
  ✅ Added: 2 × milk @ ₹60

Choice: 2

╔══════════════════════════════════════╗
║       🛒  SHOPPING BILL MAKER        ║
╠══════════════════════════════════════╣
║  18 May 2026  14:35       BILL-4821 ║
╠══════════════════════════════════════╣
║  Item         Qty     Rate   Amount ║
║--------------------------------------║
║  milk           2      ₹60    ₹120  ║
║  bread          3      ₹35    ₹105  ║
║--------------------------------------║
║  Subtotal                     ₹225  ║
║  GST (5%)                      ₹11  ║
║--------------------------------------║
║  GRAND TOTAL                  ₹236  ║
╚══════════════════════════════════════╝
       Thank you for shopping! 🙏
```

---

## 🎯 What This Project Covers (Module 2 Topics)

| Topic | Used Where |
|-------|-----------|
| `typeset -A` Associative Array | Product catalog — item → price |
| `typeset -a` Indexed Array | Cart items and quantities |
| `typeset -i` Integer variable | qty, rate, total, tax, grand total |
| `read` with `-p` prompt | User input for item name & quantity |
| `$$(PID)` special variable | Unique bill number generation |
| Command substitution `$()` | `date` for timestamp |
| Arithmetic expansion `$(( ))` | Amount, GST, grand total |
| `${(L)var}` parameter flag | Auto-lowercase item name |
| `${(ko)assoc}` expansion | Sorted catalog display |
| `-v` key existence check | Validate item before adding |
| `$#array` | Check if cart is empty |
| `case` + `while` loop | Menu navigation |

---

## 📁 Project Structure

```
shopping-bill-maker/
└── shopping_bill.zsh     # main script (single file)
```

---

## 🚀 How to Run

### 1. Clone / Download
```zsh
git clone https://github.com/sabluchaudhary555/scripting-mastery-lab.git
cd scripting-mastery-lab/module-02/shopping-bill-maker
```

### 2. Give Execute Permission
```zsh
chmod +x shopping_bill.zsh
```

### 3. Run
```zsh
./shopping_bill.zsh
# or
zsh shopping_bill.zsh
```

### Requirements
- Zsh 5.x (`zsh --version`)
- Works on: **Ubuntu**, **Kali Linux**, **macOS**, **Fedora**
- No external dependencies

---

## 🧠 Key Concepts Explained

### Associative Array as a Database
```zsh
typeset -A price=(apple 40  milk 60  bread 35)
print $price[milk]     # → 60
```
Used to store the entire product catalog — acts like a lightweight in-memory key-value database.

### `$$` for Unique Bill Number
```zsh
local bill_no="BILL-$$"    # $$ = PID of current shell
```
Every script run gets a different PID → unique bill number automatically.

### GST Calculation with Integer Arithmetic
```zsh
typeset -i tax=$(( total * 5 / 100 ))
typeset -i grand=$(( total + tax ))
```
Pure shell arithmetic — no `bc`, no Python, no external tools.

### Input Validation via `-v` (key exists check)
```zsh
[[ -v price[$item] ]] && add_to_cart || print "Not in catalog"
```

---

## 🔧 Customization Ideas

- Add more items to the `price` associative array
- Change GST rate by modifying the `5` in `$(( total * 5 / 100 ))`
- Add a `save_bill()` function to write output to a `.txt` file
- Add a `remove_item()` function using `unset "cart_items[n]"`

---

