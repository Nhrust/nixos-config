# =============================================================================
# modules/user/shell/fish.nix — Fish shell + алиасы + личный override-слой
# =============================================================================
{ lib, settings, ... }:
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

      # ── NixOS — используют $(hostname) для универсальности ──────────────
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config/#$(hostname)";
      nrb = "sudo nixos-rebuild boot   --flake ~/nixos-config/#$(hostname)";
      nfu = "nix flake update ~/nixos-config";
      ngc = "nix-collect-garbage -d";
      nrl = "sudo nixos-rebuild switch --rollback";

      # ── Git ─────────────────────────────────────────────────────────────
      g   = "git";
      gs  = "git status";
      gp  = "git push";
      gl  = "git log --oneline";
      gcl = "git clone";
    };
  };

  # ── Личный override-слой ──────────────────────────────────────────────────
  # ~/.config/fish/conf.d/local.fish создаётся при первой установке как
  # пустой template и больше не перезаписывается обновлениями.
  # Юзер кладёт туда свои alias / abbr / функции / переменные.
  # Fish автоматически источит все .fish файлы из conf.d/.
  home.activation.fishLocalConf =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.config/fish/conf.d/local.fish" ]; then
        mkdir -p "$HOME/.config/fish/conf.d"
        cat ${../dotfiles/fish/local.fish.template} > "$HOME/.config/fish/conf.d/local.fish"
        chmod u+w "$HOME/.config/fish/conf.d/local.fish"
      fi
    '';

  # Интеграция zoxide с fish (умный cd)
  programs.zoxide = {
    enable                = true;
    enableFishIntegration = true;
  };
}
