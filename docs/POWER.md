# Управление питанием

NixOS-config использует **power-profiles-daemon** для управления режимами
питания. Это официальный демон GNOME/KDE, легче чем TLP, лучше интегрирован
с системными утилитами, и поддерживается на современных ядрах из коробки.

## Профили

| Профиль | Когда использовать | Эффект |
|---|---|---|
| `performance` | Стационарный десктоп, тяжёлый воркфлоу, сборки | Максимальные частоты CPU/GPU, fan на максимум |
| `balanced` | Дефолт ноута на питании | Адаптивные частоты, авто-разгон при нагрузке |
| `power-saver` | На батарее в дороге | Низкие частоты, агрессивный CPU idle, экономия |

На laptop профиле автоматически переключается между `balanced` (на питании)
и `power-saver` (на батарее) если `settings.powerProfile = null`.

## Управление вручную

### Через хоткеи

| Бинд | Профиль |
|---|---|
| `Super + F1` | Performance |
| `Super + F2` | Balanced |
| `Super + F3` | Power Saver |

При смене профиля появляется уведомление через `notify-send`.

### Через waybar

В баре справа от трея — иконка профиля:

| Иконка | Профиль | Цвет |
|---|---|---|
| `↑` | Performance | peach (оранжевый) |
| `=` | Balanced | lavender (фиолетовый) |
| `↓` | Power Saver | green |

ЛКМ по иконке — циклит по профилям.

### Через CLI

```fish
powerprofilesctl get          # текущий
powerprofilesctl set balanced # переключить
powerprofilesctl list         # все доступные
```

## Стартовый профиль

`hosts/<host>/settings.nix`:

```nix
{
  # null — auto: laptop → balanced, desktop/server → performance
  # "performance" | "balanced" | "powersave"
  powerProfile = null;
}
```

| `settings.profile` | `powerProfile = null` → стартовый |
|---|---|
| `laptop` | `balanced` |
| `desktop` | `performance` |
| `server` | `performance` |

Можно явно зафиксировать в `settings.nix` если автомат не подходит.

## Лимит заряда батареи (laptop)

Для долговечности батареи можно ограничить максимальный заряд:

```nix
# hosts/<host>/settings.nix
{
  batteryChargeLimit = 80;  # null = без лимита, 80 = стандарт, 60 = постоянно в розетке
}
```

### Поддерживаемое железо

Работает через драйверы Linux на:

| Вендор | Модели где проверено | Драйвер |
|---|---|---|
| ThinkPad (Lenovo) | T-серия, X-серия, P-серия | `thinkpad_acpi` |
| Dell | Latitude, XPS (новые) | `dell_smbios` |
| Asus | ZenBook, ROG, TUF | `asus_wmi` |
| HP | EliteBook, ZBook | `hp_wmi` |

На неподдерживаемом железе настройка молча игнорируется (модуль `power-profiles.nix`
проверяет наличие sysfs-узлов перед записью).

### Проверка работает ли

```fish
# Проверь что значение установлено в ядре:
cat /sys/class/power_supply/BAT0/charge_control_end_threshold
# Должно вернуть твоё значение из settings (80, 60, ...)

# Если файла нет — твоё железо не поддерживает фичу через стандартный sysfs.
# Возможно есть утилита от вендора (например `tlp` для Lenovo).
```

## Гибернация

Заполняется отдельно после первой загрузки — нужен `resume_offset` swap-файла:

```fish
# 1. Узнать UUID корневого раздела
sudo btrfs filesystem show /
sudo blkid /dev/nvme0n1p2          # или твой раздел

# 2. Узнать resume_offset (физический оффсет swap-файла)
sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
```

Затем в `hosts/<host>/settings.nix`:

```nix
{
  rootUUID     = "12345678-1234-1234-1234-123456789abc";
  resumeOffset = 12345678;
}
```

И `nrs`. После этого Hyprland → wlogout → Hibernate работает.

Подробности — `docs/POST_INSTALL.md §6`.

## Известные грабли

**`hyprlock` после выхода из гибернации не разблокировался:**
Известный баг в некоторых версиях. Workaround: `pkill hyprlock && hyprlock`
через TTY (Ctrl+Alt+F2 → войти → команда → Ctrl+Alt+F1 обратно).

**Power Profile не меняется на performance под нагрузкой:**
Это нормально. `balanced` — адаптивный режим, он сам разгонится при нагрузке.
Если хочется зафиксировать частоты — переключи на `performance` явно.

**Иконка в waybar показывает `?`:**
`powerprofilesctl` не отвечает. Проверь:
```fish
systemctl status power-profiles-daemon
sudo systemctl restart power-profiles-daemon
```
