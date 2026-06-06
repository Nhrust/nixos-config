# =============================================================================
# lib/btrfs-subvolumes.nix — Общая схема btrfs-сабволюмов
# =============================================================================
# Используется обоими disko режимами (modules/disko/btrfs.nix и
# btrfs-existing.nix) — DRY-принцип, схема описана один раз.
#
# Структура:
#   @       → /          основная файловая система
#   @home   → /home      пользовательские данные
#   @nix    → /nix       /nix/store
#   @log    → /var/log   логи (отдельно — снапшоты не пухнут от логов)
#   @cache  → /var/cache кеши приложений
#   @tmp    → /var/tmp   временные файлы
#   @swap   → /swap      сабволюм для swap-файла (без сжатия — требование btrfs)
# =============================================================================
{
  "@"      = { mountpoint = "/";         mountOptions = [ "compress=zstd" "noatime" ]; };
  "@home"  = { mountpoint = "/home";     mountOptions = [ "compress=zstd" "noatime" ]; };
  "@nix"   = { mountpoint = "/nix";      mountOptions = [ "compress=zstd" "noatime" ]; };
  "@log"   = { mountpoint = "/var/log";  mountOptions = [ "noatime" ]; };
  "@cache" = { mountpoint = "/var/cache"; mountOptions = [ "compress=zstd" "noatime" ]; };
  "@tmp"   = { mountpoint = "/var/tmp";  mountOptions = [ "noatime" ]; };
  "@swap"  = { mountpoint = "/swap";     mountOptions = [ "noatime" ]; };
}
