#!/usr/bin/env bash
# =============================================================================
# wifi-menu.sh — выбор WiFi сети через wofi
# =============================================================================
# Открывается по клику на иконке сети в waybar.
# Использует nmcli для списка/подключения и wofi для выбора.
# Если сеть требует пароль и в системе его ещё нет — попросит ввести
# через wofi --password.
# =============================================================================
set -euo pipefail

NOTIFY() { command -v notify-send >/dev/null 2>&1 && notify-send "WiFi" "$1" || true; }

# 1. Спровоцировать пересканирование (не ждём результат, он подтянется)
nmcli device wifi rescan >/dev/null 2>&1 || true

# 2. Если wifi выключен — предложить только включение
wifi_state=$(nmcli radio wifi)
if [[ "$wifi_state" == "disabled" ]]; then
  choice=$(printf "Включить WiFi\nОтмена" | wofi --dmenu --prompt="WiFi выключен" --hide-search)
  case "$choice" in
    "Включить WiFi") nmcli radio wifi on; NOTIFY "Включён" ;;
    *) exit 0 ;;
  esac
  sleep 1
fi

# 3. Собрать список сетей
networks=$(
  nmcli --terse --fields IN-USE,SSID,SIGNAL,SECURITY device wifi list \
  | awk -F: '
      $2 == "" || $2 ~ /^--/ { next }
      {
        # IN-USE: "*" — текущее подключение
        # SECURITY: "" или "--" = открытая, иначе защищённая
        mark = ($1 == "*") ? "✓ " : "  "
        sec  = ($4 == "" || $4 == "--") ? "  " : "  "
        printf "%s%s%s  %d%%\n", mark, sec, $2, $3
      }
    ' \
  | sort -u
)

if [[ -z "$networks" ]]; then
  NOTIFY "Нет доступных сетей"
  exit 1
fi

# 4. Добавить служебные пункты
menu="$networks"$'\n──────────\nВыключить WiFi\nОткрыть настройки сети'

# 5. Показать в wofi
chosen=$(echo "$menu" | wofi --dmenu --prompt="WiFi" --width 400 --hide-search)
[[ -z "$chosen" ]] && exit 0

case "$chosen" in
  "Выключить WiFi")
    nmcli radio wifi off
    NOTIFY "Выключен"
    exit 0
    ;;
  "Открыть настройки сети")
    nm-connection-editor &
    exit 0
    ;;
  ──*) exit 0 ;;
esac

# 6. Извлечь SSID из строки выбора. Формат: "ME SEC  SSID  XX%"
#    Срезаем первые 6 символов (метки) и хвост " XX%"
ssid=$(echo "$chosen" | sed -E 's/^.{6}//; s/  [0-9]+%$//')

# 7. Известная сеть? Просто подключаемся
if nmcli --terse connection show | grep -qE "^${ssid}:"; then
  nmcli connection up "$ssid" >/dev/null 2>&1 && \
    NOTIFY "Подключено: $ssid" || \
    NOTIFY "Не удалось подключиться к $ssid"
  exit 0
fi

# 8. Новая сеть — определяем, нужен ли пароль
needs_password=$(nmcli --terse --fields SSID,SECURITY device wifi list | \
  awk -F: -v s="$ssid" '$1 == s { if ($2 == "" || $2 == "--") print "no"; else print "yes"; exit }')

if [[ "$needs_password" == "yes" ]]; then
  pass=$(wofi --dmenu --password --prompt="Пароль для $ssid")
  [[ -z "$pass" ]] && exit 0
  if nmcli device wifi connect "$ssid" password "$pass" >/dev/null 2>&1; then
    NOTIFY "Подключено: $ssid"
  else
    NOTIFY "Не удалось подключиться к $ssid — возможно неверный пароль"
  fi
else
  if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
    NOTIFY "Подключено: $ssid"
  else
    NOTIFY "Не удалось подключиться к $ssid"
  fi
fi
