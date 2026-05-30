#!/usr/bin/env zsh
# ================================================
# Project : Shell Detector
# Author  : Hacker (sabluchaudhary555)
# GitHub  : https://github.com/sabluchaudhary555
# Site    : SSoft.in
# Desc    : Detects & displays current shell info
# ================================================

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------- Divider ----------
divider() {
  echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# ---------- Banner ----------
banner() {
  echo ""
  divider
  echo "${BOLD}${BLUE}        🐚  SHELL DETECTOR v1.0  🐚${RESET}"
  divider
  echo ""
}

# ---------- Detect Current Shell ----------
detect_shell() {
  local shell_path="$SHELL"
  local shell_name=$(basename "$shell_path")
  local shell_version=""

  case "$shell_name" in
    zsh)
      shell_version="$ZSH_VERSION"
      ;;
    bash)
      shell_version="$BASH_VERSION"
      ;;
    fish)
      shell_version=$(fish --version 2>/dev/null | awk '{print $3}')
      ;;
    ksh)
      shell_version=$(ksh --version 2>/dev/null | awk '{print $5}')
      ;;
    *)
      shell_version="Unknown"
      ;;
  esac

  echo "${BOLD}  Shell Info${RESET}"
  divider
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "Shell Name"    "$shell_name"
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "Shell Path"    "$shell_path"
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "Shell Version" "$shell_version"
  echo ""
}

# ---------- Detect All Installed Shells ----------
installed_shells() {
  echo "${BOLD}  Installed Shells (from /etc/shells)${RESET}"
  divider

  if [[ -f /etc/shells ]]; then
    while IFS= read -r line; do
      # skip comments and empty lines
      [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
      if [[ -x "$line" ]]; then
        printf "  ${GREEN}✔${RESET}  %s\n" "$line"
      else
        printf "  ${RED}✘${RESET}  %s ${RED}(not found)${RESET}\n" "$line"
      fi
    done < /etc/shells
  else
    echo "  ${RED}/etc/shells not found!${RESET}"
  fi
  echo ""
}

# ---------- System Info ----------
system_info() {
  echo "${BOLD}  System Info${RESET}"
  divider
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "User"      "$USER"
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "Hostname"  "$(hostname)"
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "OS"        "$(uname -s)"
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "Kernel"    "$(uname -r)"
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "Home Dir"  "$HOME"
  printf "  ${YELLOW}%-18s${RESET} : ${GREEN}%s${RESET}\n" "PWD"       "$PWD"
  echo ""
}

# ---------- Shell Family Check ----------
shell_family() {
  echo "${BOLD}  Shell Family Tree${RESET}"
  divider
  echo "  sh  (Bourne Shell — 1979)"
  echo "   ├── bash  (Bourne Again SHell — 1989)"
  echo "   ├── ksh   (Korn Shell — 1983)"
  echo "   └── zsh   (Z Shell — 1990) ${GREEN}← You are here (if using Zsh)${RESET}"
  echo ""
}

# ---------- Is Zsh Default? ----------
zsh_status() {
  echo "${BOLD}  Zsh Status${RESET}"
  divider
  local current=$(basename "$SHELL")

  if [[ "$current" == "zsh" ]]; then
    echo "  ${GREEN}✔ Zsh is your DEFAULT shell!${RESET}"
  else
    echo "  ${YELLOW}⚠ Zsh is NOT your default shell.${RESET}"
    echo "  ${CYAN}  Run: chsh -s \$(which zsh)${RESET}"
  fi

  if command -v zsh &>/dev/null; then
    echo "  ${GREEN}✔ Zsh is INSTALLED at: $(which zsh)${RESET}"
  else
    echo "  ${RED}✘ Zsh is NOT installed.${RESET}"
    echo "  ${CYAN}  Run: sudo apt install zsh -y${RESET}"
  fi
  echo ""
}

# ---------- Main ----------
main() {
  banner
  detect_shell
  installed_shells
  system_info
  shell_family
  zsh_status
  divider
  echo "${BOLD}${BLUE}  Done! Run this script anytime to check your shell.${RESET}"
  divider
  echo ""
}

main