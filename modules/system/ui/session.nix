# =============================================================================
# modules/system/ui/session.nix — Hyprland + greetd + XDG portals
# =============================================================================
{ pkgs, ... }:
{
  # ── Hyprland (composit + WM) ──────────────────────────────────────────────
  programs.hyprland = {
    enable    = true;
    withUWSM  = true;  # universal wayland session manager — корректная сессия
    xwayland.enable = true;  # для приложений которые не умеют Wayland
  };

  # ── Greeter — tuigreet через greetd ───────────────────────────────────────
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user    = "greeter";
      };
    };
  };

  # ── XDG Desktop Portal — для скриншотов, выбора файлов, screen sharing ───
  xdg.portal = {
    enable            = true;
    wlr.enable        = true;  # screencast/screenshot для Wayland
    extraPortals      = with pkgs; [
      xdg-desktop-portal-gtk     # выбор файлов в GTK-стиле
      xdg-desktop-portal-hyprland # Hyprland-специфичный портал
    ];
  };

  # ── Thunar — файловый менеджер ────────────────────────────────────────────
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
    ];
  };

  services.gvfs.enable    = true;
  services.tumbler.enable = true;

  # ── Системные пакеты для рабочего окружения ───────────────────────────────
  environment.systemPackages = with pkgs; [
    # Hyprland экосистема
    hyprlock          # screen lock
    hypridle          # idle daemon (lock/suspend по таймауту)
    hyprpaper         # обои
    hyprpolkitagent   # polkit agent (запросы прав от GUI приложений)

    # Утилиты Wayland
    grim              # скриншот
    slurp             # выбор области для скриншота
    wl-clipboard      # буфер обмена (wl-copy / wl-paste)

    # Базовый GUI софт
    firefox
  ];
}
