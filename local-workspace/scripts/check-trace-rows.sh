#!/bin/bash
set -uo pipefail
echo "=== t36 内核里有没有 trace 行字符串 ==="
for K in /root/fuxi/t36-bl2/kernel.macho /root/fuxi/t32/kernel.macho; do
  printf '%-28s ' "$(basename $(dirname $K))/$(basename $K)"
  strings -a "$K" 2>/dev/null | grep -c 'USB ph=' || true
done
echo
echo "=== t36 内核里的 boot ui trace 相关 ==="
strings -a /root/fuxi/t36-bl2/kernel.macho 2>/dev/null | grep -iE 'boot-ui-trace|boot_ui_trace|ui-trace' | sort -u | head -8 | cut -c1-120
echo
echo "=== 一个 [stacks] 段长什么样 ==="
D=/root/fuxi/logs/usb3/untagged-2d4aaa003
n=$(grep -a -n '^\[stacks\]' "$D/slots.txt" | sed -n '3p' | cut -d: -f1)
awk -v s="$n" 'NR>=s && NR<=s+12 {printf "%5d| %s\n", NR, substr($0,1,150)}' "$D/slots.txt"
