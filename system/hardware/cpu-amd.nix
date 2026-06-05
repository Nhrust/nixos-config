{ settings, ... }:
{
  hardware.cpu.amd.updateMicrocode = true;
  # amd_pstate=active — современный драйвер частот для Zen 2+
  boot.kernelParams  = [ "amd_pstate=active" ];
  boot.kernelModules = if settings.virtualization then [ "kvm-amd" ] else [];
}