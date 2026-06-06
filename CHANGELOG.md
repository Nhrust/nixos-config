# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [0.4.0] — 2026-06-06

Theme-aware CSS/конфиги — устранены последние хардкоды Catppuccin Mocha
в `wofi/style.css`, `waybar/style.css`, `hyprlock.conf`. Теперь смена
`settings.theme = "light"` корректно подбирает Latte-палитру, а
`settings.themeAccent = "blue"` (или любой из 14 акцентов) перекрашивает
рамку wofi и outline hyprlock-поля. **Не breaking** — поведение по умолчанию
(Mocha + mauve) сохраняется идентично.

### Added

- **`lib/catppuccin-colors.nix`** — централизованная палитра обеих тем
  (Mocha + Latte) в двух формах (hex без `#` для CSS, и rgb `"R, G, B"` для
  `rgba()` / `rgb()`). Все 14 акцентов покрыты в обеих формах. Импортируется
  модулями для подстановки через `pkgs.substituteAll`.

### Changed

- **`modules/user/dotfiles/wofi/style.css` → `wofi/style.css.in`** — шаблон с
  placeholder'ами `@base_rgb@`, `@text@`, `@surface0@`, `@surface1@`, `@accent@`.
  Финальный `~/.config/wofi/style.css` генерируется через
  `pkgs.substituteAll` с подставленными цветами по `settings.theme` и
  `settings.themeAccent`.
- **`modules/user/dotfiles/waybar/style.css` → `waybar/style.css.in`** —
  шаблон с placeholders `@base_rgb@`, `@peach@`, `@lavender@`, `@green@`
  (powerprofile цвета — семантичные, всегда peach/lavender/green из текущей
  палитры независимо от акцента).
- **`modules/user/dotfiles/hyprland/hyprlock.conf` → `hyprlock.conf.in`** —
  шаблон с placeholders `@base_rgb@`, `@text_rgb@`, `@accent_rgb@`.
- **`modules/user/ui/wofi.nix`** — добавлена логика генерации `style.css`
  через `substituteAll`. Импортирует `lib/catppuccin-colors.nix`.
- **`modules/user/ui/waybar.nix`** — то же; одновременно переход с
  `programs.waybar.style = builtins.readFile ...` на `xdg.configFile` для
  единообразия (config.jsonc по-прежнему статичный).
- **`modules/user/ui/hyprland.nix`** — генерация `hyprlock.conf` через
  substituteAll рядом с уже существующей логикой для `input.conf`.

### Что делать другу при обновлении

```fish
cd ~/nixos-config
git pull upstream main
nrs
```

Внешне ничего не должно поменяться при дефолтных `theme = "dark"` и
`themeAccent = "mauve"` — палитра Mocha + mauve идентична хардкоду который
был раньше. Эффект ощутим только если переключить:

```nix
# hosts/<host>/settings.nix
theme       = "light";     # теперь wofi/waybar/hyprlock тоже становятся светлыми
themeAccent = "blue";      # рамка wofi и outline hyprlock получают синий цвет
```

И `nrs`.

### Что НЕ сделано в этом релизе

- `wlogout/style.css` и `mako` конфиги уже покрыты `catppuccin.autoEnable`
  напрямую — для них шаблон не нужен.
- Цвет border'а активного окна Hyprland (`general:col.active_border` в
  `decoration.conf`) — пока хардкод. Возможный шаг для следующего релиза.


## [0.3.0] — 2026-06-06

Большой релиз: секреты через sops-nix, параметризация `extras/`, опциональные
декларативные dotfiles в `custom/<host>/`, документация по утилитам и секретам.
**Не breaking** для существующих пользователей — все новые опции с дефолтами
которые сохраняют текущее поведение.

### Added

**Секреты через sops-nix**
- **`modules/system/sops.nix`** — настройка sops с автодетектом ssh host key
  как age private key. Условная активация: если `secrets/default.yaml` не
  существует, модуль no-op (для тех кто пока не использует секреты).
- **`.sops.yaml`** в корне — конфиг шифрования с placeholder'ами для
  admin-ключа и host-ключей. Заполняется по инструкции из `docs/SECRETS.md`.
