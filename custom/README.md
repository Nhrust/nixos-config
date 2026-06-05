# custom/ — Пользовательские дополнения

Сюда друзья кладут свои кастомизации поверх базового дистрибутива.
Файл `custom/<имя-хоста>.nix` подключается автоматически если существует.

## Пример

Хост называется `my-laptop` — создай `custom/my-laptop.nix`:

```nix
{ pkgs, ... }:
{
  # Дополнительные пакеты только для этой машины
  environment.systemPackages = with pkgs; [
    libreoffice
    discord
    obs-studio
  ];

  # Можно переопределять что угодно из modules/
  # Например свой шрифт по умолчанию:
  fonts.fontconfig.defaultFonts.monospace = [ "Fira Code" ];

  # Дополнительные сервисы
  services.tailscale.enable = true;
}
```

## Что можно переопределять

- Любые пакеты (`environment.systemPackages`, `home.packages`)
- Сервисы (`services.*`)
- Hardware (`hardware.*`)
- Параметры окружения (`environment.*`)
- Настройки Home Manager (через `home-manager.users.<name>.*`)

## Что НЕ стоит трогать

- `system.stateVersion` — должен оставаться зафиксированным
- Базовые модули из `modules/system/main.nix` без понимания последствий
- Disko конфигурацию после первой установки

## Обновления

Файлы в `custom/` принадлежат тебе и не затрагиваются при `git pull upstream`.
Если ты захочешь поделиться своими дополнениями — открывай PR в upstream
с предложением добавить их в основные модули.
