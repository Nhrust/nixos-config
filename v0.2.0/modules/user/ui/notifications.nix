# =============================================================================
# modules/user/ui/notifications.nix — mako (уведомления) + wlogout (logout-меню)
# =============================================================================
# Цвета Catppuccin подтягиваются автоматически через catppuccin.autoEnable —
# здесь только размеры, шрифт, таймауты и расположение.
# =============================================================================
{ pkgs, lib, ... }:
{
  # ── Mako: декларативные настройки ────────────────────────────────────────
  services.mako = {
    enable = true;
    settings = {
      anchor          = "top-right";
      width           = 320;
      height          = 110;
      border-radius   = 8;
      border-size     = 1;
      font            = "JetBrainsMono Nerd Font 11";
      default-timeout = 5000;  # 5 секунд для обычных
      margin          = "12";
      padding         = "12";
      icons           = true;
      max-icon-size   = 48;

      "urgency=critical" = {
        default-timeout = 30000;   # 30 секунд для критичных
        border-size     = 2;
      };
    };
  };

  # ── wlogout: графическое меню Lock/Logout/Reboot/Shutdown/Suspend/Hibernate
  # Вызывается через Ctrl+Alt+Delete (см. binds.conf).
  home.packages = with pkgs; [ wlogout ];

  xdg.configFile."wlogout/layout".source   = ../dotfiles/wlogout/layout;
  xdg.configFile."wlogout/style.css".source = ../dotfiles/wlogout/style.css;
}
