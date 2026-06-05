# =============================================================================
# modules/user/ui/kitty.nix — Терминал
# =============================================================================
{ ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    settings = {
      # Внешний вид
      window_padding_width   = 8;
      hide_window_decorations = "yes";  # без рамок — Hyprland сам обрамляет
      confirm_os_window_close = 0;

      # Поведение
      cursor_shape           = "beam";
      enable_audio_bell      = false;
      mouse_hide_wait        = 1;

      # Производительность
      repaint_delay          = 10;
      input_delay            = 3;
      sync_to_monitor        = "yes";
    };

    # Тема применяется через catppuccin-nix автоматически
  };
}
