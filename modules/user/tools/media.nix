# =============================================================================
# modules/user/tools/media.nix — Daily essentials (v0.5.1+)
# =============================================================================
# Утилиты которые нужны каждому desktop-юзеру с первого дня:
#   - Просмотр медиа: mpv (видео), imv (картинки), zathura (PDF)
#   - Скриншоты: hyprshot (упрощает workflow grim+slurp)
#   - Буфер обмена: cliphist (история copy/paste)
#   - Color picker: hyprpicker
#   - Запись экрана: wf-recorder
#   - Media-keys helpers: playerctl (play/pause через XF86Audio*)
#
# brightnessctl уже идёт через modules/system/profiles/laptop.nix.
# wpctl — встроен в pipewire (есть автоматически на любом профиле).
# =============================================================================
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ── Просмотрщики медиа (минималистичные, Wayland-friendly) ────────────────
    imv             # картинки — лёгкий, быстрый
    # mpv установлен через programs.mpv ниже (с конфигом)

    # ── Скриншоты и буфер обмена ──────────────────────────────────────────────
    hyprshot        # обёртка над grim+slurp с copy-to-clipboard, save-to-file
    cliphist        # история буфера (Super+V — выбор через wofi)
    hyprpicker      # color picker (eyedropper) для Hyprland

    # ── Запись экрана ─────────────────────────────────────────────────────────
    wf-recorder     # screencast в файл (более лёгкий чем OBS)

    # ── Media-keys helpers ────────────────────────────────────────────────────
    playerctl       # для XF86AudioPlay/Prev/Next (управление mpv, Spotify, etc.)
  ];

  # ── MPV — видеоплеер с разумными дефолтами ─────────────────────────────────
  programs.mpv = {
    enable = true;
    config = {
      hwdec        = "auto-safe";    # аппаратное декодирование
      vo           = "gpu-next";     # современный backend
      profile      = "high-quality"; # лучшее качество масштабирования
      osc          = false;          # минимизировать overlay (открой паузу для full controls)
      keep-open    = "yes";          # не закрывать после окончания
      save-position-on-quit = true;  # помнить позицию воспроизведения
    };
  };

  # ── Zathura — PDF viewer (vim-style биндинги) ─────────────────────────────
  programs.zathura = {
    enable = true;
    # Catppuccin home-manager модуль автоматически применит тему
    # через catppuccin.autoEnable = true.
    options = {
      selection-clipboard = "clipboard";   # выделение → системный буфер
      smooth-scroll       = true;
      window-title-basename = true;
    };
  };

  # ── XDG MIME ассоциации — открывать файлы через эти программы ─────────────
  # Когда юзер делает `xdg-open file.pdf` или кликает PDF в Thunar — Zathura.
  # JPG/PNG → imv. MP4/MKV → mpv. Без этого Linux не знает чем открыть файлы.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # PDF и документы
      "application/pdf"            = "org.pwmt.zathura.desktop";
      # Картинки — все основные форматы через imv
      "image/jpeg"                 = "imv.desktop";
      "image/jpg"                  = "imv.desktop";
      "image/png"                  = "imv.desktop";
      "image/gif"                  = "imv.desktop";
      "image/webp"                 = "imv.desktop";
      "image/bmp"                  = "imv.desktop";
      "image/tiff"                 = "imv.desktop";
      "image/svg+xml"              = "imv.desktop";
      # Видео и аудио — всё через mpv
      "video/mp4"                  = "mpv.desktop";
      "video/x-matroska"           = "mpv.desktop";
      "video/webm"                 = "mpv.desktop";
      "video/x-msvideo"            = "mpv.desktop";
      "video/quicktime"            = "mpv.desktop";
      "audio/mpeg"                 = "mpv.desktop";
      "audio/flac"                 = "mpv.desktop";
      "audio/ogg"                  = "mpv.desktop";
      "audio/wav"                  = "mpv.desktop";
    };
  };
}
