# =============================================================================
# modules/disko/btrfs-existing.nix — Монтирование существующих разделов
# =============================================================================
# Активируется при settings.diskMode = "existing".
# Используется для dual-boot или тестов на уже размеченном диске.
#
# ТРЕБОВАНИЯ:
#   1. Разделы существуют — проверь: lsblk -f
#   2. settings.diskPartBoot указывает на FAT32 EFI раздел
#   3. settings.diskPartRoot указывает на Btrfs раздел
#   4. На Btrfs созданы сабволюмы из lib/btrfs-subvolumes.nix
# =============================================================================
{ settings, ... }:
let
  subvolumes = import ../../lib/btrfs-subvolumes.nix;
in
{
  disko.devices = {

    disk.boot = {
      type   = "disk";
      device = settings.diskPartBoot;
      content = {
        type       = "filesystem";
        format     = "vfat";
        mountpoint = "/boot";
      };
    };

    disk.root = {
      type   = "disk";
      device = settings.diskPartRoot;
      content = {
        type = "btrfs";
        inherit subvolumes;
      };
    };

  };
}
