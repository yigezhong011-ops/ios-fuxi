#!/bin/bash
set -uo pipefail
echo "=== fuxi_keys 的键映射 ==="
grep -rn -i 'key 0x\|HID\|usage\|0x30' /root/ios-fuxi/xnu/fuxi-h1/fuxi_keys.c 2>/dev/null | head -20
echo
echo "=== 按键文件 ==="
ls /root/ios-fuxi/xnu/fuxi-h1/ | head -12
