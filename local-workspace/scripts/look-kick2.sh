#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi/xnu
echo "=== fuxi_display_kick 实现 ==="
F=$(grep -rln 'fuxi_display_kick' . --include='*.c' --include='*.cpp' | head -1)
echo "file: $F"
grep -n -A18 'void fuxi_display_kick' "$F" | head -30
echo
echo "=== fuxi_gpu_scanout_publish 实现 ==="
G=$(grep -rln 'fuxi_gpu_scanout_publish' . --include='*.c' --include='*.cpp' | head -1)
echo "file: $G"
grep -n -A20 'int fuxi_gpu_scanout_publish' "$G" | head -30
