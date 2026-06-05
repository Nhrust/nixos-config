# =============================================================================
# modules/user/ui/waybar.nix — Статус-бар
# =============================================================================
{ ... }:
{
  programs.waybar.enable = true;

  xdg.configFile."waybar/config.jsonc".source = ../dotfiles/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source    = ../dotfiles/waybar/style.css;
}
