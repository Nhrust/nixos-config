# Кастомизация

Как добавить свой код / пакеты / правки не ломая обновления.

## TL;DR — где что

```
modules/      ← НЕ ТРОГАТЬ. Это upstream. Правки сюда = конфликт при git pull.
hosts/<host>/ ← Параметры этой машины (settings.nix + hardware.nix)
custom/<host> ← ВСЕ твои правки сюда (файл или папка)
extras/       ← Готовые «комплекты», подключай в custom/
$HOME/...     ← Mutable: ~/.config/hypr/user.conf, fish/conf.d/local.fish
```

`custom/<host>.nix` и `hosts/<host>/settings.nix` исключены из git
через `.gitignore` — личное никуда не уезжает.

## Матрица «хочу X → иди в Y»

| Хочу… | Где править | Пример |
|---|---|---|
| Сменить hostname / username / timezone | `hosts/<host>/settings.nix` | `hostname = "my-pc";` |
| Сменить тему / акцент | `hosts/<host>/settings.nix` | `theme = "light"; themeAccent = "blue";` |
| Сменить раскладку клавиатуры | `hosts/<host>/settings.nix` (v0.2.0+) | `kbLayouts = "us,de";` |
| Включить Bluetooth / принтер / виртуализацию | `hosts/<host>/settings.nix` | `bluetooth = true;` |
| Лимит заряда батареи | `hosts/<host>/settings.nix` | `batteryChargeLimit = 80;` |
| **Включить готовый гейминг стек** | `custom/<host>.nix` | `imports = [ ../extras/gaming.nix ];` |
| **Включить готовый дев-стек** | `custom/<host>.nix` | `imports = [ ../extras/development.nix ];` |
| Установить системный пакет (Discord, OBS) | `custom/<host>.nix` | `environment.systemPackages = [ pkgs.discord ];` |
| Установить пакет только в своё $HOME | `custom/<host>.nix` | `home-manager.users.${settings.username}.home.packages = [ pkgs.spotify ];` |
| Добавить fish-алиас (декларативно) | `custom/<host>.nix` | `home-manager.users.<u>.programs.fish.shellAliases.myproj = "cd ~/work";` |
| Добавить fish-алиас (mutable, для проб) | `~/.config/fish/conf.d/local.fish` | `alias myproj 'cd ~/work'` |
| Сменить Hyprland бинд | `~/.config/hypr/user.conf` (live, без `nrs`!) | `bind = SUPER, B, exec, firefox` |
| Запустить программу при логине | `~/.config/hypr/user.conf` | `exec-once = telegram-desktop` |
| Сменить монитор / разрешение | `~/.config/hypr/user.conf` | `monitor = DP-1, 2560x1440@144, 0x0, 1` |
| Поменять обои | замени файл | `~/Pictures/wallpaper.png` |
| Включить системный сервис | `custom/<host>.nix` | `services.tailscale.enable = true;` |
| Перетереть значение из `modules/` | `custom/<host>.nix` | `services.X.enable = lib.mkForce false;` |
| Свой полноценный NixOS-модуль | `custom/<host>/<моё>.nix` (папка) | см. ниже |
| Сменить kb_layout с сохранением | `hosts/<host>/settings.nix` (v0.2.0+) | `kbLayouts = "us,ru,de";` |

## Три модели для `custom/`

### Модель 1: один файл — `custom/<host>.nix`

Самая простая, для маленьких машин:

```nix
{ pkgs, lib, settings, ... }: {
  imports = [ ../extras/gaming.nix ];
  environment.systemPackages = with pkgs; [ discord telegram-desktop ];
  services.tailscale.enable = true;
}
```

### Модель 2: папка — `custom/<host>/`

Для машин где много правок, разносим по теме:

```
custom/my-laptop/
├── default.nix       ← точка входа
├── packages.nix      ← дополнительные пакеты
├── services.nix      ← системные сервисы
└── overrides.nix     ← mkForce'ы и тонкая настройка
```

`default.nix`:

```nix
{ ... }: {
  imports = [
    ./packages.nix
    ./services.nix
    ./overrides.nix
    ../../extras/gaming.nix
    ../../extras/development.nix
  ];
}
```

`mkHost.nix` сам понимает в каком формате `custom/<host>` — файл или папка
(back-compat).

### Модель 3: своя полноценная NixOS-фича

Например — добавить i3 поверх Hyprland для совместимости:

```
custom/my-laptop/
├── default.nix
└── extras/
    └── i3-extra.nix      ← свой полноценный модуль
```

`extras/i3-extra.nix` пишется как обычный NixOS-модуль:

```nix
{ config, lib, pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
}
```

Импортируется в `custom/my-laptop/default.nix`:

```nix
{ ... }: {
  imports = [ ./extras/i3-extra.nix ];
}
```

## Использование готовых `extras/`

Текущий каталог:

| Модуль | Что |
|---|---|
| `extras/gaming.nix` | Steam, GameMode, Gamescope, MangoHud, ProtonUP, Lutris, steam-run |
| `extras/development.nix` | Podman + docker alias, podman-compose, lazydocker, dive |

Подключи через `imports`:

```nix
{ ... }: {
  imports = [
    ../extras/gaming.nix
    ../extras/development.nix
  ];
}
```

Хочешь свой `extras/` — пиши в `custom/<host>/extras/<имя>.nix` (см. Модель 3),
или если он переиспользуем многими — присылай PR (см. `CONTRIBUTING.md`).

## Override модуля из `modules/`

`modules/` нельзя править — но можно **переопределить** опции через `lib.mkForce`:

```nix
{ lib, ... }: {
  # Дефолт repo включает hypridle — выключим у себя:
  services.hypridle.enable = lib.mkForce false;

  # Дефолт extras/gaming.nix включает gamescope — нам не нужно:
  programs.gamescope.enable = lib.mkForce false;
}
```

## Mutable layer: live-правки

Эти два файла создаются один раз при первой установке и **никогда не задеваются**
обновлениями. Идеальны для проб без полной пересборки.

### `~/.config/hypr/user.conf`

Подключается последним в `hyprland.conf`. Любая директива здесь переопределяет
дефолт. Применяется **на лету** через `hyprctl reload`, не нужен `nrs`.

```bash
# Пример
echo 'bind = SUPER, B, exec, firefox' >> ~/.config/hypr/user.conf
hyprctl reload
```

Шаблон с примерами — `modules/user/dotfiles/hyprland/user.conf.template`.

### `~/.config/fish/conf.d/local.fish`

Подключается fish'ем при старте оболочки. Здесь — твои алиасы, функции,
переменные окружения. Подхватывается при `exec fish` или открытии нового
терминала, не нужен `nrs`.

```fish
# Пример
alias myproj 'cd ~/work/my-project'
set -x GITHUB_TOKEN "ghp_..."   # будет в env только для тебя
```

## Когда что выбрать

| Сценарий | Использовать |
|---|---|
| Пробую быструю идею (бинд, алиас) | `user.conf` / `local.fish` (live) |
| Уверен в правке, хочу версионировать на этой машине | `custom/<host>.nix` |
| Правка нужна на всех моих машинах | пиши в свой fork `modules/` или собственный extras/ |
| Правка кажется полезной для всех | присылай PR в upstream — `CONTRIBUTING.md` |
