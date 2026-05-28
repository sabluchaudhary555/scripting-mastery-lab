# Module 10 — File Operations

> Quick reference. One concept, one example. No fluff.

---

## File & Directory Creation / Deletion

```zsh
touch file.txt                  # create empty file
mkdir mydir                     # create directory
mkdir -p a/b/c                  # create nested dirs at once

rm file.txt                     # delete file
rm -r mydir                     # delete directory recursively
rm -rf mydir                    # force delete, no prompts (careful)
rmdir mydir                     # delete empty directory only

cp file.txt copy.txt            # copy file
cp -r dir/ newdir/              # copy directory
mv old.txt new.txt              # rename / move
```

---

## find

```zsh
find . -name "*.log"            # by name
find . -type f                  # files only
find . -type d                  # directories only
find . -size +10M               # larger than 10MB
find . -size -1k                # smaller than 1KB
find . -mtime -7                # modified in last 7 days
find . -mtime +30               # modified more than 30 days ago
find . -newer ref.txt           # newer than ref.txt

# -exec — run a command on each result
find . -name "*.tmp" -exec rm {} \;
find . -type f -exec chmod 644 {} \;

# combine conditions
find . -type f -name "*.sh" -mtime -7
find . -type f \( -name "*.jpg" -o -name "*.png" \)   # OR
find . -type f ! -name "*.log"                         # NOT
```

---

## locate & updatedb

```zsh
locate filename          # fast search using index (not live)
locate "*.conf"          # wildcards work
sudo updatedb            # rebuild the index (run before locate)
locate -i filename       # case-insensitive
locate -c filename       # count matches only
```

> `find` searches live. `locate` searches a pre-built index — faster but can be stale.

---

## Path Operations

```zsh
basename /usr/local/bin/zsh        # → zsh
basename report-2024.csv .csv      # → report-2024  (strip extension)

dirname /usr/local/bin/zsh         # → /usr/local/bin
dirname ./scripts/deploy.sh        # → ./scripts

realpath ../config/app.conf        # → absolute path, resolves symlinks
realpath --relative-to=. /etc      # → relative path from current dir
```

---

## Permissions: chmod chown chgrp

```zsh
chmod 644 file.txt          # rw-r--r--
chmod 755 script.sh         # rwxr-xr-x
chmod +x script.sh          # add execute for all
chmod -w file.txt           # remove write for all
chmod u+x,g-w file.txt      # user +exec, group -write

chown alice file.txt            # change owner
chown alice:staff file.txt      # change owner and group
chown -R alice:staff ./dir      # recursive

chgrp staff file.txt            # change group only
```

**Permission bits quick ref:**

| Octal | Symbolic | Meaning |
|---|---|---|
| `7` | `rwx` | read + write + execute |
| `6` | `rw-` | read + write |
| `5` | `r-x` | read + execute |
| `4` | `r--` | read only |
| `0` | `---` | no permissions |

---

## Links: ln

```zsh
# hard link — same inode, both point to same data
ln original.txt hardlink.txt

# symbolic link — pointer to a path
ln -s /usr/local/bin/python3 ~/bin/python
ln -s $(realpath script.sh) /usr/local/bin/myscript

# check links
ls -la                          # l = symlink
stat file.txt                   # shows inode, link count
readlink -f symlink             # resolve full path
```

> Hard links: can't cross filesystems, can't link dirs.
> Symlinks: can cross filesystems, can link dirs, can break if target moves.

---

## File Info: stat & file

```zsh
stat file.txt               # size, inode, permissions, timestamps
stat -c "%n %s %y" *.txt    # custom format: name size modified

file image.jpg              # → JPEG image data
file script.sh              # → Bourne-Again shell script
file archive.tar.gz         # → gzip compressed data
file /bin/ls                # → ELF 64-bit executable
```

---

## Disk Usage: du & df

```zsh
du -h file.txt              # human-readable size of file
du -sh ./dir                # total size of directory
du -sh *                    # size of everything in current dir
du -h --max-depth=1 .       # one level deep only
du -sh * | sort -h          # sort by size

df -h                       # disk space on all filesystems
df -h /home                 # specific mount point
df -i                       # inode usage instead of blocks
```

---

## Temporary Files: mktemp

```zsh
tmpfile=$(mktemp)                      # → /tmp/tmp.XxXxXx
tmpdir=$(mktemp -d)                    # create temp directory
tmpfile=$(mktemp /tmp/myapp.XXXXXX)    # custom prefix + suffix

# always clean up
trap "rm -f $tmpfile" EXIT
trap "rm -rf $tmpdir" EXIT

# practical pattern
tmpfile=$(mktemp)
do_something > "$tmpfile"
process "$tmpfile"
# trap cleans it up automatically
```

---

## Globbing & Wildcards

```zsh
*           # match anything
?           # match one character
[abc]       # match a, b, or c
[a-z]       # match any lowercase letter
[^abc]      # match anything except a, b, c

ls *.txt            # all .txt files
ls file?.txt        # file1.txt, fileA.txt, etc.
ls [0-9]*.sh        # files starting with a digit

# extended globbing — needs: setopt EXTENDED_GLOB
ls ^*.log           # everything except .log files
ls **/*.sh          # recursive — all .sh files
ls *.{jpg,png,gif}  # multiple extensions (brace expansion)

# glob qualifiers
ls *(.)             # regular files only
ls *(/)             # directories only
ls *(x)             # executable files only
ls *(om)            # sorted by modification time
ls *(Lm+10)         # files larger than 10MB
```

---

## Zsh zmv — Smart Batch Rename

```zsh
autoload -Uz zmv        # load it first (put in .zshrc)

# basic syntax: zmv <pattern> <replacement>
# () in pattern = capture group, $1 $2 = captured parts

# add prefix
zmv '(*).txt' 'backup_$1.txt'

# change extension
zmv '(*).jpeg' '$1.jpg'

# lowercase all filenames
zmv '(*)' '${(L)1}'

# add date prefix
zmv '(*).log' "$(date +%Y%m%d)_\$1.log"

# rename with numbering
zmv -n '*.txt' '$1_${(l:3::0:)${(j::)${=1//[^0-9]/}}}.txt'

# dry run first — always use -n before running for real
zmv -n '(*).txt' 'new_$1.txt'    # -n = preview only, no changes
zmv    '(*).txt' 'new_$1.txt'    # run for real
```