# =============================================================================
# modules/user/shell/fish.nix — Fish shell + алиасы
# =============================================================================
{ settings, ... }:
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

  # Интеграция zoxide с fish (умный cd)
  programs.zoxide = {
    enable           = true;
    enableFishIntegration = true;
  };
}
