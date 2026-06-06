# =============================================================================
# modules/system/locale.nix — Локализация (timezone, i18n, console)
# =============================================================================
# Язык интерфейса фиксирован на en_US.UTF-8 (по задумке репо).
# settings.extraLocale добавляет вторую локаль ТОЛЬКО для форматов даты,
# валюты, чисел — интерфейс остаётся английским.
# Клавиатура консоли — английская; раскладки X11/Wayland задаются в Hyprland.
# =============================================================================
{ settings, ... }:
let
  hasExtraLocale = settings.extraLocale != "";
in
{
  time.timeZone = settings.timezone;

  i18n.defaultLocale    = "en_US.UTF-8";
  i18n.supportedLocales =
    [ "en_US.UTF-8/UTF-8" ]
    ++ (if hasExtraLocale then [ "${settings.extraLocale}/UTF-8" ] else []);

  # Форматы выравниваются на вторую локаль (LC_TIME/PAPER/MEASUREMENT/...),
  # но язык интерфейса (LC_MESSAGES) остаётся английским.
  i18n.extraLocaleSettings = if hasExtraLocale then {
    LC_TIME        = settings.extraLocale;
    LC_PAPER       = settings.extraLocale;
    LC_MEASUREMENT = settings.extraLocale;
    LC_MONETARY    = settings.extraLocale;
    LC_ADDRESS     = settings.extraLocale;
    LC_TELEPHONE   = settings.extraLocale;
  } else {};

  console.keyMap = "us"; # консоль всегда английская
}
