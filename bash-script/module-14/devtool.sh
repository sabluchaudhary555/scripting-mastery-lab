#!/bin/bash
# ============================================================
#  Project 4 — Bash Tab Completion for Your CLI Tool
#  Module 14 — Advanced Bash Features
#
#  This project has TWO parts:
#   1. devtool.sh      — a realistic CLI tool (deploy/logs/db/config)
#   2. devtool_completion.sh — tab completion for devtool
#
#  Completion features:
#   - Sub-commands         → devtool <TAB>
#   - Sub-command options  → devtool deploy <TAB>
#   - Dynamic completions  → devtool logs <TAB>  (lists real services)
#   - File completions     → devtool config load <TAB>  (real files)
#   - Flag completions     → devtool deploy --<TAB>
#   - Context-aware        → different completions per sub-command
#   - compgen, COMPREPLY, COMP_WORDS, COMP_CWORD
# ============================================================

set -euo pipefail
IFS=$'\n\t'

# ============================================================
#  CONFIG
# ============================================================
TOOL_NAME="devtool"
VERSION="1.0.0"
LOG_DIR="${LOG_DIR:-/tmp/devtool_logs}"
CONFIG_DIR="${CONFIG_DIR:-/tmp/devtool_configs}"
DEPLOY_ENVS=("dev" "staging" "prod")
SERVICES=("api" "worker" "scheduler" "nginx" "postgres")

# ============================================================
#  COLORS
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ============================================================
#  HELPERS
# ============================================================
info()    { echo -e "${GREEN}  ✔  $*${RESET}"; }
warn()    { echo -e "${YELLOW}  ⚠  $*${RESET}"; }
error()   { echo -e "${RED}  ✖  $*${RESET}" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}▸ $*${RESET}"; }
die()     { error "$1"; exit "${2:-1}"; }

# ============================================================
#  USAGE / HELP
# ============================================================
usage_main() {
    cat <<EOF

${BOLD}${CYAN}$TOOL_NAME v$VERSION${RESET} — Developer CLI Tool

${BOLD}Usage:${RESET}
  $TOOL_NAME <command> [sub-command] [options]

${BOLD}Commands:${RESET}
  ${GREEN}deploy${RESET}    Deploy services to an environment
  ${GREEN}logs${RESET}      View and manage service logs
  ${GREEN}db${RESET}        Database operations
  ${GREEN}config${RESET}    Manage configuration files
  ${GREEN}status${RESET}    Show status of all services
  ${GREEN}version${RESET}   Show version info

${BOLD}Global Options:${RESET}
  ${CYAN}--help,    -h${RESET}    Show help
  ${CYAN}--verbose, -v${RESET}    Verbose output
  ${CYAN}--dry-run,  -n${RESET}   Preview without executing

${DIM}Run '$TOOL_NAME <command> --help' for command-specific help.${RESET}

EOF
}

usage_deploy() {
    cat <<EOF

${BOLD}Usage:${RESET} $TOOL_NAME deploy <env> [service] [options]

${BOLD}Environments:${RESET}  dev | staging | prod

${BOLD}Services:${RESET}      api | worker | scheduler | nginx | postgres
                 (omit to deploy all services)

${BOLD}Options:${RESET}
  --force        Force deploy even if health checks fail
  --rollback     Roll back to previous deployment
  --tag TAG      Deploy specific image tag
  --dry-run      Preview deployment steps

${BOLD}Examples:${RESET}
  $TOOL_NAME deploy dev
  $TOOL_NAME deploy staging api --tag v1.2.3
  $TOOL_NAME deploy prod --dry-run

EOF
}

usage_logs() {
    cat <<EOF

${BOLD}Usage:${RESET} $TOOL_NAME logs <service> [options]

${BOLD}Services:${RESET}  api | worker | scheduler | nginx | postgres

${BOLD}Options:${RESET}
  --follow,  -f        Follow log output (tail -f)
  --lines N, -n N      Show last N lines (default: 50)
  --grep PATTERN       Filter lines matching pattern
  --since TIME         Show logs since time (e.g. "1h", "30m")
  --clear              Clear log file

${BOLD}Examples:${RESET}
  $TOOL_NAME logs api --follow
  $TOOL_NAME logs worker --lines 100 --grep ERROR
  $TOOL_NAME logs nginx --since 1h

EOF
}

