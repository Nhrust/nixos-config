# =============================================================================
# disko/btrfs.nix — Полная автоматическая разметка диска
# ВНИМАНИЕ: уничтожает ВСЕ данные на диске указанном в settings.disk
# Используется при diskMode = "wipe"
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
          size    = "1G";
          type    = "EF00";
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
              # Swap без сжатия — требование Btrfs для swap-файлов
              "@swap"  = { mountpoint = "/swap";      mountOptions = [ "noatime" ]; };
            };
          };
        };

      };
    };
  };
}