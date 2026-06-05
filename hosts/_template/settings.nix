# =============================================================================
# hosts/_template/settings.nix
# =============================================================================
# Шаблон параметров хоста. Скопируй папку _template/ под именем твоей машины:
#   cp -r hosts/_template hosts/my-laptop
# Затем заполни поля ниже под своё железо.
# =============================================================================
{
  # ── Основное ──────────────────────────────────────────────────────────────
  username = "admin";
  hostname = "nixos";
  timezone = "Europe/Moscow";

  # Вторая локаль для форматов даты/времени/валюты.
  # Язык интерфейса и клавиатуры остаются английскими.
  # "ru_RU.UTF-8" | "de_DE.UTF-8" | "" (только английский)
  extraLocale = "ru_RU.UTF-8";

  # ── Железо ────────────────────────────────────────────────────────────────
  # cpu:     "amd"     | "intel"
  # gpu:     "amd"     | "intel"  | "nvidia"
  # profile: "laptop"  | "desktop" | "server"
  cpu     = "amd";
  gpu     = "amd";
  profile = "laptop";

  # Диск для установки. Проверь через: lsblk
  disk     = "/dev/nvme0n1";
  swapSize = 16; # GB

  # Режим разметки:
  #   "wipe"     — полная разметка (УНИЧТОЖАЕТ ВСЕ ДАННЫЕ)
  #   "existing" — использовать существующие разделы (см. docs/INSTALL.md)
  diskMode     = "wipe";
  diskPartBoot = "/dev/nvme0n1p1"; # только для diskMode = "existing"
  diskPartRoot = "/dev/nvme0n1p2"; # только для diskMode = "existing"

  # ── Гибернация (заполняется после установки, см. docs/HIBERNATION.md) ────
  resumeOffset = 0;
  rootUUID     = "FILL_ME";

  # ── Опциональный софт ─────────────────────────────────────────────────────
  virtualization = false; # KVM/QEMU + libvirtd
  printing       = false; # CUPS + Avahi
  bluetooth      = false; # hardware.bluetooth + blueman

  # ── Тема ──────────────────────────────────────────────────────────────────
  # theme:       "dark" → Catppuccin Mocha | "light" → Catppuccin Latte
  # themeAccent: blue | mauve | lavender | teal | pink | sky | sapphire
  #              red | maroon | peach | yellow | green | rosewater | flamingo
  theme       = "dark";
  themeAccent = "mauve";

  # ── Git ───────────────────────────────────────────────────────────────────
  gitName  = "Your Name";
  gitEmail = "your@email.com";
}
