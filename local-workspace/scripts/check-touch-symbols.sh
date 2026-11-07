#!/bin/bash
set -uo pipefail
K=/root/insp-user/kernel.macho
for pat in 'sheng-touch' 'sheng_touch' 'Goodix' 'goodix' 'GT9916' 'gt9916' 'FocalTech' 'focaltech' 'touch-hid' 'NativeTouch' 'HidInput'; do
  n=$(strings -a "$K" 2>/dev/null | grep -c -- "$pat" || true)
  printf '%-14s %s\n' "$pat" "$n"
done
echo
echo "=== 含 touch 的引导参数（精确）==="
strings -a "$K" 2>/dev/null | grep -E '^sheng-[a-z-]*touch[a-z-]*$|^touch[a-z-]*$' | sort -u | head -20
echo
echo "=== 含 touch 且像驱动名的 ==="
strings -a "$K" 2>/dev/null | grep -iE 'touch' | grep -vE 'touching|touchdown' | sort -u | head -25 | cut -c1-110
