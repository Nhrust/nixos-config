# =============================================================================
# custom/_examples/packages.nix — Дополнительные пакеты
# =============================================================================
# Используется как импорт в custom/<host>/default.nix или в custom/<host>.nix.
# Раскомментируй пакеты которые нужны, добавляй свои.
#
# Любой пакет ищется на https://search.nixos.org/packages
# =============================================================================
{ pkgs, settings, ... }: {

  # ── Системные пакеты — доступны всем юзерам этой машины ──────────────────
  environment.systemPackages = with pkgs; [
    # Мессенджеры и общение
    # discord
    # telegram-desktop
    # signal-desktop
    # element-desktop
    # zoom-us
    # slack

    # Браузеры (firefox идёт в базе)
    # google-chrome
    # brave
    # librewolf

    # Медиа
    # spotify
    # vlc
    # mpv
    # obs-studio

    # Производительность / заметки
    # obsidian
    # notion-app-enhanced
    # logseq
  ];

  # ── Пакеты только для твоего юзера (home-manager) ─────────────────────────
  # Установятся в $HOME/.nix-profile, не системно.
  # Это удобнее когда тебе одному, не остальным пользователям машины.
  home-manager.users.${settings.username}.home.packages = with pkgs; [
    # IDE / редакторы
    # vscode
    # neovim
    # jetbrains.idea-community

    # Девтулы (для постоянного использования)
    # postman
    # insomnia
    # dbeaver-bin

    # Личное
    # whatsapp-for-linux
    # bitwarden
  ];
}
