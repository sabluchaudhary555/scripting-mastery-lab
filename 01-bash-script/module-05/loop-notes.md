# 🔁 Module 5: Loops in Bash
> Bash Scripting Series | `scripting-mastery-lab`

---

## 1. `for` Loop

### 1.1 List Style
```bash
for fruit in apple banana mango; do
    echo "Fruit: $fruit"
done
```

### 1.2 C-Style
```bash
for (( i=1; i<=5; i++ )); do
    echo "Count: $i"
done
```

### 1.3 Brace Expansion
```bash
for i in {1..5}; do
    echo "Number: $i"
done

# With step
for i in {0..10..2}; do   # 0 2 4 6 8 10
    echo $i
done
```

### 1.4 Using `seq`
```bash
for i in $(seq 1 5); do
    echo "seq: $i"
done

# seq with step: seq start step end
for i in $(seq 1 2 10); do   # 1 3 5 7 9
    echo $i
done
```

| Method | Use When |
|--------|----------|
| List style | Fixed known values |
| C-style | Counter with complex logic |
| Brace expansion | Simple number/char ranges |
| `seq` | Dynamic ranges or decimal steps |

---

## 2. `while` Loop

> Runs **as long as** condition is **true**

```bash
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    (( count++ ))
done
```

**Read file line by line:**
```bash
while IFS= read -r line; do
    echo "$line"
done < file.txt
```

---

## 3. `until` Loop

> Runs **until** condition **becomes true** (opposite of while)

```bash
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    (( count++ ))
done
```

| Loop | Runs when condition is... |
|------|--------------------------|
| `while` | TRUE |
| `until` | FALSE |

---

## 4. Loop Control: `break` & `continue`

```bash
# break — exit loop immediately
for i in {1..10}; do
    [ $i -eq 6 ] && break
    echo $i          # prints 1 to 5 only
done

# continue — skip current iteration
for i in {1..5}; do
    [ $i -eq 3 ] && continue
    echo $i          # prints 1 2 4 5 (skips 3)
done
```

| Command | Action |
|---------|--------|
| `break` | Exit the loop entirely |
| `continue` | Skip to next iteration |
| `break 2` | Exit 2 levels of nested loop |

---

## 5. Nested Loops

```bash
for i in 1 2 3; do
    for j in A B C; do
        echo "$i$j"
    done
done
# Output: 1A 1B 1C 2A 2B 2C 3A 3B 3C
```

> ⚠️ Use `break 2` to exit both loops at once from inside inner loop.

---

## 6. Looping Over Files & Directories

```bash
# Loop over files in current directory
for file in *.txt; do
    echo "File: $file"
done

# Loop over all files recursively
for file in /home/user/**; do
    echo "$file"
done

# Loop over directories only
for dir in */; do
    echo "Dir: $dir"
done
```

---

## 7. Looping Over Arrays

```bash
fruits=("apple" "banana" "mango")

# Loop by value
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# Loop by index
for i in "${!fruits[@]}"; do
    echo "[$i] ${fruits[$i]}"
done
```

---

## 8. Looping Over Command Output

```bash
# Loop over ls output
for item in $(ls /etc); do
    echo "$item"
done

# Loop over running processes
for pid in $(pgrep bash); do
    echo "Bash PID: $pid"
done

# Safer: pipe into while
ls /etc | while read -r item; do
    echo "$item"
done
```

> ✅ **Prefer `while read`** over `for $(command)` — handles spaces in filenames safely.

---

## ⚡ Cheat Sheet

```bash
# for — list
for x in a b c; do ... done

# for — C-style
for (( i=0; i<5; i++ )); do ... done

# for — range
for i in {1..10}; do ... done

# while
while [ condition ]; do ... done

# until
until [ condition ]; do ... done

# break / continue
break       # exit loop
continue    # skip iteration
break 2     # exit 2 nested loops

# loop over files
for f in *.sh; do ... done

# loop over array
for item in "${arr[@]}"; do ... done

# loop over command output
command | while read -r line; do ... done
```

---
