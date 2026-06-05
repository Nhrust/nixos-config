# Структура репозитория

```
nixos-config/
│
├── flake.nix                              Точка входа Nix
├── README.md / CHANGELOG.md / .gitignore
│
├── lib/
│   └── mkHost.nix                         Фабрика хоста
│
├── modules/                               (обновляется upstream)
│   │
│   ├── disko/
│   │   ├── btrfs.nix                      Авторазметка (diskMode = wipe)
│   │   └── btrfs-existing.nix             Существующие разделы
│   │
│   ├── system/
│   │   │
│   │   ├── main.nix                       Фундамент: загрузчик, сеть, локаль, юзер
│   │   ├── variables.nix                  Переменные окружения Wayland
│   │   │
│   │   ├── hardware/                      Железо
│   │   │   ├── cpu-amd.nix
│   │   │   ├── cpu-intel.nix
│   │   │   ├── gpu-amd.nix
│   │   │   ├── gpu-intel.nix
│   │   │   └── gpu-nvidia.nix
│   │   │
│   │   ├── profiles/                      Сценарий использования
│   │   │   ├── laptop.nix                 TLP + тачпад + brightnessctl
│   │   │   ├── desktop.nix                schedutil governor
│   │   │   └── server.nix                 schedutil + thermald + no suspend
│   │   │
│   │   ├── ui/                            Рабочее окружение
│   │   │   ├── session.nix                Hyprland + greetd + portals
│   │   │   ├── audio.nix                  PipeWire
│   │   │   └── fonts.nix                  Шрифты
│   │   │
│   │   └── services/                      Опциональные сервисы
│   │       ├── printing.nix               CUPS (по флагу settings.printing)
│   │       └── bluetooth.nix              Bluetooth (по флагу settings.bluetooth)
│   │
│   └── user/                              Home Manager
│       │
│       ├── home.nix                       Точка входа HM
│       ├── theme.nix                      Catppuccin + GTK + курсор
│       │
│       ├── shell/                         Оболочка
│       │   ├── fish.nix                   Fish + алиасы
│       │   └── tmux.nix                   Мультиплексор
│       │
│       ├── tools/                         Утилиты
│       │   ├── cli.nix                    eza, bat, btop, helix и т.д.
│       │   └── dev.nix                    git, lazygit, direnv
│       │
│       ├── ui/                            UI приложения
│       │   ├── kitty.nix                  Терминал
│       │   ├── hyprland.nix               Hyprland + user.conf механизм
│       │   ├── waybar.nix                 Статус-бар
│       │   └── wofi.nix                   Launcher + mako
│       │
│       └── dotfiles/                      Конфиги программ
│           ├── hyprland/
│           │   ├── hyprland.conf          Главный файл (только source-директивы)
│           │   ├── user.conf.template     Шаблон пользовательских override-ов
│           │   ├── conf/                  Модули конфига
│           │   │   ├── monitors.conf
│           │   │   ├── env.conf
│           │   │   ├── autostart.conf
│           │   │   ├── input.conf
│           │   │   ├── general.conf
│           │   │   ├── decoration.conf
│           │   │   ├── animations.conf
│           │   │   ├── misc.conf
│           │   │   ├── binds.conf
│           │   │   └── windowrules.conf
│           │   ├── hyprpaper.conf
│           │   ├── hyprlock.conf
│           │   └── hypridle.conf
│           ├── waybar/
│           │   ├── config.jsonc
│           │   └── style.css
│           └── wofi/
│               ├── config
│               └── style.css
│
├── hosts/                                 ПОЛЬЗОВАТЕЛЬСКИЕ ХОСТЫ
│   ├── _template/                         Шаблон (копируй для новой машины)
│   │   ├── settings.nix
│   │   ├── hardware.nix
│   │   └── README.md
│   └── <твой-хост>/                       Создаётся при установке
│       ├── settings.nix                   Параметры этой машины
│       └── hardware.nix                   Автогенерируется
│
└── custom/                                ДОПОЛНЕНИЯ
    ├── README.md
    └── <твой-хост>.nix                    Опционально, поверх modules/
```

## Поток данных

```
flake.nix
  └─ сканирует hosts/*
      └─ для каждого вызывает lib/mkHost.nix
          ├─ читает hosts/<name>/settings.nix
          ├─ выбирает модули из modules/ на основе settings
          ├─ подключает hosts/<name>/hardware.nix
          ├─ если есть custom/<name>.nix — подключает поверх
          └─ возвращает nixosSystem
```

## Группировка модулей

Каждая папка в `modules/system/` имеет чёткую роль:

| Папка | Что внутри | Когда подключается |
|---|---|---|
| (корень) | `main.nix`, `variables.nix` | Всегда |
| `hardware/` | CPU + GPU модули | По одному из каждой группы (выбор через settings) |
| `profiles/` | laptop / desktop / server | Ровно один (выбор через settings) |
| `ui/` | session, audio, fonts | Все всегда |
| `services/` | printing, bluetooth | Все всегда, активируются флагами |

В `modules/user/` аналогично:

| Папка | Что внутри |
|---|---|
| (корень) | `home.nix`, `theme.nix` |
| `shell/` | fish, tmux |
| `tools/` | cli утилиты, dev инструменты |
| `ui/` | kitty, hyprland, waybar, wofi |
| `dotfiles/` | конфиги программ как обычные файлы |

## Слои Hyprland конфигурации

```
hyprland.conf
  ├─ source conf/monitors.conf
  ├─ source conf/env.conf
  ├─ source conf/autostart.conf
  ├─ source conf/input.conf
  ├─ source conf/general.conf
  ├─ source conf/decoration.conf
  ├─ source conf/animations.conf
  ├─ source conf/misc.conf
  ├─ source conf/binds.conf
  ├─ source conf/windowrules.conf
  └─ source user.conf           ← ПЕРЕОПРЕДЕЛЯЕТ ВСЁ ВЫШЕ
```

`conf/*.conf` — иммутабельные, обновляются через `git pull upstream`.
`user.conf` — мутабельный, создаётся один раз при первой установке, дальше не трогается.
