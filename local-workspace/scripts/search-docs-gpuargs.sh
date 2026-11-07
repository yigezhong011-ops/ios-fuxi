#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
echo "=== 文档里所有 sheng-gpu* / sheng-fb* / sheng-backlight 的说明 ==="
grep -rn 'sheng-gpu\|sheng-fb-gpu\|sheng-backlight\|sheng-vsync' "$D" --include='*.md' 2>/dev/null | head -20
echo
echo "=== 文档里的 boot 参数参考文件 ==="
ls "$D/reference/" 2>/dev/null
