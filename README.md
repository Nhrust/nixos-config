# ❄️ trefa-nixos

Минималистичный воспроизводимый NixOS-дистрибутив на базе Flakes, Home Manager,
disko и catppuccin-nix. Сделан для тестирования на разном железе и для друзей
которым нужна работающая система из коробки.

## ⚡ Что это даёт

- **Один файл `settings.nix`** на хост — все параметры там
- **Multi-host** — несколько машин в одном репо, обновляются вместе
- **Поддерживаемое железо:** AMD/Intel CPU, AMD/Intel/Nvidia GPU
- **Профили:** laptop, desktop, server
- **Hyprland** из коробки + greetd + waybar + wofi + kitty
- **Catppuccin** во всём — kitty, waybar, wofi, helix, bat, fish, GTK, Qt
- **Безопасные обновления** для друзей — модули не трогают их хосты

## 📁 Структура

```
trefa-nixos/
│
├── flake.nix                  Точка входа, сканирует hosts/
├── lib/mkHost.nix             Фабрика хоста
│
├── modules/                   Твоё видение (друзья не трогают)
│   ├── system/                Системный уровень
│   ├── user/                  Home Manager
│   └── disko/                 Схемы разметки диска
│
├── hosts/                     Конкретные машины
│   └── _template/             Шаблон для нового хоста
│
└── custom/                    Опциональные дополнения от друзей
```

Подробное описание каждого файла — `docs/STRUCTURE.md`.

## 🚀 Быстрый старт

### Я ставлю с нуля

См. `docs/INSTALL.md` — три пути установки:
- **Путь 1** — авторазметка через disko (`diskMode = "wipe"`)
- **Путь 2** — рядом с другой ОС (`diskMode = "existing"`)
- **Путь 3** — виртуальная машина

### Я уже установлен — что дальше?

См. `docs/POST_INSTALL.md`:
- Сменить пароль
- Положить обои
- Настроить гибернацию (опционально)
- Подключить upstream для обновлений

### Я хочу добавить новую машину к существующей системе

```bash
cp -r hosts/_template hosts/my-new-machine
nano hosts/my-new-machine/settings.nix
# ... генерация hardware.nix во время установки
```

## 🔄 Обновления

См. `docs/UPDATING.md` — как получать обновы без конфликтов с твоими хостами.

## 📦 Что входит в базу

**Hyprland стек:** hyprland, waybar, wofi, mako, hyprlock, hypridle, hyprpaper, kitty, firefox, thunar

**Консоль:** fish, helix, tmux, bat, eza, fzf, zoxide, yazi, fd, ripgrep, btop, duf, dust, lazygit, direnv

**Опционально (флаги в settings.nix):**
- `virtualization` → KVM/QEMU + libvirtd
- `printing` → CUPS + Avahi
- `bluetooth` → bluez + blueman

## 🎨 Тема

Catppuccin через [catppuccin-nix](https://github.com/catppuccin/nix).
Меняется в `settings.nix`:

- `theme = "dark"` → Mocha (тёмная)
- `theme = "light"` → Latte (светлая)
- `themeAccent = "mauve"` (или blue/lavender/teal/pink/...)

Применяется автоматически ко всем поддерживаемым программам.

## 📚 Документация

- `docs/INSTALL.md` — установка
- `docs/POST_INSTALL.md` — после установки
- `docs/UPDATING.md` — обновления
- `docs/STRUCTURE.md` — структура репо
- `docs/CUSTOMIZATION.md` — кастомизация через `custom/`
- `docs/TROUBLESHOOTING.md` — известные проблемы
- `CHANGELOG.md` — breaking changes

## 🛠 Алиасы

| Алиас | Команда |
|---|---|
| `nrs` | `sudo nixos-rebuild switch --flake ~/trefa-nixos/#$(hostname)` |
| `nrb` | то же, но `boot` (применить при следующей загрузке) |
| `nfu` | `nix flake update ~/trefa-nixos` |
| `ngc` | `nix-collect-garbage -d` |
| `nrl` | откат к предыдущему поколению |

Полный список — в `modules/user/fish.nix`.

## 📐 Размер

| | Размер |
|---|---|
| Базовая система | ~12 GB |
| С Hyprland стеком | ~15-18 GB |
| Рекомендуемый минимум диска | 30 GB |

## 🤝 Для друзей

Этот репо — мой личный дистрибутив. Я делюсь им потому что он работает и
выглядит так как я считаю правильным. Если тебе нравится — клонируй и пользуйся.
Если хочешь что-то другое — кастомизируй через `custom/`.

## 📄 Лицензия

MIT. Делай что хочешь.
