#!/bin/bash

# ============================================
#  Bulk File Renamer
#  Module 5 - Loops
============================================

# --- Color Codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Banner ---
echo -e "${CYAN}"
echo "╔══════════════════════════════════════╗"
echo "║        📁 Bulk File Renamer          ║"
echo "║     Bash Module 5 — Loops            ║"
echo "╚══════════════════════════════════════╝"
echo -e "${RESET}"

# --- Usage Function ---
usage() {
    echo -e "${YELLOW}Usage:${RESET}"
    echo -e "  $0 <directory> <extension> <prefix>"
    echo -e ""
    echo -e "${YELLOW}Example:${RESET}"
    echo -e "  $0 ./photos jpg photo"
    echo -e "  $0 ./docs txt report"
    echo -e "  $0 . sh script"
    exit 1
}

# --- Argument Check ---
if [ $# -lt 3 ]; then
    echo -e "${RED}❌ Error: Missing arguments.${RESET}"
    usage
fi

TARGET_DIR="$1"
EXTENSION="$2"
PREFIX="$3"

# --- Directory Check ---
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}❌ Error: Directory '$TARGET_DIR' does not exist.${RESET}"
    exit 1
fi

# --- Count matching files ---
file_count=$(ls "$TARGET_DIR"/*."$EXTENSION" 2>/dev/null | wc -l)

if [[ $file_count -eq 0 ]]; then
    echo -e "${RED}❌ No .${EXTENSION} files found in '${TARGET_DIR}'.${RESET}"
    exit 1
fi

echo -e "${BLUE}📂 Directory : ${RESET}$TARGET_DIR"
echo -e "${BLUE}🔍 Extension : ${RESET}.$EXTENSION"
echo -e "${BLUE}🏷️  Prefix    : ${RESET}$PREFIX"
echo -e "${BLUE}📄 Files Found: ${RESET}$file_count"
echo ""

# --- Confirm before renaming ---
read -p "$(echo -e ${YELLOW}"⚠️  Rename all $file_count file(s)? [y/N]: "${RESET})" confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Operation cancelled.${RESET}"
    exit 0
fi

echo ""
echo -e "${BOLD}🔄 Renaming files...${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# --- Counter ---
counter=1
success=0
failed=0

# --- Main Loop: Loop over files with matching extension ---
for file in "$TARGET_DIR"/*."$EXTENSION"; do

    # Skip if no files matched (glob returned literal string)
    [[ -e "$file" ]] || continue

    # Build new filename with zero-padded number
    new_name="${PREFIX}_$(printf '%03d' $counter).${EXTENSION}"
    new_path="${TARGET_DIR}/${new_name}"

    # Get old filename only (not full path)
    old_name=$(basename "$file")

    # Rename using mv
    if mv "$file" "$new_path" 2>/dev/null; then
        echo -e "  ${GREEN}✅ Renamed:${RESET} $old_name  →  $new_name"
        (( success++ ))
    else
        echo -e "  ${RED}❌ Failed :${RESET} $old_name"
        (( failed++ ))
    fi

    (( counter++ ))
done

# --- Summary ---
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${BOLD}📊 Summary:${RESET}"
echo -e "  ${GREEN}✅ Successfully renamed : $success file(s)${RESET}"
echo -e "  ${RED}❌ Failed               : $failed file(s)${RESET}"
echo -e "  📁 Saved in             : $TARGET_DIR"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}✅ Done | Module 5 — Loops (for loop over files)${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"