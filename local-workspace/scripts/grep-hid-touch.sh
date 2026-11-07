#!/bin/bash
set -uo pipefail
echo "=== sweet_hid_touch 的实现位置 ==="
grep -rn 'sweet_hid_touch' /root/ios-fuxi/xnu/ 2>/dev/null | grep -v '\.o:' | head -10
echo
echo "=== 实现体 ==="
F=$(grep -rl 'sweet_hid_touch(int' /root/ios-fuxi/xnu/ 2>/dev/null | head -1)
echo "文件: $F"
if [ -n "$F" ]; then
  awk '/sweet_hid_touch\(int/{found=1} found{print NR": "$0} found && /^}/{exit}' "$F" | head -60
fi
