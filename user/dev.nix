{ pkgs, settings, ... }:
{
  home.packages = with pkgs; [ lazygit ];

  programs.git = {
    enable    = true;
    userName  = settings.gitName;
    userEmail = settings.gitEmail;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = false;
    };
  };

  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable               = true;
    enableFishIntegration = true;
  };
}