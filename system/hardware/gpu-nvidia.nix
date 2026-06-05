{ pkgs, config, ... }:
{
  # Явно задаём ядро чтобы избежать циклической зависимости
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules  = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable     = true; # обязательно для Wayland
    powerManagement.enable = true;
    open                   = false;
    nvidiaSettings         = true;
    package                = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
  };

  # PRIME offload — для ноутбуков с Intel/AMD + Nvidia (гибридная графика)
  # Раскомментируй и заполни BusID (узнать: lspci | grep -E "VGA|3D"):
  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   intelBusId     = "PCI:0:2:0";
  #   nvidiaBusId    = "PCI:1:0:0";
  # };
}