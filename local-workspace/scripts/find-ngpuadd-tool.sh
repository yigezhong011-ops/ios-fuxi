#!/bin/bash
set -uo pipefail
for D in /mnt/e/DSH-Fuxi/unixnu-build/unixnu /root/fuxi/uni-fork /root/fuxi/fuxi2; do
  [ -d "$D" ] || continue
  echo "=== $D ==="
  grep -rln 'NGPUADD' "$D" --include='*.py' --include='*.c' --include='*.cpp' --include='*.h' --include='*.sh' 2>/dev/null | head -6
done
echo
echo "=== 可能的打包脚本名 ==="
for D in /mnt/e/DSH-Fuxi/unixnu-build/unixnu /root/fuxi/uni-fork /root/fuxi/fuxi2; do
  [ -d "$D" ] || continue
  find "$D" -name '*addon*' -not -path '*/.git/*' 2>/dev/null | head -6
done
