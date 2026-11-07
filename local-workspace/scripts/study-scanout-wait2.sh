#!/bin/bash
# Read-only: who writes native_gop_wait_stats and what the wait is.
cd /root/fuxi || exit 1
echo "=== writers"
grep -rlI 'native_gop_wait_stats' --include='*.c' --include='*.cpp' --include='*.h' --include='*.mm' --include='*.py' --include='*.patch' . 2>/dev/null | grep -v '^./logs' | head -20
F=$(grep -rlI 'native_gop_wait_stats' --include='*.cpp' --include='*.c' --include='*.h' drv-fork ux/drivers fork-device unixnu-pin/drivers up-latest/drivers 2>/dev/null | head -1)
echo "F=$F"
[ -z "$F" ] && F=$(grep -rlI 'native_gop_wait_stats' --include='*.cpp' . 2>/dev/null | head -1); echo "F=$F"
if [ -n "$F" ]; then
  git -C "$(dirname "$F")" log -1 --format='%h %ad %s' --date=short 2>/dev/null | cut -c1-90
  grep -n 'native_gop_wait_stats' "$F" | cut -c1-140
  L=$(grep -n 'native_gop_wait_stats\[' "$F" | head -1 | cut -d: -f1)
  echo "--- around $L"; sed -n "$((L-45)),$((L+25))p" "$F" | cut -c1-150
fi
echo "=== BootLog row"; sed -n 448,453p fuxi2/package/BootLog.c | cut -c1-260
echo "=== prepare row"; sed -n 214,222p fuxi2/package/BootLog.c | cut -c1-200
echo "=== t50 kernel: reads of stats"; llvm-nm t50/kernel.macho | grep -E 'native_gop_wait_stats|_native_legacy_(wait|prepare|present)|_gop_' | cut -c1-80 | head -12
echo "=== doc"
grep -rnI 'scanout wait\|waitForVBL\|waitVBL\|wait_stats' up-latest/docs/drivers up-latest/docs/porting 2>/dev/null | cut -c1-220 | head -10