- **`secrets/_example.yaml`** — структурированный шаблон секретов
  (ssh/wifi/api/services разделы) как ориентир. Сам файл gitignored,
  реальный `secrets/default.yaml` создаётся по шаблону + sops-encrypt.
- **`flake.nix`** — добавлен `sops-nix` input. В devShell добавлены
  `sops`, `age`, `ssh-to-age` для работы с секретами.
- **`docs/SECRETS.md`** — полный туториал (193 строки):
  получение age-ключа, заполнение `.sops.yaml`, первый секрет,
  использование в Nix-модулях, добавление нового хоста, troubleshooting.

**Параметризация `extras/`**
- **`settings.gaming.*`** в `hosts/_template/settings.nix` — `enable` +
  подопции `steam`/`gamemode`/`mangohud`/`protonup`/`gamescope`/`lutris`/`steamRun`.
  Дефолты (когда `enable = true`): steam/gamemode/mangohud/protonup `=true`,
  остальные `=false`.
- **`settings.development.*`** — `enable` + подопции `podman`/`podmanCompose`/`lazydocker`.
- **`extras/gaming.nix` переписан** под `lib.mkMerge` + `lib.mkIf cfg.<подопция>`
  для каждого компонента. Когда `gaming.enable = false`, модуль no-op целиком.
- **`extras/development.nix` переписан** аналогично.
- **`extras/README.md`** обновлён под параметризованный подход + пример
  как создать свой `extras/<name>.nix` с собственными settings.

**Опциональные декларативные dotfiles в `custom/<host>/dotfiles/`**
- Если в `custom/<host>/dotfiles/hypr-user.conf` лежит файл — `~/.config/hypr/user.conf`
  управляется декларативно через home-manager (симлинк из /nix/store, обновляется
  через `nrs`). Иначе — fallback на текущую mutable активацию.
- Аналогично для `custom/<host>/dotfiles/fish-local.fish` → `~/.config/fish/conf.d/local.fish`.
- Это позволяет **переносить личные настройки между машинами** через git
  одновременно с защитой mutable-режима для тех кто пока не хочет
  переходить на декларативный путь.

**Обнаружимость утилит**
- **`docs/TOOLS.md`** (200 строк) — каталог всех утилит из коробки + cheatsheet
  «хочу X → команда Y». CLI замены (eza, bat, fd, ripgrep, zoxide, duf, dust),
  TUI инструменты (fzf, yazi, btop, helix, lazygit, direnv), Hyprland-стек
  (pyprland, hyprshade, wlogout, mako, wofi), extras-опции, fish-хоткеи.

### Changed

- **`lib/mkHost.nix`** — `home-manager.extraSpecialArgs` получает `hostName`
  (нужно для обнаружения per-host dotfiles в `custom/<host>/dotfiles/`).
  Подключён `sops-nix.nixosModules.sops`.
- **`modules/user/ui/hyprland.nix`** — принимает `inputs` + `hostName`,
  детектит `custom/<host>/dotfiles/hypr-user.conf`. Mutable активация
  через `home.activation.hyprlandUserConf` теперь обёрнута в
  `lib.mkIf (!hasCustomUserConf)` — не срабатывает если есть custom-версия.
- **`modules/user/shell/fish.nix`** — то же для `local.fish`. **Дополнительно:**
  - Алиасы `nrs`/`nrt`/`nrb`/`nfu` переписаны через `path:` префикс
    (`sudo nixos-rebuild switch --flake "path:$HOME/nixos-config#$(hostname)"`).
    Это закрывает старую ловушку «правки без коммита не применяются».
  - Добавлен алиас `nrt` (test) которого раньше не было.
  - Добавлен `lg = "lazygit"`.
  - Подключена интеграция fzf с fish (`Ctrl+R` для истории, `Ctrl+T` для
    файлов, `Alt+C` для cd-fuzzy).
- **`.gitignore`** — добавлены `secrets/_*.yaml`, `*.dec.yaml`, `sops-key.txt`.

### Что делать другу при обновлении

```fish
cd ~/nixos-config
git pull upstream main
nrs
```

