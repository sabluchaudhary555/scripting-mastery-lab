#!/usr/bin/env zsh
# zsh-sift — search file contents with regex filters
# nothing fancy, just grep with a nicer interface

setopt extended_glob null_glob

# ── config ────────────────────────────────────────────────────────────────────

VERSION="1.0"
MATCHES=0
SEARCHED=0

# colors — disable if not a terminal
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' BOLD='' DIM='' RESET=''
fi

# ── helpers ───────────────────────────────────────────────────────────────────

usage() {
  print "zsh-sift v$VERSION — smart file content searcher"
  print ""
  print "usage:"
  print "  sift.zsh [options] <pattern> [directory]"
  print ""
  print "options:"
  print "  -e <ext>     only search files with this extension (e.g. -e zsh)"
  print "  -i           case-insensitive match"
  print "  -l           list matching filenames only, no content"
  print "  -n           show line numbers"
  print "  -v           invert match (lines that don't match)"
  print "  -r <regex>   use a raw regex instead of plain pattern"
  print "  -x <glob>    exclude files matching this glob pattern"
  print "  -h           show this help"
  print ""
  print "examples:"
  print "  sift.zsh 'TODO' ./src"
  print "  sift.zsh -e zsh -n 'setopt' ."
  print "  sift.zsh -i -r '[0-9]{1,3}\.[0-9]{1,3}' /etc"
  print "  sift.zsh -l 'password' ~"
  print "  sift.zsh -x '*.log' 'error' ./logs"
}

info()  { print "${CYAN}${BOLD}::${RESET} $*" }
warn()  { print "${YELLOW}warn:${RESET} $*" >&2 }
die()   { print "${RED}error:${RESET} $*" >&2; exit 1 }

# ── argument parsing ──────────────────────────────────────────────────────────

EXT=""
CASE_FLAG=""
LIST_ONLY=0
LINE_NUMS=""
INVERT=""
RAW_REGEX=""
EXCLUDE_GLOB=""

while getopts "e:ilnvr:x:h" opt; do
  case $opt in
    e) EXT=$OPTARG ;;
    i) CASE_FLAG="-i" ;;
    l) LIST_ONLY=1 ;;
    n) LINE_NUMS="-n" ;;
    v) INVERT="-v" ;;
    r) RAW_REGEX=$OPTARG ;;
    x) EXCLUDE_GLOB=$OPTARG ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

shift $((OPTIND - 1))

[[ $# -lt 1 ]] && { usage; exit 1; }

PATTERN=$1
SEARCH_DIR=${2:-.}   # default to current dir

[[ -d $SEARCH_DIR ]] || die "'$SEARCH_DIR' is not a directory"

# if -r was given, use that regex directly; otherwise treat pattern as literal
if [[ -n $RAW_REGEX ]]; then
  GREP_PATTERN=$RAW_REGEX
else
  # escape the pattern so special chars are treated literally
  GREP_PATTERN=$(echo "$PATTERN" | sed 's/[.[\*^$]/\\&/g')
fi

# ── file collection ───────────────────────────────────────────────────────────

collect_files() {
  local dir=$1

  # use recursive glob to find all regular files
  # *(.) = files only (glob qualifier), ** = recursive
  if [[ -n $EXT ]]; then
    files=( $dir/**/*.$EXT(.) )
  else
    files=( $dir/**/*(.) )
  fi

  # filter out excluded glob if -x was given
  if [[ -n $EXCLUDE_GLOB ]]; then
    local kept=()
    for f in $files; do
      # [[ $f != $~EXCLUDE_GLOB ]] treats EXCLUDE_GLOB as a glob pattern
      [[ $f != $~EXCLUDE_GLOB ]] && kept+=($f)
    done
    files=($kept)
  fi
}

# ── search logic ──────────────────────────────────────────────────────────────

search_file() {
  local file=$1
  (( SEARCHED++ ))

  # skip binary files — grep -I does this automatically
  # but we check manually so we can show a nicer skip message
  if file "$file" | grep -q 'binary'; then
    print "${DIM}  skip (binary): $file${RESET}"
    return
  fi

  local results
  results=$(grep -E $CASE_FLAG $LINE_NUMS $INVERT -- "$GREP_PATTERN" "$file" 2>/dev/null)

  [[ -z $results ]] && return

  (( MATCHES++ ))

  if (( LIST_ONLY )); then
    print "${GREEN}${file}${RESET}"
    return
  fi

  # print filename header
  print "${BOLD}${CYAN}── $file ${RESET}"

  # print each matching line with a bit of formatting
  while IFS= read -r line; do
    # highlight the matched portion in yellow
    local highlighted
    highlighted=$(echo "$line" | sed -E "s/($GREP_PATTERN)/${YELLOW}\1${RESET}/g")
    print "   ${highlighted}"
  done <<< "$results"

  print ""
}

# ── main ──────────────────────────────────────────────────────────────────────

info "searching for ${BOLD}'$PATTERN'${RESET} in ${BOLD}$SEARCH_DIR${RESET}"
[[ -n $EXT      ]] && info "filter: *.${EXT} files only"
[[ -n $EXCLUDE_GLOB ]] && info "exclude: $EXCLUDE_GLOB"
print ""

# collect files into array
typeset -a files
collect_files "$SEARCH_DIR"

if [[ ${#files} -eq 0 ]]; then
  warn "no files found in '$SEARCH_DIR'"
  exit 0
fi

# search each file
for f in $files; do
  search_file "$f"
done

# ── summary ───────────────────────────────────────────────────────────────────

print "${DIM}─────────────────────────────────${RESET}"
print "searched : $SEARCHED files"
print "matched  : ${BOLD}$MATCHES files${RESET}"

if (( MATCHES == 0 )); then
  print "${YELLOW}no matches found${RESET}"
fi