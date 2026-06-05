{ pkgs, settings, ... }:
{
  home.packages = with pkgs; [
    lazygit # git TUI: коммиты, diff, ветки без запоминания команд
  ];

  programs.git = {
    enable    = true;
    userName  = settings.gitName;
    userEmail = settings.gitEmail;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = false;
    };
  };

  # direnv автоматически активирует nix-окружение при входе в папку с flake.nix
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable               = true;
    enableFishIntegration = true;
  };
}
