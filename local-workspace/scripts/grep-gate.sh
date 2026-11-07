#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi
echo "=== 内核里 fuxibbgpu 的解析与门控 ==="
grep -rn 'fuxibbgpu' "$D" 2>/dev/null | head -12
echo
echo "=== 仓库里的 gate 相关文件（本地缓存）==="
grep -rn 'fuxibbgpu\|fuxi-metal' /mnt/e/DSH-Fuxi/dump/stage-fuxi-metal.py 2>/dev/null | head -8
