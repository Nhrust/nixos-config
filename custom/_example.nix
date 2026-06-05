# =============================================================================
# custom/<host>.nix — Шаблон твоих оверрайдов для этого хоста
# =============================================================================
# Скопируй этот файл под именем своего хоста:
#   cp custom/_example.nix custom/$(hostname).nix
# Затем раскомментируй то что нужно и пересобери:
#   nrs
#
# Подробности и больше примеров — см. custom/README.md
# =============================================================================
{ pkgs, lib, settings, ... }:
{
  # ── Дополнительные системные пакеты ──────────────────────────────────────
  # environment.systemPackages = with pkgs; [
  #   obsidian
  #   discord
  # ];

  # ── Дополнительные пакеты только для твоего пользователя ─────────────────
  # home-manager.users.${settings.username} = {
  #   home.packages = with pkgs; [
  #     spotify
  #     telegram-desktop
  #   ];
  # };

  # ── Свои fish-алиасы декларативно ────────────────────────────────────────
  # home-manager.users.${settings.username} = {
  #   programs.fish.shellAliases = {
  #     myproj = "cd ~/projects/foobar";
  #   };
  # };

  # ── Включить дополнительные сервисы ──────────────────────────────────────
  # services.tailscale.enable = true;

  # ── Принудительный override (когда обычное присваивание конфликтует) ─────
  # services.openssh.enable = lib.mkForce false;
}
