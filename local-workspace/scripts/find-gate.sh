#!/bin/bash
set -uo pipefail
echo "=== fuxi-metal 源码目录 ==="
ls /root/ios-fuxi/tools/fuxi-metal/ 2>/dev/null | head -15
echo
echo "=== gate / bootarg 判定 ==="
grep -rn 'policy-or-bootarg\|fuxibbgpu\|gate deny' /root/ios-fuxi/tools/fuxi-metal/*.cpp /root/ios-fuxi/tools/fuxi-metal/*.hpp 2>/dev/null | head -15
