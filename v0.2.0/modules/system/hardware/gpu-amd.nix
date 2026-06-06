# =============================================================================
# modules/system/hardware/gpu-amd.nix — AMD GPU
# =============================================================================
{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # amdgpu — официальный драйвер для AMD GPU (GCN 3+ / 2015+)
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;  # для Steam и 32-bit приложений

    # Vulkan обеспечивается через RADV который встроен в Mesa.
    # amdvlk удалён из nixpkgs (AMD его deprecated).
    extraPackages = with pkgs; [
      rocmPackages.clr.icd   # OpenCL для вычислений
    ];
  };
}
