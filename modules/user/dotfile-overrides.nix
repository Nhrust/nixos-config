# =============================================================================
# modules/user/dotfile-overrides.nix — Generic dotfile override (v0.5.0+)
# =============================================================================
# Сканирует hosts/<hostName>/dotfiles/ и для каждого найденного файла
# применяет его как override соответствующего upstream-dotfile в ~/.config/.
#
# Карта `fileMap` ниже задаёт соответствие:
#   <имя_файла_в_dotfiles>  →  <путь_в_~/.config/>
#
# Юзер кладёт любой из этих файлов в hosts/<host>/dotfiles/ — и тот
# автоматически становится override'ом. Не нужно править никакие .nix модули.
#
# Пример: положил hosts/my-laptop/dotfiles/waybar-config.jsonc →
#         ~/.config/waybar/config.jsonc симлинкается на него через lib.mkForce
#         (перекрывает upstream-версию из modules/user/dotfiles/waybar/).
#
# Этот модуль работает в паре с hyprland.nix/fish.nix которые отдельно
# обрабатывают hypr-user.conf и fish-local.fish (потому что у них особая
# логика mutable fallback). Остальные файлы — обрабатываются здесь.
# =============================================================================
{ lib, inputs, hostName, ... }:
let
  hostDotfilesDir = inputs.self + "/hosts/${hostName}/dotfiles";

  # Карта: имя файла в hostDir → путь в ~/.config/
  # Расширяемая — если в modules/user/dotfiles/ появляется новый конфиг,
  # достаточно добавить строку сюда.
  fileMap = {
    # Waybar — статус-бар
    "waybar-config.jsonc" = "waybar/config.jsonc";
    "waybar-style.css"    = "waybar/style.css";

    # Wofi — лаунчер
    "wofi-config"         = "wofi/config";
    "wofi-style.css"      = "wofi/style.css";

    # Kitty — терминал
    "kitty.conf"          = "kitty/kitty.conf";

    # Mako — уведомления
    "mako.config"         = "mako/config";

    # Hyprland sub-конфиги (полный override blocks которые не покрывает user.conf)
    "hypr-monitors.conf"  = "hypr/conf/monitors.conf";
    "hypr-binds.conf"     = "hypr/conf/binds.conf";
    "hypr-decoration.conf" = "hypr/conf/decoration.conf";
    "hypr-animations.conf" = "hypr/conf/animations.conf";
    "hypr-windowrules.conf" = "hypr/conf/windowrules.conf";

    # NB: hypr-user.conf и fish-local.fish — обрабатываются отдельно в
    # hyprland.nix и fish.nix соответственно (у них особая логика с mutable
    # fallback на ~/.config/hypr/user.conf и conf.d/local.fish).
  };

  # Список файлов которые реально лежат в hosts/<host>/dotfiles/
  presentFiles = lib.filter
    (filename: builtins.pathExists (hostDotfilesDir + "/${filename}"))
    (builtins.attrNames fileMap);

  # Сборка атрибутов xdg.configFile.<target>.source
  overrideAttrs = lib.listToAttrs (map
    (filename: lib.nameValuePair
      fileMap.${filename}
      { source = lib.mkForce (hostDotfilesDir + "/${filename}"); })
    presentFiles);

in {
  xdg.configFile = overrideAttrs;
}
