#!/usr/bin/env zsh
# filewatch.zsh — audit a directory: permissions, sizes, duplicates, old files
#
# real-world use: run this on a project folder, uploads dir, or backup
# location to get a full health report — broken symlinks, wrong perms,
# oversized files, duplicates, old temp files — all in one pass.
#
# usage:
#   ./filewatch.zsh [options] <directory>

setopt extended_glob null_glob

# ── colors ────────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  RED='\033[0;31m' YELLOW='\033[0;33m' GREEN='\033[0;32m'
  CYAN='\033[0;36m' DIM='\033[2m' BOLD='\033[1m' RESET='\033[0m'
else
  RED='' YELLOW='' GREEN='' CYAN='' DIM='' BOLD='' RESET=''
fi

# ── usage ─────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
${BOLD}filewatch${RESET} — directory audit tool

${BOLD}usage:${RESET}
  filewatch.zsh [options] <directory>

${BOLD}checks:${RESET}
  --perms      flag files with world-writable or no-read permissions
  --size <MB>  flag files larger than N megabytes (default: 50)
  --old <days> flag files not modified in N days (default: 90)
  --dupes      find duplicate filenames (same name, different path)
  --symlinks   check for broken symbolic links
  --tmp        find leftover temp files (*.tmp *.bak *~ .DS_Store)
  --all        run all checks (default if no check flags given)

${BOLD}options:${RESET}
  -o <file>    write report to file as well as terminal
  -q           quiet — only show issues, skip summaries
  -h           show this help

${BOLD}examples:${RESET}
  ./filewatch.zsh --all ./project
  ./filewatch.zsh --perms --symlinks /var/www
  ./filewatch.zsh --size 100 --old 30 ~/Downloads
  ./filewatch.zsh --all -o report.txt ./uploads
EOF
  exit 0
}

# ── helpers ───────────────────────────────────────────────────────────────────

die()     { print "${RED}error:${RESET} $*" >&2; exit 1; }
heading() { print "\n${BOLD}${CYAN}── $* ${RESET}"; }
ok()      { print "  ${GREEN}✓${RESET} $*"; }
warn()    { print "  ${YELLOW}▲${RESET} $*"; }
bad()     { print "  ${RED}✗${RESET} $*"; }
dim()     { print "  ${DIM}$*${RESET}"; }

ISSUES=0
flag_issue() { (( ISSUES++ )); }

# write to terminal and optionally to report file
out() {
  print "$*"
  [[ -n $OUTFILE ]] && print "$*" >> "$OUTFILE"
}

# ── argument parsing ──────────────────────────────────────────────────────────

CHECK_PERMS=0 CHECK_SIZE=0 CHECK_OLD=0
CHECK_DUPES=0 CHECK_SYMLINKS=0 CHECK_TMP=0
SIZE_MB=50 OLD_DAYS=90 OUTFILE="" QUIET=0

# parse long options manually (zparseopts style)
while [[ $# -gt 0 ]]; do
  case $1 in
    --perms)    CHECK_PERMS=1 ;;
    --size)     CHECK_SIZE=1; [[ $2 =~ ^[0-9]+$ ]] && { SIZE_MB=$2; shift; } ;;
    --old)      CHECK_OLD=1;  [[ $2 =~ ^[0-9]+$ ]] && { OLD_DAYS=$2; shift; } ;;
    --dupes)    CHECK_DUPES=1 ;;
    --symlinks) CHECK_SYMLINKS=1 ;;
    --tmp)      CHECK_TMP=1 ;;
    --all)      CHECK_PERMS=1; CHECK_SIZE=1; CHECK_OLD=1
                CHECK_DUPES=1; CHECK_SYMLINKS=1; CHECK_TMP=1 ;;
    -o)         OUTFILE=$2; shift ;;
    -q)         QUIET=1 ;;
    -h|--help)  usage ;;
    -*)         die "unknown option: $1" ;;
    *)          TARGET=$1 ;;
  esac
  shift
done

# default: run everything
if (( ! CHECK_PERMS && ! CHECK_SIZE && ! CHECK_OLD && ! CHECK_DUPES && ! CHECK_SYMLINKS && ! CHECK_TMP )); then
  CHECK_PERMS=1; CHECK_SIZE=1; CHECK_OLD=1
  CHECK_DUPES=1; CHECK_SYMLINKS=1; CHECK_TMP=1
fi

# validate target
[[ -z $TARGET  ]] && die "no directory given — run with -h for help"
[[ ! -d $TARGET ]] && die "'$TARGET' is not a directory"

# resolve absolute path — realpath equivalent in zsh
TARGET=${TARGET:A}

# set up report file
if [[ -n $OUTFILE ]]; then
  : > "$OUTFILE"   # truncate / create
fi

# ── header ────────────────────────────────────────────────────────────────────

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

out "${BOLD}filewatch report${RESET}"
out "directory : $TARGET"
out "timestamp : $TIMESTAMP"
out "────────────────────────────────────────────"

# ── overview ──────────────────────────────────────────────────────────────────

(( QUIET )) || {
  heading "Overview"

  # count files and dirs using find + glob qualifiers
  total_files=$(find "$TARGET" -type f | wc -l | tr -d ' ')
  total_dirs=$(find  "$TARGET" -type d | wc -l | tr -d ' ')
  total_links=$(find "$TARGET" -type l | wc -l | tr -d ' ')

  # total size using du
  total_size=$(du -sh "$TARGET" 2>/dev/null | cut -f1)

  dim "files      : $total_files"
  dim "dirs       : $total_dirs"
  dim "symlinks   : $total_links"
  dim "total size : $total_size"
}

