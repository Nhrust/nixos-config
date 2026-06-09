#!/usr/bin/env bash
# =============================================================================
# scripts/prep-disk.sh — Подготовка диска перед disko (v0.5.1+)
# =============================================================================
# Решает типичные причины зависания disko на этапе разметки:
#   - остатки старых GPT/MBR подписей и backup-GPT в конце диска
#   - активный swap занимающий часть диска
#   - открытые LUKS контейнеры
#   - активные LVM volume groups
#   - смонтированные сабволюмы из предыдущей попытки установки
#
# Использование:
#   sudo bash scripts/prep-disk.sh /dev/nvme0n1
#
# Что делает (8 шагов):
#   1. swapoff -a                        — выключает весь swap
#   2. umount -R /mnt                    — отмонтирует остатки прошлой попытки
#   3. cryptsetup close /dev/mapper/*    — закрывает LUKS
#   4. vgchange -an                      — деактивирует LVM
#   5. mdadm --stop --scan               — останавливает mdraid
#   6. wipefs -af <disk>                 — стирает все ФС-подписи
#   7. sgdisk --zap-all <disk>           — уничтожает GPT и backup-GPT в конце
#   8. partprobe + udevadm settle        — обновляет таблицу разделов в ядре
#
# Защита:
#   - Проверяет что путь — блочное устройство
#   - Проверяет что диск НЕ примонтирован в активной системе (иначе ты
#     запускаешь скрипт из работающей ОС которая сейчас работает с этого
#     диска — стерев его, ты убьёшь свою же ОС)
#   - Требует ввести точный путь диска для подтверждения (не "yes")
# =============================================================================
set -euo pipefail

# ── Проверки окружения ──────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "Ошибка: нужны права root. Запусти: sudo bash $0 /dev/<disk>" >&2
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "Использование: sudo bash $0 /dev/<disk>" >&2
  echo "Пример:        sudo bash $0 /dev/nvme0n1" >&2
  echo "               sudo bash $0 /dev/sda" >&2
  exit 1
fi

DISK="$1"

if [[ ! -b "$DISK" ]]; then
  echo "Ошибка: $DISK не существует или не блочное устройство." >&2
  echo "Доступные диски:" >&2
  lsblk -d -o NAME,SIZE,MODEL,TRAN >&2
  exit 1
fi

# ── КРИТИЧЕСКАЯ ЗАЩИТА: диск не должен использоваться активной системой ─────
# Если запускается из загруженной ОС (не с LiveCD), активные mount points
# означают что мы сейчас работаем с этого диска. Стерев его — убьём ОС.
mounted_points="$(lsblk -no MOUNTPOINTS "$DISK" 2>/dev/null | grep -v '^$' || true)"
if [[ -n "$mounted_points" ]]; then
  echo "==========================================================" >&2
  echo "  СТОП! $DISK сейчас используется активной системой." >&2
  echo "==========================================================" >&2
  echo >&2
  echo "Активные mount points на этом диске:" >&2
  while IFS= read -r mp; do
    echo "  $mp" >&2
  done <<< "$mounted_points"
  echo >&2
  echo "Это означает что ты запустил скрипт из ОС которая сейчас" >&2
  echo "работает с этого диска. Стерев его, ты убьёшь свою же" >&2
  echo "систему." >&2
  echo >&2
  echo "Что делать:" >&2
  echo "  1. Загрузись с NixOS LiveCD/USB (minimal ISO)" >&2
  echo "  2. Подключи сеть, склонируй репо в /tmp/" >&2
  echo "  3. Запусти этот скрипт оттуда" >&2
  exit 2
fi

# Дополнительно проверим что и партиции этого диска не примонтированы
# (защита от типа /dev/sda — сам диск без mount но /dev/sda1 примонтирован)
partitions_mounted="$(lsblk -no NAME,MOUNTPOINTS "$DISK" | awk 'NF==2 {print $1": "$2}' || true)"
if [[ -n "$partitions_mounted" ]]; then
  echo "==========================================================" >&2
  echo "  СТОП! Партиции $DISK примонтированы:" >&2
  echo "==========================================================" >&2
  while IFS= read -r line; do
    echo "  $line" >&2
  done <<< "$partitions_mounted"
  echo >&2
  echo "Загрузись с LiveCD и попробуй оттуда." >&2
  exit 2
fi

# ── Сводка перед действием ──────────────────────────────────────────────────
size="$(lsblk -dno SIZE "$DISK")"
model="$(lsblk -dno MODEL "$DISK" 2>/dev/null | tr -s ' ' || echo 'unknown')"

cat << EOF

==========================================================
  PREP-DISK — подготовка диска к разметке через disko
==========================================================

Диск:     $DISK
Размер:   $size
Модель:   $model

Текущее состояние:
EOF
lsblk "$DISK"
cat << EOF

Скрипт выполнит ВОСЕМЬ шагов очистки и подготовки:
  1. swapoff -a
  2. umount -R /mnt (если что-то примонтировано после прошлой попытки)
  3. cryptsetup close /dev/mapper/* (закрыть открытые LUKS контейнеры)
  4. vgchange -an (деактивировать LVM volume groups)
  5. mdadm --stop --scan (остановить mdraid массивы)
  6. wipefs -af $DISK (стереть все ФС подписи)
  7. sgdisk --zap-all $DISK (уничтожить GPT таблицу и её backup в конце диска)
  8. partprobe + udevadm settle (обновить таблицу разделов в ядре)

ВСЕ ДАННЫЕ НА $DISK БУДУТ БЕЗВОЗВРАТНО СТЁРТЫ.

EOF
echo -n "Для подтверждения введи точный путь диска ($DISK): "
read -r confirm
if [[ "$confirm" != "$DISK" ]]; then
  echo "Подтверждение не совпало («$confirm» != «$DISK»). Отмена." >&2
  exit 3
fi
echo

# ── Выполнение ──────────────────────────────────────────────────────────────

step() { echo "[$1/8] $2"; }

step 1 "swapoff -a"
swapoff -a 2>/dev/null || true

step 2 "umount -R /mnt (если есть)"
umount -R /mnt 2>/dev/null || true

step 3 "cryptsetup close /dev/mapper/* (LUKS)"
for mapper in /dev/mapper/*; do
  name="$(basename "$mapper")"
  [[ "$name" == "control" ]] && continue
  [[ ! -b "$mapper" ]] && continue
  cryptsetup close "$name" 2>/dev/null || true
done

step 4 "vgchange -an (деактивация LVM)"
vgchange -an 2>/dev/null || true

step 5 "mdadm --stop --scan (остановка mdraid)"
mdadm --stop --scan 2>/dev/null || true

step 6 "wipefs -af $DISK (стирание подписей)"
wipefs -af "$DISK"

step 7 "sgdisk --zap-all $DISK (уничтожение GPT и backup-GPT)"
sgdisk --zap-all "$DISK" >/dev/null

step 8 "partprobe + udevadm settle"
partprobe "$DISK" 2>/dev/null || true
sleep 2
udevadm settle

cat << EOF

✓ Диск $DISK подготовлен. Подписи стёрты, ядро увидело пустую таблицу.

Дальше:

  # Из корня репо nixos-config:
  nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \\
    --mode disko --flake "path:.#<hostname>"

(подставь имя хоста из своей hosts/<имя>/settings.nix → hostname)

Если disko снова зависнет — это уже железо/драйвер (см. docs/TROUBLESHOOTING.md
секция «Disko завис при установке»).
EOF
