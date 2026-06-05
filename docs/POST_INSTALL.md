# После установки

Первая загрузка прошла, видишь tuigreet. Что делать дальше.

## 1. Войти в систему

Логин: `admin` (или твоё имя из `settings.nix`)
Пароль: `nixos` (initialPassword)

Запустится Hyprland.

## 2. Сменить пароль немедленно

Открой терминал (`Super+Q` → kitty):

```bash
passwd
```

## 3. Положить обои

```bash
mkdir -p ~/Pictures
# Скачай или скопируй любые обои в ~/Pictures/wallpaper.png
cp ~/Downloads/моя-картинка.png ~/Pictures/wallpaper.png
```

Перезагрузить Hyprland: `Super+Shift+R` (или `hyprctl reload` в терминале).

## 4. Склонировать конфиг в домашнюю папку

Во время установки конфиг был в `/tmp/trefa-nixos`. Перенеси его в постоянное место:

```bash
git clone https://github.com/ТВОЙ_ЮЗЕР/trefa-nixos ~/trefa-nixos
```

Если ты делаешь свой fork — добавь upstream:

```bash
cd ~/trefa-nixos
git remote add upstream https://github.com/АВТОР_ДИСТРИБУТИВА/trefa-nixos
```

Теперь обновления получаешь через:
```bash
git fetch upstream
git merge upstream/main
nrs
```

## 5. Проверить алиасы

```bash
nrs --help    # должен быть алиасом на nixos-rebuild switch
ngc           # должен запустить garbage collection
```

## 6. Опционально — настроить гибернацию

По умолчанию выключена (`resumeOffset = 0` в settings).

Чтобы включить:

```bash
# 1. Узнать physical offset swap-файла
sudo btrfs inspect-internal map-swapfile -o /swap/swapfile

# 2. Узнать UUID корневого раздела
sudo blkid /dev/nvme0n1p2

# 3. Записать оба значения в hosts/my-machine/settings.nix
nano ~/trefa-nixos/hosts/$(hostname)/settings.nix

# 4. Применить
nrs

# 5. Проверить — должно появиться меню гибернации
systemctl hibernate
```

## 7. Опциональные сервисы

В `settings.nix` ставишь `true` нужное и `nrs`:

```nix
printing       = true;  # для печати
bluetooth      = true;  # для Bluetooth устройств
virtualization = true;  # для KVM/QEMU
```

После `nrs` соответствующие сервисы поднимутся автоматически.

## 8. Поменять акцентный цвет темы

В `settings.nix`:

```nix
themeAccent = "blue";   # или lavender, teal, pink, mauve...
```

После `nrs` все программы (waybar, wofi, kitty, hyprland) обновят акценты.

## 9. Переключить на светлую тему

```nix
theme = "light";
```

После `nrs` — Catppuccin Latte везде.

## Что дальше

- `docs/UPDATING.md` — как держать систему в актуальном состоянии
- `docs/CUSTOMIZATION.md` — добавить свои пакеты и настройки
- `docs/TROUBLESHOOTING.md` — если что-то не работает
