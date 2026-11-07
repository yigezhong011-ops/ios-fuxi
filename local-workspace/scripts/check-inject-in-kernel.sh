#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
echo "=== 内核里的注入配置与打印字符串 ==="
strings -a "$K" | grep -E 'redwood/lib|FUXI INJECT|exec_inject' | head -10
echo
echo "=== 内核大小/时间 ==="
ls -l "$K"
