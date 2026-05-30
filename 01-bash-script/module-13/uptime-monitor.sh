#!/bin/bash
# ============================================================
#  Project 1 — Website Uptime Monitor
#  Module 13 — Networking & Remote Operations
#
#  Features:
#   - curl + ping based health checks
#   - HTTP status code validation
#   - Response time tracking
#   - Email alerts on downtime / recovery
#   - Webhook alerts (Slack / Discord)
#   - Multi-site monitoring from config file
#   - Consecutive failure threshold
#   - Structured colored logging
#   - Cron-ready / daemon mode
#   - JSON status report with jq
# ============================================================

set -euo pipefail
IFS=$'\n\t'

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# ============================================================
#  CONFIGURATION
# ============================================================
SITES_FILE="${SITES_FILE:-$(dirname "$0")/sites.txt}"  # list of URLs
CHECK_INTERVAL="${CHECK_INTERVAL:-60}"                  # seconds between checks
TIMEOUT="${TIMEOUT:-10}"                                # curl timeout seconds
FAIL_THRESHOLD="${FAIL_THRESHOLD:-2}"                   # failures before alert
LOG_FILE="${LOG_FILE:-/tmp/uptime_monitor.log}"
STATUS_FILE="${STATUS_FILE:-/tmp/uptime_status.json}"   # live status JSON
ALERT_EMAIL="${ALERT_EMAIL:-}"                          # email for alerts
WEBHOOK_URL="${WEBHOOK_URL:-}"                          # Slack/Discord webhook
DAEMON_MODE="${DAEMON_MODE:-false}"                     # loop forever
DEBUG="${DEBUG:-false}"                                 # bash -x trace
DRY_RUN="${DRY_RUN:-false}"                            # no alerts sent

# Expected HTTP code (comma-separated)
EXPECTED_CODES="${EXPECTED_CODES:-200,201,301,302}"

# ============================================================
#  COLORS
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ============================================================
#  GLOBALS
# ============================================================
SCRIPT_NAME="$(basename "$0")"
declare -A FAIL_COUNT    # track consecutive failures per site
declare -A SITE_STATUS   # track current status per site (UP/DOWN)
TOTAL_CHECKS=0
TOTAL_UP=0
TOTAL_DOWN=0

# ============================================================
#  LOGGING
# ============================================================
_log() {
    local color="$1" level="$2"
    shift 2
    local msg="$*"
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    local line="[$ts] [$level] $msg"
    echo -e "${color}${line}${RESET}"
    echo "$line" >> "$LOG_FILE"
}

log_info()    { _log "$GREEN"       "INFO " "$@"; }
log_warn()    { _log "$YELLOW"      "WARN " "$@" >&2; }
log_error()   { _log "$RED"         "ERROR" "$@" >&2; }
log_debug()   { [[ "$DEBUG" == "true" ]] && _log "$CYAN" "DEBUG" "$@" || true; }
log_up()      { _log "$BOLD$GREEN"  " UP  " "$@"; }
log_down()    { _log "$BOLD$RED"    "DOWN " "$@" >&2; }

die() { log_error "$1"; exit "${2:-1}"; }

# ============================================================
#  TRAP
# ============================================================
on_exit() {
    local code=$?
    log_info "Monitor stopped (exit: $code) | checks: $TOTAL_CHECKS up: $TOTAL_UP down: $TOTAL_DOWN"
}
trap on_exit EXIT
trap 'log_warn "Interrupted — stopping monitor"; exit 0' INT TERM

# ============================================================
#  VALIDATE ENVIRONMENT
# ============================================================
validate() {
    log_info "Validating environment..."

    # curl is required
    command -v curl &>/dev/null || die "curl is required but not installed"

    # jq is optional but recommended
    command -v jq &>/dev/null || log_warn "jq not found — JSON report will be skipped"

    # sites file
    [[ -f "$SITES_FILE" ]] || die "Sites file not found: $SITES_FILE
Create it with one URL per line, e.g:
  https://google.com
  https://github.com
  https://yoursite.com"

    # remove blank lines and comments from sites file
    local count
    count=$(grep -v '^\s*#' "$SITES_FILE" | grep -v '^\s*$' | wc -l)
    [[ "$count" -gt 0 ]] || die "No valid URLs found in $SITES_FILE"

    log_info "Found $count site(s) to monitor"
    log_info "Validation passed ✅"
}