После этого:
- **Алиасы `nrs`/`nrt`/`nrb` теперь работают через `path:`** — твои правки
  применяются мгновенно без коммита (если ты раньше делал `git commit` после
  каждого изменения settings.nix — больше не нужно).
- **`gaming` и `development` в settings.nix не задеты** — если ты не описал
  эти блоки, дефолты `enable = false`, и `extras/gaming.nix` / `extras/development.nix`
  игнорируются (поведение как было). Чтобы включить — добавь блок в
  `hosts/<host>/settings.nix` и подключи `imports = [ ../extras/gaming.nix ];`
  в `custom/<host>.nix`.
- **Секреты** опциональны — пока нет `secrets/default.yaml`, sops-модуль
  ничего не делает. См. `docs/SECRETS.md` если хочешь начать использовать.

### Что НЕ сделано в этом релизе

- **Алиасы fish-local + hypr-user.conf по умолчанию не декларативные** —
  чтобы перевести на декларативный режим, нужно создать `custom/<host>/dotfiles/`
  вручную. Это сознательное решение — большинство пользователей хочет
  оставить mutable правки.
- **`.sops.yaml` в репо с placeholder'ом** — это значит конфиг шифрования
  пустой пока пользователь не заменит `age1REPLACE` на свой ключ. До этого
  попытка `sops --encrypt` упадёт с ошибкой. Это намеренно — без подмены
  никто случайно не зашифрует секрет публичным placeholder'ом.


## [0.2.0] — 2026-06-06

Большой релиз: DX + архитектурный рефакторинг + расширяемость + полностью
переписанная документация. **Breaking changes** для тех кто хранил локальные
переопределения в `modules/main.nix` — этот файл больше не существует.

### Added — DX (developer experience)

- **`flake.nix` formatter:** `nix fmt .` теперь работает, использует
  `nixfmt-rfc-style` (официальный новый форматтер).
- **`flake.nix` devShells:** `nix develop` входит в окружение с
  `nixfmt-rfc-style`, `deadnix`, `statix`, `nil` (LSP), `nix-tree`,
  `nix-output-monitor`, `gh`, `hyprland`. Для работы НАД репо.
- **`.editorconfig`** — единые отступы (2 пробела, LF) для всех редакторов.
- **`.gitattributes`** — нормализация LF для текстовых файлов, защита от CRLF
  при клонировании на Windows.

### Added — Архитектура

- **`lib/btrfs-subvolumes.nix`** — общая схема сабволюмов. Раньше дублировалась
  между `modules/disko/btrfs.nix` и `btrfs-existing.nix`, теперь импортируется
  одним `import`-выражением (DRY).
- **Автодискавер модулей** в `lib/mkHost.nix` и `modules/user/home.nix`.
  Новые `.nix` файлы в безопасных папках (`modules/system/` верхний уровень,
  `services/`, `ui/`, `modules/user/{shell,tools,ui}/`) подхватываются
  автоматически — не нужно править `mkHost.nix` или `home.nix` руками.
  Conditional модули (hardware/profiles/disko) остаются switch-based.
- **`custom/<host>/` папочный формат** в дополнение к `custom/<host>.nix`.
  `mkHost.nix` сам определяет — файл или папка (back-compat).
- **`settings.kbLayouts`** (default `"us,ru"`) — раскладка клавиатуры теперь
  Nix-параметр. Реализация через `pkgs.substituteAll` подменяет `@kbLayout@`
  в `input.conf.in` шаблоне. Друзья переопределяют в своём `settings.nix`
  (`"us,de"`, `"us"`, `"us,ru,de"` и т.д.).

### Changed — Архитектура

- **`modules/system/main.nix` разбит на 6 файлов:**
  - `nix.nix` (nix.gc, experimental features)
  - `boot.nix` (systemd-boot, swap, hibernation)
  - `network.nix` (NetworkManager, hostname)
  - `locale.nix` (timezone, i18n, console keymap)
  - `users.nix` (основной user, fish)
  - `base.nix` (системные пакеты, virtualization, stateVersion)

  Старый `main.nix` удалён. Если ты держал в нём свои правки —
  переноси в `custom/<host>.nix`.

