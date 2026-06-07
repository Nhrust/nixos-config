# =============================================================================
# custom/_examples/services.nix — Системные сервисы (опционально)
# =============================================================================
# Раскомментируй и заполни параметры для сервисов которые тебе нужны.
# Все сервисы по умолчанию выключены — включаются явно.
# =============================================================================
{ pkgs, ... }: {

  # ── Tailscale (private VPN mesh) ──────────────────────────────────────────
  # После nrs: `sudo tailscale up` для первого логина
  # services.tailscale.enable = true;

  # ── Syncthing (P2P file sync) ─────────────────────────────────────────────
  # WebUI: http://localhost:8384
  # services.syncthing = {
  #   enable = true;
  #   user   = "trefa";
  #   dataDir = "/home/trefa/Sync";
  # };

  # ── SSH сервер ────────────────────────────────────────────────────────────
  # Принимай входящие SSH (например для удалённого доступа с другой машины)
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PasswordAuthentication = false;   # только по ключам
  #     PermitRootLogin = "no";
  #   };
  # };

  # ── Borg backup (декларативные бэкапы) ────────────────────────────────────
  # services.borgbackup.jobs.home = {
  #   paths = [ "/home/trefa" ];
  #   exclude = [ ".cache" "node_modules" ".direnv" ];
  #   repo = "/mnt/backup/borg-home";
  #   encryption.mode = "none";   # или "repokey" с passwordFile из sops
  #   compression = "zstd,3";
  #   startAt = "daily";
  # };

  # ── Mullvad VPN ───────────────────────────────────────────────────────────
  # GUI потом: `mullvad-vpn`
  # services.mullvad-vpn.enable = true;

  # ── Docker (если не хочешь podman из extras/development.nix) ──────────────
  # virtualisation.docker.enable = true;
  # users.users.${settings.username}.extraGroups = [ "docker" ];

  # ── KDE Connect (телефон ↔ комп) ──────────────────────────────────────────
  # Открывает порты 1714-1764 для discovery
  # programs.kdeconnect.enable = true;

  # ── Steam через extras/gaming.nix НЕ настраивается тут ────────────────────
  # Используй extras-gaming.nix вместо.
}
