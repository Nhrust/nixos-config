# =============================================================================
# modules/user/ui/hyprland.nix — Hyprland конфиги + плагины
# =============================================================================
# Главный hyprland.conf подключает модули из conf/.
# Последним подключается user.conf — для пользовательских override-ов.
#
# Часть файлов выбирается по settings.profile (laptop/desktop/server):
#   - idle/<profile>.conf            → ~/.config/hypr/hypridle.conf
#   - conf/profile/<profile>.conf    → ~/.config/hypr/conf/profile.conf
#
# hypridle.conf копируется ТОЛЬКО для laptop/desktop. На server демон не нужен.
#
# input.conf генерируется из input.conf.in через substituteAll — подставляется
# settings.kbLayouts (новое в v0.2.0).
#
# Скрипты в scripts/ копируются как исполняемые.
# Плагины: pyprland (scratchpads + smart_gaps), hyprshade (blue-light).
# =============================================================================
{ lib, pkgs, settings, ... }:
let
  profile     = settings.profile;
  profileSrc  = ../dotfiles/hyprland/conf/profile + "/${profile}.conf";

  # hypridle нужен только на laptop/desktop. На server файл не копируется,
  # а демон не запускается из conf/profile/server.conf.
  needsHypridle = profile != "server";
  hypridleSrc   = ../dotfiles/hyprland/idle + "/${profile}.conf";

  # Обои выбираются по теме
  wallpaperSrc = ../dotfiles/hyprland/wallpapers + "/default-${settings.theme}.png";

  # input.conf генерируется из шаблона. settings.kbLayouts по умолчанию "us,ru".
  # Друзья с другим вторым языком переопределяют в своём settings.nix
  # (например "us,de" или просто "us").
  kbLayouts = settings.kbLayouts or "us,ru";
  inputConf = pkgs.substituteAll {
    src       = ../dotfiles/hyprland/conf/input.conf.in;
    kbLayout  = kbLayouts;
  };
in
{
  # ── Плагины Hyprland-стека ────────────────────────────────────────────────
  home.packages = with pkgs; [
    pyprland     # Python-плагины (scratchpads, smart_gaps), запускается через `pypr`
    hyprshade    # шейдеры — blue-light filter, vibrance и т.д.
  ];

  # ── Конфиги Hyprland (read-only, обновляются upstream) ────────────────────
  xdg.configFile = {
    "hypr/hyprland.conf".source = ../dotfiles/hyprland/hyprland.conf;

    # Модули
    "hypr/conf/monitors.conf".source     = ../dotfiles/hyprland/conf/monitors.conf;
    "hypr/conf/env.conf".source          = ../dotfiles/hyprland/conf/env.conf;
    "hypr/conf/autostart.conf".source    = ../dotfiles/hyprland/conf/autostart.conf;
    "hypr/conf/input.conf".source        = inputConf;   # ← v0.2.0: генерится с kbLayouts
    "hypr/conf/general.conf".source      = ../dotfiles/hyprland/conf/general.conf;
    "hypr/conf/decoration.conf".source   = ../dotfiles/hyprland/conf/decoration.conf;
    "hypr/conf/animations.conf".source   = ../dotfiles/hyprland/conf/animations.conf;
    "hypr/conf/misc.conf".source         = ../dotfiles/hyprland/conf/misc.conf;
    "hypr/conf/binds.conf".source        = ../dotfiles/hyprland/conf/binds.conf;
    "hypr/conf/windowrules.conf".source  = ../dotfiles/hyprland/conf/windowrules.conf;

    # Профильный конфиг — выбирается по settings.profile
    "hypr/conf/profile.conf".source = profileSrc;

    # Сопутствующие конфиги Hyprland
    "hypr/hyprpaper.conf".source = ../dotfiles/hyprland/hyprpaper.conf;
    "hypr/hyprlock.conf".source  = ../dotfiles/hyprland/hyprlock.conf;

    # Pyprland: scratchpads + smart_gaps
    "hypr/pyprland.toml".source  = ../dotfiles/hyprland/pyprland.toml;

    # Скрипты-обёртки (executable)
    "hypr/scripts/volume.sh" = {
      source     = ../dotfiles/hyprland/scripts/volume.sh;
      executable = true;
    };
    "hypr/scripts/wifi-menu.sh" = {
      source     = ../dotfiles/hyprland/scripts/wifi-menu.sh;
      executable = true;
    };
    "hypr/scripts/powerprofile.sh" = {
      source     = ../dotfiles/hyprland/scripts/powerprofile.sh;
      executable = true;
    };
  } // (lib.optionalAttrs needsHypridle {
    # hypridle конфиг только для laptop/desktop
    "hypr/hypridle.conf".source = hypridleSrc;
  });

  # ── user.conf: создаётся один раз при первой установке ────────────────────
  home.activation.hyprlandUserConf =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.config/hypr/user.conf" ]; then
        mkdir -p "$HOME/.config/hypr"
        cat ${../dotfiles/hyprland/user.conf.template} > "$HOME/.config/hypr/user.conf"
        chmod u+w "$HOME/.config/hypr/user.conf"
      fi
    '';

  # ── Дефолтная обоина: создаётся один раз при первой установке ─────────────
  home.activation.defaultWallpaper =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/Pictures/wallpaper.png" ]; then
        mkdir -p "$HOME/Pictures"
        cp ${wallpaperSrc} "$HOME/Pictures/wallpaper.png"
        chmod u+w "$HOME/Pictures/wallpaper.png"
      fi
    '';
}
