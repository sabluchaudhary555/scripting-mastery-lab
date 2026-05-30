# Zsh — Networking & Remote Operations

Short notes. Concept → syntax → when to use.

---

## curl

```zsh
curl URL                                        # fetch/print
curl -s URL                                     # silent (no progress)
curl -O URL                                     # save with original name
curl -L URL                                     # follow redirects
curl -I URL                                     # headers only

# GET with auth
curl -H "Authorization: Bearer TOKEN" URL

# POST JSON
curl -X POST URL \
     -H "Content-Type: application/json" \
     -d '{"key":"value"}'

# get HTTP status code only
curl -s -o /dev/null -w "%{http_code}" URL

# capture body + status together
RESP=$(curl -s -w "\n%{http_code}" URL)
BODY=$(echo "$RESP" | head -n -1)
CODE=$(echo "$RESP" | tail -n 1)
```

---

## wget

```zsh
wget URL                      # download file
wget -q -O out.html URL       # quiet, custom name
wget -c URL                   # resume interrupted download
wget -r -np -k URL            # recursive download (mirror docs)
wget -i urls.txt              # download list of URLs
```

> Use `curl` for API calls. Use `wget` for recursive/file downloads.

---

## nc (netcat)

```zsh
nc -zv host port              # test if port is open
nc -zv host 20-25             # scan port range
nc -l 4444                    # listen on port (simple server)
nc host 4444                  # connect to listener
nc -l 5555 > file.txt         # receive file
nc host 5555 < file.txt       # send file
```

---

## ping / traceroute / dig

```zsh
ping -c 4 host                # send 4 pings
ping -c 1 -W 2 host           # quick reachability check (2s timeout)

traceroute host               # show each hop to destination

dig +short host               # quick IP lookup
dig host MX                   # mail records
dig host NS                   # nameservers
dig -x IP                     # reverse DNS
dig @8.8.8.8 host             # use specific DNS server
```

**In scripts:**
```zsh
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "online"
fi

IP=$(dig +short google.com | head -1)
```

---

## ip / ifconfig

```zsh
ip addr                       # show all IPs
ip addr show eth0             # specific interface
ip route                      # routing table
ip route show default         # default gateway

# get local IP in a script
LOCAL=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
PUBLIC=$(curl -s https://ifconfig.me)
```

> `ip` = Linux (modern). `ifconfig` = macOS / legacy Linux.

---

## SSH

```zsh
ssh user@host                         # connect
ssh -p 2222 user@host                 # custom port
ssh -i ~/.ssh/key user@host           # specific key
ssh user@host "df -h && free -m"      # run remote command

# port forwarding
ssh -L 8080:localhost:80 user@host    # local → remote
ssh -R 9090:localhost:3000 user@host  # remote → local
```

**~/.ssh/config** — save profiles:
```
Host prod
    HostName 1.2.3.4
    User deploy
    IdentityFile ~/.ssh/prod_key
    Port 2222
```
Then just: `ssh prod`

---

## SSH Keys

```zsh
ssh-keygen -t ed25519 -C "comment"    # generate key (use ed25519)
ssh-copy-id user@host                 # install public key on server
ssh-add ~/.ssh/mykey                  # add key to agent
ssh-add -l                            # list loaded keys
cat ~/.ssh/id_ed25519.pub             # view public key
```

> Private key = secret. Public key = safe to share/copy to servers.

---

## scp / rsync

```zsh
# scp — simple copy
scp file.txt user@host:/path/
scp -r /dir/ user@host:/path/
scp user@host:/remote/file.txt ./

# rsync — smarter (only sends changes)
rsync -avz  src/ user@host:/dest/     # sync with compression
rsync -avzP src/ user@host:/dest/     # + progress + resume
rsync --delete src/ dest/             # mirror (delete extra files)
rsync -n src/ dest/                   # dry run (preview only)
rsync --exclude="*.log" src/ dest/    # exclude patterns
rsync -e "ssh -p 2222" src/ u@h:/d/  # custom SSH port
```

> Use `rsync` over `scp` for anything more than a one-off file copy.

---

## API calls with curl + jq

```zsh
# pretty-print response
curl -s URL | jq .

# extract fields
curl -s URL | jq '.name'           # string field
curl -s URL | jq -r '.name'        # raw (no quotes)
curl -s URL | jq '.[].email'       # field from each array item
curl -s URL | jq 'select(.age>18)' # filter by condition

# build JSON from variables (safe, no quoting issues)
JSON=$(jq -n \
    --arg name "Alice" \
    --argjson age 30 \
    '{name: $name, age: $age}')
```

**Loop over JSON array:**
```zsh
curl -s URL | jq -c '.[]' | while IFS= read -r item; do
    name=$(echo "$item" | jq -r '.name')
    echo "user: $name"
done
```

---

## XML (xmllint / xmlstarlet)

```zsh
xmllint --format file.xml                          # pretty-print
xmllint --xpath "//user/name/text()" file.xml      # XPath query

xmlstarlet sel -t -v "//user/name" -n file.xml     # select values
xmlstarlet sel -t -v "//user[@id='1']/email" file.xml  # with filter
```

> Never use `grep`/`sed` for XML. Use `xmllint` or `xmlstarlet`.

---

## Email

```zsh
echo "body" | mail -s "Subject" user@example.com
echo "body" | mail -s "Subject" -A file.log user@example.com  # attachment

# sendmail with headers
sendmail user@example.com << EOF
From: me@example.com
To: user@example.com
Subject: Test

body here
EOF
```

---

## FTP / SFTP

```zsh
sftp user@host                        # interactive secure FTP (preferred)
sftp -i ~/.ssh/key user@host

# automated sftp
sftp user@host << EOF
cd /remote/dir
put file.txt
bye
EOF

# curl for FTP
curl ftp://host/file.txt --user u:p -o file.txt
curl -T file.txt ftp://host/uploads/ --user u:p

# lftp (best for scripts)
lftp -c "open -u user,pass host; mirror -R /local/ /remote/"
```

---

## Quick Reference

```zsh
# connectivity
ping -c 1 -W 2 host > /dev/null && echo "up" || echo "down"
curl -s -o /dev/null -w "%{http_code}" URL   # HTTP status
nc -zw 2 host port                            # port open?

# DNS
dig +short domain              # IP
dig domain MX                  # mail servers

# SSH
ssh user@host "cmd"            # remote command
ssh-keygen -t ed25519          # generate key
ssh-copy-id user@host          # install key

# file transfer
scp file user@host:/path/
rsync -avzP src/ user@host:/dest/
rsync -n src/ dest/            # dry run first!

# JSON
curl -s URL | jq -r '.field'
jq -n --arg k "v" '{key: $k}' # build JSON safely

# XML
xmllint --xpath "//tag/text()" file.xml

# email
echo "body" | mail -s "subj" addr@example.com
```