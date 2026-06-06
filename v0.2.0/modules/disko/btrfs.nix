# =============================================================================
# modules/disko/btrfs.nix — Полная автоматическая разметка диска
# =============================================================================
# Активируется при settings.diskMode = "wipe".
# УНИЧТОЖАЕТ все данные на settings.disk.
#
# Схема:
#   p1 → EFI (1 GB, FAT32, /boot)
#   p2 → Btrfs (остаток) с сабволюмами из lib/btrfs-subvolumes.nix
# =============================================================================
{ settings, ... }:
let
  subvolumes = import ../../lib/btrfs-subvolumes.nix;
in
{
  disko.devices.disk.main = {
    type   = "disk";
    device = settings.disk;

    content = {
      type = "gpt";
      partitions = {

        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type       = "filesystem";
            format     = "vfat";
            mountpoint = "/boot";
          };
        };

        root = {
          size    = "100%";
          content = {
            type       = "btrfs";
            extraArgs  = [ "-L" "nixos" "-f" ];
            inherit subvolumes;
          };
        };

      };
    };
  };
}
