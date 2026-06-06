# =============================================================================
# modules/user/ui/waybar.nix — Статус-бар + системные апплеты для трея
# =============================================================================
{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    style  = builtins.readFile ../dotfiles/waybar/style.css;
  };

  xdg.configFile."waybar/config.jsonc".source = ../dotfiles/waybar/config.jsonc;

  # GUI-апплеты которые сидят в системном трее waybar.
  # nm-applet — добавляет иконку NetworkManager в трей.
  # nm-connection-editor — открывается по ПКМ на иконке сети в waybar.
  home.packages = with pkgs; [
    networkmanagerapplet
  ];

  # Сервис nm-applet — автостарт в трей (без сетевой индикации, она уже в waybar)
  services.network-manager-applet.enable = true;
}
