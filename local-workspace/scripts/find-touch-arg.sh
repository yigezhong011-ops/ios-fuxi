#!/bin/bash
set -uo pipefail
echo "=== fuxi 触摸驱动的 boot-arg ==="
grep -rn 'PE_parse_boot_argn' /root/ios-fuxi/xnu/fuxi-sys/*.c 2>/dev/null | head -20
echo
echo "=== 触摸相关文件 ==="
ls /root/ios-fuxi/xnu/fuxi-sys/ 2>/dev/null
echo
echo "=== touch 关键字 ==="
grep -rn -i 'touch' /root/ios-fuxi/xnu/fuxi-sys/*.c 2>/dev/null | grep -i 'boot_arg\|parse\|enable' | head -8
