#!/bin/bash
# t32-diag: t32-max's speed arguments with the live diagnostic page kept on (-v, boot-progress=2, armcpu-diagnostics=1),
# to read where frame time goes (FB/SWAP/GPUC rows, direct-scanout state, GPU level) instead of guessing.
set -euo pipefail
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-diag \
  sheng-fb-gpu=1 add:sheng-gpu-perf=8 add:sheng-gpu-dcvs-min=8 add:sheng-dpu-scanout=2 sheng-cpufreq=3 \
  | grep -o 'boot-progress=[0-9]\|sheng-dpu-scanout=[0-9]\|sheng-gpu-perf=[0-9]\|t32-diag_OK'