usage_db() {
    cat <<EOF

${BOLD}Usage:${RESET} $TOOL_NAME db <operation> [options]

${BOLD}Operations:${RESET}
  backup   Create a database backup
  restore  Restore from backup file
  migrate  Run pending migrations
  seed     Seed database with test data
  shell    Open interactive DB shell

${BOLD}Options:${RESET}
  --env ENV        Target environment (default: dev)
  --file FILE      Backup file (for restore)
  --force          Skip confirmation prompts

${BOLD}Examples:${RESET}
  $TOOL_NAME db backup --env prod
  $TOOL_NAME db restore --file backup_20250502.sql
  $TOOL_NAME db migrate --env staging

EOF
}

usage_config() {
    cat <<EOF

${BOLD}Usage:${RESET} $TOOL_NAME config <operation> [file] [options]

${BOLD}Operations:${RESET}
  list     List all config files
  show     Display config file contents
  load     Load/apply a config file
  diff     Compare config with deployed version
  edit     Open config in \$EDITOR

${BOLD}Options:${RESET}
  --env ENV    Target environment

${BOLD}Examples:${RESET}
  $TOOL_NAME config list
  $TOOL_NAME config show app.conf
  $TOOL_NAME config load nginx.conf --env prod

EOF
}

# ============================================================
#  COMMAND: deploy
# ============================================================
cmd_deploy() {
    local env="${1:-}"
    shift || true
    local service="${1:-all}"
    [[ "$service" == --* ]] && service="all"

    local force=false dry_run=false rollback=false tag="latest"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)    force=true ;;
            --dry-run)  dry_run=true ;;
            --rollback) rollback=true ;;
            --tag)      tag="$2"; shift ;;
            --help|-h)  usage_deploy; return 0 ;;
            *)          warn "Unknown option: $1" ;;
        esac
        shift
    done

    # validate env
    local valid=false
    for e in "${DEPLOY_ENVS[@]}"; do
        [[ "$env" == "$e" ]] && valid=true && break
    done
    $valid || die "Invalid environment: '$env'. Choose: ${DEPLOY_ENVS[*]}"

    header "Deploy — env=$env service=$service tag=$tag"

    $dry_run && warn "DRY-RUN mode — no changes will be made"
    $rollback && warn "ROLLBACK mode — reverting to previous deployment"

    local targets=()
    if [[ "$service" == "all" ]]; then
        targets=("${SERVICES[@]}")
    else
        targets=("$service")
    fi

    for svc in "${targets[@]}"; do
        echo -ne "  Deploying ${CYAN}$svc${RESET} to ${YELLOW}$env${RESET}..."
        if ! $dry_run; then
            sleep 0.5   # simulate deploy
            # Create fake log entry
            mkdir -p "$LOG_DIR"
            echo "$(date) DEPLOY $svc → $env (tag: $tag)" >> "$LOG_DIR/${svc}.log"
        fi
        echo -e " ${GREEN}done${RESET}"
    done

    info "Deploy complete → $env ($tag)"
}

# ============================================================
#  COMMAND: logs
# ============================================================
cmd_logs() {
    local service="${1:-}"
    shift || true

    local follow=false lines=50 grep_pat="" since="" clear_log=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --follow|-f)  follow=true ;;
            --lines|-n)   lines="$2"; shift ;;
            --grep)       grep_pat="$2"; shift ;;
            --since)      since="$2"; shift ;;
            --clear)      clear_log=true ;;
            --help|-h)    usage_logs; return 0 ;;
            *)            warn "Unknown option: $1" ;;
        esac
        shift
    done

    [[ -z "$service" ]] && { usage_logs; die "Service required"; }

    mkdir -p "$LOG_DIR"
    local logfile="$LOG_DIR/${service}.log"

    # create demo log if empty
    if [[ ! -f "$logfile" ]]; then
        for i in {1..20}; do
            echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]  $service: Request processed #$i" >> "$logfile"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN]  $service: High memory usage" >> "$logfile"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $service: Connection timeout #$i" >> "$logfile"
        done
    fi

    if $clear_log; then
        > "$logfile"
        info "Cleared logs for $service"
        return 0
    fi

    header "Logs — $service (last $lines lines)"

    local cmd="tail -n $lines $logfile"
    [[ -n "$grep_pat" ]] && cmd+=" | grep --color=always '$grep_pat'"

    if $follow; then
        info "Following $logfile (Ctrl+C to stop)"
        eval "$cmd" -f
    else
        eval "$cmd" 2>/dev/null || warn "No logs found for $service"
    fi
}