- **`modules/disko/btrfs.nix` и `btrfs-existing.nix`** — переписаны под
  использование `lib/btrfs-subvolumes.nix`. Поведение идентичное.

- **`modules/user/dotfiles/hyprland/conf/input.conf`** переименован в
  `input.conf.in` (это шаблон). Финальный `input.conf` теперь генерируется
  Nix'ом из этого шаблона с подстановкой `settings.kbLayouts`.

### Added — Extras (опциональные комплекты)

- **`extras/gaming.nix`** — Steam (gamescopeSession), GameMode (с настройками
  performance/renice), Gamescope, MangoHud, ProtonUP-Qt, Lutris, steam-run,
  Wine. Юзер добавляется в группу `gamemode`, 32-bit OpenGL гарантирован.
- **`extras/development.nix`** — Podman с `dockerCompat` (docker CLI alias),
  podman-compose, lazydocker, docker-buildx, dive. Fish-алиасы для
  `docker = podman`.
- **`extras/README.md`** — описание подхода, каталог, инструкция «как
  добавить свой extras».

Подключаются через `imports = [ ../extras/<имя>.nix ]` в `custom/<host>.nix`.

### Changed — Документация (полностью переписана)

- **`docs/STRUCTURE.md`** — переписан под актуальное дерево + ASCII data-flow
  диаграмма + принципы организации.
- **`docs/CUSTOMIZATION.md`** — теперь cheat-sheet с матрицей решений
  «хочу X → иди в Y» + 3 модели для `custom/` (файл/папка/полный модуль) +
  override-паттерны через `lib.mkForce`.
- **`README.md`** — раздел «За 5 минут» в начале (быстрый старт), затем
  обзор стека и матрица кастомизации, ссылки на все docs.

### Added — Документация (новые файлы)

- **`docs/KEYBINDINGS.md`** — единая таблица всех биндов Hyprland с
  пояснениями (запуск приложений, окна, воркспейсы, скриншоты, power
  profiles, blue-light filter, медиа, жесты тачпада, где править).
- **`docs/POWER.md`** — power-profiles-daemon, profile selection,
  batteryChargeLimit с матрицей вендоров, гибернация, известные грабли.
- **`docs/HARDWARE.md`** — матрица CPU × GPU × profile, что протестировано
  лично, CPU specifics (AMD/Intel), GPU specifics (AMD/Intel/Nvidia).
- **`CONTRIBUTING.md`** — гайд для PR в корне репо: что приветствуется,
  стиль кода, формат коммитов, проверки перед PR.

### Что делать другу при обновлении

```fish
cd ~/nixos-config
git fetch upstream
git merge upstream/main

# Если у тебя были правки в modules/main.nix — это файл больше не существует.
# Переноси их в свой custom/<host>.nix как override:
# 
#   # custom/<host>.nix
#   { lib, ... }: {
#     # ... твои правки которые были в main.nix
#   }

nrs
```

После обновления:
- Дефолтная раскладка остаётся `us,ru` (то же что раньше)
- Чтобы сменить — добавь `kbLayouts = "us";` (или другое) в `hosts/<host>/settings.nix`
- Чтобы попробовать `extras/gaming.nix` — добавь `imports = [ ../extras/gaming.nix ];`
  в свой `custom/<host>.nix`

### Что НЕ доставляется в этом релизе

Отложено в **v0.3.0**:
- sops-nix для секретов
- `settings.gaming.*` / `settings.development.*` параметризация (сейчас
  extras работают с дефолтами, без подопций)
- Опциональные dotfiles в `custom/<host>/dotfiles/` (для переносимости
  `user.conf`/`local.fish` между машинами)


## [0.1.9] — 2026-06-06

Автоматизация bootstrap'а после установки. После `nixos-install` папка
`~/<user>/nixos-config/` создаётся сама, git репо инициализируется,
upstream-remote добавляется, локальные файлы (settings.nix, hardware.nix,
custom/<host>.nix) исключаются из git через новый `.gitignore` в корне.

Это закрывает дыру в INSTALL.md где приходилось руками делать
`cp -r /root/nixos-config /mnt/home/...` перед reboot.

