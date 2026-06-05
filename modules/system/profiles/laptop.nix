# =============================================================================
# modules/system/profiles/laptop.nix — Профиль ноутбука
# =============================================================================
# TLP убран. Переключение профилей делается через power-profiles-daemon
# (см. modules/system/power-profiles.nix).
# =============================================================================
{ pkgs, lib, settings, ... }:
let
  chargeLimit = settings.batteryChargeLimit or null;
in
{
  services.libinput.touchpad = {
    naturalScrolling   = true;
    tapping            = true;
    disableWhileTyping = true;
  };

  # ── Закрытие крышки — НЕ суспендим ─────────────────────────────────────────
  # В свежих NixOS опции переехали в settings.Login.
  # (Старые services.logind.lidSwitch* остаются в работе но дают warning.)
  services.logind.settings.Login = {
    HandleLidSwitch              = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked        = "ignore";
  };

  # ── Лимит заряда батареи (опционально) ────────────────────────────────────
  systemd.services.battery-charge-limit = lib.mkIf (chargeLimit != null) {
    description = "Set battery charge end threshold to ${toString chargeLimit}%";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "sysinit.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
        echo ${toString chargeLimit} > "$f" 2>/dev/null || true
      done
      for f in /sys/class/power_supply/BAT*/charge_stop_threshold; do
        echo ${toString chargeLimit} > "$f" 2>/dev/null || true
      done
    '';
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi
    powertop
  ];
}
