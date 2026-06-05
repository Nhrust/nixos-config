# Раздел "Подготовка диска" с тремя сценариями:

## Сценарий 1 — diskMode = "wipe" (автоматически)
Ничего делать не нужно, disko всё сделает сам. Только убедись что правильный диск в settings.disk.

## Сценарий 2 — diskMode = "existing" (вручную, dual-boot)
Полная инструкция через parted + создание сабволюмов:

### Смотрим что есть
lsblk

### Открываем parted для нужного диска
parted /dev/nvme0n1

### Внутри parted:
(parted) mklabel gpt                  # только если диск пустой
(parted) mkpart ESP fat32 1MiB 1GiB
(parted) set 1 esp on
(parted) mkpart root btrfs 1GiB 100%
(parted) quit

### Форматируем
mkfs.vfat -F 32 -n boot /dev/nvme0n1p1
mkfs.btrfs -L nixos /dev/nvme0n1p2

### Создаём сабволюмы
mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@swap
umount /mnt

### Проверяем
mount -o subvol=@ /dev/nvme0n1p2 /mnt
btrfs subvolume list /mnt
umount /mnt

После этого заполняешь diskPartBoot и diskPartRoot в settings.nix и запускаешь установку.

## Сценарий 3 — VM (рекомендуется для первых тестов)
Отдельный блок с командами для QEMU/libvirt — создать образ, запустить ISO, указать виртуальный диск /dev/vda.
