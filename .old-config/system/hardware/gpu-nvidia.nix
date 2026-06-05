{ pkgs, config, ... }:
{
  # Явно задаём ядро чтобы избежать циклической зависимости модулей
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Модули ядра Nvidia — все четыре обязательны для корректной работы Wayland
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # nvidia — проприетарный драйвер, единственный вариант для Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable     = true;  # обязательно для Wayland
    powerManagement.enable = true;  # корректный suspend/resume
    open                   = false; # проприетарный драйвер (не открытый модуль)
    nvidiaSettings         = true;
    package                = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
  };

  # ── PRIME offload (ноутбуки с гибридной графикой Intel/AMD + Nvidia) ────────
  # Раскомментируй если есть две видеокарты.
  # BusID узнать через: lspci | grep -E "VGA|3D"
  # Формат: "PCI:шина:устройство:функция"
  #
  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   intelBusId     = "PCI:0:2:0";  # или amdgpuBusId для AMD iGPU
  #   nvidiaBusId    = "PCI:1:0:0";
  # };
}
