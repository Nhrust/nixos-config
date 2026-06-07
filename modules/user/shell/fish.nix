# =============================================================================
# modules/user/shell/fish.nix — Fish shell + алиасы + личный override-слой
# =============================================================================
{ lib, settings, inputs, hostName, ... }:
let
  # ── Опциональный декларативный local.fish (v0.3.0+) ─────────────────────
  # Если в hosts/<hostName>/dotfiles/fish-local.fish лежит файл — управляем
  # ~/.config/fish/conf.d/local.fish декларативно через home-manager.
  # Иначе fallback на mutable активацию из template.
  customLocalFish    = inputs.self + "/hosts/${hostName}/dotfiles/fish-local.fish";
  hasCustomLocalFish = builtins.pathExists customLocalFish;
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
      fastfetch
    '';

    shellAliases = {
      # ── Замены стандартных команд ───────────────────────────────────────
      cat   = "bat";
      ls    = "eza --icons";
      ll    = "eza -la --icons";
      tree  = "eza --tree --icons";
      find  = "fd";
      grep  = "rg";
      cd    = "z";
      ".."  = "cd ..";
      "..." = "cd ../..";

      # ── NixOS — через path: чтобы избегать ловушки git-rev ──────────────
      # path: говорит Nix читать файлы с диска, а не из последнего коммита.
      # Поэтому правки в hosts/<host>/ или его файлы применяются
      # сразу через `nrs`, без обязательного git commit.
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config/#$(hostname)";
      nrd = "sudo nixos-rebuild dry-build --flake ~/nixos-config/#$(hostname)";
      nrb = "sudo nixos-rebuild boot   --flake ~/nixos-config/#$(hostname)";
      nfu = "sudo nix flake update ~/nixos-config";
      ncg = "sudo nix-collect-garbage -d";
      nso = "sudo nix store optimise";
      nrl = "sudo nixos-rebuild switch --rollback";

      # ── Git ─────────────────────────────────────────────────────────────
      g   = "git";
      gs  = "git status";
      gph = "git push";
      gpl = "git pull";
      gl  = "git log --oneline";
      gcl = "git clone";

      # ── TUI инструменты ─────────────────────────────────────────────────
      lg  = "lazygit";
    };
  };

  # ── v0.3.0+: декларативный local.fish из hosts/<host>/dotfiles/ ──────────
  # Когда файла нет — опция остаётся unset, mutable активация ниже сработает.
  xdg.configFile."fish/conf.d/local.fish" = lib.mkIf hasCustomLocalFish {
    source = customLocalFish;
  };

  # ── local.fish mutable fallback ───────────────────────────────────────────
  # Активируется ТОЛЬКО когда нет hosts/<host>/dotfiles/fish-local.fish.
  # Создаётся один раз из template, дальше юзер правит руками в $HOME.
  home.activation.fishLocalConf = lib.mkIf (!hasCustomLocalFish)
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.config/fish/conf.d/local.fish" ]; then
        mkdir -p "$HOME/.config/fish/conf.d"
        cat ${../dotfiles/fish/local.fish.template} > "$HOME/.config/fish/conf.d/local.fish"
        chmod u+w "$HOME/.config/fish/conf.d/local.fish"
      fi
    '');

  # Интеграция zoxide с fish (умный cd → команда z)
  programs.zoxide = {
    enable                = true;
    enableFishIntegration = true;
  };

  # Интеграция fzf с fish (Ctrl+R история, Ctrl+T файлы, Alt+C cd)
  programs.fzf = {
    enable                = true;
    enableFishIntegration = true;
  };
}
