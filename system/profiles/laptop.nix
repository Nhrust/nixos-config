{ pkgs, ... }:
{
  services.tlp = {
    enable   = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT  = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC   = "performance";
      # Лимит заряда — продлевает срок службы батареи (75-80% оптимально)
      START_CHARGE_THRESH_BAT0     = 75;
      STOP_CHARGE_THRESH_BAT0      = 80;
    };
  };

  # Автоматическая оптимизация питания периферии (USB, PCIe ASPM и т.д.)
  powerManagement.powertop.enable = true;

  services.libinput.touchpad = {
    naturalScrolling   = true;
    tapping            = true;
    disableWhileTyping = true;
  };

  hardware.brightnessctl.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi      # статус батареи: acpi -b
    powertop  # анализ энергопотребления
  ];
}