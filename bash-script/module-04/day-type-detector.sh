#!/bin/bash

# ============================================
#  Day Type Detector
#  Module 4 - Conditional Statements (case)
#  Author: sabluchaudhary555
#  GitHub: scripting-mastery-lab
# ============================================

# --- Color Codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Banner ---
echo -e "${CYAN}"
echo "╔══════════════════════════════════╗"
echo "║       📅 Day Type Detector       ║"
echo "║     Bash Module 4 — case/esac    ║"
echo "╚══════════════════════════════════╝"
echo -e "${RESET}"

# --- Input ---
read -p "$(echo -e ${BOLD}"Enter a day name: "${RESET})" day

# --- Normalize input to lowercase ---
day=$(echo "$day" | tr '[:upper:]' '[:lower:]')

# --- Case Statement ---
case $day in

    monday)
        echo -e "\n${YELLOW}📌 Day     : Monday${RESET}"
        echo -e "${RED}🔴 Type    : Weekday${RESET}"
        echo -e "${CYAN}💬 Quote   : 'New week, new goals!'${RESET}"
        ;;

    tuesday)
        echo -e "\n${YELLOW}📌 Day     : Tuesday${RESET}"
        echo -e "${RED}🔴 Type    : Weekday${RESET}"
        echo -e "${CYAN}💬 Quote   : 'Keep pushing forward!'${RESET}"
        ;;

    wednesday)
        echo -e "\n${YELLOW}📌 Day     : Wednesday${RESET}"
        echo -e "${RED}🔴 Type    : Weekday${RESET}"
        echo -e "${CYAN}💬 Quote   : 'Halfway there, stay strong!'${RESET}"
        ;;

    thursday)
        echo -e "\n${YELLOW}📌 Day     : Thursday${RESET}"
        echo -e "${RED}🔴 Type    : Weekday${RESET}"
        echo -e "${CYAN}💬 Quote   : 'Almost Friday, keep going!'${RESET}"
        ;;

    friday)
        echo -e "\n${YELLOW}📌 Day     : Friday${RESET}"
        echo -e "${RED}🔴 Type    : Weekday (but feels like weekend 😄)${RESET}"
        echo -e "${CYAN}💬 Quote   : 'TGIF — Thank God It'\''s Friday!'${RESET}"
        ;;

    saturday)
        echo -e "\n${YELLOW}📌 Day     : Saturday${RESET}"
        echo -e "${GREEN}🟢 Type    : Weekend${RESET}"
        echo -e "${CYAN}💬 Quote   : 'Rest, recharge, repeat!'${RESET}"
        ;;

    sunday)
        echo -e "\n${YELLOW}📌 Day     : Sunday${RESET}"
        echo -e "${GREEN}🟢 Type    : Weekend${RESET}"
        echo -e "${CYAN}💬 Quote   : 'Prep for the week ahead!'${RESET}"
        ;;

    *)
        echo -e "\n${RED}❌ Error: '${day}' is not a valid day name.${RESET}"
        echo -e "${YELLOW}👉 Please enter a valid day (e.g. Monday, Tuesday...)${RESET}"
        exit 1
        ;;
esac

# --- Extra Info using if/elif ---
echo ""
echo -e "${BOLD}📊 Additional Info:${RESET}"

if [[ $day == "saturday" || $day == "sunday" ]]; then
    echo -e "   🏖️  Office  : Closed"
    echo -e "   😴  Status  : Rest Day"
    echo -e "   📅  Plan    : Personal projects / Chill"
elif [[ $day == "monday" || $day == "friday" ]]; then
    echo -e "   🏢  Office  : Open"
    echo -e "   ⚡  Status  : High Energy Day"
    echo -e "   📅  Plan    : Meetings & Planning"
else
    echo -e "   🏢  Office  : Open"
    echo -e "   💻  Status  : Deep Work Day"
    echo -e "   📅  Plan    : Focus & Execute"
fi
