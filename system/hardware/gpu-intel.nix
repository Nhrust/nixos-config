{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules  = [ "i915" ];
  # GuC/HuC firmware — улучшает производительность GPU на 8+ поколении Intel
  boot.kernelParams   = [ "i915.enable_guc=2" ];

  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vaapiIntel
    ];
  };
}