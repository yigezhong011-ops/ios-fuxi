#!/bin/bash
# t32-buttons-bl: t32-buttons-daily (PMIC buttons, t32-pause arguments) plus sheng-backlight=1, which publishes sheng's
# ShengBacklight service so CoreBrightness finds a backlight (brightness slider, screen-off on lock). On fuxi its KTZ8866 target
# (I2C address 0x11) does not exist: i2c@a84000 is disabled in the stock DT and i2c@988000 only carries fsa4480@42 and rtc6226@64,
# so the level reads and writes go unanswered and the panel brightness itself does not change.
set -euo pipefail
OUT=${1:-t32-buttons-bl}
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL=/root/fuxi/t32/kernel-t32-buttons-daily.macho bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1 \
  | grep -E 'kernel replaced|kernel copy|_OK|args'
