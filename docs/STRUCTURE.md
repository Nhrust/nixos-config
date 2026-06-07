# Структура репозитория

Карта файлов и принципов организации. Если запутался куда что положить —
смотри также `docs/CUSTOMIZATION.md` (матрица «хочу X → иди в Y»).

## Дерево

```
nixos-config/
│
├── flake.nix                        — entry point, регистрирует хосты + formatter/devShells
├── README.md                        — обзор, «5 минут» гайд
├── CHANGELOG.md                     — история релизов
├── CONTRIBUTING.md                  — как присылать PR
├── LICENSE
├── .editorconfig                    — единые отступы (v0.2.0)
├── .gitattributes                   — нормализация LF (v0.2.0)
├── .gitignore                       — локальные файлы не уходят в git (v0.1.9)
│
├── lib/                             — Nix-функции переиспользуемые во флейке
│   ├── mkHost.nix                   — фабрика хоста (автодискавер с v0.2.0)
│   └── btrfs-subvolumes.nix         — общая схема сабволюмов (v0.2.0, DRY)
│
├── modules/                         — UPSTREAM ZONE. Друг не трогает.
│   │                                  Обновляется через `git pull upstream main`.
│   │
│   ├── disko/                       — разметка диска
│   │   ├── btrfs.nix                — wipe режим (полная переразметка)
│   │   └── btrfs-existing.nix       — existing режим (готовые разделы)
│   │
│   ├── system/                      — системный слой NixOS
│   │   ├── nix.nix                  — nix.gc, experimental features
│   │   ├── boot.nix                 — systemd-boot, swap, hibernation
│   │   ├── network.nix              — NetworkManager, hostname
│   │   ├── locale.nix               — timezone, i18n, console keymap
│   │   ├── users.nix                — основной user, fish
│   │   ├── base.nix                 — git/curl/wget, virtualization, stateVersion
│   │   ├── variables.nix            — переменные окружения (Wayland)
│   │   ├── power-profiles.nix       — power-profiles-daemon
│   │   ├── bootstrap.nix            — автокопия репо в HOME (v0.1.9)
│   │   │
│   │   ├── hardware/                — conditional: ОДИН выбирается по settings
│   │   │   ├── cpu-amd.nix          —   settings.cpu = "amd"
│   │   │   ├── cpu-intel.nix        —   settings.cpu = "intel"
│   │   │   ├── gpu-amd.nix          —   settings.gpu = "amd"
│   │   │   ├── gpu-intel.nix        —   settings.gpu = "intel"
│   │   │   └── gpu-nvidia.nix       —   settings.gpu = "nvidia"
│   │   │
│   │   ├── profiles/                — conditional: ОДИН выбирается по settings
│   │   │   ├── laptop.nix           —   settings.profile = "laptop"  (TLP, lidSwitch)
│   │   │   ├── desktop.nix          —   settings.profile = "desktop" (без батарей)
│   │   │   └── server.nix           —   settings.profile = "server"  (без GUI авто)
│   │   │
│   │   ├── services/                — все подхватываются автодискавером
│   │   │   ├── bluetooth.nix        — settings.bluetooth = true
│   │   │   └── printing.nix         — settings.printing = true
│   │   │
│   │   └── ui/                      — системный UI (всегда активен)
│   │       ├── audio.nix            — Pipewire + WirePlumber
│   │       ├── fonts.nix            — Noto, JetBrainsMono, CJK
│   │       └── session.nix          — greetd + tuigreet + Hyprland session
│   │
│   └── user/                        — Home Manager слой
│       ├── home.nix                 — entry point (автодискавер с v0.2.0)
│       ├── theme.nix                — Catppuccin GTK/Qt/cursor
│       │
│       ├── shell/
│       │   ├── fish.nix             — fish + плагины + nrs/nrt/nrb алиасы
│       │   └── tmux.nix             — tmux
│       │
│       ├── tools/
│       │   ├── cli.nix              — CLI утилиты (eza, bat, fd, ripgrep, ...)
│       │   └── dev.nix              — dev-tools (git, gh, lazygit, helix)
│       │
│       ├── ui/                      — все подхватываются автодискавером
│       │   ├── hyprland.nix         — kbLayouts templating (v0.2.0), idle/profile select
│       │   ├── kitty.nix
│       │   ├── waybar.nix
│       │   ├── wofi.nix
│       │   └── notifications.nix    — mako
│       │
│       └── dotfiles/                — статические конфиги, копируются как файлы
│           ├── hyprland/
│           │   ├── hyprland.conf            — главный, source-ит conf/*.conf
│           │   ├── hyprpaper.conf
│           │   ├── hyprlock.conf
│           │   ├── pyprland.toml
│           │   ├── user.conf.template       — создаётся в $HOME при первом запуске
│           │   ├── conf/                    — модульный конфиг Hyprland
│           │   │   ├── monitors.conf
│           │   │   ├── env.conf
│           │   │   ├── autostart.conf
│           │   │   ├── input.conf.in        — шаблон с @kbLayout@ (v0.2.0)
│           │   │   ├── general.conf
│           │   │   ├── decoration.conf
│           │   │   ├── animations.conf
│           │   │   ├── misc.conf
│           │   │   ├── binds.conf
│           │   │   ├── windowrules.conf
│           │   │   └── profile/             — по settings.profile
│           │   │       ├── laptop.conf
│           │   │       ├── desktop.conf
│           │   │       └── server.conf
│           │   ├── idle/                    — по settings.profile (только laptop/desktop)
│           │   │   ├── laptop.conf
│           │   │   └── desktop.conf
│           │   ├── scripts/
│           │   │   ├── volume.sh
│           │   │   ├── wifi-menu.sh
│           │   │   └── powerprofile.sh
│           │   └── wallpapers/
│           │       ├── default-dark.png
│           │       └── default-light.png
│           ├── waybar/{config.jsonc, style.css}
│           ├── wlogout/{layout, style.css}
│           ├── wofi/{config, style.css}
│           └── fish/local.fish.template
│
├── hosts/                           — USER ZONE: всё про каждую машину
│   ├── _template/                   — полный шаблон новой машины (v0.5.0+)
│   │   ├── README.md                — навигатор по файлам шаблона
│   │   ├── settings.nix             — параметры (hostname, cpu, theme, ...)
│   │   ├── hardware.nix             — заглушка (генерится через nixos-generate-config)
│   │   ├── default.nix              — entry-point с imports
│   │   ├── packages.nix             — системные + home-manager пакеты
│   │   ├── services.nix             — tailscale/syncthing/SSH/borg/...
│   │   ├── aliases.nix              — декларативные fish-алиасы
│   │   ├── extras-gaming.nix        — подключение extras/gaming.nix
│   │   ├── extras-development.nix   — подключение extras/development.nix
│   │   ├── overrides.nix            — lib.mkForce примеры
│   │   ├── secrets-usage.nix        — использование sops секретов
│   │   └── dotfiles/                — опц. декларативные dotfile overrides
│   │       ├── README.md            — список поддерживаемых файлов
│   │       ├── hypr-user.conf       — Hyprland override
│   │       └── fish-local.fish      — fish override
│   └── <твоя-машина>/               — копия _template/, отредактирована (gitignored)
│
├── extras/                          — опциональные тематические модули (v0.2.0)
│   ├── README.md
│   ├── gaming.nix                   — Steam, GameMode, Gamescope, Lutris, ...
│   └── development.nix              — Podman, podman-compose, lazydocker
│
└── docs/                            — документация
    ├── INSTALL.md                   — пошаговая установка
    ├── POST_INSTALL.md              — что сделать после первой загрузки
    ├── UPDATING.md                  — git pull upstream main + nrs
    ├── STRUCTURE.md                 — этот файл
    ├── CUSTOMIZATION.md             — матрица «хочу X → иди в Y» (v0.2.0)
    ├── KEYBINDINGS.md               — все бинды одной таблицей (v0.2.0)
    ├── POWER.md                     — powerProfile, batteryChargeLimit (v0.2.0)
    ├── HARDWARE.md                  — матрица протестированного железа (v0.2.0)
    └── TROUBLESHOOTING.md           — частые проблемы и решения
```

