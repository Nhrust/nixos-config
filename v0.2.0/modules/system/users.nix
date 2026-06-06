# =============================================================================
# modules/system/users.nix — Основной пользователь и его шелл
# =============================================================================
# Имя берётся из settings.username. Пароль по умолчанию "nixos" — сменить
# через `passwd` после первой загрузки.
# Группы:
#   wheel          — sudo доступ
#   input/audio/video — устройства ввода и медиа
#   networkmanager — управление сетями без sudo
#   libvirtd       — KVM/QEMU (только если settings.virtualization = true)
# =============================================================================
{ pkgs, settings, ... }:
{
  programs.fish.enable = true;

  users.users.${settings.username} = {
    isNormalUser    = true;
    shell           = pkgs.fish;
    extraGroups     = [ "wheel" "input" "networkmanager" "audio" "video" ]
      ++ (if settings.virtualization then [ "libvirtd" ] else []);
    initialPassword = "nixos"; # смени через passwd после первой загрузки
  };
}
