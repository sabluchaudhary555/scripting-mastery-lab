# Zsh Loops — Quick Notes

## Loop Types

| Loop | Use When |
|---|---|
| `for` | List or count known upfront |
| `while` | Repeat while condition is true |
| `until` | Repeat while condition is false |
| `repeat` | Run exactly N times (Zsh only) |

---

## for — List Form
```zsh
for var in item1 item2 item3; do
    commands
done

for n in 1 2 3 4 5; do print "$n squared = $(( n*n ))"; done
for i in $(seq 0 2 10); do print $i; done   # 0 2 4 6 8 10
```

---

## for — C-Style
```zsh
for (( i=1; i<=10; i++ )); do
    commands
done

# Multiple variables
for (( i=0, j=10; i<=10; i++, j-- )); do print "i=$i j=$j"; done

# Sum 1 to 100
typeset -i total=0
for (( i=1; i<=100; i++ )); do (( total += i )); done
print $total   # 5050
```

---

## for — Zsh Shorthand
```zsh
for var (list) command          # no do/done needed

for fruit (apple banana cherry) print $fruit
for i ({1..5}) print "Item $i"
for f (*.zsh) print "Script: $f"
```
Zsh only — not Bash.

---

## Brace Expansion
```zsh
for i in {1..10};     do ...    # 1 to 10
for i in {2..20..2};  do ...    # even numbers
for i in {10..1};     do ...    # countdown
for i in {01..10};    do ...    # zero-padded
for c in {a..z};      do ...    # letters
```
⚠️ Variables don't work in `{}` — use `seq` or C-style instead:
```zsh
n=5
for i in {1..$n}; do ...        # ❌ prints literal {1..5}
for i in $(seq 1 $n); do ...    # ✅ correct
```

---

## while Loop
```zsh
while condition; do
    commands
done

typeset -i count=1
while (( count <= 5 )); do
    print $count; (( count++ ))
done

# Infinite loop
while true; do
    commands
done
```

---

## until Loop
```zsh
until condition; do      # opposite of while
    commands
done

# Wait for a file to appear
until [[ -f /tmp/ready.flag ]]; do
    print -n "."; sleep 1
done
```

---

## repeat Loop (Zsh only)
```zsh
repeat N command
repeat N { commands }

repeat 5 print "Hello"
repeat 40 print -n "-"; print ""    # separator line

typeset -i n=7
repeat $n print -n "* "
```

---

## break & continue
```zsh
break        # exit loop
break N      # exit N levels of nested loops
continue     # skip to next iteration
continue 2   # skip up N levels
```
```zsh
# skip even, print odd
for i in {1..10}; do
    (( i % 2 == 0 )) && continue
    print $i
done
```

---

## Loop Over Arrays
```zsh
fruits=(apple banana cherry)

for fruit in $fruits; do print $fruit; done       # all elements
for i in {1..$#fruits}; do print "$i: $fruits[$i]"; done  # with index
for fruit ($fruits) print $fruit                  # Zsh shorthand

# Associative array
typeset -A scores=(Alice 95 Bob 78)
for key val in ${(kv)scores}; do print "$key → $val"; done
```

---

## Loop Over Files
```zsh
for f in /etc/*(.) ;  do ...   # regular files only
for d in /var/*/;     do ...   # directories only
for f in **/*.log;    do ...   # recursive

for log in *.log; do
    print "$log: $(wc -l < $log) lines"
done
```

---

## Read File Line by Line
```zsh
# Always use this — safest method
while IFS= read -r line; do
    print "$line"
done < filename.txt

# Loop over command output — use <() not pipe
while IFS= read -r line; do
    [[ $line == *ERROR* ]] && (( count++ ))
done < <(cat /var/log/syslog)
```
⚠️ Never `cat file | while read` — variables are lost after pipe (subshell).

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| `{1..$n}` with variable | Use `$(seq 1 $n)` or C-style `for` |
| `for line in $(cat file)` | Use `while IFS= read -r line` |
| `cmd \| while read` | Use `while ... done < <(cmd)` |
| Forgetting `done` | Every `do` needs a `done` |
| Not quoting `"$file"` | Filenames can have spaces |
| `(( i=0 ))` as while condition | `0` = false in `(( ))` |