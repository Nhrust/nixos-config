# =============================================================================
# extras/development.nix — Стек разработки (опционально, v0.3.0+ параметризация)
# =============================================================================
# Подключение:
#   imports = [ ../../extras/development.nix ];  # в hosts/<host>/extras-development.nix
#
# Активация:
#   1. settings.development.enable = true в hosts/<host>/settings.nix
#   2. Опционально — выключи подопции которые не нужны
#
# Если settings.development.enable = false (дефолт) — модуль no-op.
# =============================================================================
{ pkgs, lib, settings, ... }:
let
  defaults = {
    enable        = false;
    podman        = true;
    podmanCompose = true;
    lazydocker    = false;
  };
  cfg = defaults // (settings.development or {});
in
lib.mkIf cfg.enable (lib.mkMerge [

  # ── Podman + Docker alias ─────────────────────────────────────────────────
  (lib.mkIf cfg.podman {
    virtualisation.podman = {
      enable                              = true;
      dockerCompat                        = true;  # docker CLI alias
      defaultNetwork.settings.dns_enabled = true;
    };

    # Fish-алиасы для docker → podman
    home-manager.users.${settings.username}.programs.fish.shellAliases = {
      docker           = "podman";
      "docker-compose" = "podman-compose";
    };
  })

  # ── Дополнительные пакеты пользователя ────────────────────────────────────
  (lib.mkIf (cfg.podmanCompose || cfg.lazydocker) {
    home-manager.users.${settings.username}.home.packages = with pkgs;
      lib.optionals cfg.podmanCompose [ podman-compose ]
      ++ lib.optionals cfg.lazydocker [ lazydocker ];
  })

  # ── Универсальные dev-tools (всегда если development.enable) ──────────────
  (lib.mkIf cfg.enable {
    home-manager.users.${settings.username}.home.packages = with pkgs; [
      dive          # анализ слоёв контейнеров
      docker-buildx # мульти-арч сборки
    ];
  })

])
