# =============================================================================
# modules/user/waybar.nix — Статус-бар
# =============================================================================
{ ... }:
{
  programs.waybar = {
    enable = true;
  };

  # Конфиг и стиль — через симлинки на dotfiles
  xdg.configFile."waybar/config.jsonc".source = ./dotfiles/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source    = ./dotfiles/waybar/style.css;
}
