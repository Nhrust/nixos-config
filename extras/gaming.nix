# =============================================================================
# extras/gaming.nix — Гейминг стек (опционально, v0.3.0+ параметризация)
# =============================================================================
# Подключение:
#   imports = [ ../../extras/gaming.nix ];  # в hosts/<host>/extras-gaming.nix
#
# Активация:
#   1. settings.gaming.enable = true в hosts/<host>/settings.nix
#   2. Опционально — выключи подопции которые не нужны:
#        gaming.gamescope = false;
#        gaming.lutris    = false;
#
# Если settings.gaming.enable = false (дефолт) — модуль no-op. Это позволяет
# держать `imports = [ ../extras/gaming.nix ]` всегда подключённым, а
# включать/выключать через settings без правки hosts/<host>/extras-gaming.nix.
#
# Системные требования (включаются автоматически когда steam = true):
#   - 32-bit OpenGL/Vulkan
#   - Группа gamemode для пользователя (когда gamemode = true)
#
# Совместимость:
#   gamescope = true + steam = true → Steam запускается в gamescope-сессии
#   (gamescopeSession.enable).
# =============================================================================
{ pkgs, lib, settings, ... }:
let
  # Дефолты подопций (если в settings.nix юзера блок gaming не описан полностью)
  defaults = {
    enable    = false;
    steam     = true;
    gamemode  = true;
    mangohud  = true;
    protonup  = true;
    gamescope = false;
    lutris    = false;
    steamRun  = false;
  };
  cfg = defaults // (settings.gaming or {});
in
lib.mkIf cfg.enable (lib.mkMerge [

  # ── Steam ─────────────────────────────────────────────────────────────────
  (lib.mkIf cfg.steam {
    programs.steam = {
      enable                       = true;
      remotePlay.openFirewall      = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable      = cfg.gamescope;  # auto-on если gamescope=true
    };

    # 32-bit OpenGL для Steam/Proton
    hardware.graphics.enable32Bit = true;
  })

  # ── GameMode ──────────────────────────────────────────────────────────────
  (lib.mkIf cfg.gamemode {
    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice              = 10;
          ioprio              = 0;
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
  })

  # ── Gamescope (отдельный programs.gamescope блок) ────────────────────────
  (lib.mkIf cfg.gamescope {
    programs.gamescope = {
      enable     = true;
      capSysNice = true;  # позволяет менять nice без sudo
    };
  })

  # ── Пользовательские пакеты (mangohud, protonup-qt, lutris, steam-run) ────
  (lib.mkIf (cfg.mangohud || cfg.protonup || cfg.lutris || cfg.steamRun) {
    home-manager.users.${settings.username}.home.packages = with pkgs;
      lib.optionals cfg.mangohud  [ mangohud ]
      ++ lib.optionals cfg.protonup  [ protonup-qt ]
      ++ lib.optionals cfg.lutris    [ lutris wineWowPackages.stable ]
      ++ lib.optionals cfg.steamRun  [ steam-run ];
  })

])
