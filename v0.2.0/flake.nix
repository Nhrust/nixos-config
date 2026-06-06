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
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};

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
      # ── Конфиги машин ────────────────────────────────────────────────────
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames
        (name: mkHost { inherit name; });

      # ── Форматтер (`nix fmt .`) ───────────────────────────────────────────
      # Официальный новый форматтер на основе RFC 166.
      # Прогоняется по всему .nix коду — единое форматирование без споров.
      formatter.${system} = pkgs.nixfmt-rfc-style;

      # ── Dev shell (`nix develop`) ─────────────────────────────────────────
      # Окружение для работы НАД репо: линтеры, форматтер, утилиты Nix.
      # Не требуется для использования конфига — только для тех кто разрабатывает.
      devShells.${system}.default = pkgs.mkShell {
        name = "nixos-config-dev";

        packages = with pkgs; [
          # Форматирование
          nixfmt-rfc-style

          # Линтеры
          deadnix    # ищет неиспользуемый код
          statix     # antipatterns в Nix-коде

          # LSP для редакторов
          nil

          # Навигация и анализ
          nix-tree   # визуализация зависимостей derivation
          nix-output-monitor  # nom — красивый прогресс билдов

          # GitHub CLI (для тех кто работает через gh)
          gh

          # Hyprland утилиты для отладки
          hyprland
        ];

        shellHook = ''
          echo "═══════════════════════════════════════════════════════════════"
          echo "  nixos-config dev shell"
          echo "═══════════════════════════════════════════════════════════════"
          echo "  nix fmt            форматировать все .nix файлы"
          echo "  deadnix            найти неиспользуемый Nix-код"
          echo "  statix check       проверить на antipatterns"
          echo "  nix flake check    валидация флейка"
          echo "  nom build ...      сборка с красивым прогрессом"
          echo "═══════════════════════════════════════════════════════════════"
        '';
      };
    };
}
