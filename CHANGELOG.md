# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

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
