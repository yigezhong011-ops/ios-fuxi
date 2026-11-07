#!/bin/bash
set -uo pipefail
MU=/root/uefi-fuxi
echo "=== 4. 放 fuxi 设备树和 ramdisk 占位 ==="
mkdir -p "$MU/Resources/DTBs"
cp /root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi/device-tree/hardware.dtb "$MU/Resources/DTBs/fuxi.dtb"
: > "$MU/Resources/ramdisk"
ls -l "$MU/Resources/DTBs/fuxi.dtb" "$MU/Resources/ramdisk"

echo "=== 5. 重建固件（带 XnuLoader 的 BootManager）==="
cd /root/UniXNU
python3 ./unixnu build firmware --uefi "$MU" -D /root/UniXNU-fuxi > /root/fw-xnu.log 2>&1
echo "FW_EXIT=$?"
grep -iE 'error|warning.*XnuLoader' /root/fw-xnu.log | head -5
ls -lh "$MU/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd" 2>/dev/null

echo "=== 6. 编 xnuloader ==="
cd /root/hackios
command -v lld-link || echo "(缺 lld-link)"
bash xnuloader/build.sh 2>&1 | tail -5
ls -lh xnuloader/loader.efi 2>/dev/null
