{ inputs }:

# Фабрика хоста: принимает имя папки в hosts/, возвращает nixosSystem.
# Читает hosts/<name>/settings.nix, выбирает нужные модули из modules/,
# подключает hosts/<name>/hardware.nix и опционально custom/<name>.nix.

{ name }:

let
  inherit (inputs) nixpkgs home-manager disko catppuccin;

  hostPath = ../hosts + "/${name}";
  settings = import (hostPath + "/settings.nix");

  # Опциональные кастомизации пользователя
  customPath   = ../custom + "/${name}.nix";
  hasCustom    = builtins.pathExists customPath;
  customModule = if hasCustom then [ (import customPath) ] else [];

  # ── Выбор модулей на основе settings ─────────────────────────────────────
  cpuModule = {
    "amd"   = ../modules/system/hardware/cpu-amd.nix;
    "intel" = ../modules/system/hardware/cpu-intel.nix;
  }.${settings.cpu} or (throw "settings.cpu: ожидалось amd|intel, получено «${settings.cpu}»");

  gpuModule = {
    "amd"    = ../modules/system/hardware/gpu-amd.nix;
    "intel"  = ../modules/system/hardware/gpu-intel.nix;
    "nvidia" = ../modules/system/hardware/gpu-nvidia.nix;
  }.${settings.gpu} or (throw "settings.gpu: ожидалось amd|intel|nvidia, получено «${settings.gpu}»");

  profileModule = {
    "laptop"  = ../modules/system/profiles/laptop.nix;
    "desktop" = ../modules/system/profiles/desktop.nix;
    "server"  = ../modules/system/profiles/server.nix;
  }.${settings.profile} or (throw "settings.profile: ожидалось laptop|desktop|server, получено «${settings.profile}»");

  diskoModule = {
    "wipe"     = ../modules/disko/btrfs.nix;
    "existing" = ../modules/disko/btrfs-existing.nix;
  }.${settings.diskMode} or (throw "settings.diskMode: ожидалось wipe|existing, получено «${settings.diskMode}»");

in
nixpkgs.lib.nixosSystem {
  system      = "x86_64-linux";
  specialArgs = { inherit inputs settings; hostName = name; };

  modules = [
    # Разметка диска
    disko.nixosModules.disko
    diskoModule

    # Catppuccin (системный уровень — консоль, plymouth и т.д.)
    catppuccin.nixosModules.catppuccin

    # Железо конкретной машины
    (hostPath + "/hardware.nix")

    # Фундамент
    ../modules/system/main.nix
    ../modules/system/variables.nix
    ../modules/system/power-profiles.nix

    # UI: сессия, аудио, шрифты
    ../modules/system/ui/session.nix
    ../modules/system/ui/audio.nix
    ../modules/system/ui/fonts.nix

    # Опциональные сервисы (активируются через флаги в settings)
    ../modules/system/services/printing.nix
    ../modules/system/services/bluetooth.nix

    # Выбранные железо и профиль
    cpuModule
    gpuModule
    profileModule

    # Home Manager
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs    = true;
      home-manager.useUserPackages  = true;
      home-manager.extraSpecialArgs = { inherit inputs settings; };
      home-manager.sharedModules    = [ catppuccin.homeModules.catppuccin ];
      home-manager.users.${settings.username} = import ../modules/user/home.nix;
    }
  ] ++ customModule;
}
