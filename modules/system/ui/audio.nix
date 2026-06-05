# =============================================================================
# modules/system/ui/audio.nix — Звук через PipeWire
# =============================================================================
{ pkgs, ... }:
{
  # PulseAudio выключен — заменяется PipeWire
  services.pulseaudio.enable = false;

  # rtkit нужен PipeWire для real-time приоритетов (без лагов звука)
  security.rtkit.enable = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;  # для 32-bit приложений (Steam, Wine)
    pulse.enable      = true;  # совместимость с PulseAudio API
    jack.enable       = true;  # для аудио-софта (DAW и т.д.)
  };

  # Графический микшер
  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
