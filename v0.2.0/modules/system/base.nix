# =============================================================================
# modules/system/base.nix — Базовые системные пакеты + stateVersion
# =============================================================================
# Только инструменты-первой-необходимости. Прикладной софт — через
# modules/user/tools/ или extras/.
# =============================================================================
{ pkgs, settings, ... }:
{
  # KVM/QEMU — опционально через settings.virtualization
  virtualisation.libvirtd.enable = settings.virtualization;

  environment.systemPackages = with pkgs; [
    git curl wget pciutils usbutils lsof
  ] ++ (if settings.virtualization then [ pkgs.virt-manager ] else []);

  # ВАЖНО: stateVersion — версия NixOS на момент первой установки.
  # НЕ менять при апгрейдах! Иначе сломаются миграции stateful-сервисов.
  # См. https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.05";
}
