{
  description = "nixos-config — multi-host NixOS дистрибутив";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      # Фабрика хоста — собирает nixosSystem из hosts/<name>/
      mkHost = import ./lib/mkHost.nix { inherit inputs; };

      # Сканируем hosts/, берём все папки кроме скрытых (начинающихся с _ или .)
      hostNames = builtins.attrNames (
        nixpkgs.lib.filterAttrs
          (name: type:
            type == "directory"
            && !nixpkgs.lib.hasPrefix "_" name
            && !nixpkgs.lib.hasPrefix "." name
          )
          (builtins.readDir ./hosts)
      );
    in {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames
        (name: mkHost { inherit name; });
    };
}
