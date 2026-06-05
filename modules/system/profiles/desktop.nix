# =============================================================================
# modules/system/profiles/desktop.nix — Профиль десктопа
# =============================================================================
{ ... }:
{
  # Schedutil — адаптивный governor, эффективнее "performance" при простое
  powerManagement.cpuFreqGovernor = "schedutil";
}
