#!/bin/bash
# t32-buttons<N> diagnostic build: the button poller with its state written into the diagnostic page's CPU row (DIAG_ROW) and
# the volume-HUD self-test, booted with the diagnostic page on and sheng-cpufreq=0 (so nothing else writes that row).
# Row: "BTN s<stage> v<arbiter version> a<apids> p<PON apid> g<GPIO apid> r<PON RT_STS> u<GPIO RT_STS> m<mask> n<reports>
#       e<HID +0xe4: IOHIDEventDriver found> x<HID +0xe1: last button bits>"
#   s10 set_sink called, s20 thread runs, s31/32/33 setup failed (map/version/PON), s40 ready, s50 polling.
# Usage: make-t32-buttons-diag.sh [out-name] ; FORCE_REPORT=1 also makes buttonsAction send report 2 without the driver lookup.
set -euo pipefail
OUT=${1:-t32-buttons3}
export BLOB_DEFS="-DSELF_TEST -DDIAG_ROW"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t32/kernel.macho "/root/fuxi/t32/kernel-$OUT.macho"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 sheng-cpufreq=0 ${EXTRA_ARGS:-} \
  | grep -E 'kernel replaced|kernel copy|_OK'
