# =============================================================================
# modules/user/hyprland.nix — Конфиг Hyprland (на стороне пользователя)
# =============================================================================
{ ... }:
{
  # Конфиг Hyprland хранится в dotfiles, подключаем через xdg.configFile.
  # Использовать source = ... позволяет редактировать .conf без пересборки HM
  # для быстрой итерации (после правки — Super+R перезагружает Hyprland).
  xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hyprland/hyprland.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./dotfiles/hyprland/hyprpaper.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./dotfiles/hyprland/hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source = ./dotfiles/hyprland/hypridle.conf;
}
