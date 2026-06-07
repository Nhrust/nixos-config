# =============================================================================
# custom/_examples/aliases.nix — Fish-алиасы декларативно
# =============================================================================
# Альтернатива mutable-варианту через ~/.config/fish/conf.d/local.fish.
# Декларативные алиасы переносятся между машинами вместе с репо.
#
# Если в modules/user/shell/fish.nix уже есть алиас с тем же именем — будет
# ошибка билда. Чтобы переопределить, используй lib.mkForce (см. overrides.nix).
# =============================================================================
{ lib, settings, ... }: {
  home-manager.users.${settings.username}.programs.fish.shellAliases = {

    # ── Личные ярлыки навигации ─────────────────────────────────────────────
    # myproj = "cd ~/work/my-project";
    # docs   = "cd ~/Documents";
    # dl     = "cd ~/Downloads";

    # ── Сокращения для частых команд ────────────────────────────────────────
    # serve  = "python3 -m http.server";
    # ports  = "ss -tunlp";
    # myip   = "curl -s ifconfig.me";

    # ── Docker/Podman ярлыки ────────────────────────────────────────────────
    # d  = "docker";
    # dc = "docker compose";
    # dps = "docker ps --format 'table {{.Names}}\\t{{.Status}}\\t{{.Ports}}'";

    # ── Kubernetes ──────────────────────────────────────────────────────────
    # k     = "kubectl";
    # kctx  = "kubectx";
    # kns   = "kubens";

    # ── Системное ───────────────────────────────────────────────────────────
    # logs  = "journalctl -xe -f";
    # syss  = "systemctl status";
    # sysu  = "systemctl --user status";
  };

  # ── Fish-функции (если нужно сложнее чем алиас) ────────────────────────────
  # home-manager.users.${settings.username}.programs.fish.functions = {
  #   mkcd = {
  #     description = "Create a directory and cd into it";
  #     body        = "mkdir -p $argv[1]; and cd $argv[1]";
  #   };
  # };
}
