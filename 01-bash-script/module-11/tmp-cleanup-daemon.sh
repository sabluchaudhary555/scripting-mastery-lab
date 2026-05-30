#!/bin/bash
# ============================================================
#  Project 19 — Temp File Cleanup Daemon
#  Automatically deletes old tmp files on a schedule.
#  Uses: process management, signals, trap, cron, nohup, daemon
# ============================================================

# ---------- Configuration ----------
WATCH_DIRS=("/tmp" "/var/tmp" "${HOME}/.cache/tmp")   # dirs to clean
MAX_AGE_MINUTES=60          # delete files older than this
CHECK_INTERVAL=300          # check every 5 minutes (seconds)
PIDFILE="/tmp/tmp_cleanup_daemon.pid"
LOGFILE="/tmp/tmp_cleanup_daemon.log"
DRY_RUN=false               # set true to preview without deleting
# -----------------------------------

# ---------- Logging ----------
log() {
    local level="$1"
    shift
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $*" | tee -a "$LOGFILE"
}

# ---------- Check if already running ----------
check_existing() {
    if [[ -f "$PIDFILE" ]]; then
        local old_pid
        old_pid=$(cat "$PIDFILE")
        if kill -0 "$old_pid" 2>/dev/null; then
            echo "Daemon already running with PID $old_pid"
            echo "  Stop it first: kill $old_pid"
            exit 1
        else
            log "INFO" "Stale PID file found — removing"
            rm -f "$PIDFILE"
        fi
    fi
}

# ---------- Cleanup on exit ----------
on_exit() {
    log "INFO" "Daemon stopping (PID $$)"
    rm -f "$PIDFILE"
}

# ---------- Reload config on SIGHUP ----------
on_reload() {
    log "INFO" "SIGHUP received — reloading config"
    # Re-source config if external config file is used
    # source /etc/tmp_cleanup.conf
    log "INFO" "Config reloaded (MAX_AGE_MINUTES=$MAX_AGE_MINUTES)"
}

# ---------- Print stats on SIGUSR1 ----------
on_status() {
    log "INFO" "=== STATUS REPORT ==="
    log "INFO" "PID         : $$"
    log "INFO" "Watch dirs  : ${WATCH_DIRS[*]}"
    log "INFO" "Max age     : ${MAX_AGE_MINUTES} min"
    log "INFO" "Interval    : ${CHECK_INTERVAL}s"
    log "INFO" "Dry run     : $DRY_RUN"
    log "INFO" "Logfile     : $LOGFILE"
    log "INFO" "===================="
}

# ---------- Register signal traps ----------
trap on_exit    EXIT
trap on_reload  HUP
trap on_status  USR1
trap 'log "INFO" "SIGTERM received — shutting down"; exit 0' TERM
trap 'log "INFO" "SIGINT received — shutting down";  exit 0' INT

# ---------- Core cleanup function ----------
cleanup_directory() {
    local dir="$1"

    # Skip if directory does not exist
    [[ -d "$dir" ]] || { log "WARN" "Directory not found: $dir — skipping"; return; }

    local deleted=0
    local failed=0
    local total=0

    # Find files older than MAX_AGE_MINUTES
    while IFS= read -r -d '' file; do
        (( total++ ))
        if $DRY_RUN; then
            log "DRY-RUN" "Would delete: $file"
            (( deleted++ ))
        else
            if rm -f "$file" 2>/dev/null; then
                log "DELETE" "$file"
                (( deleted++ ))
            else
                log "ERROR"  "Cannot delete: $file"
                (( failed++ ))
            fi
        fi
    done < <(find "$dir" \
                  -maxdepth 2 \
                  -type f \
                  -mmin +"$MAX_AGE_MINUTES" \
                  -print0 2>/dev/null)

    # Also remove empty subdirectories
    if ! $DRY_RUN; then
        find "$dir" -mindepth 1 -maxdepth 2 -type d -empty -delete 2>/dev/null
    fi

    log "INFO" "[$dir] scanned=$total deleted=$deleted failed=$failed"
}

