{ ... }:
{
  # schedutil — адаптивный governor, эффективнее "performance" при простое
  powerManagement.cpuFreqGovernor = "schedutil";

  # Добавляй специфику своего десктопа сюда по мере необходимости
}
