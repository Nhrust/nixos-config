# =============================================================================
# modules/system/profiles/laptop.nix — Профиль ноутбука
# =============================================================================
{ pkgs, ... }:
{
  services.tlp = {
    enable   = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";

    };
  };

  # Автооптимизация питания периферии: USB autosuspend, PCIe ASPM
  powerManagement.powertop.enable = true;

  services.libinput.touchpad = {
    naturalScrolling   = true;
    tapping            = true;
    disableWhileTyping = true;
  };

  services.logind = {
    lidSwitch              = "ignore";  # от батареи
    lidSwitchExternalPower = "ignore";  # от сети
    lidSwitchDocked        = "ignore";  # в док-станции
  };

  environment.systemPackages = with pkgs; [
    brightnessctl    # управление яркостью: brightnessctl set 10%+
    acpi             # статус батареи: acpi -b
    powertop         # анализ энергопотребления
  ];
}
