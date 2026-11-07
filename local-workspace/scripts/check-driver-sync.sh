#!/bin/bash
# Are the device drivers actually present and part of the built tree?
set -uo pipefail
T=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree
D=/mnt/e/DSH-Fuxi/unixnu-build/fuxi

echo "=== 设备仓库的驱动子模块 ==="
ls "$D/drivers" 2>/dev/null | head -12
echo
for d in "$D"/drivers/*/; do
  n=$(basename "$d")
  c=$(ls "$d" 2>/dev/null | wc -l)
  printf '  %-24s %s 个文件\n' "$n" "$c"
done
echo
echo "=== 构建树里的驱动（core + device 合并后）==="
ls "$T/drivers" 2>/dev/null | head -25
echo
echo "=== kits ==="
ls "$T/kits" 2>/dev/null | head -12
echo
echo "=== 已编出的 archive ==="
ls "$T/build"/*.a 2>/dev/null | head -12
find "$T/build" -name '*.a' 2>/dev/null | head -12
