#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi/shim
echo "=== 文件清单 ==="
ls
echo
echo "=== 含 framebuffer 地址的文件 ==="
grep -rn 'b8000000' . 2>/dev/null | head -10
echo
echo "=== v_baseAddr / baseAddr 出现处 ==="
grep -rn 'v_baseAddr' . 2>/dev/null | head -10
echo
echo "=== 显示初始化相关 ==="
grep -rln 'display\|panel\|dsi' --include='*.c' --include='*.h' . 2>/dev/null | head -10
