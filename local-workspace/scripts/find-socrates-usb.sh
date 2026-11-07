#!/bin/bash
# Where the socrates (SM8550) USB logging write-up and its firmware handoff live, and fuxi UEFI's USB driver set.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-code-search.py > /root/fuxi/cs.py
for q in 'filename:direct-usb-logging.md' 'UsbfnDwc3Dxe socrates' 'repo:ljhhkx529/uefi-fuxi UsbConfigDxe'; do
  echo "### $q"; python3 /root/fuxi/cs.py "$q" | head -8; sleep 3
done
echo "### fuxi DXE.inc USB lines and the FUXI_UFS_STACK gating"
F=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg
grep -n -iE 'usb|FUXI_UFS_STACK|!if|!else|!endif' $F/Include/DXE.inc | head -60
grep -n -B2 -A6 'FUXI_UFS_STACK' $F/fuxi.dsc | head -40
