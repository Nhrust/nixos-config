# =============================================================================
# modules/system/power-profiles.nix — Power-profiles-daemon
# =============================================================================
# Один демон, три профиля для всех машин:
#   performance — макс CPU/GPU, без троттлинга, кулера на полную
#   balanced    — адаптивно (дефолт для большинства)
#   powersave   — минимум потребления, дим экрана, консерватив
#
# Переключение на лету через `powerprofilesctl set <profile>` или через
# waybar-модуль / бинды Super+F1/F2/F3 — без необходимости пересобирать систему.
#
# Дефолт при загрузке выбирается так:
#   - если settings.powerProfile != null → используется он
#   - иначе по settings.profile:
#       laptop  → balanced
#       desktop → performance
#       server  → performance
# =============================================================================
{ pkgs, settings, lib, ... }:
let
  defaultByProfile = {
    laptop  = "balanced";
    desktop = "performance";
    server  = "performance";
  };
  effectivePowerProfile =
    if settings.powerProfile != null
    then settings.powerProfile
    else defaultByProfile.${settings.profile};
in
{
  services.power-profiles-daemon.enable = true;

  # Применить дефолтный профиль при загрузке.
  # Powerprofilesctl запоминает последний выбор пользователя, но эта служба
  # ставит явный дефолт в момент первой загрузки (или после nrs если
  # settings.powerProfile поменялся).
  systemd.services.set-default-power-profile = {
    description = "Apply default power profile from settings";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "power-profiles-daemon.service" ];
    requires    = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set ${effectivePowerProfile} || true
    '';
  };

  # Утилиты для пользователя
  environment.systemPackages = with pkgs; [ power-profiles-daemon ];
}
