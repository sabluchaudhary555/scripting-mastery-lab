#!/usr/bin/env zsh
# netcheck.zsh — network health checker + API tester + file sync
# usage: ./netcheck.zsh [check|api|sync|dns|all]

setopt ERR_EXIT NO_UNSET PIPE_FAIL

# ── config ─────────────────────────────────────────────────────────────────

LOGFILE="/tmp/netcheck_$(date +%Y%m%d).log"
API_URL="${API_URL:-https://jsonplaceholder.typicode.com}"
PING_HOSTS=(8.8.8.8 1.1.1.1 google.com)
DNS_TARGETS=(google.com github.com)

exec > >(tee -a "$LOGFILE") 2>&1

# ── logging ────────────────────────────────────────────────────────────────

log_info()  { print "[INFO]  $(date '+%H:%M:%S') $*"; }
log_ok()    { print "[  OK ] $(date '+%H:%M:%S') $*"; }
log_warn()  { print "[WARN]  $(date '+%H:%M:%S') $*" >&2; }
log_error() { print "[ERROR] $(date '+%H:%M:%S') $*" >&2; }

# ── traps ──────────────────────────────────────────────────────────────────

trap 'log_info "netcheck done. log: $LOGFILE"' EXIT
trap 'log_warn "interrupted"; exit 130'         INT TERM

# ── helpers ────────────────────────────────────────────────────────────────

_divider() { print "────────────────────────────────────────"; }

# check if a tool is installed before using it
_require() {
    local tool=$1
    command -v "$tool" &>/dev/null || {
        log_error "required tool not found: $tool"
        return 127
    }
}

# returns http status code for a url
_http_status() {
    local url=$1
    curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null
}

# ── 1. connectivity check ──────────────────────────────────────────────────

check_connectivity() {
    _divider
    log_info "checking connectivity..."

    local -i passed=0 failed=0

    for host in "${PING_HOSTS[@]}"; do
        if ping -c 1 -W 2 "$host" > /dev/null 2>&1; then
            log_ok "reachable: $host"
            (( passed++ ))
        else
            log_warn "unreachable: $host"
            (( failed++ ))
        fi
    done

    print ""
    print "  result: ${passed} reachable, ${failed} unreachable"

    (( failed == ${#PING_HOSTS[@]} )) && {
        log_error "all hosts unreachable — no network"
        return 1
    }

    # grab public ip while we're at it
    local pub_ip
    pub_ip=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null || print "n/a")
    log_info "public IP: $pub_ip"
}

# ── 2. dns check ───────────────────────────────────────────────────────────

check_dns() {
    _divider
    log_info "checking DNS resolution..."

    _require dig || return 127

    for domain in "${DNS_TARGETS[@]}"; do
        local ip
        ip=$(dig +short "$domain" | head -1)

        if [[ -n $ip ]]; then
            log_ok "$domain → $ip"
        else
            log_warn "$domain → failed to resolve"
        fi
    done

    # also show mx records for first domain
    local mx
    mx=$(dig +short "${DNS_TARGETS[1]}" MX | head -1)
    log_info "MX for ${DNS_TARGETS[1]}: ${mx:-none}"
}

# ── 3. api health check ────────────────────────────────────────────────────

check_api() {
    _divider
    log_info "testing API: $API_URL"

    _require curl || return 127
    _require jq   || { log_warn "jq not found — skipping JSON parse"; return 0; }

    # GET /users/1
    local endpoint="$API_URL/users/1"
    local status
    status=$(_http_status "$endpoint")

    if [[ $status == "200" ]]; then
        log_ok "GET $endpoint → $status"
    else
        log_error "GET $endpoint → $status"
        return 1
    fi

    # parse the response
    local body
    body=$(curl -s --max-time 5 "$endpoint")

    local name email city
    name=$(print  "$body" | jq -r '.name')
    email=$(print "$body" | jq -r '.email')
    city=$(print  "$body" | jq -r '.address.city')

    print ""
    print "  name  : $name"
    print "  email : $email"
    print "  city  : $city"
    print ""

    # quick POST test
    log_info "testing POST /posts..."
    local post_status
    post_status=$(curl -s -o /dev/null -w "%{http_code}" \
        --max-time 5 \
        -X POST "$API_URL/posts" \
        -H "Content-Type: application/json" \
        -d '{"title":"test","body":"hello","userId":1}')

    [[ $post_status == "201" ]] \
        && log_ok "POST /posts → $post_status (created)" \
        || log_warn "POST /posts → $post_status"
}

# ── 4. port check ──────────────────────────────────────────────────────────

check_ports() {
    _divider
    log_info "checking common ports on google.com..."

    _require nc || { log_warn "nc not found — skipping port check"; return 0; }

    local -A ports=(80 "http" 443 "https" 22 "ssh")

    for port in ${(k)ports}; do
        if nc -zw 2 google.com "$port" 2>/dev/null; then
            log_ok "port $port (${ports[$port]}) open"
        else
            log_warn "port $port (${ports[$port]}) closed or filtered"
        fi
    done
}

# ── 5. summary ─────────────────────────────────────────────────────────────

print_summary() {
    _divider
    print ""
    print "╔═══════════════════════════════════╗"
    print "║   netcheck complete               ║"
    printf "║   log: %-26s ║\n" "$(basename $LOGFILE)"
    print "╚═══════════════════════════════════╝"
    print ""
}

# ── main ───────────────────────────────────────────────────────────────────

main() {
    local cmd=${1:-"all"}

    print ""
    log_info "netcheck started (pid $$)"

    case $cmd in
        check) check_connectivity ;;
        dns)   check_dns          ;;
        api)   check_api          ;;
        ports) check_ports        ;;
        all)
            check_connectivity
            check_dns
            check_api
            check_ports
            ;;
        --help|-h)
            print "usage: netcheck.zsh [check|dns|api|ports|all]"
            return 0
            ;;
        *)
            log_error "unknown command: $cmd"
            return 1
            ;;
    esac

    print_summary
}

main "$@"