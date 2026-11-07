#!/bin/bash
# Read-only: the reset layer and fastboot verb in V2, and what the local tree and the t50 kernel have.
set -u
R=/root/fuxi/ref-unixnu-fuxi-bare; Q=/root/fuxi/ref-qcomxnuusbdebug; L=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
echo '== QcomReset.c'; git -C "$R" show V2:package/QcomReset.c | cut -c1-130
echo '== QcomReset.h'; git -C "$R" show V2:package/QcomReset.h 2>/dev/null | cut -c1-130 | head -40
echo '== module control handler'; sed -n 1045,1125p "$Q/kernel/QcomXnuUsbDebug.c" | cut -c1-130
echo '== local tree'; git -C "$L" branch --show-current 2>/dev/null; git -C "$L" log -3 --format='%h %ad %s' --date=short 2>/dev/null | cut -c1-110; ls "$L/drivers" 2>/dev/null; ls "$L/drivers/QcomXnuUsbDebug" 2>/dev/null | head; ls /mnt/e/DSH-Fuxi/unixnu-build | head -20
ls "$L/package" | grep -i -E 'reset|usb|LegacyDisplay'
grep -n -E 'build-fuxi-usb|QcomUsb|usb' "$L/board.toml" | cut -c1-120 | head
echo '== last built kernels'; find /mnt/e/DSH-Fuxi/unixnu-build -maxdepth 6 -name 'kernel.macho' -printf '%TY-%Tm-%Td %s %p\n' 2>/dev/null | sort | tail -5
echo '== t50 kernel symbols'; K=/root/fuxi/t50-wall17/kernel.macho
for s in qcom_usb_debug_register_framebuffer qcom_usb_debug_register_screenshot qcom_usb_debug_set_reboot qcom_reset; do strings -a "$K" | grep -c "$s" | sed "s/^/$s strings: /"; done
python3 -I - "$K" <<'PY'
import sys
d=open(sys.argv[1],'rb').read(); print('size',len(d),'magic',d[:4].hex())
PY
