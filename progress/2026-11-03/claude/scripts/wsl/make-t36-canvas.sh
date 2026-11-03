#!/bin/bash
# t36-canvas: the daily t36-bl2 (buttons + brightness) whose NativeLegacyDisplay reports an iPhone 14 Pro canvas, 1179x2556
# (393x852 pt at 3x), instead of the panel's 1080x2400, which no iPhone has and makes UIKit show the red fallback status
# bar. Experiment: how the scanout copes with surfaces larger than the panel is exactly what this boot shows.
set -euo pipefail
OUT=${1:-t36-canvas}; W=${CANVAS_W:-1179}; H=${CANVAS_H:-2556}
D=/root/fuxi/$OUT; rm -rf $D; mkdir -p $D
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36-bl2/vol.img $D/vol.img
mcopy -n -i $D/vol.img ::/EFI/UniXNU/Payloads/kernel.macho $D/bl2.kernel
# Stub right after t36-bl2's 0x68c-byte blob at 0xfffffff00c08e340: the cave past ~0xa23 bytes from its start is not free
# (a 0xaeb-byte blob died before the kernel console), so keep the stub well inside (0x6c0).
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-canvas.py $D/bl2.kernel $D/kernel.macho $W $H 0xfffffff00c08ea00
cmp -l $D/bl2.kernel $D/kernel.macho | wc -l | sed 's/^/changed bytes: /'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $D/vol.img ::/EFI/UniXNU/Payloads/kernel.macho $D/kernel.macho
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t36-bl2.img $D/vol.img /mnt/e/DSH-Fuxi/$OUT.img
