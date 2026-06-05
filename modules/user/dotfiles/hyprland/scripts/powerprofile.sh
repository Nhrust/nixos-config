#!/usr/bin/env bash
# =============================================================================
# powerprofile.sh — управление power-profiles-daemon
# =============================================================================
# Использует базовые Unicode-стрелки (BMP) вместо Nerd Font PUA глифов,
# чтобы работало в любом шрифте.
# =============================================================================
set -euo pipefail

icon_for() {
  case "$1" in
    performance) echo "↑" ;;
    balanced)    echo "=" ;;
    power-saver) echo "↓" ;;
    *)           echo "?" ;;
  esac
}

human_for() {
  case "$1" in
    performance) echo "Performance" ;;
    balanced)    echo "Balanced" ;;
    power-saver) echo "Power Saver" ;;
    *)           echo "Unknown" ;;
  esac
}

case "${1:-status}" in
  status)
    profile=$(powerprofilesctl get 2>/dev/null || echo "unknown")
    echo "$(icon_for "$profile") $(human_for "$profile")"
    ;;

  cycle)
    current=$(powerprofilesctl get 2>/dev/null || echo "balanced")
    case "$current" in
      performance) next="balanced"     ;;
      balanced)    next="power-saver"  ;;
      power-saver) next="performance"  ;;
      *)           next="balanced"     ;;
    esac
    powerprofilesctl set "$next"
    command -v notify-send >/dev/null 2>&1 && \
      notify-send "Power Profile" "$(icon_for "$next") $(human_for "$next")" || true
    ;;

  *)
    echo "Usage: $0 {status|cycle}" >&2
    exit 1
    ;;
esac
