# =============================================================================
# modules/user/home.nix — Точка входа Home Manager
# =============================================================================
{ settings, ... }:
{
  home.username      = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  imports = [
    ./fish.nix
    ./tmux.nix
    ./tools.nix
    ./dev.nix
    ./kitty.nix
    ./hyprland.nix
    ./waybar.nix
    ./wofi.nix
    ./theme.nix
  ];

  home.stateVersion = "26.05";
}
