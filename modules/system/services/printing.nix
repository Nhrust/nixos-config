# =============================================================================
# modules/system/printing.nix — Печать (опционально)
# =============================================================================
# Активируется при settings.printing = true.
# Включает CUPS + автообнаружение сетевых принтеров.
# =============================================================================
{ pkgs, settings, ... }:
{
  services.printing = {
    enable  = settings.printing;
    drivers = if settings.printing then (with pkgs; [
      gutenprint       # драйверы для Canon, Epson, HP, и т.д.
      hplip            # HP принтеры/МФУ
    ]) else [];
  };

  # Автообнаружение принтеров в локальной сети
  services.avahi = {
    enable        = settings.printing;
    nssmdns4      = settings.printing;  # резолв *.local имён
    openFirewall  = settings.printing;
  };
}
