# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

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
так как `user.conf` подключается последним. Но если был
`xdg.configFile."hypr/hypridle.conf"` в custom — теперь его источник
перекрывает выбранный профильный вариант (это и должно быть желаемым).

### Что делать другу при обновлении
```bash
cd ~/nixos-config
git fetch upstream
git merge upstream/main
nrs
```
После пересборки и нового логина в Hyprland — поведение idle подхватится
автоматически по `settings.profile`. Для проверки lid switch на ноуте:
закрой крышку → экран должен погаснуть и появиться lock-screen, но машина
не уснёт. Имя устройства lid switch можно проверить через `hyprctl devices`
если экран не гаснет при закрытии (см. комментарий в `conf/profile-laptop.conf`).

---

## [0.1.1] — 2026-06-05

### Fixed
- **fonts:** `noto-fonts-emoji` переименован в `noto-fonts-color-emoji`
  (deprecation в nixpkgs). Файл `modules/system/ui/fonts.nix`.
- **session:** `${pkgs.greetd.tuigreet}` → `${pkgs.tuigreet}` (пакет
  больше не лежит под префиксом `greetd.*`). Файл `modules/system/ui/session.nix`.
- **session:** `xfce.thunar` в `environment.systemPackages` заменён на
  модуль `programs.thunar.enable = true` с плагинами `thunar-volman` и
  `thunar-archive-plugin`. Добавлены `services.gvfs.enable` и
  `services.tumbler.enable` — нужны для корзины, MTP, превью.
  Файл `modules/system/ui/session.nix`.
- **theme:** `catppuccin.autoEnable` теперь задан явно (`= true`) —
  убирает предупреждение от модуля catppuccin-nix.
  Файл `modules/user/theme.nix`.

### Changed
- **flake:** поле `description` обновлено со старого `trefa-nixos` на
  `nixos-config — multi-host NixOS дистрибутив`.
- **fish:** алиасы `nrs`, `nrb`, `nfu` теперь используют путь
  `~/nixos-config/` вместо `~/trefa-nixos/`. Под friend-friendly путь по
  умолчанию (клонирование в `~/nixos-config`).

### Docs
- `hosts/_template/settings.nix`: ссылка на несуществующий
  `docs/HIBERNATION.md` заменена на `docs/POST_INSTALL.md` (раздел 6).
- Заголовочные комментарии в 10 файлах `modules/` приведены в
  соответствие с реальными путями после рефакторинга в подпапки
  (`shell/`, `tools/`, `ui/`, `services/`).

### Breaking
Нет. Все правки внутренние или косметические; пользовательские
`settings.nix` и `custom/<name>.nix` не затронуты.

### Что делать другу при обновлении
```bash
cd ~/nixos-config
git fetch upstream
git merge upstream/main
nrs   # или: sudo nixos-rebuild switch --flake .#$(hostname)
```
Если ты клонировал репо как `~/trefa-nixos`, переименуй папку:
```bash
mv ~/trefa-nixos ~/nixos-config
```
Иначе обновлённые алиасы `nrs`/`nrb`/`nfu` не найдут flake.

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

### Параметры в settings.nix
- `username`, `hostname`, `timezone`
- `extraLocale` — опциональная вторая локаль
- `cpu`, `gpu`, `profile`
- `disk`, `swapSize`, `diskMode` (wipe / existing)
- `diskPartBoot`, `diskPartRoot` (для existing)
- `resumeOffset`, `rootUUID` (для гибернации)
- `virtualization`, `printing`, `bluetooth`
- `theme` (dark/light), `themeAccent`
- `gitName`, `gitEmail`

### Базовые алиасы
- `nrs` / `nrb` / `nrl` / `nfu` / `ngc` — управление NixOS
- `cat→bat`, `ls→eza`, `grep→rg`, `find→fd`, `cd→z` — замены команд
- `g` / `gs` / `gp` / `gl` / `gcl` — git

---

## Формат записей в будущем

```
## [версия] — дата

### Added — новые фичи
### Changed — изменения существующего
### Deprecated — что будет удалено
### Removed — что удалено
### Fixed — исправления багов
### Breaking — что ломает обратную совместимость (требует внимания при обновлении)
```
