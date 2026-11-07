#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon38/boot.log
echo "=== 触摸相关日志 ==="
tr -d '\000' < "$L" | grep -a -i 'touch\|hid\|focal\|goodix\|gt9916\|novatek' | tail -15
echo
echo "=== cmdline 里的触摸开关 ==="
grep -o 'touchscreen=[0-9]*' /mnt/e/DSH-Fuxi/dump/wsl/step11b-build-boot.sh | head -2 || echo "(未设置 touchscreen=)"
echo
echo "=== 输入设备注册 ==="
tr -d '\000' < "$L" | grep -a -i 'HID: \|iohid\|digitizer' | tail -10
