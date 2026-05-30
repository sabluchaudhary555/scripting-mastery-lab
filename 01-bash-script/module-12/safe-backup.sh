#!/bin/bash
# ============================================================
#  Project 1 — Safe Backup Script
#  Module 12 — Error Handling & Debugging
#
#  Features:
#   - set -euo pipefail (strict mode)
#   - trap EXIT + ERR (cleanup & error reporting)
#   - Full input validation
#   - Atomic write (temp → final)
#   - Archive integrity verification
#   - Log rotation (keep last N backups)
#   - Colored structured logging
#   - Dry-run mode
#   - Retry on failure
# ============================================================

set -euo pipefail
IFS=$'\n\t'

# ── PS4 for debug mode ───────────────────────────────────────
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# ============================================================
#  CONFIGURATION — edit these or override via env variables
# ============================================================
BACKUP_SRC="${BACKUP_SRC:-$HOME}"               # what to back up
BACKUP_DST="${BACKUP_DST:-/tmp/safe_backups}"   # where to store
MAX_BACKUPS="${MAX_BACKUPS:-5}"                  # how many to keep
RETRY_COUNT="${RETRY_COUNT:-3}"                 # retries on failure
RETRY_DELAY="${RETRY_DELAY:-5}"                 # seconds between retries
LOG_FILE="${LOG_FILE:-/tmp/safe_backup.log}"    # log file path
DRY_RUN="${DRY_RUN:-false}"                     # preview mode
DEBUG="${DEBUG:-false}"                         # debug trace mode
COMPRESS_LEVEL="${COMPRESS_LEVEL:-6}"           # gzip 1-9

# ============================================================
#  COLORS
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ============================================================
#  GLOBALS (set at runtime)
# ============================================================
SCRIPT_NAME="$(basename "$0")"
SCRIPT_START=$(date +%s)
TMPARCHIVE=""
BACKUP_FILE=""

# ============================================================
#  LOGGING
# ============================================================
_log() {
    local color="$1" level="$2"
    shift 2
    local msg="$*"
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    local line="[$ts] [$level] $msg"

    # terminal
    echo -e "${color}${line}${RESET}"

    # file
    echo "$line" >> "$LOG_FILE"
}

log_info()    { _log "$GREEN"  "INFO " "$@"; }
log_warn()    { _log "$YELLOW" "WARN " "$@" >&2; }
log_error()   { _log "$RED"    "ERROR" "$@" >&2; }
log_success() { _log "$BOLD$GREEN" "DONE " "$@"; }
log_debug()   { [[ "$DEBUG" == "true" ]] && _log "$CYAN" "DEBUG" "$@" || true; }

# ============================================================
#  die — print error and exit
# ============================================================
die() {
    local msg="$1"
    local code="${2:-1}"
    log_error "$msg"
    exit "$code"
}

# ============================================================
#  TRAP — ERR handler (fires on any failed command)
# ============================================================
on_error() {
    local exit_code=$?
    local line_no="$1"
    echo -e "${RED}" >&2
    echo "╔══════════════════════════════════════╗" >&2
    echo "║         ❌  BACKUP FAILED            ║" >&2
    echo "╠══════════════════════════════════════╣" >&2
    echo "║  Script  : $SCRIPT_NAME"              >&2
    echo "║  Line    : $line_no"                  >&2
    echo "║  Command : $BASH_COMMAND"             >&2
    echo "║  Code    : $exit_code"                >&2
    echo "╚══════════════════════════════════════╝" >&2
    echo -e "${RESET}" >&2
    log_error "Backup failed at line $line_no | cmd: $BASH_COMMAND | code: $exit_code"
}

# ============================================================
#  TRAP — EXIT handler (always runs)
# ============================================================
on_exit() {
    local exit_code=$?

    # remove temp archive if it exists and backup didn't finish
    if [[ -n "$TMPARCHIVE" && -f "$TMPARCHIVE" ]]; then
        log_warn "Removing incomplete temp archive: $TMPARCHIVE"
        rm -f "$TMPARCHIVE"
    fi

    # elapsed time
    local elapsed=$(( $(date +%s) - SCRIPT_START ))
    log_info "Total time: ${elapsed}s | Exit code: $exit_code"

    if [[ $exit_code -eq 0 ]]; then
        log_success "Backup script finished successfully ✅"
    else
        log_error "Backup script finished with errors ❌"
    fi
}

# register traps
trap 'on_error $LINENO' ERR
trap 'on_exit'          EXIT

