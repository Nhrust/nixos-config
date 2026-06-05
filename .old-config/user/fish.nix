{ settings, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
      zoxide init fish | source
      fastfetch
    '';

    shellAliases = {
      # ── Замены стандартных команд ──────────────────────────────────────────
      cat   = "bat";
      ls    = "eza --icons";
      ll    = "eza -la --icons";
      tree  = "eza --tree --icons";
      find  = "fd";
      grep  = "rg";
      cd    = "z";
      ".."  = "cd ..";
      "..." = "cd ../..";

      # ── NixOS ──────────────────────────────────────────────────────────────
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config/#${settings.hostname}";
      nrb = "sudo nixos-rebuild boot   --flake ~/nixos-config/#${settings.hostname}";
      nfu = "nix flake update ~/nixos-config";
      ngc = "nix-collect-garbage -d";
      nrl = "sudo nixos-rebuild switch --rollback";

      # ── Git ────────────────────────────────────────────────────────────────
      g   = "git";
      gs  = "git status";
      gp  = "git push";
      gl  = "git log --oneline";
      gcl = "git clone";
    };
  };
}
