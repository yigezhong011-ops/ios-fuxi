#!/bin/bash
set -uo pipefail
echo "=== 文档里的 device lost / rc -4 ==="
grep -rn -i 'device lost\|DEVICE_LOST\|rc -4\|rc=-4\|VK_ERROR' /root/ios-fuxi/docs-lanes/*.md 2>/dev/null | head -15
echo
echo "=== Backend.hpp:1125 是什么调用 ==="
sed -n '1110,1135p' /root/ios-fuxi/tools/fuxi-metal/Backend.hpp
