# Секреты (sops-nix)

Зашифрованные YAML в `secrets/` расшифровываются на хосте автоматически
во время `nixos-rebuild`. Под капотом — sops + age + ssh host key.

## Концепция в одной картинке

```
                        ┌────────────────────────────────────┐
                        │ secrets/default.yaml (в репо)       │
                        │ зашифрован для admin_age + host_age │
                        └────────────────┬────────────────────┘
                                         │
                                         │  nixos-rebuild
                                         ▼
       ┌───────────────────────────────────────────────────────┐
       │ /etc/ssh/ssh_host_ed25519_key  ──────►  age private    │
       │              (на хосте)                  расшифровка    │
       └───────────────────────────────────────────────────────┘
                                         │
                                         ▼
                        ┌────────────────────────────────────┐
                        │ /run/secrets/<имя>                  │
                        │ читается из NixOS-модулей через    │
                        │ config.sops.secrets."<имя>".path   │
                        └────────────────────────────────────┘
```

## ⚡ Автонастройка при установке (рекомендуется)

В **v0.3.1+** есть автоматический путь через `bootstrap.nix`. Юзер не запускает
никаких интерактивных скриптов — `.sops.yaml` заполняется автоматом во время
`nixos-install`.

**Подготовка (один раз, перед установкой):**

Получи свой age public key на любой машине где у тебя уже есть ssh:

```fish
nix-shell -p ssh-to-age --run 'ssh-to-age < ~/.ssh/id_ed25519.pub'
# → age1abcxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Или сгенерируй отдельный age key:

```fish
nix-shell -p age --run 'age-keygen -o ~/.config/sops/age/keys.txt'
# покажет: "Public key: age1..."
# private сохранён в ~/.config/sops/age/keys.txt — не теряй
```

**На инсталлере** в `hosts/<host>/settings.nix` заполни:

```nix
secretsAdminAgePubKey = "age1abcxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
```

И продолжай установку как обычно (`disko` → `nixos-install --flake "path:.#"`
→ `reboot`).

**После reboot:** `~/nixos-config/.sops.yaml` уже заполнен:
- твой admin key вместо placeholder
- `&host_<hostname>` с автоматически полученным host age key
- активная строка `- *host_<hostname>` в `creation_rules`

Можно сразу создавать первый зашифрованный секрет — раздел ниже.

**Если без автонастройки** (`secretsAdminAgePubKey` не задан): bootstrap не
трогает `.sops.yaml`. Тогда настраивай руками — следующий раздел.

## Первый запуск — получение age-ключа

После первой установки хоста (или на текущем хосте), получи его age public key:

```fish
sudo nix-shell -p ssh-to-age --run 'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub'
# выводит: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

И твой персональный age key (для редактирования секретов с любой машины):

```fish
# Из существующего SSH ключа
ssh-to-age < ~/.ssh/id_ed25519.pub

# Или сгенерируй отдельный age ключ
age-keygen -o ~/.config/sops/age/keys.txt
# покажет: # public key: age1yyyyyyyyyyyy...
```

## Заполни `.sops.yaml`

```yaml
keys:
  - &admin     age1yyyyyy...     ← твой персональный ключ
  - &host_pc   age1xxxxxx...     ← вывод ssh-to-age для хоста pc
  # - &host_laptop age1zzzzzz... ← для второго хоста (если есть)

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *admin
          - *host_pc
          # - *host_laptop
```

И закоммить — это публичная информация (public keys можно показывать).

## Создай первый секрет

```fish
# 1. Скопируй структуру из примера
cp secrets/_example.yaml secrets/default.yaml

# 2. Отредактируй с реальными значениями (пока НЕзашифрованный — не коммить!)
$EDITOR secrets/default.yaml

# 3. Зашифруй на месте
sops --encrypt --in-place secrets/default.yaml

# 4. Проверь что зашифрован — увидишь base64 cipher вместо твоих значений
head secrets/default.yaml

# 5. Теперь можно коммитить
git add secrets/default.yaml
git commit -m "feat(secrets): initial encrypted secrets"
```

## Редактирование зашифрованного секрета

```fish
# Открывает $EDITOR с расшифрованным содержимым.
# При сохранении автоматически перешифровывается на диске.
sops secrets/default.yaml
```

## Использование секрета в Nix-модуле

В любом модуле (например `custom/<host>.nix` или новом `extras/<foo>.nix`):

```nix
{ config, ... }: {
  # Объявляем какие секреты нам нужны
  sops.secrets."wifi/home_psk" = {};
  sops.secrets."api/github_token" = {
    owner = "trefa";          # кому доступен файл
    mode  = "0400";           # права
  };

  # Используем через config.sops.secrets.<имя>.path
  networking.wireless.networks."home".pskFile =
    config.sops.secrets."wifi/home_psk".path;

  # Или передаём в окружение сервиса
  systemd.services.my-service = {
    serviceConfig.LoadCredential = [
      "github-token:${config.sops.secrets."api/github_token".path}"
    ];
  };
}
```

После `nrs` файлы появятся в `/run/secrets/wifi/home_psk` и т.д. Это
**runtime** расшифровка — пути доступны только после старта systemd,
не на этапе билда.

## Добавить новый хост к существующим секретам

Когда у тебя появилась вторая машина и хочешь чтобы она тоже могла
читать `secrets/default.yaml`:

```fish
# 1. На новом хосте получи его age key
sudo ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# → age1NEW_HOST_KEY

# 2. На любой машине с твоим admin-ключом
$EDITOR .sops.yaml
# добавь:
#   - &host_laptop age1NEW_HOST_KEY
# и включи его в creation_rules → key_groups → age

# 3. Перешифруй существующие секреты с новым ключом
sops updatekeys secrets/default.yaml

# 4. Коммит + push
git add .sops.yaml secrets/default.yaml
git commit -m "feat(secrets): add laptop host"
git push origin main

# 5. На новом хосте
git pull upstream main
nrs
# Теперь /run/secrets/ доступен и тут
```

## Откатить секрет назад в plain text (для миграции/отказа от sops)

```fish
sops --decrypt secrets/default.yaml > /tmp/secrets-decoded.yaml
# работай с plain версией, потом удали /tmp/secrets-decoded.yaml
```

## Несколько файлов секретов

Можно делить:
- `secrets/default.yaml` — общие (wifi, api tokens)
- `secrets/wifi.yaml` — только сетевые PSK
- `secrets/services.yaml` — пароли БД, бэкап-passphrase

В `.sops.yaml` `creation_rules` уже покрывает `secrets/*.yaml` regex'ом —
просто положи файл и зашифруй. В Nix-коде указывай явно:

```nix
sops.secrets."db_password" = {
  sopsFile = ../secrets/services.yaml;  # вместо default.yaml
};
```

## Если что-то пошло не так

**`sops: failed to get the data key required to decrypt the SOPS file`:**
Значит твой age private key (из `~/.config/sops/age/keys.txt` или
`/var/lib/sops-nix/key.txt`) не входит в список `keys:` в `.sops.yaml`.
Проверь что age public key который выводит `age-keygen -y < ~/.config/sops/age/keys.txt`
есть в `.sops.yaml`.

**`secrets/default.yaml не существует` при `nrs`:**
Это нормально — модуль `sops.nix` no-op до тех пор пока не создашь файл.
Команда проходит, секретов просто нет в `/run/secrets/`.

**Хочу отключить sops временно:**
Удали `secrets/default.yaml` (или закомитти пустой), модуль перестанет
активироваться.
