# Extras

Опциональные тематические модули — готовые «комплекты» которые подключаются
**по выбору пользователя**. По умолчанию ничего из `extras/` не активно
(в отличие от `modules/system/` и `modules/user/`, которые загружаются всегда).

## Текущий каталог

| Модуль | Что включает |
|---|---|
| `gaming.nix` | Steam, GameMode, MangoHud, Gamescope, ProtonUP-Qt, Lutris, steam-run |
| `development.nix` | Podman + docker-CLI alias, podman-compose, lazydocker |

## Как использовать

В своём `custom/<host>.nix` (или `custom/<host>/default.nix`) добавь
`imports`:

```nix
{ ... }: {
  imports = [
    ../extras/gaming.nix
    ../extras/development.nix
  ];
}
```

Каждый модуль самостоятельный — можно подключить любой набор.

## Дефолты подопций

В v0.2.0 модули `extras/` работают **с разумными дефолтами** без
параметризации. Например `extras/gaming.nix` ставит весь типовой gaming-стек.
Если хочется выключить отдельные компоненты — переопредели в
`custom/<host>.nix` через `lib.mkForce`:

```nix
{ lib, ... }: {
  imports = [ ../extras/gaming.nix ];
  programs.gamemode.enable = lib.mkForce false;  # отключить gamemode
}
```

В **v0.3.0** появятся параметры в `settings.nix`
(`settings.gaming.{enable, steam, lutris, gamemode, mangohud, ...}`)
для красивого включения подопций. Сейчас — только всё или ничего.

## Как добавить свой extras

Просто положи новый `.nix` файл в `extras/`. Пример:

```nix
# extras/media.nix
{ pkgs, settings, ... }: {
  home-manager.users.${settings.username}.home.packages = with pkgs; [
    spotify
    vlc
    obs-studio
  ];
}
```

И подключи в `custom/<host>.nix`:

```nix
{ ... }: {
  imports = [ ../extras/media.nix ];
}
```

Если получится что-то полезное и универсальное — присылай PR (`CONTRIBUTING.md`).
