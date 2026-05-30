#!/bin/bash
# ============================================================
#  devtool_completion.sh — Bash Tab Completion
#  Module 14 — Advanced Bash Features
#
#  HOW TO USE:
#    source ./devtool_completion.sh
#    OR
#    cp devtool_completion.sh /etc/bash_completion.d/devtool
#
#  KEY BASH COMPLETION CONCEPTS USED:
#    COMP_WORDS   — array of words typed so far
#    COMP_CWORD   — index of current word being completed
#    COMPREPLY    — array you fill with completion options
#    compgen -W   — generate completions from word list
#    compgen -f   — generate completions from filenames
#    compgen -d   — generate completions from directories
#    complete -F  — register function as completer for command
# ============================================================

# ── Completion data ──────────────────────────────────────────
_DEVTOOL_COMMANDS="deploy logs db config status version --help --version"
_DEVTOOL_ENVS="dev staging prod"
_DEVTOOL_SERVICES="api worker scheduler nginx postgres"

_DEVTOOL_DEPLOY_OPTS="--force --rollback --dry-run --tag --help"
_DEVTOOL_LOGS_OPTS="--follow --lines --grep --since --clear --help"
_DEVTOOL_DB_OPS="backup restore migrate seed shell"
_DEVTOOL_DB_OPTS="--env --file --force --help"
_DEVTOOL_CONFIG_OPS="list show load diff edit"
_DEVTOOL_CONFIG_OPTS="--env --help"

# ── Helper: complete from word list ─────────────────────────
_devtool_compwords() {
    # compgen -W generates completions from a space-separated list
    # -- separates options from the current word being typed
    COMPREPLY=( $(compgen -W "$1" -- "$2") )
}

