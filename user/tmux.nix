{ ... }:
{
  programs.tmux = {
    enable     = true;
    mouse      = true;
    baseIndex  = 1;      # нумерация окон с 1
    escapeTime = 0;      # без задержки Escape (важно для helix)
    keyMode    = "vi";
    shortcut   = "a";    # prefix: Ctrl+a вместо Ctrl+b
  };
}