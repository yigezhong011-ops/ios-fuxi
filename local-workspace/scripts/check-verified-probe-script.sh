#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== build-verified-root-probe.py 的输出目录 ==="
grep -n "OUT\|out =\|libVerifiedRootProbe" "$T/scripts/build-verified-root-probe.py" 2>/dev/null | head -8 | cut -c1-170
echo
echo "=== sheng_defconfig 里的路径（对照）==="
grep -n 'VERIFIED_ROOT_ARCHIVE' /root/fuxi/fork-device/configs/sheng_defconfig 2>/dev/null | cut -c1-170
echo
echo "=== 设备仓库的 build-xnu-4k-baseline.sh 里默认值 ==="
grep -n 'verified-root' /root/fuxi/fork-device/scripts/build-xnu-4k-baseline.sh 2>/dev/null | head -4 | cut -c1-170
