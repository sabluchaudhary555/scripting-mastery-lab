#!/usr/bin/env zsh
# ============================================================
#  Simple Shopping Bill Maker
#  Topics: variables, arrays, associative arrays, arithmetic,
#          read, command substitution, special variables
# ============================================================

setopt NO_UNSET

# ---------- Store Catalog (Associative Array) ---------------
typeset -A price=(
  apple   40
  milk    60
  bread   35
  eggs    90
  butter  110
  rice    80
)

# ---------- Cart (Indexed Array) ---------------------------
typeset -a cart_items
typeset -a cart_qty

# ---------- Helper ------------------------------------------
function show_catalog() {
  print "\n📦 Available Items & Price (per unit in ₹)"
  print "-------------------------------------------"
  for item in ${(ko)price}; do          # (k) keys, (o) sorted
    printf "  %-10s ₹%d\n" $item $price[$item]
  done
  print "-------------------------------------------"
}

function add_item() {
  read -p "  Item name  : " item
  item=${(L)item}                        # lowercase (typeset -l trick via flag)

  if [[ -v price[$item] ]]; then
    read -p "  Quantity   : " qty
    typeset -i qty                       # force integer
    cart_items+=($item)
    cart_qty+=($qty)
    print "  ✅ Added: $qty × $item @ ₹$price[$item]"
  else
    print "  ❌ '$item' not in catalog."
  fi
}

function generate_bill() {
  typeset -i total=0
  typeset -i i=1
  local date_now=$(date "+%d %b %Y  %H:%M")
  local bill_no="BILL-$$"               # $$ = PID used as unique bill number

  print "\n╔══════════════════════════════════════╗"
  print   "║       🛒  SHOPPING BILL MAKER        ║"
  print   "╠══════════════════════════════════════╣"
  printf  "║  %-20s %15s ║\n" "$date_now" "$bill_no"
  print   "╠══════════════════════════════════════╣"
  printf  "║  %-12s %5s %8s %8s ║\n" "Item" "Qty" "Rate" "Amount"
  print   "║--------------------------------------║"

  for item in $cart_items; do
    typeset -i qty=$cart_qty[$i]
    typeset -i rate=$price[$item]
    typeset -i amount=$(( qty * rate ))
    (( total += amount ))
    printf  "║  %-12s %5d %8s %8s ║\n" $item $qty "₹$rate" "₹$amount"
    (( i++ ))
  done

  typeset -i tax=$(( total * 5 / 100 ))            # 5% GST
  typeset -i grand=$(( total + tax ))

  print   "║--------------------------------------║"
  printf  "║  %-28s %7s ║\n" "Subtotal"  "₹$total"
  printf  "║  %-28s %7s ║\n" "GST (5%)"  "₹$tax"
  print   "║--------------------------------------║"
  printf  "║  %-28s %7s ║\n" "GRAND TOTAL" "₹$grand"
  print   "╚══════════════════════════════════════╝"
  print   "       Thank you for shopping! 🙏\n"
}

# ---------- Main Loop ---------------------------------------
print "\n🛍️  Welcome to Shopping Bill Maker"
show_catalog

while true; do
  print "\n[1] Add item  [2] Generate Bill  [3] Exit"
  read -p "Choice: " choice

  case $choice in
    1) add_item ;;
    2)
      if (( $#cart_items == 0 )); then
        print "  ⚠️  Cart is empty!"
      else
        generate_bill
      fi
      ;;
    3) print "👋 Goodbye!"; exit 0 ;;
    *) print "  ❗ Invalid choice" ;;
  esac
done