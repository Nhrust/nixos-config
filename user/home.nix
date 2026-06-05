{ settings, ... }:
{
  home.username      = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  imports = [
    ./fish.nix
    ./tmux.nix
    ./tools.nix
    ./dev.nix
  ];

  home.stateVersion = "26.05";
}