#!/bin/bash
# After t32-gpu4 panicked. Every kernel built after 14:38 differs from t32-bl-daily's by 48 bytes of the button/brightness blob
# (the 120 Hz edits), and every image with such a kernel failed. Both images here reuse t32-bl-daily's verified kernel.
# The daily arguments are 1 byte longer than the source's, so qcom-usb-debug=1 is dropped to keep unixnu.toml in place (as gpu4 did).
#   t32-bl-clean: t32-bl-daily with in-place packing (original addon)
#   t32-gpu5:     plus a GPU client list of two (the kernel has windows for the render server + 2 clients)
set -uo pipefail
export MTOOLS_SKIP_CHECK=1
K=/root/fuxi/t32/kernel-t32-bl-daily.macho
ARGS="rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 rm:qcom-usb-debug=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
echo "### t32-bl-clean"
KERNEL=$K bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-bl-clean $ARGS | grep -vE '^args:'
echo "### t32-gpu5"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/addon-set-clients.py /root/fuxi/t32/kernel.macho.gpuaddon /root/fuxi/t32/addon-t32-gpu5 \
  SpringBoard,WidgetRenderer_Default --same-size | tail -1
KERNEL=$K GPUADDON=/root/fuxi/t32/addon-t32-gpu5 bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-gpu5 $ARGS | grep -vE '^args:'
echo "### seed check"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/diff-bootimg-vs-vol.py /root/fuxi/t32/vol.img \
  /mnt/e/DSH-Fuxi/t32-bl-clean.img /mnt/e/DSH-Fuxi/t32-gpu5.img | grep changed
