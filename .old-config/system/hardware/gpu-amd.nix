{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # amdgpu — официальный драйвер для AMD GPU (GCN 3+)
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable      = true;
    enable32Bit = true; # нужно для Steam и 32-bit приложений

    extraPackages = with pkgs; [
      # amdvlk удалён из nixpkgs — AMD его deprecated
      # Vulkan обеспечивается через RADV, который встроен в Mesa
      rocmPackages.clr.icd # OpenCL для вычислений на GPU
    ];
  };
}
