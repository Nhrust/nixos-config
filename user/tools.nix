{ pkgs, ... }:
{
  home.packages = with pkgs; [
    eza zoxide yazi fd
    bat ripgrep fzf
    btop duf dust
    nmap
    helix
    fastfetch
  ];
}