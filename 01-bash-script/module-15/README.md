# 🚀 Bash Mini Projects Collection

A collection of 10 practical, short, and powerful Bash scripts for system administration, automation, and daily tasks.

## 📋 Table of Contents

- [Overview](#overview)
- [Projects](#projects)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage Examples](#usage-examples)
- [Project Details](#project-details)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

## 📖 Overview

This repository contains 10 mini Bash scripts covering essential Linux system administration tasks. Each script is:
- **10-15 lines** of clean code
- **Self-contained** with no external dependencies
- **Production-ready** with error handling
- **Color-coded** output for better readability

## 🎯 Projects

| # | Project | Description | Key Concepts |
|---|---------|-------------|--------------|
| 1 | **System Monitor** | Real-time system stats | `top`, `awk`, `free`, `df` |
| 2 | **Password Generator** | Secure random passwords | `/dev/urandom`, `sha256sum` |
| 3 | **Disk Cleaner** | Clean cache & temp files | `find`, `du`, `rm` |
| 4 | **Log Watcher** | Real-time log monitoring | `tail -f`, `grep`, colored output |
| 5 | **Backup Script** | Create compressed backups | `tar`, `date`, error handling |
| 6 | **Service Manager** | Control system services | `systemctl`, `case` statement |
| 7 | **User Manager** | User account management | `id`, `useradd`, `/etc/passwd` |
| 8 | **Download Manager** | Download files with progress | `curl`, `md5sum` |
| 9 | **Process Killer** | Kill problematic processes | `ps`, `kill`, PID management |
| 10 | **Log Rotator** | Rotate oversized log files | `gzip`, `truncate`, size check |

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/bash-mini-projects.git
cd bash-mini-projects

# Make all scripts executable
chmod +x *.sh

# Run any script
./system-monitor.sh