# Обновления

## Концепция

Репо разделён на две части:

- **Файлы автора** — `modules/`, `flake.nix`, `lib/`, `docs/`.
  Обновляется через `git pull upstream main`. Идёт в git, ходит между машинами.
- **Твои локальные файлы** — `hosts/<имя>/settings.nix`, `hosts/<имя>/hardware.nix`,
  `hosts/<имя>/` со всеми её файлами. **Не отслеживаются git'ом**
  (исключены через `.gitignore` в корне репо). Существуют только на твоей
  машине, не уходят при `git push`, не конфликтуют при `git pull`.

Поскольку git вообще не видит твои локальные файлы — конфликтов при
обновлении быть не может.

## Получить обновления

```bash
cd ~/nixos-config
git fetch upstream
git merge upstream/main
```

Или одной командой:
```bash
git pull upstream main
```

## Применить обновления

```bash
nrs
```

Это вызовет `nixos-rebuild switch` через `path:` (см. алиас в `fish.nix`)
с новыми модулями. Старое поколение остаётся в меню загрузчика — можно
откатиться если что-то сломалось.

## Обновить зависимости (nixpkgs и т.д.)

```bash
nfu        # alias для: nix flake update ~/nixos-config
nrs        # применить с новыми версиями
```

## Откат

Сломалось после обновления:

```bash
nrl        # откат на предыдущее поколение
```

Или жёстче — выбери предыдущее поколение в меню загрузчика при следующей загрузке.

## Перед мажорным обновлением

Я (автор дистрибутива) обещаю писать в `CHANGELOG.md` обо всех breaking changes.
Читай его перед `git merge upstream/main`.

## Чистка

```bash
ngc        # удалить старые поколения (>7 дней удаляются автоматически еженедельно)
```

## Полная схема workflow

```bash
# Каждый день
git pull upstream main    # подтянуть мои обновления
nrs                       # применить

# Раз в неделю
nfu                       # обновить nixpkgs
nrs                       # применить

# Раз в месяц
ngc                       # почистить store
```

## Куда уходит `git push`?

Если ты сделал свой fork моего репо на github (или gitea/gitlab):

```bash
git remote add origin git@github.com:<твоё-имя>/nixos-config.git
git push -u origin main
```

`upstream` остаётся указывать на мой репо (источник обновлений).
`origin` — на твой fork.

Благодаря `.gitignore`, в `origin` улетают только публичные изменения.
Твои `hosts/<host>/*` остаются исключительно
на твоей машине.

## Что если я хочу свои hosts/<>/settings всё-таки версионировать?

Стандартный паттерн — отдельный приватный git внутри `hosts/<имя>/`:

```bash
cd ~/nixos-config/hosts/my-machine
git init
git remote add origin git@private-server:nixos-private.git
git add settings.nix hardware.nix
git commit -m "my-machine settings"
git push -u origin main
```

Внешний (upstream) репо игнорирует папки где есть свой `.git/` — это
стандартное поведение git. Внутренний (твой приватный) ходит на свой
приватный сервер.
