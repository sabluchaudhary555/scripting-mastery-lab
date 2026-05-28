#!/usr/bin/env zsh
# csvtool.zsh — analyze and transform CSV files from the terminal
#
# does the stuff you'd normally open Excel for:
# preview, stats, filter rows, extract columns, find duplicates
#
# usage:
#   ./csvtool.zsh <command> <file.csv> [options]

# ── setup ─────────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  BOLD='\033[1m' DIM='\033[2m' CYAN='\033[0;36m'
  GREEN='\033[0;32m' YELLOW='\033[0;33m' RED='\033[0;31m' RESET='\033[0m'
else
  BOLD='' DIM='' CYAN='' GREEN='' YELLOW='' RED='' RESET=''
fi

# ── usage ─────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
${BOLD}csvtool${RESET} — CSV analyzer and transformer

${BOLD}usage:${RESET}
  csvtool.zsh <command> <file.csv> [options]

${BOLD}commands:${RESET}
  preview   [file]               pretty-print first N rows (default: 10)
  headers   [file]               list column names with index
  stats     [file] -c <col>      min / max / avg / count for a numeric column
  filter    [file] -c <col> -m <pattern>   print rows where column matches
  extract   [file] -c <col>      print unique values from a column
  dupes     [file] -c <col>      find duplicate values in a column
  count     [file] -c <col>      count rows grouped by column value
  rename    [file] -o <out>      normalize headers (lowercase, trim spaces)

${BOLD}options:${RESET}
  -c <col>    column name or number (1-based)
  -m <pat>    pattern to match (grep -i)
  -n <rows>   number of rows for preview (default 10)
  -o <file>   output file for rename command
  -d <delim>  delimiter (default: comma)
  -h          show help

${BOLD}examples:${RESET}
  ./csvtool.zsh preview  data.csv
  ./csvtool.zsh headers  data.csv
  ./csvtool.zsh stats    sales.csv -c revenue
  ./csvtool.zsh filter   users.csv -c city -m "New York"
  ./csvtool.zsh extract  orders.csv -c status
  ./csvtool.zsh dupes    users.csv -c email
  ./csvtool.zsh count    orders.csv -c country
  ./csvtool.zsh rename   messy.csv -o clean.csv
EOF
  exit 0
}

# ── helpers ───────────────────────────────────────────────────────────────────

die()  { print "${RED}error:${RESET} $*" >&2; exit 1; }
info() { print "${CYAN}::${RESET} $*"; }

