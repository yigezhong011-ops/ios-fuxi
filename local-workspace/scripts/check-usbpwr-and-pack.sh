#!/bin/bash
set -uo pipefail
U=/root/build/uefi-fuxi
echo "=== 构建产物里有没有 UsbPwrEnablerDxe ==="
find "$U/Build/fuxiPkg/DEBUG_CLANGPDB" -maxdepth 4 -iname '*UsbPwr*' 2>/dev/null | head -5
echo
echo "=== 构建日志里有没有它 ==="
grep -c 'UsbPwrEnabler' /root/build/unixnu/out/fuxi/logs/firmware.log 2>/dev/null || echo 0
grep -n 'UsbPwrEnabler' /root/build/unixnu/out/fuxi/logs/firmware.log 2>/dev/null | head -3 | cut -c1-140
echo
echo "=== FV 里的模块名（FV 用 GUID，名字在 .map 里）==="
ls "$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/" 2>/dev/null | head -8
grep -c 'UsbPwrEnabler' "$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/RELEASE_*FvMain*.inf" 2>/dev/null || true
echo
echo "=== 打包镜像 ==="
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/pack-with-fd.sh > /root/fuxi/pwf.sh
bash /root/fuxi/pwf.sh "$U/BootShim/BootShim.bin" \
  "$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd" \
  /root/build/unixnu/out/fuxi/payload/payload.img t32-usb 2>&1 | tail -4
