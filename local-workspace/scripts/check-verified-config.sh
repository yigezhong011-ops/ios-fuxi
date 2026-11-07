#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
D=/root/fuxi/fork-device
echo "=== defconfig 里的 VERIFIED_ROOT ==="
grep -n 'VERIFIED_ROOT' "$D/configs/fuxi_gpu_defconfig" 2>/dev/null | cut -c1-170
echo
echo "=== build-arm-driver.py 的产物目录 ==="
grep -n "OUT =\|out =\|verified-root" "$T/scripts/build-arm-driver.py" 2>/dev/null | head -10 | cut -c1-170
echo
echo "=== 本地树里 build/ 下与 verified 相关的目录 ==="
find "$T/build" -maxdepth 1 -name '*verified*' 2>/dev/null | head -5
