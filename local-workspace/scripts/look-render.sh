#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== README 里 CPU / CoreAnimation / render ==="
grep -n -i -E 'coreanimation|cpu render|renders on|cpu-only|software render' README.md docs/sweet.md 2>/dev/null | head -15
echo
echo "=== README 状态表（Display/GPU 行）==="
grep -n -E '^\| *(Display|GPU|Graphics)' README.md | head -10
echo
echo "=== 关于 IOAcceleratorES ==="
grep -rn 'IOAcceleratorES' --include='*.md' . 2>/dev/null | head -10
