# Поддерживаемое железо

Матрица сочетаний CPU × GPU × profile, протестированных автором.
Если у тебя есть рабочая комбинация которой здесь нет — присылай PR.

## Что подразумевается под "тестировано"

✅ — установлено, загрузка, графика, звук, Wi-Fi, сон/гибернация, hyprland работают
🟡 — установлено и грузится, но известны мелкие проблемы (см. примечания)
❓ — должно работать по архитектуре, но никто не пробовал
❌ — известны блокирующие проблемы

## Матрица

| CPU \ GPU       | AMD iGPU | Intel iGPU | NVIDIA dGPU | AMD dGPU |
|-----------------|:---:|:---:|:---:|:---:|
| AMD Ryzen 5/7   | ✅ | —  | 🟡 (1) | ✅ |
| AMD Ryzen mobile| ✅ | —  | 🟡 (1) | ❓ |
| Intel i5/i7     | —  | ✅ | 🟡 (1) | ❓ |

### Примечания

**(1) Nvidia hybrid (PRIME):** работает с патчем в `gpu-nvidia.nix`,
но нужен ручной выбор offload-команды. Гибернация на Nvidia hybrid
может срывать сессию — используй `suspend` вместо.

## Профили по типу машины

| Машина | `settings.profile` | Что включается |
|---|---|---|
| Ноутбук | `laptop` | `lidSwitch=ignore`, hypridle (3 мин блок), battery-aware power profile |
| Десктоп | `desktop` | Без батарей, hypridle (5 мин блок), profile дефолт performance |
| Сервер | `server` | Без GUI-автологина, без hypridle, без auto-suspend |

## Что протестировано лично автором

| Машина | profile | cpu | gpu | Заметки |
|---|---|---|---|---|
| ASUS Zenbook 14 (2024) | laptop | amd | amd | gpu-amd ребрендинговая, всё работает |
| Custom desktop | desktop | amd | amd | примарный билд автора |
| (зарезервировано для friends) | | | | присылайте свои отзывы! |

## Что не протестировано но должно работать

- **Intel + Intel iGPU ноутбуки** (ThinkPad T-серия, Dell Latitude новые) — должно работать как и AMD iGPU
- **AMD + NVIDIA hybrid** (большинство игровых ноутов) — настройка через `gpu-nvidia.nix` + ручной выбор offload
- **Старые машины (10+ лет)** — поддержка от ядра Linux, не от нашего конфига; если ядро видит железо — работает

## Сетевые карты

NetworkManager поддерживает практически все Wi-Fi/Ethernet чипы через ядро.
Если карта не видится — проверь:

```fish
lspci | grep -i network        # видит ли железо
ip link                        # инициализирована ли в системе
sudo dmesg | grep -i firmware  # не нужен ли firmware blob
```

NixOS включает `linux-firmware` по умолчанию, но некоторые экзотические
чипы (Broadcom старые, некоторые realtek) требуют `nixpkgs.legacyPackages`
или unfree firmware. См. `TROUBLESHOOTING.md`.

## Bluetooth

Активируется через `settings.bluetooth = true`. Поддержка через BlueZ —
работает на всех чипах что BlueZ знает (≈ 99% современных).

## Принтеры

Активируется через `settings.printing = true`. CUPS + Avahi. Auto-discovery
по сети работает; локальные USB — добавлять через `system-config-printer`
после первой загрузки.

## CPU specifics

### AMD (Ryzen 1000–7000)
- Microcode обновляется автоматически через `hardware.cpu.amd.updateMicrocode`
- `amd-pstate` driver включён — нужен для нормальной работы power-profiles на новых Ryzen
- Опционально (custom): `services.thermald.enable = false` — не нужен на AMD

### Intel (8+ поколения)
- Microcode обновляется через `hardware.cpu.intel.updateMicrocode`
- На 12+ поколении (Alder Lake / Raptor Lake) с P+E ядрами — `intel-pstate`
  работает корректно, но Linux 6.6+ улучшил планировщик; убедись что ядро ≥ 6.6

## GPU specifics

### AMD (RDNA2/3 — RX 6000/7000, iGPU 680M/780M)
- Драйвер `amdgpu` (открытый, in-kernel)
- 32-bit OpenGL включён для Steam/Proton автоматически когда `extras/gaming.nix`
- HIP/ROCm — отдельно через custom-пакеты, не входит в дефолт

### Intel (Arc / Iris Xe / UHD)
- Драйвер `i915` или `xe` (новый, в Linux 6.8+) — `xe` пока экспериментальный
- Для Arc серии (A380, A750, A770) — может потребоваться ручной `kernelParams`

### NVIDIA
- Использует proprietary blob (как иначе)
- Wayland поддержка: explicit sync requires Linux 6.8+ и NVIDIA driver ≥ 555
- Не рекомендуется для laptop hybrid setup'ов — слишком много фрустрации,
  лучше iGPU-only или отдельная AMD dGPU
