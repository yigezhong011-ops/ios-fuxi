#!/bin/bash
set -uo pipefail
echo "=== publish / owned 的定义位置 ==="
grep -rn 'fuxi_gpu_scanout_publish\|fuxi_gpu_scanout_owned' /root/ios-fuxi/xnu/ 2>/dev/null | grep -v '\.patch' | head -10
echo
echo "=== 在 fuxi-adreno 里搜 ==="
grep -rn 'scanout_publish\|scanout_owned' /root/ios-fuxi/xnu/fuxi-adreno/*.c /root/ios-fuxi/xnu/fuxi-adreno/*.h 2>/dev/null | head -10
