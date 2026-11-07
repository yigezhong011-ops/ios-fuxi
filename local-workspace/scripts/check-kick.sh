#!/bin/bash
set -uo pipefail
echo "=== fuxi_display_kick 实现 ==="
grep -rn -A20 'fuxi_display_kick' /root/ios-fuxi/xnu/fuxi-sys/*.c /root/ios-fuxi/xnu/fuxi-unixnu/*.cpp 2>/dev/null | head -35
