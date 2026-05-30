#!/usr/bin/env zsh

# logcheck.zsh — analyze any log file from the terminal
# usage: ./logcheck.zsh <logfile>
# usage: ./logcheck.zsh        (uses demo mode if no file given)

setopt NO_UNSET

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ─────────────────────────────────────
# helpers
# ─────────────────────────────────────

header() { print "\n${BOLD}${CYAN}  $1${RESET}"; print "  $(repeat ${#1} printf '-')"; }
ok()     { print "  ${GREEN}✔${RESET}  $1"; }
warn()   { print "  ${YELLOW}⚠${RESET}  $1"; }
err()    { print "  ${RED}✘${RESET}  $1"; }
info()   { print "  $1"; }

# ─────────────────────────────────────
# generate demo log if no file given
# ─────────────────────────────────────

make_demo_log() {
    local tmp=$(mktemp /tmp/demo_XXXX.log)
    local -a levels=(INFO INFO INFO WARNING ERROR INFO DEBUG INFO ERROR WARNING INFO INFO ERROR)
    local -a msgs=(
        "Server started on port 8080"
        "Request received from 192.168.1.10"
        "Database connection established"
        "High memory usage detected: 87%"
        "Failed to connect to cache server"
        "User alice logged in"
        "Cache miss for key user_session_42"
        "Request processed in 120ms"
        "Disk write error on /dev/sda1"
        "Response time exceeded threshold: 3200ms"
        "User bob logged out"
        "Scheduled backup completed"
        "Authentication failed for user admin"
    )

    for i in {1..50}; do
        local idx=$(( (RANDOM % $#levels) + 1 ))
        printf "2026-05-23 %02d:%02d:%02d [%s] %s\n" \
            $(( RANDOM % 24 )) $(( RANDOM % 60 )) $(( RANDOM % 60 )) \
            $levels[$idx] $msgs[$idx]
    done > $tmp

    print $tmp
}

# ─────────────────────────────────────
# summary stats
# ─────────────────────────────────────

show_summary() {
    local file=$1
    typeset -i total=0 errors=0 warnings=0 infos=0 debugs=0

    while IFS= read -r line; do
        (( total++ ))
        [[ $line == *ERROR* ]]   && (( errors++ ))
        [[ $line == *WARNING* ]] && (( warnings++ ))
        [[ $line == *INFO* ]]    && (( infos++ ))
        [[ $line == *DEBUG* ]]   && (( debugs++ ))
    done < "$file"

    header "Summary"
    info "File     : $file"
    info "Lines    : $total"
    ok   "INFO     : $infos"
    warn "WARNING  : $warnings"
    err  "ERROR    : $errors"
    info "DEBUG    : $debugs"
}

# ─────────────────────────────────────
# show error lines
# ─────────────────────────────────────

show_errors() {
    local file=$1
    typeset -i count=0

    header "Error Lines"

    while IFS= read -r line; do
        [[ $line != *ERROR* ]] && continue
        (( count++ ))
        print "  ${RED}[$count]${RESET} $line"
        (( count >= 10 )) && { warn "Showing first 10 only."; break; }
    done < "$file"

    (( count == 0 )) && ok "No errors found."
}

# ─────────────────────────────────────
# top repeated messages
# ─────────────────────────────────────

show_top_messages() {
    local file=$1
    typeset -A msg_count=()

    header "Top Repeated Messages (Top 5)"

    while IFS= read -r line; do
        # strip timestamp — keep from [ onward
        local msg="${line##*\] }"
        [[ -z $msg ]] && continue
        (( msg_count[$msg]++ ))
    done < "$file"

    # sort by count descending — collect into array
    typeset -a sorted=()
    for msg val in ${(kv)msg_count}; do
        sorted+=("$val $msg")
    done

    # bubble sort top 5 (small N — fine here)
    typeset -i n=$#sorted
    for (( i=1; i<n; i++ )); do
        for (( j=1; j<n-i+1; j++ )); do
            typeset -i a=${sorted[$j]%% *}
            typeset -i b=${sorted[$(( j+1 ))%% *]}
            if (( a < b )); then
                local tmp=$sorted[$j]
                sorted[$j]=$sorted[$(( j+1 ))]
                sorted[$(( j+1 ))]=$tmp
            fi
        done
    done

    typeset -i shown=0
    for entry in $sorted; do
        local count=${entry%% *}
        local msg="${entry#* }"
        printf "  ${YELLOW}%3dx${RESET}  %s\n" $count $msg
        (( ++shown >= 5 )) && break
    done
}

# ─────────────────────────────────────
# activity by hour
# ─────────────────────────────────────

show_hourly() {
    local file=$1
    typeset -A hours=()

    header "Activity by Hour"

    while IFS= read -r line; do
        # expect format: YYYY-MM-DD HH:MM:SS ...
        [[ $line =~ [0-9]{4}-[0-9]{2}-[0-9]{2}\ ([0-9]{2}):[0-9]{2}:[0-9]{2} ]] || continue
        local hr=$match[1]
        (( hours[$hr]++ ))
    done < "$file"

    for hr in ${(ko)hours}; do
        typeset -i c=$hours[$hr]
        local bar=""
        repeat $(( c / 2 + 1 )) bar+="█"
        printf "  %s:00  %-20s  %d\n" $hr $bar $c
    done
}

# ─────────────────────────────────────
# keyword search
# ─────────────────────────────────────

search_keyword() {
    local file=$1 keyword=$2
    typeset -i count=0

    header "Search: '$keyword'"

    while IFS= read -r line; do
        [[ $line != *$keyword* ]] && continue
        (( count++ ))
        print "  ${CYAN}$count${RESET}  $line"
    done < "$file"

    (( count == 0 )) && warn "No matches found for '$keyword'."
    (( count > 0  )) && ok "$count line(s) matched."
}

# ─────────────────────────────────────
# menu
# ─────────────────────────────────────

run_menu() {
    local file=$1

    while true; do
        print "\n${BOLD}  ┌──────────────────────────┐"
        print "  │     logcheck.zsh         │"
        print "  │  $file"
        print "  └──────────────────────────┘${RESET}"
        print "  1) Summary stats"
        print "  2) Show error lines"
        print "  3) Top repeated messages"
        print "  4) Activity by hour"
        print "  5) Search keyword"
        print "  6) Exit"
        print ""
        printf "  Choose [1-6]: "
        read -r choice

        case $choice in
            1) show_summary "$file" ;;
            2) show_errors "$file" ;;
            3) show_top_messages "$file" ;;
            4) show_hourly "$file" ;;
            5)
                printf "  Keyword: "
                read -r kw
                search_keyword "$file" "$kw"
                ;;
            6) print "\n  Bye!\n"; exit 0 ;;
            *) warn "Pick 1–6" ;;
        esac

        printf "\n  Press Enter to continue..."
        read -r
    done
}

# ─────────────────────────────────────
# entry point
# ─────────────────────────────────────

if [[ -n ${1:-} ]]; then
    if [[ ! -f $1 ]]; then
        err "File not found: $1"
        exit 1
    elif [[ ! -r $1 ]]; then
        err "Cannot read file: $1"
        exit 1
    fi
    LOGFILE=$1
else
    print "  No file given — generating demo log..."
    LOGFILE=$(make_demo_log)
    print "  Demo log: $LOGFILE"
fi

run_menu "$LOGFILE"