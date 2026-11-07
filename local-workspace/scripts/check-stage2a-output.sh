#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== pre_build 里 kernel.macho 相关 ==="
grep -n "kernel.macho\|find out/fuxi\|native-prelink" "$L" | head -15 | cut -c1-190
echo
echo "=== 有没有 '== kernel: prelink' 或 kernel 产物行 ==="
grep -n 'kernel: prelink\|kernel/kernel' "$L" | head -8 | cut -c1-190