# ── check: permissions ────────────────────────────────────────────────────────

(( CHECK_PERMS )) && {
  heading "Permission Check"

  # world-writable files (permissions like 777, 666, o+w)
  found=0
  while IFS= read -r f; do
    bad "world-writable: $f"
    flag_issue; found=1
  done < <(find "$TARGET" -type f -perm -o+w 2>/dev/null)

  # files with no read permission for owner
  while IFS= read -r f; do
    bad "not readable by owner: $f"
    flag_issue; found=1
  done < <(find "$TARGET" -type f ! -perm -u+r 2>/dev/null)

  # executable files that maybe shouldn't be (non-.sh files with +x)
  while IFS= read -r f; do
    ext=${f##*.}
    [[ $ext == (sh|zsh|bash|py|rb|pl) ]] && continue
    warn "unexpected +x: $f"
    found=1
  done < <(find "$TARGET" -type f -perm -u+x 2>/dev/null)

  (( found == 0 )) && ok "no permission issues found"
}

# ── check: large files ────────────────────────────────────────────────────────

(( CHECK_SIZE )) && {
  heading "Large Files  (> ${SIZE_MB}MB)"

  found=0
  while IFS= read -r f; do
    # stat for size in bytes, then convert
    size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null)
    size_mb=$(( size / 1024 / 1024 ))
    human=$(du -sh "$f" 2>/dev/null | cut -f1)
    warn "$human  ${DIM}$(basename "$f")${RESET}  ${DIM}${f%/*}/${RESET}"
    flag_issue; found=1
  done < <(find "$TARGET" -type f -size +${SIZE_MB}M 2>/dev/null)

  (( found == 0 )) && ok "no files larger than ${SIZE_MB}MB"
}

# ── check: old files ──────────────────────────────────────────────────────────

(( CHECK_OLD )) && {
  heading "Old Files  (not modified in ${OLD_DAYS}+ days)"

  found=0
  count=0
  while IFS= read -r f; do
    (( count++ ))
    # only show first 10 to avoid flooding output
    if (( count <= 10 )); then
      # get last modified time with stat
      mtime=$(stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
      warn "$mtime  ${f#$TARGET/}"
    fi
    flag_issue; found=1
  done < <(find "$TARGET" -type f -mtime +${OLD_DAYS} 2>/dev/null)

  (( count > 10 )) && dim "  ... and $(( count - 10 )) more"
  (( found == 0 )) && ok "no files older than ${OLD_DAYS} days"
}

# ── check: duplicate filenames ────────────────────────────────────────────────

(( CHECK_DUPES )) && {
  heading "Duplicate Filenames"

  # collect all basenames, find ones that appear more than once
  tmpfile=$(mktemp)
  trap "rm -f $tmpfile" EXIT

  find "$TARGET" -type f 2>/dev/null | while IFS= read -r f; do
    basename "$f"
  done | sort > "$tmpfile"

  found=0
  while IFS= read -r name; do
    warn "duplicate name: $name"
    # show all paths with this name
    find "$TARGET" -type f -name "$name" 2>/dev/null | while IFS= read -r p; do
      dim "    $p"
    done
    flag_issue; found=1
  done < <(uniq -d "$tmpfile")

  (( found == 0 )) && ok "no duplicate filenames found"
}

# ── check: broken symlinks ────────────────────────────────────────────────────

(( CHECK_SYMLINKS )) && {
  heading "Symlink Check"

  found=0
  # find all symlinks, check if target exists
  while IFS= read -r link; do
    target=$(readlink "$link")
    if [[ ! -e $link ]]; then
      bad "broken symlink: ${link#$TARGET/}"
      dim "    → $target  (target missing)"
      flag_issue; found=1
    else
      (( QUIET )) || ok "ok: ${link#$TARGET/}  → $target"
    fi
  done < <(find "$TARGET" -type l 2>/dev/null)

  (( found == 0 )) && ok "no broken symlinks"
}

# ── check: temp / junk files ──────────────────────────────────────────────────

(( CHECK_TMP )) && {
  heading "Temp / Junk Files"

  found=0

  # use extended glob patterns to find common junk
  junk_patterns=("*.tmp" "*.bak" "*.swp" "*~" ".DS_Store" "Thumbs.db" "*.orig" "*.log.1")

  for pat in $junk_patterns; do
    while IFS= read -r f; do
      size=$(du -sh "$f" 2>/dev/null | cut -f1)
      warn "$size  ${f#$TARGET/}"
      flag_issue; found=1
    done < <(find "$TARGET" -name "$pat" -type f 2>/dev/null)
  done

  (( found == 0 )) && ok "no temp or junk files found"
}

# ── final summary ─────────────────────────────────────────────────────────────

out "\n────────────────────────────────────────────"

if (( ISSUES == 0 )); then
  out "${GREEN}${BOLD}✓ all checks passed — no issues found${RESET}"
else
  out "${YELLOW}${BOLD}▲ $ISSUES issue(s) found${RESET}"
fi

[[ -n $OUTFILE ]] && print "\n${DIM}report saved to: $OUTFILE${RESET}"