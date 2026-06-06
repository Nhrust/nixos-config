# ❄️ nixos-config

Минималистичный воспроизводимый NixOS-дистрибутив на базе Flakes, Home Manager,
disko и catppuccin-nix. Сделан для тестирования на разном железе и для друзей
которым нужна работающая система из коробки. Multi-host, разворачивается одной
командой, обновляется без боли, делится без раскрытия личных данных.

## ⚡ Что это даёт

- **Один файл `settings.nix`** на хост — все параметры там
- **Multi-host** — несколько машин в одном репо, обновляются вместе
- **Поддерживаемое железо:** AMD/Intel CPU, AMD/Intel/Nvidia GPU
- **Профили:** laptop, desktop, server
- **Hyprland** из коробки + greetd + waybar + wofi + kitty
- **Catppuccin** во всём — kitty, waybar, wofi, helix, bat, fish, GTK, Qt
- **Безопасные обновления** для друзей — модули не трогают их хосты
- **`extras/`** — готовые комплекты (гейминг, дев) одной строчкой
- **Bootstrap** — после установки `~/nixos-config/` создаётся сам
- **`.gitignore`** — личное (settings, hardware, custom) не уходит в публичный fork

## 🚀 За 5 минут

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
passwd                                  # сменить дефолтный "nixos"
```

И всё. Дальше работаешь через `nrs` (алиас в fish для `nixos-rebuild switch`).

### Другие сценарии

- **Ставлю рядом с другой ОС** (dual-boot, existing разделы) →
  `docs/INSTALL.md` Путь 2 (parted + ручные сабволюмы)
- **Хочу сначала в виртуалке потестить** → `docs/INSTALL.md` Путь 3 (QEMU/virt-manager)
- **Я уже установил — что дальше?** → `docs/POST_INSTALL.md` (пароль, обои, гибернация, upstream)
- **Хочу добавить новую машину к существующей системе** →
  `cp -r hosts/_template hosts/<имя>` → отредактировать `settings.nix` →
  `nrs` после генерации `hardware.nix`

## 📦 Что входит в базу

**Hyprland-стек:**

| Слой | Что |
|---|---|
| Composer | Hyprland (Wayland) |
| Дисплей-менеджер | greetd + tuigreet |
| Терминал | kitty |
| Лаунчер | wofi |
| Бар | waybar (с power-profile модулем) |
| Уведомления | mako |
| Logout-меню | wlogout |
| Файловый менеджер | thunar (`Super+E`) |
| Локскрин / Idle | hyprlock + hypridle |
| Шейдеры | hyprshade (blue-light filter) |
| Плагины | pyprland (scratchpads, smart_gaps) |
| Браузер | firefox |

**Консоль:** fish + tide, helix, tmux, bat, eza, fzf, zoxide, yazi, fd, ripgrep, btop, duf, dust, lazygit, direnv

**Аудио / сеть / питание:** Pipewire + WirePlumber, NetworkManager + nm-applet, power-profiles-daemon

**Опционально (флаги в `settings.nix`):**
- `virtualization = true` → KVM/QEMU + libvirtd + virt-manager
- `printing = true` → CUPS + Avahi
- `bluetooth = true` → BlueZ + blueman

## ➕ Опционально через `extras/`

Готовые тематические комплекты — подключаются одной строчкой в `custom/<host>.nix`:

| Модуль | Что включает |
|---|---|
| `extras/gaming.nix` | Steam, GameMode, MangoHud, Gamescope, ProtonUP-Qt, Lutris, steam-run, Wine |
| `extras/development.nix` | Podman + docker-CLI alias, podman-compose, lazydocker, dive, docker-buildx |

```nix
# custom/<host>.nix
{ ... }: {
  imports = [ ../extras/gaming.nix ];
}
```

Свои `extras/` можно добавлять как угодно — см. `extras/README.md`.

## 📁 Структура

```
nixos-config/
│
├── flake.nix                  Точка входа, formatter, devShells
├── lib/                       Переиспользуемые Nix-функции
│
├── modules/                   UPSTREAM ZONE (не трогать)
│   ├── system/                Системный уровень NixOS
│   ├── user/                  Home Manager + dotfiles
│   └── disko/                 Схемы разметки диска
│
├── hosts/                     Per-machine конфиги
│   └── _template/             Шаблон для нового хоста
│
├── custom/                    USER ZONE (твои правки, gitignored)
├── extras/                    Готовые «комплекты»
└── docs/                      Документация
```

Подробное описание каждого файла + ASCII data-flow — `docs/STRUCTURE.md`.

## 🎨 Тема

Catppuccin через [catppuccin-nix](https://github.com/catppuccin/nix).
Меняется в `hosts/<host>/settings.nix`:

```nix
theme       = "dark";   # "dark" → Mocha (тёмная) | "light" → Latte (светлая)
themeAccent = "mauve";  # blue / mauve / lavender / teal / pink / sky / sapphire
                        # red / maroon / peach / yellow / green / rosewater / flamingo
