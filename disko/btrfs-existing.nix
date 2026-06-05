# =============================================================================
# disko/btrfs-existing.nix — Монтирование существующих разделов
# Используется при diskMode = "existing" (dual-boot, тесты рядом с другой ОС)
# Не трогает таблицу разделов и не форматирует диск.
#
# Перед использованием:
#   1. Убедись что разделы уже существуют: lsblk -f
#   2. Заполни diskPartBoot и diskPartRoot в settings.nix
#   3. Корневой раздел должен быть отформатирован в Btrfs
#      и содержать сабволюмы @, @home, @nix, @log, @cache, @tmp, @swap
#      Если их нет — создай вручную или используй diskMode = "wipe"
# =============================================================================
{ settings, ... }:
{
  disko.devices = {

    disk.boot = {
      type   = "disk";
      device = settings.diskPartBoot;
      content = {
        type = "filesystem";
        format = "vfat";
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