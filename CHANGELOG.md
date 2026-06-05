# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [0.1.6] — 2026-06-05

### Fixed
- **Громкость не выше 100%** — `XF86AudioRaiseVolume` теперь идёт через
  скрипт `~/.config/hypr/scripts/volume.sh up`, который использует
  `wpctl set-volume -l 1.0` (лимит 100%). Плюс `max-volume: 100` в waybar.
- **Auto-mute при громкости 0** — скрипт `volume.sh down` после понижения
  проверяет уровень, и если стал 0.00 — выставляет mute. Waybar тогда
  показывает иконку перечёркнутого динамика, а не "0%".
- **Иконка mute вместо текста** — в `pulseaudio.format-muted` теперь
  одна глифа () без слова "muted".
- **windowrulev2 → windowrule** — Hyprland 0.53+ unified синтаксис, старая
  `windowrulev2` deprecated. Migrated all 11 правил в `windowrules.conf`.
  Это должно убрать часть оставшейся error-плашки.

### Added
- **Backlight модуль в waybar** — иконка + процент яркости, колесо мыши
  крутит ±5%. Модуль показывается только когда есть backlight интерфейс
  (т.е. на ноутбуках; на десктопах не появится).
- **Bluetooth модуль в waybar** — иконка состояния (вкл/выкл/подключено).
  ЛКМ — `blueman-manager`, ПКМ — `rfkill toggle bluetooth`.
  Если в `settings.bluetooth = false`, модуль покажет "off" и не будет
  ни на что реагировать.
- **Кликабельность всех модулей**:
  - Часы — ЛКМ переключает между коротким/длинным форматом
  - Backlight — колесо мыши крутит яркость
  - Громкость — ЛКМ pavucontrol, ПКМ mute, колесо ±5%
  - Bluetooth — ЛКМ blueman-manager, ПКМ rfkill
  - Сеть — ЛКМ `~/.config/hypr/scripts/wifi-menu.sh` (выбор WiFi через wofi),
    ПКМ `nm-connection-editor`
  - CPU/RAM — ЛКМ открывает btop в kitty
- **Tooltips** на ховер для всех модулей — детали (полная дата,
  имя интерфейса, IP, USB battery и т.п.)
- **WiFi-меню через wofi** — `scripts/wifi-menu.sh` показывает доступные
  сети с уровнем сигнала и индикатором защиты (🔒/🔓), позволяет
  подключиться (с запросом пароля если нужно), переключить WiFi off/on,
  открыть nm-connection-editor.
- **Volume control скрипт** — `scripts/volume.sh up|down|mute` с capping
  и auto-mute, описан выше.
- **`networkmanagerapplet`** добавлен в `modules/user/ui/waybar.nix`,
  плюс `services.network-manager-applet.enable = true` — даёт системный
  апплет в трей для подтверждения подключений и быстрых переключений.

### Changed
- **Иконки сети без текста**:
  - `format-wifi`: " {signalStrength}%" — только глифа + сигнал
  - `format-ethernet`: "" — только глифа
  - `format-disconnected`: "" — перечёркнутая
- **CSS-цвета для состояний** — `#pulseaudio.muted`, `#network.disconnected`,
  `#bluetooth.disabled` и `.off` стилизованы в серый (Catppuccin overlay0),
  активные индикаторы остаются базовым text-цветом.

### Что делать другу при обновлении

```fish
cd ~/nixos-config
git fetch upstream
git merge upstream/main
nrs
```

После пересборки перелогинься в Hyprland — home-manager переразложит
конфиги waybar и hyprland. Скрипты появятся в `~/.config/hypr/scripts/`
с правами на выполнение.

### Проверки после применения

```fish
# 1. Скрипты на месте и исполняемые
ls -la ~/.config/hypr/scripts/
# volume.sh и wifi-menu.sh с x-битом

# 2. Громкость не поднимается выше 100% (физическая Fn+F+)
# 3. Когда опустишь до 0 — waybar показывает иконку mute (одну глифу)

# 4. Hyprctl reload не пишет про deprecated windowrulev2
hyprctl reload 2>&1 | grep -i "deprecat\|invalid"

# 5. Тычь по иконкам в waybar:
#    - сеть → wifi-меню в wofi
#    - bluetooth → blueman-manager (если settings.bluetooth = true)
#    - громкость → pavucontrol
#    - CPU/RAM → btop в kitty
```

---

## [0.1.5] — 2026-06-05

### Changed
- Тачпад: `clickfinger_behavior = false` → button-areas режим (нижний-левый = ЛКМ, нижний-правый = ПКМ).

---

## [0.1.4] — 2026-06-05

### Fixed
- «Белая Thunar»: `Adwaita-dark` → `adw-gtk3-dark` по `settings.theme`.
- Error-плашка Hyprland: deprecated `workspace_swipe = true` → новый `gesture = ...` синтаксис.

### Added
- Qt theming (Kvantum + qt5ct/qt6ct), nwg-look, Papirus иконки,
  3-пальцевые жесты тачпада, явный tap_button_map = lrm.

### Removed
- Файл-сирота `hypridle.conf` от 0.1.1.

---

## [0.1.3] — 2026-06-05

### Added
- Дефолтные обои Catppuccin, комментарии в `binds.conf`.

### Changed
- Реструктура `dotfiles/hyprland/`: `idle/`, `conf/profile/`, `wallpapers/`.

---

## [0.1.2] — 2026-06-05

### Added
- Профильное idle поведение и закрытие крышки на ноутбуке.

---

## [0.1.1] — 2026-06-05

### Fixed
- `noto-fonts-color-emoji`, `pkgs.tuigreet`, `programs.thunar`, `catppuccin.autoEnable = true`.

### Changed
- `flake.nix` description: `trefa-nixos` → `nixos-config`.
- fish-алиасы используют `~/nixos-config/`.

---

## [0.1.0] — Initial release

Multi-host архитектура, Catppuccin, Hyprland-стек, AMD/Intel/Nvidia,
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
