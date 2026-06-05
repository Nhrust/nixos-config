# =============================================================================
# modules/user/dev.nix — Инструменты разработчика
# =============================================================================
{ pkgs, settings, ... }:
{
  home.packages = with pkgs; [
    lazygit          # git TUI
  ];

  programs.git = {
    enable    = true;
    userName  = settings.gitName;
    userEmail = settings.gitEmail;

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = "hx";
    };
  };

  # direnv автоматически активирует nix-окружение при входе в папку с flake.nix
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable                = true;
    enableFishIntegration = true;
  };
}
