#!/bin/bash
# t32-fastdiag: t32-fast's arguments (sheng-fb-gpu=1, no direct scanout, default GPU/CPU governors) with the diagnostic
# page on. t32-diag showed "gpu offers=0", CPU copies of 65-130 ms and "native-metal: no device answer"; this tells
# whether sheng-dpu-scanout=2 or the perf arguments caused gpu offers=0, or the t32 kernel's Metal path itself.
set -euo pipefail
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-fastdiag sheng-fb-gpu=1 \
  | grep -o 'boot-progress=[0-9]\|sheng-fb-gpu=[0-9]\|sheng-dpu-scanout=[0-9]\|t32-fastdiag_OK'
