# Установка

Три пути в зависимости от того где ставишь.

---

## Подготовка (для всех путей)

### 1. Скачать ISO

Минимальный ISO: https://nixos.org/download → Minimal install

Запиши на флешку:
```bash
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress
```

### 2. Загрузиться с флешки и подключить сеть

Проводная — работает автоматически.

Wi-Fi:
```bash
iwctl
  station wlan0 scan
  station wlan0 connect "ИМЯ_СЕТИ"
  exit
```

Проверь:
```bash
ping nixos.org
```

### 3. Клонировать репо

```bash
nix-shell -p git
git clone https://github.com/ТВОЙ_ЮЗЕР/trefa-nixos /tmp/trefa-nixos
cd /tmp/trefa-nixos
```

### 4. Создать свой хост из шаблона

```bash
cp -r hosts/_template hosts/my-machine
nano hosts/my-machine/settings.nix
```

Проверь имя диска перед заполнением:
```bash
lsblk
```

---

## Путь 1 — Авторазметка диска (`diskMode = "wipe"`)

> ⚠️ Уничтожает **все данные** на диске указанном в `settings.disk`.

```bash
# 1. Запустить disko (разметит диск и смонтирует в /mnt)
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko --flake .#my-machine

# 2. Сгенерировать файл железа (флаг --no-filesystems обязателен!)
sudo nixos-generate-config --no-filesystems --root /mnt

# 3. Скопировать в hosts/
sudo cp /mnt/etc/nixos/hardware-configuration.nix hosts/my-machine/hardware.nix

# 4. Закоммитить (Nix flakes требуют чтобы все файлы были в git)
git add hosts/my-machine/
git commit -m "Add my-machine"

# 5. Установить систему
sudo nixos-install --flake .#my-machine

# 6. После установки — пароль root и перезагрузка
reboot
```

---

## Путь 2 — Рядом с другой ОС (`diskMode = "existing"`)

> ⚠️ Если на диске уже стоит GRUB — возможен конфликт. Безопаснее использовать
> отдельный диск или VM (Путь 3). Также EFI раздел должен иметь флаг `esp`,
> не только `boot` — иначе systemd-boot не запишет загрузочную запись.

### 2а — Разделы уже есть, нужно только создать сабволюмы

```bash
lsblk -f  # проверь имена

# Монтируем Btrfs раздел (замени nvme0n1p2 на свой)
sudo mount /dev/nvme0n1p2 /mnt

# Создаём все сабволюмы
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix
sudo btrfs subvolume create /mnt/@log
sudo btrfs subvolume create /mnt/@cache
sudo btrfs subvolume create /mnt/@tmp
sudo btrfs subvolume create /mnt/@swap

# Проверяем
sudo btrfs subvolume list /mnt

sudo umount /mnt
```

### 2б — Разметить диск вручную через parted

```bash
sudo parted /dev/nvme0n1

# Внутри parted:
(parted) mklabel gpt              # ТОЛЬКО для пустого диска без таблицы разделов!
(parted) mkpart ESP fat32 1MiB 1GiB
(parted) set 1 esp on             # КРИТИЧНО: флаг esp обязателен
(parted) mkpart root btrfs 1GiB 100%
(parted) print                    # проверить
(parted) quit

# Форматируем
sudo mkfs.vfat -F 32 -n boot /dev/nvme0n1p1
sudo mkfs.btrfs -L nixos /dev/nvme0n1p2

# Создаём сабволюмы (как в 2а)
sudo mount /dev/nvme0n1p2 /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix
sudo btrfs subvolume create /mnt/@log
sudo btrfs subvolume create /mnt/@cache
sudo btrfs subvolume create /mnt/@tmp
sudo btrfs subvolume create /mnt/@swap
sudo umount /mnt
```

### 2в — Установка после подготовки

В `hosts/my-machine/settings.nix`:
```nix
diskMode     = "existing";
diskPartBoot = "/dev/nvme0n1p1";
diskPartRoot = "/dev/nvme0n1p2";
```

```bash
# 1. Смонтировать через disko (mount, не disko)
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode mount --flake .#my-machine

# 2. Проверь что EFI раздел смонтирован
mount | grep /mnt/boot

# 3. Сгенерировать железо
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix hosts/my-machine/hardware.nix
git add hosts/my-machine/ && git commit -m "Add my-machine"

# 4. Установить
sudo nixos-install --flake .#my-machine

# 5. После установки проверить что загрузочная запись создана:
sudo efibootmgr -v | grep -i nixos
# Если записи нет — добавить вручную:
# sudo bootctl install --esp-path=/mnt/boot

reboot
```

---

## Путь 3 — Виртуальная машина (рекомендуется для первого теста)

### QEMU

```bash
# Создать виртуальный диск 40 GB
qemu-img create -f qcow2 nixos-test.qcow2 40G

# Запустить с ISO
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -smp 2 \
  -cpu host \
  -drive file=nixos-test.qcow2,format=qcow2 \
  -cdrom ~/Downloads/nixos-minimal-*.iso \
  -boot d
```

В `settings.nix` для VM:
```nix
disk     = "/dev/vda";
diskMode = "wipe";
profile  = "desktop";
gpu      = "amd";     # виртуальный QXL/Virtio совместим с amdgpu
```

Дальше — как в Пути 1.

### virt-manager

Создай новую ВМ через GUI, укажи ISO, выдели 4 GB RAM / 40 GB диск.
Включи "Customize before install" → выбери UEFI прошивку (OVMF). Без UEFI
systemd-boot не сможет установиться.

---

## После установки

Смотри `docs/POST_INSTALL.md`.
