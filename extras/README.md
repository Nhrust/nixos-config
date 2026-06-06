# Extras

Опциональные тематические модули — готовые «комплекты» которые подключаются
**по выбору пользователя**. По умолчанию ничего из `extras/` не активно
(в отличие от `modules/system/` и `modules/user/`, которые загружаются всегда).

## Текущий каталог

| Модуль | Что включает | Параметризация |
|---|---|---|
| `gaming.nix` | Steam, GameMode, MangoHud, Gamescope, ProtonUP-Qt, Lutris, steam-run, Wine | `settings.gaming.*` (v0.3.0) |
| `development.nix` | Podman + docker-CLI alias, podman-compose, lazydocker, dive | `settings.development.*` (v0.3.0) |

## Как использовать

### Шаг 1: Подключи модуль в `custom/<host>.nix`

```nix
{ ... }: {
  imports = [
    ../extras/gaming.nix
    ../extras/development.nix
  ];
}
```

Это **просто импортирует** код. Сам по себе он ничего не активирует —
все блоки внутри обёрнуты в `lib.mkIf cfg.enable`.

### Шаг 2: Активируй и сконфигурируй в `hosts/<host>/settings.nix`

```nix
gaming = {
  enable    = true;
  steam     = true;
  gamemode  = true;
  mangohud  = true;
  gamescope = true;   # переопределил дефолт false
  protonup  = true;
  lutris    = false;
  steamRun  = false;
};

development = {
  enable        = true;
  podman        = true;
  podmanCompose = true;
  lazydocker    = true;
};
```

Дефолты подопций (когда блок `gaming`/`development` в `settings.nix`
не задан полностью) описаны в начале `extras/<имя>.nix` в `let defaults = ...`.

## Зачем «всегда импортировать, а активировать через settings»?

Альтернатива была — подключать `imports = [ ../extras/gaming.nix ]` только
когда нужно. Но это менее удобно:
- Чтобы временно выключить — надо править `custom/<host>.nix`
- Чтобы попробовать одну подопцию — надо помнить весь стек

С текущим подходом:
- Импорт один раз и навсегда
- Включение/отключение через `settings.gaming.enable = true/false`
- Тонкая настройка через `settings.gaming.<подопция>`
- Settings.nix остаётся **единым местом** где описаны все параметры машины

## Как добавить свой extras

Положи новый `.nix` файл в `extras/`. Если параметризуешь через settings —
добавь блок в `hosts/_template/settings.nix` (опционально) и в `let defaults`
своего модуля. Пример:

```nix
# extras/media.nix
{ pkgs, lib, settings, ... }:
let
  defaults = { enable = false; spotify = true; vlc = true; obs = false; };
  cfg = defaults // (settings.media or {});
in
lib.mkIf cfg.enable {
  home-manager.users.${settings.username}.home.packages = with pkgs;
    lib.optionals cfg.spotify [ spotify ]
    ++ lib.optionals cfg.vlc  [ vlc ]
    ++ lib.optionals cfg.obs  [ obs-studio ];
}
```

И подключи как все остальные. Если получится универсально-полезный —
присылай PR в upstream (`CONTRIBUTING.md`).
