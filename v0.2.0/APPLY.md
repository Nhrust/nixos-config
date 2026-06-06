# v0.2.0 — инструкция

Tarball **полной замены**: содержит финальное состояние репо после v0.2.0.
Применяется поверх существующего репо (с сохранением `hosts/<host>/`,
`custom/<host>.nix`, `flake.lock`).

## Применение одной командой (рекомендуется)

```fish
cd ~/nixos-config
tar xzf /путь/к/nixos-config-v0.2.0.tar.gz -C /tmp
bash /tmp/v0.2.0/apply.sh
```

`apply.sh`:
1. Делает бэкап твоего `custom/`, `hosts/`, `flake.lock` в `/tmp/`
2. Удаляет `modules/system/main.nix` (его больше нет — разбит на 6 файлов)
3. Удаляет `modules/user/dotfiles/hyprland/conf/input.conf` (заменён на `.in`)
4. Копирует всё содержимое tarball'а поверх репо
5. Восстанавливает твои локальные файлы из бэкапа

После — `git diff --stat`, `nrs`, коммит.

## Применение вручную

Если хочешь контролировать diff:

```fish
cd ~/nixos-config
tar xzf /путь/к/nixos-config-v0.2.0.tar.gz -C /tmp
diff -rq . /tmp/v0.2.0   # посмотри что меняется

# Удалить старые файлы которые исчезли
rm -f modules/system/main.nix
rm -f modules/user/dotfiles/hyprland/conf/input.conf

# Скопировать всё новое
rsync -av --exclude='apply.sh' --exclude='APPLY.md' \
  --exclude='custom/_*.nix' --exclude='custom/*.nix' --exclude='custom/*/' \
  --exclude='hosts/[!_]*' \
  /tmp/v0.2.0/ ./

# Дальше — стандартно
git status
git diff --stat
nrs
```

## После применения

1. **Проверь что собирается:**

   ```fish
   nix flake check
   sudo nixos-rebuild test --flake "path:.#$(hostname)"
   ```

   Если `dry-build` падает — посмотри ошибку, скорее всего нужен импорт
   `extras/<...>` в твой `custom/<host>.nix` или правка `kbLayouts`.

2. **Применить:**

   ```fish
   nrs
   ```

3. **Войти в dev shell** (опционально):

   ```fish
   nix develop
   nix fmt           # форматнуть весь .nix код
   git diff --stat   # посмотреть что изменилось от форматирования
   ```

4. **Коммитить:**

   ```fish
   git add -A
   git commit -m "release: 0.2.0 — DX + Architecture + Docs + Extras"
   git tag v0.2.0
   git push --tags origin main
   ```

## Breaking changes для тебя

Если у тебя были правки в `modules/system/main.nix` — этого файла больше нет.
Он разбит на 6 файлов:
- `modules/system/nix.nix` (nix.gc, experimental features)
- `modules/system/boot.nix` (systemd-boot, swap, hibernation)
- `modules/system/network.nix` (NetworkManager)
- `modules/system/locale.nix` (timezone, i18n)
- `modules/system/users.nix` (основной user)
- `modules/system/base.nix` (системные пакеты, stateVersion)

Перенеси свои правки в свой `custom/<host>.nix` через override (`lib.mkForce`)
или просто как обычные NixOS опции.

## Если что-то пошло не так

`apply.sh` сделал бэкап перед началом — путь печатается в логе. Откатиться:

```fish
# Бэкап лежит в /tmp/nixos-config-backup-XXXXXX
rsync -av /tmp/nixos-config-backup-XXXXXX/ ./
```

## Что ещё посмотреть после применения

- `CHANGELOG.md` — секция `[0.2.0]` с полным списком изменений
- `docs/STRUCTURE.md` — обновлённое дерево репо с пояснениями
- `docs/CUSTOMIZATION.md` — матрица «хочу X → иди в Y»
- `extras/README.md` — как пользоваться готовыми комплектами
- `CONTRIBUTING.md` — если хочешь прислать PR
