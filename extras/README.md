# Extras

Опциональные тематические модули — готовые «комплекты» которые подключаются
**по выбору пользователя**. По умолчанию ничего из `extras/` не активно
(в отличие от `modules/system/` и `modules/user/`, которые загружаются всегда).

## Текущий каталог

| Модуль | Что включает | Параметризация |
|---|---|---|
| `gaming.nix` | Steam, GameMode, MangoHud, Gamescope, ProtonUP-Qt, Lutris, steam-run, Wine | `settings.gaming.*` |
| `development.nix` | Podman + docker-CLI alias, podman-compose, lazydocker, dive | `settings.development.*` |

## Как использовать (v0.5.0+)

Каждый extras-модуль имеет соответствующий файл-обёртку в `hosts/_template/`:
- `extras-gaming.nix` — подключает `extras/gaming.nix`
- `extras-development.nix` — подключает `extras/development.nix`

### Шаг 1: Раскомментируй импорт в `hosts/<host>/default.nix`

Когда копируешь `hosts/_template` под имя своей машины, в `default.nix`
у тебя уже готовый список `imports`. Просто раскомментируй нужные:

```nix
# hosts/my-laptop/default.nix
{ ... }: {
  imports = [
    ./packages.nix
    ./services.nix
    ./aliases.nix
    ./extras-gaming.nix          # ← раскомментируй
    ./extras-development.nix     # ← раскомментируй
  ];
}
```

### Шаг 2: Активируй и настрой в `hosts/<host>/settings.nix`

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

Дефолты подопций (когда блок `gaming`/`development` в `settings.nix` не задан
полностью) описаны в начале `extras/<имя>.nix` в `let defaults = ...`.

## Зачем «всегда импортировать, а активировать через settings»?

Альтернатива была — подключать `imports = [ ../../extras/gaming.nix ]` только
когда нужно. Но это менее удобно:
- Чтобы временно выключить — надо править `default.nix`
- Чтобы попробовать одну подопцию — надо помнить весь стек

С текущим подходом:
- Импорт один раз и навсегда в `default.nix` через `extras-gaming.nix`
- Включение/отключение через `settings.gaming.enable = true/false`
- Тонкая настройка через `settings.gaming.<подопция>`
- `settings.nix` остаётся **единым местом** где описаны все параметры машины

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

Также создай файл-обёртку `hosts/_template/extras-media.nix`:

```nix
# hosts/_template/extras-media.nix
{ ... }: {
  imports = [ ../../extras/media.nix ];
}
```

И добавь его в imports в `hosts/_template/default.nix`. Тогда новые машины
будут иметь готовое подключение, юзеру останется только активировать
через `settings.media.enable = true;`.

Если получится универсально-полезный extras — присылай PR в upstream
(`CONTRIBUTING.md`).
