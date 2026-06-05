# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [0.1.7] — 2026-06-05 (combined)

Большой релиз: Hyprland-полировка + декларативные уведомления + logout-меню +
node power-profiles-daemon + слой кастомизации с примерами.

### Added — Hyprland-полировка
- **`pyprland`** — Python-плагины:
  - `scratchpads.term` — терминал «quake-style» поверх всего, `Super+\``
  - `scratchpads.notes` — helix с `~/.notes.md`, `Super+Shift+N`
  - `smart_gaps` — gaps исчезают когда одно окно на воркспейсе
  - Конфиг: `modules/user/dotfiles/hyprland/pyprland.toml`
  - Autostart: `exec-once = pypr` в `autostart.conf`
- **`hyprshade`** — blue-light filter, бинд `Super+F11` toggle `blue-light-filter`
- **`wlogout`** — графическое logout-меню (Lock/Logout/Suspend/Hibernate/Reboot/Shutdown),
  Catppuccin Mocha-стайл, бинд `Ctrl+Alt+Delete`
  - Заменяет старый опасный `Super+Shift+M = exit`

### Added — Power-profiles-daemon (3-режима для всех машин)
- `services.power-profiles-daemon` включён через `modules/system/power-profiles.nix`
- Новые поля в `hosts/_template/settings.nix`:
  - `powerProfile = null` — `null` авто-выбор по `settings.profile`
    (laptop→balanced, desktop/server→performance), либо явный
    `"performance"`/`"balanced"`/`"powersave"`
  - `batteryChargeLimit = null` — `null` без лимита, или число 1-100 в %
- Бинды `Super+F1/F2/F3` (performance/balanced/powersave) с уведомлениями
- Waybar модуль `custom/powerprofile`: иконка текущего профиля, ЛКМ цикл,
  обновление каждые 5с
- Скрипт `~/.config/hypr/scripts/powerprofile.sh`: `status` / `cycle` / `tooltip`

### Added — Battery charge limit
- Кастомный systemd-сервис `battery-charge-limit` пишет порог в
  `/sys/class/power_supply/BAT*/charge_*_threshold`
- Активируется только когда `settings.batteryChargeLimit != null`
- Работает на ThinkPad, некоторых Dell/HP/Asus — где есть sysfs-узел
- На прочем железе тихо игнорируется

### Added — Декларативный mako
- `modules/user/ui/notifications.nix` — новый модуль
- `services.mako.settings` с top-right, 320×110, JetBrainsMono Nerd Font 11,
  5с обычные / 30с критичные, скруглённые углы

### Added — Декларативный nano
- `programs.nano.nanorc` в `tools/cli.nix`
- Номера строк, подсветка синтаксиса (sh/nix/python/json/md/...), мышь,
  softwrap, 4-space tabs

### Added — Слой персональных настроек (mutable файлы)
- `~/.config/fish/conf.d/local.fish` создаётся при первой установке как
  template с примерами (alias/abbr/функции/env), больше не трогается
  обновлениями. Fish сам подхватывает.
- `~/.config/hypr/user.conf` template расширен — теперь содержит подробные
  примеры: бинды, мониторы, env vars, windowrules, autostart, жесты.
  Подключается ПОСЛЕДНИМ в hyprland.conf — переопределяет любые defaults.

### Added — Слой системных оверрайдов (`custom/<host>.nix`)
- `custom/README.md` переписан с подробными примерами:
  - Добавить системные/user пакеты
  - Свои fish-алиасы декларативно
  - Включить дополнительный сервис
  - Принудительный override (`lib.mkForce`)
- `custom/_example.nix` — готовый template для копирования

