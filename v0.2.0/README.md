# ❄️ nixos-config

Минималистичный воспроизводимый NixOS-дистрибутив на базе Flakes, Home Manager,
disko и catppuccin-nix. Multi-host, разворачивается одной командой, обновляется
без боли, делится с друзьями без раскрытия личных данных.

---

## ⚡ За 5 минут

```fish
# 1. С NixOS minimal ISO загрузился, подключил сеть
sudo -i
nix-shell -p git
git clone https://github.com/Nhrust/nixos-config /root/nixos-config
cd /root/nixos-config

# 2. Создай свой хост из шаблона и заполни settings
cp -r hosts/_template hosts/my-machine
nano hosts/my-machine/settings.nix     # hostname, username, cpu, gpu, disk, ...

# 3. Разметь диск (УНИЧТОЖИТ ВСЁ на settings.disk!)
nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko -- --mode disko --flake .#my-machine

# 4. Сгенерируй железо
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/my-machine/hardware.nix

# 5. Установка (ВАЖНО: префикс path:)
nixos-install --flake "path:.#my-machine"
reboot

# 6. После реббута логинишься, ~/nixos-config/ уже на месте (bootstrap)
# Сменить пароль:
passwd
```

И всё. Дальше работаешь через `nrs` (алиас в fish для `nixos-rebuild switch`).

Подробная установка — `docs/INSTALL.md`.

---

## Что входит из коробки

| Слой | Что |
|---|---|
| Composer | Hyprland (Wayland) |
| Дисплей-менеджер | greetd + tuigreet |
| Терминал | kitty |
| Лаунчер | wofi |
| Бар | waybar |
| Уведомления | mako |
| Logout-меню | wlogout |
| Файловый менеджер | thunar (через `Super+E`) |
| Локскрин | hyprlock |
| Idle | hypridle |
| Шейдеры | hyprshade (blue-light filter и т.д.) |
| Плагины Hyprland | pyprland (scratchpads, smart_gaps) |
| Тема | Catppuccin (Mocha/Latte) — всё консистентно |
| Шрифты | Noto, JetBrainsMono Nerd Font, CJK |
| Аудио | Pipewire + WirePlumber |
| Сеть | NetworkManager + nm-applet |
| Питание | power-profiles-daemon (waybar модуль) |
| Шелл | fish + tide + плагины |
| CLI стек | eza, bat, fd, ripgrep, zoxide, lazygit, helix |

## Опционально через `extras/`

| `extras/gaming.nix` | Steam, GameMode, MangoHud, Gamescope, ProtonUP-Qt, Lutris, steam-run |
| `extras/development.nix` | Podman + docker alias, podman-compose, lazydocker |

Подключаются в `custom/<host>.nix`:

```nix
{ ... }: { imports = [ ../extras/gaming.nix ]; }
```

---

## 📁 Где что лежит

```
nixos-config/
├── flake.nix                    Точка входа, formatter, devShells
├── lib/                         Переиспользуемые Nix-функции
├── modules/                     UPSTREAM ZONE (не трогать)
│   ├── disko/                   Разметка диска
│   ├── system/                  Системный уровень NixOS
│   └── user/                    Home Manager + dotfiles
├── hosts/                       Per-machine конфиги
│   └── _template/               Шаблон для нового хоста
├── custom/                      USER ZONE (твои правки, gitignored)
├── extras/                      Готовые «комплекты», подключай по выбору
└── docs/                        Документация
```

Подробное описание + ASCII data-flow — `docs/STRUCTURE.md`.

## 🔧 Как поменять что-то

Краткая шпаргалка, полная — `docs/CUSTOMIZATION.md`:

| Хочу… | Куда |
|---|---|
| Сменить тему/раскладку/cpu | `hosts/<host>/settings.nix` |
| Включить гейминг/дев-стек | `imports = [ ../extras/<...> ];` в `custom/<host>.nix` |
| Установить пакет | `custom/<host>.nix` |
| Сменить Hyprland бинд | `~/.config/hypr/user.conf` (live!) |
| Добавить fish-алиас | `~/.config/fish/conf.d/local.fish` (live!) |
| Поменять обои | заменить `~/Pictures/wallpaper.png` |

## 🔄 Обновления

```fish
git pull upstream main    # подтянуть upstream
nrs                       # применить
```

Локальные правки (settings.nix, hardware.nix, custom/) **не в git** —
конфликтов при обновлении не бывает.

Подробнее — `docs/UPDATING.md`.

## 📚 Документация

| Файл | Когда читать |
|---|---|
| `docs/INSTALL.md` | Ставлю с нуля |
| `docs/POST_INSTALL.md` | Только что установился — что дальше |
| `docs/UPDATING.md` | Подтянуть upstream обновления |
| `docs/STRUCTURE.md` | Что где лежит и почему |
| `docs/CUSTOMIZATION.md` | Хочу что-то поменять — куда положить |
| `docs/KEYBINDINGS.md` | Какие бинды в Hyprland |
| `docs/POWER.md` | Профили питания, лимит батареи |
| `docs/HARDWARE.md` | Какое железо протестировано |
| `docs/TROUBLESHOOTING.md` | Что-то сломалось |
| `CONTRIBUTING.md` | Хочу прислать PR |
| `CHANGELOG.md` | Что менялось |

## 🧩 Принципы

1. **Один файл — один хост.** `settings.nix` это всё что нужно знать про машину.
2. **Multi-host из коробки.** Несколько машин в одном репо. `flake.nix` сканирует `hosts/`.
3. **Безопасные обновления.** `git pull upstream main` никогда не задевает твоё.
4. **Иммутабельный upstream, мутабельный custom.** `modules/` обновляется,
   `custom/<host>` твоё, `~/.config/.../user.conf` mutable.

## 🤝 Контрибьют

См. `CONTRIBUTING.md`. Принимаются bug-fix'ы, поддержка нового железа, новые
`extras/`, улучшения docs.

## ⚖ Лицензия

MIT — см. `LICENSE`.
