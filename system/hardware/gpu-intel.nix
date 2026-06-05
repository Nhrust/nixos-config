{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules  = [ "i915" ];

  # GuC/HuC firmware — улучшает производительность GPU на поколениях Intel 8+
  # GuC: планировщик задач GPU, HuC: аппаратное декодирование видео через GPU
  boot.kernelParams = [ "i915.enable_guc=2" ];

  # modesetting — универсальный драйвер, рекомендован для Intel на Wayland
  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver   # VA-API: аппаратное декодирование видео (8+ поколение)
      intel-compute-runtime # OpenCL
      vaapiIntel           # VA-API fallback для старых поколений Intel
    ];
  };
}