# given a column name or number, return the 1-based column index
col_index() {
  local file=$1 col=$2 delim=$3

  # if it's already a number, return it
  if [[ $col =~ ^[0-9]+$ ]]; then
    print $col
    return
  fi

  # otherwise look it up in the header row
  local headers
  headers=$(head -1 "$file")
  local i=1
  while IFS="$delim" read -rA fields; do
    for field in $fields; do
      # zsh string ops: trim spaces, lowercase for comparison
      local clean=${(L)${field## }%% }
      local want=${(L)${col## }%% }
      [[ $clean == $want ]] && { print $i; return; }
      (( i++ ))
    done
  done <<< "$headers"

  die "column '$col' not found in headers"
}

# ── commands ──────────────────────────────────────────────────────────────────

cmd_preview() {
  local file=$1 rows=${ROWS:-10} delim=${DELIM:-,}
  info "preview: $file (first $rows rows)"
  print ""
  head -$(( rows + 1 )) "$file" | column -t -s"$delim"
}

cmd_headers() {
  local file=$1 delim=${DELIM:-,}
  info "headers in: ${file##*/}"   # zsh: strip path prefix
  print ""

  local i=1
  IFS="$delim" read -rA cols < "$file"
  for col in $cols; do
    # strip surrounding whitespace with zsh param expansion
    local clean=${col## }
    clean=${clean%% }
    printf "  ${CYAN}%2d${RESET}  %s\n" $i "$clean"
    (( i++ ))
  done
}

cmd_stats() {
  local file=$1 col=$COL delim=${DELIM:-,}
  [[ -z $col ]] && die "stats needs -c <column>"

  local idx
  idx=$(col_index "$file" "$col" "$delim")
  info "stats for column $col (field $idx)"
  print ""

  # use awk for the number crunching — it's the right tool here
  tail -n +2 "$file" | awk -F"$delim" -v c="$idx" '
    $c ~ /^[0-9]+(\.[0-9]+)?$/ {
      val = $c + 0
      if (NR == 1 || val < min) min = val
      if (NR == 1 || val > max) max = val
      sum += val
      count++
    }
    END {
      if (count == 0) { print "  no numeric values found"; exit }
      printf "  count  : %d\n", count
      printf "  min    : %g\n", min
      printf "  max    : %g\n", max
      printf "  sum    : %g\n", sum
      printf "  avg    : %.2f\n", sum / count
    }
  '
}

cmd_filter() {
  local file=$1 col=$COL pattern=$MATCH delim=${DELIM:-,}
  [[ -z $col     ]] && die "filter needs -c <column>"
  [[ -z $pattern ]] && die "filter needs -m <pattern>"

  local idx
  idx=$(col_index "$file" "$col" "$delim")
  info "rows where '$col' matches '$pattern'"
  print ""

  # print header then matching rows
  head -1 "$file" | column -t -s"$delim"
  print "${DIM}$(head -1 "$file" | sed 's/[^,]/-/g')${RESET}"

  tail -n +2 "$file" | awk -F"$delim" -v c="$idx" -v pat="$pattern" '
    tolower($c) ~ tolower(pat) { print }
  ' | column -t -s"$delim"
}

cmd_extract() {
  local file=$1 col=$COL delim=${DELIM:-,}
  [[ -z $col ]] && die "extract needs -c <column>"

  local idx
  idx=$(col_index "$file" "$col" "$delim")
  info "unique values in column '$col'"
  print ""

  tail -n +2 "$file" \
    | cut -d"$delim" -f"$idx" \
    | sort \
    | uniq \
    | while IFS= read -r val; do
        # trim with zsh expansion, skip blanks
        local v=${val## }; v=${v%% }
        [[ -n $v ]] && print "  $v"
      done
}

cmd_dupes() {
  local file=$1 col=$COL delim=${DELIM:-,}
  [[ -z $col ]] && die "dupes needs -c <column>"

  local idx
  idx=$(col_index "$file" "$col" "$delim")
  info "duplicate values in column '$col'"
  print ""

  local found=0
  tail -n +2 "$file" \
    | cut -d"$delim" -f"$idx" \
    | sort \
    | uniq -d \
    | while IFS= read -r val; do
        [[ -n $val ]] && { print "  ${YELLOW}duplicate:${RESET} $val"; found=1; }
      done

  (( found == 0 )) && print "  ${GREEN}no duplicates found${RESET}"
}

cmd_count() {
  local file=$1 col=$COL delim=${DELIM:-,}
  [[ -z $col ]] && die "count needs -c <column>"

  local idx
  idx=$(col_index "$file" "$col" "$delim")
  info "row count grouped by '$col'"
  print ""

  tail -n +2 "$file" \
    | cut -d"$delim" -f"$idx" \
    | sort \
    | uniq -c \
    | sort -rn \
    | while read -r count val; do
        printf "  ${CYAN}%5d${RESET}  %s\n" "$count" "$val"
      done
}

cmd_rename() {
  local file=$1 out=${OUTPUT:-} delim=${DELIM:-,}
  [[ -z $out ]] && die "rename needs -o <output file>"

  info "normalizing headers: $file → $out"

  # read header, normalize each column name with zsh string ops
  IFS="$delim" read -rA cols < "$file"
  local new_headers=()
  for col in $cols; do
    local clean=${col## }   # strip leading space
    clean=${clean%% }        # strip trailing space
    clean=${(L)clean}        # lowercase
    clean=${clean// /_}      # spaces → underscores
    clean=${clean//[^a-z0-9_]/}  # remove non-alphanumeric (except _)
    new_headers+=("$clean")
  done

  # write normalized header + rest of file
  print ${(j:,:)new_headers} > "$out"
  tail -n +2 "$file" >> "$out"

  print "  saved to: $out"
  print "  headers:"
  printf '    %s\n' $new_headers
}

# ── argument parsing ──────────────────────────────────────────────────────────

[[ $# -lt 1 ]] && usage

COMMAND=$1; shift
[[ $COMMAND == "-h" || $COMMAND == "help" ]] && usage

FILE=$1; shift
[[ -z $FILE  ]] && die "no file given"
[[ ! -f $FILE ]] && die "file not found: $FILE"

# check it looks like a CSV
if ! head -1 "$FILE" | grep -q ','; then
  print "${YELLOW}warn:${RESET} no commas in first line — maybe wrong delimiter? use -d"
fi

COL="" MATCH="" ROWS=10 OUTPUT="" DELIM=","

while getopts "c:m:n:o:d:h" opt; do
  case $opt in
    c) COL=$OPTARG ;;
    m) MATCH=$OPTARG ;;
    n) ROWS=$OPTARG ;;
    o) OUTPUT=$OPTARG ;;
    d) DELIM=$OPTARG ;;
    h) usage ;;
    *) usage ;;
  esac
done

# ── dispatch ──────────────────────────────────────────────────────────────────

case $COMMAND in
  preview) cmd_preview "$FILE" ;;
  headers) cmd_headers "$FILE" ;;
  stats)   cmd_stats   "$FILE" ;;
  filter)  cmd_filter  "$FILE" ;;
  extract) cmd_extract "$FILE" ;;
  dupes)   cmd_dupes   "$FILE" ;;
  count)   cmd_count   "$FILE" ;;
  rename)  cmd_rename  "$FILE" ;;
  *)       die "unknown command: $COMMAND — run with -h for help" ;;
esac