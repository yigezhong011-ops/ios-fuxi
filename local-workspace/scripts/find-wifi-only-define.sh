#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
echo "=== 树里 PRIVATE_WIFI_ONLY 的定义处 ==="
grep -rn 'PRIVATE_WIFI_ONLY' "$T/.cache/xnu-work/makedefs" "$T/.cache/xnu-work/iokit/conf" "$T/config" 2>/dev/null | head -8 | cut -c1-170
echo
echo "=== 我们的 defconfig 里有没有 ==="
grep -n 'WIFI\|PRIVATE' /root/ux2/fuxi/.config 2>/dev/null | head -6
echo
echo "=== 内核构建脚本里定义了什么 -D ==="
grep -n '\-DPRIVATE\|WIFI' "$T/scripts/build-xnu-4k-baseline.sh" 2>/dev/null | head -6 | cut -c1-170
