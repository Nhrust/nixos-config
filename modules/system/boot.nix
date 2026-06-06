# =============================================================================
# modules/system/boot.nix — Загрузчик, swap, гибернация
# =============================================================================
# systemd-boot (UEFI). Swap-файл создаётся в @swap btrfs-сабволюме при первой
# загрузке через oneshot systemd-сервис. Гибернация активируется когда
# settings.resumeOffset заполнен (см. docs/POST_INSTALL.md §6).
# =============================================================================
{ pkgs, settings, ... }:
let
  hasHibernation = settings.resumeOffset != 0;
in
{
  # ── systemd-boot ─────────────────────────────────────────────────────────
  boot.loader.systemd-boot = {
    enable             = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Swap-файл (создаётся автоматически после первой загрузки) ────────────
  # Disko создал сабволюм @swap, но swap-файл нужно создать как файл.
  # Делаем это через systemd-сервис который отрабатывает один раз.
  systemd.services.create-swapfile = {
    description = "Create Btrfs swap file";
    wantedBy    = [ "multi-user.target" ];
    path        = with pkgs; [ btrfs-progs util-linux ];
    script = ''
      if [ ! -f /swap/swapfile ]; then
        btrfs filesystem mkswapfile --size ${toString settings.swapSize}g /swap/swapfile
        chmod 600 /swap/swapfile
      fi
    '';
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
    };
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # ── Гибернация (активируется когда заполнен resumeOffset) ────────────────
  boot.kernelParams =
    if hasHibernation
    then [ "resume_offset=${toString settings.resumeOffset}" ]
    else [];

  boot.resumeDevice =
    if hasHibernation
    then "/dev/disk/by-uuid/${settings.rootUUID}"
    else "";
}