# ============================================================
#  CHECK SINGLE SITE
# ============================================================
check_site() {
    local url="$1"
    local result status_code response_time is_up

    log_debug "Checking: $url"

    # curl: get HTTP status code + response time
    # -s silent, -o discard body, -w write info, --max-time timeout
    result=$(curl \
        --silent \
        --output /dev/null \
        --max-time "$TIMEOUT" \
        --connect-timeout 5 \
        --write-out "%{http_code} %{time_total}" \
        --location \
        "$url" 2>/dev/null) || result="000 0"

    status_code=$(echo "$result" | awk '{print $1}')
    response_time=$(echo "$result" | awk '{printf "%.2f", $2}')

    log_debug "  HTTP: $status_code | Time: ${response_time}s"

    # check if status code is in expected list
    is_up=false
    IFS=',' read -ra expected <<< "$EXPECTED_CODES"
    for code in "${expected[@]}"; do
        if [[ "$status_code" == "$code" ]]; then
            is_up=true
            break
        fi
    done

    # return values via echo (caller captures)
    echo "$status_code $response_time $is_up"
}

# ============================================================
#  SEND EMAIL ALERT
# ============================================================
send_email() {
    local subject="$1"
    local body="$2"

    [[ -z "$ALERT_EMAIL" ]] && { log_debug "No email configured — skipping"; return 0; }
    $DRY_RUN && { log_warn "[DRY-RUN] Would email: $subject → $ALERT_EMAIL"; return 0; }

    if command -v mail &>/dev/null; then
        echo "$body" | mail -s "$subject" "$ALERT_EMAIL"
        log_info "Email sent to $ALERT_EMAIL: $subject"
    else
        log_warn "mail command not found — cannot send email alert"
    fi
}

