{ pkgs, settings, ... }:
let
  hasExtraLocale = settings.extraLocale != "";
  hasHibernation = settings.resumeOffset != 0;
in
{
  # ── Nix ─────────────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true; # хардлинки для дублей в store
  };

  # Автоматическая очистка старых поколений раз в неделю
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };

  # ── Загрузчик ────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable             = true;
  boot.loader.efi.canTouchEfiVariables        = true;
  boot.loader.systemd-boot.configurationLimit = 5; # хранить последние 5 поколений

  boot.tmp.useTmpfs = false; # tmpfs несовместим со swap-файлом на Btrfs

  # ── Гибернация ───────────────────────────────────────────────────────────────
  # Активируется только если resumeOffset != 0 в settings.nix
  boot.kernelParams =
    if hasHibernation
    then [ "resume_offset=${toString settings.resumeOffset}" ]
    else [];

  boot.resumeDevice =
    if hasHibernation
    then "/dev/disk/by-uuid/${settings.rootUUID}"
    else "";

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # ── Сеть ─────────────────────────────────────────────────────────────────────
  networking.hostName              = settings.hostname;
  networking.networkmanager.enable = true;

  # ── Локализация ──────────────────────────────────────────────────────────────
  time.timeZone = settings.timezone;

  i18n.defaultLocale    = "en_US.UTF-8";
  i18n.supportedLocales =
    [ "en_US.UTF-8/UTF-8" ]
    ++ (if hasExtraLocale then [ "${settings.extraLocale}/UTF-8" ] else []);

  # Форматы даты, времени, валюты и т.д. выравниваются на вторую локаль.
  # Язык интерфейса (LANG) и раскладка клавиатуры остаются английскими.
  i18n.extraLocaleSettings = if hasExtraLocale then {
    LC_TIME        = settings.extraLocale;
    LC_PAPER       = settings.extraLocale;
    LC_MEASUREMENT = settings.extraLocale;
    LC_MONETARY    = settings.extraLocale;
    LC_ADDRESS     = settings.extraLocale;
    LC_TELEPHONE   = settings.extraLocale;
  } else {};

  console = {
    font   = "cyr-sun16"; # шрифт с поддержкой кириллицы
    keyMap = "us";        # клавиатура всегда английская по умолчанию
  };

  # ── Пользователь ─────────────────────────────────────────────────────────────
  programs.fish.enable = true;

  users.users.${settings.username} = {
    isNormalUser    = true;
    shell           = pkgs.fish;
    extraGroups     = [ "wheel" "input" "networkmanager" "audio" "video" ]
      ++ (if settings.virtualization then [ "libvirtd" ] else []);
    initialPassword = "nixos"; # смени через passwd после первой загрузки
  };

  # ── Виртуализация ────────────────────────────────────────────────────────────
  virtualisation.libvirtd.enable = settings.virtualization;

  # ── Базовые системные пакеты ─────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git curl wget pciutils usbutils lsof
  ] ++ (if settings.virtualization then [ pkgs.virt-manager ] else []);

  system.stateVersion = "25.05";
}
