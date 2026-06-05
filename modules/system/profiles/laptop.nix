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

      # Лимит заряда — продлевает срок службы батареи.
      # Работает на ThinkPad и некоторых Dell/HP — на остальных просто игнорируется.
      # Закомментируй если нужен полный заряд.
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0  = 80;
    };
  };

  # Автооптимизация питания периферии: USB autosuspend, PCIe ASPM
  powerManagement.powertop.enable = true;

  services.libinput.touchpad = {
    naturalScrolling   = true;
    tapping            = true;
    disableWhileTyping = true;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl    # управление яркостью: brightnessctl set 10%+
    acpi             # статус батареи: acpi -b
    powertop         # анализ энергопотребления
  ];
}
