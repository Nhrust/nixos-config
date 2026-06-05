{ pkgs, settings, ... }:
let
  hasExtraLocale  = settings.extraLocale != "";
  hasHibernation  = settings.resumeOffset != 0;
in
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true;
  };

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };

  boot.loader.systemd-boot.enable             = true;
  boot.loader.efi.canTouchEfiVariables        = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.tmp.useTmpfs                           = false;

  # Гибернация активируется только если resumeOffset задан в settings.nix
  boot.kernelParams =
    if hasHibernation
    then [ "resume_offset=${toString settings.resumeOffset}" ]
    else [];

  boot.resumeDevice =
    if hasHibernation
    then "/dev/disk/by-uuid/${settings.rootUUID}"
    else "";

  swapDevices = [ { device = "/swap/swapfile"; } ];

  networking.hostName              = settings.hostname;
  networking.networkmanager.enable = true;

  time.timeZone = settings.timezone;

  i18n.defaultLocale    = "en_US.UTF-8";
  i18n.supportedLocales =
    [ "en_US.UTF-8/UTF-8" ]
    ++ (if hasExtraLocale then [ "${settings.extraLocale}/UTF-8" ] else []);

  # Выравниваем форматы на вторую локаль, язык интерфейса остаётся английским
  i18n.extraLocaleSettings = if hasExtraLocale then {
    LC_TIME        = settings.extraLocale;
    LC_PAPER       = settings.extraLocale;
    LC_MEASUREMENT = settings.extraLocale;
    LC_MONETARY    = settings.extraLocale;
    LC_ADDRESS     = settings.extraLocale;
    LC_TELEPHONE   = settings.extraLocale;
  } else {};

  console = {
    font   = "cyr-sun16";
    keyMap = "us";
  };

  programs.fish.enable = true;

  users.users.${settings.username} = {
    isNormalUser    = true;
    shell           = pkgs.fish;
    extraGroups     = [ "wheel" "input" "networkmanager" "audio" "video" ]
      ++ (if settings.virtualization then [ "libvirtd" ] else []);
    initialPassword = "nixos"; # смени через passwd после первой загрузки
  };

  virtualisation.libvirtd.enable = settings.virtualization;

  environment.systemPackages = with pkgs; [
    git curl wget pciutils usbutils lsof
  ] ++ (if settings.virtualization then with pkgs; [ virt-manager ] else []);

  system.stateVersion = "26.05";
}