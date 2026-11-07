#!/bin/bash
# Verify the new firmware volume carries the USB power enabler, then pack a boot image
# with it and the wallpaper payload.
set -uo pipefail
U=/root/build/uefi-fuxi
FD=$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
PAYLOAD=/root/build/unixnu/out/fuxi/payload/payload.img

echo "=== FD 大小 ==="
ls -l "$FD"

echo "=== 固件里的模块名证据 ==="
for pat in UsbPwrEnabler UsbPwr AdvancedLogDxe FuxiUfsLog FuxiUefiLog UniXNULogFlush; do
  n=$(strings -a "$FD" 2>/dev/null | grep -c -i "$pat" || true)
  printf '  %-16s %s\n' "$pat" "$n"
done

echo "=== BootShim ==="
find "$U" -name 'BootShim.bin' -newermt '-3 hours' 2>/dev/null | head -3

SHIM=$(find "$U" -name 'BootShim.bin' -newermt '-3 hours' 2>/dev/null | head -1)
if [ -z "$SHIM" ]; then SHIM=$(find "$U" -name 'BootShim.bin' 2>/dev/null | head -1); fi
echo "使用 $SHIM ($(stat -c%s "$SHIM" 2>/dev/null) 字节)"

echo "=== 打包 ==="
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/pack-with-fd.sh > /root/fuxi/pwf.sh
bash /root/fuxi/pwf.sh "$SHIM" "$FD" "$PAYLOAD" t32-usb 2>&1 | tail -5
