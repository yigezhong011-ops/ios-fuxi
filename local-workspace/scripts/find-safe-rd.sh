#!/bin/bash
set -uo pipefail
echo "=== probe_safe_rd32 声明 ==="
grep -rn 'probe_safe_rd32\|probe_safe_wr32\|probe_fault' /root/ios-fuxi/shim/fuxi-probe/*.h /root/ios-fuxi/shim/fuxi-probe/*.c 2>/dev/null | head -12
echo
echo "=== fuxi-probe 文件 ==="
ls /root/ios-fuxi/shim/fuxi-probe/ 2>/dev/null
