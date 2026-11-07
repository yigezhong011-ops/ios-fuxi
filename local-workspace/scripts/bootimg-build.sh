#!/bin/bash
set -uo pipefail
echo "=== 安装 dtc ==="
command -v dtc || apt-get install -y device-tree-compiler > /dev/null 2>&1
command -v dtc

SOC_DTS=$(ls -d /root/UniXNU/out/feeds/UniXNU-sm8550-common-*/dts 2>/dev/null | head -1)
echo "soc dts: $SOC_DTS"
DEV=/root/UniXNU-fuxi
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi

echo "=== 编译 fuxi.dtb ==="
mkdir -p "$OUT/device-tree"
dtc -I dts -O dtb -i "$SOC_DTS" -o "$OUT/device-tree/hardware.dtb" "$DEV/dts/fuxi.dts" 2>&1 | head -10
ls -lh "$OUT/device-tree/hardware.dtb"

echo "=== 组装 boot.img ==="
cd /root/UniXNU
python3 ./unixnu bootimg -D "$DEV" --uefi /root/uefi-fuxi \
  --fd /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd \
  --dtb "$OUT/device-tree/hardware.dtb" \
  --ramdisk "$OUT/payload/payload.img" \
  -o "$OUT/boot/boot.img" > /root/unixnu-bootimg.log 2>&1
echo "BOOTIMG_EXIT=$?"
tail -25 /root/unixnu-bootimg.log
ls -lh "$OUT/boot" 2>/dev/null