```

Применяется автоматически ко всем поддерживаемым программам: kitty, waybar,
wofi, helix, bat, fish, GTK, Qt, mako, hyprlock, hyprland borders, обои.

## 🔧 Как поменять что-то

Краткая шпаргалка — полная матрица в `docs/CUSTOMIZATION.md`:

| Хочу… | Куда |
|---|---|
| Сменить тему/раскладку/cpu/железо | `hosts/<host>/settings.nix` |
| Включить гейминг или дев-стек | `imports = [ ../extras/<...> ];` в `custom/<host>.nix` |
| Установить системный пакет | `custom/<host>.nix` |
| Установить пакет в свой $HOME | `custom/<host>.nix` через `home-manager.users.<u>.home.packages` |
| Сменить Hyprland бинд | `~/.config/hypr/user.conf` (live, без `nrs`!) |
| Добавить fish-алиас | `~/.config/fish/conf.d/local.fish` (live!) |
| Поменять обои | заменить `~/Pictures/wallpaper.png` |
| Перетереть значение из `modules/` | `lib.mkForce` в `custom/<host>.nix` |

## 🛠 Алиасы fish

| Алиас | Команда |
|---|---|
| `nrs` | `sudo nixos-rebuild switch --flake "path:~/nixos-config#$(hostname)"` |
| `nrt` | то же, но `test` (применить временно, без записи в boot) |
| `nrb` | то же, но `boot` (применить при следующей загрузке) |
| `nrl` | откат к предыдущему поколению |
| `nfu` | `nix flake update ~/nixos-config` |
| `ngc` | `nix-collect-garbage -d` (почистить store) |

Полный список — `modules/user/shell/fish.nix`.

## 🔄 Обновления

```fish
git pull upstream main    # подтянуть upstream
nrs                       # применить
```

Локальные правки (`settings.nix`, `hardware.nix`, `custom/`) **не в git** —
конфликтов при обновлении не бывает.

Подробнее — `docs/UPDATING.md`.

## 📚 Документация

| Файл | Когда читать |
|---|---|
| `docs/INSTALL.md` | Ставлю с нуля (3 пути: wipe, existing, VM) |
| `docs/POST_INSTALL.md` | Только что установился — что дальше |
| `docs/UPDATING.md` | Подтянуть upstream обновления |
| `docs/STRUCTURE.md` | Что где лежит и почему |
| `docs/CUSTOMIZATION.md` | Хочу что-то поменять — куда положить |
| `docs/KEYBINDINGS.md` | Какие бинды в Hyprland |
| `docs/POWER.md` | Профили питания, лимит батареи, гибернация |
| `docs/HARDWARE.md` | Какое железо протестировано |
| `docs/TROUBLESHOOTING.md` | Что-то сломалось |
| `CONTRIBUTING.md` | Хочу прислать PR |
| `CHANGELOG.md` | История релизов и breaking changes |

## 🧩 Принципы

1. **Один файл — один хост.** `settings.nix` это всё что нужно знать про машину.
2. **Multi-host из коробки.** Несколько машин в одном репо. `flake.nix` сканирует `hosts/`.
3. **Безопасные обновления.** `git pull upstream main` никогда не задевает твоё —
   локальные файлы исключены из git через `.gitignore`.
4. **Иммутабельный upstream, мутабельный custom.** `modules/` обновляется,
   `custom/<host>` твоё, `~/.config/.../user.conf` mutable.
5. **Settings > Custom > Extras > Mutable.** Параметризация через `settings.nix`,
   обвязка через `custom/`, готовые комплекты через `extras/`, живые правки —
   через файлы в `$HOME`.

## 🤝 Для друзей

Этот репо — мой пет-проект. Я делюсь им потому что он работает и выглядит
так как я считаю правильным. Если тебе нравится — клонируй и пользуйся.
Если хочешь что-то другое — кастомизируй через `custom/<host>.nix` или
форкни и меняй у себя.

Не стесняйся писать issue если что-то не работает на твоём железе или
непонятно из docs — обратная связь делает дистрибутив лучше для всех.

Хочешь прислать PR с поддержкой своего железа или с новым `extras/` — добро
пожаловать, см. `CONTRIBUTING.md`.

## ⚖ Лицензия

MIT — см. `LICENSE`. Делай с этим всё что хочешь, я только рад если поможет.
