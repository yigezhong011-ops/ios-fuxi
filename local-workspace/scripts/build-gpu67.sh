#!/bin/bash
# GPU client list follow-ups to t32-gpu5 (SpringBoard + WidgetRenderer_Default: widgets white -> black), on the verified daily kernel.
#   t32-gpu6: pong's list (SpringBoard, CollectionsPoster, WidgetRenderer_Default): CollectionsPoster draws the default wallpaper
#   t32-gpu7: wide list, close to uke's (adds PosterBoard, iconservicesagent, Preferences)
set -uo pipefail
export MTOOLS_SKIP_CHECK=1
K=/root/fuxi/t32/kernel-t32-bl-daily.macho
ARGS="rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 rm:qcom-usb-debug=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
build() {
  echo "### $1: $2"
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/addon-set-clients.py /root/fuxi/t32/kernel.macho.gpuaddon /root/fuxi/t32/addon-$1 "$2" --same-size | tail -1
  KERNEL=$K GPUADDON=/root/fuxi/t32/addon-$1 bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img $1 $ARGS | grep -E 'volume|_OK|rror'
}
build t32-gpu6 SpringBoard,CollectionsPoster,WidgetRenderer_Default
build t32-gpu7 SpringBoard,WidgetRenderer_Default,CollectionsPoster,PosterBoard,iconservicesagent,Preferences
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/diff-bootimg-vs-vol.py /root/fuxi/t32/vol.img \
  /mnt/e/DSH-Fuxi/t32-gpu6.img /mnt/e/DSH-Fuxi/t32-gpu7.img | grep changed
