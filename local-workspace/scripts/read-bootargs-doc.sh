#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs/reference/boot-configuration.md
echo "=== 文件 $(wc -l < "$F") 行 ==="
echo
echo "=== GPU / 显示 / ignition / owner 相关参数 ==="
grep -n -i 'gpu\|fb-gpu\|metal\|ignition\|owner\|backlight\|vsync\|display' "$F" | head -40
