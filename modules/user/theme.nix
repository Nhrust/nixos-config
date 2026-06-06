# =============================================================================
# modules/user/theme.nix — Catppuccin тема + единое покрытие GTK и Qt
# =============================================================================
# Принцип:
#   - GTK тема, иконки, курсор, и весь app-уровень (kitty, bat, fish, helix,
#     wofi, waybar, mako, hyprlock, etc) → ставятся catppuccin.autoEnable.
#     Здесь дополнительные пакеты НЕ нужны — autoEnable сам разруливает.
#   - Qt приложения (Telegram, OBS, qBittorrent, Dolphin, ...) catppuccin
#     home-manager НЕ покрывает. Делаем явно через Kvantum:
#       1. qt.platformTheme + qt.style → активируем движок Kvantum
#       2. catppuccin-kvantum пакет → даёт SVG/kvconfig темы
#       3. xdg.configFile → симлинк темы в ~/.config/Kvantum/ + указание
#          активной темы в kvantum.kvconfig
# =============================================================================
{ settings, pkgs, lib, ... }:
let
  flavor = if settings.theme == "light" then "latte" else "mocha";
  isDark = settings.theme != "light";

  # catppuccin-kvantum override принимает Capitalized значения.
  # "mocha" → "Mocha", "mauve" → "Mauve".
  flavorCap = if flavor == "latte" then "Latte" else "Mocha";
  accentCap =
    (lib.toUpper (builtins.substring 0 1 settings.themeAccent))
    + (builtins.substring 1 (-1) settings.themeAccent);

  kvantumTheme  = pkgs.catppuccin-kvantum.override {
    accent  = accentCap;
    variant = flavorCap;
  };
  kvantumFolder = "Catppuccin-${flavorCap}-${accentCap}";
in
{
  # ── Catppuccin core ──────────────────────────────────────────────────────
  # autoEnable сам ставит:
  #   - gtk.theme, gtk.iconTheme, home.pointerCursor (всё catppuccin-flavour'ом)
  #   - app-темы для kitty, bat, fish, helix, wofi, waybar, mako, hyprlock,
  #     hyprland borders, lazygit, btop, и прочих поддерживаемых программ.
  # Дублировать gtk.theme.package / pkgs.adw-gtk3 / pkgs.bibata-cursors здесь
  # НЕ нужно — autoEnable конфликтует с явными переопределениями.
  catppuccin = {
    enable     = true;
    autoEnable = true;
    inherit flavor;
    accent     = settings.themeAccent;
  };

  # ── GTK — только prefer-dark флаг ────────────────────────────────────────
  # Сама тема и иконки приходят от catppuccin.autoEnable. Здесь только
  # подсказка GTK4/libadwaita приложениям что хотим тёмный/светлый вариант.
  gtk = {
    enable                                             = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = isDark;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = isDark;
  };

  # ── Qt: Kvantum как platform theme + style ───────────────────────────────
  # platformTheme.name = "kvantum" → Qt-приложения подгружают тему через
  # Kvantum-движок (вместо дефолтного Fusion / системной Adwaita).
  # style.name = "kvantum" → виджеты тоже рендерятся через Kvantum.
  # home-manager сам подтянет нужные пакеты (kvantum, qtstyleplugin-kvantum).
  qt = {
    enable             = true;
    platformTheme.name = "kvantum";
    style.name         = "kvantum";
  };

  # ── Kvantum: указание активной темы ──────────────────────────────────────
  # 1. Симлинк папки темы из /nix/store в ~/.config/Kvantum/
  # 2. kvantum.kvconfig говорит движку какую тему использовать
  xdg.configFile = {
    "Kvantum/${kvantumFolder}".source =
      "${kvantumTheme}/share/Kvantum/${kvantumFolder}";

    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=${kvantumFolder}
    '';
  };
}
