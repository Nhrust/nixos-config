# =============================================================================
# modules/user/wofi.nix — Launcher (Super+R)
# =============================================================================
{ pkgs, ... }:
{
  home.packages = [ pkgs.wofi ];

  xdg.configFile."wofi/config".source = ./dotfiles/wofi/config;
  xdg.configFile."wofi/style.css".source = ./dotfiles/wofi/style.css;

  # mako — уведомления
  services.mako = {
    enable = true;
  };
}
