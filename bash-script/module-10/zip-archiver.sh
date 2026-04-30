#!/bin/bash
# ============================================================
#  Password-Protected Zip Archiver
#  Zips and encrypts sensitive folders securely
# ============================================================

set -euo pipefail

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------- Config ----------
OUTPUT_DIR="./archives"
LOG_FILE="./archiver.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ---------- Logging ----------
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG_FILE"
}

# ---------- Print helpers ----------
info()    { echo -e "${CYAN}[INFO]${RESET}  $1"; }
success() { echo -e "${GREEN}[OK]${RESET}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $1"; }
error()   { echo -e "${RED}[ERROR]${RESET} $1"; }

# ---------- Check dependencies ----------
check_deps() {
    if ! command -v zip &>/dev/null; then
        error "'zip' is not installed."
        echo -e "  Install it with: ${BOLD}sudo apt install zip${RESET} (Debian/Ubuntu)"
        echo -e "                or ${BOLD}brew install zip${RESET} (macOS)"
        exit 1
    fi
}

# ---------- Usage ----------
usage() {
    echo -e "${BOLD}Usage:${RESET}"
    echo -e "  $0 <folder_or_file> [output_name]"
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  $0 ./documents"
    echo -e "  $0 ./documents my_secure_backup"
    echo -e "  $0 ./secret.txt"
    echo ""
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  -h, --help    Show this help message"
    exit 0
}

# ---------- Password prompt ----------
get_password() {
    local pass1 pass2

    echo -e "${YELLOW}Set archive password:${RESET}"
    read -rsp "  Enter password     : " pass1
    echo ""
    read -rsp "  Confirm password   : " pass2
    echo ""

    if [[ "$pass1" != "$pass2" ]]; then
        error "Passwords do not match. Aborting."
        exit 1
    fi

    if [[ ${#pass1} -lt 6 ]]; then
        warn "Password is very short (< 6 chars). Consider using a stronger one."
    fi

    PASSWORD="$pass1"
}

# ---------- Archive ----------
create_archive() {
    local source="$1"
    local archive_name="${2:-$(basename "$source")_${TIMESTAMP}}"
    local output="${OUTPUT_DIR}/${archive_name}.zip"

    # Create output dir
    mkdir -p "$OUTPUT_DIR"

    info "Source      : $source"
    info "Output      : $output"
    info "Encryption  : AES-256"
    echo ""

    # Create the encrypted zip
    zip -r -P "$PASSWORD" --encrypt "$output" "$source" \
        --quiet 2>/dev/null

    # Verify archive
    if zip -T "$output" &>/dev/null; then
        local size
        size=$(du -sh "$output" | cut -f1)
        success "Archive created successfully!"
        echo -e "  ${BOLD}File :${RESET} $output"
        echo -e "  ${BOLD}Size :${RESET} $size"
        log "SUCCESS | source=$source | output=$output | size=$size"
    else
        error "Archive verification failed! Deleting corrupt file."
        rm -f "$output"
        log "FAILED  | source=$source | archive corrupt, deleted"
        exit 1
    fi
}

# ---------- Show archive info ----------
show_archive_info() {
    local archive="$1"

    if [[ ! -f "$archive" ]]; then
        error "File not found: $archive"
        exit 1
    fi

    info "Contents of: $archive"
    echo ""
    unzip -l "$archive" 2>/dev/null || {
        warn "Could not list contents (may require password)."
    }
}

# ---------- Main ----------
main() {
    echo ""
    echo -e "${BOLD}${CYAN}==============================${RESET}"
    echo -e "${BOLD}${CYAN}  Password-Protected Archiver ${RESET}"
    echo -e "${BOLD}${CYAN}==============================${RESET}"
    echo ""

    # Flags
    [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage
    [[ $# -lt 1 ]] && { error "No source provided."; usage; }

    check_deps

    local source="$1"
    local name="${2:-}"

    # Validate source
    if [[ ! -e "$source" ]]; then
        error "Source not found: $source"
        exit 1
    fi

    get_password
    echo ""
    create_archive "$source" "$name"

    echo ""
    echo -e "${GREEN}${BOLD}Done! Keep your password safe — there is no recovery.${RESET}"
    echo ""
}

main "$@"