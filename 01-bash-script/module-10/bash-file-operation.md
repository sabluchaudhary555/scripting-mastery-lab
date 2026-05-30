# 📂 Bash File Operations — Quick Notes

## File Test Operators
```bash
[[ -e file ]]   # exists (any type)
[[ -f file ]]   # regular file
[[ -d file ]]   # directory
[[ -L file ]]   # symlink
[[ -s file ]]   # exists & non-empty
[[ -r file ]]   # readable
[[ -w file ]]   # writable
[[ -x file ]]   # executable
[[ f1 -nt f2 ]] # f1 newer than f2
[[ f1 -ot f2 ]] # f1 older than f2
[[ f1 -ef f2 ]] # same inode
```

---

## Create
```bash
touch file.txt                  # empty file
mkdir -p a/b/c                  # nested dirs
mkdir -p proj/{src,docs,tests}  # multiple dirs
mktemp                          # safe temp file
mktemp -d                       # safe temp dir
```

---

## Copy / Move / Delete
```bash
cp -a src/ dst/     # archive copy (best for backups)
cp -u src dst       # copy only if newer
mv -i src dst       # move with prompt
rm -i file          # delete with confirmation
rm -rf dir/         # ⚠️ force delete dir (no undo!)
```
> **Rule:** Always check `[[ -n "$dir" ]]` before `rm -rf "$dir"` — empty var = `rm -rf /`

---

## Permissions
```bash
chmod 755 file      # rwxr-xr-x  (scripts)
chmod 644 file      # rw-r--r--  (config files)
chmod 600 file      # rw-------  (private keys)
chmod +x file       # add execute bit
chmod -R 755 dir/   # recursive
chown user:group file
chown -R user dir/
```

---

## Read File
```bash
# Line by line (safest)
while IFS= read -r line; do
    echo "$line"
done < file.txt

# Into array
mapfile -t lines < file.txt

# Specific lines
head -n 1 file      # first line
tail -n 1 file      # last line
sed -n '5p' file    # line 5
```

---

## Write File
```bash
echo "text" > file          # overwrite
echo "text" >> file         # append
echo "text" | tee file      # write + show on terminal
echo "text" | tee -a file   # append + show
```

**Atomic write (safe for important files):**
```bash
tmp=$(mktemp)
echo "data" > "$tmp"
mv "$tmp" /etc/myapp.conf   # atomic rename
```

---

## Archive & Compress
```bash
tar -czf out.tar.gz dir/    # create gzip archive
tar -xf archive.tar.gz      # extract
tar -tf archive.tar.gz      # list contents
gzip file                   # compress (replaces original)
gunzip file.gz              # decompress
zip -r out.zip dir/
unzip out.zip
```

---

## Find Files
```bash
find . -name "*.sh"         # by name
find . -type f/d/l          # file / dir / symlink
find . -size +10M           # larger than 10MB
find . -mtime -7            # modified in last 7 days
find . -empty               # empty files or dirs
find . -name "*.tmp" -delete           # find & delete
find . -name "*.sh" -exec chmod +x {} \;  # find & exec
```

---

## Links
```bash
ln original hardlink            # hard link (same inode)
ln -s /path/to/orig symlink     # symbolic link
readlink -f link                # resolve absolute path
rm link                         # remove symlink (not rm -rf!)
```

| | Hard | Symlink |
|---|---|---|
| Cross filesystem | ❌ | ✅ |
| Survives original deletion | ✅ | ❌ |
| Can link dirs | ❌ | ✅ |

---

## Temp Files (Safe Pattern)
```bash
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT    # auto-cleanup on exit
echo "data" > "$tmpfile"
# ... use tmpfile ...
```

---

## File Info
```bash
stat file               # full metadata
stat -c "%s" file       # size in bytes
stat -c "%a" file       # octal permissions
file doc.pdf            # identify file type
du -sh dir/             # dir size
df -h                   # disk free space
```

---

## File Locking (Prevent Duplicate Runs)
```bash
flock -n /tmp/script.lock ./script.sh || echo "Already running!"
```

---

## Watch File Changes
```bash
tail -f /var/log/syslog             # follow log in real-time
inotifywait -m -e create /tmp/      # watch for new files
```

---

> 💡 **Golden Rules**
> - Always check before delete: `[[ -f file ]] && rm file`
> - Never `rm -rf` with unchecked variables
> - Use `mktemp` + `trap EXIT` for temp files
> - Use `cp -a` for backups, `cp -u` for sync