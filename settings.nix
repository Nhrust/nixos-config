# =============================================================================
# settings.nix — Личные параметры конфигурации
# =============================================================================
# Это единственный файл который нужно заполнить перед установкой.
# Скопируй его с GitHub, заполни поля и следуй инструкции в README.md
# =============================================================================
{
  # ── Основное ────────────────────────────────────────────────────────────
  username = "user";
  hostname = "nixos";
  timezone = "Europe/Moscow";

  # Вторая локаль — добавляется в систему и используется для LC_TIME,
  # LC_PAPER, LC_MEASUREMENT, LC_MONETARY и т.д.
  # Язык интерфейса и раскладка клавиатуры остаются английскими.
  # Примеры: "ru_RU.UTF-8" | "de_DE.UTF-8" | "" (только английский)
  extraLocale = "ru_RU.UTF-8";

  # ── Железо ──────────────────────────────────────────────────────────────
  # cpu:     "amd"   | "intel"
  # gpu:     "amd"   | "intel" | "nvidia"
  # profile: "laptop" | "desktop" | "server"
  #   laptop  — TLP, тачпад, powertop autotune, лимит заряда батареи
  #   desktop — schedutil governor, без TLP
  #   server  — schedutil governor, thermald (Intel) / аналог (AMD), без suspend
  cpu     = "amd";
  gpu     = "amd";
  profile = "laptop";

  # Путь к диску — проверь через: lsblk
  disk     = "/dev/nvme0n1";
  swapSize = 4; # GB, рекомендуется +4 GB от объёма RAM, 
  # если гибернация не нужна рекомендуется 4 GB и тогда раздел гибернации не заполняется

  # Режим разметки диска:
  #   "wipe"     — ПОЛНАЯ РАЗМЕТКА, уничтожает все данные на диске
  #   "existing" — использовать уже существующие разделы (dual-boot, тесты)
  # При "existing" заполни diskPartBoot и diskPartRoot ниже
  diskMode = "wipe";

  # Разделы для режима "existing" (игнорируются при diskMode = "wipe")
  # Проверь имена разделов через: lsblk -f
  diskPartBoot = "/dev/nvme0n1p1";
  diskPartRoot = "/dev/nvme0n1p2";

  # ── Гибернация ──────────────────────────────────────────────────────────
  # Оставь resumeOffset = 0 чтобы отключить гибернацию.
  # Для включения после установки:
  #   resumeOffset → btrfs inspect-internal map-swapfile -o /swap/swapfile
  #   rootUUID     → blkid /dev/nvme0n1p2
  resumeOffset = 0;
  rootUUID     = "";

  # ── Виртуализация ───────────────────────────────────────────────────────
  # Включает KVM/QEMU, добавляет пользователя в группу libvirtd
  virtualization = false;

  # ── Git ─────────────────────────────────────────────────────────────────
  gitName  = "Your Name";
  gitEmail = "your@email.com";
}