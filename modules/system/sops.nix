# =============================================================================
# modules/system/sops.nix — Управление секретами через sops-nix
# =============================================================================
# Зашифрованные YAML лежат в secrets/, расшифровываются на хосте автоматически
# через age-ключ который выводится из SSH host key (/etc/ssh/ssh_host_ed25519_key).
#
# Структура:
#   .sops.yaml                  — config sops: какие age-ключи имеют доступ к каким файлам
#   secrets/<name>.yaml         — зашифрованный YAML (закоммитан в публичный git)
#   /var/lib/sops-nix/key.txt   — age private key хоста (не в репо)
#
# Использование секрета в любом модуле:
#   { config, ... }: {
#     sops.secrets."ssh/github_key" = {};
#     # → secret будет расшифрован в /run/secrets/ssh/github_key
#     services.X.passwordFile = config.sops.secrets."ssh/github_key".path;
#   }
#
# Полная инструкция (как создать первый секрет, как добавить второй хост):
#   docs/SECRETS.md
#
# Если secrets/default.yaml не существует — модуль no-op, sops пропускается.
# Это позволяет использовать конфиг без секретов на старте.
# =============================================================================
{ config, lib, inputs, ... }:
let
  # Путь к default.yaml в репо (через self.outPath на этапе eval)
  defaultSecretsPath = inputs.self + "/secrets/default.yaml";
  hasSecrets         = builtins.pathExists defaultSecretsPath;
in
lib.mkIf hasSecrets {
  sops = {
    # Дефолтный файл секретов — используется если в .secrets-блоке хоста не
    # указан другой путь через sops.defaultSopsFile.
    defaultSopsFile   = defaultSecretsPath;
    defaultSopsFormat = "yaml";

    # Age-ключ берётся из ssh host key. Это означает что:
    #   1. ssh-keygen -t ed25519 во время install создаёт ключ
    #   2. ssh-to-age конвертирует его в age public key
    #   3. .sops.yaml использует этот key чтобы шифровать секреты для хоста
    #   4. На загрузке sops-nix конвертит ssh host key в age private key и
    #      расшифровывает /run/secrets/
    age = {
      sshKeyPaths      = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile          = "/var/lib/sops-nix/key.txt";  # alternate location
      generateKey      = true;                          # auto-gen если ключа нет
    };
  };
}
