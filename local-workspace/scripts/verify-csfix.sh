#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/kernel-inject/kernel.csfix.fuxi
echo "=== 新内核里的注入与客户端打印 ==="
strings -a "$K" | grep -E 'FUXI INJECT|exec_inject_target|FUXI CLIENT|exec_inject' | sort -u | head -10
echo
echo "=== 大小对比 ==="
ls -l "$K" /mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi | awk '{print $5, $9}'
