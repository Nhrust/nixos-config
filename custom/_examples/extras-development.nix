# =============================================================================
# custom/_examples/extras-development.nix — Подключение dev стека
# =============================================================================
# Импортирует extras/development.nix. Активация и подопции — в
# hosts/<host>/settings.nix:
#
#   development = {
#     enable        = true;    # включить весь блок
#     podman        = true;    # default true — Podman + docker CLI alias
#     podmanCompose = true;    # default true — podman-compose
#     lazydocker    = true;    # default false — TUI для управления контейнерами
#   };
# =============================================================================
{ ... }: {
  imports = [ ../../extras/development.nix ];
}