# ============================================================
#  SEND WEBHOOK ALERT (Slack / Discord)
# ============================================================
send_webhook() {
    local message="$1"
    local color="${2:-danger}"   # good | warning | danger

    [[ -z "$WEBHOOK_URL" ]] && { log_debug "No webhook configured — skipping"; return 0; }
    $DRY_RUN && { log_warn "[DRY-RUN] Would POST webhook: $message"; return 0; }

    # Slack-compatible payload
    local payload
    payload=$(printf '{"attachments":[{"color":"%s","text":"%s","footer":"Uptime Monitor | %s"}]}' \
        "$color" \
        "$message" \
        "$(date '+%Y-%m-%d %H:%M:%S')")

    local http_code
    http_code=$(curl \
        --silent \
        --output /dev/null \
        --write-out "%{http_code}" \
        --max-time 10 \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$WEBHOOK_URL" 2>/dev/null) || http_code="000"

    if [[ "$http_code" == "200" || "$http_code" == "204" ]]; then
        log_info "Webhook alert sent (HTTP $http_code)"
    else
        log_warn "Webhook failed (HTTP $http_code)"
    fi
}

# ============================================================
#  HANDLE SITE DOWN
# ============================================================
handle_down() {
    local url="$1"
    local status_code="$2"
    local response_time="$3"

    FAIL_COUNT["$url"]=$(( ${FAIL_COUNT["$url"]:-0} + 1 ))
    local fails=${FAIL_COUNT["$url"]}

    log_down "$url | HTTP $status_code | ${response_time}s | fails: $fails/$FAIL_THRESHOLD"
    (( TOTAL_DOWN++ ))

    # only alert when threshold is first hit (not every check)
    if (( fails == FAIL_THRESHOLD )); then
        local msg="🔴 DOWN: $url | HTTP $status_code | failed $fails consecutive checks"
        log_error "ALERT TRIGGERED: $url is DOWN"

        send_email "🔴 ALERT: $url is DOWN" \
"Site is DOWN!

URL         : $url
HTTP Code   : $status_code
Response    : ${response_time}s
Fails       : $fails consecutive
Time        : $(date)
Log         : $LOG_FILE"

        send_webhook "$msg" "danger"
        SITE_STATUS["$url"]="DOWN"
    fi
}

# ============================================================
#  HANDLE SITE UP
# ============================================================
handle_up() {
    local url="$1"
    local status_code="$2"
    local response_time="$3"
    local prev_status="${SITE_STATUS["$url"]:-UP}"
    local prev_fails="${FAIL_COUNT["$url"]:-0}"

    # reset fail counter
    FAIL_COUNT["$url"]=0
    SITE_STATUS["$url"]="UP"

    log_up "$url | HTTP $status_code | ${response_time}s"
    (( TOTAL_UP++ ))

    # send recovery alert only if site was previously DOWN
    if [[ "$prev_status" == "DOWN" ]]; then
        local msg="🟢 RECOVERED: $url | HTTP $status_code | was down for $prev_fails checks"
        log_info "RECOVERY: $url is back UP"

        send_email "🟢 RECOVERED: $url is back UP" \
"Site has RECOVERED!

URL         : $url
HTTP Code   : $status_code
Response    : ${response_time}s
Was down for: $prev_fails checks
Time        : $(date)"

        send_webhook "$msg" "good"
    fi
}

# ============================================================
#  GENERATE JSON STATUS REPORT
# ============================================================
generate_status_report() {
    command -v jq &>/dev/null || return 0

    log_debug "Generating JSON status report..."

    local sites_json="["
    local first=true

    while IFS= read -r url; do
        [[ "$url" =~ ^\s*# ]] && continue
        [[ -z "${url// }" ]]   && continue

        local status="${SITE_STATUS["$url"]:-UNKNOWN}"
        local fails="${FAIL_COUNT["$url"]:-0}"

        $first || sites_json+=","
        sites_json+=$(printf '{"url":"%s","status":"%s","consecutive_fails":%d}' \
            "$url" "$status" "$fails")
        first=false
    done < "$SITES_FILE"

    sites_json+="]"

    # build full report
    local report
    report=$(jq -n \
        --argjson sites "$sites_json" \
        --arg ts "$(date '+%Y-%m-%d %H:%M:%S')" \
        --argjson total "$TOTAL_CHECKS" \
        --argjson up "$TOTAL_UP" \
        --argjson down "$TOTAL_DOWN" \
        '{
            generated_at: $ts,
            summary: {
                total_checks: $total,
                up: $up,
                down: $down
            },
            sites: $sites
        }')

    echo "$report" > "$STATUS_FILE"
    log_debug "Status report saved: $STATUS_FILE"
}

# ============================================================
#  RUN ONE FULL CHECK CYCLE
# ============================================================
run_check_cycle() {
    local cycle_start; cycle_start=$(date +%s)
    local sites_checked=0

    echo ""
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Check cycle started at $(date '+%H:%M:%S')"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    while IFS= read -r url; do
        # skip comments and blank lines
        [[ "$url" =~ ^\s*# ]] && continue
        [[ -z "${url// }" ]]   && continue

        # initialize tracking for new sites
        FAIL_COUNT["$url"]="${FAIL_COUNT["$url"]:-0}"
        SITE_STATUS["$url"]="${SITE_STATUS["$url"]:-UP}"

        # check the site
        local result
        result=$(check_site "$url")
        local status_code response_time is_up
        status_code=$(echo  "$result" | awk '{print $1}')
        response_time=$(echo "$result" | awk '{print $2}')
        is_up=$(echo        "$result" | awk '{print $3}')

        (( TOTAL_CHECKS++ ))
        (( sites_checked++ ))

        if [[ "$is_up" == "true" ]]; then
            handle_up   "$url" "$status_code" "$response_time"
        else
            handle_down "$url" "$status_code" "$response_time"
        fi

    done < "$SITES_FILE"

    local elapsed=$(( $(date +%s) - cycle_start ))
    log_info "Cycle complete | $sites_checked sites | ${elapsed}s elapsed"

    generate_status_report
}

# ============================================================
#  SHOW LIVE STATUS SUMMARY
# ============================================================
print_summary() {
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}  📡 UPTIME MONITOR SUMMARY${RESET}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    while IFS= read -r url; do
        [[ "$url" =~ ^\s*# ]] && continue
        [[ -z "${url// }" ]]   && continue

        local status="${SITE_STATUS["$url"]:-UNKNOWN}"
        local fails="${FAIL_COUNT["$url"]:-0}"

        if [[ "$status" == "UP" ]]; then
            echo -e "  ${GREEN}✅ UP  ${RESET} $url"
        else
            echo -e "  ${RED}❌ DOWN${RESET} $url ${YELLOW}(fails: $fails)${RESET}"
        fi
    done < "$SITES_FILE"

    echo ""
    echo -e "  Total checks : $TOTAL_CHECKS"
    echo -e "  Up responses : ${GREEN}$TOTAL_UP${RESET}"
    echo -e "  Down alerts  : ${RED}$TOTAL_DOWN${RESET}"
    echo -e "  Log file     : $LOG_FILE"
    [[ -f "$STATUS_FILE" ]] && \
    echo -e "  JSON status  : $STATUS_FILE"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# ============================================================
#  USAGE
# ============================================================
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -f FILE      Sites file (default: ./sites.txt)
  -i N         Check interval in seconds (default: 60)
  -t N         HTTP timeout seconds (default: 10)
  -T N         Failure threshold before alert (default: 2)
  -e EMAIL     Alert email address
  -w URL       Slack/Discord webhook URL
  -l FILE      Log file (default: /tmp/uptime_monitor.log)
  --daemon     Run forever (loop mode)
  --dry-run    Simulate alerts without sending
  --debug      Enable bash -x trace
  -h           Show this help

Environment Variables:
  SITES_FILE, CHECK_INTERVAL, TIMEOUT, FAIL_THRESHOLD
  ALERT_EMAIL, WEBHOOK_URL, LOG_FILE, DAEMON_MODE, DEBUG

Examples:
  $SCRIPT_NAME                              # single check of sites.txt
  $SCRIPT_NAME --daemon                     # monitor forever
  $SCRIPT_NAME --daemon -i 30 -T 3         # check every 30s, alert after 3 fails
  $SCRIPT_NAME -e admin@example.com         # with email alerts
  $SCRIPT_NAME -w https://hooks.slack.com/… # with Slack alerts
  ALERT_EMAIL=me@email.com $SCRIPT_NAME --daemon
  DEBUG=true $SCRIPT_NAME 2>trace.log

sites.txt format:
  https://google.com
  https://github.com
  # this is a comment
  https://yoursite.com
EOF
    exit 0
}

# ============================================================
#  PARSE ARGUMENTS
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f)        SITES_FILE="$2";      shift 2 ;;
            -i)        CHECK_INTERVAL="$2";  shift 2 ;;
            -t)        TIMEOUT="$2";         shift 2 ;;
            -T)        FAIL_THRESHOLD="$2";  shift 2 ;;
            -e)        ALERT_EMAIL="$2";     shift 2 ;;
            -w)        WEBHOOK_URL="$2";     shift 2 ;;
            -l)        LOG_FILE="$2";        shift 2 ;;
            --daemon)  DAEMON_MODE=true;     shift ;;
            --dry-run) DRY_RUN=true;         shift ;;
            --debug)   DEBUG=true;           shift ;;
            -h|--help) usage ;;
            *)         die "Unknown option: $1" 2 ;;
        esac
    done

    [[ "$DEBUG" == "true" ]] && set -x
}

# ============================================================
#  MAIN
# ============================================================
main() {
    parse_args "$@"

    mkdir -p "$(dirname "$LOG_FILE")"

    log_info "════════════════════════════════════════"
    log_info " Website Uptime Monitor"
    log_info " Sites     : $SITES_FILE"
    log_info " Interval  : ${CHECK_INTERVAL}s"
    log_info " Threshold : $FAIL_THRESHOLD fails"
    log_info " Daemon    : $DAEMON_MODE"
    log_info " Email     : ${ALERT_EMAIL:-none}"
    log_info " Webhook   : ${WEBHOOK_URL:+configured}"
    log_info "════════════════════════════════════════"

    validate

    if $DAEMON_MODE; then
        log_info "Running in daemon mode (Ctrl+C to stop)"
        while true; do
            run_check_cycle
            log_info "Next check in ${CHECK_INTERVAL}s..."
            sleep "$CHECK_INTERVAL"
        done
    else
        run_check_cycle
        print_summary
    fi
}

main "$@"