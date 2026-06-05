{ pkgs, ... }:
{
  services.tlp = {
    enable   = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";

      # Лимит заряда — продлевает срок службы аккумулятора.
      # Закомментируй если нужен полный заряд (в дороге и т.д.)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0  = 80;
    };
  };

  # Автооптимизация питания периферии: USB autosuspend, PCIe ASPM и т.д.
  powerManagement.powertop.enable = true;

  services.libinput.touchpad = {
    naturalScrolling   = true;
    tapping            = true;
    disableWhileTyping = true;
  };

  # hardware.brightnessctl удалён из NixOS — используем пакет напрямую
  environment.systemPackages = with pkgs; [
    brightnessctl # управление яркостью: brightnessctl set 10%+
    acpi          # статус батареи: acpi -b
    powertop      # анализ энергопотребления
  ];
}
