# Структура репозитория

```
trefa-nixos/
│
├── flake.nix                              Точка входа Nix
├── README.md / CHANGELOG.md / .gitignore
│
├── lib/
│   └── mkHost.nix                         Фабрика хоста
│
├── modules/                               ТВОЁ (обновляется upstream)
│   │
│   ├── disko/
│   │   ├── btrfs.nix                      Авторазметка (diskMode = wipe)
│   │   └── btrfs-existing.nix             Существующие разделы (diskMode = existing)
│   │
│   ├── system/
│   │   ├── main.nix                       База: загрузчик, сеть, локаль, юзер
│   │   ├── variables.nix                  Переменные окружения Wayland
│   │   ├── audio.nix                      PipeWire
│   │   ├── desktop.nix                    Hyprland + greetd + portals
│   │   ├── fonts.nix                      Шрифты
│   │   ├── printing.nix                   CUPS (по флагу)
│   │   ├── bluetooth.nix                  Bluetooth (по флагу)
│   │   ├── hardware/
│   │   │   ├── cpu-amd.nix
│   │   │   ├── cpu-intel.nix
│   │   │   ├── gpu-amd.nix
│   │   │   ├── gpu-intel.nix
│   │   │   └── gpu-nvidia.nix
│   │   └── profiles/
│   │       ├── laptop.nix                 TLP + tachpad + brightnessctl
│   │       ├── desktop.nix                schedutil governor
│   │       └── server.nix                 schedutil + thermald + no suspend
│   │
│   └── user/                              Home Manager
│       ├── home.nix                       Точка входа HM, импортит остальные
│       ├── fish.nix                       Shell + алиасы
│       ├── tmux.nix                       Мультиплексор
│       ├── tools.nix                      Консольные утилиты
│       ├── dev.nix                        git, lazygit, direnv
│       ├── kitty.nix                      Терминал
│       ├── hyprland.nix                   Подключает hyprland dotfiles
│       ├── waybar.nix                     Статус-бар
│       ├── wofi.nix                       Launcher + mako (notifications)
│       ├── theme.nix                      Catppuccin + GTK + курсор
│       └── dotfiles/
│           ├── hyprland/                  hyprland.conf, hyprpaper, hyprlock, hypridle
│           ├── waybar/                    config.jsonc, style.css
│           └── wofi/                      config, style.css
│
├── hosts/                                 ТВОИ ХОСТЫ
│   │
│   ├── _template/                         Шаблон (копируй для новой машины)
│   │   ├── settings.nix
│   │   ├── hardware.nix
│   │   └── README.md
│   │
│   └── <твой-хост>/                       Создаётся при установке
│       ├── settings.nix                   Параметры этой машины
│       └── hardware.nix                   Автогенерируется
│
└── custom/                                ТВОИ ДОПОЛНЕНИЯ
    ├── README.md
    └── <твой-хост>.nix                    Опционально, поверх modules/
```

## Что куда подключается

```
flake.nix
  → сканирует hosts/*
  → для каждого вызывает lib/mkHost.nix
       → читает hosts/<name>/settings.nix
       → выбирает модули из modules/ на основе settings
       → подключает hosts/<name>/hardware.nix
       → если есть custom/<name>.nix — подключает поверх
       → возвращает nixosSystem
```

## Поток данных

`settings.nix` доступен во всех модулях через `specialArgs`:

```nix
{ settings, ... }:
{
  # Используешь settings.username, settings.cpu, settings.theme и т.д.
}
```

`hostName` (имя папки в `hosts/`) тоже доступен через `specialArgs` — на нём
основан `networking.hostName`, чтобы нельзя было перепутать.

## Какие модули подключаются всегда vs по флагу

**Всегда:**
- `modules/system/main.nix`
- `modules/system/variables.nix`
- `modules/system/audio.nix`
- `modules/system/desktop.nix`
- `modules/system/fonts.nix`
- `modules/system/printing.nix` (но активируется по `settings.printing`)
- `modules/system/bluetooth.nix` (но активируется по `settings.bluetooth`)
- Все user-модули через `modules/user/home.nix`

**По выбору из `settings`:**
- Один из `cpu-amd` / `cpu-intel`
- Один из `gpu-amd` / `gpu-intel` / `gpu-nvidia`
- Один из `laptop` / `desktop` / `server`
- Один из `btrfs` / `btrfs-existing`
