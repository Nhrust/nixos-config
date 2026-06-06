# =============================================================================
# hosts/_template/settings.nix
# =============================================================================
# Шаблон параметров хоста. Скопируй папку _template/ под именем твоей машины:
#   cp -r hosts/_template hosts/my-laptop
# Затем заполни поля ниже под своё железо.
# =============================================================================
{
  # ── Основное ──────────────────────────────────────────────────────────────
  username = "user";
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
  swapSize = 4; # GB

  # Режим разметки:
  #   "wipe"     — полная разметка (УНИЧТОЖАЕТ ВСЕ ДАННЫЕ)
  #   "existing" — использовать существующие разделы (см. docs/INSTALL.md)
  diskMode     = "wipe";
  diskPartBoot = "/dev/nvme0n1p1"; # только для diskMode = "existing"
  diskPartRoot = "/dev/nvme0n1p2"; # только для diskMode = "existing"

  # ── Гибернация (заполняется после установки, см. docs/POST_INSTALL.md §6) ─
  resumeOffset = 0;
  rootUUID     = "FILL_ME";

  # ── Опциональный софт ─────────────────────────────────────────────────────
  virtualization = false; # KVM/QEMU + libvirtd
  printing       = false; # CUPS + Avahi
  bluetooth      = false; # hardware.bluetooth + blueman

  # ── Питание ───────────────────────────────────────────────────────────────
  # powerProfile при загрузке:
  #   null            — auto: laptop → balanced, desktop/server → performance
  #   "performance"   — макс производительность (десктоп / тяжёлый воркфлоу)
  #   "balanced"      — адаптивно (дефолт ноута)
  #   "powersave"     — минимум потребления (в дороге, на батарее)
  # Меняется на лету через Super+F1/F2/F3 или клик по иконке в waybar.
  powerProfile = null;

  # Лимит заряда батареи (только laptop profile, работает на ThinkPad/Dell/HP/Asus).
  # null  — без лимита (заряд до 100%)
  # 80    — стандарт для долговечности батареи
  # 60    — если ноут всё время в розетке
  batteryChargeLimit = null;

  # ── Тема ──────────────────────────────────────────────────────────────────
  # theme:       "dark" → Catppuccin Mocha | "light" → Catppuccin Latte
  # themeAccent: blue | mauve | lavender | teal | pink | sky | sapphire
  #              red | maroon | peach | yellow | green | rosewater | flamingo
  theme       = "dark";
  themeAccent = "mauve";

  # ── Git ───────────────────────────────────────────────────────────────────
  gitName  = "Your Name";
  gitEmail = "your@email.com";

  # ── Upstream-источник обновлений (опционально, v0.1.9+) ───────────────────
  # URL который bootstrap пропишет в `git remote add upstream` при первой
  # установке. Если ты НЕ форкал репо — оставь закомментировано (используется
  # дефолт — апстрим автора). Если ты СДЕЛАЛ свой fork и хочешь получать
  # обновления от себя — поставь URL своего форка.
  #
  # Дефолт (если поле отсутствует): https://github.com/Nhrust/nixos-config.git
  #
  # upstream = "https://github.com/your-name/nixos-config.git";
}
