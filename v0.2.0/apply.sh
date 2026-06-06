#!/usr/bin/env bash
# =============================================================================
# apply.sh — обновление существующего репо до v0.2.0
# =============================================================================
# Запускать ИЗ КОРНЯ репозитория nixos-config:
#   cd ~/nixos-config
#   bash /путь/к/v0.2.0/apply.sh
#
# Что делает:
#   1. Проверяет что мы в корне репо (есть flake.nix)
#   2. Делает бэкап custom/<host>.nix и hosts/<host>/ если они существуют
#   3. Удаляет старые файлы которые больше не существуют (main.nix, input.conf)
#   4. Копирует всё новое поверх
#   5. Возвращает бэкап custom/ и hosts/ на место (не должны были задеться)
#   6. Печатает резюме + следующие шаги
# =============================================================================
set -euo pipefail

if [[ ! -f "flake.nix" || ! -d "modules" ]]; then
  echo "Ошибка: запусти из корня репо nixos-config (там где flake.nix)" >&2
  exit 1
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$HERE/modules" || ! -f "$HERE/CHANGELOG.md" ]]; then
  echo "Ошибка: $HERE не похож на содержимое v0.2.0 tarball." >&2
  exit 1
fi

REPO="$PWD"

echo "=== Применяю v0.2.0 ==="
echo "Источник: $HERE"
echo "Цель:     $REPO"
echo

# ── Бэкапы локального ──────────────────────────────────────────────────────
BACKUP="$(mktemp -d /tmp/nixos-config-backup-XXXXXX)"
echo "[1/5] Бэкап локальных файлов в $BACKUP"
if [[ -d "$REPO/custom" ]]; then
  cp -r "$REPO/custom" "$BACKUP/custom"
fi
if [[ -d "$REPO/hosts" ]]; then
  cp -r "$REPO/hosts" "$BACKUP/hosts"
fi
if [[ -f "$REPO/flake.lock" ]]; then
  cp "$REPO/flake.lock" "$BACKUP/flake.lock"
fi

# ── Удаление файлов которые исчезли в v0.2.0 ───────────────────────────────
echo "[2/5] Удаляю файлы которые больше не существуют:"
removed=(
  "modules/system/main.nix"                              # разбит на 6 файлов
  "modules/user/dotfiles/hyprland/conf/input.conf"       # переименован в .in
)
for f in "${removed[@]}"; do
  if [[ -e "$REPO/$f" ]]; then
    rm -f "$REPO/$f"
    echo "    REMOVED: $f"
  fi
done

# ── Копируем всё новое поверх ──────────────────────────────────────────────
echo "[3/5] Копирую файлы v0.2.0:"
cd "$HERE"
# Все файлы кроме apply.sh и самого APPLY.md (то что в tarball'е, не в репо)
find . -type f ! -name apply.sh ! -name APPLY.md ! -path "./.git*" | while read -r src; do
  rel="${src#./}"
  dst="$REPO/$rel"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
done
echo "    скопировано $(find . -type f ! -name apply.sh ! -name APPLY.md | wc -l) файлов"

# ── Делаем скрипты исполняемыми ────────────────────────────────────────────
echo "[4/5] chmod +x для скриптов:"
chmod +x "$REPO/modules/user/dotfiles/hyprland/scripts/powerprofile.sh" 2>/dev/null || true
chmod +x "$REPO/modules/user/dotfiles/hyprland/scripts/volume.sh"       2>/dev/null || true
chmod +x "$REPO/modules/user/dotfiles/hyprland/scripts/wifi-menu.sh"    2>/dev/null || true

# ── Восстанавливаем локальное (не должно было задеться, но проверим) ───────
echo "[5/5] Восстановление локального из бэкапа (если что-то задело):"
cd "$REPO"
# custom/<host>.nix или custom/<host>/ — back-compat
if [[ -d "$BACKUP/custom" ]]; then
  for item in "$BACKUP/custom"/*; do
    name="$(basename "$item")"
    # Скип шаблонов и README — они приехали из v0.2.0
    if [[ "$name" == "README.md" || "$name" == "_example.nix" || "$name" == ".gitkeep" ]]; then
      continue
    fi
    cp -r "$item" "custom/$name"
  done
fi
# hosts/<host>/ — все кроме _template (он приехал из v0.2.0)
if [[ -d "$BACKUP/hosts" ]]; then
  for d in "$BACKUP/hosts"/*; do
    name="$(basename "$d")"
    if [[ "$name" == "_template" || "$name" == ".gitkeep" ]]; then
      continue
    fi
    cp -r "$d" "hosts/$name"
  done
fi
# flake.lock — оставляем твой, не перезатираем upstream'овским
if [[ -f "$BACKUP/flake.lock" ]]; then
  cp "$BACKUP/flake.lock" flake.lock
fi

echo
echo "=== v0.2.0 применён. Бэкап лежит в $BACKUP ==="
echo
cat << 'EOM'
Что дальше:

  1. Проверь изменения:
     git status
     git diff --stat

  2. ВНИМАНИЕ: если у тебя были правки в modules/system/main.nix —
     этого файла больше нет. Перенеси их в custom/<host>.nix как override.

  3. Войди в dev shell и прогони форматтер (опционально):
     nix develop
     nix fmt

  4. Применить:
     nrs

  5. Если всё ок — коммитим:
     git add -A
     git commit -m "release: 0.2.0 — DX + Architecture + Docs + Extras"
     git tag v0.2.0
     git push --tags origin main

  6. Бэкап можно удалить когда уверен что всё ок:
     rm -rf $BACKUP

Полное описание изменений — CHANGELOG.md, секция [0.2.0].
EOM
