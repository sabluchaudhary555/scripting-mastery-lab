# Zsh Operators & Expressions — Quick Notes

## Arithmetic
```zsh
(( a = 2 ** 8 ))       # inside (( )) for math
echo $(( 17 % 5 ))     # substitution → 2
```
Operators: `+ - * / % **` | Float needs `zmodload zsh/mathfunc`

---

## Assignment
```zsh
(( x += 5 ))   (( x **= 2 ))   (( x &= 0xFF ))
```
All work inside `(( ))` or `let`.

---

## Comparison
| Context | Style |
|---|---|
| `(( ))` | `== != < > <= >=` |
| `[[ ]]` | `-eq -ne -lt -le -gt -ge` |
| Strings | `== != < > -z -n` |

---

## Logical & Bitwise
```zsh
[[ -d /tmp && -w /tmp ]]       # AND / OR / NOT
(( a = 0b1100 & 0b1010 ))      # bitwise AND → 8
(( b = 1 << 3 ))               # left shift → 8
```

---

## File Tests
```zsh
[[ -f file ]]   # regular file     [[ -d dir ]]   # directory
[[ -r file ]]   # readable         [[ -x file ]]  # executable
[[ -s file ]]   # non-empty        [[ f1 -nt f2 ]] # f1 newer
```

---

## String Ops
```zsh
${#str}              # length
${str:2:3}           # substring
${str/old/new}       # replace first
${str//old/new}      # replace all
${str##*/}           # basename
${str%/*}            # dirname
${str:u} / ${str:l}  # UPPER / lower
```

---

## Parameter Defaults
```zsh
${var:-default}   # use default if unset/empty
${var:=default}   # assign default if unset/empty
${var:+alt}       # use alt if set
${var:?msg}       # exit with msg if unset
```

---

## Arrays
```zsh
arr=(a b c d)
echo $arr[1]        # a  (1-indexed)
echo $arr[-1]       # d  (last)
echo $arr[2,3]      # b c (slice)
echo ${(u)arr}      # unique
echo ${(o)arr}      # sorted
```

---

## Associative Arrays
```zsh
typeset -A colors
colors=(red "#FF0000" blue "#0000FF")
echo $colors[red]          # #FF0000
echo ${(k)colors}          # keys
echo ${(kv)colors}         # key-value pairs
```

---

## Regex & Glob
```zsh
[[ $str =~ ^[a-z]+@[a-z]+\.[a-z]{2,}$ ]]   # regex
echo $match[1]                                # capture group

setopt extendedglob
ls !(*.bak)          # not .bak files
ls *.+(txt|md)       # .txt or .md
```

---

## Redirection & Pipes
```zsh
cmd > out.txt        # stdout overwrite
cmd >> out.txt       # append
cmd 2> err.txt       # stderr
cmd &> all.txt       # both
diff <(ls dir1) <(ls dir2)   # process substitution
```

---

## Ternary & Increment
```zsh
(( result = x > 5 ? 100 : 0 ))   # ternary
(( y = ++x ))   # pre-increment
(( y = x++ ))   # post-increment
```

---

## Operator Precedence (high → low)
`++ --` → `** ` → `* / %` → `+ -` → `<< >>` → `== !=` → `& ^ |` → `&& ||` → `?:` → `=`