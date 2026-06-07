# hosts/&lt;host&gt;/dotfiles/ — Декларативные override

Любой файл из списка ниже, положенный в эту папку, **автоматически становится
override'ом** соответствующего upstream-dotfile. Не нужно править никакие
`.nix` модули — generic-сканер в `modules/user/dotfile-overrides.nix`
подхватит файл при следующем `nrs`.

## Поддерживаемые файлы

| Имя файла здесь | Куда симлинкается | Что override'ит |
|---|---|---|
| `hypr-user.conf` | `~/.config/hypr/user.conf` | Hyprland — твои бинды/мониторы/правила поверх дефолтных |
| `fish-local.fish` | `~/.config/fish/conf.d/local.fish` | fish — твои алиасы/функции/env |
| `waybar-config.jsonc` | `~/.config/waybar/config.jsonc` | Waybar — полная замена конфига модулей бара |
| `waybar-style.css` | `~/.config/waybar/style.css` | Waybar — стилизация (отменяет theme-aware шаблон) |
| `wofi-config` | `~/.config/wofi/config` | Wofi — настройки лаунчера |
| `wofi-style.css` | `~/.config/wofi/style.css` | Wofi — стилизация (отменяет theme-aware шаблон) |
| `kitty.conf` | `~/.config/kitty/kitty.conf` | Kitty — полная замена конфига терминала |
| `mako.config` | `~/.config/mako/config` | Mako — настройки уведомлений |
| `hypr-monitors.conf` | `~/.config/hypr/conf/monitors.conf` | Hyprland — твои мониторы (заменяет дефолт) |
| `hypr-binds.conf` | `~/.config/hypr/conf/binds.conf` | Hyprland — твои бинды (заменяет ВСЕ дефолтные!) |
| `hypr-decoration.conf` | `~/.config/hypr/conf/decoration.conf` | Hyprland — твоя декорация (отменяет theme-aware шаблон) |
| `hypr-animations.conf` | `~/.config/hypr/conf/animations.conf` | Hyprland — твои анимации |
| `hypr-windowrules.conf` | `~/.config/hypr/conf/windowrules.conf` | Hyprland — твои windowrules |

## Когда использовать override vs `user.conf`

**Используй `hypr-user.conf`** — для **дополнений и точечных правок**. Этот
файл подключается ПОСЛЕДНИМ в `hyprland.conf`, поэтому твои бинды и параметры
**добавляются** к дефолтным или **точечно перебивают**. Большинство правок —
сюда.

**Используй `hypr-binds.conf`** — только если хочешь **полностью заменить
весь набор биндов**. Тогда твой файл полностью встаёт вместо
`modules/user/dotfiles/hyprland/conf/binds.conf`. Будь готов потерять
дефолтные бинды (Super+T для kitty, и т.д.) — придётся переопределить вручную.

Аналогично для `wofi-style.css` и `waybar-style.css` — если кладёшь сюда
свой файл, **theme-aware Catppuccin шаблон из `modules/user/dotfiles/`
больше не применяется**. Получаешь полный контроль, но теряешь авто-смену
темы по `settings.theme`.

## Дефолтная двойка

В `hosts/_template/dotfiles/` лежат два готовых файла-примера:

- `hypr-user.conf` — с закомментированными примерами биндов, мониторов,
  windowrules, env, exec-once
- `fish-local.fish` — с закомментированными примерами алиасов, функций,
  env-переменных

Скопируй `hosts/_template` под именем своей машины (как описано в главном
README), отредактируй эти два файла под себя, удали закомментированные
секции. Остальные dotfile-override файлы из таблицы выше создавай по
потребности — их нет в _template/, чтобы не засорять (generic-сканер
подхватит любой создаваемый файл).

## Полный путь — Mocha-only override style.css

Пример: ты хочешь свою стилизацию waybar (без theme-aware Catppuccin).

```fish
# 1. Создай файл
hx hosts/(hostname)/dotfiles/waybar-style.css

# 2. Заполни CSS как для обычного waybar
# (см. modules/user/dotfiles/waybar/style.css.in как основу — но без @placeholder@)

# 3. Применить
nrs

# 4. Проверь
readlink ~/.config/waybar/style.css
# → /nix/store/.../waybar-style.css (твой)
```

После `nrs` твой файл симлинкается через `lib.mkForce` поверх upstream-версии.
