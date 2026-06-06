# =============================================================================
# modules/system/bootstrap.nix — Автоматическое создание копии репо в $HOME
# =============================================================================
# При первой установке копирует исходники флейка в $HOME/<username>/nixos-config
# и инициализирует git репо с upstream remote'ом.
#
# Идемпотентно: если папка УЖЕ существует, ничего не делается.
#
# v0.3.1+: Автонастройка sops если в settings задан secretsAdminAgePubKey.
#   - При первой установке заполняет ~/nixos-config/.sops.yaml:
#     1. Подставляет твой admin age public key вместо placeholder'а
#     2. Получает host age key через ssh-to-age (вывод из host SSH key)
#     3. Добавляет &host_<hostname> в keys
#     4. Раскомментирует *host_<hostname> в creation_rules
#   - Если поле не задано (default ""), .sops.yaml не трогается.
# =============================================================================
{ pkgs, settings, inputs, ... }:
let
  upstream = settings.upstream or "https://github.com/Nhrust/nixos-config.git";
  user     = settings.username;

  # Если задан admin age public key — bootstrap автозаполнит .sops.yaml.
  # Получить ключ заранее на любой машине:
  #   ssh-to-age < ~/.ssh/id_ed25519.pub
  # или сгенерировать отдельный:
  #   age-keygen   (показывает public key и сохраняет private в ~/.config/sops/age/keys.txt)
  adminAgeKey = settings.secretsAdminAgePubKey or "";
in {
  system.activationScripts.bootstrapConfigRepo = ''
    USER_HOME=/home/${user}
    TARGET="$USER_HOME/nixos-config"

    # Идемпотентность: если папка уже есть — выходим
    if [ -d "$TARGET" ]; then exit 0; fi

    if ! id "${user}" >/dev/null 2>&1; then
      echo "bootstrap: user ${user} ещё не создан, пропускаю" >&2
      exit 0
    fi

    if [ ! -d "$USER_HOME" ]; then
      ${pkgs.coreutils}/bin/mkdir -p "$USER_HOME"
      ${pkgs.coreutils}/bin/chown ${user}:users "$USER_HOME"
    fi

    echo "bootstrap: создаю $TARGET (первый запуск)"

    # Копируем флейк-снимок из /nix/store
    ${pkgs.coreutils}/bin/cp -r ${inputs.self} "$TARGET"
    ${pkgs.coreutils}/bin/chmod -R u+w "$TARGET"
    ${pkgs.coreutils}/bin/chown -R ${user}:users "$TARGET"

    # ── v0.3.1+: Автонастройка .sops.yaml ─────────────────────────────────
    # Если в settings задан adminAgeKey и .sops.yaml содержит placeholder —
    # заполняем его автоматически. Юзер ничего интерактивного не запускает.
    SOPS_YAML="$TARGET/.sops.yaml"
    if [ -n "${adminAgeKey}" ] && [ -f "$SOPS_YAML" ]; then
      if ${pkgs.gnugrep}/bin/grep -q "age1REPLACE_WITH_YOUR_OWN_AGE_KEY" "$SOPS_YAML"; then
        echo "bootstrap: настраиваю .sops.yaml (admin + host)"

        HOSTNAME_RAW=$(${pkgs.nettools}/bin/hostname)
        HOST_AGE=""
        if [ -f /etc/ssh/ssh_host_ed25519_key.pub ]; then
          HOST_AGE=$(${pkgs.ssh-to-age}/bin/ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub)
        fi

        # 1. Заменить admin placeholder
        ${pkgs.gnused}/bin/sed -i \
          "s|age1REPLACE_WITH_YOUR_OWN_AGE_KEY|${adminAgeKey}|" "$SOPS_YAML"

        # 2. Добавить host ключ если получили
        if [ -n "$HOST_AGE" ]; then
          if ! ${pkgs.gnugrep}/bin/grep -q "&host_$HOSTNAME_RAW" "$SOPS_YAML"; then
            ${pkgs.gnused}/bin/sed -i \
              "/&user/a\\  - \&host_$HOSTNAME_RAW   $HOST_AGE" "$SOPS_YAML"
          fi
          # 3. Раскомментировать в creation_rules
          ${pkgs.gnused}/bin/sed -i -E \
            "s|^([[:space:]]*)#[[:space:]]*-[[:space:]]*\*host_name.*|\1- *host_$HOSTNAME_RAW|" \
            "$SOPS_YAML"
        fi

        ${pkgs.coreutils}/bin/chown ${user}:users "$SOPS_YAML"
        echo "bootstrap: .sops.yaml настроен (admin + host_$HOSTNAME_RAW)"
      fi
    fi

    # Инициализируем git репо
    cd "$TARGET"
    ${pkgs.git}/bin/git init -q -b main
    ${pkgs.git}/bin/git remote add upstream "${upstream}" 2>/dev/null || true
    ${pkgs.git}/bin/git add -A
    ${pkgs.git}/bin/git \
      -c user.email=bootstrap@local \
      -c user.name="Bootstrap" \
      commit -q -m "initial bootstrap from upstream"

    # После git init — снова chown (init создаёт .git/ как root)
    ${pkgs.coreutils}/bin/chown -R ${user}:users "$TARGET"

    echo "bootstrap: готово. $TARGET создан."
  '';
}
