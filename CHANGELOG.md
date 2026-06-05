# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [0.1.4] — 2026-06-05

### Fixed
- **GTK тема: «белая Thunar».** В `modules/user/theme.nix` имя GTK темы было
  `Adwaita-dark`, но пакет `adw-gtk3` поставляет темы под именами
  `adw-gtk3` и `adw-gtk3-dark`. GTK не находил `Adwaita-dark` и сваливался
  на дефолт (светлый Adwaita) — отсюда белые окна Thunar. Имя исправлено,
  выбирается автоматически по `settings.theme`.
- **Deprecated gestures syntax в `input.conf`.** Опции `workspace_swipe = true`
  и `workspace_swipe_fingers = 3` были выпилены в Hyprland 0.51 (сентябрь 2025).
  Они и были причиной error-плашки сверху экрана. Заменены на новый синтаксис
  `gesture = <fingers>, <direction>, <action>`.

### Added
- **Полное покрытие Qt тем.** В `theme.nix` добавлено:
  - `qt.enable = true` с `platformTheme.name = "kvantum"` и `style.name = "kvantum"`
  - пакеты `qt5ct`, `qt6ct`, `qtstyleplugin-kvantum` для Qt5 и Qt6
  - Catppuccin-Kvantum тема подключается автоматически через `catppuccin.autoEnable`
- **`nwg-look`** для GUI-настройки GTK тем/шрифтов/курсоров на лету.
- **GTK4/libadwaita color-scheme** — `gtk-application-prefer-dark-theme`
  прописывается в gtk3 и gtk4 конфигах, чтобы GTK4-приложения тоже
  переключались в тёмный режим.
- **Иконки Papirus** — `Papirus-Dark` / `Papirus-Light` по теме.
- **Жесты тачпада на 3 пальца** в `input.conf`:
  - горизонталь → переключение воркспейсов (как раньше, но новый синтаксис)
  - вверх → fullscreen активного окна
  - вниз → togglefloating (tile ↔ float)
- **Явный `tap_button_map = lrm`** в touchpad — гарантирует, что
  2 пальца тапом = ПКМ, 3 пальца = СКМ, независимо от системного дефолта.

### Removed
- **Файл-сирота `modules/user/dotfiles/hyprland/hypridle.conf`** — остаток
  от эпохи до 0.1.2, на него ничего не ссылалось.

### Что делать другу при обновлении
```bash
cd ~/nixos-config
git fetch upstream
git merge upstream/main
nrs
```
После пересборки и нового логина в Hyprland:
- Thunar и другие GTK3-приложения должны быть в тёмной теме (или светлой, по `settings.theme`).
- Qt-приложения (`pavucontrol`, `kdenlive`, и т.п.) подхватывают Catppuccin через Kvantum.
- Error-плашка от устаревших gesture-опций должна исчезнуть.
- 3-пальцевые жесты тачпада начинают работать сразу.

Если тема Qt не подцепилась — проверь:
```bash
echo $QT_QPA_PLATFORMTHEME    # должно быть "kvantum"
echo $QT_STYLE_OVERRIDE       # должно быть "kvantum" или пусто
ls ~/.config/Kvantum/         # должна быть kvantum.kvconfig с Catppuccin
```

---

## [0.1.3] — 2026-06-05

### Added
- **Дефолтные обои Catppuccin** — `wallpapers/default-dark.png` и
  `wallpapers/default-light.png`. Копируется в `~/Pictures/wallpaper.png`
  при первой установке.
- **Комментарии в `conf/binds.conf`** — каждый бинд подписан.

### Changed
- **Реструктура `dotfiles/hyprland/`**:
  - `hypridle-{laptop,desktop,server}.conf` → `idle/{laptop,desktop,server}.conf`
  - `conf/profile-{laptop,desktop,server}.conf` → `conf/profile/{laptop,desktop,server}.conf`
- `modules/user/ui/hyprland.nix` — обновлены пути, добавлен activation-скрипт обоев.

---

## [0.1.2] — 2026-06-05

### Added
- **Профильное idle** — `hypridle.conf` по `settings.profile`:
  - `laptop` → 3 минуты → экран гаснет + лок
  - `desktop` → 5 минут → экран гаснет + лок
  - `server` → только ручной лок
- **Закрытие крышки на ноутбуке** — гасит и лочит, но не суспендит
  (`services.logind.lidSwitch* = "ignore"` + `bindl=,switch:on:Lid Switch`).

### Removed
- Старый общий `modules/user/dotfiles/hyprland/hypridle.conf` (заменён вариантами).

---

## [0.1.1] — 2026-06-05

### Fixed
- `noto-fonts-emoji` → `noto-fonts-color-emoji`.
- `${pkgs.greetd.tuigreet}` → `${pkgs.tuigreet}`.
- `xfce.thunar` → `programs.thunar.enable = true` + плагины.
- `catppuccin.autoEnable = true` явно.

### Changed
- `flake.nix` description: `trefa-nixos` → `nixos-config`.
- `fish.nix` алиасы `~/nixos-config/` вместо `~/trefa-nixos/`.

---

## [0.1.0] — Initial release

Multi-host архитектура, авто-сканирование hosts/, поддержка custom/,
Catppuccin через catppuccin-nix flake input. CPU AMD/Intel, GPU
AMD/Intel/Nvidia, профили laptop/desktop/server.

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
