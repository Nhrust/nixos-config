# =============================================================================
# modules/user/home.nix — Точка входа Home Manager
# =============================================================================
{ settings, ... }:
{
  home.username      = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  imports = [
    # Общее
    ./theme.nix

    # Shell
    ./shell/fish.nix
    ./shell/tmux.nix

    # Инструменты
    ./tools/cli.nix
    ./tools/dev.nix

    # UI приложения
    ./ui/kitty.nix
    ./ui/hyprland.nix
    ./ui/waybar.nix
    ./ui/wofi.nix
    ./ui/notifications.nix
  ];

  home.stateVersion = "26.05";
}
