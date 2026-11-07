#!/bin/bash
set -uo pipefail
ls -l /root/ios-fuxi/tools/mkadt* 2>/dev/null
echo "=== ADT 生成器里的 display 节点 ==="
for f in /root/ios-fuxi/tools/mkadt-fuxi.py /root/ios-fuxi/tools/mkadt.py; do
  [ -f "$f" ] && { echo "--- $f ---"; grep -n -i 'display\|screen\|corner\|radius' "$f" | head -12; }
done
echo
echo "=== 已生成 ADT 里的 display 相关（strings）==="
strings /root/fuxi/fuxi.adt | grep -i 'display\|screen\|corner' | head -10
