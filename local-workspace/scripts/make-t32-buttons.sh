#!/bin/bash
# t32-buttons<N>: t32-pause's arguments (sheng-fb-gpu=1, sheng-gpu-pause-us=100, no diagnostic page) with the kernel whose
# native_buttons_set_sink now starts the PMIC button poller (patch-t32-buttons.py). Temp-boot only until confirmed.
# Usage: make-t32-buttons.sh [out-name [BLOB_DEFS]]   e.g. make-t32-buttons.sh t32-buttons2 -DSELF_TEST
set -euo pipefail
OUT=${1:-t32-buttons}
export BLOB_DEFS=${2:-}
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t32/kernel.macho "/root/fuxi/t32/kernel-$OUT.macho"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 \
  | grep -E 'kernel replaced|kernel copy|_OK'
