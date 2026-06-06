# =============================================================================
# modules/user/theme.nix — Catppuccin тема + единое покрытие GTK и Qt
# =============================================================================
{ settings, pkgs, ... }:
let
  flavor = if settings.theme == "light" then "latte" else "mocha";
  isDark = settings.theme != "light";

  gtkThemeName  = if isDark then "adw-gtk3-dark" else "adw-gtk3";
  iconThemeName = if isDark then "Papirus-Dark" else "Papirus-Light";
in
{
  # ── Catppuccin core ──────────────────────────────────────────────────────
  # enable + autoEnable явно — без этого свежий catppuccin-nix кидает warning
  # про скорое изменение поведения дефолтов.
  catppuccin = {
    enable     = true;
    autoEnable = true;
    inherit flavor;
    accent     = settings.themeAccent;
  };

  # ── GTK (Thunar, gtk2/3, GTK4 через libadwaita) ──────────────────────────
  gtk = {
    enable = true;
    theme = {
      name    = gtkThemeName;
      package = pkgs.adw-gtk3;
    };
    cursorTheme = {
      name    = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size    = 24;
    };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = isDark; };
    gtk4.extraConfig = { gtk-application-prefer-dark-theme = isDark; };
  };

  # ── Qt (Qt5/Qt6 через Kvantum) ───────────────────────────────────────────
  qt = {
    enable             = true;
    platformTheme.name = "kvantum";
    style.name         = "kvantum";
  };

  home.pointerCursor = {
    name       = "Bibata-Modern-Classic";
    package    = pkgs.bibata-cursors;
    size       = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
