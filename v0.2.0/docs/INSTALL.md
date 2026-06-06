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

> 💡 **Почему `path:.#` а не `.#`?** Префикс `path:` говорит Nix читать
> файлы прямо с диска, минуя git. Без него Nix берёт состояние последнего
> коммита и не видит `hosts/my-machine/` которая только что появилась
> (git add без commit для Nix невидим). Через `path:` всё работает сразу,
> никаких `git commit` посреди установки.

---

## Путь 2 — Существующие разделы (`diskMode = "existing"`)

Если у тебя уже разбит диск (двойная загрузка, сохранение данных и т.д.):

```bash
# 1. Заполни в settings.nix:
#      diskMode     = "existing";
#      diskPartBoot = "/dev/sdX1";  # EFI раздел
#      diskPartRoot = "/dev/sdX2";  # корневой Btrfs

# 2. Disko ОТФОРМАТИРУЕТ ТОЛЬКО diskPartRoot. EFI раздел не трогается.
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko --flake .#my-machine

# 3. Дальше как в пути 1, начиная с шага 2.
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/my-machine/hardware.nix
nixos-install --flake "path:.#my-machine"
reboot
```

---

## После reboot — что произошло автоматически (v0.1.9+)

После установки и перезагрузки войди в систему под своим пользователем
(пароль по умолчанию — `nixos`, сменить через `passwd`).

Сразу после первого логина в HOME уже лежит **готовая копия репо**:

```bash
ls -la ~/nixos-config/
# flake.nix  modules/  hosts/  lib/  custom/  .git/  и т.д.
```

Эту папку создал `bootstrap.nix` — активационный скрипт который:
1. Скопировал исходники флейка из `/nix/store` в `~/nixos-config`
2. Сделал тебя владельцем (`chown -R`)
3. Инициализировал git репо, добавил `upstream` remote
4. Создал первый коммит — но **без** твоих локальных файлов
   (`hosts/<host>/settings.nix`, `hardware.nix`, `custom/*` — в `.gitignore`)

Это значит:
- Все твои правки на месте, рабочие, читаются Nix'ом
- `git status` покажет их как untracked — не в git, не уйдут при `git push`
- `git pull upstream main` подтянет обновления, не задевая твоё

Ничего копировать руками **не нужно**.

---

## Путь 3 — Виртуалка (QEMU/KVM)

Для тестов:

```bash
qemu-img create -f qcow2 nixos-test.qcow2 40G

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