# ── Helper: complete config files ───────────────────────────
_devtool_config_files() {
    local cur="$1"
    local config_dir="${CONFIG_DIR:-/tmp/devtool_configs}"

    if [[ -d "$config_dir" ]]; then
        # complete from actual .conf files in config dir
        local files
        files=$(ls "$config_dir"/*.conf 2>/dev/null | xargs -I{} basename {})
        COMPREPLY=( $(compgen -W "$files" -- "$cur") )
    else
        # fallback to filesystem completion
        COMPREPLY=( $(compgen -f -- "$cur") )
    fi
}

# ── Helper: complete log services (real log files) ───────────
_devtool_log_services() {
    local cur="$1"
    local log_dir="${LOG_DIR:-/tmp/devtool_logs}"

    if [[ -d "$log_dir" ]]; then
        # complete from actual log files
        local svcs
        svcs=$(ls "$log_dir"/*.log 2>/dev/null \
               | xargs -I{} basename {} .log)
        COMPREPLY=( $(compgen -W "$svcs $_DEVTOOL_SERVICES" -- "$cur") )
    else
        _devtool_compwords "$_DEVTOOL_SERVICES" "$cur"
    fi
}

# ── Helper: complete backup files for db restore ─────────────
_devtool_backup_files() {
    local cur="$1"
    # complete sql and gz files
    COMPREPLY=( $(compgen -f -X '!*.@(sql|gz|dump)' -- "$cur") )
    # also show all files if nothing matches
    [[ ${#COMPREPLY[@]} -eq 0 ]] && \
        COMPREPLY=( $(compgen -f -- "$cur") )
}

# ============================================================
#  MAIN COMPLETION FUNCTION
#  Called by bash whenever user presses TAB after "devtool"
# ============================================================
_devtool_complete() {
    # COMP_WORDS — array of all words typed so far
    # COMP_CWORD — index of the word currently being typed
    local cur="${COMP_WORDS[COMP_CWORD]}"   # word being completed NOW
    local prev="${COMP_WORDS[COMP_CWORD-1]}" # word before cursor
    local cmd=""

    # figure out which sub-command was typed (if any)
    # COMP_WORDS[0] = "devtool", COMP_WORDS[1] = sub-command
    [[ ${#COMP_WORDS[@]} -gt 1 ]] && cmd="${COMP_WORDS[1]}"

    # ── Depth 1: complete sub-commands ───────────────────────
    # devtool <TAB>
    if [[ $COMP_CWORD -eq 1 ]]; then
        _devtool_compwords "$_DEVTOOL_COMMANDS" "$cur"
        return
    fi

    # ── Handle --flag value completions ──────────────────────
    # When previous word is a flag that takes a value
    case "$prev" in
        --tag)
            # complete image tags (static list or dynamic from registry)
            _devtool_compwords "latest stable v1.0.0 v1.1.0 v2.0.0" "$cur"
            return
            ;;
        --env)
            _devtool_compwords "$_DEVTOOL_ENVS" "$cur"
            return
            ;;
        --file)
            _devtool_backup_files "$cur"
            return
            ;;
        --lines|-n)
            # suggest common line counts
            _devtool_compwords "10 20 50 100 200 500 1000" "$cur"
            return
            ;;
        --since)
            _devtool_compwords "5m 15m 30m 1h 2h 6h 12h 24h 7d" "$cur"
            return
            ;;
        --grep)
            # suggest common log patterns
            _devtool_compwords "ERROR WARN INFO DEBUG FATAL" "$cur"
            return
            ;;
    esac

    # ── Depth 2+: per-command completions ────────────────────
    case "$cmd" in

        # devtool deploy <env> <service> [--flags]
        deploy)
            if [[ $COMP_CWORD -eq 2 ]]; then
                # devtool deploy <TAB> → environments
                _devtool_compwords "$_DEVTOOL_ENVS" "$cur"
            elif [[ $COMP_CWORD -eq 3 ]]; then
                # devtool deploy dev <TAB> → services or flags
                _devtool_compwords "$_DEVTOOL_SERVICES $_DEVTOOL_DEPLOY_OPTS" "$cur"
            else
                # devtool deploy dev api <TAB> → flags only
                _devtool_compwords "$_DEVTOOL_DEPLOY_OPTS" "$cur"
            fi
            ;;

        # devtool logs <service> [--flags]
        logs)
            if [[ $COMP_CWORD -eq 2 ]]; then
                # devtool logs <TAB> → services (dynamic from real log files)
                _devtool_log_services "$cur"
            else
                # devtool logs api <TAB> → flags
                _devtool_compwords "$_DEVTOOL_LOGS_OPTS" "$cur"
            fi
            ;;

        # devtool db <operation> [--flags]
        db)
            if [[ $COMP_CWORD -eq 2 ]]; then
                # devtool db <TAB> → operations
                _devtool_compwords "$_DEVTOOL_DB_OPS" "$cur"
            else
                local db_op="${COMP_WORDS[2]}"
                case "$db_op" in
                    restore)
                        # devtool db restore <TAB> → --file or backup files
                        _devtool_compwords "--file --env --force --help" "$cur"
                        ;;
                    backup|migrate|seed)
                        _devtool_compwords "--env --force --help" "$cur"
                        ;;
                    *)
                        _devtool_compwords "$_DEVTOOL_DB_OPTS" "$cur"
                        ;;
                esac
            fi
            ;;

        # devtool config <operation> [file] [--flags]
        config)
            if [[ $COMP_CWORD -eq 2 ]]; then
                # devtool config <TAB> → operations
                _devtool_compwords "$_DEVTOOL_CONFIG_OPS" "$cur"
            elif [[ $COMP_CWORD -eq 3 ]]; then
                local config_op="${COMP_WORDS[2]}"
                case "$config_op" in
                    show|load|diff|edit)
                        # devtool config show <TAB> → config files (dynamic)
                        _devtool_config_files "$cur"
                        ;;
                    list)
                        _devtool_compwords "$_DEVTOOL_CONFIG_OPTS" "$cur"
                        ;;
                    *)
                        _devtool_compwords "$_DEVTOOL_CONFIG_OPS $_DEVTOOL_CONFIG_OPTS" "$cur"
                        ;;
                esac
            else
                _devtool_compwords "$_DEVTOOL_CONFIG_OPTS" "$cur"
            fi
            ;;

        # devtool status — no sub-completions needed
        status)
            COMPREPLY=()
            ;;

        # unknown command — no completions
        *)
            COMPREPLY=()
            ;;
    esac
}

# ============================================================
#  REGISTER the completion function for "devtool" command
#
#  complete flags:
#   -F function   use this function to generate completions
#   -o filenames  treat results as filenames (adds trailing /)
#   -o nospace    don't add space after completion
# ============================================================
complete -F _devtool_complete devtool
complete -F _devtool_complete devtool.sh   # also works with .sh extension

# ── Confirmation message ─────────────────────────────────────
echo "✅ devtool tab completion loaded!"
echo "   Try: devtool <TAB>  or  devtool deploy <TAB>"