{ settings, ... }:
{
  hardware.cpu.intel.updateMicrocode = true;

  # intel_pstate=active — активный P-state драйвер для современных Intel CPU
  boot.kernelParams  = [ "intel_pstate=active" ];

  # kvm-intel подключается только если включена виртуализация в settings.nix
  boot.kernelModules = if settings.virtualization then [ "kvm-intel" ] else [];
}
