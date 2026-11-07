#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== NativeAdrenoRing 的公开方法 ==="
F=$(grep -rl 'class NativeAdrenoRing' "$T/.cache/xnu-work" "$T/drivers" 2>/dev/null | head -1)
echo "文件: $F"
[ -n "$F" ] && grep -n 'void \|bool \|IOReturn \|setP\|ttbr' "$F" | head -20 | cut -c1-150
echo
echo "=== GpuPowerProbe 里调用处上下文 ==="
awk 'NR>=1435 && NR<=1450 {printf "%4d| %s\n", NR, $0}' "$T/kits/sheng/GpuPowerProbe.cpp" | cut -c1-160
