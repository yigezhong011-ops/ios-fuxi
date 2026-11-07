#!/bin/bash
# Read-only: what qcom-usb-ctl and qcom-usb-reboot do in the driver's sources.
for R in /root/build/fuxi/drivers/QcomXnuUsbDebug /root/fuxi/ref-sad-fuxi/drivers/QcomXnuUsbDebug; do [ -f $R/README.md ] && break; done
D=$(find /root/build /root/fuxi /root/fuxi-build -type d -name 'QcomXnuUsbDebug' -not -path '*/out/*' 2>/dev/null | while read d; do [ "$(ls -A "$d" 2>/dev/null)" ] && echo "$d"; done | head -3)
echo "$D"
for d in $D; do
  echo "== $d"; ls "$d" "$d/docs" 2>/dev/null | head -30
  grep -rIn -E 'qcom-usb-ctl|qcom-usb-reboot|usb-reboot|reboot|fastboot|bootloader' "$d" --exclude-dir=.git 2>/dev/null | cut -c1-220 | head -30
done
grep -rIn -E 'qcom-usb-ctl|qcom-usb-reboot' /root/fuxi/ref-sad-fuxi /root/fuxi/up-latest/docs --exclude-dir=.git --exclude-dir=zh 2>/dev/null | cut -c1-260 | head -12
grep -n -i -E 'usb|COM3' /mnt/e/DSH-Fuxi/share-for-author/* 2>/dev/null | cut -c1-200 | head -14
ls /mnt/e/DSH-Fuxi/dump/wsl | grep -i -E 'com3|serial|usblog|usb-log|read-com' | head
