# =============================================================================
# modules/user/home.nix — Точка входа Home Manager
# =============================================================================
# Автодискавер модулей (v0.2.0+):
#   - все *.nix в modules/user/ верхнего уровня (theme.nix и т.д.)
#   - все *.nix в modules/user/shell/  (fish, tmux, ...)
#   - все *.nix в modules/user/tools/  (cli, dev, ...)
#   - все *.nix в modules/user/ui/     (hyprland, kitty, waybar, wofi, notifications, ...)
# Файлы начинающиеся с _ игнорируются (зарезервировано для шаблонов).
#
# Добавил новый user-модуль? Положи .nix в правильную папку — home.nix
# подхватит автоматически, ничего здесь править не надо.
# =============================================================================
{ lib, settings, ... }:
let
  collectNixFiles = path:
    let entries = builtins.readDir path;
    in lib.pipe entries [
      (lib.filterAttrs (n: t:
        t == "regular"
        && lib.hasSuffix ".nix" n
        && !lib.hasPrefix "_" n
        && n != "home.nix"))
      (lib.mapAttrsToList (n: _: path + "/${n}"))
    ];

  discoveredImports = lib.concatMap collectNixFiles [
    ./.        # theme.nix и любые другие на верхнем уровне
    ./shell    # fish, tmux, ...
    ./tools    # cli, dev, ...
    ./ui       # hyprland, kitty, waybar, wofi, notifications, ...
  ];
in
{
  home.username      = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  imports = discoveredImports;

  home.stateVersion = "26.05";
}
