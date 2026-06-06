#!/usr/bin/env bash
# =============================================================================
# powerprofile.sh — управление power-profiles-daemon
# =============================================================================
# Используется из binds (Super+F1/F2/F3 ставят профиль напрямую через
# powerprofilesctl), из waybar custom/powerprofile модуля (вызов `json`
# каждые 5 секунд + `cycle` по ЛКМ), и вручную из терминала.
#
# Подкоманды:
#   status  — текущий профиль человеко-читаемо (для отладки)
#   cycle   — переключить performance → balanced → power-saver → ...
#   json    — JSON для waybar (text + tooltip + class)
#
# Иконки — базовые Unicode стрелки (BMP), работают в любом шрифте,
# не зависят от Nerd Font PUA глифов.
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

current() {
  powerprofilesctl get 2>/dev/null || echo "balanced"
}

case "${1:-status}" in
  status)
    p=$(current)
    echo "$(icon_for "$p") $(human_for "$p")"
    ;;

  cycle)
    case "$(current)" in
      performance) next="balanced"     ;;
      balanced)    next="power-saver"  ;;
      power-saver) next="performance"  ;;
      *)           next="balanced"     ;;
    esac
    powerprofilesctl set "$next"
    command -v notify-send >/dev/null 2>&1 && \
      notify-send "Power Profile" "$(icon_for "$next") $(human_for "$next")" || true
    ;;

  json)
    # Формат для waybar custom-module с return-type=json:
    #   text    — что показать в баре
    #   tooltip — hover-подсказка
    #   class   — CSS-класс (используется #custom-powerprofile.performance и т.д.)
    p=$(current)
    printf '{"text":"%s","tooltip":"Power: %s","class":"%s"}\n' \
      "$(icon_for "$p")" "$(human_for "$p")" "$p"
    ;;

  *)
    echo "Usage: $0 {status|cycle|json}" >&2
    exit 1
    ;;
esac
