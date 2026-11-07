#!/bin/bash
set -uo pipefail
P=/root/ios-fuxi/xnu/patches
echo "=== 0087: kick 区域 ==="
awk '/fuxi_display_kick/,/^ }/' "$P/0087-fuxi-display-autorefresh.patch" | head -25
echo
echo "=== 0108: kick 区域 ==="
awk '/fuxi_display_kick/,/^ }/' "$P/0108-fuxi-gpu-scanout.patch" | head -25
