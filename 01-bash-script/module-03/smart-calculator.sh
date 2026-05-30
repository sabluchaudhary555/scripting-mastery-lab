#!/bin/bash
# ============================================================
#  smart-calculator.sh
#  Module 3 Mini Project — Operators & Expressions
#  Covers: let | (( )) | expr | bc | + - * / % ** ++ --
# ============================================================

# ── colour codes ────────────────────────────────────────────
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

# ── running total (demonstrates ++ / --) ────────────────────
total=0
op_count=0

# ── banner ──────────────────────────────────────────────────
show_banner() {
    echo -e "${CYAN}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║        🧮  Smart Calculator           ║"
    echo "  ║   Bash Module 3 — Mini Project        ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ── display running total ────────────────────────────────────
show_total() {
    echo -e "${YELLOW}  Running Total : ${BOLD}${total}${RESET}"
    echo -e "${YELLOW}  Operations    : ${BOLD}${op_count}${RESET}"
    echo ""
}

# ── menu ─────────────────────────────────────────────────────
show_menu() {
    echo -e "${BOLD}  ── Basic ──────────────────────────────${RESET}"
    echo "   1) Addition          ( + )"
    echo "   2) Subtraction       ( - )"
    echo "   3) Multiplication    ( * )"
    echo "   4) Division          ( / )  [integer]"
    echo "   5) Modulo            ( % )"
    echo ""
    echo -e "${BOLD}  ── Advanced ───────────────────────────${RESET}"
    echo "   6) Power / Exponent  ( ** )"
    echo "   7) Float Division    ( bc  )"
    echo "   8) Square Root       ( bc  )"
    echo ""
    echo -e "${BOLD}  ── Running Total ──────────────────────${RESET}"
    echo "   9) Increment total   ( ++ )"
    echo "  10) Decrement total   ( -- )"
    echo "  11) Add result to total"
    echo "  12) Reset total to 0"
    echo ""
    echo -e "${BOLD}  ── Other ──────────────────────────────${RESET}"
    echo "   0) Exit"
    echo -e "${CYAN}  ────────────────────────────────────────${RESET}"
}

# ── input helper ─────────────────────────────────────────────
get_two_numbers() {
    read -rp "  Enter first number  : " num1
    read -rp "  Enter second number : " num2

    # validate — must be integers for most ops
    if ! [[ "$num1" =~ ^-?[0-9]+$ ]] || ! [[ "$num2" =~ ^-?[0-9]+$ ]]; then
        echo -e "${RED}  ✗ Please enter valid integers.${RESET}"
        return 1
    fi
    return 0
}

get_one_number() {
    read -rp "  Enter a number : " num1
    if ! [[ "$num1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo -e "${RED}  ✗ Please enter a valid number.${RESET}"
        return 1
    fi
    return 0
}

# ── print result ──────────────────────────────────────────────
print_result() {
    local expression="$1"
    local result="$2"
    echo ""
    echo -e "${GREEN}  ✔ ${expression} = ${BOLD}${result}${RESET}"
    echo ""
    last_result="$result"
    (( op_count++ ))          # ++ operator demo
}

# ── operations ────────────────────────────────────────────────

do_addition() {
    get_two_numbers || return
    result=$(( num1 + num2 ))          # (( )) arithmetic
    print_result "${num1} + ${num2}" "$result"
}

do_subtraction() {
    get_two_numbers || return
    result=$(( num1 - num2 ))
    print_result "${num1} - ${num2}" "$result"
}

do_multiplication() {
    get_two_numbers || return
    result=$(( num1 * num2 ))
    print_result "${num1} * ${num2}" "$result"
}

do_division() {
    get_two_numbers || return
    if (( num2 == 0 )); then
        echo -e "${RED}  ✗ Division by zero is not allowed.${RESET}"
        return
    fi
    result=$(( num1 / num2 ))          # integer division via (( ))
    remainder=$(( num1 % num2 ))
    print_result "${num1} / ${num2}" "$result"
    echo -e "  (remainder: ${remainder})"
    echo ""
}

do_modulo() {
    get_two_numbers || return
    if (( num2 == 0 )); then
        echo -e "${RED}  ✗ Modulo by zero is not allowed.${RESET}"
        return
    fi
    let "result = num1 % num2"         # let operator demo
    print_result "${num1} % ${num2}" "$result"
}

do_power() {
    get_two_numbers || return
    if (( num2 < 0 )); then
        echo -e "${RED}  ✗ Negative exponents not supported for integers. Use float division.${RESET}"
        return
    fi
    result=$(( num1 ** num2 ))         # ** exponent operator
    print_result "${num1} ** ${num2}" "$result"
}

do_float_division() {
    read -rp "  Enter first number  : " num1
    read -rp "  Enter second number : " num2
    if [[ "$num2" == "0" ]]; then
        echo -e "${RED}  ✗ Division by zero.${RESET}"
        return
    fi
    result=$(echo "scale=4; ${num1} / ${num2}" | bc)   # bc for float
    print_result "${num1} / ${num2}" "$result"
}

do_sqrt() {
    get_one_number || return
    if (( $(echo "$num1 < 0" | bc -l) )); then
        echo -e "${RED}  ✗ Cannot find square root of a negative number.${RESET}"
        return
    fi
    result=$(echo "scale=4; sqrt(${num1})" | bc -l)    # bc math library
    print_result "sqrt(${num1})" "$result"
}

do_increment() {
    (( total++ ))                      # ++ on running total
    echo -e "${GREEN}  ✔ Total incremented → ${BOLD}${total}${RESET}"
    echo ""
    (( op_count++ ))
}

do_decrement() {
    (( total-- ))                      # -- on running total
    echo -e "${GREEN}  ✔ Total decremented → ${BOLD}${total}${RESET}"
    echo ""
    (( op_count++ ))
}

add_to_total() {
    if [[ -z "$last_result" ]]; then
        echo -e "${RED}  ✗ No result yet. Run a calculation first.${RESET}"
        return
    fi
    # expr to add (demonstrates expr usage)
    total=$(expr "$total" + "${last_result%.*}")
    echo -e "${GREEN}  ✔ Added ${last_result} to total → ${BOLD}${total}${RESET}"
    echo ""
}

reset_total() {
    total=0
    echo -e "${YELLOW}  ↺ Running total reset to 0.${RESET}"
    echo ""
}

# ── main loop ─────────────────────────────────────────────────
main() {
    show_banner
    last_result=""

    while true; do
        show_total
        show_menu
        read -rp "  Choose an option [0-12] : " choice
        echo ""

        case "$choice" in
            1)  do_addition        ;;
            2)  do_subtraction     ;;
            3)  do_multiplication  ;;
            4)  do_division        ;;
            5)  do_modulo          ;;
            6)  do_power           ;;
            7)  do_float_division  ;;
            8)  do_sqrt            ;;
            9)  do_increment       ;;
            10) do_decrement       ;;
            11) add_to_total       ;;
            12) reset_total        ;;
            0)
                echo -e "${CYAN}  Goodbye! Total operations performed: ${BOLD}${op_count}${RESET}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}  ✗ Invalid option. Please choose 0–12.${RESET}"
                echo ""
                ;;
        esac
    done
}

main