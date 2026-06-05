# =============================================================================
# modules/system/bluetooth.nix — Bluetooth (опционально)
# =============================================================================
# Активируется при settings.bluetooth = true.
# =============================================================================
{ pkgs, settings, ... }:
{
  hardware.bluetooth = {
    enable      = settings.bluetooth;
    powerOnBoot = settings.bluetooth;
    settings.General = {
      # Современный профиль — лучшая совместимость с наушниками и геймпадами
      Experimental = true;
    };
  };

  # GUI для управления Bluetooth (трей-апплет)
  services.blueman.enable = settings.bluetooth;
}
