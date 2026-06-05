# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [0.1.3] — 2026-06-05

### Added
- **Дефолтные обои Catppuccin** — `wallpapers/default-dark.png` и
  `wallpapers/default-light.png` в `modules/user/dotfiles/hyprland/`.
  Подбирается по `settings.theme` и копируется (не симлинком!) в
  `~/Pictures/wallpaper.png` при первой установке. Замена пользовательской
  картинкой переживает `git pull` и `nrs`.
- **Комментарии в `conf/binds.conf`** — каждый бинд теперь подписан,
  плюс шапка с объяснением `bind` vs `bindm` vs `bindl` vs `bindel`.

### Changed
- **Реструктура `dotfiles/hyprland/`** — профильные конфиги ушли в подпапки:
  - `hypridle-{laptop,desktop,server}.conf` → `idle/{laptop,desktop,server}.conf`
  - `conf/profile-{laptop,desktop,server}.conf` → `conf/profile/{laptop,desktop,server}.conf`
- **`modules/user/ui/hyprland.nix`** — пути источников обновлены под новую
  структуру, добавлен селектор обоев и второй activation-скрипт для
  копирования дефолтной обоины.

### Breaking
Нет в смысле поведения. Если у кого-то были собственные оверрайды
`xdg.configFile."hypr/hypridle.conf"` или `"hypr/conf/profile.conf"` в
`custom/<host>.nix` — они продолжают работать (мы не меняли destination,
только source). Старые файлы `hypridle-*.conf` и `conf/profile-*.conf`
удаляются из репо — но они уже не упоминаются нигде в коде.

### Что делать другу при обновлении
```bash
cd ~/nixos-config
git fetch upstream
git merge upstream/main
nrs
# Перелогиниться в Hyprland — home-manager перемонтирует ~/.config/hypr/
# При первой установке после обновления появится ~/Pictures/wallpaper.png
# с дефолтной обоиной (если файла там ещё не было).
```

---

## [0.1.2] — 2026-06-05

### Added
- **Профильное поведение idle** — `hypridle.conf` теперь выбирается по
  `settings.profile`:
  - `laptop`  → 3 минуты простоя → экран гаснет И сессия лочится
  - `desktop` → 5 минут простоя → экран гаснет И сессия лочится
  - `server`  → автоматический idle отключён, ручной lock работает
- **Закрытие крышки на ноутбуке** — экран гаснет, сессия лочится,
  но машина НЕ суспендится. Wifi, музыка, фоновая компиляция продолжают
  работать. Реализовано двумя слоями:
  - `services.logind.lidSwitch* = "ignore"` в `modules/system/profiles/laptop.nix`
  - `bindl=,switch:on:Lid Switch,exec,...` в новом `conf/profile-laptop.conf`
- **Профильные конфиги Hyprland** — новый файл `conf/profile.conf`
  подключается из главного `hyprland.conf` и автоматически указывает на
  `conf/profile-{laptop,desktop,server}.conf`.

### Changed
- `modules/user/ui/hyprland.nix` теперь принимает `settings` в аргументах
  и собирает source-пути для `hypridle.conf` и `conf/profile.conf`
  через интерполяцию `settings.profile`.

### Removed
- Старый общий `modules/user/dotfiles/hyprland/hypridle.conf` удалён —
  заменён тремя профильными вариантами (`hypridle-{laptop,desktop,server}.conf`).

### Breaking
Если кто-то из друзей переопределял у себя `hypridle.conf` через
`custom/<host>.nix` или `~/.config/hypr/user.conf` — поведение не меняется,
так как `user.conf` подключается последним.

---

## [0.1.1] — 2026-06-05

### Fixed
- **fonts:** `noto-fonts-emoji` переименован в `noto-fonts-color-emoji`.
- **session:** `${pkgs.greetd.tuigreet}` → `${pkgs.tuigreet}`.
- **session:** `xfce.thunar` → `programs.thunar.enable = true` + плагины,
  gvfs, tumbler.
- **theme:** `catppuccin.autoEnable = true` задан явно.

### Changed
- `flake.nix` description: `trefa-nixos` → `nixos-config`.
- `fish.nix` алиасы используют `~/nixos-config/` вместо `~/trefa-nixos/`.

### Docs
- `hosts/_template/settings.nix`: ссылка на `docs/POST_INSTALL.md §6` вместо
  несуществующего `docs/HIBERNATION.md`.
- Заголовочные комментарии в 10 файлах модулей приведены к актуальным путям.

---

## [0.1.0] — Initial release

### Архитектура
- Multi-host через `hosts/<имя>/`
- Авто-сканирование папок в `flake.nix` через `lib/mkHost.nix`
- Поддержка `custom/<имя>.nix` для опциональных кастомизаций
- Catppuccin тема через `catppuccin-nix` flake input

### Поддерживаемое железо
- CPU: AMD, Intel
- GPU: AMD (Mesa/RADV), Intel, Nvidia (proprietary)
- Профили: laptop, desktop, server
- Опционально: virtualization, printing, bluetooth

### Софт в базе
- **Hyprland стек:** hyprland, waybar, wofi, mako, hyprlock, hypridle, hyprpaper
- **Аудио:** PipeWire (alsa/pulse/jack) + wireplumber + pavucontrol
- **Сессия:** greetd + tuigreet
- **GUI:** kitty, firefox, thunar
- **Консоль:** fish, helix, tmux, bat, eza, fzf, zoxide, yazi, fd, ripgrep, btop, duf, dust, lazygit, direnv

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
