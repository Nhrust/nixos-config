# =============================================================================
# modules/system/hardware/cpu-intel.nix — Intel CPU
# =============================================================================
{ settings, ... }:
{
  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelParams  = [ "intel_pstate=active" ];
  boot.kernelModules = if settings.virtualization then [ "kvm-intel" ] else [];
}
