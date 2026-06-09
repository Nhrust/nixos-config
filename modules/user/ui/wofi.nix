# =============================================================================
# modules/user/ui/wofi.nix — Launcher (Super+R)
# =============================================================================
# style.css генерируется из style.css.in через pkgs.replaceVars
# с подстановкой Catppuccin палитры по settings.theme и settings.themeAccent
# (v0.4.0+). Поддерживает обе темы (Mocha/Latte) и все 14 акцентов.
# =============================================================================
{ pkgs, settings, ... }:
let
  palette = import ../../../lib/catppuccin-colors.nix;
  flavor  = if settings.theme == "light" then "latte" else "mocha";
  c       = palette.${flavor};
  accent  = settings.themeAccent;

  styleCSS = pkgs.replaceVars ../dotfiles/wofi/style.css.in {
    inherit (c.hex) text surface0 surface1;
    base_rgb   = c.rgb.base;
    accent     = c.hex.${accent};
  };
in {
  home.packages = [ pkgs.wofi ];

  xdg.configFile."wofi/config".source    = ../dotfiles/wofi/config;
  xdg.configFile."wofi/style.css".source = styleCSS;
}
