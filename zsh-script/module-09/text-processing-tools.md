# Module 9 — Text Processing Tools

> Quick reference. One concept, one example. No fluff.

---

## grep

```zsh
grep "error" file.log          # basic match
grep -i "error" file.log       # case-insensitive
grep -v "debug" file.log       # invert — lines that don't match
grep -r "TODO" ./src           # recursive through dirs
grep -n "fail" file.log        # show line numbers
grep -c "INFO" file.log        # count matching lines
grep -E "[0-9]{3}" file.log    # extended regex (ERE)
grep -o "[0-9]+" file.log      # print only matched part
```

---

## sed

```zsh
sed 's/foo/bar/' file          # replace first match per line
sed 's/foo/bar/g' file         # replace all matches
sed '/error/d' file            # delete matching lines
sed -n '5,10p' file            # print only lines 5–10
sed -i 's/old/new/g' file      # in-place edit (modifies file)
sed -E 's/([0-9]+)/NUM/g'      # ERE with capture group
sed -n '/START/,/END/p' file   # address range between patterns
```

---

## awk

```zsh
awk '{ print $1, $3 }' file          # print fields 1 and 3
awk -F',' '{ print $2 }' file.csv    # custom delimiter
awk 'NR > 1 { print }' file          # skip header (row 1)
awk '$3 > 100 { print $1 }' file     # filter rows by value
awk '{ sum += $2 } END { print sum }' file   # sum a column
awk '/ERROR/ { count++ } END { print count }' file  # count pattern
awk '{ print NR, NF, $0 }' file      # NR=row num, NF=field count
```

---

## cut · paste · sort · uniq · tr · wc · head · tail

```zsh
cut -d',' -f1,3 file.csv       # extract columns 1 and 3
paste a.txt b.txt              # merge two files side by side

sort file                      # sort alphabetically
sort -n file                   # sort numerically
sort -r file                   # reverse sort
sort -t',' -k2 file.csv        # sort by column 2

uniq file                      # remove consecutive duplicates (sort first)
uniq -c file                   # count occurrences
uniq -d file                   # show only duplicates

echo "Hello" | tr 'a-z' 'A-Z'  # translate chars
echo "a:b:c" | tr ':' ' '      # replace chars

wc -l file     # count lines
wc -w file     # count words
wc -c file     # count bytes

head -5 file   # first 5 lines
tail -5 file   # last 5 lines
tail -f file   # follow live (streaming)
```

---

## column · join

```zsh
column -t -s',' file.csv       # align CSV into readable columns
join a.txt b.txt               # join two sorted files on first field
join -t',' -1 1 -2 1 a.csv b.csv  # join CSVs on column 1
```

---

## Zsh String Manipulation

No pipes, no subshells — pure parameter expansion.

### Strip prefix

```zsh
path="/usr/local/bin/zsh"
${path#/usr}          # → /local/bin/zsh   (shortest prefix match)
${path##*/}           # → zsh              (longest — acts like basename)
```

### Strip suffix

```zsh
file="report-2024.csv"
${file%.csv}          # → report-2024      (shortest suffix match)
${path%/*}            # → /usr/local/bin   (longest — acts like dirname)
```

### Substitution

```zsh
str="the cat sat on the mat"
${str/the/a}          # → a cat sat on the mat   (first only)
${str//the/a}         # → a cat sat on a mat      (all)
```

### Length

```zsh
str="hello"
${#str}               # → 5
```

### Substring

```zsh
str="hello world"
${str:6:5}            # → world   (offset 6, length 5)
${str: -5}            # → world   (from end)
```

### Case

```zsh
${(U)str}             # → HELLO WORLD   (uppercase)
${(L)"HELLO"}         # → hello          (lowercase)
${(C)str}             # → Hello World    (capitalize each word)
```

### Join / Split

```zsh
arr=(a b c d)
${(j:, :)arr}         # → a, b, c, d    (join with ", ")

str="one:two:three"
parts=(${(s/:/)str})  # split on ":" → array of 3 items
print $parts[2]       # → two
```

### Chaining (no pipes needed)

```zsh
path="/var/log/app.log"
name=${path##*/}      # → app.log
base=${name%.log}     # → app
upper=${(U)base}      # → APP
```