## Поток данных

```
                    ┌─────────────────────────────────────┐
                    │ hosts/<host>/settings.nix           │
                    │  ┌─ cpu, gpu, profile              │
                    │  ├─ theme, themeAccent             │
                    │  ├─ disk, diskMode                 │
                    │  ├─ powerProfile, batteryLimit    │
                    │  ├─ kbLayouts (v0.2.0)            │
                    │  ├─ virtualization, printing, ...  │
                    │  └─ upstream (опц.)                │
                    └────────────────┬────────────────────┘
                                     │
                                     ▼
                    ┌─────────────────────────────────────┐
                    │ lib/mkHost.nix                      │
                    │                                     │
                    │ Conditional switch:                 │
                    │  cpu      → modules/system/hardware/cpu-<cpu>.nix
                    │  gpu      → modules/system/hardware/gpu-<gpu>.nix
                    │  profile  → modules/system/profiles/<profile>.nix
                    │  diskMode → modules/disko/btrfs[-existing].nix
                    │                                     │
                    │ Автодискавер (v0.2.0):              │
                    │  modules/system/*.nix               │
                    │  modules/system/services/*.nix      │
                    │  modules/system/ui/*.nix            │
                    │                                     │
                    │ Custom layer:                       │
                    │  hosts/<host>/default.nix           │
                    │  + остальные *.nix рядом            │
                    │                                     │
                    │ Home-manager:                       │
                    │  modules/user/home.nix              │
                    │   └─ автодискавер (v0.2.0):         │
                    │       modules/user/{theme,*/}.nix   │
                    └────────────────┬────────────────────┘
                                     │
                                     ▼
                            nixosSystem (готовый хост)
```

## Принципы

1. **`modules/` иммутабельно для пользователя.** Любая правка там = конфликт
   при `git pull upstream main`. Если нужно поменять поведение модуля —
   override в `hosts/<host>/overrides.nix` через `lib.mkForce` или подключение
   собственного модуля.

2. **`settings.nix` — единственный конфиг машины первой необходимости.**
   Все per-host параметры сюда. Шаблон в `hosts/_template/settings.nix`.

3. **`hosts/<host>/default.nix` + остальные `.nix` файлы — для всего что не вписалось в `settings.nix`.**
   Дополнительные пакеты, сервисы, override модулей, подключение `extras/`.

4. **Автодискавер — для модулей без conditional choice.** Если у модуля
   нет альтернатив (например `bluetooth.nix` — он либо активен через
   `settings.bluetooth`, либо нет), его можно положить в `services/` и
   `mkHost.nix` подхватит автоматически.

5. **Conditional choice — switch-based в `mkHost.nix`.** Где надо выбрать
   ОДИН вариант из нескольких (cpu, gpu, profile, diskMode) — это
   switch-выражение в `lib/mkHost.nix`, не автодискавер.

6. **Mutable layer в `$HOME`:**
   - `~/.config/hypr/user.conf` — Hyprland override'ы (бинды/мониторы/правила)
   - `~/.config/fish/conf.d/local.fish` — fish-алиасы/функции/env
   Создаются один раз при первой установке, обновлениями не задеваются.
