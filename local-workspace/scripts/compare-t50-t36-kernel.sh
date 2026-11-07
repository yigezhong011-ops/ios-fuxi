#!/bin/bash
set -uo pipefail
K=/root/fuxi/t50-mine/kernel.macho
echo "=== t50 内核里有没有 UniXNU / git 版本串 ==="
strings -a "$K" 2>/dev/null | grep -iE 'unixnu[-_ ]?(version|rev|commit)|git describe|793d6bd|adreno740.*[0-9a-f]{7}' | sort -u | head -10 | cut -c1-140
echo
echo "=== 内核构建时间 ==="
strings -a "$K" 2>/dev/null | grep -E '^[A-Z][a-z]{2} [A-Z][a-z]{2} +[0-9]+ [0-9:]{8} [A-Z]{3,4} 2026' | sort -u | head -5
echo
echo "=== t50 与 t36 内核大小/哈希对比 ==="
for f in /root/fuxi/t50-mine/kernel.macho /root/fuxi/t36-bl2/kernel.macho; do
  [ -f "$f" ] && printf '%-40s %12d  %s\n' "$f" "$(stat -c%s "$f")" "$(sha256sum "$f" | cut -c1-16)"
done
echo
echo "=== 两版内核里 Adreno740 导出的符号数量（粗略 ABI 面）==="
for f in /root/fuxi/t50-mine/kernel.macho /root/fuxi/t36-bl2/kernel.macho; do
  [ -f "$f" ] || continue
  n=$(strings -a "$f" | grep -c '__ZN22NativeAdrenoUserClient')
  printf '%-40s NativeAdrenoUserClient 符号 %s\n' "$(basename $(dirname $f))" "$n"
done
