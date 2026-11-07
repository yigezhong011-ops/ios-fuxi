#!/bin/bash
set -uo pipefail
echo "=== 内核里的 overlay 实现 ==="
grep -rn 'sweet_overlay_add\|overlay' /root/ios-fuxi/xnu/sweet-fs/*.c 2>/dev/null | head -12
echo
echo "=== overlay 怎么从 ADT/命令行拿到 ==="
grep -rn 'overlay' /root/ios-fuxi/tools/mkadt-fuxi.py /root/ios-fuxi/xnu/sweet-fs/*.c 2>/dev/null | grep -i 'chosen\|adt\|prop' | head -8
echo
echo "=== 我们之前是怎么用 overlay 的（脚本）==="
grep -rln 'overlay' /mnt/e/DSH-Fuxi/dump/wsl/*.sh 2>/dev/null | head -5
