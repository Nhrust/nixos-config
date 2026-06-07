# Шаблон новой машины

Эта папка — **полный стартовый набор** для любой новой машины. Не используется
напрямую при сборке — папки начинающиеся с `_` игнорируются автодискавером.

## Как создать свою машину

```fish
# 1. Скопируй весь шаблон под имя своего хоста (то что в settings.nix → hostname)
cp -r hosts/_template hosts/$(hostname)

# 2. Заполни параметры
$EDITOR hosts/$(hostname)/settings.nix

# 3. Сгенерируй hardware.nix через nixos-generate-config во время установки
#    (см. docs/INSTALL.md), скопируй сюда:
#    nixos-generate-config --no-filesystems --root /mnt
#    cp /mnt/etc/nixos/hardware-configuration.nix hosts/$(hostname)/hardware.nix

# 4. Пройди по остальным файлам и раскомментируй нужное
$EDITOR hosts/$(hostname)/default.nix       # подключения модулей
$EDITOR hosts/$(hostname)/packages.nix      # пакеты
$EDITOR hosts/$(hostname)/services.nix      # сервисы
$EDITOR hosts/$(hostname)/aliases.nix       # fish-алиасы
# опционально (раскомментируй в default.nix перед редактированием):
$EDITOR hosts/$(hostname)/extras-gaming.nix
$EDITOR hosts/$(hostname)/extras-development.nix
$EDITOR hosts/$(hostname)/overrides.nix
$EDITOR hosts/$(hostname)/secrets-usage.nix
$EDITOR hosts/$(hostname)/dotfiles/hypr-user.conf
$EDITOR hosts/$(hostname)/dotfiles/fish-local.fish

# 5. Установи систему
sudo nixos-install --flake "path:.#$(hostname)"
```

## Что в шаблоне (11 файлов + dotfiles/)

| Файл | Назначение | Импортируется через |
|---|---|---|
| `settings.nix` | Параметры машины (hostname, cpu, gpu, theme, kbLayouts, gaming.*, development.*, ...) | автоматически через `lib/mkHost.nix` |
| `hardware.nix` | Hardware config (генерится через nixos-generate-config) | автоматически через `lib/mkHost.nix` |
| `default.nix` | Entry-point модулей кастомизации с `imports` | автоматически через `lib/mkHost.nix` если файл существует |
| `packages.nix` | Системные пакеты (`environment.systemPackages`) + пакеты для $HOME (`home-manager.users.X.home.packages`) | через `default.nix` → imports |
| `services.nix` | Системные сервисы (tailscale, syncthing, openssh, borg, mullvad, docker, kdeconnect) | через `default.nix` → imports |
| `aliases.nix` | Декларативные fish-алиасы + функции через `programs.fish.shellAliases`/`functions` | через `default.nix` → imports |
| `extras-gaming.nix` | Обёртка `imports = [ ../../extras/gaming.nix ];` — подключает гейминг стек | через `default.nix` (закомментирован по умолчанию) |
| `extras-development.nix` | Обёртка для дев-стека (Podman, lazydocker, dive) | через `default.nix` (закомментирован) |
| `overrides.nix` | Примеры `lib.mkForce` для override опций из `modules/` | через `default.nix` (закомментирован) |
| `secrets-usage.nix` | Паттерны использования sops секретов через `config.sops.secrets."<имя>".path` | через `default.nix` (закомментирован) |
| `README.md` | Этот файл — навигатор | не импортируется (документация) |

## Опциональная папка `dotfiles/`

| Файл | Куда симлинкуется | Эффект |
|---|---|---|
| `hypr-user.conf` | `~/.config/hypr/user.conf` | Hyprland дополнения (последний выигрывает) |
| `fish-local.fish` | `~/.config/fish/conf.d/local.fish` | fish дополнения |

Plus ещё 11 файлов которые можно создать самостоятельно (waybar/wofi/kitty/mako/hyprland-blocks) — см. `dotfiles/README.md`.

Generic-сканер `modules/user/dotfile-overrides.nix` подхватывает любой
поддерживаемый файл и применяет как override через `xdg.configFile + lib.mkForce`.

## Подсказки

- **Файлы которые тебе не нужны** — оставляй как есть с закомментированными примерами. Это безопасно: закомментированный Nix-модуль это no-op.
- **Закоммитить свою машину в свой fork**: `git add -f hosts/$(hostname)/` (нужен `-f` потому что в `.gitignore`).
- **Перенос на другую машину** — `git pull origin main` подхватит твою папку если hostname совпадает.
- **Override любого upstream-конфига** — кидай файл в `dotfiles/` с именем из таблицы `fileMap` в `modules/user/dotfile-overrides.nix`. Без правки никаких `.nix` модулей.

## Полные документы

- `docs/INSTALL.md` — пошаговая установка
- `docs/CUSTOMIZATION.md` — глубокая теория модели кастомизации
- `docs/KEYBINDINGS.md` — список Hyprland биндов из коробки
- `docs/TOOLS.md` — каталог CLI/TUI утилит + cheatsheet
- `docs/SECRETS.md` — настройка sops секретов
- `docs/POWER.md` — power profiles + лимит батареи
- `docs/TROUBLESHOOTING.md` — что-то сломалось
