{ settings, ... }:
{
  hardware.cpu.amd.updateMicrocode = true;

  # amd_pstate=active — современный драйвер частот P-state для процессоров Zen 2+
  # Обеспечивает более точное управление частотой и энергопотреблением
  boot.kernelParams  = [ "amd_pstate=active" ];

  # kvm-amd подключается только если включена виртуализация в settings.nix
  boot.kernelModules = if settings.virtualization then [ "kvm-amd" ] else [];
}
