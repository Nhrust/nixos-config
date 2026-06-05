{ pkgs, settings, ... }:
{
  powerManagement.cpuFreqGovernor = "schedutil";

  # Запрет автоматического suspend — машина работает 24/7
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # thermald — тепловой демон, предотвращает троттлинг при длительной нагрузке.
  # Актуален только для Intel: на AMD ядро управляет температурой через amd_pstate.
  services.thermald.enable = settings.cpu == "intel";

  environment.systemPackages = with pkgs; [
    lm_sensors # температуры процессора и материнской платы: sensors
    s-tui      # нагрузочный тест + мониторинг температур в TUI
  ];
}
