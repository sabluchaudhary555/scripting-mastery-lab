#!/usr/bin/env zsh
# procwatch.zsh — a simple process manager for the terminal
# Uses: ps pgrep pidof kill killall pkill nice nohup jobs fg bg disown
# Usage: ./procwatch.zsh

RED='\033[0;31m'    GREEN='\033[0;32m'
YELLOW='\033[1;33m' CYAN='\033[0;36m'
BOLD='\033[1m'      RESET='\033[0m'

header() { print "\n${BOLD}${CYAN}  $1${RESET}"; printf '  '; repeat ${#1} printf '-'; print ""; }
ok()     { print "  ${GREEN}✔${RESET}  $1"; }
warn()   { print "  ${YELLOW}⚠${RESET}  $1"; }
err()    { print "  ${RED}✘${RESET}  $1"; }
info()   { print "  $1"; }

# ─────────────────────────────
# 1. snapshot — top 10 cpu/mem
# ─────────────────────────────
snapshot() {
    header "Top 10 Processes by CPU"
    ps aux --sort=-%cpu 2>/dev/null | head -11 \
        | awk 'NR==1{printf "  %-10s %6s %6s %s\n","USER","CPU%","MEM%","COMMAND"}
               NR>1 {printf "  %-10s %6s %6s %s\n",$1,$3,$4,$11}'

    header "Top 10 Processes by Memory"
    ps aux --sort=-%mem 2>/dev/null | head -11 \
        | awk 'NR==1{printf "  %-10s %6s %6s %s\n","USER","CPU%","MEM%","COMMAND"}
               NR>1 {printf "  %-10s %6s %6s %s\n",$1,$3,$4,$11}'
}

# ─────────────────────────────
# 2. find process by name
# ─────────────────────────────
find_process() {
    header "Find Process"
    printf "  Process name: "
    read -r name
    [[ -z $name ]] && return

    local pids
    pids=$(pgrep -a "$name" 2>/dev/null)

    if [[ -z $pids ]]; then
        warn "No process found: '$name'"
    else
        ok "Found:"
        echo "$pids" | while IFS= read -r line; do
            local pid=${line%% *}
            local cmd=${line#* }
            local cpu mem
            cpu=$(ps -p $pid -o %cpu= 2>/dev/null | tr -d ' ')
            mem=$(ps -p $pid -o %mem= 2>/dev/null | tr -d ' ')
            printf "  ${CYAN}PID %-7s${RESET}  CPU:%-5s  MEM:%-5s  %s\n" "$pid" "$cpu%" "$mem%" "$cmd"
        done
    fi
}

# ─────────────────────────────
# 3. kill process
# ─────────────────────────────
kill_process() {
    header "Kill Process"
    print "  Signals:"
    print "    1) SIGTERM (15) — graceful shutdown (default)"
    print "    2) SIGKILL  (9) — force kill"
    print "    3) SIGHUP   (1) — reload config"
    print ""
    printf "  Signal [1-3]: "
    read -r sig_choice

    local sig
    case $sig_choice in
        1) sig=15 ;;
        2) sig=9  ;;
        3) sig=1  ;;
        *) sig=15 ;;
    esac

    printf "  PID or process name: "
    read -r target
    [[ -z $target ]] && return

    if [[ $target =~ ^[0-9]+$ ]]; then
        kill -$sig $target 2>/dev/null && ok "Sent signal $sig to PID $target" \
            || err "Failed — PID $target not found or no permission"
    else
        pkill -$sig "$target" 2>/dev/null && ok "Sent signal $sig to '$target'" \
            || err "No process named '$target' found"
    fi

    # check exit code — practice $?
    typeset -i code=$?
    (( code != 0 )) && info "Exit code: $code"
}

# ─────────────────────────────
# 4. run in background with nohup
# ─────────────────────────────
run_background() {
    header "Run Command in Background"
    printf "  Command to run: "
    read -r cmd
    [[ -z $cmd ]] && return

    printf "  Use nohup (survives terminal close)? [y/N]: "
    read -r use_nohup

    local logfile="/tmp/procwatch_bg_$(date +%s).log"

    if [[ $use_nohup == [yY] ]]; then
        nohup zsh -c "$cmd" >> "$logfile" 2>&1 &
        local pid=$!
        ok "Started with nohup — PID $pid"
    else
        zsh -c "$cmd" >> "$logfile" 2>&1 &
        local pid=$!
        ok "Started in background — PID $pid"
    fi

    info "Output → $logfile"
    info "Stop with: kill $pid"
}