# ============================================================
#  COMMAND: db
# ============================================================
cmd_db() {
    local operation="${1:-}"
    shift || true

    local env="dev" file="" force=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --env)   env="$2"; shift ;;
            --file)  file="$2"; shift ;;
            --force) force=true ;;
            --help|-h) usage_db; return 0 ;;
            *)       warn "Unknown option: $1" ;;
        esac
        shift
    done

    case "$operation" in
        backup)
            header "DB Backup — $env"
            local bkfile="backup_$(date +%Y%m%d_%H%M%S).sql"
            echo "  Creating backup: $bkfile"
            sleep 0.5
            info "Backup saved: $bkfile"
            ;;
        restore)
            [[ -z "$file" ]] && die "--file required for restore"
            header "DB Restore — $env from $file"
            ! $force && {
                read -r -p "  Restore will overwrite $env database. Continue? [y/N] " yn
                [[ "$yn" =~ ^[Yy]$ ]] || { warn "Aborted"; return 0; }
            }
            sleep 0.5
            info "Database restored from $file"
            ;;
        migrate)
            header "DB Migrate — $env"
            info "Running pending migrations..."
            sleep 0.3
            info "3 migrations applied"
            ;;
        seed)
            header "DB Seed — $env"
            sleep 0.3
            info "Database seeded with test data"
            ;;
        shell)
            header "DB Shell — $env"
            info "Opening interactive shell (simulated)..."
            ;;
        ""|--help|-h)
            usage_db ;;
        *)
            die "Unknown db operation: $operation" ;;
    esac
}

# ============================================================
#  COMMAND: config
# ============================================================
cmd_config() {
    local operation="${1:-list}"
    shift || true
    local file="${1:-}"
    [[ "$file" == --* ]] && file=""
    local env="dev"

    mkdir -p "$CONFIG_DIR"
    # create demo configs if empty
    for f in app.conf nginx.conf postgres.conf; do
        [[ -f "$CONFIG_DIR/$f" ]] || cat > "$CONFIG_DIR/$f" <<CONF
# $f — generated by devtool
ENV=dev
LOG_LEVEL=info
MAX_CONNECTIONS=100
CONF
    done

    case "$operation" in
        list)
            header "Config Files"
            ls -lh "$CONFIG_DIR"/*.conf 2>/dev/null \
                | awk '{print "  " $NF, $5}' \
                || warn "No config files found"
            ;;
        show)
            [[ -z "$file" ]] && die "Specify a config file"
            local path="$CONFIG_DIR/$file"
            [[ -f "$path" ]] || die "Config not found: $file"
            header "Config: $file"
            cat "$path"
            ;;
        load)
            [[ -z "$file" ]] && die "Specify a config file to load"
            header "Loading config: $file → $env"
            sleep 0.3
            info "Config applied to $env"
            ;;
        diff)
            header "Config Diff: $file"
            warn "No differences found (simulated)"
            ;;
        edit)
            [[ -z "$file" ]] && die "Specify a config file to edit"
            "${EDITOR:-nano}" "$CONFIG_DIR/$file"
            ;;
        --help|-h)
            usage_config ;;
        *)
            die "Unknown config operation: $operation" ;;
    esac
}

# ============================================================
#  COMMAND: status
# ============================================================
cmd_status() {
    header "Service Status"
    printf "  %-15s %-10s %-8s %s\n" "SERVICE" "STATUS" "CPU%" "MEMORY"
    echo "  ──────────────────────────────────────────"
    for svc in "${SERVICES[@]}"; do
        local status cpu mem
        # simulate random status
        (( RANDOM % 10 < 8 )) && status="${GREEN}running${RESET}" || status="${RED}stopped${RESET}"
        cpu=$(( RANDOM % 40 + 1 ))
        mem=$(( RANDOM % 200 + 50 ))
        printf "  %-15s " "$svc"
        echo -e "${status}    ${cpu}%     ${mem}MB"
    done
}

# ============================================================
#  MAIN DISPATCHER
# ============================================================
main() {
    # global flags
    local verbose=false

    [[ $# -eq 0 ]] && { usage_main; exit 0; }

    local cmd="$1"
    shift

    case "$cmd" in
        deploy)   cmd_deploy "$@" ;;
        logs)     cmd_logs   "$@" ;;
        db)       cmd_db     "$@" ;;
        config)   cmd_config "$@" ;;
        status)   cmd_status "$@" ;;
        version)  echo "$TOOL_NAME v$VERSION" ;;
        --help|-h) usage_main ;;
        *)        error "Unknown command: '$cmd'"; usage_main; exit 1 ;;
    esac
}

main "$@"