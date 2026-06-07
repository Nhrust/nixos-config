# =============================================================================
# hosts/_template/overrides.nix (копируется как hosts/<host>/overrides.nix) — Override опций из modules/ через lib.mkForce
# =============================================================================
# modules/ — upstream immutable. Чтобы изменить настройку которая там задана,
# используй lib.mkForce — это говорит NixOS module system «возьми моё значение,
# проигнорируй то что в modules/».
#
# Без mkForce, при дубликате настройки в двух местах NixOS бросает ошибку
# билда «option X has been declared multiple times».
# =============================================================================
{ lib, settings, ... }: {

  # ── Выключить hypridle (например на десктопе с большим монитором) ─────────
  # services.hypridle.enable = lib.mkForce false;

  # ── Сменить дефолтную раскладку клавиатуры из settings.kbLayouts ──────────
  # Если settings.kbLayouts = "us,ru" но конкретно на этой машине нужно
  # "us,de,fr" — можно либо изменить settings (предпочтительно), либо тут:
  # ВНИМАНИЕ: kbLayouts применяется через input.conf.in, mkForce здесь
  # не сработает — меняй в settings.nix.

  # ── Сменить дефолтный шелл (отказаться от fish) ───────────────────────────
  # users.users.${settings.username}.shell = lib.mkForce pkgs.zsh;
  # programs.zsh.enable = true;
  # programs.fish.enable = lib.mkForce false;

  # ── Сменить дисплей-менеджер (например на SDDM вместо tuigreet) ───────────
  # services.greetd.enable = lib.mkForce false;
  # services.xserver.displayManager.sddm.enable = true;

  # ── Выключить bluetooth даже когда settings.bluetooth=true ────────────────
  # (зачем? — например для гостевой машины где хотим контроль через CLI)
  # hardware.bluetooth.enable = lib.mkForce false;
  # services.blueman.enable   = lib.mkForce false;

  # ── Сменить timezone независимо от settings ───────────────────────────────
  # time.timeZone = lib.mkForce "America/New_York";

  # ── Поменять Power Profile дефолт ─────────────────────────────────────────
  # (обычно проще через settings.powerProfile, но если нужен другой механизм)
  # systemd.tmpfiles.rules = lib.mkForce [
  #   "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 60"
  # ];
}
