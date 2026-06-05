# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [0.1.5] — 2026-06-05

### Changed
- **Тачпад: физический клик переключён в режим button-areas.**
  В `modules/user/dotfiles/hyprland/conf/input.conf` опция
  `clickfinger_behavior` теперь `false`. Это означает:
  - Раньше (`true`, режим clickfinger): кнопку определяло **число пальцев**
    (1 палец = ЛКМ, 2 пальца = ПКМ).
  - Теперь (`false`, режим button-areas): кнопку определяет **где ты кликнул**
    физически на тачпаде:
    - нижний-левый угол → ЛКМ
    - нижний-правый угол → ПКМ
    - нижний-центральный → СКМ
  - Tap-to-click и `tap_button_map = lrm` не затронуты — двойной тап
    одним пальцем продолжает работать как ПКМ.

### Что делать другу при обновлении
```bash
cd ~/nixos-config
git fetch upstream
git merge upstream/main
nrs
```
Перелогиниваться в Hyprland не обязательно — `hyprctl reload` подхватит
новый input.conf на лету.

---

## [0.1.4] — 2026-06-05

### Fixed
- **«Белая Thunar»:** `theme.name = "Adwaita-dark"` → `adw-gtk3-dark`/`adw-gtk3`
  по `settings.theme`. Пакет `adw-gtk3` не поставляет тему `Adwaita-dark`.
- **Error-плашка от Hyprland:** `workspace_swipe = true` и
  `workspace_swipe_fingers = 3` (deprecated в Hyprland 0.51+) заменены
  на новый синтаксис `gesture = ...`.

### Added
- Qt theming: Kvantum + `qt5ct`/`qt6ct` + Catppuccin-Kvantum через
  `catppuccin.autoEnable`.
- `nwg-look` для GUI-настройки GTK.
- Иконки Papirus (Dark/Light по теме).
- GTK4/libadwaita `prefer-dark-theme` в gtk3/gtk4 extraConfig.
- 3-пальцевые жесты тачпада: ←/→ воркспейсы, ↑ fullscreen, ↓ togglefloating.
- Явный `tap_button_map = lrm` для tap-to-click.

### Removed
- Файл-сирота `modules/user/dotfiles/hyprland/hypridle.conf` (от 0.1.1).

---

## [0.1.3] — 2026-06-05

### Added
- Дефолтные обои Catppuccin (`wallpapers/default-{dark,light}.png`).
- Комментарии в `conf/binds.conf` для каждого бинда.

### Changed
- Реструктура `dotfiles/hyprland/`: `hypridle-*.conf` → `idle/*.conf`,
  `conf/profile-*.conf` → `conf/profile/*.conf`.

---

## [0.1.2] — 2026-06-05

### Added
- Профильное idle поведение и закрытие крышки на ноутбуке.

### Removed
- Старый общий `hypridle.conf`, заменён вариантами.

---

## [0.1.1] — 2026-06-05

### Fixed
- `noto-fonts-color-emoji`, `pkgs.tuigreet` (без greetd.), `programs.thunar`,
  `catppuccin.autoEnable = true`.

### Changed
- `flake.nix` description: `trefa-nixos` → `nixos-config`.
- `fish.nix` алиасы используют `~/nixos-config/`.

---

## [0.1.0] — Initial release

Multi-host архитектура, Catppuccin, Hyprland-стек, поддержка AMD/Intel/Nvidia,
профили laptop/desktop/server.

---

## Формат записей в будущем

```
## [версия] — дата

### Added — новые фичи
### Changed — изменения существующего
### Deprecated — что будет удалено
### Removed — что удалено
### Fixed — исправления багов
### Breaking — что ломает обратную совместимость
```
