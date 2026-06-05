# =============================================================================
# modules/user/theme.nix — Catppuccin тема через catppuccin-nix
# =============================================================================
# Применяет тему ко всем поддерживаемым программам автоматически:
# kitty, waybar, wofi, mako, helix, bat, fish, tmux, fastfetch, hyprland,
# hyprlock, GTK, Qt, Firefox и многим другим.
# =============================================================================
{ settings, pkgs, ... }:
let
  flavor = if settings.theme == "light" then "latte" else "mocha";
in
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    inherit flavor;
    accent = settings.themeAccent;
  };

  # GTK тема (без iconTheme — им управляет catppuccin)
  gtk = {
    enable = true;
    theme = {
      name    = "Adwaita-dark";
      package = pkgs.adw-gtk3;
    };
    cursorTheme = {
      name    = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size    = 24;
    };
  };

  # Курсор для Wayland
  home.pointerCursor = {
    name    = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size    = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}