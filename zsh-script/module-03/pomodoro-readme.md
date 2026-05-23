#!/usr/bin/env zsh

# pomodoro.zsh - a simple focus timer
# usage: ./pomodoro.zsh [work_minutes] [break_minutes]

WORK=${1:-25}
BREAK=${2:-5}
SESSION=1

# colors - nothing fancy
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

notify() {
    local msg=$1
    # try desktop notification, fallback to terminal bell
    if command -v notify-send &>/dev/null; then
        notify-send "Pomodoro" "$msg"
    elif command -v osascript &>/dev/null; then
        osascript -e "display notification \"$msg\" with title \"Pomodoro\""
    else
        echo -e "\a"  # terminal bell
    fi
}

countdown() {
    local total=$(( $1 * 60 ))
    local label=$2

    while (( total > 0 )); do
        local mins=$(( total / 60 ))
        local secs=$(( total % 60 ))
        printf "\r  %s  →  %02d:%02d  " "$label" $mins $secs
        sleep 1
        (( total-- ))
    done
    printf "\n"
}

run_session() {
    echo ""
    echo -e "${GREEN}  Session $SESSION starting — focus for ${WORK} minutes${RESET}"
    echo "  Press Ctrl+C to stop anytime"
    echo ""

    countdown $WORK "Work"
    notify "Work session done! Take a break."

    echo ""
    echo -e "${YELLOW}  Break time — ${BREAK} minutes${RESET}"
    echo ""

    countdown $BREAK "Break"
    notify "Break over. Back to work!"

    (( SESSION++ ))
}

# trap ctrl+c for clean exit
trap 'echo -e "\n${RED}  Stopped after $((SESSION-1)) session(s)${RESET}\n"; exit 0' INT

echo ""
echo "  Pomodoro Timer"
echo "  Work: ${WORK}m  |  Break: ${BREAK}m"
echo "  ─────────────────────"

while true; do
    run_session
    echo -e "${GREEN}  Session complete! Total sessions: $((SESSION-1))${RESET}"
    echo ""

    # ask to continue
    printf "  Keep going? [y/n]: "
    read -r answer
    [[ $answer != "y" && $answer != "Y" ]] && break
done

echo ""
echo "  Done! You completed $((SESSION-1)) session(s) today."
echo ""