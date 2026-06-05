# =============================================================================
# modules/user/ui/wofi.nix — Launcher (Super+R)
# =============================================================================
{ pkgs, ... }:
{
  home.packages = [ pkgs.wofi ];

  xdg.configFile."wofi/config".source    = ../dotfiles/wofi/config;
  xdg.configFile."wofi/style.css".source = ../dotfiles/wofi/style.css;

  # mako (уведомления) перенесён в modules/user/ui/notifications.nix
  # вместе с декларативной конфигурацией и wlogout.
}
