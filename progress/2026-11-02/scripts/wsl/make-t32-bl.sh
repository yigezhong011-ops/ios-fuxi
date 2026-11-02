#!/bin/bash
# t32-bl-daily: t32-pause's arguments (no diagnostic page) with the PMIC buttons and the DSI panel brightness
# (fuxi-buttons-blob.c with BACKLIGHT; t32's ShengBacklight service started by sheng-backlight=1).
# Verified on the phone with t32-bl1 (2026-11-02): 359 brightness requests, 359 DCS writes, no failure.
# Usage: make-t32-bl.sh [out-name]
set -euo pipefail
OUT=${1:-t32-bl-daily}
export BLOB_DEFS="-DBACKLIGHT"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t32/kernel.macho "/root/fuxi/t32/kernel-$OUT.macho"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1 \
  | grep -E 'kernel replaced|kernel copy|_OK'
