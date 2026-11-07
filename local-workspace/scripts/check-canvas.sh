#!/bin/bash
set -uo pipefail
echo "=== ADT 里的常量定义 ==="
grep -n -E '^(FB|FB_W|FB_H|FB_STRIDE|CANVAS)|FB_W *=|FB_H *=|FB_STRIDE *=' /root/ios-fuxi/tools/mkadt.py /root/ios-fuxi/tools/mkadt-fuxi.py 2>/dev/null | head -10
echo
echo "=== canvas 在别处还有吗（display-scale 等）==="
grep -n -B3 -A6 'canvas-width' /root/ios-fuxi/tools/mkadt.py | head -20
echo
echo "=== fbcon 驱动怎么用 width/height/stride ==="
grep -rn 'canvas\|fbcon' /root/ios-fuxi/xnu/fuxi-sys/*.c 2>/dev/null | head -10
