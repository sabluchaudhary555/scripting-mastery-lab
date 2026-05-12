# 🟣 Module 15: System Administration & Automation — Short Notes

---

## 📊 System Monitoring

### CPU
```bash
top                          # real-time CPU monitor
htop                         # enhanced monitor
mpstat 1                     # per-CPU stats every 1s
ps aux --sort=-%cpu | head   # top CPU processes
uptime                       # load averages (1m 5m 15m)

# load average > CPU cores = overloaded
nproc                        # number of CPU cores
```

### Memory
```bash
free -h                      # total/used/free/available
vmstat 2                     # virtual memory stats every 2s
ps aux --sort=-%mem | head   # top memory processes

# "available" = what programs can actually use
# high swap usage = RAM problem
```

### Disk
```bash
df -h                        # disk space per filesystem
df -h /                      # root partition only
du -sh /var/log              # size of directory
du -sh /* | sort -hr | head  # largest dirs in /
lsblk                        # list block devices
iostat -x 2                  # disk I/O stats every 2s
```

### Network
```bash
ss -tlnp                     # listening ports + PIDs
ss -anp                      # all connections
netstat -tlnp                # older equivalent
iftop                        # real-time bandwidth monitor
ip addr                      # interfaces + IPs
ip -s link                   # interface traffic stats
curl -s ifconfig.me          # public IP
```

### One-liner System Report
```bash
echo "CPU:" && uptime
echo "MEM:" && free -h | grep Mem
echo "DISK:" && df -h /
echo "NET:" && ss -s
```

---

## 💾 Automated Backups

### tar — Archive
```bash
# Create compressed backup
tar -czf backup_$(date +%Y%m%d).tar.gz /home/user

# Incremental backup (only changed files)
tar -czf backup_inc.tar.gz \
    --newer-mtime="1 day ago" /home/user

# Verify archive
tar -tzf backup.tar.gz

# Restore
tar -xzf backup.tar.gz -C /restore/path

# Options
# -c create  -x extract  -z gzip  -f file
# -v verbose  -p preserve permissions
```

### rsync — Smart Sync
```bash
# Local sync
rsync -av /source/ /dest/

# Remote sync
rsync -avz /source/ user@host:/dest/

# Incremental (only changed files)
rsync -av --checksum /source/ /dest/

# Mirror (delete files not in source)
rsync -av --delete /source/ /dest/

# Dry run (preview)
rsync -av --dry-run /source/ /dest/

# Exclude patterns
rsync -av --exclude='.git' --exclude='node_modules' src/ dest/

# Bandwidth limit
rsync -av --bwlimit=1000 /source/ user@host:/dest/  # 1MB/s
```

### Rotation Strategy
```bash
# Keep last 7 daily backups
ls -t /backup/backup_*.tar.gz | tail -n +8 | xargs rm -f

# Keep daily (7) + weekly (4) + monthly (3)
find /backup/daily/   -mtime +7  -delete
find /backup/weekly/  -mtime +28 -delete
find /backup/monthly/ -mtime +90 -delete
```

---

## 📋 Log Management

### Rotation — logrotate
```bash
# /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily             # rotate daily
    rotate 7          # keep 7 rotated files
    compress          # gzip old logs
    delaycompress     # compress on next rotation
    missingok         # no error if log missing
    notifempty        # skip if log is empty
    create 0644 root root   # create new log with permissions
    postrotate
        systemctl reload myapp
    endscript
}

# Test rotation config
logrotate -d /etc/logrotate.d/myapp   # dry run
logrotate -f /etc/logrotate.d/myapp   # force rotate
```

### Log Analysis
```bash
# Count ERROR lines
grep -c "ERROR" /var/log/app.log

# Last 100 errors
grep "ERROR" /var/log/app.log | tail -100

# Most common errors
grep "ERROR" /var/log/app.log \
    | awk '{print $NF}' | sort | uniq -c | sort -rn | head

# Log entries per hour
grep "ERROR" /var/log/app.log \
    | awk '{print $1, substr($2,1,2)}' | uniq -c

# Follow live
tail -f /var/log/app.log
tail -f /var/log/app.log | grep --line-buffered "ERROR"

# journalctl (systemd logs)
journalctl -u nginx               # service logs
journalctl -u nginx -f            # follow
journalctl --since "1 hour ago"   # time filter
journalctl -p err                 # errors only
journalctl --disk-usage           # log size
```

### Log Alerts
```bash
# Alert on keyword in log
tail -F /var/log/app.log | while read line; do
    echo "$line" | grep -q "CRITICAL" \
        && echo "$line" | mail -s "CRITICAL Alert" admin@example.com
done &
```

---

## 👥 User Management

