#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
for f in scripts/audit-mobile-graphics-legacy.py; do
  echo "=== $f 里 plan 的用法 ==="
  grep -n "plan\[" "$T/$f" 2>/dev/null | head -12 | cut -c1-170
done
echo
echo "=== 设备仓库 build-native-legacy-display.py 里 plan 的用法 ==="
D=/root/fuxi/fork-device/scripts/build-native-legacy-display.py
grep -n "plan\[" "$D" 2>/dev/null | head -12 | cut -c1-170
echo
echo "=== 候选选择处 108-125 行 ==="
awk 'NR>=105 && NR<=125 {printf "%3d| %s\n", NR, $0}' "$D" | cut -c1-170
