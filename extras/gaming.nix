# =============================================================================
# extras/gaming.nix — Гейминг стек (опционально)
# =============================================================================
# Подключение:
#   imports = [ ../extras/gaming.nix ];  # в custom/<host>.nix
#
# Что внутри:
#   - Steam (нативный клиент + sandbox)
#   - GameMode (CPU/IO performance во время игры)
#   - MangoHud (FPS оверлей)
#   - Gamescope (композитор Valve — лучшее масштабирование для игр)
#   - ProtonUP-Qt (GUI установщик Proton-GE кастомных версий)
#   - Lutris (запуск игр не из Steam — Epic, GoG, эмуляторы)
#   - steam-run (FHS обёртка для запуска чужих бинарей)
#
# Системные требования:
#   - 32-bit OpenGL/Vulkan (уже включены через hardware.graphics.enable32Bit)
#   - Группа gamemode для пользователя (добавлена ниже)
#
# Зачем gamescope: для игр которые лочат разрешение, плохо работают с
# Wayland scale, или которые хочется отскейлить с целочисленным множителем
# (например 720p → 1440p без размывания).
# =============================================================================
{ pkgs, settings, ... }:
{
  # ── Steam ─────────────────────────────────────────────────────────────────
  # Включает steam-сессию через programs.steam — оптимальный путь для NixOS,
  # автоматически подтягивает 32-bit libs и udev правила контроллеров.
  programs.steam = {
    enable                       = true;
    remotePlay.openFirewall      = true;  # стрим на телефон/SteamLink
    dedicatedServer.openFirewall = true;  # хостить сервера
    gamescopeSession.enable      = true;  # запуск Steam в gamescope-сессии
  };

  # ── GameMode ──────────────────────────────────────────────────────────────
  # Daemon переключает CPU governor на performance во время игры,
  # повышает приоритет процесса, фиксирует частоты. Steam запускает игры
  # с переменной LD_PRELOAD автоматически когда установлен mangohud/gamemoderun.
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice              = 10;       # nice-уровень для игры
        ioprio              = 0;        # IO приоритет
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device              = 0;
        amd_performance_level   = "high";
      };
    };
  };

  # Пользователь в группе gamemode чтобы daemon мог менять параметры без sudo
  users.users.${settings.username}.extraGroups = [ "gamemode" ];

  # ── Gamescope ─────────────────────────────────────────────────────────────
  programs.gamescope = {
    enable     = true;
    capSysNice = true;  # позволяет менять nice без sudo (для приоритезации потоков)
  };

  # ── Пользовательские пакеты гейминг-стека ─────────────────────────────────
  home-manager.users.${settings.username}.home.packages = with pkgs; [
    mangohud         # FPS/temps/usage оверлей. Запуск: mangohud <game>
    protonup-qt      # GUI установщик Proton-GE
    lutris           # игры не из Steam (Epic, GoG, эмуляторы, ROM-launchers)
    steam-run        # FHS обёртка: steam-run ./какой-нибудь-чужой-бинарь
    wineWowPackages.stable  # Wine для самостоятельного запуска .exe (опционально)
  ];

  # ── 32-bit поддержка (для старых игр и Proton) ────────────────────────────
  # Эти настройки обычно уже включены modules/system/hardware/gpu-*.nix,
  # но дублируем для надёжности — если кто-то использует extras/gaming.nix
  # без полного GPU-модуля.
  hardware.graphics.enable32Bit = true;
}