```bash
# Create user
useradd -m -s /bin/bash username          # -m = home dir
useradd -m -G sudo,docker username        # with groups
adduser username                          # interactive (Debian)

# Set / change password
passwd username
echo "username:newpass" | chpasswd        # non-interactive

# Modify user
usermod -aG docker username               # add to group (-a = append!)
usermod -s /bin/zsh username             # change shell
usermod -L username                      # lock account
usermod -U username                      # unlock account
usermod -e 2025-12-31 username           # set expiry date

# Delete user
userdel username                         # keep home dir
userdel -r username                      # remove home dir too

# Groups
groupadd devteam                         # create group
groupdel devteam                         # delete group
gpasswd -a username devteam             # add user to group
gpasswd -d username devteam             # remove from group
groups username                          # show user's groups
id username                              # UID, GID, groups

# View users
cat /etc/passwd | cut -d: -f1           # all usernames
who                                      # who is logged in
w                                        # who + what they're doing
last                                     # login history
```

---

## 📦 Package Management

### apt (Debian/Ubuntu)
```bash
apt update                    # refresh package lists
apt upgrade                   # upgrade all packages
apt full-upgrade              # upgrade + remove obsoletes
apt install nginx curl jq     # install packages
apt remove nginx              # remove (keep config)
apt purge nginx               # remove + config files
apt autoremove                # remove unused deps
apt search nginx              # search packages
apt show nginx                # package info
apt list --installed          # list installed
apt-cache policy nginx        # show versions available

# Non-interactive install
DEBIAN_FRONTEND=noninteractive apt install -y nginx
```

### yum (CentOS/RHEL 7)
```bash
yum update                    # update all
yum install nginx             # install
yum remove nginx              # remove
yum search nginx              # search
yum info nginx                # package info
yum list installed            # list installed
```

### dnf (CentOS/RHEL 8+, Fedora)
```bash
dnf update                    # update all
dnf install nginx             # install
dnf remove nginx              # remove
dnf search nginx              # search
dnf history                   # transaction history
dnf history undo last         # undo last transaction
```

---

## ⚙️ Service Management — systemctl

```bash
# Start / Stop / Restart
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl reload nginx          # reload config (no downtime)

# Enable / Disable at boot
systemctl enable nginx          # start on boot
systemctl disable nginx         # don't start on boot
systemctl enable --now nginx    # enable + start immediately

# Status & Info
systemctl status nginx          # detailed status + recent logs
systemctl is-active nginx       # active or inactive
systemctl is-enabled nginx      # enabled or disabled
systemctl list-units --type=service         # all services
systemctl list-units --type=service --failed  # failed only

# Logs
journalctl -u nginx             # all logs for service
journalctl -u nginx -f          # follow live
journalctl -u nginx --since "10 min ago"

# Create custom service: /etc/systemd/system/myapp.service
cat > /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=My Application
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/myapp/app.py
Restart=always
User=www-data
WorkingDirectory=/opt/myapp

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload          # reload after editing unit files
systemctl enable --now myapp
```

---

## 🕐 Task Scheduling

### cron — Recurring Jobs
```bash
crontab -e         # edit current user's crontab
crontab -l         # list crontab
crontab -r         # remove crontab
crontab -u user -e # edit another user's crontab

# System crontabs
/etc/crontab               # system crontab (has user column)
/etc/cron.d/               # drop-in cron files
/etc/cron.daily/           # scripts run daily
/etc/cron.hourly/          # scripts run hourly
```

```
# Format: min  hr  dom  mon  dow  command
  0      2    *   *    *    /backup.sh         # daily 2AM
  */5    *    *   *    *    /health_check.sh   # every 5 min
  0      9    *   *    1-5  /standup.sh        # weekdays 9AM
  0      0    1   *    *    /monthly.sh        # 1st of month
  @reboot                   /start_services.sh # on boot
  @daily                    /daily_backup.sh   # once a day
  @weekly                   /weekly_report.sh  # once a week
```

```bash
# Always use full paths in cron
0 2 * * * /usr/bin/python3 /home/user/script.py >> /var/log/cron.log 2>&1

# Suppress output
0 * * * * /script.sh > /dev/null 2>&1
```

### anacron — For Machines That Aren't Always On
```bash
# /etc/anacrontab — runs missed jobs when machine comes back online
# period  delay  job-id    command
1         5      daily     /etc/cron.daily/backup.sh
7         10     weekly    /etc/cron.weekly/report.sh
30        15     monthly   /etc/cron.monthly/cleanup.sh

# period = days between runs
# delay  = minutes to wait after boot before running
```

### at — One-time Jobs
```bash
echo "/backup.sh" | at 2:00 AM
echo "/deploy.sh" | at now + 1 hour
echo "/restart.sh" | at 3:00 PM tomorrow

atq              # list pending jobs
atrm 1           # remove job 1
at -c 1          # show job 1 contents
```

---
