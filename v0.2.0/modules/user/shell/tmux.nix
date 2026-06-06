# =============================================================================
# modules/user/shell/tmux.nix — Терминальный мультиплексор
# =============================================================================
{ ... }:
{
  programs.tmux = {
    enable     = true;
    mouse      = true;
    baseIndex  = 1;     # нумерация окон с 1, удобнее
    escapeTime = 0;     # без задержки Escape — критично для helix
    keyMode    = "vi";
    shortcut   = "a";   # prefix Ctrl+a вместо Ctrl+b (Ctrl+b пересекается с emacs)
  };
}
