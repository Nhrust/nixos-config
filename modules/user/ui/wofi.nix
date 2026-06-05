# =============================================================================
# modules/user/ui/wofi.nix — Launcher (Super+R) + mako (уведомления)
# =============================================================================
{ pkgs, ... }:
{
  home.packages = [ pkgs.wofi ];

  xdg.configFile."wofi/config".source    = ../dotfiles/wofi/config;
  xdg.configFile."wofi/style.css".source = ../dotfiles/wofi/style.css;

  services.mako.enable = true;
}
