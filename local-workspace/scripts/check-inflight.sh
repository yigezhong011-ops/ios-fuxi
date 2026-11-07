#!/bin/bash
set -uo pipefail
echo "=== fuxi-scanout 里的 boot-arg 开关 ==="
grep -rn 'PE_parse_boot_argn' /root/ios-fuxi/xnu/fuxi-scanout/*.cpp /root/ios-fuxi/xnu/fuxi-adreno/*.inc 2>/dev/null | head -12
echo
echo "=== sweet_gpu_inflight 的置位/清除 ==="
grep -rn 'sweet_gpu_inflight' /root/ios-fuxi/xnu/fuxi-scanout/*.cpp 2>/dev/null | head -10
