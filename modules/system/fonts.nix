# =============================================================================
# modules/system/fonts.nix — Шрифты
# =============================================================================
{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      noto-fonts                       # покрытие большинства языков
      noto-fonts-emoji                 # emoji
      noto-fonts-cjk-sans              # китайский / японский / корейский
      liberation_ttf                   # замены Arial / Times / Courier для веба
      jetbrains-mono                   # моноширинный для терминала и редактора
      nerd-fonts.jetbrains-mono        # та же гарнитура с иконками для UI
    ];

    # Дефолтные шрифты для разных категорий
    fontconfig.defaultFonts = {
      serif     = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };
}
