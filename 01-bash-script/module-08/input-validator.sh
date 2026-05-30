#!/bin/bash
# ============================================================
#  User Input Validator
#  Author  : scripting-mastery-lab
#  Version : 1.0
#  Usage   : ./input_validator.sh
#  Concepts: Regex [[ =~ ]], Conditionals, Functions, Arrays,
#            Loops, String ops, I/O Redirection, Pipes, Colors
# ============================================================

# ── ANSI Colors ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Log File Setup ───────────────────────────────────────────
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/validation_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

# ── Logging Helper ───────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ── Print Helpers ────────────────────────────────────────────
pass()    { echo -e "  ${GREEN}✔${RESET}  $1"; }
fail()    { echo -e "  ${RED}✗${RESET}  $1"; }
info()    { echo -e "  ${CYAN}ℹ${RESET}  $1"; }
warn()    { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
header()  { echo -e "\n${BOLD}${BLUE}  ── $1 ──${RESET}\n"; }

# ── Banner ───────────────────────────────────────────────────
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║       🛡️  User Input Validator  v1.0      ║"
    echo "  ║     Validate · Sanitize · Confirm        ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ════════════════════════════════════════════════════════════
#  VALIDATOR FUNCTIONS
# ════════════════════════════════════════════════════════════

# ── 1. Full Name ─────────────────────────────────────────────
validate_name() {
    local name="$1"
    local errors=0

    header "Full Name Validation"

    # Rule 1: Not empty
    if [[ -z "$name" ]]; then
        fail "Name cannot be empty"
        log "NAME FAIL: empty input"
        return 1
    fi

    # Rule 2: Only letters and spaces
    if [[ ! "$name" =~ ^[a-zA-Z[:space:]]+$ ]]; then
        fail "Only letters and spaces allowed (no digits or symbols)"
        (( errors++ ))
    else
        pass "Only letters and spaces"
    fi

    # Rule 3: Length 2–50
    local len=${#name}
    if (( len < 2 || len > 50 )); then
        fail "Length must be 2–50 characters (got $len)"
        (( errors++ ))
    else
        pass "Length is valid ($len characters)"
    fi

    # Rule 4: At least two words (first + last name)
    local word_count
    word_count=$(echo "$name" | wc -w)
    if (( word_count < 2 )); then
        warn "Consider entering full name (first + last)"
    else
        pass "Contains first and last name ($word_count words)"
    fi

    # Rule 5: No leading/trailing spaces
    if [[ "$name" =~ ^[[:space:]] || "$name" =~ [[:space:]]$ ]]; then
        fail "No leading or trailing spaces"
        (( errors++ ))
    else
        pass "No leading/trailing spaces"
    fi

    if (( errors == 0 )); then
        echo -e "\n  ${GREEN}${BOLD}✅ Name is VALID${RESET}"
        log "NAME PASS: '$name'"
    else
        echo -e "\n  ${RED}${BOLD}❌ Name has $errors error(s)${RESET}"
        log "NAME FAIL: '$name' — $errors error(s)"
    fi
    return $errors
}

# ── 2. Email Address ─────────────────────────────────────────
validate_email() {
    local email="$1"
    local errors=0

    header "Email Address Validation"

    if [[ -z "$email" ]]; then
        fail "Email cannot be empty"
        log "EMAIL FAIL: empty"
        return 1
    fi

    # Rule 1: Basic format check
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$ ]]; then
        fail "Invalid email format (expected: user@domain.com)"
        (( errors++ ))
    else
        pass "Valid email format"
    fi

    # Rule 2: No consecutive dots
    if [[ "$email" =~ \.\. ]]; then
        fail "No consecutive dots allowed (..) in email"
        (( errors++ ))
    else
        pass "No consecutive dots"
    fi

    # Rule 3: @ symbol exists exactly once
    local at_count
    at_count=$(grep -o "@" <<< "$email" | wc -l)
    if (( at_count != 1 )); then
        fail "Exactly one @ symbol required (found $at_count)"
        (( errors++ ))
    else
        pass "Exactly one @ symbol"
    fi

    # Rule 4: Domain part has at least one dot
    local domain="${email#*@}"
    if [[ ! "$domain" =~ \. ]]; then
        fail "Domain must contain a dot (e.g. gmail.com)"
        (( errors++ ))
    else
        pass "Domain has valid dot notation"
    fi

    # Rule 5: TLD length check (2–6 chars)
    local tld="${email##*.}"
    if (( ${#tld} < 2 || ${#tld} > 6 )); then
        fail "Top-level domain must be 2–6 chars (got: .$tld)"
        (( errors++ ))
    else
        pass "Valid TLD: .${tld}"
    fi

    # Extract parts for display
    local local_part="${email%@*}"
    info "Local part : $local_part"
    info "Domain     : $domain"

    if (( errors == 0 )); then
        echo -e "\n  ${GREEN}${BOLD}✅ Email is VALID${RESET}"
        log "EMAIL PASS: '$email'"
    else
        echo -e "\n  ${RED}${BOLD}❌ Email has $errors error(s)${RESET}"
        log "EMAIL FAIL: '$email' — $errors error(s)"
    fi
    return $errors
}

# ── 3. Phone Number ──────────────────────────────────────────
validate_phone() {
    local phone="$1"
    local errors=0

    header "Phone Number Validation"

    if [[ -z "$phone" ]]; then
        fail "Phone cannot be empty"
        log "PHONE FAIL: empty"
        return 1
    fi

    # Strip spaces and dashes for core check
    local stripped="${phone//[[:space:]-]/}"
    local stripped="${stripped//(/}"
    local stripped="${stripped//)/}"

    info "Stripped input: $stripped"

    # Rule 1: Only valid chars in original
    if [[ ! "$phone" =~ ^[0-9[:space:]\+\-\(\)]+$ ]]; then
        fail "Only digits, spaces, +, -, ( ) allowed"
        (( errors++ ))
    else
        pass "Valid characters only"
    fi

    # Rule 2: Stripped must be all digits
    if [[ ! "$stripped" =~ ^[0-9]+$ ]]; then
        fail "Phone must contain only numeric digits (after stripping)"
        (( errors++ ))
    else
        pass "Digits only after stripping formatting"
    fi

    # Rule 3: Length check 7–15 digits (ITU-T E.164 standard)
    local dlen=${#stripped}
    if (( dlen < 7 || dlen > 15 )); then
        fail "Must be 7–15 digits long (got $dlen)"
        (( errors++ ))
    else
        pass "Valid length: $dlen digits"
    fi

    # Rule 4: Indian mobile check (10 digits starting 6-9)
    if (( dlen == 10 )); then
        if [[ "$stripped" =~ ^[6-9][0-9]{9}$ ]]; then
            pass "Valid Indian mobile number format (starts with ${stripped:0:1})"
        else
            warn "10-digit number but doesn't match Indian mobile format (6–9 start)"
        fi
    fi

    # Rule 5: International format check
    if [[ "$phone" =~ ^\+ ]]; then
        pass "International format detected (+country code)"
        info "Country code: +${stripped:0:2}"
    fi

    if (( errors == 0 )); then
        echo -e "\n  ${GREEN}${BOLD}✅ Phone is VALID${RESET}"
        log "PHONE PASS: '$phone'"
    else
        echo -e "\n  ${RED}${BOLD}❌ Phone has $errors error(s)${RESET}"
        log "PHONE FAIL: '$phone' — $errors error(s)"
    fi
    return $errors
}

# ── 4. IPv4 Address ──────────────────────────────────────────
validate_ip() {
    local ip="$1"
    local errors=0

    header "IPv4 Address Validation"

    if [[ -z "$ip" ]]; then
        fail "IP cannot be empty"
        log "IP FAIL: empty"
        return 1
    fi

    # Rule 1: Basic format (4 groups of digits separated by dots)
    if [[ ! "$ip" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
        fail "Invalid format (expected: x.x.x.x where x = 0–255)"
        log "IP FAIL: '$ip' — bad format"
        return 1
    else
        pass "Format matches x.x.x.x pattern"
    fi

    # Rule 2: Each octet must be 0–255
    IFS='.' read -ra octets <<< "$ip"
    local octet_errors=0
    for i in "${!octets[@]}"; do
        local oct="${octets[$i]}"
        if (( oct < 0 || oct > 255 )); then
            fail "Octet $((i+1)) out of range: $oct (must be 0–255)"
            (( errors++ ))
            (( octet_errors++ ))
        fi
    done
    (( octet_errors == 0 )) && pass "All 4 octets in range (0–255)"

    # Rule 3: No leading zeros (e.g. 192.168.01.1 is invalid)
    for oct in "${octets[@]}"; do
        if [[ "$oct" =~ ^0[0-9]+ ]]; then
            fail "Leading zeros not allowed (e.g. 01, 007)"
            (( errors++ ))
            break
        fi
    done
    [[ ! "$ip" =~ \b0[0-9] ]] && pass "No leading zeros in octets"

    # Rule 4: Classify the IP type
    local first="${octets[0]}"
    if (( first == 10 )) || \
       ( (( first == 172 )) && (( octets[1] >= 16 && octets[1] <= 31 )) ) || \
       ( (( first == 192 )) && (( octets[1] == 168 )) ); then
        info "Type: 🏠 Private IP address"
    elif (( first == 127 )); then
        info "Type: 🔄 Loopback address (localhost)"
    elif (( first == 0 )); then
        warn "0.x.x.x is reserved"
    elif (( first >= 224 && first <= 239 )); then
        info "Type: 📡 Multicast address"
    elif (( first >= 240 )); then
        warn "240+ is reserved/experimental"
    else
        info "Type: 🌐 Public IP address"
    fi

    if (( errors == 0 )); then
        echo -e "\n  ${GREEN}${BOLD}✅ IP Address is VALID${RESET}"
        log "IP PASS: '$ip'"
    else
        echo -e "\n  ${RED}${BOLD}❌ IP has $errors error(s)${RESET}"
        log "IP FAIL: '$ip' — $errors error(s)"
    fi
    return $errors
}

# ── 5. Username ──────────────────────────────────────────────
validate_username() {
    local uname="$1"
    local errors=0

    header "Username Validation"

    if [[ -z "$uname" ]]; then
        fail "Username cannot be empty"
        log "USERNAME FAIL: empty"
        return 1
    fi

    # Rule 1: Allowed chars (letters, digits, underscore, hyphen)
    if [[ ! "$uname" =~ ^[a-zA-Z0-9_\-]+$ ]]; then
        fail "Only letters, digits, _ and - allowed"
        (( errors++ ))
    else
        pass "Valid characters (a-z, A-Z, 0-9, _, -)"
    fi

    # Rule 2: Must start with a letter
    if [[ ! "$uname" =~ ^[a-zA-Z] ]]; then
        fail "Must start with a letter (not digit or symbol)"
        (( errors++ ))
    else
        pass "Starts with a letter"
    fi

    # Rule 3: Length 3–20
    local len=${#uname}
    if (( len < 3 || len > 20 )); then
        fail "Length must be 3–20 characters (got $len)"
        (( errors++ ))
    else
        pass "Valid length: $len characters"
    fi

    # Rule 4: No consecutive special chars (-- or __)
    if [[ "$uname" =~ --|__ ]]; then
        fail "No consecutive dashes (--) or underscores (__)"
        (( errors++ ))
    else
        pass "No consecutive special characters"
    fi

    # Rule 5: Cannot end with special char
    if [[ "$uname" =~ [_\-]$ ]]; then
        fail "Cannot end with _ or -"
        (( errors++ ))
    else
        pass "Does not end with special character"
    fi

    # Info
    info "Username: $uname  (${#uname} chars)"
    local lower="${uname,,}"
    info "Lowercase form: $lower"

    if (( errors == 0 )); then
        echo -e "\n  ${GREEN}${BOLD}✅ Username is VALID${RESET}"
        log "USERNAME PASS: '$uname'"
    else
        echo -e "\n  ${RED}${BOLD}❌ Username has $errors error(s)${RESET}"
        log "USERNAME FAIL: '$uname' — $errors error(s)"
    fi
    return $errors
}

# ── 6. Date (YYYY-MM-DD) ─────────────────────────────────────
validate_date() {
    local date_str="$1"
    local errors=0

    header "Date Validation (YYYY-MM-DD)"

    if [[ -z "$date_str" ]]; then
        fail "Date cannot be empty"
        log "DATE FAIL: empty"
        return 1
    fi

    # Rule 1: Format check
    if [[ ! "$date_str" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
        fail "Invalid format (expected: YYYY-MM-DD)"
        log "DATE FAIL: '$date_str' — bad format"
        return 1
    else
        pass "Format matches YYYY-MM-DD"
    fi

    # Extract parts via BASH_REMATCH
    local year="${BASH_REMATCH[1]}"
    local month="${BASH_REMATCH[2]}"
    local day="${BASH_REMATCH[3]}"

    info "Year: $year  Month: $month  Day: $day"

    # Rule 2: Year range
    local current_year
    current_year=$(date +%Y)
    if (( year < 1900 || year > current_year + 10 )); then
        fail "Year out of reasonable range (1900–$((current_year+10)))"
        (( errors++ ))
    else
        pass "Year in valid range: $year"
    fi

    # Rule 3: Month 01–12
    if (( 10#$month < 1 || 10#$month > 12 )); then
        fail "Month must be 01–12 (got $month)"
        (( errors++ ))
    else
        pass "Month valid: $month"
    fi

    # Rule 4: Day range based on month
    local max_day=31
    case $((10#$month)) in
        4|6|9|11) max_day=30 ;;
        2)
            # Leap year check
            if (( year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) )); then
                max_day=29
                info "Leap year: $year ✓"
            else
                max_day=28
            fi
            ;;
    esac

    if (( 10#$day < 1 || 10#$day > max_day )); then
        fail "Day out of range for month $month (must be 01–$max_day)"
        (( errors++ ))
    else
        pass "Day valid: $day (max for this month: $max_day)"
    fi

    # Rule 5: Past or future
    local today
    today=$(date +%Y-%m-%d)
    if [[ "$date_str" < "$today" ]]; then
        info "📅 This date is in the past"
    elif [[ "$date_str" == "$today" ]]; then
        info "📅 This is today's date"
    else
        info "📅 This date is in the future"
    fi

    if (( errors == 0 )); then
        echo -e "\n  ${GREEN}${BOLD}✅ Date is VALID${RESET}"
        log "DATE PASS: '$date_str'"
    else
        echo -e "\n  ${RED}${BOLD}❌ Date has $errors error(s)${RESET}"
        log "DATE FAIL: '$date_str' — $errors error(s)"
    fi
    return $errors
}

# ── 7. URL ───────────────────────────────────────────────────
validate_url() {
    local url="$1"
    local errors=0

    header "URL Validation"

    if [[ -z "$url" ]]; then
        fail "URL cannot be empty"
        log "URL FAIL: empty"
        return 1
    fi

    # Rule 1: Must start with http:// or https://
    if [[ ! "$url" =~ ^https?:// ]]; then
        fail "Must start with http:// or https://"
        (( errors++ ))
    else
        pass "Valid scheme: $(echo "$url" | grep -oP '^https?')"
    fi

    # Rule 2: Full format validation
    if [[ ! "$url" =~ ^https?://[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+(/.*)?$ ]]; then
        fail "URL format is invalid"
        (( errors++ ))
    else
        pass "URL format is valid"
    fi

    # Rule 3: No spaces
    if [[ "$url" =~ [[:space:]] ]]; then
        fail "URLs cannot contain spaces"
        (( errors++ ))
    else
        pass "No spaces in URL"
    fi

    # Extract and display parts
    local scheme="${url%%://*}"
    local rest="${url#*://}"
    local host="${rest%%/*}"
    local path="/${rest#*/}"
    [[ "$path" == "/$host" ]] && path="/"

    info "Scheme : $scheme"
    info "Host   : $host"
    info "Path   : $path"

    # Rule 4: HTTPS is preferred
    if [[ "$scheme" == "http" ]]; then
        warn "Consider using HTTPS for security"
    else
        pass "Uses secure HTTPS ✓"
    fi

    if (( errors == 0 )); then
        echo -e "\n  ${GREEN}${BOLD}✅ URL is VALID${RESET}"
        log "URL PASS: '$url'"
    else
        echo -e "\n  ${RED}${BOLD}❌ URL has $errors error(s)${RESET}"
        log "URL FAIL: '$url' — $errors error(s)"
    fi
    return $errors
}

# ════════════════════════════════════════════════════════════
#  BULK VALIDATION FROM FILE
# ════════════════════════════════════════════════════════════
validate_from_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo -e "  ${RED}Error: File not found: $file${RESET}"
        return 1
    fi

    echo -e "\n${BOLD}${MAGENTA}  📂 Bulk Validation from: $file${RESET}"
    echo -e "  ${DIM}Format: type,value  (e.g. email,user@example.com)${RESET}\n"

    local pass_count=0
    local fail_count=0
    local line_num=0

    while IFS=',' read -r type value; do
        (( line_num++ ))
        # Skip empty lines and comments
        [[ -z "$type" || "$type" =~ ^# ]] && continue

        echo -e "  ${DIM}Line $line_num: [$type] → $value${RESET}"

        case "${type,,}" in
            name)     validate_name     "$value" &>/dev/null && (( pass_count++ )) || (( fail_count++ )) ;;
            email)    validate_email    "$value" &>/dev/null && (( pass_count++ )) || (( fail_count++ )) ;;
            phone)    validate_phone    "$value" &>/dev/null && (( pass_count++ )) || (( fail_count++ )) ;;
            ip)       validate_ip       "$value" &>/dev/null && (( pass_count++ )) || (( fail_count++ )) ;;
            username) validate_username "$value" &>/dev/null && (( pass_count++ )) || (( fail_count++ )) ;;
            date)     validate_date     "$value" &>/dev/null && (( pass_count++ )) || (( fail_count++ )) ;;
            url)      validate_url      "$value" &>/dev/null && (( pass_count++ )) || (( fail_count++ )) ;;
            *)        warn "Unknown type: $type (skip)" ;;
        esac

    done < "$file"

    echo ""
    echo -e "  ${GREEN}${BOLD}✔ Passed: $pass_count${RESET}"
    echo -e "  ${RED}${BOLD}✗ Failed: $fail_count${RESET}"
    echo -e "  ${DIM}Full log saved to: $LOG_FILE${RESET}\n"
    log "BULK: pass=$pass_count fail=$fail_count file=$file"
}

# ════════════════════════════════════════════════════════════
#  VIEW LOG
# ════════════════════════════════════════════════════════════
view_log() {
    echo -e "\n${BOLD}${MAGENTA}  📋 Validation Log — $LOG_FILE${RESET}\n"
    if [[ -f "$LOG_FILE" ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ PASS ]]; then
                echo -e "  ${GREEN}$line${RESET}"
            elif [[ "$line" =~ FAIL ]]; then
                echo -e "  ${RED}$line${RESET}"
            else
                echo -e "  ${DIM}$line${RESET}"
            fi
        done < "$LOG_FILE"
    else
        echo -e "  ${DIM}No log entries yet.${RESET}"
    fi
    echo ""
}

# ════════════════════════════════════════════════════════════
#  MAIN INTERACTIVE MENU
# ════════════════════════════════════════════════════════════
main() {
    print_banner
    log "=== Session started ==="

    while true; do
        echo -e "${BOLD}  What would you like to validate?${RESET}"
        echo ""
        echo    "  1)  Full Name"
        echo    "  2)  Email Address"
        echo    "  3)  Phone Number"
        echo    "  4)  IPv4 Address"
        echo    "  5)  Username"
        echo    "  6)  Date (YYYY-MM-DD)"
        echo    "  7)  URL"
        echo    "  8)  📂 Bulk validate from file"
        echo    "  9)  📋 View session log"
        echo    "  10) Exit"
        echo ""
        read -p "  Enter choice [1-10]: " choice
        echo ""

        case $choice in
            1)
                read -p "  Enter full name: " input
                validate_name "$input"
                ;;
            2)
                read -p "  Enter email: " input
                validate_email "$input"
                ;;
            3)
                read -p "  Enter phone number: " input
                validate_phone "$input"
                ;;
            4)
                read -p "  Enter IPv4 address: " input
                validate_ip "$input"
                ;;
            5)
                read -p "  Enter username: " input
                validate_username "$input"
                ;;
            6)
                read -p "  Enter date (YYYY-MM-DD): " input
                validate_date "$input"
                ;;
            7)
                read -p "  Enter URL: " input
                validate_url "$input"
                ;;
            8)
                read -p "  Enter path to CSV file: " input
                validate_from_file "$input"
                ;;
            9)
                view_log
                ;;
            10)
                echo -e "  ${CYAN}${BOLD}Goodbye! Stay validated. 🛡️${RESET}\n"
                echo -e "  ${DIM}Session log: $LOG_FILE${RESET}\n"
                log "=== Session ended ==="
                exit 0
                ;;
            *)
                echo -e "  ${RED}Invalid choice. Please enter 1–10.${RESET}\n"
                ;;
        esac

        echo ""
        read -p "  Press Enter to continue..." _
        echo ""
    done
}

main