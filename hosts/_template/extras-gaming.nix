# =============================================================================
# hosts/_template/extras-gaming.nix (копируется как hosts/<host>/extras-gaming.nix) — Подключение гейминг стека
# =============================================================================
# Этот файл — две вещи в одном:
#   1. imports = [ ../../extras/gaming.nix ] — подключает код стека
#   2. settings.gaming = { ... } — настраивает что именно включить
#
# Сам extras/gaming.nix живёт в upstream zone — его не трогаем. Этот файл —
# твой управляющий слой.
# =============================================================================
{ ... }: {
  imports = [ ../../extras/gaming.nix ];

  # ── Активация и подопции ──────────────────────────────────────────────────
  # Чтобы фактически что-то поставилось, нужен enable = true.
  # Все остальные опции имеют разумные дефолты — см. extras/gaming.nix
  # начало файла. Здесь только то что хочешь явно переопределить.
  #
  # Внимание — настройка идёт в hosts/<host>/settings.nix, не сюда!
  # Здесь только импорт. Параметры там:
  #
  #   gaming = {
  #     enable    = true;     # включить весь блок
  #     steam     = true;     # default true
  #     gamemode  = true;     # default true
  #     mangohud  = true;     # default true
  #     protonup  = true;     # default true
  #     gamescope = true;     # default false — composer для проблемных игр
  #     lutris    = true;     # default false — игры не-Steam
  #     steamRun  = false;    # default false — FHS-обёртка для внешних бинарей
  #   };
}
