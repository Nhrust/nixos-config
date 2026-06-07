# =============================================================================
# custom/_examples/secrets-usage.nix — Как использовать секреты из sops
# =============================================================================
# Предусловия:
#   1. Ты прошёл туториал в docs/SECRETS.md или включил автонастройку
#      через settings.secretsAdminAgePubKey в hosts/<host>/settings.nix.
#   2. У тебя есть secrets/default.yaml (зашифрованный).
#
# В этом файле — паттерны как читать секреты в системных модулях.
# Раскомментируй то что нужно, замени имена секретов на свои.
# =============================================================================
{ config, ... }: {

  # ── Объявление секретов которые нужны этой машине ──────────────────────────
  # sops.secrets — это map "путь_в_yaml" → опции
  sops.secrets = {

    # # Пример 1: WiFi PSK для домашней сети
    # "wifi/home_psk" = {
    #   # путь будет: /run/secrets/wifi/home_psk
    # };

    # # Пример 2: GitHub token для CLI gh
    # "api/github_token" = {
    #   owner = "trefa";       # кто может читать
    #   mode  = "0400";        # права (только владелец)
    # };

    # # Пример 3: SSH приватный ключ для git push
    # "ssh/github_key" = {
    #   owner = "trefa";
    #   mode  = "0600";
    #   path  = "/home/trefa/.ssh/id_ed25519";  # явный путь вместо /run/secrets/
    # };
  };

  # ── Использование секретов ────────────────────────────────────────────────

  # # WiFi: пароль из секрета вместо плейн-текста
  # networking.wireless.networks."MyHomeWiFi".pskFile =
  #   config.sops.secrets."wifi/home_psk".path;

  # # Передача токена в окружение сервиса (через LoadCredential)
  # systemd.services.my-service.serviceConfig.LoadCredential = [
  #   "github-token:${config.sops.secrets."api/github_token".path}"
  # ];

  # # Сделать SSH-ключ доступным юзеру (через path выше)
  # # Ничего дополнительно делать не нужно — sops сам кладёт файл по path
  # # с правильным owner+mode.

  # # Пароль для пользователя из секрета
  # users.users.trefa.hashedPasswordFile = config.sops.secrets."users/trefa".path;
}
