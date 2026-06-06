# =============================================================================
# extras/development.nix — Стек разработки (опционально)
# =============================================================================
# Подключение:
#   imports = [ ../extras/development.nix ];  # в custom/<host>.nix
#
# Что внутри:
#   - Podman (rootless контейнеры, drop-in замена docker)
#   - docker CLI alias → podman (привычные команды работают)
#   - podman-compose (Docker Compose синтаксис)
#   - lazydocker (TUI для управления контейнерами — как lazygit для docker)
#   - docker-buildx (мульти-архитектурные сборки)
#
# Почему podman, а не docker:
#   - rootless по умолчанию — безопаснее, не нужен daemon с root правами
#   - совместим с docker CLI (docker run, docker compose работают)
#   - лучше под Nix-философию (без stateful daemon'а)
#   - не требует группы docker (которая фактически = sudo через сокет)
#
# Если нужен нативный docker (например для specific docker-compose feature
# которая не работает в podman), переопредели в custom/<host>.nix:
#   virtualisation.docker.enable = lib.mkForce true;
#   virtualisation.podman.enable = lib.mkForce false;
# =============================================================================
{ pkgs, settings, ... }:
{
  # ── Podman + Docker alias ─────────────────────────────────────────────────
  virtualisation.podman = {
    enable            = true;
    dockerCompat      = true;   # /run/podman/podman.sock + docker CLI alias
    defaultNetwork.settings.dns_enabled = true;  # для resolve по имени контейнера
  };

  # ── Пользовательские dev-tools ────────────────────────────────────────────
  home-manager.users.${settings.username}.home.packages = with pkgs; [
    podman-compose   # docker-compose синтаксис
    lazydocker       # TUI: lazydocker
    docker-buildx    # мульти-арч сборки (qemu user mode)
    dive             # анализ слоёв образа
  ];

  # ── Удобство: docker без полного пути в скриптах ──────────────────────────
  # podman.dockerCompat уже ставит symlink /usr/bin/docker -> podman,
  # но добавляем алиас в fish чтобы `docker ps` точно работало в любом окружении
  home-manager.users.${settings.username}.programs.fish.shellAliases = {
    docker         = "podman";
    "docker-compose" = "podman-compose";
  };
}
