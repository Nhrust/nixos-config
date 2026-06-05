# Шаблон хоста

Это шаблон для создания нового хоста. Не используется напрямую — папки
начинающиеся с `_` игнорируются при сборке.

## Как создать свой хост

```bash
cp -r hosts/_template hosts/my-machine
```

Затем:

1. Открой `hosts/my-machine/settings.nix` и заполни параметры.
2. Замени `hardware.nix` автосгенерированным файлом во время установки
   (см. `docs/INSTALL.md`).
3. Опционально создай `custom/my-machine.nix` для своих дополнений
   (см. `custom/README.md`).
4. Установи систему:
   ```bash
   sudo nixos-install --flake .#my-machine
   ```
