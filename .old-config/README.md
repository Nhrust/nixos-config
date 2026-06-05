# ❄️ NixOS Config

Минималистичная воспроизводимая конфигурация NixOS на базе Flakes + disko + Home Manager.

**Принцип:** заполни один файл `settings.nix` → разверни на любом железе одной командой.

Поддерживаемое железо:
- CPU: AMD, Intel
- GPU: AMD (RADV/Mesa), Intel, Nvidia
- Профили: `laptop`, `desktop`, `server`

---

## 📁 Структура репозитория

```
nixos-config/
├── settings.nix                ← заполняешь перед установкой
├── flake.nix                   ← точка входа, читает settings.nix
├── .gitignore
├── README.md
│
├── disko/
│   ├── btrfs.nix               ← авторазметка диска (diskMode = "wipe")
│   └── btrfs-existing.nix      ← монтирование готовых разделов (diskMode = "existing")
│
├── system/
│   ├── hardware.nix            ← генерируется на каждой машине (не в git)
│   ├── main.nix                ← загрузчик, сеть, локаль, пользователь
│   ├── variables.nix           ← переменные окружения для Wayland
│   ├── hardware/
│   │   ├── cpu-amd.nix
│   │   ├── cpu-intel.nix
│   │   ├── gpu-amd.nix
│   │   ├── gpu-intel.nix
│   │   └── gpu-nvidia.nix
│   └── profiles/
│       ├── laptop.nix          ← TLP, тачпад, powertop, лимит батареи
│       ├── desktop.nix         ← schedutil governor
│       └── server.nix          ← schedutil, thermald (Intel), запрет suspend
│
└── user/
    ├── home.nix                ← точка входа Home Manager
    ├── fish.nix                ← fish shell + все алиасы
    ├── tmux.nix                ← мультиплексор терминала
    ├── tools.nix               ← консольные утилиты
    ├── dev.nix                 ← git, lazygit, direnv
    └── dotfiles/               ← будущие конфиги: hyprland, waybar и т.д.
```

---

## ⚙️ Параметры settings.nix

| Параметр | Описание | Допустимые значения |
|---|---|---|
| `username` | Имя пользователя | строка |
| `hostname` | Имя машины | строка |
| `timezone` | Часовой пояс | строка из [tz database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) |
| `extraLocale` | Вторая локаль для форматов | `"ru_RU.UTF-8"`, `"de_DE.UTF-8"`, `""` |
| `cpu` | Производитель CPU | `"amd"`, `"intel"` |
| `gpu` | Производитель GPU | `"amd"`, `"intel"`, `"nvidia"` |
| `profile` | Профиль использования | `"laptop"`, `"desktop"`, `"server"` |
| `disk` | Путь к диску | `/dev/nvme0n1`, `/dev/sda`, `/dev/vda` |
| `swapSize` | Размер swap в GB | число |
| `diskMode` | Режим разметки | `"wipe"`, `"existing"` |
| `diskPartBoot` | EFI раздел (только `"existing"`) | `/dev/nvme0n1p1` |
| `diskPartRoot` | Btrfs раздел (только `"existing"`) | `/dev/nvme0n1p2` |
| `resumeOffset` | Смещение swap-файла для гибернации | число, `0` = выключить |
| `rootUUID` | UUID корневого раздела | строка |
| `virtualization` | Включить KVM/QEMU | `true`, `false` |
| `gitName` | Имя для git | строка |
| `gitEmail` | Email для git | строка |

---

## 🚀 Установка

### Шаг 1 — Загрузись с ISO

Скачай минимальный образ: https://nixos.org/download
Запиши на флешку и загрузись.

### Шаг 2 — Сеть

```bash
# Проводное подключение работает автоматически.
# Wi-Fi:
iwctl
  station wlan0 scan
  station wlan0 connect "ИМЯ_СЕТИ"
  exit
```

### Шаг 3 — Клонируй репозиторий

```bash
nix-shell -p git
git clone https://github.com/ВАШ_ЮЗЕР/nixos-config /tmp/nixos-config
cd /tmp/nixos-config
```

### Шаг 4 — Заполни settings.nix

```bash
lsblk          # посмотреть имена дисков
nano settings.nix
```

---

## 💾 Путь 1 — Полная разметка (`diskMode = "wipe"`)

> ⚠️ Уничтожает **все данные** на диске указанном в `settings.disk`.

```bash
# 1. Разметка диска через disko
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko --flake .#ТВОЙ_HOSTNAME

# 2. Генерация файла железа — флаг --no-filesystems обязателен:
#    без него hardware.nix будет содержать точки монтирования live-системы
#    и вызовет конфликт с disko при сборке
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix ./system/hardware.nix

# 3. Добавить в git принудительно (файл в .gitignore)
git add -f system/hardware.nix

# 4. Установка
sudo nixos-install --flake .#ТВОЙ_HOSTNAME
```

После завершения: задай пароль root, выполни `reboot`, вытащи флешку.

---

## 💾 Путь 2 — Существующие разделы (`diskMode = "existing"`)

Используется для установки **рядом с другой ОС** или на уже размеченный диск.

> ⚠️ **Важно про загрузчик:** если на диске уже стоит GRUB или другой загрузчик —
> systemd-boot запишется в EFI и они могут конфликтовать. Безопаснее использовать
> отдельный диск или виртуальную машину (Путь 3) для тестов.

### 2а — Разделы уже есть, нужно только создать сабволюмы

```bash
# Проверяем что есть
lsblk -f

# Монтируем Btrfs раздел (замени nvme0n1p2 на свой)
mount /dev/nvme0n1p2 /mnt

# Создаём все сабволюмы
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@swap

# Проверяем
btrfs subvolume list /mnt

umount /mnt
```

### 2б — Нужно разметить диск вручную через parted

