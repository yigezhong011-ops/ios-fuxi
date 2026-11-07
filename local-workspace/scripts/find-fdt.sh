#!/bin/bash
set -uo pipefail
cd /root/uefi-fuxi
echo "=== FDT / 设备树 指针的来源 ==="
grep -rn -i 'gFdtTableGuid\|FdtTable\|DeviceTreeGuid\|dtb' --include='*.c' --include='*.h' Platforms/Xiaomi/fuxiPkg Silicon/Silicium 2>/dev/null | grep -i -E 'guid|table|pointer|install' | head -12
echo
echo "=== 哪些地方把 payload 地址放进 HOB ==="
grep -rn -i '8f2c1e44\|PayloadGuid\|PayloadHob' --include='*.c' --include='*.h' . 2>/dev/null | head -10
