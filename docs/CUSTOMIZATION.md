# Кастомизация

Хочешь что-то поверх базы? Не редактируй `modules/` — потеряешь при обновлении.
Используй один из двух механизмов.

## Путь 1 — `custom/<имя-хоста>.nix`

Создай файл с именем твоего хоста. Он подключится автоматически.

```bash
# Если хост называется my-laptop
nano custom/my-laptop.nix
```

```nix
{ pkgs, ... }:
{
  # Дополнительные системные пакеты
  environment.systemPackages = with pkgs; [
    libreoffice
    discord
    obs-studio
  ];

  # Дополнительные сервисы
  services.tailscale.enable = true;

  # Переопределение настроек
  services.tlp.settings.STOP_CHARGE_THRESH_BAT0 = 100;
}
```

## Путь 2 — Home Manager модуль

Для пользовательских пакетов и конфигов лучше через HM. В том же `custom/my-laptop.nix`:

```nix
{ pkgs, ... }:
{
  home-manager.users.admin = { pkgs, ... }: {
    home.packages = with pkgs; [
      spotify
      telegram-desktop
    ];

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
  };
}
```

## Что можно переопределить

- ✅ Любые пакеты (`environment.systemPackages`, `home.packages`)
- ✅ Сервисы (`services.*`)
- ✅ Hardware-настройки (`hardware.*`)
- ✅ Переменные окружения
- ✅ Параметры программ из Home Manager

## Что НЕ стоит трогать

- ❌ `system.stateVersion` — должен быть зафиксирован
- ❌ `home.stateVersion` — то же самое
- ❌ Disko после первой установки
- ❌ Основные параметры Hyprland (риск что не запустится)

## Пример: своя тема для одной машины

```nix
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

## Пример: дополнительные шрифты

```nix
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    fira-code
    inter
  ];
}
```

## Пример: специфичные параметры ядра

Например для Intel 12+ поколения нужен `vpl-gpu-rt`:

```nix
{ pkgs, ... }:
{
  hardware.graphics.extraPackages = with pkgs; [
    vpl-gpu-rt
  ];
}
```

## Поделиться кастомизацией

Если твоё дополнение полезно всем — открой Pull Request в upstream с предложением
добавить опцию в `settings.nix` или модуль в `modules/`.
