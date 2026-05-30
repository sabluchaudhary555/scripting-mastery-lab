#!/bin/bash

# ============================================
#  Mini Task Manager (To-Do CLI)
#  Module 6 - Functions
# ============================================

# --- Color Codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Config ---
TASK_FILE="tasks.txt"

# --- Create task file if not exists ---
[[ ! -f "$TASK_FILE" ]] && touch "$TASK_FILE"

# ============================================
#  FUNCTIONS
# ============================================

# --- Banner ---
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════╗"
    echo "║       ✅ Mini Task Manager           ║"
    echo "║     Bash Module 6 — Functions        ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${RESET}"
}

# --- Show Menu ---
show_menu() {
    echo -e "${BOLD}📋 Menu:${RESET}"
    echo -e "  ${GREEN}[1]${RESET} Add Task"
    echo -e "  ${BLUE}[2]${RESET} List Tasks"
    echo -e "  ${YELLOW}[3]${RESET} Complete Task"
    echo -e "  ${RED}[4]${RESET} Delete Task"
    echo -e "  ${MAGENTA}[5]${RESET} Clear All Tasks"
    echo -e "  ${CYAN}[6]${RESET} Search Task"
    echo -e "  ${BOLD}[0]${RESET} Exit"
    echo ""
}

# --- Add Task ---
add_task() {
    local task="$1"

    if [[ -z "$task" ]]; then
        echo -e "${RED}❌ Error: Task name cannot be empty.${RESET}"
        return 1
    fi

    local id=$(get_next_id)
    local timestamp=$(date '+%Y-%m-%d %H:%M')
    echo "${id}|${task}|PENDING|${timestamp}" >> "$TASK_FILE"
    echo -e "${GREEN}✅ Task added: [#${id}] ${task}${RESET}"
}

# --- Get Next ID ---
get_next_id() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo 1
    else
        local last_id=$(awk -F'|' 'END {print $1}' "$TASK_FILE")
        echo $(( last_id + 1 ))
    fi
}

# --- List Tasks ---
list_tasks() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo -e "${YELLOW}📭 No tasks found. Add one!${RESET}"
        return
    fi

    echo -e "${BOLD}📋 Your Tasks:${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "  ${BOLD}%-4s %-25s %-10s %s${RESET}\n" "ID" "TASK" "STATUS" "ADDED"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    while IFS='|' read -r id task status timestamp; do
        if [[ "$status" == "DONE" ]]; then
            printf "  ${GREEN}%-4s %-25s %-10s %s${RESET}\n" "#$id" "$task" "✅ DONE" "$timestamp"
        else
            printf "  ${YELLOW}%-4s %-25s %-10s %s${RESET}\n" "#$id" "$task" "⏳ PENDING" "$timestamp"
        fi
    done < "$TASK_FILE"

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  Total: $(wc -l < "$TASK_FILE") task(s) | Done: $(grep -c 'DONE' "$TASK_FILE" 2>/dev/null || echo 0) | Pending: $(grep -c 'PENDING' "$TASK_FILE" 2>/dev/null || echo 0)"
}

# --- Complete Task ---
complete_task() {
    local id="$1"

    if [[ -z "$id" ]]; then
        echo -e "${RED}❌ Error: Please provide a task ID.${RESET}"
        return 1
    fi

    if ! grep -q "^${id}|" "$TASK_FILE"; then
        echo -e "${RED}❌ Task #${id} not found.${RESET}"
        return 1
    fi

    # Check already done
    if grep -q "^${id}|.*|DONE|" "$TASK_FILE"; then
        echo -e "${YELLOW}⚠️  Task #${id} is already marked as DONE.${RESET}"
        return
    fi

    sed -i "s/^${id}|\(.*\)|PENDING|\(.*\)$/${id}|\1|DONE|\2/" "$TASK_FILE"
    local task_name=$(grep "^${id}|" "$TASK_FILE" | awk -F'|' '{print $2}')
    echo -e "${GREEN}✅ Task #${id} marked as DONE: ${task_name}${RESET}"
}

# --- Delete Task ---
delete_task() {
    local id="$1"

    if [[ -z "$id" ]]; then
        echo -e "${RED}❌ Error: Please provide a task ID.${RESET}"
        return 1
    fi

    if ! grep -q "^${id}|" "$TASK_FILE"; then
        echo -e "${RED}❌ Task #${id} not found.${RESET}"
        return 1
    fi

    local task_name=$(grep "^${id}|" "$TASK_FILE" | awk -F'|' '{print $2}')
    sed -i "/^${id}|/d" "$TASK_FILE"
    echo -e "${RED}🗑️  Task #${id} deleted: ${task_name}${RESET}"
}

# --- Clear All Tasks ---
clear_tasks() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo -e "${YELLOW}📭 No tasks to clear.${RESET}"
        return
    fi

    read -p "$(echo -e ${RED}"⚠️  Delete ALL tasks? [y/N]: "${RESET})" confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        > "$TASK_FILE"
        echo -e "${GREEN}✅ All tasks cleared.${RESET}"
    else
        echo -e "${YELLOW}❌ Cancelled.${RESET}"
    fi
}

# --- Search Task ---
search_task() {
    local keyword="$1"

    if [[ -z "$keyword" ]]; then
        echo -e "${RED}❌ Error: Please provide a search keyword.${RESET}"
        return 1
    fi

    local results=$(grep -i "$keyword" "$TASK_FILE")

    if [[ -z "$results" ]]; then
        echo -e "${YELLOW}🔍 No tasks found matching: '$keyword'${RESET}"
        return
    fi

    echo -e "${BOLD}🔍 Search results for '${keyword}':${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    while IFS='|' read -r id task status timestamp; do
        if [[ "$status" == "DONE" ]]; then
            printf "  ${GREEN}%-4s %-25s %-10s %s${RESET}\n" "#$id" "$task" "✅ DONE" "$timestamp"
        else
            printf "  ${YELLOW}%-4s %-25s %-10s %s${RESET}\n" "#$id" "$task" "⏳ PENDING" "$timestamp"
        fi
    done <<< "$results"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# ============================================
#  MAIN — Entry Point
# ============================================
main() {
    show_banner

    while true; do
        show_menu
        read -p "$(echo -e ${BOLD}"Enter choice [0-6]: "${RESET})" choice
        echo ""

        case $choice in
            1)
                read -p "$(echo -e ${GREEN}"📝 Enter task: "${RESET})" task_input
                add_task "$task_input"
                ;;
            2)
                list_tasks
                ;;
            3)
                list_tasks
                echo ""
                read -p "$(echo -e ${YELLOW}"🔢 Enter task ID to complete: "${RESET})" task_id
                complete_task "$task_id"
                ;;
            4)
                list_tasks
                echo ""
                read -p "$(echo -e ${RED}"🔢 Enter task ID to delete: "${RESET})" task_id
                delete_task "$task_id"
                ;;
            5)
                clear_tasks
                ;;
            6)
                read -p "$(echo -e ${CYAN}"🔍 Enter keyword to search: "${RESET})" keyword
                search_task "$keyword"
                ;;
            0)
                echo -e "${GREEN}👋 Goodbye! Stay productive.${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid choice. Enter 0–6.${RESET}"
                ;;
        esac

        echo ""
    done
}

# --- Run ---
main