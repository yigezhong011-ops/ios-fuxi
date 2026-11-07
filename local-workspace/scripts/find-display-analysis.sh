#!/bin/bash
set -uo pipefail
D=/root/fuxi/fork-device
echo "=== 谁生成 mobile-graphics-legacy-abi.json ==="
grep -rn 'mobile-graphics-legacy-abi' "$D/scripts" 2>/dev/null | head -6 | cut -c1-170
echo
echo "=== 谁消费它 ==="
grep -rn 'display-analysis' "$D/scripts" 2>/dev/null | head -6 | cut -c1-170
echo
echo "=== defconfig 里 mobile/legacy display 开关 ==="
grep -n 'MOBILE_DISPLAY\|LEGACY_DISPLAY' "$D/configs/fuxi_gpu_defconfig"
