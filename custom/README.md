# Кастомизация — единая точка входа

Эта папка содержит **всё что юзер может настроить** в системе. Если ты не
знаешь куда положить свою правку — начни отсюда.

## Быстрый старт (5 минут)

```fish
# 1. Скопируй готовый набор примеров под имя своей машины
cp -r custom/_examples custom/$(hostname)

# 2. Открой папку в редакторе и пройди по файлам — раскомментируй что нужно
hx custom/$(hostname)/default.nix     # подключения модулей
hx custom/$(hostname)/packages.nix    # пакеты которые хочешь установить
hx custom/$(hostname)/services.nix    # системные сервисы
# ... и т.д.

# 3. Применить
nrs
```

После `nrs` все твои правки активируются. Между машинами переносятся через
**коммит и push в твой fork** — `~/nixos-config` на другой машине получит
их через `git pull upstream main && nrs`.

## Что куда класть — матрица

| Хочу… | Куда |
|---|---|
| **Параметры машины** (hostname, cpu, gpu, тема, kbLayouts, gaming.enable, etc.) | `hosts/<host>/settings.nix` |
| **Установить пакет** (Discord, OBS, Spotify) | `custom/<host>/packages.nix` |
| **Включить системный сервис** (tailscale, syncthing, SSH) | `custom/<host>/services.nix` |
| **Декларативный fish-алиас** (переедет на другие машины) | `custom/<host>/aliases.nix` |
| **Live fish-алиас** (быстро попробовать) | `~/.config/fish/conf.d/local.fish` |
| **Включить гейминг стек** (Steam, GameMode, ...) | `custom/<host>/extras-gaming.nix` + `gaming.enable=true` в settings |
| **Включить дев-стек** (Podman, ...) | `custom/<host>/extras-development.nix` + `development.enable=true` в settings |
| **Override опции из `modules/`** (например выключить hypridle) | `custom/<host>/overrides.nix` через `lib.mkForce` |
| **Использовать секреты** (WiFi PSK, API tokens) | `custom/<host>/secrets-usage.nix` + `secrets/default.yaml` |
| **Декларативный Hyprland override** (переносимый между машинами) | `custom/<host>/dotfiles/hypr-user.conf` |
| **Декларативный fish-local** (переносимый) | `custom/<host>/dotfiles/fish-local.fish` |
| **Live Hyprland бинд** (быстро попробовать) | `~/.config/hypr/user.conf` + `hyprctl reload` |
| **Поменять обои** | заменить `~/Pictures/wallpaper.png` |

## Структура одной машины (после копирования `_examples`)

```
custom/my-laptop/
├── default.nix              ← точка входа, imports = [...]
├── packages.nix             ← дополнительные пакеты
├── services.nix             ← системные сервисы
├── aliases.nix              ← декларативные fish-алиасы
├── extras-gaming.nix        ← подключение extras/gaming.nix
├── extras-development.nix   ← подключение extras/development.nix
├── overrides.nix            ← lib.mkForce примеры
├── secrets-usage.nix        ← использование sops секретов
└── dotfiles/                ← опциональные декларативные dotfiles
    ├── hypr-user.conf       ← Hyprland override
    └── fish-local.fish      ← fish-локальные алиасы и функции
```

Папка целиком **gitignored** (`.gitignore` исключает `custom/*/`). Чтобы её
переносить между машинами — закоммить **в свой fork** (например в отдельной
ветке `my-laptop`):

```fish
# на одной машине
git add -f custom/my-laptop/                  # -f т.к. в .gitignore
git commit -m "config: my-laptop"
git push origin main

# на другой машине этого же юзера
git pull
nrs
```

## Минималистичный путь — один файл

Если тебе достаточно одной точки на машину (без папочной структуры) — используй
`custom/<host>.nix` как **один файл**:

```nix
# custom/my-laptop.nix
{ pkgs, lib, settings, ... }: {
  environment.systemPackages = with pkgs; [ discord obs-studio ];
  services.tailscale.enable = true;
  services.hypridle.enable  = lib.mkForce false;

  home-manager.users.${settings.username}.programs.fish.shellAliases = {
    myproj = "cd ~/work";
  };
}
```

Минимальный валидный пример — `custom/_example.nix` рядом.

## Какой подход выбрать

- **`custom/<host>.nix` файл** — если правок мало (< 20 строк), всё помещается
  в один файл, не нужно разделять по темам.
- **`custom/<host>/` папка из `_examples`** — если правок много, или хочешь
  порядок (один файл = одна тема), или хочешь декларативные dotfiles.

Оба подхода полностью поддерживаются — `lib/mkHost.nix` определяет какой
ты выбрал автоматически.

## Когда нужна mutable правка (НЕ через эту папку)

| Сценарий | Файл |
|---|---|
| Хочу быстро попробовать бинд / алиас (без `nrs`) | `~/.config/hypr/user.conf` / `~/.config/fish/conf.d/local.fish` |
| Правка только на этой машине, переносить не хочу | то же самое |
| Тонкая настройка GUI-программ (kitty, helix theme) | `~/.config/<программа>/...` напрямую |

Mutable-файлы создаются один раз при первой установке из template, **никогда
не задеваются обновлениями репо**, и не уходят в git благодаря `.gitignore`.

## Глубокая теория модели кастомизации

`docs/CUSTOMIZATION.md` — полное описание принципов:
- 4 уровня кастомизации
- Когда NixOS module system мерджит без конфликтов, когда падает с ошибкой
- Как использовать `lib.mkForce` правильно
- Hyprland "последний выигрывает" подход
- Конкретные сценарии и анти-паттерны

## Что НЕ через эту папку

| Не сюда | Куда тогда |
|---|---|
| Установка новой ОС | `docs/INSTALL.md` |
| Подключение secrets | `docs/SECRETS.md` (один раз, через `secretsAdminAgePubKey` в settings) |
| Изменение upstream-модулей (например waybar/style.css) | через `lib.mkForce` или fork (никогда через прямую правку `modules/`) |
| Контрибьют в upstream | `CONTRIBUTING.md` |
