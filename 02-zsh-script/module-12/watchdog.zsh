#!/usr/bin/env zsh
# watchdog.zsh — runs any script with full error handling, traps, and logging
# usage: ./watchdog.zsh [--debug] <script_to_run> [args...]

# ── safety first ───────────────────────────────────────────────────────────

setopt ERR_EXIT NO_UNSET PIPE_FAIL

# ── config ─────────────────────────────────────────────────────────────────

LOGFILE="/tmp/watchdog_$(date +%Y%m%d_%H%M%S).log"
TMPDIR_WORK=$(mktemp -d /tmp/watchdog_XXXXXX)

DEBUG_MODE=0
TARGET_SCRIPT=""
TARGET_ARGS=()

# ── logging ────────────────────────────────────────────────────────────────

# all output goes to terminal + logfile
exec > >(tee -a "$LOGFILE") 2>&1

log_info()  { print "[INFO]  $(date '+%H:%M:%S') $*"; }
log_warn()  { print "[WARN]  $(date '+%H:%M:%S') $*" >&2; }
log_error() { print "[ERROR] $(date '+%H:%M:%S') $*" >&2; }
log_debug() { (( DEBUG_MODE )) && print "[DEBUG] $(date '+%H:%M:%S') $*"; }

# ── traps ──────────────────────────────────────────────────────────────────

cleanup() {
    log_info "cleaning up work dir: $TMPDIR_WORK"
    rm -rf "$TMPDIR_WORK"
}

error_handler() {
    local code=$?
    local line=$LINENO

    log_error "failed at line $line — exit code: $code"

    case $code in
        1)   log_error "reason: general error" ;;
        2)   log_error "reason: bad arguments or misuse" ;;
        126) log_error "reason: script not executable" ;;
        127) log_error "reason: command not found" ;;
        130) log_error "reason: killed by ctrl+c" ;;
        *)   log_error "reason: signal or unknown error" ;;
    esac

    cleanup
    exit $code
}

trap cleanup       EXIT
trap error_handler ERR
trap 'log_warn "interrupted — ctrl+c"; cleanup; exit 130' INT TERM

# ── argument parsing ───────────────────────────────────────────────────────

parse_args() {
    if (( $# == 0 )); then
        print "usage: watchdog.zsh [--debug] <script> [args...]" >&2
        print "       --debug   enable xtrace for the target script"
        return 2
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            --debug) DEBUG_MODE=1; shift ;;
            -*)      log_warn "unknown flag: $1"; shift ;;
            *)
                TARGET_SCRIPT=$1
                shift
                TARGET_ARGS=("$@")
                break
                ;;
        esac
    done

    [[ -z $TARGET_SCRIPT ]] && {
        log_error "no target script provided"
        return 2
    }
}

# ── pre-flight checks ──────────────────────────────────────────────────────

preflight() {
    local script=$1

    log_info "running pre-flight checks..."

    # does the file exist?
    [[ -f $script ]] || {
        log_error "script not found: $script"
        return 4
    }

    # is it executable?
    [[ -x $script ]] || {
        log_warn "$script is not executable — fixing with chmod +x"
        chmod +x "$script" || {
            log_error "cannot make it executable — check permissions"
            return 126
        }
    }

    # syntax check before running
    log_info "checking syntax: zsh -n $script"
    if zsh -n "$script" 2>/tmp/syntax_check_$$.txt; then
        log_info "syntax OK"
    else
        log_error "syntax error found:"
        cat /tmp/syntax_check_$$.txt >&2
        rm -f /tmp/syntax_check_$$.txt
        return 1
    fi
    rm -f /tmp/syntax_check_$$.txt
}

# ── runner ─────────────────────────────────────────────────────────────────

run_script() {
    local script=$1
    shift
    local args=("$@")

    log_info "launching: $script $args"
    log_info "log file : $LOGFILE"
    print "─────────────────────────────────────────────────────"

    local start=$SECONDS

    # run with xtrace if debug mode is on
    if (( DEBUG_MODE )); then
        log_debug "debug mode ON — enabling xtrace"
        export PS4='+%D{%H:%M:%S} %N:%I %_ '
        zsh -x "$script" "${args[@]}"
    else
        zsh "$script" "${args[@]}"
    fi

    local exit_code=$?
    local elapsed=$(( SECONDS - start ))

    print "─────────────────────────────────────────────────────"

    if (( exit_code == 0 )); then
        log_info "script finished OK in ${elapsed}s"
    else
        log_error "script exited with code $exit_code after ${elapsed}s"
        return $exit_code
    fi
}

# ── summary ────────────────────────────────────────────────────────────────

print_summary() {
    local code=$1
    print ""
    print "╔══════════════════════════════════════╗"
    if (( code == 0 )); then
        print "║   ✓  watchdog: SUCCESS               ║"
    else
        printf  "║   ✗  watchdog: FAILED  (code %3d)   ║\n" $code
    fi
    print "╚══════════════════════════════════════╝"
    print "  log saved to: $LOGFILE"
    print ""
}

# ── main ───────────────────────────────────────────────────────────────────

main() {
    log_info "watchdog started (pid $$)"

    parse_args "$@"

    preflight "$TARGET_SCRIPT"

    run_script "$TARGET_SCRIPT" "${TARGET_ARGS[@]}"
    local final_code=$?

    print_summary $final_code
    return $final_code
}

main "$@"