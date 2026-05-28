#!/usr/bin/env zsh
# logrouter.zsh — split a log stream into separate files by level
#
# reads from stdin (or a file), routes each line to the right
# output file based on log level, and optionally prints a live
# summary to the terminal.
#
# real-world use: pipe your app's output through this so errors
# go to error.log, warnings to warn.log, everything to all.log
#
# usage:
#   tail -f app.log | ./logrouter.zsh -o ./logs
#   cat app.log     | ./logrouter.zsh -o ./logs -v
#   ./logrouter.zsh -o ./logs -i app.log

setopt pipe_fail
TMPDIR_CREATED=""

# ── colors ────────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  RED='\033[0;31m' YELLOW='\033[0;33m' GREEN='\033[0;32m'
  CYAN='\033[0;36m' DIM='\033[2m' BOLD='\033[1m' RESET='\033[0m'
else
  RED='' YELLOW='' GREEN='' CYAN='' DIM='' BOLD='' RESET=''
fi

# ── usage ─────────────────────────────────────────────────────────────────────

usage() {
  cat >&2 <<EOF
logrouter — split log streams by level

usage:
  cmd | logrouter.zsh [options]
  logrouter.zsh [options] -i <logfile>

options:
  -o <dir>     output directory (default: ./log-output)
  -i <file>    read from file instead of stdin
  -v           verbose: print each line to terminal as it's routed
  -s           print summary at the end
  -p <prefix>  prefix for output filenames (default: app)
  -h           show this help

output files:
  <prefix>.all.log     every line
  <prefix>.info.log    INFO lines
  <prefix>.warn.log    WARN / WARNING lines
  <prefix>.error.log   ERROR lines
  <prefix>.debug.log   DEBUG lines
  <prefix>.other.log   anything that doesn't match a known level

examples:
  tail -f /var/log/app.log | ./logrouter.zsh -o ./logs -v
  ./logrouter.zsh -i app.log -o ./out -s -p myapp
EOF
  exit 1
}

# ── defaults ──────────────────────────────────────────────────────────────────

OUTDIR="./log-output"
INFILE=""
VERBOSE=0
SUMMARY=0
PREFIX="app"

# ── parse arguments (getopts) ─────────────────────────────────────────────────

while getopts "o:i:p:vsh" opt; do
  case $opt in
    o) OUTDIR=$OPTARG ;;
    i) INFILE=$OPTARG ;;
    p) PREFIX=$OPTARG ;;
    v) VERBOSE=1 ;;
    s) SUMMARY=1 ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

# ── validate ──────────────────────────────────────────────────────────────────

if [[ -n $INFILE && ! -f $INFILE ]]; then
  print "${RED}error:${RESET} file not found: $INFILE" >&2
  exit 1
fi

# if no -i and stdin is a terminal, nothing to read
if [[ -z $INFILE && -t 0 ]]; then
  print "${RED}error:${RESET} no input — pipe something in or use -i <file>" >&2
  usage
fi

# ── setup output dir ──────────────────────────────────────────────────────────

mkdir -p "$OUTDIR" || {
  print "${RED}error:${RESET} could not create output dir: $OUTDIR" >&2
  exit 1
}

# output file paths
F_ALL="$OUTDIR/${PREFIX}.all.log"
F_INFO="$OUTDIR/${PREFIX}.info.log"
F_WARN="$OUTDIR/${PREFIX}.warn.log"
F_ERROR="$OUTDIR/${PREFIX}.error.log"
F_DEBUG="$OUTDIR/${PREFIX}.debug.log"
F_OTHER="$OUTDIR/${PREFIX}.other.log"

# open file descriptors for each log level
# this is faster than opening/closing files per line
exec 10>> "$F_ALL"
exec 11>> "$F_INFO"
exec 12>> "$F_WARN"
exec 13>> "$F_ERROR"
exec 14>> "$F_DEBUG"
exec 15>> "$F_OTHER"

# ── cleanup on exit ───────────────────────────────────────────────────────────

cleanup() {
  exec 10>&- 11>&- 12>&- 13>&- 14>&- 15>&-
}
trap cleanup EXIT INT TERM

# ── counters ──────────────────────────────────────────────────────────────────

typeset -A counts
counts=(info 0 warn 0 error 0 debug 0 other 0 total 0)

# ── routing function ──────────────────────────────────────────────────────────

route_line() {
  local line=$1
  local level="other"
  local color=$DIM

  # detect log level — check for common formats
  # supports: "INFO", "[INFO]", "level=info", "LEVEL: INFO"
  if [[ $line =~ '[[:space:]|\[](INFO)[[:space:]|\]]' || $line =~ 'level=info' ]]; then
    level="info"; color=$GREEN
  elif [[ $line =~ '[[:space:]|\[](WARN(ING)?)[[:space:]|\]]' || $line =~ 'level=warn' ]]; then
    level="warn"; color=$YELLOW
  elif [[ $line =~ '[[:space:]|\[](ERROR|FATAL|CRITICAL)[[:space:]|\]]' || $line =~ 'level=error' ]]; then
    level="error"; color=$RED
  elif [[ $line =~ '[[:space:]|\[](DEBUG|TRACE)[[:space:]|\]]' || $line =~ 'level=debug' ]]; then
    level="debug"; color=$DIM
  fi

  # write to all.log always
  print "$line" >&10

  # write to the right level file
  case $level in
    info)  print "$line" >&11 ;;
    warn)  print "$line" >&12 ;;
    error) print "$line" >&13 ;;
    debug) print "$line" >&14 ;;
    other) print "$line" >&15 ;;
  esac

  # update counters
  (( counts[$level]++ ))
  (( counts[total]++ ))

  # verbose output — also uses tee-like behaviour: prints to terminal
  if (( VERBOSE )); then
    printf "${color}[%-5s]${RESET} %s\n" ${level:u} "$line"
  fi
}

# ── main read loop ────────────────────────────────────────────────────────────

print "${CYAN}${BOLD}logrouter${RESET} started — writing to ${BOLD}$OUTDIR/${PREFIX}.*${RESET}"
print "${DIM}  all    → $F_ALL"
print "  info   → $F_INFO"
print "  warn   → $F_WARN"
print "  error  → $F_ERROR"
print "  debug  → $F_DEBUG"
print "  other  → $F_OTHER${RESET}"
print ""

# use process substitution to read from file or stdin
# <() keeps stdin clean so we can still use it for other things
if [[ -n $INFILE ]]; then
  INPUT_SOURCE="$INFILE"
else
  INPUT_SOURCE="/dev/stdin"
fi

while IFS= read -r line; do
  route_line "$line"
done < "$INPUT_SOURCE"

# ── summary ───────────────────────────────────────────────────────────────────

if (( SUMMARY )) || (( ! VERBOSE )); then
  print "\n${BOLD}── summary ──────────────────────────────${RESET}"
  printf "  %-8s %s\n" "total"  "$counts[total]"
  printf "  ${GREEN}%-8s${RESET} %s\n" "info"   "$counts[info]"
  printf "  ${YELLOW}%-8s${RESET} %s\n" "warn"   "$counts[warn]"
  printf "  ${RED}%-8s${RESET} %s\n" "error"  "$counts[error]"
  printf "  ${DIM}%-8s${RESET} %s\n" "debug"  "$counts[debug]"
  printf "  %-8s %s\n" "other"  "$counts[other]"
  print "\n  output: ${BOLD}$OUTDIR/${RESET}"
fi