### Added
- **`modules/system/bootstrap.nix`** — `system.activationScripts` скрипт,
  выполняется при `nixos-install` и каждом `nrs`. Идемпотентен: если
  `~/nixos-config/` уже есть, ничего не делается. При первом запуске:
  1. Копирует исходники флейка из `/nix/store` в `/home/<username>/nixos-config`
  2. `chmod -R u+w` + `chown -R <username>:users` (мутабельность + владелец)
  3. `git init -b main` + `git remote add upstream <url>` + первый коммит
- **`.gitignore`** в корне репозитория. Исключает:
  - `hosts/*/settings.nix` (кроме `hosts/_template/settings.nix`)
  - `hosts/*/hardware.nix` (кроме `hosts/_template/hardware.nix`)
  - `custom/*.nix` (кроме `_example.nix` и `README.md`)
  - `custom/*/` (папки расширенного формата)
  - Стандартный мусор (`result`, `.direnv/`, `*.bak`, `*.swp`)
- **Опциональное поле `settings.upstream`** в `hosts/_template/settings.nix`.
  По умолчанию (если не задано) — `https://github.com/Nhrust/nixos-config.git`.

### Changed
- `lib/mkHost.nix` — `bootstrap.nix` добавлен в список модулей хоста.
- `docs/INSTALL.md` — переписан:
  - Команда установки теперь `nixos-install --flake "path:.#<host>"`
    (с префиксом `path:`, чтобы Nix читал с диска, а не из git HEAD).
    Это убирает ловушку `does not provide attribute "<host>"` которая
    возникала когда юзер `git add`-ил файлы но не делал `git commit`.
  - Убран ручной `cp -r /root/nixos-config /mnt/home/...` перед reboot.
- `docs/UPDATING.md` — концепция переписана: локальные файлы теперь
  не в git, а не «в git но никто их не трогает». Добавлен раздел
  «Куда уходит `git push`» и про nested-private-repo паттерн.

### Что делать другу при обновлении

```fish
cd ~/nixos-config
git fetch upstream && git merge upstream/main
# Убрать из tracking'а локальные файлы которые раньше были в git:
git rm --cached hosts/<host>/settings.nix hosts/<host>/hardware.nix
git rm --cached custom/<host>.nix 2>/dev/null || true
git commit -m "stop tracking local files (v0.1.9 gitignore)"
nrs
```

## [0.1.8] — 2026-06-06

Bug-fix wave: доставка waybar-интеграции power-profiles-daemon, чистка
мёртвой обвязки hypridle на server профиле, удаление хардкоднутых
Catppuccin-цветов которые конфликтовали с `catppuccin.autoEnable`.

### Fixed
- **Waybar `custom/powerprofile` модуль доставлен.** В CHANGELOG v0.1.7 он
  был заявлен, но в реальном `waybar/config.jsonc` отсутствовал — скрипт
  `powerprofile.sh` лежал в репо, но никто его не вызывал. Теперь модуль
  присутствует между `tray` и `backlight`, показывает иконку текущего
  профиля (↑/=/↓), циклит по ЛКМ, обновляется каждые 5 секунд.
- **`hypridle` больше не запускается на server профиле.** Раньше
  `exec-once = hypridle` стоял в общем `autostart.conf` и читал почти
  пустой `idle/server.conf`. Теперь запуск перенесён в
  `conf/profile/laptop.conf` и `conf/profile/desktop.conf`; на server
  демон не стартует, и `hypridle.conf` туда не копируется.
- **Скрипт `powerprofile.sh` получил подкоманду `json`** — выдаёт JSON
  для waybar custom-module (text/tooltip/class).

### Removed
- Хардкоднутые Catppuccin-цвета из `waybar/style.css` для модулей
  `#workspaces`, `#battery.warning/critical`, `#pulseaudio.muted`,
  `#network.disconnected/disabled`, `#bluetooth.*`. Catppuccin autoEnable
  подставляет их сам — хардкод мешал смене акцента.
- Тот же хардкод убран из `wlogout/style.css`.

