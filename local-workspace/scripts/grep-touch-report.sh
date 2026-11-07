#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-h1/fuxi_touch.c
echo "=== 'down at' / 'up at' 的来源 ==="
grep -n 'down at\|up at\|touch %d' "$F" | head -10
echo
echo "=== ft_report 实现 ==="
awk '/^ft_report|static void[[:space:]]*$/{p=1} p{print NR": "$0} /^}/{if(p){p=0; print "---"}}' "$F" | grep -A40 'ft_report' | head -50
echo
echo "=== 上报函数附近的代码（找坐标怎么填） ==="
grep -n 'ft.x\[\|ft.y\[\|report_touch\|hid' "$F" | head -20
