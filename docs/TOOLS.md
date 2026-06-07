# Инструменты — что есть и как пользоваться

Каталог утилит из коробки + практический cheatsheet «хочу X → команда Y».
Всё ниже **уже установлено и настроено** — никаких `nix-shell` запускать не надо.

---

## 📚 Каталог

### CLI: замены классических утилит

| Утилита | Заменяет | Что делает | Как звать |
|---|---|---|---|
| **eza** | `ls` | Цветной ls с иконками Nerd Font, дерево, git status | `ls` (alias), `ll` (long), `tree` |
| **bat** | `cat` | Cat с подсветкой синтаксиса + git diff inline | `cat` (alias) |
| **fd** | `find` | Быстрая замена find — проще синтаксис, по умолчанию игнорит `.gitignore` | `fd <pattern>` |
| **ripgrep** | `grep -r` | Быстрый рекурсивный grep, уважает gitignore | `rg <pattern>` |
| **zoxide** | `cd` | Умный cd — помнит куда ты ходил, прыгает по частичному имени | `z myproj` |
| **duf** | `df -h` | Красивый df с цветами и табличкой | `duf` |
| **dust** | `du -sh *` | Визуальный disk usage в виде дерева | `dust` |

### CLI: инструменты которых нет в стандартном Linux

| Утилита | Что делает | Как звать |
|---|---|---|
| **fzf** | Fuzzy finder. Встроен в zoxide, fish history (Ctrl+R), file pick (Ctrl+T) | `Ctrl+R`, `Ctrl+T`, или вызов: `<команда> \| fzf` |
| **yazi** | TUI файловый менеджер (как ranger, но быстрее) | `yazi` |
| **btop** | Системный монитор — CPU/RAM/GPU/процессы/сеть | `btop` |
| **helix** | Modal-редактор с LSP из коробки (vim-like, без конфигурации) | `hx file.nix` |
| **lazygit** | TUI для git — коммит/branch/rebase/log в одном окне | `lg` (alias) или `lazygit` |
| **direnv** | Per-project env-переменные через `.envrc` | `direnv allow` в проекте |
| **fastfetch** | Информация о системе при старте fish | (запускается автоматически) |

### Hyprland стек

| Утилита | Что делает | Как звать |
|---|---|---|
| **pyprland** | Scratchpads (всплывающие окна) + smart_gaps | `Super+grave` (терм), `Super+Shift+N` (заметки) |
| **hyprshade** | Шейдеры — blue-light filter, vibrance, и т.д. | `Super+F11` (toggle), CLI: `hyprshade list` / `hyprshade on <name>` |
| **wlogout** | Меню выхода — Lock/Logout/Suspend/Hibernate/Reboot/Shutdown | `Ctrl+Alt+Delete` |
| **hyprlock** | Локскрин (часть Hyprland-стека) | `Super+L` |
| **hypridle** | Автоблокировка по таймауту (только laptop/desktop профили) | автомат, конфиг в `~/.config/hypr/hypridle.conf` |
| **mako** | Уведомления (notify-send показывается через него) | автомат |
| **wofi** | Лаунчер приложений | `Super+R` |

### Опционально (через `extras/`)

| Утилита | Из какого extras | Как звать |
|---|---|---|
| **lazydocker** | `extras/development.nix` (`development.lazydocker = true;`) | `lazydocker` |
| **dive** | `extras/development.nix` | `dive <image>` |
| **mangohud** | `extras/gaming.nix` (`gaming.mangohud = true;`) | `mangohud <game>` |
| **gamemoderun** | `extras/gaming.nix` (`gaming.gamemode = true;`) | `gamemoderun <game>` |
| **protonup-qt** | `extras/gaming.nix` (`gaming.protonup = true;`) | `protonup-qt` (GUI) |
| **lutris** | `extras/gaming.nix` (`gaming.lutris = true;`) | `lutris` |

### Просмотр медиа и буфер обмена (v0.5.1+)

| Утилита | Категория | Команда / триггер |
|---|---|---|
| **mpv** | видеоплеер | `mpv <file>` или клик в Thunar |
| **imv** | картинки | `imv <file>` или клик в Thunar |
| **zathura** | PDF | `zathura <file>.pdf` или клик в Thunar |
| **hyprshot** | скриншоты | `Print` (область) / `Shift+Print` (экран) / `Ctrl+Print` (в файл) |
| **cliphist** | история буфера | `Super+V` (wofi-выбор) |
| **hyprpicker** | color picker | `hyprpicker -a` (в буфер) или `hyprpicker --autocopy` |
| **wf-recorder** | запись экрана | `wf-recorder -g "$(slurp)" -f out.mp4` |
| **playerctl** | управление плеером | `playerctl play-pause` (нужно для XF86AudioPlay) |

---

## 🎯 Cheatsheet — «хочу X → команда Y»

### Навигация и поиск