### Changed — Бинды
| Что | Было | Стало |
|---|---|---|
| Терминал | `Super+Q` | **`Super+T`** |
| Закрыть окно | `Super+C` | **`Super+Q`** (graceful, respects tray) |
| Force-kill | — | **`Super+Shift+Q`** (новое, SIGKILL) |
| Logout меню | `Super+Shift+M = exit` (опасный!) | **`Ctrl+Alt+Delete = wlogout`** |
| Power performance | — | **`Super+F1`** |
| Power balanced | — | **`Super+F2`** |
| Power powersave | — | **`Super+F3`** |
| Hyprshade toggle | — | **`Super+F11`** |
| Scratchpad term | — | **`Super+\``** |
| Scratchpad notes | — | **`Super+Shift+N`** |

`Super+C` теперь свободен (был killactive).

### Removed
- **TLP** — заменён `power-profiles-daemon`. Charge thresholds через свой systemd-сервис.
- **`Super+Shift+M = exit`** — заменён на `Ctrl+Alt+Delete = wlogout`.

### Changed — архитектура
- `modules/user/ui/wofi.nix`: убран `services.mako.enable` (переехал в `notifications.nix`).
- `modules/user/home.nix`: добавлен импорт `./ui/notifications.nix`.
- `lib/mkHost.nix`: добавлен `../modules/system/power-profiles.nix` в список модулей.

### Что делать другу при обновлении

```fish
cd ~/nixos-config
git fetch upstream
git merge upstream/main

# Если хост настроен — заполни новые поля в settings.nix:
hx hosts/(hostname)/settings.nix
# Добавь:
#   powerProfile = null;
#   batteryChargeLimit = null;

nrs
```

После пересборки и перелогина в Hyprland:
- `~/.config/fish/conf.d/local.fish` появится с примерами
- `~/.config/hypr/user.conf` обновится с расширенными примерами (если ты
  не редактировал старый — он перезапишется новым шаблоном; если
  редактировал — старый останется, поскольку activation проверяет существование)

### Breaking changes
1. `services.tlp` убран — если в твоём `custom/<host>.nix` ты от него зависел,
   надо переключиться на `services.power-profiles-daemon` (или вернуть TLP
   в `custom/`).
2. `Super+Shift+M` больше не выходит из сессии. Используй `Ctrl+Alt+Delete`.
3. `Super+Q` больше не открывает kitty — теперь `Super+T`. Если привык —
   можно переопределить через `~/.config/hypr/user.conf`:
   ```
   unbind = SUPER, T
   unbind = SUPER, Q
   bind = SUPER, Q, exec, kitty
   bind = SUPER, C, killactive
   ```

---

## [0.1.6] — 2026-06-05

### Fixed
- Громкость не выше 100% через `volume.sh` (cap + auto-mute at 0)
- Иконка mute вместо текста, `windowrulev2` → `windowrule`

### Added
- Backlight + Bluetooth waybar модули, кликабельность всего, tooltips,
  wifi-меню через wofi, networkmanagerapplet в трее

---

## [0.1.5] — 2026-06-05

### Changed
- Тачпад: `clickfinger_behavior = false` → button-areas режим

---

## [0.1.4] — 2026-06-05

### Fixed
- "Белая Thunar": `Adwaita-dark` → `adw-gtk3-dark`
- `workspace_swipe = true` (deprecated) → `gesture = ...`

### Added
- Qt theming, nwg-look, Papirus иконки, 3-пальцевые жесты

---

## [0.1.3] — 2026-06-05

### Added
- Дефолтные обои Catppuccin, комментарии в `binds.conf`

### Changed
- Реструктура `dotfiles/hyprland/`: `idle/`, `conf/profile/`, `wallpapers/`

---

## [0.1.2] — 2026-06-05

### Added
- Профильное idle, lid switch без suspend

---

## [0.1.1] — 2026-06-05

### Fixed
- noto-fonts-color-emoji, tuigreet, thunar, catppuccin.autoEnable

### Changed
- flake description, fish-алиасы → `~/nixos-config/`

---

## [0.1.0] — Initial release

Multi-host архитектура, Catppuccin, Hyprland-стек.

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
