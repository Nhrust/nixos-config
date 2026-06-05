{ pkgs, settings, hostName, ... }:
let
  hasExtraLocale = settings.extraLocale != "";
  hasHibernation = settings.resumeOffset != 0;
in
{
  # ── Nix ───────────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Автоочистка старых поколений раз в неделю
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };

  # ── Загрузчик ─────────────────────────────────────────────────────────────
  boot.loader.systemd-boot = {
    enable             = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Swap-файл (создаётся автоматически после первой загрузки) ────────────
  # Disko создал сабволюм @swap, но swap-файл нужно создать как файл.
  # Делаем это через systemd-сервис который отрабатывает один раз.
  systemd.services.create-swapfile = {
    description = "Create Btrfs swap file";
    wantedBy    = [ "multi-user.target" ];
    path        = with pkgs; [ btrfs-progs util-linux ];
    script = ''
      if [ ! -f /swap/swapfile ]; then
        btrfs filesystem mkswapfile --size ${toString settings.swapSize}g /swap/swapfile
        chmod 600 /swap/swapfile
      fi
    '';
    serviceConfig = {
      Type             = "oneshot";
      RemainAfterExit  = true;
    };
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # ── Гибернация (активируется когда заполнен resumeOffset) ─────────────────
  boot.kernelParams =
    if hasHibernation
    then [ "resume_offset=${toString settings.resumeOffset}" ]
    else [];

  boot.resumeDevice =
    if hasHibernation
    then "/dev/disk/by-uuid/${settings.rootUUID}"
    else "";

  # ── Сеть ──────────────────────────────────────────────────────────────────
  networking.hostName              = hostName;
  networking.networkmanager.enable = true;

  # ── Локализация ───────────────────────────────────────────────────────────
  time.timeZone = settings.timezone;

  i18n.defaultLocale    = "en_US.UTF-8";
  i18n.supportedLocales =
    [ "en_US.UTF-8/UTF-8" ]
    ++ (if hasExtraLocale then [ "${settings.extraLocale}/UTF-8" ] else []);

  # Форматы выравниваются на вторую локаль, язык интерфейса остаётся английским
  i18n.extraLocaleSettings = if hasExtraLocale then {
    LC_TIME        = settings.extraLocale;
    LC_PAPER       = settings.extraLocale;
    LC_MEASUREMENT = settings.extraLocale;
    LC_MONETARY    = settings.extraLocale;
    LC_ADDRESS     = settings.extraLocale;
    LC_TELEPHONE   = settings.extraLocale;
  } else {};

  console.keyMap = "us"; # клавиатура всегда английская в консоли

  # ── Пользователь ──────────────────────────────────────────────────────────
  programs.fish.enable = true;

  users.users.${settings.username} = {
    isNormalUser    = true;
    shell           = pkgs.fish;
    extraGroups     = [ "wheel" "input" "networkmanager" "audio" "video" ]
      ++ (if settings.virtualization then [ "libvirtd" ] else []);
    initialPassword = "nixos"; # смени через passwd после первой загрузки
  };

  # ── Виртуализация ─────────────────────────────────────────────────────────
  virtualisation.libvirtd.enable = settings.virtualization;

  # ── Базовые системные пакеты ──────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git curl wget pciutils usbutils lsof
  ] ++ (if settings.virtualization then [ pkgs.virt-manager ] else []);

  system.stateVersion = "26.05";
}
