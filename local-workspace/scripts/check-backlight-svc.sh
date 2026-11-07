#!/bin/bash
set -uo pipefail
echo "=== fuxi-backlight 驱动发布的属性 ==="
grep -rn 'backlight-control\|setProperty\|publish' /root/ios-fuxi/xnu/fuxi-backlight/*.c 2>/dev/null | head -15
echo
echo "=== 0096/0109 补丁里 backlight 服务的注册 ==="
grep -rn -B2 -A6 'backlight-control' /root/ios-fuxi/xnu/patches/*.patch 2>/dev/null | head -25
