# =============================================================================
# disko/btrfs-existing.nix — Монтирование существующих разделов
# =============================================================================
# Используется при diskMode = "existing" (dual-boot, тесты рядом с другой ОС)
# Не трогает таблицу разделов и не форматирует диск.
#
# ТРЕБОВАНИЯ перед использованием:
#   1. Разделы уже существуют — проверь: lsblk -f
#   2. diskPartBoot в settings.nix указывает на FAT32 EFI раздел
#   3. diskPartRoot в settings.nix указывает на Btrfs раздел
#   4. На Btrfs разделе созданы все сабволюмы:
#        @, @home, @nix, @log, @cache, @tmp, @swap
#      Если сабволюмов нет — см. раздел "Путь 2" в README.md
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
