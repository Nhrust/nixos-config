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
# input.conf генерируется из input.conf.in через pkgs.replaceVars — подставляется
# settings.kbLayouts (новое в v0.2.0).
#
# Скрипты в scripts/ копируются как исполняемые.
# Плагины: pyprland (scratchpads + smart_gaps, опционально через settings.hyprland.pyprland).
# =============================================================================
{ lib, pkgs, settings, inputs, hostName, ... }:
let
  profile     = settings.profile;
  profileSrc  = ../dotfiles/hyprland/conf/profile + "/${profile}.conf";

  # hypridle нужен только на laptop/desktop. На server файл не копируется,
  # а демон не запускается из conf/profile/server.conf.
  needsHypridle = profile != "server";
  hypridleSrc   = ../dotfiles/hyprland/idle + "/${profile}.conf";

  # pyprland — опциональный (default true). scratchpad биндинги Super+grave
  # и Super+Shift+N работают только при включённом pyprland.
  pyprlandEnabled = (settings.hyprland.pyprland or null) != false;

  # Обои выбираются по теме
  wallpaperSrc = ../dotfiles/hyprland/wallpapers + "/default-${settings.theme}.png";

  # input.conf генерируется из шаблона. settings.kbLayouts по умолчанию "us,ru".
  # Друзья с другим вторым языком переопределяют в своём settings.nix
  # (например "us,de" или просто "us").
  kbLayouts = settings.kbLayouts or "us,ru";
  inputConf = pkgs.replaceVars ../dotfiles/hyprland/conf/input.conf.in {
    kbLayout = kbLayouts;
  };

  # ── hyprlock.conf генерируется из шаблона (v0.4.0+) ─────────────────────
  # Подставляются Catppuccin цвета по settings.theme и settings.themeAccent.
  # Поддерживает обе темы (Mocha/Latte) и все 14 акцентов.
  catppuccinPalette = import ../../../lib/catppuccin-colors.nix;
  flavor            = if settings.theme == "light" then "latte" else "mocha";
  c                 = catppuccinPalette.${flavor};
  hyprlockConf      = pkgs.replaceVars ../dotfiles/hyprland/hyprlock.conf.in {
    base_rgb   = c.rgb.base;
    text_rgb   = c.rgb.text;
    accent_rgb = c.rgb.${settings.themeAccent};
  };

  # ── Опциональный декларативный user.conf (v0.3.0+) ─────────────────────
  # Если в hosts/<hostName>/dotfiles/hypr-user.conf лежит файл — управляем
  # ~/.config/hypr/user.conf декларативно через home-manager (read-only симлинк
  # из /nix/store). Иначе — fallback на mutable активацию (создаётся один раз
  # из template, дальше юзер правит руками в $HOME).
  customUserConf    = inputs.self + "/hosts/${hostName}/dotfiles/hypr-user.conf";
  hasCustomUserConf = builtins.pathExists customUserConf;
in
{
  # ── Плагины Hyprland-стека ────────────────────────────────────────────────
  home.packages = with pkgs;
    # pyprland (scratchpads + smart_gaps) — опционально через settings.
    # Default = true для back-compat. Если выключишь — биндинги Super+grave
    # (scratchpad term) и Super+Shift+N (scratchpad notes) перестанут работать.
    lib.optionals pyprlandEnabled [
      pyprland     # Python-плагины, запускается через `pypr`
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
    "hypr/hyprlock.conf".source  = hyprlockConf;


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
  } // (lib.optionalAttrs pyprlandEnabled {
    # pyprland.toml — копируется только если pyprland включён
    "hypr/pyprland.toml".source = ../dotfiles/hyprland/pyprland.toml;
  }) // (lib.optionalAttrs needsHypridle {
    # hypridle конфиг только для laptop/desktop
    "hypr/hypridle.conf".source = hypridleSrc;
  }) // (lib.optionalAttrs hasCustomUserConf {
    # v0.3.0+: декларативный user.conf из hosts/<host>/dotfiles/
    # Read-only симлинк из /nix/store — переносится между машинами вместе с репо.
    "hypr/user.conf".source = customUserConf;
  });

  # ── user.conf mutable fallback ────────────────────────────────────────────
  # Активируется ТОЛЬКО когда нет hosts/<host>/dotfiles/hypr-user.conf.
  # Создаётся один раз из template, дальше юзер правит руками в $HOME.
  home.activation.hyprlandUserConf = lib.mkIf (!hasCustomUserConf)
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.config/hypr/user.conf" ]; then
        mkdir -p "$HOME/.config/hypr"
        cat ${../dotfiles/hyprland/user.conf.template} > "$HOME/.config/hypr/user.conf"
        chmod u+w "$HOME/.config/hypr/user.conf"
      fi
    '');

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