# ============================================================
#  VALIDATION
# ============================================================
validate_inputs() {
    log_info "Validating inputs..."

    # Source must exist
    [[ -e "$BACKUP_SRC" ]] \
        || die "Source not found: $BACKUP_SRC"

    # Source must be readable
    [[ -r "$BACKUP_SRC" ]] \
        || die "Source not readable: $BACKUP_SRC"

    # Destination must be a directory or creatable
    if [[ ! -d "$BACKUP_DST" ]]; then
        log_warn "Destination missing — creating: $BACKUP_DST"
        mkdir -p "$BACKUP_DST" \
            || die "Cannot create destination: $BACKUP_DST"
    fi

    # Destination must be writable
    [[ -w "$BACKUP_DST" ]] \
        || die "Destination not writable: $BACKUP_DST"

    # MAX_BACKUPS must be a positive integer
    [[ "$MAX_BACKUPS" =~ ^[1-9][0-9]*$ ]] \
        || die "MAX_BACKUPS must be a positive integer, got: $MAX_BACKUPS"

    # COMPRESS_LEVEL must be 1-9
    [[ "$COMPRESS_LEVEL" =~ ^[1-9]$ ]] \
        || die "COMPRESS_LEVEL must be 1-9, got: $COMPRESS_LEVEL"

    # Required tools
    local tools=(tar gzip du stat date)
    local missing=()
    for tool in "${tools[@]}"; do
        command -v "$tool" &>/dev/null || missing+=("$tool")
    done
    [[ ${#missing[@]} -eq 0 ]] \
        || die "Missing required tools: ${missing[*]}"

    log_info "Validation passed ✅"
}

# ============================================================
#  DISK SPACE CHECK
# ============================================================
check_disk_space() {
    log_info "Checking available disk space..."

    local src_size
    src_size=$(du -sb "$BACKUP_SRC" 2>/dev/null | awk '{print $1}')

    local dst_available
    dst_available=$(df -B1 "$BACKUP_DST" | awk 'NR==2 {print $4}')

    log_debug "Source size    : $src_size bytes"
    log_debug "Dest available : $dst_available bytes"

    # need at least 1.2x source size (compression headroom)
    local needed=$(( src_size * 12 / 10 ))
    if (( dst_available < needed )); then
        die "Not enough disk space. Need ~$(( needed / 1024 / 1024 ))MB, available $(( dst_available / 1024 / 1024 ))MB"
    fi

    log_info "Disk space OK (available: $(( dst_available / 1024 / 1024 ))MB)"
}

# ============================================================
#  CREATE ARCHIVE  (with retry)
# ============================================================
create_archive() {
    local attempt=1

    while (( attempt <= RETRY_COUNT )); do
        log_info "Creating archive (attempt $attempt/$RETRY_COUNT)..."

        # Create temp file in destination directory
        TMPARCHIVE=$(mktemp "${BACKUP_DST}/tmp_backup_XXXXXX.tar.gz")
        log_debug "Temp archive: $TMPARCHIVE"

        if $DRY_RUN; then
            log_warn "[DRY-RUN] Would run: tar -czf $TMPARCHIVE $BACKUP_SRC"
            log_warn "[DRY-RUN] Skipping actual archive creation"
            return 0
        fi

        # Create archive
        if tar \
            --create \
            --gzip \
            --file="$TMPARCHIVE" \
            --preserve-permissions \
            --exclude="*.tmp" \
            --exclude=".cache" \
            --exclude="node_modules" \
            "$BACKUP_SRC" \
            2>>"$LOG_FILE"
        then
            log_info "Archive created successfully"
            return 0
        else
            log_warn "Archive creation failed (attempt $attempt)"
            rm -f "$TMPARCHIVE"
            TMPARCHIVE=""

            if (( attempt < RETRY_COUNT )); then
                log_info "Retrying in ${RETRY_DELAY}s..."
                sleep "$RETRY_DELAY"
            fi
        fi

        (( attempt++ ))
    done

    die "Archive creation failed after $RETRY_COUNT attempts"
}

# ============================================================
#  VERIFY ARCHIVE
# ============================================================
verify_archive() {
    if $DRY_RUN; then
        log_warn "[DRY-RUN] Skipping verification"
        return 0
    fi

    log_info "Verifying archive integrity..."

    # Test archive can be listed/read
    if ! tar -tzf "$TMPARCHIVE" > /dev/null 2>>"$LOG_FILE"; then
        die "Archive verification FAILED — archive is corrupt"
    fi

    # Check archive is not empty
    local file_count
    file_count=$(tar -tzf "$TMPARCHIVE" 2>/dev/null | wc -l)
    log_debug "Files in archive: $file_count"

    [[ "$file_count" -gt 0 ]] \
        || die "Archive is empty — backup aborted"

    local size
    size=$(du -sh "$TMPARCHIVE" | cut -f1)
    log_info "Archive verified ✅ | $file_count files | size: $size"
}

# ============================================================
#  ATOMIC MOVE — temp → final name
# ============================================================
finalize_archive() {
    if $DRY_RUN; then
        log_warn "[DRY-RUN] Skipping finalize"
        return 0
    fi

    local timestamp; timestamp=$(date '+%Y%m%d_%H%M%S')
    local src_basename; src_basename=$(basename "$BACKUP_SRC")
    BACKUP_FILE="${BACKUP_DST}/backup_${src_basename}_${timestamp}.tar.gz"

    log_info "Moving archive to final location: $BACKUP_FILE"

    # Atomic move — mv is atomic on same filesystem
    mv "$TMPARCHIVE" "$BACKUP_FILE"
    TMPARCHIVE=""   # clear so EXIT trap doesn't delete it

    log_success "Backup saved: $BACKUP_FILE"
}

# ============================================================
#  ROTATE OLD BACKUPS
# ============================================================
rotate_backups() {
    log_info "Rotating old backups (keeping last $MAX_BACKUPS)..."

    local src_basename; src_basename=$(basename "$BACKUP_SRC")
    local pattern="${BACKUP_DST}/backup_${src_basename}_*.tar.gz"

    # Count existing backups
    local count
    count=$(ls -1 $pattern 2>/dev/null | wc -l)
    log_debug "Existing backups: $count"

    if (( count > MAX_BACKUPS )); then
        local to_delete=$(( count - MAX_BACKUPS ))
        log_info "Removing $to_delete old backup(s)..."

        if $DRY_RUN; then
            ls -t $pattern 2>/dev/null \
                | tail -n "+$((MAX_BACKUPS + 1))" \
                | while read -r f; do
                    log_warn "[DRY-RUN] Would delete: $f"
                done
        else
            ls -t $pattern 2>/dev/null \
                | tail -n "+$((MAX_BACKUPS + 1))" \
                | while read -r f; do
                    rm -f "$f"
                    log_info "Deleted old backup: $f"
                done
        fi
    else
        log_info "No rotation needed ($count/$MAX_BACKUPS slots used)"
    fi
}

# ============================================================
#  SUMMARY REPORT
# ============================================================
print_summary() {
    local count
    local src_basename; src_basename=$(basename "$BACKUP_SRC")
    count=$(ls -1 "${BACKUP_DST}/backup_${src_basename}_"*.tar.gz 2>/dev/null | wc -l)

    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}  📦 BACKUP SUMMARY${RESET}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  Source       : ${CYAN}$BACKUP_SRC${RESET}"
    echo -e "  Destination  : ${CYAN}$BACKUP_DST${RESET}"
    if [[ -n "$BACKUP_FILE" ]] && ! $DRY_RUN; then
        local size; size=$(du -sh "$BACKUP_FILE" 2>/dev/null | cut -f1)
        echo -e "  Archive      : ${GREEN}$(basename "$BACKUP_FILE")${RESET}"
        echo -e "  Size         : ${GREEN}$size${RESET}"
    fi
    echo -e "  Total stored : ${YELLOW}$count / $MAX_BACKUPS${RESET}"
    echo -e "  Log          : $LOG_FILE"
    $DRY_RUN && echo -e "  Mode         : ${YELLOW}DRY RUN — nothing written${RESET}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# ============================================================
#  USAGE
# ============================================================
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -s PATH    Source to backup      (default: \$HOME)
  -d PATH    Backup destination    (default: /tmp/safe_backups)
  -n N       Max backups to keep   (default: 5)
  -r N       Retry count           (default: 3)
  -l FILE    Log file path         (default: /tmp/safe_backup.log)
  --dry-run  Preview without writing
  --debug    Enable bash -x tracing
  -h         Show this help

Environment overrides:
  BACKUP_SRC, BACKUP_DST, MAX_BACKUPS, RETRY_COUNT
  LOG_FILE, DRY_RUN, DEBUG, COMPRESS_LEVEL

Examples:
  $SCRIPT_NAME -s /etc -d /backup
  $SCRIPT_NAME -s /home -d /mnt/nas -n 7
  DRY_RUN=true $SCRIPT_NAME -s /var/www
  DEBUG=true $SCRIPT_NAME -s /etc 2>trace.log
EOF
    exit 0
}

# ============================================================
#  PARSE ARGUMENTS
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s)        BACKUP_SRC="$2"; shift 2 ;;
            -d)        BACKUP_DST="$2"; shift 2 ;;
            -n)        MAX_BACKUPS="$2"; shift 2 ;;
            -r)        RETRY_COUNT="$2"; shift 2 ;;
            -l)        LOG_FILE="$2"; shift 2 ;;
            --dry-run) DRY_RUN=true; shift ;;
            --debug)   DEBUG=true; shift ;;
            -h|--help) usage ;;
            *)         die "Unknown option: $1" 2 ;;
        esac
    done

    # enable bash -x if debug mode
    [[ "$DEBUG" == "true" ]] && set -x
}

# ============================================================
#  MAIN
# ============================================================
main() {
    parse_args "$@"

    # ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    log_info "════════════════════════════════════════"
    log_info " Safe Backup Script starting"
    log_info " Source : $BACKUP_SRC"
    log_info " Dest   : $BACKUP_DST"
    log_info " Dry run: $DRY_RUN | Debug: $DEBUG"
    log_info "════════════════════════════════════════"

    validate_inputs
    check_disk_space
    create_archive
    verify_archive
    finalize_archive
    rotate_backups
    print_summary
}

main "$@"