# =============================================================================
# modules/system/nix.nix — Настройки Nix
# =============================================================================
{ ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Автоочистка старых поколений раз в неделю (>7 дней)
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };
}