### Added
- Стиль `#custom-powerprofile.<class>` в `waybar/style.css` — цвет иконки
  меняется по режиму (peach/lavender/green).

### Changed
- Комментарии в `input.conf` (про `clickfinger_behavior`) и `monitors.conf`
  (про override через user.conf) уточнены.


## [0.1.7] — 2026-06-05 (combined)

Большой релиз: Hyprland-полировка + декларативные уведомления + logout-меню +
node power-profiles-daemon + слой кастомизации с примерами.

### Added — Hyprland-полировка
- **`pyprland`** — Python-плагины:
  - `scratchpads.term` — терминал «quake-style» поверх всего, `Super+\``
  - `scratchpads.notes` — helix с `~/.notes.md`, `Super+Shift+N`
  - `smart_gaps` — gaps исчезают когда одно окно на воркспейсе
  - Конфиг: `modules/user/dotfiles/hyprland/pyprland.toml`
  - Autostart: `exec-once = pypr` в `autostart.conf`
- **`hyprshade`** — blue-light filter, бинд `Super+F11` toggle `blue-light-filter`
- **`wlogout`** — графическое logout-меню (Lock/Logout/Suspend/Hibernate/Reboot/Shutdown),
  Catppuccin Mocha-стайл, бинд `Ctrl+Alt+Delete`
  - Заменяет старый опасный `Super+Shift+M = exit`

### Added — Power-profiles-daemon (3-режима для всех машин)
- `services.power-profiles-daemon` включён через `modules/system/power-profiles.nix`
- Новые поля в `hosts/_template/settings.nix`:
  - `powerProfile = null` — `null` авто-выбор по `settings.profile`
    (laptop→balanced, desktop/server→performance), либо явный
    `"performance"`/`"balanced"`/`"powersave"`
  - `batteryChargeLimit = null` — `null` без лимита, или число 1-100 в %
- Бинды `Super+F1/F2/F3` (performance/balanced/powersave) с уведомлениями
- Waybar модуль `custom/powerprofile`: иконка текущего профиля, ЛКМ цикл,
  обновление каждые 5с
- Скрипт `~/.config/hypr/scripts/powerprofile.sh`: `status` / `cycle` / `tooltip`

### Added — Battery charge limit
- Кастомный systemd-сервис `battery-charge-limit` пишет порог в
  `/sys/class/power_supply/BAT*/charge_*_threshold`
- Активируется только когда `settings.batteryChargeLimit != null`
- Работает на ThinkPad, некоторых Dell/HP/Asus — где есть sysfs-узел
- На прочем железе тихо игнорируется

### Added — Декларативный mako
- `modules/user/ui/notifications.nix` — новый модуль
- `services.mako.settings` с top-right, 320×110, JetBrainsMono Nerd Font 11,
  5с обычные / 30с критичные, скруглённые углы

### Added — Декларативный nano
- `programs.nano.nanorc` в `tools/cli.nix`
- Номера строк, подсветка синтаксиса (sh/nix/python/json/md/...), мышь,
  softwrap, 4-space tabs

### Added — Слой персональных настроек (mutable файлы)
- `~/.config/fish/conf.d/local.fish` создаётся при первой установке как
  template с примерами (alias/abbr/функции/env), больше не трогается
  обновлениями. Fish сам подхватывает.
- `~/.config/hypr/user.conf` template расширен — теперь содержит подробные
  примеры: бинды, мониторы, env vars, windowrules, autostart, жесты.
  Подключается ПОСЛЕДНИМ в hyprland.conf — переопределяет любые defaults.

### Added — Слой системных оверрайдов (`custom/<host>.nix`)
- `custom/README.md` переписан с подробными примерами:
  - Добавить системные/user пакеты
  - Свои fish-алиасы декларативно
  - Включить дополнительный сервис
  - Принудительный override (`lib.mkForce`)
- `custom/_example.nix` — готовый template для копирования

