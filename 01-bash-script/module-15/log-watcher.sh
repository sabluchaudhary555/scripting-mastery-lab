#!/bin/bash
LOG=${1:-/var/log/syslog}
echo "=== WATCHING: $LOG ==="
echo "Press Ctrl+C to stop"
tail -f "$LOG" | while read line; do
    if echo "$line" | grep -qi "error\|fail\|critical"; then
        echo -e "\033[31m[ALERT] $line\033[0m"
    elif echo "$line" | grep -qi "warning"; then
        echo -e "\033[33m[WARN] $line\033[0m"
    else
        echo "$line"
    fi
done