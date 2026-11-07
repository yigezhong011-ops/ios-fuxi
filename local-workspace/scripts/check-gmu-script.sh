#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts
echo "=== 设备仓库 scripts 里与固件相关的脚本 ==="
ls "$D" | head -20
echo
echo "=== prepare-fuxi-gmu.py 里读哪些路径 ==="
grep -n 'zap\|firmware\|mbn\|cache\|Path(' "$D/prepare-fuxi-gmu.py" 2>/dev/null | head -20
echo
echo "=== 构建脚本里 kit 怎么找固件 ==="
grep -rn 'a740_zap\|firmware' "$D/build-adreno740-kits.py" 2>/dev/null | head -12
