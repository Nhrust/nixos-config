# =============================================================================
# modules/system/hardware/cpu-amd.nix — AMD CPU
# =============================================================================
{ settings, ... }:
{
  hardware.cpu.amd.updateMicrocode = true;

  # amd_pstate=active — современный драйвер частот для Zen 2+ (2019+)
  # Для старых процессоров безопасно, ядро выберет acpi-cpufreq автоматически
  boot.kernelParams  = [ "amd_pstate=active" ];

  # KVM для виртуализации — подключается по флагу
  boot.kernelModules = if settings.virtualization then [ "kvm-amd" ] else [];
}
