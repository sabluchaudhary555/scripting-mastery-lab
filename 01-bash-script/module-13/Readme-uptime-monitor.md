# 📡 Website Uptime Monitor

A production-grade Bash uptime monitor that checks multiple websites, tracks HTTP status codes and response times, sends **email + webhook alerts** on downtime, and generates a live **JSON status report** — built entirely with Module 13 networking tools.

---

## 📌 Module 13 Concepts Used

| Concept | Where Used |
|---------|-----------|
| `curl` | HTTP health checks with status code + response time |
| `curl -X POST` | Webhook alerts to Slack / Discord |
| `curl --write-out` | Extract `%{http_code}` and `%{time_total}` |
| `jq` | Generate and format JSON status report |
| `mail` | Email alerts on downtime and recovery |
| `nc` netcat | Optional TCP port check before HTTP |
| API calls with `curl` | Webhook POST with JSON payload |

---

## ✨ Features

- ✅ **Multi-site monitoring** — check unlimited sites from `sites.txt`
- ✅ **HTTP status validation** — configurable expected codes (200, 301, etc.)
- ✅ **Response time tracking** — logs how long each site takes
- ✅ **Consecutive failure threshold** — alert only after N failures (not every blip)
- ✅ **Recovery alerts** — notifies when a site comes back up
- ✅ **Email alerts** — via `mail` command
- ✅ **Slack / Discord webhook alerts** — colored POST with JSON payload
- ✅ **JSON status report** — live snapshot generated with `jq`
- ✅ **Daemon mode** — loop forever with configurable interval
- ✅ **Dry-run mode** — simulate alerts without sending
- ✅ **Debug mode** — full `bash -x` trace
- ✅ **Cron-ready** — single-run mode for cron integration
- ✅ **Colored logging** — UP (green) / DOWN (red) / WARN (yellow)

---

## 📁 Project Structure

```
uptime-monitor/
├── uptime_monitor.sh           # main script
├── sites.txt                   # list of URLs to monitor
├── README.md                   # this file
├── /tmp/uptime_monitor.log     # auto-created log
└── /tmp/uptime_status.json     # live JSON status report
```

---

## 🚀 Getting Started

### 1. Make executable
```bash
chmod +x uptime_monitor.sh
```

### 2. Add your sites to sites.txt
```
https://google.com
https://github.com
https://yoursite.com
```

### 3. Single check
```bash
./uptime_monitor.sh
```

### 4. Daemon mode
```bash
./uptime_monitor.sh --daemon
```

---

## 🛠️ Usage

```bash
./uptime_monitor.sh [OPTIONS]
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `-f FILE` | `./sites.txt` | Sites list file |
| `-i N` | `60` | Check interval in seconds |
| `-t N` | `10` | HTTP timeout seconds |
| `-T N` | `2` | Failures before alert |
| `-e EMAIL` | — | Alert email address |
| `-w URL` | — | Slack/Discord webhook URL |
| `-l FILE` | `/tmp/uptime_monitor.log` | Log file |
| `--daemon` | false | Run forever |
| `--dry-run` | false | Simulate alerts only |
| `--debug` | false | Enable `bash -x` trace |
| `-h` | — | Show help |

---

## 📊 Example Output

```
[2025-05-02 10:00:01] [ UP  ] https://google.com | HTTP 200 | 0.43s
[2025-05-02 10:00:01] [ UP  ] https://github.com | HTTP 200 | 0.61s
[2025-05-02 10:00:02] [DOWN ] https://yoursite.com | HTTP 000 | 0.00s | fails: 1/2

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📡 UPTIME MONITOR SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ UP   https://google.com
  ✅ UP   https://github.com
  ❌ DOWN https://yoursite.com (fails: 1)
  Total checks : 3  |  Up: 2  |  Down: 1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### JSON Status Report (`/tmp/uptime_status.json`)
```json
{
  "generated_at": "2025-05-02 10:00:02",
  "summary": { "total_checks": 3, "up": 2, "down": 1 },
  "sites": [
    { "url": "https://google.com",   "status": "UP",   "consecutive_fails": 0 },
    { "url": "https://github.com",   "status": "UP",   "consecutive_fails": 0 },
    { "url": "https://yoursite.com", "status": "DOWN", "consecutive_fails": 1 }
  ]
}
```

---

## 🔔 Alert Setup

### Email
```bash
./uptime_monitor.sh -e admin@example.com --daemon
```

### Slack Webhook
```bash
./uptime_monitor.sh -w https://hooks.slack.com/services/XXX/YYY/ZZZ --daemon
```

### Discord Webhook
```bash
./uptime_monitor.sh -w https://discord.com/api/webhooks/ID/TOKEN --daemon
```

---

## 🔁 Cron Setup

```bash
crontab -e
```
```
# Check every 5 minutes
*/5 * * * * /path/to/uptime_monitor.sh -e admin@example.com >> /tmp/uptime_cron.log 2>&1
```

---

## 🔍 Query JSON Status

```bash
# all sites and status
jq '.sites[] | "\(.status) \(.url)"' -r /tmp/uptime_status.json

# only DOWN sites
jq '.sites[] | select(.status == "DOWN")' /tmp/uptime_status.json

# count UP
jq '.summary.up' /tmp/uptime_status.json
```

---

## 💡 How It Works

```
start
  │
  ├── validate()          → curl exists? sites.txt has URLs?
  │
  └── [daemon loop] or [single run]
        └── run_check_cycle()
              ├── for each URL:
              │     ├── curl → HTTP code + response time
              │     ├── UP?  → log ✅ | send recovery if was DOWN
              │     └── DOWN → increment fail count
              │               → alert if threshold hit (email + webhook)
              └── jq → write JSON status report
```

---

## 📋 Requirements

```bash
sudo apt install curl jq mailutils
```

- `curl` — required
- `jq` — optional (JSON report)
- `mail` — optional (email alerts)

---

## 🧠 Learning Outcomes

- How `curl --write-out` extracts HTTP status codes and timing
- How to POST JSON webhooks to Slack/Discord with `curl -X POST`
- How to build and write JSON reports with `jq`
- How threshold-based alerting prevents false alarm spam
- How to build a clean daemon loop with `trap INT TERM`
- How `mail` sends automated email alerts from shell scripts

---
