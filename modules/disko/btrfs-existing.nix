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
#   4. На Btrfs созданы сабволюмы: @, @home, @nix, @log, @cache, @tmp, @swap
#
# Подготовка разделов и сабволюмов — см. docs/INSTALL.md
# =============================================================================
{ settings, ... }:
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
        subvolumes = {
          "@"      = { mountpoint = "/";         mountOptions = [ "compress=zstd" "noatime" ]; };
          "@home"  = { mountpoint = "/home";      mountOptions = [ "compress=zstd" "noatime" ]; };
          "@nix"   = { mountpoint = "/nix";       mountOptions = [ "compress=zstd" "noatime" ]; };
          "@log"   = { mountpoint = "/var/log";   mountOptions = [ "noatime" ]; };
          "@cache" = { mountpoint = "/var/cache"; mountOptions = [ "compress=zstd" "noatime" ]; };
          "@tmp"   = { mountpoint = "/var/tmp";   mountOptions = [ "noatime" ]; };
          "@swap"  = { mountpoint = "/swap";      mountOptions = [ "noatime" ]; };
        };
      };
    };

  };
}