```bash
# Смотрим доступные диски
lsblk

# Открываем parted (замени nvme0n1 на свой диск)
parted /dev/nvme0n1

# Внутри parted:
(parted) mklabel gpt          # только для пустого диска без таблицы разделов!
(parted) mkpart ESP fat32 1MiB 1GiB
(parted) set 1 esp on
(parted) mkpart root btrfs 1GiB 100%
(parted) print                # проверить результат
(parted) quit

# Форматируем
mkfs.vfat -F 32 -n boot /dev/nvme0n1p1
mkfs.btrfs -L nixos /dev/nvme0n1p2

# Создаём сабволюмы (те же что в 2а)
mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@swap
btrfs subvolume list /mnt
umount /mnt
```

### 2в — Установка после подготовки разделов

Заполни в `settings.nix`:

```nix
diskMode     = "existing";
diskPartBoot = "/dev/nvme0n1p1";
diskPartRoot = "/dev/nvme0n1p2";
```

```bash
# Монтирование через disko
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode mount --flake .#ТВОЙ_HOSTNAME

# Генерация файла железа (--no-filesystems обязателен)
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix ./system/hardware.nix
git add -f system/hardware.nix

# Установка
sudo nixos-install --flake .#ТВОЙ_HOSTNAME
```

---

## 💾 Путь 3 — Виртуальная машина (рекомендуется для первых тестов)

Самый безопасный способ — полная изоляция, нет риска для данных на хосте.

### QEMU

```bash
# Создать виртуальный диск 40 GB
qemu-img create -f qcow2 nixos-test.qcow2 40G

# Запустить с ISO
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -smp 2 \
  -drive file=nixos-test.qcow2,format=qcow2 \
  -cdrom /path/to/nixos.iso \
  -boot d
```

В `settings.nix` для VM:

```nix
disk     = "/dev/vda";
diskMode = "wipe";
profile  = "desktop";
gpu      = "amd";
```

### virt-manager

Если на хосте уже есть NixOS с `virtualization = true` — создай ВМ через virt-manager GUI.

---

## 🔄 Повседневное использование

После установки клонируй конфиг в домашнюю папку:

```bash
git clone https://github.com/ВАШ_ЮЗЕР/nixos-config ~/nixos-config
```

| Команда | Действие |
|---|---|
| `nrs` | Применить изменения конфига |
| `nrb` | Применить при следующей загрузке |
| `nfu` | Обновить все входные данные (nixpkgs и т.д.) |
| `ngc` | Удалить старые поколения и очистить store |
| `nrl` | Откатиться к предыдущему поколению |

---

## 💤 Включение гибернации (после установки)

По умолчанию гибернация отключена (`resumeOffset = 0`). Для включения:

```bash
# Создать swap-файл
btrfs filesystem mkswapfile --size 16g /swap/swapfile
swapon /swap/swapfile

# Узнать resumeOffset
sudo btrfs inspect-internal map-swapfile -o /swap/swapfile

# Узнать rootUUID
blkid /dev/nvme0n1p2
```

Вписать оба значения в `settings.nix` и выполнить `nrs`.

---

## 🛠️ Известные проблемы и решения

| Ошибка | Причина | Решение |
|---|---|---|
| `path 'system/hardware.nix' does not exist` | Файл не добавлен в git | `git add -f system/hardware.nix` |
| `system/hardware.nix is ignored by .gitignore` | Файл в .gitignore | `git add -f system/hardware.nix` (принудительно) |
| `fileSystems."/".fsType conflicting values: "btrfs" and "tmpfs"` | hardware.nix сгенерирован без `--no-filesystems` и содержит точки монтирования live-системы | Пересоздай: `nixos-generate-config --no-filesystems --root /mnt` |
| `hardware.brightnessctl` — неизвестная опция | Модуль удалён из NixOS | Уже исправлено в конфиге — используем пакет `brightnessctl` |
| `amdvlk has been removed` | Пакет deprecated и удалён из nixpkgs | Уже исправлено — AMD Vulkan обеспечивается через RADV в Mesa |
| Нет загрузочной записи при `diskMode = "existing"` | Конфликт systemd-boot с существующим загрузчиком (GRUB) на EFI разделе | Используй отдельный диск или VM для тестов. При dual-boot — убедись что EFI раздел пустой или содержит только NixOS |

---

## 🎛️ Консольные утилиты

| Утилита | Описание | Алиас |
|---|---|---|
| `eza` | ls с цветами и иконками | `ls`, `ll`, `tree` |
| `zoxide` | умный cd | `cd` → `z` |
| `yazi` | файловый менеджер TUI | `yazi` |
| `fd` | замена find | `find` |
| `bat` | cat с подсветкой синтаксиса | `cat` |
| `ripgrep` | быстрый grep | `grep` → `rg` |
| `fzf` | fuzzy-поиск | встроен в fish |
| `btop` | мониторинг системы | `btop` |
| `duf` | читаемый df | `duf` |
| `dust` | дерево папок по размеру | `dust` |
| `nmap` | сканирование сети | `nmap` |
| `helix` | modal редактор | `hx` |
| `tmux` | мультиплексор терминала | `tmux` |
| `lazygit` | git TUI | `lazygit` |
| `direnv` | автоактивация nix-окружений | автоматически |

---

## 📐 Размер системы

| Компонент | Примерный размер |
|---|---|
| Базовый NixOS + ядро | ~3 GB |
| nixpkgs closure | ~4–6 GB |
| Home Manager пакеты | ~1–2 GB |
| Nix store служебное | ~1 GB |
| **Итого `/nix/store`** | **~9–12 GB** |
| Корень + home | ~500 MB |
| **Итого** | **~10–13 GB** |

Рекомендуемый минимум диска для тестов: **30 GB**.
