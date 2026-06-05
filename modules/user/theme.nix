# =============================================================================
# modules/user/theme.nix — Catppuccin тема + единое покрытие GTK и Qt
# =============================================================================
# catppuccin-nix через autoEnable применяет тему ко всем поддерживаемым
# программам (kitty, waybar, wofi, mako, helix, bat, fish, tmux, fastfetch,
# hyprland, hyprlock, Firefox, Kvantum для Qt и т.д.).
#
# Этот файл дополнительно настраивает:
#   - GTK тему (adw-gtk3 / adw-gtk3-dark) и иконки (Papirus)
#   - Qt тему через Kvantum + qt5ct/qt6ct
#   - Курсор (Bibata) общий для всего Wayland
#   - GUI-утилиты для тонкой подгонки тем (nwg-look, qt5ct, qt6ct)
# =============================================================================
{ settings, pkgs, ... }:
let
  flavor = if settings.theme == "light" then "latte" else "mocha";
  isDark = settings.theme != "light";

  # adw-gtk3 предоставляет две темы: "adw-gtk3" и "adw-gtk3-dark"
  # (а НЕ "Adwaita-dark" — это была главная причина "белой Thunar")
  gtkThemeName = if isDark then "adw-gtk3-dark" else "adw-gtk3";

  iconThemeName = if isDark then "Papirus-Dark" else "Papirus-Light";
in
{
  # ── Catppuccin core: применяет тему ко всем поддерживаемым программам ────
  catppuccin = {
    enable     = true;
    autoEnable = true;
    inherit flavor;
    accent     = settings.themeAccent;
  };

  # ── GTK (Thunar, gtk2/3 диалоги, GTK4 через libadwaita) ──────────────────
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

    # GTK4 / libadwaita-приложения смотрят на color-scheme через gsettings —
    # эти настройки гарантируют тёмный режим для них тоже.
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = isDark;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = isDark;
    };
  };

  # ── Qt (Qt5/Qt6 приложения через Kvantum) ────────────────────────────────
  # catppuccin-nix через autoEnable хендлит сам Kvantum-стиль
  # (catppuccin.kvantum.enable = true автоматически). Здесь говорим Qt:
  # «бери стиль у Kvantum».
  qt = {
    enable             = true;
    platformTheme.name = "kvantum";   # откуда читать настройки темы
    style.name         = "kvantum";   # какой стиль использовать
  };

  # ── Курсор для Wayland (общий для всех приложений) ───────────────────────
  home.pointerCursor = {
    name       = "Bibata-Modern-Classic";
    package    = pkgs.bibata-cursors;
    size       = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ── GUI-утилиты для тонкой настройки тем ─────────────────────────────────
  # Эти штуки полезны при отладке и подстройке вручную, но не обязательны
  # для работы темы — основная конфигурация декларативна через nix выше.
  home.packages = with pkgs; [
  libsForQt5.qt5ct
  qt6Packages.qt6ct
  libsForQt5.qtstyleplugin-kvantum
  nwg-look
  ];
}