# ---------- One full scan cycle ----------
run_cycle() {
    log "INFO" "--- Cleanup cycle started ---"
    for dir in "${WATCH_DIRS[@]}"; do
        cleanup_directory "$dir"
    done
    log "INFO" "--- Cleanup cycle complete ---"
}

# ---------- Show usage ----------
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  start         Start the daemon
  stop          Stop a running daemon
  status        Show daemon status
  run-once      Run a single cleanup cycle and exit
  --dry-run     Preview deletions without removing files
  --age N       Max file age in minutes (default: $MAX_AGE_MINUTES)
  --interval N  Check interval in seconds (default: $CHECK_INTERVAL)
  --log FILE    Custom log file path
  -h, --help    Show this help

Examples:
  $0 start                    # start daemon (background)
  $0 start --dry-run          # preview what would be deleted
  $0 start --age 30           # delete files older than 30 min
  $0 stop                     # stop running daemon
  $0 status                   # show daemon status
  $0 run-once                 # one-shot cleanup
  kill -USR1 \$(cat $PIDFILE)  # print stats to log
  kill -HUP  \$(cat $PIDFILE)  # reload config
EOF
}

# ---------- Parse arguments ----------
ACTION="start"
for arg in "$@"; do
    case "$arg" in
        start)       ACTION="start" ;;
        stop)        ACTION="stop" ;;
        status)      ACTION="status" ;;
        run-once)    ACTION="run-once" ;;
        --dry-run)   DRY_RUN=true ;;
        --age)       shift; MAX_AGE_MINUTES="$1" ;;
        --interval)  shift; CHECK_INTERVAL="$1" ;;
        --log)       shift; LOGFILE="$1" ;;
        -h|--help)   usage; exit 0 ;;
    esac
done

# ---------- Actions ----------
case "$ACTION" in

    stop)
        if [[ -f "$PIDFILE" ]]; then
            pid=$(cat "$PIDFILE")
            if kill -TERM "$pid" 2>/dev/null; then
                echo "Daemon (PID $pid) stopped"
                rm -f "$PIDFILE"
            else
                echo "No process found for PID $pid"
                rm -f "$PIDFILE"
            fi
        else
            echo "Daemon is not running (no PID file)"
        fi
        exit 0
        ;;

    status)
        if [[ -f "$PIDFILE" ]]; then
            pid=$(cat "$PIDFILE")
            if kill -0 "$pid" 2>/dev/null; then
                echo "Daemon is RUNNING (PID $pid)"
                echo "  Log : $LOGFILE"
                echo "  Send kill -USR1 $pid to print stats"
                kill -USR1 "$pid" 2>/dev/null
            else
                echo "Daemon is NOT running (stale PID file)"
            fi
        else
            echo "Daemon is NOT running"
        fi
        exit 0
        ;;

    run-once)
        log "INFO" "Running one-shot cleanup"
        run_cycle
        exit 0
        ;;

    start)
        check_existing
        echo $$ > "$PIDFILE"
        log "INFO" "========================================"
        log "INFO" "Temp File Cleanup Daemon started"
        log "INFO" "PID         : $$"
        log "INFO" "Watch dirs  : ${WATCH_DIRS[*]}"
        log "INFO" "Max age     : ${MAX_AGE_MINUTES} min"
        log "INFO" "Interval    : ${CHECK_INTERVAL}s"
        log "INFO" "Dry run     : $DRY_RUN"
        log "INFO" "Log file    : $LOGFILE"
        log "INFO" "========================================"
        log "INFO" "Stop  : kill -TERM $$"
        log "INFO" "Stats : kill -USR1 $$"
        log "INFO" "Reload: kill -HUP  $$"

        # Main daemon loop
        while true; do
            run_cycle
            log "INFO" "Next cycle in ${CHECK_INTERVAL}s — sleeping..."
            sleep "$CHECK_INTERVAL"
        done
        ;;
esac