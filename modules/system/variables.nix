# =============================================================================
# modules/system/variables.nix — Переменные окружения
# =============================================================================
# Настроены для нативной работы Wayland/Hyprland.
# =============================================================================
{ ... }:
{
  environment.sessionVariables = {
    # Wayland для всех типов приложений
    NIXOS_OZONE_WL                      = "1";          # Electron (Chrome, VSCode, Discord)
    MOZ_ENABLE_WAYLAND                  = "1";          # Firefox
    SDL_VIDEODRIVER                     = "wayland";    # SDL2 игры и приложения
    QT_QPA_PLATFORM                     = "wayland;xcb"; # Qt с fallback на X11
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";          # без двойных рамок
    CLUTTER_BACKEND                     = "wayland";    # GTK-based

    # Qt theming (для Kvantum, см. modules/user/theme.nix)
    # Дублируем на системном уровне чтобы exec-once-приложения из Hyprland
    # (запускающиеся ДО полной home-manager сессии) тоже видели эти переменные.
    QT_QPA_PLATFORMTHEME = "kvantum";
    QT_STYLE_OVERRIDE    = "kvantum";  # для приложений игнорирующих PLATFORMTHEME

    # XDG (Hyprland задаёт это и сам, но дублируем для надёжности)
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE    = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # Терминал по умолчанию для xdg-open и подобных
    TERMINAL = "kitty";
  };
}
