{ inputs }:

# =============================================================================
# lib/mkHost.nix — Фабрика хоста (v0.2.0)
# =============================================================================
# Принимает имя папки в hosts/, возвращает nixosSystem.
#
# Что нового в v0.2.0:
#   1. Автодискавер модулей в безопасных папках (modules/system на корне,
#      services/, ui/). Hardware/profiles/disko остаются switch-based — там
#      выбор один из вариантов, не «все сразу».
#   2. Поддержка custom/<host>/ папки в дополнение к custom/<host>.nix
#      (back-compat: если есть файл — используется он, иначе папка).
#   3. Доступ к inputs.self из любого модуля через specialArgs.inputs.
# =============================================================================

{ name }:

let
  inherit (inputs) nixpkgs home-manager disko catppuccin;
  lib = nixpkgs.lib;

  hostPath = ../hosts + "/${name}";
  settings = import (hostPath + "/settings.nix");

  # ── Кастомизации: файл или папка ─────────────────────────────────────────
  customFile = ../custom + "/${name}.nix";
  customDir  = ../custom + "/${name}";
  customModule =
    if      builtins.pathExists customFile                  then [ (import customFile) ]
    else if builtins.pathExists (customDir + "/default.nix") then [ (import (customDir + "/default.nix")) ]
    else                                                         [];

  # ── Conditional modules: выбор по settings ───────────────────────────────
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

  # ── Автодискавер модулей ──────────────────────────────────────────────────
  # Берём все *.nix файлы из указанных путей (на одном уровне, без рекурсии
  # в подпапки — потому что hardware/profiles/ это conditional choice, их
  # автоматом включать нельзя).
  # Файлы начинающиеся с _ игнорируются (зарезервировано для шаблонов).
  collectNixFiles = path:
    let entries = builtins.readDir path;
    in lib.pipe entries [
      (lib.filterAttrs (n: t:
        t == "regular"
        && lib.hasSuffix ".nix" n
        && !lib.hasPrefix "_" n))
      (lib.mapAttrsToList (n: _: path + "/${n}"))
    ];

  autoDiscoverPaths = [
    ../modules/system           # boot, network, locale, users, base, nix, variables, power-profiles, bootstrap
    ../modules/system/services  # printing, bluetooth
    ../modules/system/ui        # audio, fonts, session
  ];

  autoModules = lib.concatMap collectNixFiles autoDiscoverPaths;
in
nixpkgs.lib.nixosSystem {
  system      = "x86_64-linux";
  specialArgs = { inherit inputs settings; hostName = name; };

  modules = [
    # ── Разметка диска ──────────────────────────────────────────────────
    disko.nixosModules.disko
    diskoModule

    # ── Catppuccin (системный уровень — консоль, plymouth и т.д.) ───────
    catppuccin.nixosModules.catppuccin

    # ── Железо конкретной машины ────────────────────────────────────────
    (hostPath + "/hardware.nix")

    # ── Conditional choice modules ──────────────────────────────────────
    cpuModule
    gpuModule
    profileModule

    # ── Home Manager ────────────────────────────────────────────────────
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs    = true;
      home-manager.useUserPackages  = true;
      home-manager.extraSpecialArgs = { inherit inputs settings; };
      home-manager.sharedModules    = [ catppuccin.homeModules.catppuccin ];
      home-manager.users.${settings.username} = import ../modules/user/home.nix;
    }
  ]
  ++ autoModules         # boot/network/locale/users/base/nix/variables/power-profiles/bootstrap + services/* + ui/*
  ++ customModule;       # custom/<host>.nix или custom/<host>/default.nix
}
