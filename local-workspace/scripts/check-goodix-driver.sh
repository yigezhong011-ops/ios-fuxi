#!/bin/bash
set -uo pipefail
D=/root/fuxi/fork-device
echo "=== 设备仓库里与触控相关 ==="
find "$D" -iname '*touch*' -o -iname '*goodix*' -o -iname '*hid*' 2>/dev/null | grep -v '\.git/' | head -15
echo
echo "=== 包里的 HID 文件 ==="
ls "$D/package" | grep -i 'hid\|touch' | head -10
echo
echo "=== 是否有 goodix 字样 ==="
grep -rl -i 'goodix\|gt9916' "$D" --include='*.c' --include='*.cpp' --include='*.h' --include='*.py' --include='*.toml' 2>/dev/null | head -8
echo
echo "=== 上游树里的触控驱动 ==="
find /mnt/e/DSH-Fuxi/unixnu-build/unixnu/drivers -maxdepth 1 -type d 2>/dev/null | head -12
ls /mnt/e/DSH-Fuxi/unixnu-build/unixnu/drivers 2>/dev/null | grep -i 'touch\|hid\|novatek\|goodix'
