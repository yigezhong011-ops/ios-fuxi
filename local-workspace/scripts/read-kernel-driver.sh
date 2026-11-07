#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py
echo "=== 函数定义 ==="
grep -n '^def \|^    def ' "$K" | head -20
echo
echo "=== bootstrap 相关行 ==="
grep -n 'bootstrap' "$K" | head -12
echo
echo "=== 内核主流程（含 'kernel: XNU' 打印附近）==="
line=$(grep -n "kernel: XNU" "$K" | head -1 | cut -d: -f1)
if [ -n "$line" ]; then sed -n "$((line-10)),$((line+40))p" "$K"; fi