### Changed — Бинды
| Что | Было | Стало |
|---|---|---|
| Терминал | `Super+Q` | **`Super+T`** |
| Закрыть окно | `Super+C` | **`Super+Q`** (graceful, respects tray) |
| Force-kill | — | **`Super+Shift+Q`** (новое, SIGKILL) |
| Logout меню | `Super+Shift+M = exit` (опасный!) | **`Ctrl+Alt+Delete = wlogout`** |
| Power performance | — | **`Super+F1`** |
| Power balanced | — | **`Super+F2`** |
| Power powersave | — | **`Super+F3`** |
| Hyprshade toggle | — | **`Super+F11`** |
| Scratchpad term | — | **`Super+\``** |
| Scratchpad notes | — | **`Super+Shift+N`** |

`Super+C` теперь свободен (был killactive).

### Removed
- **TLP** — заменён `power-profiles-daemon`. Charge thresholds через свой systemd-сервис.
- **`Super+Shift+M = exit`** — заменён на `Ctrl+Alt+Delete = wlogout`.

### Changed — архитектура
- `modules/user/ui/wofi.nix`: убран `services.mako.enable` (переехал в `notifications.nix`).
- `modules/user/home.nix`: добавлен импорт `./ui/notifications.nix`.
- `lib/mkHost.nix`: добавлен `../modules/system/power-profiles.nix` в список модулей.

### Что делать другу при обновлении

```fish
cd ~/nixos-config
git fetch upstream
git merge upstream/main

# Если хост настроен — заполни новые поля в settings.nix:
hx hosts/(hostname)/settings.nix
# Добавь:
#   powerProfile = null;
#   batteryChargeLimit = null;

nrs
```

После пересборки и перелогина в Hyprland:
- `~/.config/fish/conf.d/local.fish` появится с примерами
- `~/.config/hypr/user.conf` обновится с расширенными примерами (если ты
  не редактировал старый — он перезапишется новым шаблоном; если
  редактировал — старый останется, поскольку activation проверяет существование)

### Breaking changes
1. `services.tlp` убран — если в твоём `custom/<host>.nix` ты от него зависел,
   надо переключиться на `services.power-profiles-daemon` (или вернуть TLP
   в `custom/`).
2. `Super+Shift+M` больше не выходит из сессии. Используй `Ctrl+Alt+Delete`.
3. `Super+Q` больше не открывает kitty — теперь `Super+T`. Если привык —
   можно переопределить через `~/.config/hypr/user.conf`:
   ```
   unbind = SUPER, T
   unbind = SUPER, Q
   bind = SUPER, Q, exec, kitty
   bind = SUPER, C, killactive
   ```

---

## [0.1.6] — 2026-06-05

### Fixed
- Громкость не выше 100% через `volume.sh` (cap + auto-mute at 0)
- Иконка mute вместо текста, `windowrulev2` → `windowrule`

### Added
- Backlight + Bluetooth waybar модули, кликабельность всего, tooltips,
  wifi-меню через wofi, networkmanagerapplet в трее

---

## [0.1.5] — 2026-06-05

### Changed
- Тачпад: `clickfinger_behavior = false` → button-areas режим

---

## [0.1.4] — 2026-06-05

### Fixed
- "Белая Thunar": `Adwaita-dark` → `adw-gtk3-dark`
- `workspace_swipe = true` (deprecated) → `gesture = ...`

### Added
- Qt theming, nwg-look, Papirus иконки, 3-пальцевые жесты

---

## [0.1.3] — 2026-06-05

### Added
- Дефолтные обои Catppuccin, комментарии в `binds.conf`

### Changed
- Реструктура `dotfiles/hyprland/`: `idle/`, `conf/profile/`, `wallpapers/`

---

## [0.1.2] — 2026-06-05

### Added
- Профильное idle, lid switch без suspend

---

## [0.1.1] — 2026-06-05

### Fixed
- noto-fonts-color-emoji, tuigreet, thunar, catppuccin.autoEnable

### Changed
- flake description, fish-алиасы → `~/nixos-config/`

---

## [0.1.0] — Initial release

Multi-host архитектура, Catppuccin, Hyprland-стек.

---

## Формат записей в будущем

```
## [версия] — дата

### Added — новые фичи
### Changed — изменения существующего
### Deprecated — что будет удалено
### Removed — что удалено
### Fixed — исправления багов
### Breaking — что ломает обратную совместимость
```
