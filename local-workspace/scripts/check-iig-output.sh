#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
echo "=== 生成的 DriverKit 头（IOService.h 等）==="
find "$T/build" "$T/.cache" -name 'IOService.h' 2>/dev/null | head -5
echo
echo "=== 源 .iig 里有没有这两个方法 ==="
grep -rn 'UserSetProperties\|SendIOMessageServicePropertyChange' "$T/.cache/xnu-work/iokit" 2>/dev/null | head -8
echo
echo "=== 生成头里的 IOService 方法 ==="
H=$(find "$T/build" "$T/.cache" -name 'IOService.h' 2>/dev/null | head -1)
if [ -n "$H" ]; then
  echo "文件: $H ($(wc -l < "$H") 行)"
  grep -n 'UserSetProperties\|SendIOMessageServicePropertyChange\|virtual' "$H" | head -12
fi
