# Известные проблемы и решения

## Установка

### `path 'hosts/my-machine/hardware.nix' does not exist in Git`

В Nix flakes виден только тот файл что зафиксирован в git.

```bash
git add hosts/my-machine/
git commit -m "Add my-machine"
```

### `fileSystems."/".fsType conflicting values: "btrfs" and "tmpfs"`

`hardware.nix` сгенерирован без флага `--no-filesystems` и содержит точки монтирования live-системы.

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix hosts/my-machine/hardware.nix
```

### После установки нет загрузочной записи

**Причина 1:** EFI раздел не имеет флага `esp`.

```bash
sudo parted /dev/nvme0n1
(parted) set N esp on    # N — номер EFI раздела
(parted) quit
```

Потом перезапустить установку.

**Причина 2:** `/mnt/boot` не был смонтирован во время установки.

Проверь:
```bash
mount | grep /mnt/boot
```

Если пусто — `nixos-install` не записал systemd-boot.

**Решение:** добавить запись вручную после установки:
```bash
sudo bootctl install --esp-path=/mnt/boot
```

### Не загружается после установки рядом с другой ОС

Если на EFI разделе уже был GRUB — systemd-boot может его перезаписать или
наоборот не сработать. Проверь записи:

```bash
sudo efibootmgr -v
```

Можно вручную добавить запись для NixOS или для другой ОС.

## Сборка / nixos-rebuild

### `option hardware.brightnessctl does not exist`

Опция удалена в новых версиях NixOS. Решение уже в конфиге — используется
просто пакет `brightnessctl` без модуля.

### `error: package amdvlk has been removed`

`amdvlk` deprecated AMD. Решение в конфиге — Vulkan через RADV в Mesa.

### `attribute 'vaapiIntel' missing`

Переименован в `intel-vaapi-driver`. Решение уже в конфиге.

## Hyprland

### Чёрный экран после tuigreet

**Nvidia:** проверь что все четыре модуля ядра загружены:
```bash
lsmod | grep nvidia
# должны быть: nvidia, nvidia_modeset, nvidia_uvm, nvidia_drm
```

Если нет — пересобери систему, убедись что выбран `gpu = "nvidia"` в settings.

**Intel/AMD:** обычно работает из коробки. Если нет — проверь логи:
```bash
journalctl -b -1 --user -u hyprland-session
```

### Waybar не показывает иконки

Не загружен Nerd Font. Проверь:
```bash
fc-list | grep -i jetbrains
```

Должны быть и обычный, и Nerd Font версии. Если нет — пересобери систему.

### Не работает скриншот

Должны быть установлены `grim`, `slurp`, `wl-clipboard`. Проверь:
```bash
which grim slurp wl-copy
```

Все три есть — попробуй вручную:
```bash
grim -g "$(slurp)" - | wl-copy
```

Если ошибка про XDG portal — пересобери систему (`xdg.portal.wlr.enable = true`).

## Звук

### Звука нет

Проверь PipeWire:
```bash
systemctl --user status pipewire
systemctl --user status wireplumber
```

Оба должны быть `active (running)`.

```bash
# Список звуковых устройств
wpctl status

# Выбрать default sink
wpctl set-default <ID>
```

### Звук есть но громкость не меняется через биндинги

Проверь что `wpctl` доступен:
```bash
which wpctl
# /run/current-system/sw/bin/wpctl
```

Если нет — в `modules/system/audio.nix` должен быть включён `services.pipewire`.

## Сеть

### Wi-Fi не подключается

NetworkManager должен быть активен:
```bash
nmcli device status
```

Если устройство есть но не подключается:
```bash
nmcli device wifi list
nmcli device wifi connect "SSID" password "пароль"
```

## Bluetooth

### Не работает после `bluetooth = true`

Применил `nrs`? Проверь:
```bash
systemctl status bluetooth
bluetoothctl power on
```

## Тема

### Тема не применилась

Catppuccin требует пересборки Home Manager. После изменения `settings.theme`:
```bash
nrs
```

Перезапусти Hyprland: `Super+Shift+R` или `hyprctl reload`.

## Гибернация

### `Failed to hibernate system via logind`

Не заполнены `resumeOffset` и `rootUUID` в settings, или заполнены неверно.

См. `docs/POST_INSTALL.md` раздел 6 — как правильно их получить.

## Откат

В любой непонятной ситуации:

```bash
nrl    # откат на предыдущее поколение
```

Или при загрузке выбери предыдущее поколение в меню systemd-boot.

## Если ничего не помогает

1. Проверь логи: `journalctl -b -p err`
2. Открой issue в репо с выводом `nixos-version` и описанием проблемы
3. Откатись на рабочее поколение (`nrl`) и подожди фикса
