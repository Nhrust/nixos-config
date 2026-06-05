# =============================================================================
# disko/btrfs.nix — Полная автоматическая разметка диска
# =============================================================================
# ВНИМАНИЕ: уничтожает ВСЕ данные на диске указанном в settings.disk
# Используется при diskMode = "wipe"
#
# Схема разделов:
#   p1 → EFI  (1 GB, FAT32, /boot)
#   p2 → Root (всё остальное, Btrfs)
#
# Сабволюмы Btrfs:
#   @       → /           compress=zstd, noatime
#   @home   → /home       compress=zstd, noatime
#   @nix    → /nix        compress=zstd, noatime
#   @log    → /var/log    noatime (логи не сжимаем)
#   @cache  → /var/cache  compress=zstd, noatime
#   @tmp    → /var/tmp    noatime
#   @swap   → /swap       noatime, БЕЗ сжатия (требование Btrfs)
# =============================================================================
{ settings, ... }:
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
            type      = "btrfs";
            extraArgs = [ "-L" "nixos" "-f" ];

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
    };
  };
}
