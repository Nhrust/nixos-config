# =============================================================================
# modules/user/ui/waybar.nix — Статус-бар
# =============================================================================
{ ... }:
{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ../dotfiles/waybar/style.css;
  };

  xdg.configFile."waybar/config.jsonc".source = ../dotfiles/waybar/config.jsonc;
}
