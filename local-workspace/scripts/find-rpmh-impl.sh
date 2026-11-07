#!/bin/bash
set -uo pipefail
echo "=== fuxi_adreno 里的 RPMh / ARC / RSC ==="
grep -n -i 'rpmh\|arc_\|rsc\|tcs\|vrm' /root/ios-fuxi/xnu/fuxi-adreno/*.c /root/ios-fuxi/xnu/fuxi-adreno/*.h /root/ios-fuxi/xnu/fuxi-adreno/*.inc 2>/dev/null | head -20
echo
echo "=== 全仓搜索 RSC/TCS 实现 ==="
grep -rln -i 'rsc_drv\|tcs_cmd\|rpmh_write\|RSC_DRV' /root/ios-fuxi/xnu/ 2>/dev/null | grep -v '\.patch' | head -8
echo
echo "=== fuxi-perf（频率投票）里的 RPMh ==="
grep -n -i 'rpmh\|arc\|rsc\|vote' /root/ios-fuxi/xnu/fuxi-perf/*.c 2>/dev/null | head -15
