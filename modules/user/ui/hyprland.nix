# =============================================================================
# modules/user/ui/hyprland.nix — Hyprland конфиги
# =============================================================================
# Главный hyprland.conf только подключает модули из conf/.
# Последним подключается user.conf — для пользовательских override-ов.
#
# user.conf создаётся пустым при первой установке и больше не трогается
# при обновлениях. Туда друг кладёт свои настройки.
#
# Часть файлов выбирается по settings.profile (laptop/desktop/server):
#   - hypridle.conf      — разные таймауты idle
#   - conf/profile.conf  — lid switch для ноута, заглушка для остальных
# =============================================================================
{ lib, settings, ... }:
let
  profile = settings.profile;
  hypridleSrc = ../dotfiles/hyprland + "/hypridle-${profile}.conf";
  profileSrc  = ../dotfiles/hyprland/conf + "/profile-${profile}.conf";
in
{
  # Главный конфиг — иммутабельный, обновляется через git pull upstream
  xdg.configFile."hypr/hyprland.conf".source = ../dotfiles/hyprland/hyprland.conf;

  # Модули конфигурации — все иммутабельные
  xdg.configFile."hypr/conf/monitors.conf".source     = ../dotfiles/hyprland/conf/monitors.conf;
  xdg.configFile."hypr/conf/env.conf".source          = ../dotfiles/hyprland/conf/env.conf;
  xdg.configFile."hypr/conf/autostart.conf".source    = ../dotfiles/hyprland/conf/autostart.conf;
  xdg.configFile."hypr/conf/input.conf".source        = ../dotfiles/hyprland/conf/input.conf;
  xdg.configFile."hypr/conf/general.conf".source      = ../dotfiles/hyprland/conf/general.conf;
  xdg.configFile."hypr/conf/decoration.conf".source   = ../dotfiles/hyprland/conf/decoration.conf;
  xdg.configFile."hypr/conf/animations.conf".source   = ../dotfiles/hyprland/conf/animations.conf;
  xdg.configFile."hypr/conf/misc.conf".source         = ../dotfiles/hyprland/conf/misc.conf;
  xdg.configFile."hypr/conf/binds.conf".source        = ../dotfiles/hyprland/conf/binds.conf;
  xdg.configFile."hypr/conf/windowrules.conf".source  = ../dotfiles/hyprland/conf/windowrules.conf;

  # Профильный конфиг — выбирается по settings.profile
  xdg.configFile."hypr/conf/profile.conf".source = profileSrc;

  # Сопутствующие конфиги Hyprland
  xdg.configFile."hypr/hyprpaper.conf".source = ../dotfiles/hyprland/hyprpaper.conf;
  xdg.configFile."hypr/hyprlock.conf".source  = ../dotfiles/hyprland/hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source  = hypridleSrc;

  # ── user.conf: создаётся один раз при первой установке ────────────────────
  # Файл становится обычным mutable файлом — пользователь редактирует свободно,
  # обновления через git pull его не трогают.
  home.activation.hyprlandUserConf =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.config/hypr/user.conf" ]; then
        mkdir -p "$HOME/.config/hypr"
        cat ${../dotfiles/hyprland/user.conf.template} > "$HOME/.config/hypr/user.conf"
        chmod u+w "$HOME/.config/hypr/user.conf"
      fi
    '';
}
