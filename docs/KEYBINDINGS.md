# Биндинги клавиш

Все бинды по умолчанию из `modules/user/dotfiles/hyprland/conf/binds.conf`.
Свои бинды добавляй в `~/.config/hypr/user.conf` — он подключается ПОСЛЕДНИМ
и переопределяет любые дефолты.

`$mod = SUPER` (клавиша Win/Cmd).

## Запуск приложений

| Бинд | Действие |
|---|---|
| `Super + T` | Терминал (kitty) |
| `Super + E` | Файловый менеджер (Thunar) |
| `Super + R` | Лаунчер приложений (wofi --show drun) |
| `Super + L` | Залочить экран (hyprlock) |
| `Super + Backtick` | Pyprland scratchpad terminal (всплывающий) |
| `Super + Shift + N` | Pyprland scratchpad заметки (helix) |
| `Ctrl + Alt + Delete` | Меню выхода/перезагрузки (wlogout) |

## Управление активным окном

| Бинд | Действие |
|---|---|
| `Super + Q` | Закрыть окно (приложения с tray уйдут в трей) |
| `Super + Shift + Q` | **SIGKILL** зависшего окна (nuke-кнопка) |
| `Super + V` | Toggle плавающий/тайл |
| `Super + P` | Pseudo-tile (слот занят, размер исходный) |
| `Super + J` | Сменить направление следующего сплита |
| `Super + F` | Fullscreen |
| `Super + Shift + R` | `hyprctl reload` (перечитать конфиг) |

## Фокус и перемещение

| Бинд | Действие |
|---|---|
| `Super + ←/→/↑/↓` | Переместить фокус |
| `Super + Shift + ←/→/↑/↓` | Переместить активное окно |
| `Super + ЛКМ` (drag) | Перетаскивать окно мышью |
| `Super + ПКМ` (drag) | Менять размер окна мышью |

## Воркспейсы

| Бинд | Действие |
|---|---|
| `Super + 1–9` | Переключиться на воркспейс 1–9 |
| `Super + 0` | Воркспейс 10 |
| `Super + Shift + 1–0` | Перенести активное окно на воркспейс |
| `Super + колесо мыши` | Переключение по существующим воркспейсам |

## Скриншоты

| Бинд | Действие |
|---|---|
| `PrintScreen` | Выделить область → буфер обмена (`grim + slurp + wl-copy`) |
| `Shift + PrintScreen` | Полный экран → `~/Pictures/screenshot-*.png` |
| `Ctrl + PrintScreen` | Выделить область → `~/Pictures/screenshot-*.png` |

## Power profiles (laptop)

| Бинд | Действие |
|---|---|
| `Super + F1` | Performance (макс производительность) |
| `Super + F2` | Balanced (адаптивно) |
| `Super + F3` | Power Saver (минимум потребления) |
| ЛКМ по иконке профиля в waybar | Циклить performance → balanced → power-saver |

## Blue-light filter

| Бинд | Действие |
|---|---|
| `Super + F11` | Toggle blue-light filter (через `hyprshade`) |

## Громкость, яркость, медиа

Работают даже когда экран залочен (`bindel` / `bindl`).

| Бинд | Действие |
|---|---|
| `XF86AudioRaiseVolume` | Громкость +5% (cap 100%, auto-mute на 0) |
| `XF86AudioLowerVolume` | Громкость -5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle микрофон mute |
| `XF86MonBrightnessUp` | Яркость +5% |
| `XF86MonBrightnessDown` | Яркость -5% |
| `XF86AudioPlay` | Play/Pause (через playerctl) |
| `XF86AudioPrev` | Предыдущий трек |
| `XF86AudioNext` | Следующий трек |

## Жесты тачпада (3 пальца)

| Жест | Действие |
|---|---|
| Свайп влево/вправо | Переключение воркспейсов с анимацией |
| Свайп вверх | Fullscreen активного окна |
| Свайп вниз | Toggle floating/tile активного окна |

## Где править

| Хочу… | Где |
|---|---|
| Сменить бинд (дефолтный) | `~/.config/hypr/user.conf` (override) |
| Добавить новый бинд | `~/.config/hypr/user.conf` |
| Запустить программу при старте | `~/.config/hypr/user.conf` через `exec-once` |
| Изменить раскладку клавиатуры | `hosts/<host>/settings.nix` → `kbLayouts` |
| Перетащить дефолт на свой PR | `modules/user/dotfiles/hyprland/conf/binds.conf` |

Шаблон с примерами override'ов — `modules/user/dotfiles/hyprland/user.conf.template`.
Он копируется в `~/.config/hypr/user.conf` при первой установке.
