#!/bin/bash
set -uo pipefail
K=/root/fuxi/t36-bl2/kernel.macho
echo "=== 内核里的屏幕/控制台相关参数与字符串 ==="
for pat in sheng-banner boot-progress sheng-fb-diff console fb_console 'kprintf'; do
  n=$(strings -a "$K" 2>/dev/null | grep -c -i -- "$pat" || true)
  printf '  %-16s %s\n' "$pat" "$n"
done
echo
echo "=== sheng-banner 附近 ==="
strings -a "$K" 2>/dev/null | grep -iE 'sheng-banner|banner' | sort -u | head -10 | cut -c1-140
echo
echo "=== 控制台/framebuffer 控制台 ==="
strings -a "$K" 2>/dev/null | grep -iE 'fb_console|framebuffer console|console.*fb|vgaconsole|bootprogress' | sort -u | head -10 | cut -c1-140
