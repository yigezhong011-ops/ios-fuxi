#!/bin/bash
# t32-bl<N> diagnostic build: the buttons as in t32-buttons-daily2 plus panel brightness over DSI (BACKLIGHT in
# fuxi-buttons-blob.c), its state on the diagnostic page's CPU row (BL_DIAG_ROW; sheng-cpufreq=0 keeps the row free):
#   "BL g<bl stage> s<sheng stage> q<requests> t<target> l<last level> k<sends> f<failures> e<last failure> c<DSI_CTRL> i<INT_CTRL>
#    r<120 Hz switch: 0 sent, ffffffff not built in, else 100 * packet + failure>"
# Usage: make-t32-bl-diag.sh [out-name]  ; EXTRA_DEFS="-DPANEL_120HZ" also switches the panel to 120 Hz at start
set -euo pipefail
OUT=${1:-t32-bl1}
export BLOB_DEFS="-DBACKLIGHT -DBL_DIAG_ROW ${EXTRA_DEFS:-}"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t32/kernel.macho "/root/fuxi/t32/kernel-$OUT.macho"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 sheng-cpufreq=0 add:sheng-backlight=1 \
  | grep -E 'kernel replaced|kernel copy|_OK'