| Хочу… | Команда |
|---|---|
| Прыгнуть в часто посещаемую папку | `z myproj` |
| Выбрать папку из всех посещённых fzf-меню | `zi` |
| Перейти в родительскую папку | `..` |
| Перейти на два уровня выше | `...` |
| Просмотреть содержимое папки с иконками | `ls` |
| Просмотреть детально (даты, права, размер) | `ll` |
| Дерево директории | `tree` или `ls --tree` |
| Найти файл по имени | `fd config.toml` |
| Найти файл с фильтром по типу | `fd -e nix` (только .nix) |
| Найти строку в коде рекурсивно | `rg "function foo"` |
| Найти строку, фильтр по типу | `rg "TODO" -t nix` |
| Найти строку, показать только имена файлов | `rg -l "import"` |
| Открыть файл в редакторе | `hx file.nix` |
| Просмотреть файл с подсветкой | `cat file.nix` (bat) |

### Git и DevOps

| Хочу… | Команда |
|---|---|
| Открыть TUI для git | `lg` (lazygit) |
| Статус (короткая команда) | `gs` |
| Закоммитить через TUI | `lg` → `c` → ввод сообщения → Enter |
| История коммитов сжато | `gl` |
| Запушить | `gp` |
| Открыть TUI для контейнеров (если ставил development.lazydocker) | `lazydocker` |

### NixOS

| Хочу… | Команда |
|---|---|
| Применить изменения | `nrs` |
| Применить временно (откат при ребуте) | `nrt` |
| Применить при следующей загрузке | `nrb` |
| Откатиться | `nrl` |
| Обновить nixpkgs/inputs | `nfu` |
| Почистить старые поколения | `ngc` |
| Войти в dev shell для работы над репо | `nix develop` (из `~/nixos-config`) |
| Форматнуть .nix код | `nix fmt` (из `~/nixos-config`, после `nix develop`) |

### Системный мониторинг

| Хочу… | Команда |
|---|---|
| Посмотреть процессы / нагрузку | `btop` |
| Что заняло место на диске | `dust` |
| Куда ушли inode'ы / куда смонтировано | `duf` |
| Логи systemd-сервиса | `journalctl -u <сервис> -e` (или `-f` для tail) |
| Логи всей системы (последние) | `journalctl -e` |

### Fish-шорткаты

| Хочу… | Хоткей |
|---|---|
| Найти команду в истории | `Ctrl+R` (fzf-фильтр) |
| Найти файл и вставить в командную строку | `Ctrl+T` |
| Cd через fzf по подпапкам | `Alt+C` |
| Принять предложение из истории | `→` (стрелка вправо) |
| Принять только следующее слово | `Alt+→` |

### Hyprland-десктоп

| Хочу… | Команда / хоткей |
|---|---|
| Открыть терминал | `Super+T` |
| Открыть файловый менеджер | `Super+E` |
| Открыть лаунчер приложений | `Super+R` |
| Залочить экран | `Super+L` |
| Меню выхода | `Ctrl+Alt+Del` |
| Скрин области → буфер | `PrintScreen` |
| Скрин экрана → файл | `Shift+PrintScreen` |
| Сменить power profile | `Super+F1` (perf) / `F2` (balanced) / `F3` (saver) |
| Toggle blue-light filter | `Super+F11` |
| Scratchpad терминал | `Super+grave` (` под Tab) |
| Scratchpad заметок | `Super+Shift+N` |

Полная таблица биндов — `docs/KEYBINDINGS.md`.

---

## 🎓 Quick wins для начинающих

Если только что установился — попробуй эти 5 команд:

```fish
# 1. fastfetch при открытии терминала — уже видишь системную инфу
exec fish

# 2. Дерево репо с иконками
cd ~/nixos-config
ls --tree

# 3. Найти всё про "gaming" в коде
rg gaming

# 4. Открыть редактор на settings.nix
hx hosts/(hostname)/settings.nix

# 5. Запустить lazygit для коммита
lg
```

---

## 🛠 Что если хочется добавить новую утилиту?

Системно (доступна всем юзерам):
```nix
# hosts/<host>/packages.nix (или services.nix)
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.discord ];
}
```

Пользовательски (только в своём `$HOME`):
```nix
# hosts/<host>/packages.nix (или services.nix)
{ pkgs, settings, ... }: {
  home-manager.users.${settings.username}.home.packages = [
    pkgs.spotify
    pkgs.obsidian
  ];
}
```

Если ставишь TUI/CLI инструмент которым будешь пользоваться часто —
добавь fish-алиас в `~/.config/fish/conf.d/local.fish`:

```fish
# ~/.config/fish/conf.d/local.fish
alias myproj 'cd ~/work/my-project'
alias serve 'python3 -m http.server'
```

Без `nrs` — после открытия нового терминала или `source ~/.config/fish/conf.d/local.fish`.

Подробнее — `docs/CUSTOMIZATION.md`.
