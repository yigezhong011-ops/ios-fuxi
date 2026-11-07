#!/bin/bash
set -uo pipefail
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi
echo "=== 当前本地输出目录 ==="
ls -la "$OUT" 2>/dev/null || echo "(不存在)"
echo
echo "=== 把 CI 产物放进对应位置 ==="
mkdir -p "$OUT/kernel" "$OUT/payload"
cp /mnt/e/DSH-Fuxi/unixnu/payload/ipados-17.7.11-21H461/fuxi/kernel/kernel.macho "$OUT/kernel/kernel.macho"
cp /mnt/e/DSH-Fuxi/unixnu/payload/ipados-17.7.11-21H461/fuxi/payload/payload.img "$OUT/payload/payload.img"
cp /mnt/e/DSH-Fuxi/unixnu/payload/ipados-17.7.11-21H461/fuxi/payload/payload.json "$OUT/payload/payload.json"
ls -lh "$OUT/kernel" "$OUT/payload"
echo
echo "=== 固件 FD ==="
ls -lh /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
echo
echo "=== bootimg 用法 ==="
cd /root/UniXNU && python3 ./unixnu bootimg --help 2>&1 | head -20
