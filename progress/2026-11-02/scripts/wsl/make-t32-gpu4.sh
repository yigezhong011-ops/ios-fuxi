#!/bin/bash
# t32-gpu4: same as mgc.sh, but the toml also drops qcom-usb-debug=1 so the edited
# argument list fits the fixed file length (the toml can only shrink, never grow).
set -euo pipefail
OUT=t32-gpu4
LIST='SpringBoard,WidgetRenderer_Default,iconservicesagent,Preferences'

ls -l /root/fuxi/t32/addon-$OUT /root/fuxi/t32/kernel-$OUT.macho

tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" \
GPUADDON="/root/fuxi/t32/addon-$OUT" \
bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 rm:qcom-usb-debug=1 \
  sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1 \
  | grep -E 'replaced|mismatch|volume:|_OK|args:'
