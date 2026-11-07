#!/bin/bash
set -uo pipefail
cd /root/fuxi/uni-star || exit 1
echo "=== workflow 里的 xcode 设置 ==="
grep -n 'xcode' .github/workflows/macos.yml | head -10 | cut -c1-140
echo
echo "=== 默认值 ==="
grep -n -A3 'xcode:' .github/workflows/macos.yml | head -8 | cut -c1-140
echo
echo "=== 他们是否处理 availability.pl ==="
grep -rn 'availability.pl' scripts/ 2>/dev/null | head -5 | cut -c1-150
