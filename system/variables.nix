# Переменные окружения для Wayland/Hyprland
# Не влияют на чистую консоль — нужны когда будет DE/WM
{ ... }:
{
  environment.sessionVariables = {
    NIXOS_OZONE_WL              = "1";
    MOZ_ENABLE_WAYLAND          = "1";
    SDL_VIDEODRIVER             = "wayland";
    QT_QPA_PLATFORM             = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP         = "Hyprland";
    XDG_SESSION_TYPE            = "wayland";
    XDG_SESSION_DESKTOP         = "Hyprland";
    TERMINAL                    = "kitty";
  };
}