#!/bin/bash
set -uo pipefail
P=/root/ios-fuxi/xnu/patches/0109-fuxi-backlight.patch
echo "=== boot-arg 与启用条件 ==="
grep -n 'PE_parse_boot_argn' "$P" | head -6
grep -n 'enable' "$P" | grep -v '^.*+.*enable()' | head -12
echo
echo "=== AppleCLCD 里的调用点 ==="
grep -n -B3 -A6 'fuxi_backlight_publish' "$P" | head -30
