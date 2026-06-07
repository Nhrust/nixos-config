# =============================================================================
# modules/system/hardware/gpu-intel.nix — Intel GPU
# =============================================================================
{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules  = [ "i915" ];

  # GuC/HuC firmware — улучшает производительность GPU на Intel 8+ поколении
  boot.kernelParams = [ "i915.enable_guc=2" ];

  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver       # VA-API для Broadwell+ (2014+)
      intel-compute-runtime    # OpenCL
      intel-vaapi-driver       # VA-API fallback для старых поколений
      # Для 12+ поколения (Alder Lake+) может потребоваться vpl-gpu-rt
      # вместо intel-media-driver. Включи в hosts/<host>/overrides.nix через lib.mkForce.
    ];
  };
}
