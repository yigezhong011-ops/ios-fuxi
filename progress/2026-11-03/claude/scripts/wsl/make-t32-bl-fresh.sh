#!/bin/bash
# Control for t32-iphone14a (iPhone identity + fresh Data, rebooted after the colour bars): the same image with the iPad
# identity, i.e. t32-bl-clean without sheng-data-persist=2. Boots -> the identity is the problem; fails the same way -> fresh Data is.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL=/root/fuxi/t32/kernel-t32-bl-daily.macho bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-bl-fresh \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1 rm:sheng-data-persist=2 \
  | grep -E 'replaced|volume|_OK|rror'