# ─────────────────────────────
# 5. run with nice priority
# ─────────────────────────────
run_nice() {
    header "Run Command with Priority (nice)"
    info "Nice values: -20 (highest priority) to 19 (lowest)"
    info "Default is 0. Use high values for background tasks."
    print ""
    printf "  Nice value [-20 to 19]: "
    read -r niceval
    [[ ! $niceval =~ ^-?[0-9]+$ ]] && { err "Invalid nice value."; return; }

    printf "  Command: "
    read -r cmd
    [[ -z $cmd ]] && return

    nice -n $niceval zsh -c "$cmd" &
    local pid=$!
    ok "Running '$cmd' with nice=$niceval (PID $pid)"

    # show renice example
    info "To change priority later: renice $niceval -p $pid"
}

# ─────────────────────────────
# 6. job control demo
# ─────────────────────────────
job_demo() {
    header "Background Job Demo"
    info "Starting a background sleep job..."
    sleep 30 &
    local pid=$!
    ok "sleep 30 started (PID $pid)"
    print ""

    info "Current jobs:"
    jobs

    print ""
    printf "  Kill this demo job? [y/N]: "
    read -r confirm
    if [[ $confirm == [yY] ]]; then
        kill $pid 2>/dev/null && ok "Job $pid killed." || warn "Already done."
    else
        info "Job still running — use 'kill $pid' to stop it."
        disown $pid 2>/dev/null && info "Disowned — survives shell exit."
    fi
}

# ─────────────────────────────
# 7. process monitor (live, 5s)
# ─────────────────────────────
live_monitor() {
    header "Live Monitor (5 refreshes, Ctrl+C to stop)"

    trap 'print "\n  Stopped."; return' INT

    typeset -i i=0
    while (( i < 5 )); do
        (( i++ ))
        printf "\r\033[2J\033[H"   # clear screen
        print "  ${BOLD}Process Monitor — refresh $i/5${RESET}  ($(date +%T))"
        print ""
        ps aux --sort=-%cpu 2>/dev/null | head -8 \
            | awk 'NR==1{printf "  %-10s %6s %6s  %s\n","USER","CPU%","MEM%","COMMAND"}
                   NR>1 {printf "  %-10s %6s %6s  %s\n",$1,$3,$4,$11}'

        # $pipestatus — check each stage of last pipeline
        print ""
        info "Last pipeline status: $pipestatus"
        sleep 2
    done

    trap - INT
    ok "Monitor ended."
}

# ─────────────────────────────
# 8. subshell vs group demo
# ─────────────────────────────
subshell_demo() {
    header "Subshell ( ) vs Command Group { }"

    info "--- Subshell ( ) ---"
    info "Variable changes don't affect parent:"
    x=original
    ( x=changed; info "  Inside subshell: x=$x" )
    info "  After subshell : x=$x   ← unchanged"

    print ""
    info "--- Command Group { } ---"
    info "Variable changes DO affect parent:"
    y=original
    { y=changed; info "  Inside group: y=$y"; }
    info "  After group : y=$y   ← changed"

    print ""
    info "--- Exit codes with \$? ---"
    ls /nonexistent 2>/dev/null
    info "  ls /nonexistent exit code: $?"

    true
    info "  true exit code: $?"

    false
    info "  false exit code: $?"
}

# ─────────────────────────────
# menu
# ─────────────────────────────
while true; do
    print "\n${BOLD}  ┌─────────────────────────────┐"
    print "  │       procwatch.zsh         │"
    print "  └─────────────────────────────┘${RESET}"
    print "  1) Process snapshot (CPU/MEM)"
    print "  2) Find process by name"
    print "  3) Kill process (SIGTERM/SIGKILL/SIGHUP)"
    print "  4) Run command in background (nohup)"
    print "  5) Run with nice priority"
    print "  6) Job control demo"
    print "  7) Live process monitor (5s)"
    print "  8) Subshell vs command group demo"
    print "  9) Exit"
    print ""
    printf "  Choose [1-9]: "
    read -r choice

    case $choice in
        1) snapshot ;;
        2) find_process ;;
        3) kill_process ;;
        4) run_background ;;
        5) run_nice ;;
        6) job_demo ;;
        7) live_monitor ;;
        8) subshell_demo ;;
        9) print "\n  Bye!\n"; exit 0 ;;
        *) warn "Pick 1–9" ;;
    esac

    printf "\n  Press Enter to continue..."
    read -r
done