#!/bin/bash
set -uo pipefail
echo "=== G4_FB_PA 定义 ==="
grep -rn 'define G4_FB_PA\|define G4_FB_VA\|G4_FB_PA =' /root/ios-fuxi/xnu/fuxi-adreno/ 2>/dev/null | head -5
echo
echo "=== 日志里的 framebuffer 地址 ==="
for L in /root/fuxi/mon23/boot.log /root/fuxi/mon24/boot.log; do
  echo "--- $L"
  tr -d '\000' < "$L" 2>/dev/null | grep -a 'AppleCLCD' | head -2
done
echo
echo "=== fuxi_gpu_start 的检查 ==="
sed -n '548,560p' /root/ios-fuxi/xnu/fuxi-adreno/fuxi_adreno.c
