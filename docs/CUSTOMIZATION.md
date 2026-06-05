# Кастомизация

Хочешь что-то поверх базы? Есть три уровня кастомизации, от простого к сложному.

---

## Уровень 1 — `~/.config/hypr/user.conf` (для Hyprland)

Самый простой случай. Меняешь поведение Hyprland — биндинги, мониторы,
автозапуск, правила окон.

Файл `~/.config/hypr/user.conf` создаётся **один раз** при первой установке.
Обновления через `git pull` его **не трогают**.

Открой и редактируй:

```bash
hx ~/.config/hypr/user.conf
```

Применить:

```bash
hyprctl reload
# или Super+Shift+R
```

Примеры внутри файла-шаблона. Документация Hyprland: https://wiki.hyprland.org/

---

## Уровень 2 — `custom/<имя-хоста>.nix`

Для всего что не вписывается в `user.conf`. Системные пакеты, сервисы,
параметры HM для других программ.

Создай файл с именем твоего хоста:

```bash
hx custom/$(hostname).nix
```

```nix
{ pkgs, ... }:
{
  # Системные пакеты только для этой машины
  environment.systemPackages = with pkgs; [
    libreoffice
    discord
    obs-studio
  ];

  # Дополнительные сервисы
  services.tailscale.enable = true;

  # Переопределение опций
  services.tlp.settings.STOP_CHARGE_THRESH_BAT0 = 100;
}
```

Применить:

```bash
nrs
```

### HM настройки в custom

```nix
{ pkgs, ... }:
{
  home-manager.users.admin = { pkgs, ... }: {
    home.packages = with pkgs; [
      spotify
      telegram-desktop
    ];

    programs.vscode = {
      enable  = true;
      package = pkgs.vscodium;
    };
  };
}
```

---

## Уровень 3 — Fork репозитория

Если хочешь менять сам дистрибутив (`modules/`, `flake.nix`) — делай fork.
Не редактируй `modules/` в склонированном репо, потеряешь при `git pull upstream`.

---

## Что можно переопределять

- ✅ Любые пакеты (`environment.systemPackages`, `home.packages`)
- ✅ Сервисы (`services.*`)
- ✅ Hardware-настройки (`hardware.*`)
- ✅ Переменные окружения
- ✅ Параметры программ из Home Manager
- ✅ Hyprland через `user.conf`

## Что НЕ стоит трогать

- ❌ `system.stateVersion` — должен быть зафиксирован
- ❌ `home.stateVersion` — то же самое
- ❌ Disko после первой установки
- ❌ `modules/` напрямую (твои правки потеряются при `git pull`)

---

## Примеры

### Своя тема для одной машины

```nix
# custom/my-laptop.nix
{ ... }:
{
  home-manager.users.admin = {
    catppuccin = {
      flavor = "frappe";   # переопределить mocha
      accent = "pink";     # переопределить mauve
    };
  };
}
```

### Дополнительные шрифты

```nix
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    fira-code
    inter
  ];
}
```

### Intel 12+ поколения (vpl-gpu-rt)

```nix
{ pkgs, ... }:
{
  hardware.graphics.extraPackages = with pkgs; [
    vpl-gpu-rt
  ];
}
```

### Свои биндинги Hyprland

В `~/.config/hypr/user.conf`:

```
bind = SUPER, T, exec, telegram-desktop
bind = SUPER, B, exec, firefox
bind = SUPER SHIFT, Q, exec, hyprctl kill
```

### Подключить второй монитор

В `~/.config/hypr/user.conf`:

```
monitor = DP-1, 2560x1440@144, 0x0, 1
monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
```

---

## Поделиться кастомизацией

Если твоё дополнение полезно всем — открой Pull Request с предложением
добавить опцию в `settings.nix` или модуль в `modules/`.
