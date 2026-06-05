{ pkgs, settings, ... }:
{
  powerManagement.cpuFreqGovernor = "schedutil";

  # Запрет автоматического suspend — машина должна работать 24/7
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # thermald — тепловой демон для Intel, предотвращает троттлинг при нагрузке
  # На AMD не нужен — ядро справляется само через amd_pstate
  services.thermald.enable = settings.cpu == "intel";

  environment.systemPackages = with pkgs; [
    lm_sensors  # температуры: sensors
    s-tui       # нагрузочный тест + температуры в TUI
  ];
}