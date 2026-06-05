# =============================================================================
# system/variables.nix — Переменные окружения
# =============================================================================
# Готовы для Wayland/Hyprland — не мешают работе в чистой консоли.
# Эти переменные будут нужны когда добавишь DE/WM поверх базовой системы.
# =============================================================================
{ ... }:
{
  environment.sessionVariables = {
    NIXOS_OZONE_WL              = "1";   # Electron-приложения через Wayland
    MOZ_ENABLE_WAYLAND          = "1";   # Firefox нативный Wayland
    SDL_VIDEODRIVER             = "wayland";
    QT_QPA_PLATFORM             = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP         = "Hyprland";
    XDG_SESSION_TYPE            = "wayland";
    XDG_SESSION_DESKTOP         = "Hyprland";
    TERMINAL                    = "kitty"; # поменяй под свой терминал
  };
}
