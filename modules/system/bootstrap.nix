# =============================================================================
# modules/system/bootstrap.nix — Автоматическое создание копии репо в $HOME
# =============================================================================
# При первой установке копирует исходники флейка в $HOME/<username>/nixos-config
# и инициализирует git репо с upstream remote'ом.
#
# Идемпотентно: если папка УЖЕ существует, ничего не делается.
#   - первичная установка → копирование + git init
#   - все последующие nixos-rebuild switch → no-op
#   - юзер правит файлы в HOME без страха что bootstrap затрёт их
#
# Локальные файлы (hosts/<host>/settings.nix, hardware.nix, custom/<host>.nix)
# попадают в файловую систему через cp -r из /nix/store, НО в git commit не
# входят благодаря .gitignore в корне репозитория — git их игнорирует.
#
# Upstream URL берётся из settings.upstream (опционально), дефолт — этот репо.
# =============================================================================
{ pkgs, settings, inputs, ... }:
let
  upstream = settings.upstream or "https://github.com/Nhrust/nixos-config.git";
  user     = settings.username;
in {
  system.activationScripts.bootstrapConfigRepo = ''
    USER_HOME=/home/${user}
    TARGET="$USER_HOME/nixos-config"

    # Идемпотентность: если папка уже есть — выходим, ничего не трогаем
    if [ -d "$TARGET" ]; then exit 0; fi

    # Если пользователь ещё не существует (промежуточное состояние при rebuild)
    if ! id "${user}" >/dev/null 2>&1; then
      echo "bootstrap: user ${user} ещё не создан, пропускаю" >&2
      exit 0
    fi

    # Если $HOME отсутствует (бывает при некоторых сетапах) — создаём
    if [ ! -d "$USER_HOME" ]; then
      ${pkgs.coreutils}/bin/mkdir -p "$USER_HOME"
      ${pkgs.coreutils}/bin/chown ${user}:users "$USER_HOME"
    fi

    echo "bootstrap: создаю $TARGET (первый запуск)"

    # Копируем флейк-снимок из /nix/store. inputs.self указывает на снимок
    # исходников который Nix вычислил при evaluation; туда входит ВСЁ что
    # лежало в директории во время nixos-install --flake "path:.#<host>",
    # включая твои settings.nix и hardware.nix.
    ${pkgs.coreutils}/bin/cp -r ${inputs.self} "$TARGET"

    # Файлы из /nix/store идут с read-only правами и владельцем root —
    # делаем мутабельными и передаём пользователю
    ${pkgs.coreutils}/bin/chmod -R u+w "$TARGET"
    ${pkgs.coreutils}/bin/chown -R ${user}:users "$TARGET"

    # Инициализируем git репо. Локальные файлы исключаются .gitignore'ом —
    # они есть в файлсистеме, но в коммит не попадают.
    cd "$TARGET"
    ${pkgs.git}/bin/git init -q -b main
    ${pkgs.git}/bin/git remote add upstream "${upstream}" 2>/dev/null || true
    ${pkgs.git}/bin/git add -A
    ${pkgs.git}/bin/git \
      -c user.email=bootstrap@local \
      -c user.name="Bootstrap" \
      commit -q -m "initial bootstrap from upstream"

    # После git init права в .git/ могут сбиться на root — chown повторно
    ${pkgs.coreutils}/bin/chown -R ${user}:users "$TARGET"

    echo "bootstrap: готово. $TARGET создан, git init выполнен."
  '';
}
