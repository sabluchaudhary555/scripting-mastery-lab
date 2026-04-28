#!/bin/bash
# ============================================================
#  Password Strength Checker
#  Author  : scripting-mastery-lab
#  Version : 1.0
#  Usage   : ./password_checker.sh
# ============================================================

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helper: print a rule result ──────────────────────────────
pass_rule() { echo -e "  ${GREEN}✔${RESET}  $1"; }
fail_rule()  { echo -e "  ${RED}✗${RESET}  $1"; }

# ── Banner ───────────────────────────────────────────────────
print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║     🔐 Password Strength Checker     ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ── Strength Bar ─────────────────────────────────────────────
strength_bar() {
    local score=$1
    local bar=""
    local filled=$(( score * 2 ))   # each point = 2 blocks
    local empty=$(( 20 - filled ))

    for (( i=0; i<filled; i++ )); do bar+="█"; done
    for (( i=0; i<empty;  i++ )); do bar+="░"; done

    if   (( score <= 2 )); then echo -e "${RED}${bar}${RESET}"
    elif (( score <= 4 )); then echo -e "${YELLOW}${bar}${RESET}"
    else                        echo -e "${GREEN}${bar}${RESET}"
    fi
}

# ── Check Password ───────────────────────────────────────────
check_password() {
    local pass="$1"
    local score=0
    local -a suggestions=()

    echo -e "\n${BOLD}  📋 Checking Rules:${RESET}\n"

    # Rule 1 — Minimum length 8
    if (( ${#pass} >= 8 )); then
        pass_rule "Length ≥ 8 characters   (${#pass} chars)"
        (( score++ ))
    else
        fail_rule "Length ≥ 8 characters   (only ${#pass} chars)"
        suggestions+=("Use at least 8 characters")
    fi

    # Rule 2 — Recommended length 12+
    if (( ${#pass} >= 12 )); then
        pass_rule "Length ≥ 12 characters  (recommended)"
        (( score++ ))
    else
        fail_rule "Length ≥ 12 characters  (recommended)"
        suggestions+=("Use 12+ characters for stronger security")
    fi

    # Rule 3 — Uppercase letter
    if [[ "$pass" =~ [A-Z] ]]; then
        pass_rule "Contains uppercase letter (A–Z)"
        (( score++ ))
    else
        fail_rule "Contains uppercase letter (A–Z)"
        suggestions+=("Add at least one uppercase letter (A-Z)")
    fi

    # Rule 4 — Lowercase letter
    if [[ "$pass" =~ [a-z] ]]; then
        pass_rule "Contains lowercase letter (a–z)"
        (( score++ ))
    else
        fail_rule "Contains lowercase letter (a–z)"
        suggestions+=("Add at least one lowercase letter (a-z)")
    fi

    # Rule 5 — Digit
    if [[ "$pass" =~ [0-9] ]]; then
        pass_rule "Contains digit (0–9)"
        (( score++ ))
    else
        fail_rule "Contains digit (0–9)"
        suggestions+=("Add at least one digit (0-9)")
    fi

    # Rule 6 — Special character
    if [[ "$pass" =~ [^a-zA-Z0-9] ]]; then
        pass_rule "Contains special character (!@#\$%^&*...)"
        (( score++ ))
    else
        fail_rule "Contains special character (!@#\$%^&*...)"
        suggestions+=("Add a special character like !@#\$%^&*")
    fi

    # Rule 7 — No common passwords
    local common=("password" "123456" "password123" "admin" "letmein"
                  "qwerty" "abc123" "111111" "iloveyou" "welcome")
    local lower_pass="${pass,,}"
    local is_common=false
    for word in "${common[@]}"; do
        if [[ "$lower_pass" == "$word" ]]; then
            is_common=true
            break
        fi
    done

    if $is_common; then
        fail_rule "Not a commonly used password"
        suggestions+=("Avoid common passwords like 'password', '123456'")
    else
        pass_rule "Not a commonly used password"
        (( score++ ))
    fi

    # Rule 8 — No repeating characters (aaa, 111)
    if [[ "$pass" =~ (.)\1\1 ]]; then
        fail_rule "No 3+ repeating characters (e.g. aaa, 111)"
        suggestions+=("Avoid repeating the same character 3+ times")
    else
        pass_rule "No 3+ repeating characters"
        (( score++ ))
    fi

    # Rule 9 — No sequential patterns (abc, 123)
    if [[ "$pass" =~ (abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz|012|123|234|345|456|567|678|789) ]]; then
        fail_rule "No sequential patterns (abc, 123)"
        suggestions+=("Avoid sequential patterns like 'abc' or '123'")
    else
        pass_rule "No sequential patterns (abc, 123)"
        (( score++ ))
    fi

    # Rule 10 — Mix of character types (entropy check)
    local types=0
    [[ "$pass" =~ [A-Z] ]]       && (( types++ ))
    [[ "$pass" =~ [a-z] ]]       && (( types++ ))
    [[ "$pass" =~ [0-9] ]]       && (( types++ ))
    [[ "$pass" =~ [^a-zA-Z0-9] ]] && (( types++ ))

    if (( types >= 3 )); then
        pass_rule "Uses 3+ character types (good entropy)"
        (( score++ ))
    else
        fail_rule "Uses 3+ character types (good entropy)"
        suggestions+=("Mix uppercase, lowercase, digits, and symbols")
    fi

    # ── Result ───────────────────────────────────────────────
    echo -e "\n${BOLD}  📊 Score: ${score}/10${RESET}"
    echo -n "  "
    strength_bar $score

    echo ""
    if   (( score <= 3 )); then
        echo -e "  ${RED}${BOLD}💀 Strength: VERY WEAK${RESET}"
        echo -e "  ${RED}   This password is extremely easy to crack.${RESET}"
    elif (( score <= 5 )); then
        echo -e "  ${YELLOW}${BOLD}⚠️  Strength: WEAK${RESET}"
        echo -e "  ${YELLOW}   Vulnerable to brute-force attacks.${RESET}"
    elif (( score <= 7 )); then
        echo -e "  ${YELLOW}${BOLD}🔶 Strength: MODERATE${RESET}"
        echo -e "  ${YELLOW}   Acceptable but could be stronger.${RESET}"
    elif (( score <= 9 )); then
        echo -e "  ${GREEN}${BOLD}✅ Strength: STRONG${RESET}"
        echo -e "  ${GREEN}   Good password — hard to crack.${RESET}"
    else
        echo -e "  ${GREEN}${BOLD}🔒 Strength: VERY STRONG${RESET}"
        echo -e "  ${GREEN}   Excellent! Maximum protection.${RESET}"
    fi

    # ── Suggestions ──────────────────────────────────────────
    if (( ${#suggestions[@]} > 0 )); then
        echo -e "\n${BOLD}  💡 Suggestions to improve:${RESET}"
        for tip in "${suggestions[@]}"; do
            echo -e "  ${CYAN}→${RESET}  $tip"
        done
    fi

    echo ""
}

# ── Generate Strong Password ─────────────────────────────────
generate_password() {
    local length=${1:-16}
    local chars='A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?'
    local pass
    pass=$(tr -dc "$chars" < /dev/urandom | head -c "$length")
    echo -e "\n  ${GREEN}${BOLD}🎲 Generated Password (${length} chars):${RESET}"
    echo -e "  ${CYAN}${BOLD}  $pass${RESET}\n"
}

# ── Hide input while typing ───────────────────────────────────
read_password() {
    local prompt="$1"
    local pass=""
    local char=""

    echo -ne "${BOLD}${prompt}${RESET}"
    while IFS= read -r -s -n1 char; do
        if [[ -z "$char" ]]; then          # Enter key
            echo ""
            break
        elif [[ "$char" == $'\x7f' ]]; then # Backspace
            if (( ${#pass} > 0 )); then
                pass="${pass%?}"
                echo -ne "\b \b"
            fi
        else
            pass+="$char"
            echo -n "*"
        fi
    done
    REPLY="$pass"
}

# ── Main Menu ────────────────────────────────────────────────
main() {
    print_banner

    while true; do
        echo -e "${BOLD}  Choose an option:${RESET}"
        echo    "  1) Check password strength"
        echo    "  2) Check your own password (hidden input)"
        echo    "  3) Generate a strong password"
        echo    "  4) Exit"
        echo ""
        read -p "  Enter choice [1-4]: " choice
        echo ""

        case $choice in
            1)
                read -p "  Enter password to check: " user_pass
                if [[ -z "$user_pass" ]]; then
                    echo -e "  ${RED}Error: Password cannot be empty.${RESET}\n"
                else
                    check_password "$user_pass"
                fi
                ;;
            2)
                read_password "  Enter password (hidden): "
                if [[ -z "$REPLY" ]]; then
                    echo -e "  ${RED}Error: Password cannot be empty.${RESET}\n"
                else
                    check_password "$REPLY"
                fi
                ;;
            3)
                read -p "  Enter desired length (default 16): " len
                len=${len:-16}
                if ! [[ "$len" =~ ^[0-9]+$ ]] || (( len < 8 )); then
                    echo -e "  ${RED}Error: Length must be a number ≥ 8.${RESET}\n"
                else
                    generate_password "$len"
                fi
                ;;
            4)
                echo -e "  ${CYAN}Goodbye! Stay secure. 🔐${RESET}\n"
                exit 0
                ;;
            *)
                echo -e "  ${RED}Invalid choice. Please enter 1-4.${RESET}\n"
                ;;
        esac
    done
}

main