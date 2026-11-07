#!/bin/bash
set -uo pipefail
K=/root/insp-user/kernel.macho
for pat in 'FUXI TOUCH' 'fuxitouch_poll_us' 'fuxitouch_idle_us' 'fuxitouch_offsuppress' 'SweetHIDTouch' 'sweetfb_hz' 'SweetFramebuffer' 'fuxi_touch'; do
  n=$(strings -a "$K" 2>/dev/null | grep -c -- "$pat" || true)
  printf '%-26s %s\n' "$pat" "$n"
done
echo
echo "=== sweetfb / 显示相关字符串 ==="
strings -a "$K" 2>/dev/null | grep -E 'sweetfb|SWEET FB|SweetSurface' | sort -u | head -12 | cut -c1-120
