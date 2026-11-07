#!/bin/bash
# t50-auto-120clock-p plus a reset hook for the USB control channel's REBOOT. Only the blob and one store in control_start differ. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh; tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh
bash /tmp/g120.sh t50-mine-gpu-usbreboot -DPANEL_120 -DUSB_REBOOT -DCLOCK_SECS=$(date +%s)UL
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-usbreboot /root/fuxi/t50-priv-usbreboot
bash /tmp/a.sh /root/fuxi/t50-priv-usbreboot 300 t50-auto-usbreboot
E=/root/fuxi/t50-mine-gpu-usbreboot
echo "=== hook"; llvm-objdump -d "$E/kernel.blob.elf" | awk '/<reboot_hook>:/{p=1} p&&/^$/{p=0} p' | cut -c19-80
echo "=== control_start store"; llvm-objdump -d --start-address=0xfffffff00c06e7b0 --stop-address=0xfffffff00c06e7e0 "$E/kernel.macho" | tail -n +7 | cut -c19-70
sha256sum /mnt/e/DSH-Fuxi/t50-auto-usbreboot.img | cut -c1-16
