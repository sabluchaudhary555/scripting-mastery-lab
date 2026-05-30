# 🟠 Module 13: Networking & Remote Operations — Short Notes

---

## 🌐 curl — HTTP Requests
```bash
curl https://api.example.com                      # GET request
curl -o file.zip https://example.com/file.zip     # download file
curl -L https://example.com                       # follow redirects
curl -I https://example.com                       # headers only
curl -s https://api.example.com                   # silent (no progress)
curl -f https://example.com || echo "failed"      # fail on HTTP error

# POST with JSON
curl -X POST https://api.example.com/data \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $TOKEN" \
     -d '{"name":"hacker","role":"admin"}'

# Save + show response code
curl -s -o response.json -w "%{http_code}" https://api.example.com
```

---

## 📥 wget — Download Files
```bash
wget https://example.com/file.tar.gz              # download
wget -O output.zip https://example.com/file.zip   # custom filename
wget -q https://example.com/file.zip              # quiet mode
wget -c https://example.com/largefile.zip         # resume download
wget -r -np https://example.com/docs/             # recursive download
wget --tries=3 --timeout=10 https://example.com   # retry + timeout
```

---

## 🔌 nc (Netcat) — Network Swiss Army Knife
```bash
nc -zv host.com 80          # check if port 80 is open
nc -zv host.com 20-100      # scan port range
nc -l 4444                  # listen on port 4444
nc host.com 4444            # connect to port 4444
echo "test" | nc host.com 80  # send data to port
```

---

## 🔎 Network Diagnostics
```bash
# ping — check connectivity
ping -c 4 google.com         # 4 packets
ping -c 1 host &>/dev/null && echo "up" || echo "down"

# traceroute — trace network path
traceroute google.com
traceroute -n google.com     # no DNS lookup (faster)

# nslookup — basic DNS lookup
nslookup google.com
nslookup google.com 8.8.8.8  # use specific DNS server

# dig — detailed DNS lookup
dig google.com               # full DNS info
dig google.com A             # only A record (IP)
dig google.com MX            # mail records
dig +short google.com        # just the IP
dig @8.8.8.8 google.com      # query specific server
```

---

## 🖧 Network Interfaces
```bash
# ip (modern)
ip addr                      # show all interfaces + IPs
ip addr show eth0            # specific interface
ip link show                 # interface status
ip route                     # routing table
ip route get 8.8.8.8         # route to a specific IP

# ifconfig (legacy)
ifconfig                     # all interfaces
ifconfig eth0                # specific interface

# Get your public IP
curl -s https://ifconfig.me
curl -s https://api.ipify.org
```

---

## 🔐 SSH — Secure Remote Access

### Key Setup
```bash
ssh-keygen -t ed25519 -C "your@email.com"   # generate key pair
ssh-copy-id user@remote-host                 # copy pub key to server
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host
```

### Connect & Run
```bash
ssh user@host                          # connect
ssh user@host -p 2222                  # custom port
ssh user@host "ls -la /var/www"        # run remote command
ssh user@host "bash -s" < script.sh   # run local script remotely
ssh -i ~/.ssh/mykey.pem user@host      # use specific key
```

### SSH Config (`~/.ssh/config`)
```
Host myserver
    HostName 192.168.1.10
    User hacker
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
```
```bash
ssh myserver    # now just this!
```

---

## 📁 scp — Secure File Copy
```bash
scp file.txt user@host:/remote/path/         # local → remote
scp user@host:/remote/file.txt ./            # remote → local
scp -r ./folder user@host:/remote/path/      # copy directory
scp -P 2222 file.txt user@host:/path/        # custom port
```

---

## 🔄 rsync — Smart File Sync
```bash
rsync -av src/ user@host:/dest/              # sync to remote
rsync -av user@host:/src/ ./dest/            # sync from remote
rsync -av --delete src/ dest/                # mirror (delete extras)
rsync -av --dry-run src/ dest/               # preview only
rsync -avz src/ user@host:/dest/             # compress during transfer
rsync -av --exclude='.git' --exclude='node_modules' src/ dest/

# Progress bar
rsync -av --progress largefile user@host:/path/
```

---

## 🌍 API Calls with curl

```bash
# GET with auth token
curl -s -H "Authorization: Bearer $TOKEN" \
     https://api.github.com/user

# POST JSON data
curl -s -X POST \
     -H "Content-Type: application/json" \
     -d '{"title":"bug","body":"something broke"}' \
     https://api.github.com/repos/user/repo/issues

# Check HTTP response code
code=$(curl -s -o /dev/null -w "%{http_code}" https://api.example.com)
[[ "$code" == "200" ]] && echo "OK" || echo "Failed: $code"

# Download with retry
curl --retry 3 --retry-delay 2 -s https://api.example.com/data
```

---

## 📦 jq — JSON Parsing
```bash
# install
sudo apt install jq

# parse JSON
echo '{"name":"hacker","age":25}' | jq .
echo '{"name":"hacker","age":25}' | jq '.name'      # "hacker"
echo '{"name":"hacker","age":25}' | jq -r '.name'   # hacker (raw, no quotes)

# from file
jq '.users[0].name' data.json
jq '.users[] | .email' data.json        # all emails
jq '.users | length' data.json          # count items

# with curl
curl -s https://api.github.com/users/torvalds | jq '{name: .name, repos: .public_repos}'

# filter array
curl -s https://api.example.com/items \
  | jq '[.[] | select(.status == "active")]'

# create JSON
jq -n --arg name "hacker" --arg role "admin" \
   '{name: $name, role: $role}'
```

---

## 📧 Email — mail / sendmail
```bash
# send simple email
echo "Server is down" | mail -s "Alert" admin@example.com

# with file attachment
echo "See attached log" | mail -s "Log Report" \
     -A /var/log/app.log admin@example.com

# multiple recipients
echo "Deploy done" | mail -s "Deploy" dev@example.com,ops@example.com

# sendmail
sendmail admin@example.com << EOF
Subject: Alert
From: script@server.com

Disk usage is above 90%
EOF
```

---

## 🗂️ FTP Automation
```bash
# basic ftp
ftp -n host.com << EOF
user username password
cd /uploads
put localfile.txt
bye
EOF

# lftp (better — supports SFTP, FTPS, retry)
lftp -u user,pass ftp://host.com << EOF
cd /uploads
mput *.csv
bye
EOF

# wget for FTP download
wget ftp://user:pass@host.com/file.txt

# curl for FTP
curl -u user:pass ftp://host.com/file.txt -o localfile.txt
curl -u user:pass -T upload.txt ftp://host.com/remote/
```

---

## 🧠 Quick Reference

| Task | Command |
|------|---------|
| HTTP GET | `curl -s https://url` |
| Download file | `wget https://url` |
| Check port open | `nc -zv host port` |
| DNS lookup | `dig +short domain` |
| My public IP | `curl -s ifconfig.me` |
| Show interfaces | `ip addr` |
| SSH connect | `ssh user@host` |
| Copy key to server | `ssh-copy-id user@host` |
| Remote file copy | `scp file user@host:/path` |
| Smart sync | `rsync -av src/ user@host:/dst/` |
| Parse JSON | `curl -s url \| jq '.field'` |
| Send alert email | `echo "msg" \| mail -s "subj" email` |
| Check HTTP code | `curl -o /dev/null -w "%{http_code}" url` |