#!/bin/bash
set -uo pipefail
echo "=== metal 组件来源 ==="
find /root/ios-fuxi -maxdepth 3 -iname '*metal*' 2>/dev/null | head -12
echo
echo "=== FuxiMetal.bundle ==="
find / -maxdepth 6 -iname 'FuxiMetal.bundle' -not -path '*/proc/*' 2>/dev/null | head -3
echo
echo "=== 之前的 metal 安装日志 ==="
cat /root/fuxi/metal-install.log 2>/dev/null | head -10
