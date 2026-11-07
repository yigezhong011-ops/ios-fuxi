#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon24/boot.log
echo "=== framebuffer 物理地址 / 尺寸 ==="
grep -a 'SWEET FB: AppleCLCD' "$L" | head -3
echo
echo "=== display on/off 与 CTL0 ==="
grep -a 'SWEET FB: display' "$L" | head -4
grep -a 'SWEET DBG: ctl0\|SWEET DBG: panel' "$L" | head -4
echo
echo "=== GPU 扫描输出配置 ==="
grep -a 'FUXI SCANOUT\|FUXI GPU: scanout\|g4_tlb\|G4_FB' "$L" | head -6
echo
echo "=== 最后 20 行 ==="
tail -c 3000 "$L" | tr -d '\000' | tail -20
