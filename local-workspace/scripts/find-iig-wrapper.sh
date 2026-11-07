#!/bin/bash
set -uo pipefail
echo "=== iig 可执行文件 ==="
ls -l /opt/unixnu-linux/bin/iig* $HOME/.local/xnu-linux/bin/iig* 2>/dev/null
which iig 2>/dev/null
echo
echo "=== 找包装脚本 ==="
for f in /opt/unixnu-linux/bin/iig $HOME/.local/xnu-linux/bin/iig; do
  [ -f "$f" ] || continue
  echo "--- $f ---"
  head -20 "$f" 2>/dev/null | cut -c1-160
done
echo
echo "=== 树里 iig 的调用点 ==="
grep -rn 'iig' /root/ux2/fuxi/tree/.cache/xnu-work/makedefs/*.mk /root/ux2/fuxi/tree/.cache/xnu-work/makedefs/* 2>/dev/null | head -6 | cut -c1-170
