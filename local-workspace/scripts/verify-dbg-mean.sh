#!/bin/bash
set -uo pipefail
echo "=== 1. 0110 补丁里 SWEET DBG 打印的含义 ==="
grep -n -B12 -A6 'SWEET DBG: id=' /mnt/e/DSH-Fuxi/0110-fuxi-fb-debug.patch | head -40
echo
echo "=== 2. gpu=2 是什么 ==="
grep -n -B6 -A6 'gpu=%d\|gpu=' /mnt/e/DSH-Fuxi/0110-fuxi-fb-debug.patch | head -25
