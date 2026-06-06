# =============================================================================
# lib/catppuccin-colors.nix — Палитра Catppuccin для CSS/conf шаблонов
# =============================================================================
# Используется через pkgs.substituteAll для генерации theme-aware
# конфигов (waybar/wofi/hyprlock) из *.in шаблонов.
#
# Использование:
#   let
#     palette = import ../../lib/catppuccin-colors.nix;
#     flavor  = if settings.theme == "light" then "latte" else "mocha";
#     c       = palette.${flavor};
#     accent  = settings.themeAccent;
#   in
#     pkgs.substituteAll {
#       src        = ./style.css.in;
#       base       = c.hex.base;
#       base_rgb   = c.rgb.base;
#       accent     = c.hex.${accent};
#       accent_rgb = c.rgb.${accent};
#       text       = c.hex.text;
#       text_rgb   = c.rgb.text;
#       ...
#     };
#
# В шаблоне placeholder: `@base@`, `@base_rgb@`, `@accent@` и т.д.
#
# Все 14 акцентов имеют формы hex и rgb для возможности взять любой
# через c.hex.${themeAccent} / c.rgb.${themeAccent}.
#
# Источник цветов — официальная палитра catppuccin/palette.
# =============================================================================
{
  mocha = {
    hex = {
      base       = "1e1e2e";  mantle    = "181825";  crust     = "11111b";
      text       = "cdd6f4";  subtext0  = "a6adc8";  subtext1  = "bac2de";
      surface0   = "313244";  surface1  = "45475a";  surface2  = "585b70";
      overlay0   = "6c7086";  overlay1  = "7f849c";  overlay2  = "9399b2";
      # 14 акцентов
      rosewater  = "f5e0dc";  flamingo  = "f2cdcd";  pink      = "f5c2e7";
      mauve      = "cba6f7";  red       = "f38ba8";  maroon    = "eba0ac";
      peach      = "fab387";  yellow    = "f9e2af";  green     = "a6e3a1";
      teal       = "94e2d5";  sky       = "89dceb";  sapphire  = "74c7ec";
      blue       = "89b4fa";  lavender  = "b4befe";
    };
    rgb = {
      base       = "30, 30, 46";     mantle    = "24, 24, 37";     crust     = "17, 17, 27";
      text       = "205, 214, 244";  subtext0  = "166, 173, 200";  subtext1  = "186, 194, 222";
      surface0   = "49, 50, 68";     surface1  = "69, 71, 90";     surface2  = "88, 91, 112";
      overlay0   = "108, 112, 134";  overlay1  = "127, 132, 156";  overlay2  = "147, 153, 178";
      # 14 акцентов
      rosewater  = "245, 224, 220";  flamingo  = "242, 205, 205";  pink      = "245, 194, 231";
      mauve      = "203, 166, 247";  red       = "243, 139, 168";  maroon    = "235, 160, 172";
      peach      = "250, 179, 135";  yellow    = "249, 226, 175";  green     = "166, 227, 161";
      teal       = "148, 226, 213";  sky       = "137, 220, 235";  sapphire  = "116, 199, 236";
      blue       = "137, 180, 250";  lavender  = "180, 190, 254";
    };
  };

  latte = {
    hex = {
      base       = "eff1f5";  mantle    = "e6e9ef";  crust     = "dce0e8";
      text       = "4c4f69";  subtext0  = "6c6f85";  subtext1  = "5c5f77";
      surface0   = "ccd0da";  surface1  = "bcc0cc";  surface2  = "acb0be";
      overlay0   = "9ca0b0";  overlay1  = "8c8fa1";  overlay2  = "7c7f93";
      # 14 акцентов
      rosewater  = "dc8a78";  flamingo  = "dd7878";  pink      = "ea76cb";
      mauve      = "8839ef";  red       = "d20f39";  maroon    = "e64553";
      peach      = "fe640b";  yellow    = "df8e1d";  green     = "40a02b";
      teal       = "179299";  sky       = "04a5e5";  sapphire  = "209fb5";
      blue       = "1e66f5";  lavender  = "7287fd";
    };
    rgb = {
      base       = "239, 241, 245";  mantle    = "230, 233, 239";  crust     = "220, 224, 232";
      text       = "76, 79, 105";    subtext0  = "108, 111, 133";  subtext1  = "92, 95, 119";
      surface0   = "204, 208, 218";  surface1  = "188, 192, 204";  surface2  = "172, 176, 190";
      overlay0   = "156, 160, 176";  overlay1  = "140, 143, 161";  overlay2  = "124, 127, 147";
      # 14 акцентов
      rosewater  = "220, 138, 120";  flamingo  = "221, 120, 120";  pink      = "234, 118, 203";
      mauve      = "136, 57, 239";   red       = "210, 15, 57";    maroon    = "230, 69, 83";
      peach      = "254, 100, 11";   yellow    = "223, 142, 29";   green     = "64, 160, 43";
      teal       = "23, 146, 153";   sky       = "4, 165, 229";    sapphire  = "32, 159, 181";
      blue       = "30, 102, 245";   lavender  = "114, 135, 253";
    };
  };
}
