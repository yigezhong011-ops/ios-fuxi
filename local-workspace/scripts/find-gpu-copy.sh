#!/bin/bash
set -uo pipefail
echo "=== sweet_surface_gpu_copy 实现位置 ==="
grep -rn 'sweet_surface_gpu_copy' /root/ios-fuxi/xnu/ 2>/dev/null | head -8
echo
echo "=== fuxi-adreno 源码里的提交/围栏 ==="
ls /root/ios-fuxi/xnu/fuxi-adreno/ 2>/dev/null
echo
grep -rn 'inflight\|fence\|submit\|busy' /root/ios-fuxi/xnu/fuxi-adreno/*.c 2>/dev/null | head -20
