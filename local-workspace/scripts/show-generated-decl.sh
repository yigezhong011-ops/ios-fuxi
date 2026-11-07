#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
H=$T/build/xnu/ios-obj/DEVELOPMENT_ARM64_BCM2837/iokit/DEVELOPMENT/DriverKit/IOService.h
H2=$T/build/xnu/ios-obj/DEVELOPMENT_ARM64_BCM2837/iokit/DriverKit/IOService.h
for f in "$H" "$H2"; do
  [ -f "$f" ] || continue
  echo "=== $f ==="
  grep -n 'UserSetProperties\|SendIOMessageServicePropertyChange' "$f" | head -8
  echo "--- 上下文（第一条附近的宏）---"
  n=$(grep -n 'UserSetProperties' "$f" | head -1 | cut -d: -f1)
  [ -n "${n:-}" ] && awk -v s=$((n>6?n-6:1)) -v e=$((n+6)) 'NR>=s && NR<=e {printf "%4d| %s\n", NR, $0}' "$f"
  echo
done
