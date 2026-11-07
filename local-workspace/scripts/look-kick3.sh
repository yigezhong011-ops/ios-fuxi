#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== fuxi_display_kick 定义 ==="
grep -rn 'fuxi_display_kick' xnu/ | grep -v SweetFramebuffer | head -5
P=$(grep -rln 'void fuxi_display_kick(void)' xnu/ | head -1)
echo "def in: $P"
grep -n -A16 'void fuxi_display_kick(void)' "$P" | head -24
echo
echo "=== fuxi_gpu_scanout_publish ==="
grep -rn 'fuxi_gpu_scanout_publish' xnu/ | head -4
Q=$(grep -rln 'int fuxi_gpu_scanout_publish' xnu/ | head -1)
echo "def in: $Q"
grep -n -A18 'int fuxi_gpu_scanout_publish' "$Q" | head -26
