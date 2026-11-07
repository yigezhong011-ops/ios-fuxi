#!/bin/bash
set -uo pipefail
W=/root/fuxi/adtcmp
echo "=== 两个 ADT 的前 16 字节 ==="
for f in theirs ours; do
  printf '%-8s ' "$f"
  xxd -l 16 "$W/$f.adt" 2>/dev/null | head -1
done
echo
echo "=== 设备仓库的 make-fuxi-adt.py 里与 mix / prevention 相关 ==="
grep -n 'mix\|prevention\|img4\|boot-manifest' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/make-fuxi-adt.py 2>/dev/null | head -12
echo
echo "=== 该脚本的命令行选项 ==="
grep -n 'add_argument' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/make-fuxi-adt.py 2>/dev/null | head -25
