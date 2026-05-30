#!/bin/bash
# ============================================================
#  Bulk File Renamer
#  Author  : scripting-mastery-lab
#  Version : 1.0
#  Usage   : ./bulk_renamer.sh [directory]
#  Concepts: find, tr, sed, awk, loops, arrays, functions,
#            regex, string ops, I/O redirection, pipes, colors
# ============================================================

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Config ───────────────────────────────────────────────────
WORK_DIR="${1:-.}"          # default to current directory
DRY_RUN=true                # safe mode: preview only by default
LOG_DIR="./rename_logs"
LOG_FILE="$LOG_DIR/rename_$(date +%Y%m%d_%H%M%S).log"
UNDO_FILE="$LOG_DIR/undo_$(date +%Y%m%d_%H%M%S).sh"
RENAME_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0

# ── Helpers ──────────────────────────────────────────────────
ok()     { echo -e "  ${GREEN}✔${RESET}  $1"; }
fail()   { echo -e "  ${RED}✗${RESET}  $1"; }
info()   { echo -e "  ${CYAN}→${RESET}  $1"; }
warn()   { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
skip()   { echo -e "  ${DIM}–${RESET}  $1"; }
header() { echo -e "\n${BOLD}${BLUE}  ── $1 ──${RESET}\n"; }

log() {
    mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ── Banner ───────────────────────────────────────────────────
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ╔═══════════════════════════════════════════╗"
    echo "  ║        📁 Bulk File Renamer  v1.0          ║"
    echo "  ║   Rename · Clean · Organize · Undo        ║"
    echo "  ╚═══════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "  ${DIM}Working directory: ${BOLD}$WORK_DIR${RESET}"
    echo -e "  ${DIM}Log file         : $LOG_FILE${RESET}"
    if $DRY_RUN; then
        echo -e "  ${YELLOW}${BOLD}  🔍 DRY RUN MODE — No files will be changed${RESET}\n"
    else
        echo -e "  ${RED}${BOLD}  ⚡ LIVE MODE — Files WILL be renamed${RESET}\n"
    fi
}

# ── Toggle Dry Run ───────────────────────────────────────────
toggle_dry_run() {
    if $DRY_RUN; then
        DRY_RUN=false
        echo -e "\n  ${RED}${BOLD}⚡ Switched to LIVE MODE — changes will be applied!${RESET}\n"
        log "MODE: switched to LIVE"
    else
        DRY_RUN=true
        echo -e "\n  ${YELLOW}${BOLD}🔍 Switched to DRY RUN MODE — preview only${RESET}\n"
        log "MODE: switched to DRY RUN"
    fi
}

# ── Core Rename Function ─────────────────────────────────────
do_rename() {
    local old_path="$1"
    local new_path="$2"
    local dir
    dir=$(dirname "$old_path")
    local old_name
    old_name=$(basename "$old_path")
    local new_name
    new_name=$(basename "$new_path")

    # Skip if name unchanged
    if [[ "$old_name" == "$new_name" ]]; then
        skip "No change: $old_name"
        (( SKIP_COUNT++ ))
        return 0
    fi

    # Check if target already exists
    if [[ -e "$new_path" && "$old_path" != "$new_path" ]]; then
        fail "Conflict: '$new_name' already exists — skipping"
        log "CONFLICT: '$old_path' → '$new_path'"
        (( ERROR_COUNT++ ))
        return 1
    fi

    if $DRY_RUN; then
        info "${DIM}$old_name${RESET}  →  ${GREEN}${BOLD}$new_name${RESET}"
        (( RENAME_COUNT++ ))
    else
        if mv -- "$old_path" "$new_path" 2>/dev/null; then
            ok "${DIM}$old_name${RESET}  →  ${GREEN}${BOLD}$new_name${RESET}"
            log "RENAMED: '$old_path' → '$new_path'"
            # Write undo command
            echo "mv -- \"$new_path\" \"$old_path\"" >> "$UNDO_FILE"
            (( RENAME_COUNT++ ))
        else
            fail "Failed to rename: $old_name"
            log "ERROR: failed to rename '$old_path'"
            (( ERROR_COUNT++ ))
        fi
    fi
}

# ── Print Summary ────────────────────────────────────────────
print_summary() {
    echo ""
    echo -e "  ${BOLD}📊 Summary:${RESET}"
    echo -e "  ${GREEN}✔  Renamed : $RENAME_COUNT${RESET}"
    echo -e "  ${DIM}–  Skipped : $SKIP_COUNT${RESET}"
    (( ERROR_COUNT > 0 )) && echo -e "  ${RED}✗  Errors  : $ERROR_COUNT${RESET}"
    if ! $DRY_RUN && (( RENAME_COUNT > 0 )); then
        echo -e "\n  ${DIM}Undo script : $UNDO_FILE${RESET}"
        echo -e "  ${DIM}Log file    : $LOG_FILE${RESET}"
        echo -e "  ${CYAN}  To undo: bash $UNDO_FILE${RESET}"
    fi
    RENAME_COUNT=0; SKIP_COUNT=0; ERROR_COUNT=0
    echo ""
}

# ════════════════════════════════════════════════════════════
#  RENAME OPERATIONS
# ════════════════════════════════════════════════════════════

# ── 1. Spaces → Underscores ──────────────────────────────────
op_spaces_to_underscores() {
    header "Replace Spaces with Underscores"
    log "OP: spaces_to_underscores dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        newname=$(echo "$name" | tr ' ' '_')
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 2. Convert to Lowercase ──────────────────────────────────
op_to_lowercase() {
    header "Convert Filenames to Lowercase"
    log "OP: to_lowercase dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        newname=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 3. Convert to Uppercase ──────────────────────────────────
op_to_uppercase() {
    header "Convert Filenames to Uppercase"
    log "OP: to_uppercase dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        newname=$(echo "$name" | tr '[:lower:]' '[:upper:]')
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 4. Add Prefix ────────────────────────────────────────────
op_add_prefix() {
    read -p "  Enter prefix to add: " prefix
    [[ -z "$prefix" ]] && { warn "Prefix cannot be empty"; return; }

    header "Add Prefix: '$prefix'"
    log "OP: add_prefix prefix='$prefix' dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        newname="${prefix}${name}"
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 5. Add Suffix (before extension) ─────────────────────────
op_add_suffix() {
    read -p "  Enter suffix to add (before extension): " suffix
    [[ -z "$suffix" ]] && { warn "Suffix cannot be empty"; return; }

    header "Add Suffix: '$suffix'"
    log "OP: add_suffix suffix='$suffix' dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name base ext newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        ext="${name##*.}"
        base="${name%.*}"
        # If no extension, just append suffix
        if [[ "$name" == "$ext" ]]; then
            newname="${name}${suffix}"
        else
            newname="${base}${suffix}.${ext}"
        fi
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 6. Remove Prefix ─────────────────────────────────────────
op_remove_prefix() {
    read -p "  Enter prefix to remove: " prefix
    [[ -z "$prefix" ]] && { warn "Prefix cannot be empty"; return; }

    header "Remove Prefix: '$prefix'"
    log "OP: remove_prefix prefix='$prefix' dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        # Only remove if name actually starts with prefix
        if [[ "$name" == "$prefix"* ]]; then
            newname="${name#"$prefix"}"
            newpath="$dir/$newname"
            do_rename "$filepath" "$newpath"
        else
            skip "No prefix '$prefix' in: $name"
            (( SKIP_COUNT++ ))
        fi
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 7. Remove Suffix ─────────────────────────────────────────
op_remove_suffix() {
    read -p "  Enter suffix to remove (before extension): " suffix
    [[ -z "$suffix" ]] && { warn "Suffix cannot be empty"; return; }

    header "Remove Suffix: '$suffix'"
    log "OP: remove_suffix suffix='$suffix' dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name base ext newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        ext="${name##*.}"
        base="${name%.*}"
        if [[ "$base" == *"$suffix" ]]; then
            newbase="${base%"$suffix"}"
            if [[ "$name" == "$ext" ]]; then
                newname="$newbase"
            else
                newname="${newbase}.${ext}"
            fi
            newpath="$dir/$newname"
            do_rename "$filepath" "$newpath"
        else
            skip "No suffix '$suffix' in: $name"
            (( SKIP_COUNT++ ))
        fi
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 8. Change Extension ──────────────────────────────────────
op_change_extension() {
    read -p "  Change FROM extension (e.g. txt): " old_ext
    read -p "  Change TO extension   (e.g. md ): " new_ext
    old_ext="${old_ext#.}"    # strip leading dot if given
    new_ext="${new_ext#.}"

    [[ -z "$old_ext" || -z "$new_ext" ]] && { warn "Extensions cannot be empty"; return; }

    header "Change Extension: .$old_ext → .$new_ext"
    log "OP: change_extension .$old_ext→.$new_ext dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name base ext newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        ext="${name##*.}"
        base="${name%.*}"
        if [[ "${ext,,}" == "${old_ext,,}" ]]; then
            newname="${base}.${new_ext}"
            newpath="$dir/$newname"
            do_rename "$filepath" "$newpath"
        else
            skip "Different extension ($ext): $name"
            (( SKIP_COUNT++ ))
        fi
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 9. Find & Replace in Filename ────────────────────────────
op_find_replace() {
    read -p "  Find text in filename   : " find_text
    read -p "  Replace with            : " replace_text
    [[ -z "$find_text" ]] && { warn "Find text cannot be empty"; return; }

    header "Find & Replace: '$find_text' → '$replace_text'"
    log "OP: find_replace '$find_text'→'$replace_text' dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        if [[ "$name" == *"$find_text"* ]]; then
            newname="${name//"$find_text"/"$replace_text"}"
            newpath="$dir/$newname"
            do_rename "$filepath" "$newpath"
        else
            skip "Pattern not found in: $name"
            (( SKIP_COUNT++ ))
        fi
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 10. Add Sequential Numbering ─────────────────────────────
op_add_numbering() {
    read -p "  Enter base name (e.g. photo): " base_name
    read -p "  Enter extension   (e.g. jpg): " ext
    read -p "  Start number (default 1)    : " start_num
    ext="${ext#.}"
    start_num="${start_num:-1}"
    [[ -z "$base_name" ]] && { warn "Base name cannot be empty"; return; }
    ! [[ "$start_num" =~ ^[0-9]+$ ]] && { warn "Start number must be an integer"; return; }

    header "Add Sequential Numbering: ${base_name}_NNN.${ext}"
    log "OP: sequential base='$base_name' ext='$ext' start=$start_num dir=$WORK_DIR"

    local counter=$start_num
    while IFS= read -r -d '' filepath; do
        local dir name newname newpath cur_ext
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        cur_ext="${name##*.}"
        # Filter by extension if provided
        if [[ -n "$ext" && "${cur_ext,,}" != "${ext,,}" ]]; then
            skip "Different extension: $name"
            (( SKIP_COUNT++ ))
            continue
        fi
        newname="${base_name}_$(printf '%03d' $counter).${cur_ext}"
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
        (( counter++ ))
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 11. Add Date Prefix ──────────────────────────────────────
op_add_date_prefix() {
    local today
    today=$(date +%Y%m%d)
    header "Add Date Prefix: ${today}_"
    log "OP: add_date_prefix date=$today dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        # Skip if already starts with a date pattern
        if [[ "$name" =~ ^[0-9]{8}_ ]]; then
            skip "Already has date prefix: $name"
            (( SKIP_COUNT++ ))
            continue
        fi
        newname="${today}_${name}"
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 12. Remove Special Characters ────────────────────────────
op_remove_special_chars() {
    header "Remove Special Characters (keep a-z A-Z 0-9 . _ -)"
    log "OP: remove_special_chars dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name base ext newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        ext="${name##*.}"
        base="${name%.*}"
        # Remove special chars from base (keep alphanumeric, underscore, hyphen)
        local clean_base
        clean_base=$(echo "$base" | tr -dc 'a-zA-Z0-9_-' | tr -s '_-')
        if [[ "$name" == "$ext" ]]; then
            newname="$clean_base"
        else
            newname="${clean_base}.${ext}"
        fi
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 13. Regex-Based Rename (sed) ─────────────────────────────
op_regex_rename() {
    echo -e "  ${DIM}Examples: 's/[0-9]//g'  's/_/-/g'  's/^img/photo/'${RESET}"
    read -p "  Enter sed expression: " sed_expr
    [[ -z "$sed_expr" ]] && { warn "Expression cannot be empty"; return; }

    header "Regex Rename: sed '$sed_expr'"
    log "OP: regex_rename expr='$sed_expr' dir=$WORK_DIR"

    while IFS= read -r -d '' filepath; do
        local dir name newname newpath
        dir=$(dirname "$filepath")
        name=$(basename "$filepath")
        newname=$(echo "$name" | sed -E "$sed_expr" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            fail "Invalid sed expression for: $name"
            (( ERROR_COUNT++ ))
            continue
        fi
        newpath="$dir/$newname"
        do_rename "$filepath" "$newpath"
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)

    print_summary
}

# ── 14. Preview All Files ────────────────────────────────────
op_preview_files() {
    header "Files in: $WORK_DIR"
    local count=0
    while IFS= read -r -d '' filepath; do
        local name size
        name=$(basename "$filepath")
        size=$(du -sh "$filepath" 2>/dev/null | cut -f1)
        printf "  ${CYAN}%-40s${RESET} ${DIM}%s${RESET}\n" "$name" "$size"
        (( count++ ))
    done < <(find "$WORK_DIR" -maxdepth 1 -type f -print0 | sort -z)
    echo -e "\n  ${BOLD}Total files: $count${RESET}\n"
}

# ── 15. Undo Last Operation ──────────────────────────────────
op_undo() {
    # Find most recent undo script
    local latest_undo
    latest_undo=$(find "$LOG_DIR" -name "undo_*.sh" -type f 2>/dev/null | sort | tail -1)

    if [[ -z "$latest_undo" ]]; then
        warn "No undo history found in $LOG_DIR"
        return
    fi

    header "Undo Last Operation"
    echo -e "  ${DIM}Undo file: $latest_undo${RESET}\n"

    local count
    count=$(wc -l < "$latest_undo")
    echo -e "  Will undo ${BOLD}$count${RESET} rename(s):\n"

    # Preview undo
    while IFS= read -r line; do
        local from to
        from=$(echo "$line" | awk -F'"' '{print $4}' | xargs basename 2>/dev/null)
        to=$(echo "$line" | awk -F'"' '{print $2}' | xargs basename 2>/dev/null)
        info "${DIM}$from${RESET}  →  ${GREEN}$to${RESET}"
    done < "$latest_undo"

    echo ""
    read -p "  Proceed with undo? [y/N]: " confirm
    if [[ "${confirm,,}" == "y" ]]; then
        if bash "$latest_undo" 2>/dev/null; then
            ok "Undo completed successfully"
            log "UNDO: executed $latest_undo"
            rm -f "$latest_undo"
        else
            fail "Some undo operations failed"
            log "UNDO ERROR: $latest_undo"
        fi
    else
        warn "Undo cancelled"
    fi
    echo ""
}

# ════════════════════════════════════════════════════════════
#  MAIN MENU
# ════════════════════════════════════════════════════════════
main() {
    mkdir -p "$LOG_DIR"

    # Initialize undo file with header
    echo "#!/bin/bash" > "$UNDO_FILE"
    echo "# Undo script generated: $(date)" >> "$UNDO_FILE"
    echo "# Run: bash $UNDO_FILE" >> "$UNDO_FILE"

    log "=== Session started | dir=$WORK_DIR ==="
    print_banner

    while true; do
        echo -e "${BOLD}  Choose a rename operation:${RESET}\n"
        echo    "  ── Basic ──────────────────────────────────"
        echo    "  1)  Spaces → Underscores"
        echo    "  2)  Convert to Lowercase"
        echo    "  3)  Convert to Uppercase"
        echo    ""
        echo    "  ── Prefix / Suffix ────────────────────────"
        echo    "  4)  Add Prefix"
        echo    "  5)  Add Suffix  (before extension)"
        echo    "  6)  Remove Prefix"
        echo    "  7)  Remove Suffix"
        echo    ""
        echo    "  ── Advanced ───────────────────────────────"
        echo    "  8)  Change Extension"
        echo    "  9)  Find & Replace in Filename"
        echo    "  10) Add Sequential Numbering"
        echo    "  11) Add Date Prefix (YYYYMMDD_)"
        echo    "  12) Remove Special Characters"
        echo    "  13) Regex-Based Rename (sed)"
        echo    ""
        echo    "  ── Tools ──────────────────────────────────"
        echo    "  14) Preview Files in Directory"
        echo    "  15) Undo Last Operation"
        echo    "  16) Toggle Dry Run / Live Mode"
        echo    "  17) Exit"
        echo ""

        # Show current mode
        if $DRY_RUN; then
            echo -e "  ${YELLOW}[Mode: DRY RUN — preview only]${RESET}"
        else
            echo -e "  ${RED}[Mode: LIVE — changes applied]${RESET}"
        fi
        echo ""

        read -p "  Enter choice [1-17]: " choice
        echo ""

        case $choice in
            1)  op_spaces_to_underscores ;;
            2)  op_to_lowercase ;;
            3)  op_to_uppercase ;;
            4)  op_add_prefix ;;
            5)  op_add_suffix ;;
            6)  op_remove_prefix ;;
            7)  op_remove_suffix ;;
            8)  op_change_extension ;;
            9)  op_find_replace ;;
            10) op_add_numbering ;;
            11) op_add_date_prefix ;;
            12) op_remove_special_chars ;;
            13) op_regex_rename ;;
            14) op_preview_files ;;
            15) op_undo ;;
            16) toggle_dry_run ;;
            17)
                echo -e "  ${CYAN}${BOLD}Goodbye! Files organized. 📁${RESET}\n"
                echo -e "  ${DIM}Session log : $LOG_FILE${RESET}\n"
                log "=== Session ended ==="
                exit 0
                ;;
            *)
                echo -e "  ${RED}Invalid choice. Enter 1–17.${RESET}\n"
                ;;
        esac

        read -p "  Press Enter to continue..." _
        echo ""
        print_banner
    done
}

# ── Validate directory ───────────────────────────────────────
if [[ ! -d "$WORK_DIR" ]]; then
    echo -e "${RED}Error: Directory not found: $WORK_DIR${RESET}"
    echo "Usage: $0 [directory]"
    exit 1
fi

main