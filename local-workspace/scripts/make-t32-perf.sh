#!/bin/bash
# t32-perf: t32-fast (no diagnostic overlay, GPU scan-out) with the GPU held at its top OPP:
#   sheng-gpu-perf=8      initial GMU vote, OPP 8 = 680 MHz (GpuPowerProbe.cpp: 1 = 220 MHz ... 8 = 680 MHz, default 1)
#   sheng-gpu-dcvs-min=8  DCVS floor at the same OPP, so idle gaps do not drop it to 348 MHz between frames
#                         (ljhhkx529 BUILD-PROGRESS: "GPU 长期停在 348 MHz 地板")
# Keeps sheng-data-persist=2, like t32. Temp-boot only.
set -euo pipefail
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-perf \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-perf=8 add:sheng-gpu-dcvs-min=8 \
  | grep -o 'sheng-gpu[^ ]*\|sheng-fb-gpu=[0-9]\|t32-perf_OK'
