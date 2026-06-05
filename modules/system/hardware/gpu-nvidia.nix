# =============================================================================
# modules/system/hardware/gpu-nvidia.nix — Nvidia GPU
# =============================================================================
{ pkgs, config, ... }:
{
  # Явно задаём ядро, чтобы избежать циклической зависимости
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Все четыре модуля нужны для корректной работы Wayland с Nvidia
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable     = true;  # обязательно для Wayland
    powerManagement.enable = true;  # корректный suspend/resume
    open                   = false; # проприетарный драйвер (open модуль ещё не зрел)
    nvidiaSettings         = true;
    package                = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
  };

  # ── PRIME offload (ноутбуки с гибридной графикой) ─────────────────────────
  # Если есть и iGPU и dGPU — раскомментируй блок ниже и заполни BusID.
  # Узнать BusID: lspci | grep -E "VGA|3D"
  # Формат: "PCI:шина:устройство:функция"
  #
  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   intelBusId  = "PCI:0:2:0";   # для Intel iGPU
  #   # amdgpuBusId = "PCI:5:0:0"; # для AMD iGPU вместо Intel
  #   nvidiaBusId = "PCI:1:0:0";
  # };
}
