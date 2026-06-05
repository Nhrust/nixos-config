{
  description = "first console os by geysex";

  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-unstable";
    home-manager     = {
      url             = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url             = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }@inputs:
    let
      s = import ./settings.nix;

      cpuModule = {
        "amd"   = ./system/hardware/cpu-amd.nix;
        "intel" = ./system/hardware/cpu-intel.nix;
      }.${s.cpu} or (throw "settings.nix: неизвестный cpu «${s.cpu}»");

      gpuModule = {
        "amd"    = ./system/hardware/gpu-amd.nix;
        "intel"  = ./system/hardware/gpu-intel.nix;
        "nvidia" = ./system/hardware/gpu-nvidia.nix;
      }.${s.gpu} or (throw "settings.nix: неизвестный gpu «${s.gpu}»");

      profileModule = {
        "laptop"  = ./system/profiles/laptop.nix;
        "desktop" = ./system/profiles/desktop.nix;
        "server"  = ./system/profiles/server.nix;
      }.${s.profile} or (throw "settings.nix: неизвестный profile «${s.profile}»");

      # Выбор схемы разметки диска
      diskoModule = {
        "wipe"     = ./disko/btrfs.nix;
        "existing" = ./disko/btrfs-existing.nix;
      }.${s.diskMode} or (throw "settings.nix: diskMode должен быть «wipe» или «existing»");

    in {
      nixosConfigurations.${s.hostname} = nixpkgs.lib.nixosSystem {
        system      = "x86_64-linux";
        specialArgs = { inherit inputs; settings = s; };

        modules = [
          disko.nixosModules.disko
          diskoModule
          ./system/hardware.nix
          ./system/main.nix
          ./system/variables.nix
          cpuModule
          gpuModule
          profileModule

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs    = true;
            home-manager.useUserPackages  = true;
            home-manager.extraSpecialArgs = { settings = s; };
            home-manager.users.${s.username} = import ./user/home.nix;
          }
        ];
      };
    };
}