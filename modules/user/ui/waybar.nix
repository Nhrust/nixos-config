# =============================================================================
# modules/user/ui/waybar.nix — Статус-бар + системные апплеты для трея
# =============================================================================
# style.css генерируется из style.css.in через pkgs.replaceVars
# с подстановкой Catppuccin палитры по settings.theme (v0.4.0+).
# Базовые цвета модулей подключает catppuccin.autoEnable; здесь — только
# фон карманов и powerprofile-индикатор.
# =============================================================================
{ pkgs, settings, ... }:
let
  palette = import ../../../lib/catppuccin-colors.nix;
  flavor  = if settings.theme == "light" then "latte" else "mocha";
  c       = palette.${flavor};

  styleCSS = pkgs.replaceVars ../dotfiles/waybar/style.css.in {
    base_rgb = c.rgb.base;
    inherit (c.hex) peach lavender green;
  };
in {
  programs.waybar.enable = true;

  # Стиль и конфиг — через xdg.configFile (style как сгенерированный derivation,
  # config.jsonc как статический файл)
  xdg.configFile = {
    "waybar/style.css".source   = styleCSS;
    "waybar/config.jsonc".source = ../dotfiles/waybar/config.jsonc;
  };

  # GUI-апплеты для системного трея waybar.
  # nm-applet — иконка NetworkManager в трее, открывает GUI настройщик по ПКМ.
  home.packages = with pkgs; [
    networkmanagerapplet
  ];

  services.network-manager-applet.enable = true;
}
