#!/usr/bin/env zsh

# validate.zsh — a handy input validator for daily use
# checks: username, email, IPv4, port, file path
# usage: ./validate.zsh

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

ok()   { print "${GREEN}  ✔  $1${RESET}"; }
err()  { print "${RED}  ✘  $1${RESET}"; }
info() { print "${CYAN}  →  $1${RESET}"; }
warn() { print "${YELLOW}  ⚠  $1${RESET}"; }

# ─────────────────────────────────────────
# validators
# ─────────────────────────────────────────

check_username() {
    local u=$1

    [[ -z $u ]] && { err "Username is empty"; return 1; }

    local len=${#u}
    (( len < 3 || len > 20 )) && {
        err "Must be 3–20 characters (got $len)"
        return 1
    }

    [[ ! $u =~ ^[a-zA-Z0-9_]+$ ]] && {
        err "Only letters, digits, and underscores allowed"
        return 1
    }

    ok "Valid username: $u"
}

check_email() {
    local e=$1

    [[ -z $e ]] && { err "Email is empty"; return 1; }

    if [[ $e =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        ok "Valid email: $e"
    else
        err "Invalid email format"
        return 1
    fi
}

check_ipv4() {
    local ip=$1

    [[ -z $ip ]] && { err "IP address is empty"; return 1; }

    if [[ $ip =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
        local valid=true
        for octet in $match[1] $match[2] $match[3] $match[4]; do
            (( octet > 255 )) && { valid=false; break; }
        done

        if [[ $valid == true ]]; then
            ok "Valid IPv4: $ip"
        else
            err "Octet out of range (each must be 0–255)"
            return 1
        fi
    else
        err "Doesn't match IPv4 format (x.x.x.x)"
        return 1
    fi
}

check_port() {
    local p=$1

    [[ -z $p ]] && { err "Port is empty"; return 1; }

    [[ ! $p =~ ^[0-9]+$ ]] && {
        err "Port must be a number"
        return 1
    }

    if (( p < 1 || p > 65535 )); then
        err "Port must be between 1 and 65535"
        return 1
    elif (( p < 1024 )); then
        warn "Port $p is privileged (requires root)"
    else
        ok "Valid port: $p"
    fi
}

check_file() {
    local f=$1

    [[ -z $f ]] && { err "Path is empty"; return 1; }

    if [[ ! -e $f ]]; then
        err "Does not exist: $f"
        return 1
    elif [[ -d $f ]]; then
        err "That's a directory, not a file"
        return 1
    elif [[ ! -f $f ]]; then
        err "Not a regular file"
        return 1
    elif [[ ! -r $f ]]; then
        err "File exists but is not readable"
        return 1
    fi

    local size lines
    size=$(du -sh "$f" 2>/dev/null | cut -f1)
    lines=$(wc -l < "$f")
    ok "Valid file: $f"
    info "Size: $size  |  Lines: $lines"
}

# ─────────────────────────────────────────
# menu
# ─────────────────────────────────────────

show_menu() {
    print ""
    print "  ┌─────────────────────────────┐"
    print "  │     Zsh Input Validator     │"
    print "  └─────────────────────────────┘"
    print "  1) Username"
    print "  2) Email address"
    print "  3) IPv4 address"
    print "  4) Port number"
    print "  5) File path"
    print "  6) Exit"
    print ""
}

run() {
    while true; do
        show_menu
        printf "  Choose [1-6]: "
        read -r choice

        case $choice in
            1)
                printf "\n  Username: "
                read -r val
                check_username "$val"
                ;;
            2)
                printf "\n  Email: "
                read -r val
                check_email "$val"
                ;;
            3)
                printf "\n  IPv4 address: "
                read -r val
                check_ipv4 "$val"
                ;;
            4)
                printf "\n  Port number: "
                read -r val
                check_port "$val"
                ;;
            5)
                printf "\n  File path: "
                read -r val
                check_file "$val"
                ;;
            6)
                print ""
                print "  Bye!"
                print ""
                exit 0
                ;;
            *)
                warn "Invalid choice, pick 1–6"
                ;;
        esac

        print ""
        printf "  Press Enter to continue..."
        read -r
    done
}

run