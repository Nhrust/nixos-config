# Кастомизация системы — `custom/`

Эта папка — твой Nix-уровень оверрайдов. Любой файл `custom/<имя-хоста>.nix`
автоматически подцепляется к соответствующему хосту через `lib/mkHost.nix`.

Если файла нет — используются только дефолты из `modules/`.

## Три слоя кастомизации

| Слой | Где | Что внутри | Когда применяется |
|---|---|---|---|
| 1. Default | `modules/` (этот репо) | Базовая конфигурация. Не трогается юзером. | при `nrs` |
| 2. **Custom** | `custom/<host>.nix` | **Этот слой**. Системные пакеты, сервисы, переопределения опций. | при `nrs` |
| 3. Local | `~/.config/.../local.*` и `user.conf` | Бинды, алиасы, mutable конфиги | сразу, без `nrs` |

**Правило:** если вещь — это NixOS-опция или системный пакет, она идёт в `custom/<host>.nix`. Если это конфиг приложения, который читается на лету (hyprland, fish) — лучше в Local-слой.

## Как создать свой custom-файл

```bash
cd ~/nixos-config
cp custom/_example.nix custom/$(hostname).nix
hx custom/$(hostname).nix
nrs
```

## Примеры (раскомментируй нужное в своём файле)

### Добавить системные пакеты

```nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    obsidian
    discord
    libreoffice
    inkscape
  ];
}
```

### Добавить пакеты только для своего юзера

```nix
{ pkgs, settings, ... }: {
  home-manager.users.${settings.username} = {
    home.packages = with pkgs; [
      spotify
      telegram-desktop
      tldr            # `tldr ls` показывает шпаргалку по команде
    ];
  };
}
```

### Добавить fish-алиасы декларативно

```nix
{ settings, ... }: {
  home-manager.users.${settings.username} = {
    programs.fish.shellAliases = {
      myproj = "cd ~/projects/foobar";
      vimrc  = "hx ~/.vimrc";
    };
  };
}
```
(Можно и через `~/.config/fish/conf.d/local.fish` — там mutable файл, не требует `nrs`.)

### Переопределить опцию модуля

Например, поднять `gaps_out` в Hyprland системно:

```nix
{ settings, ... }: {
  home-manager.users.${settings.username} = {
    # переписать gaps через extra конфиг — конкретные опции catppuccin/hyprland
    # лучше через user.conf (mutable), это пример для жёсткой переопределялки
    wayland.windowManager.hyprland.settings.general.gaps_out = 16;
  };
}
```

### Включить дополнительный системный сервис

```nix
{ ... }: {
  services.tailscale.enable = true;       # VPN
  services.fail2ban.enable  = true;       # защита SSH (для сервера)
  services.flatpak.enable   = true;       # если нужны Flatpak пакеты
}
```

### Принудительно перетереть значение из default

Когда нужно вытеснить значение из `modules/` — используй `lib.mkForce`:

```nix
{ lib, ... }: {
  # Отключить мой автостарт hypridle для этой машины:
  # (если в modules/user/dotfiles/hyprland/conf/autostart.conf захардкожено)
  # В этом случае всё равно лучше через ~/.config/hypr/user.conf
  # но для системных опций — mkForce:
  services.openssh.enable = lib.mkForce false;
}
```

### Слои приоритета (если нужно)

Для случаев когда несколько мест задают одну опцию:

```nix
{ lib, ... }: {
  # Низкий приоритет (можно перетереть): lib.mkDefault X
  services.openssh.ports = lib.mkDefault [ 22 ];

  # Высокий приоритет (перебивает default): lib.mkForce X
  services.openssh.ports = lib.mkForce [ 2222 ];
}
```

## Что НЕ стоит делать в custom

- **Hyprland бинды** — для этого есть `~/.config/hypr/user.conf` (mutable, без `nrs`).
- **Fish алиасы для проб/тестов** — для этого есть `~/.config/fish/conf.d/local.fish`.
- **Менять стайлинг waybar / kitty** — лучше через xdg.configFile с `lib.mkForce` или
  через прямое редактирование mutable копии в `~/.config/`.
- **Удалять модули из `modules/`** — это сломает обновления `git pull upstream`.

## Связанные файлы

| Файл | Что в нём настраивается |
|---|---|
| `hosts/<host>/settings.nix` | Высокоуровневые параметры (CPU, GPU, theme, profile) |
| `custom/<host>.nix` | **(этот файл)** Системные пакеты, сервисы, оверрайды |
| `~/.config/hypr/user.conf` | Личные Hyprland бинды и правила (см. шаблон в файле) |
| `~/.config/fish/conf.d/local.fish` | Личные fish алиасы, функции, env vars |
| `~/Pictures/wallpaper.png` | Обои — заменяй любой картинкой, обновы её не трогают |
