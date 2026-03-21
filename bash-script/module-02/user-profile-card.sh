#!/bin/bash
# Project 2 — User Profile Card
# Topics covered: read, variables, ${} expansion, command substitution, silent input

# ── collect input ──────────────────────────────────────────
read -p "Enter your name   : " name
read -p "Enter your age    : " age
read -p "Enter your city   : " city
read -p "Enter your role   : " role
read -sp "Enter password   : " passwd
echo ""   # newline after silent input

# ── command substitution variables ─────────────────────────
timestamp=$(date)
host=$(hostname)
uid_val=$(id -u)

# ── display the profile card ───────────────────────────────
echo ""
echo "╔══════════════════════════════════════╗"
echo "║        USER PROFILE CARD             ║"
echo "╠══════════════════════════════════════╣"
echo "  Name     : ${name}"
echo "  Age      : ${age} yrs"
echo "  City     : ${city}"
echo "  Role     : ${role}"
echo "  UID      : ${uid_val}"
echo "  Host     : ${host}"
echo "  Login at : ${timestamp}"
echo "  Password : (stored securely)"
echo "╚══════════════════════════════════════╝"