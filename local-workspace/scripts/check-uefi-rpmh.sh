#!/bin/bash
set -uo pipefail
echo "=== uefi-fuxi 里的 RPMh / LDO 相关源码 ==="
grep -rln -i 'rpmh\|rsc\|ldob12\|ldom6\|regulator' /root/uefi-fuxi/Silicon /root/uefi-fuxi/Platforms 2>/dev/null | head -12
echo
echo "=== 是否有 cmd-db 解析 ==="
grep -rln -i 'cmd.db\|cmddb\|cmd_db' /root/uefi-fuxi/Silicon /root/uefi-fuxi/Platforms 2>/dev/null | head -6
echo
echo "=== fuxiPkg 里的驱动列表 ==="
ls /root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/ 2>/dev/null
