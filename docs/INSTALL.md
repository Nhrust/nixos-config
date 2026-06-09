# Установка

Три пути в зависимости от того где ставишь:

- **Путь 1** — авторазметка через disko (`diskMode = "wipe"`). Простой, для пустого диска.
- **Путь 2** — рядом с другой ОС (`diskMode = "existing"`). Ручная разметка через parted.
- **Путь 3** — виртуальная машина (для теста).

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

Стань root один раз, чтобы дальше не писать `sudo` в каждой команде:
```bash
sudo -i
```

### 3. Клонировать репо

```bash
nix-shell -p git
git clone https://github.com/Nhrust/nixos-config.git /root/nixos-config
cd /root/nixos-config
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

## Шаг 0 — Подготовка диска (только для `diskMode = "wipe"`)

Если ставишь на **бывший в употреблении диск** (раньше была другая ОС,
NixOS-установка зависла на середине, диск с предыдущим LUKS/LVM/btrfs/swap) —
сначала запусти подготовку. Это **самая частая причина зависания disko**:
остатки старых подписей, GPT backup в конце диска, активный swap, LUKS
контейнеры.

```bash
# Из корня репо, ОБЯЗАТЕЛЬНО с LiveCD/USB (не из активной системы!):
sudo bash scripts/prep-disk.sh /dev/nvme0n1     # или /dev/sda, /dev/vda — твой диск
```

Скрипт выполнит 8 шагов очистки (см. начало файла), потребует подтверждения
вводом точного пути диска перед стиранием, и проверит что диск **не
примонтирован в активной системе** (иначе откажется работать — защита от
самоубийства, см. ниже).

**Если ставишь на свежий, никогда не использовавшийся диск** — этот шаг
можно пропустить, disko справится сам. Если не уверен — лучше запусти,
скрипт идемпотентен и не сделает хуже.

### Почему `prep-disk.sh` нельзя запускать из активной системы

Скрипт **полностью стирает диск**. Если запустить его из загруженной ОС
которая сейчас работает с этого диска — ты убьёшь свою систему. Поэтому
скрипт проверяет mount points диска и **отказывается работать** если что-то
смонтировано. Защита от человеческого фактора.

Загрузись с NixOS Minimal LiveCD/USB, склонируй репо в `/tmp/`, и запусти
оттуда — диск в этот момент **не активен**, скрипт пропустит проверку.

### Что делать если зависло на середине установки

Если disko уже зависал и диск в полу-размеченном состоянии:

```bash
sudo umount -R /mnt           # отмонтировать остатки прошлой попытки
sudo bash scripts/prep-disk.sh /dev/<твой-диск>   # переподготовить с нуля
# и заново disko
```

См. также `docs/TROUBLESHOOTING.md` секция «Disko завис при установке».

---

## Путь 1 — Авторазметка диска (`diskMode = "wipe"`)

> ⚠️ Уничтожает **все данные** на диске указанном в `settings.disk`.

```bash
# 1. Запустить disko (разметит диск и смонтирует в /mnt)
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko --flake .#my-machine

# 2. Сгенерировать файл железа (флаг --no-filesystems обязателен!)
nixos-generate-config --no-filesystems --root /mnt

# 3. Скопировать в hosts/
cp /mnt/etc/nixos/hardware-configuration.nix hosts/my-machine/hardware.nix

# 4. Установить — ВНИМАНИЕ: используй path: префикс, не просто .#
nixos-install --flake "path:.#my-machine"

# 5. Перезагрузиться
reboot
```

> 💡 **Почему `path:.#` а не `.#`?** Префикс `path:` говорит Nix читать файлы
> прямо с диска, минуя git. Без него Nix берёт состояние последнего коммита
> и не видит `hosts/my-machine/` которая только что появилась (`git add` без
> `commit` для Nix невидим). Через `path:` всё работает сразу, никаких
> `git commit` посреди установки.

---

## Путь 2 — Рядом с другой ОС (`diskMode = "existing"`)

> ⚠️ Если на диске уже стоит GRUB — возможен конфликт. Безопаснее использовать
> отдельный диск или VM (Путь 3). Также EFI раздел должен иметь флаг `esp`,
> не только `boot` — иначе systemd-boot не запишет загрузочную запись.

### 2.1 — Разметить диск вручную через parted

```bash
parted /dev/nvme0n1

# Внутри parted:
(parted) mklabel gpt              # ТОЛЬКО для пустого диска без таблицы разделов!
(parted) mkpart ESP fat32 1MiB 1GiB
(parted) set 1 esp on             # КРИТИЧНО: флаг esp обязателен
(parted) mkpart root btrfs 1GiB 100%
(parted) print                    # проверить
(parted) quit

# Форматируем
mkfs.vfat -F 32 -n boot /dev/nvme0n1p1
mkfs.btrfs -L nixos /dev/nvme0n1p2

# Создаём сабволюмы — должны точно совпадать с lib/btrfs-subvolumes.nix
mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@swap
umount /mnt
```

> 💡 Если хочешь добавить/убрать сабволюм — поменяй и здесь, и в
> `lib/btrfs-subvolumes.nix`. Они должны строго совпадать иначе при загрузке
> система не сможет смонтировать что-то.

### 2.2 — Заполнить settings.nix под existing режим

В `hosts/my-machine/settings.nix`:

```nix
diskMode     = "existing";
diskPartBoot = "/dev/nvme0n1p1";
diskPartRoot = "/dev/nvme0n1p2";
```

### 2.3 — Смонтировать через disko и установить

```bash
# 1. Смонтировать через disko (mount, не disko — disko перетёр бы разделы)
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode mount --flake .#my-machine

# 2. Проверь что EFI раздел смонтирован
mount | grep /mnt/boot

# 3. Сгенерировать железо
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/my-machine/hardware.nix

# 4. Установить (path: префикс — см. пояснение в Пути 1)
nixos-install --flake "path:.#my-machine"

# 5. После установки проверить что загрузочная запись создана:
efibootmgr -v | grep -i nixos
# Если записи нет — добавить вручную:
# bootctl install --esp-path=/mnt/boot

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

## После reboot — что произошло автоматически (v0.1.9+)

После установки и перезагрузки войди в систему под своим пользователем
(пароль по умолчанию — `nixos`, сменить через `passwd`).

Сразу после первого логина в HOME уже лежит **готовая копия репо**:

```bash
ls -la ~/nixos-config/
# flake.nix  modules/  hosts/  lib/  extras/  secrets/  .git/  и т.д.
```

Эту папку создал `bootstrap.nix` — активационный скрипт который:
1. Скопировал исходники флейка из `/nix/store` в `~/nixos-config`
2. Сделал тебя владельцем (`chown -R`)
3. Инициализировал git репо, добавил `upstream` remote
4. Создал первый коммит — но **без** твоих локальных файлов
   (вся папка `hosts/<host>/` — в `.gitignore`, кроме `_template/`)

Это значит:
- Все твои правки на месте, рабочие, читаются Nix'ом
- `git status` покажет их как untracked — не в git, не уйдут при `git push`
- `git pull upstream main` подтянет обновления, не задевая твоё

Ничего копировать руками **не нужно**.

---

## После установки

Смотри `docs/POST_INSTALL.md`.
